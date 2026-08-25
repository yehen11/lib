import 'package:adgo_mobile/services/models/subscription_model.dart';
import 'package:adgo_mobile/services/providers/subscription_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../themes/utils.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  bool isAnnual = false;
  bool isLoading = true;
  List<Subscription> subscriptions = [];
  final List<int> subscriptionIds = [1, 2, 3];

  @override
  void initState() {
    super.initState();
    _fetchSubscriptions();
  }

  Future<void> _fetchSubscriptions() async {
    setState(() => isLoading = true);
    
    try {
      List<Subscription> fetchedSubscriptions = [];
      
      for (int id in subscriptionIds) {
        try {
          // Use ref.read to fetch data from the provider
          final subscriptionData = await ref.read(subscriptionProvider(id).future);
          
          // Convert the Map to Subscription model
          final subscription = Subscription.fromJson(subscriptionData);
          fetchedSubscriptions.add(subscription);
        } catch (e) {
          _showSnackBar('Failed to load subscription $id', isError: true);
        }
      }
      
      setState(() {
        subscriptions = fetchedSubscriptions;
        isLoading = false;
      });
      
      if (subscriptions.isEmpty) {
        _showSnackBar('No subscription plans available', isError: true);
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showSnackBar('Failed to load subscriptions', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : primaryLightColor,
        action: isError ? SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: _fetchSubscriptions,
        ) : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryLightColor,
      appBar: AppBar(
        title: const Text('Subscription Plans'),
        backgroundColor: primaryDarkColor,
        foregroundColor: secondaryLightColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchSubscriptions,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: primaryLightColor))
          : subscriptions.isEmpty
              ? Center(child: Text('No plans available', style: TextStyle(fontSize: 16, color: primaryDarkColor)))
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose Your Plan',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryDarkColor),
          ),
          const SizedBox(height: 16),
          _buildToggle(),
          const SizedBox(height: 24),
          ...subscriptions.asMap().entries.map((entry) {
            final subscription = entry.value;
            final isMostPopular = entry.key == 1;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildSubscriptionCard(subscription, isMostPopular),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildToggle() {
    return Center(
      child: Container(
        width: 200,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(25),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              left: isAnnual ? 100 : 0,
              top: 0,
              bottom: 0,
              width: 100,
              child: Container(
                decoration: BoxDecoration(
                  color: primaryLightColor,
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => isAnnual = false),
                    child: Center(
                      child: Text(
                        'Monthly',
                        style: TextStyle(
                          color: !isAnnual ? whiteColor : primaryDarkColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => isAnnual = true),
                    child: Center(
                      child: Text(
                        'Annual',
                        style: TextStyle(
                          color: isAnnual ? whiteColor : primaryDarkColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionCard(Subscription subscription, bool isMostPopular) {
    final currentPrice = isAnnual ? subscription.discountYearlyPrice : subscription.discountMonthlyPrice;
    final originalPrice = isAnnual ? subscription.actualYearlyPrice : subscription.actualMonthlyPrice;
    final billingCycle = isAnnual ? '/year' : '/month';
    final hasDiscount = currentPrice < originalPrice;
    final monthlyEquivalent = isAnnual ? (subscription.discountYearlyPrice / 12).toStringAsFixed(2) : null;
    final features = subscription.features;

    return Card(
      elevation: isMostPopular ? 8 : 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isMostPopular ? BorderSide(color: primaryLightColor, width: 2) : BorderSide.none,
      ),
      child: Column(
        children: [
          if (isMostPopular)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryLightColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              ),
              child: Text(
                '⭐ Most Popular',
                textAlign: TextAlign.center,
                style: TextStyle(color: whiteColor, fontWeight: FontWeight.bold),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      subscription.name,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryDarkColor),
                    ),
                    if (hasDiscount)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${subscription.discountPercentage.toInt()}% OFF',
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  subscription.description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (hasDiscount) ...[
                      Text(
                        '\$${originalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      '\$${currentPrice.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryDarkColor),
                    ),
                    Text(
                      billingCycle,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
                if (isAnnual && monthlyEquivalent != null)
                  Text(
                    'Just \$$monthlyEquivalent/month',
                    style: TextStyle(fontSize: 12, color: Colors.green[700]),
                  ),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: features.length,
                  itemBuilder: (context, index) {
                    return Row(
                      children: [
                        Icon(Icons.check_circle, color: primaryLightColor, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            features[index],
                            style: TextStyle(fontSize: 14, color: primaryDarkColor),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _handleSubscription(subscription),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isMostPopular ? primaryDarkColor : primaryLightColor,
                      foregroundColor: whiteColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(isAnnual ? 'Subscribe Annually' : 'Subscribe Monthly'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleSubscription(Subscription subscription) {
    final billingCycle = isAnnual ? 'annual' : 'monthly';
    final price = isAnnual ? subscription.discountYearlyPrice : subscription.discountMonthlyPrice;
    
    _showSnackBar('Processing ${subscription.name} $billingCycle subscription (\$${price.toStringAsFixed(2)})...');
    
    // Simulate processing
    Future.delayed(const Duration(seconds: 2), () {
      _showSnackBar('Subscription activated successfully! Welcome to ${subscription.name}.');
    });
  }
}