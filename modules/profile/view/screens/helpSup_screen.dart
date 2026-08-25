import 'package:adgo_mobile/services/providers/help_provider.dart';
import 'package:adgo_mobile/themes/Utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportPage extends ConsumerStatefulWidget {
  const HelpSupportPage({Key? key}) : super(key: key);

  @override
  ConsumerState<HelpSupportPage> createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends ConsumerState<HelpSupportPage> {
  int? expandedFaqIndex;

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    await _tryLaunchInOrder([emailUri], errorMessage: 'Could not open email client');
  }

  Future<void> _launchPhone(String phone) async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: phone,
    );
    await _tryLaunchInOrder([phoneUri], errorMessage: 'Could not initiate call');
  }

  Future<void> _openChat(String phone) async {
    // Open WhatsApp chat via universal web links
    const String message = 'Hello, I need help with my order.';
    
    // Clean the phone number: remove +, spaces, dashes, parentheses
    final number = phone.replaceAll(RegExp(r'[^\d]'), '');

    // Encode the message properly for URL
    final encodedMessage = Uri.encodeComponent(message);

    // Try multiple WhatsApp URLs with different launch modes
    final waMe = Uri.parse('https://wa.me/$number?text=$encodedMessage');
    final apiWhatsApp = Uri.parse(
        'https://api.whatsapp.com/send?phone=$number&text=$encodedMessage');

    // Try wa.me first with external app (opens WhatsApp directly)
    if (await canLaunchUrl(waMe)) {
      if (await launchUrl(waMe, mode: LaunchMode.externalApplication)) return;
    }

    // Try api.whatsapp.com with external app
    if (await canLaunchUrl(apiWhatsApp)) {
      if (await launchUrl(apiWhatsApp, mode: LaunchMode.externalApplication))
        return;
    }

    // Fallback: try opening in browser
    if (await launchUrl(waMe, mode: LaunchMode.externalNonBrowserApplication))
      return;
    if (await launchUrl(apiWhatsApp, mode: LaunchMode.platformDefault)) return;

    _showError(
        'Could not open WhatsApp. Please ensure WhatsApp is installed or try email/phone.');
  }

  Future<void> _tryLaunchInOrder(List<Uri> uris, {required String errorMessage}) async {
    for (final uri in uris) {
      // Try external app first, then default, then in-app browser view
      if (await launchUrl(uri, mode: LaunchMode.externalApplication)) return;
      if (await launchUrl(uri, mode: LaunchMode.platformDefault)) return;
      if (await launchUrl(uri, mode: LaunchMode.inAppBrowserView)) return;
    }
    _showError(errorMessage);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch the help data provider - this will automatically rebuild when data loads
    final helpAsync = ref.watch(helpDataProvider);

    return Scaffold(
      backgroundColor: whiteColor,
      body: SafeArea(
        child: helpAsync.when(
          // Loading state - show spinner while fetching data
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          // Error state - show error message with retry button
          error: (error, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      size: 64, color: Colors.red.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load help information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryDarkColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Refresh the provider to retry loading
                      ref.invalidate(helpDataProvider);
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryLightColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Data state - render the UI with fetched data
          data: (helpData) => SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: primaryLightColor,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text(
                      'Help & Support',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: whiteColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'How can we help you?',
                      style: TextStyle(
                        fontSize: 14,
                        color: secondaryLightColor,
                      ),
                    ),
                  ],
                ),
              ),

              // Contact Section
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text(
                      'Get in Touch',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: primaryDarkColor,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Email Button
                    _buildContactCard(
                      icon: Icons.email_outlined,
                      title: 'Email Us',
                        subtitle: helpData.email,
                        onTap: () => _launchEmail(helpData.email),
                    ),
                    const SizedBox(height: 12),

                    // Phone Button
                    _buildContactCard(
                      icon: Icons.phone_outlined,
                      title: 'Call Us',
                        subtitle: helpData.phone,
                        onTap: () => _launchPhone(helpData.phone),
                    ),
                    const SizedBox(height: 12),

                    // Chat Button
                    InkWell(
                        onTap: () => _openChat(helpData.phone),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: primaryLightColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                             Icon(
                              Icons.chat_bubble_outline,
                              color: whiteColor,
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                   Text(
                                    'Chat with Us',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: whiteColor,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'We typically reply in minutes',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: secondaryLightColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // FAQ Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Frequently Asked Questions',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: primaryDarkColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                      // FAQ Items - using dynamic data from API
                      ...List.generate(
                        helpData.faqs.length,
                        (index) => _buildFaqItem(helpData.faqs, index),
                      ),
                  ],
                ),
              ),

              // Support Hours
              Padding(
                padding: const EdgeInsets.all(24),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryLightColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: primaryLightColor.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Support Hours',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: primaryDarkColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                          helpData.supportHours,
                        style: TextStyle(
                          fontSize: 13,
                          color: primaryDarkColor.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: primaryLightColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: primaryLightColor,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: primaryDarkColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: primaryDarkColor.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem(List<dynamic> faqs, int index) {
    final faq = faqs[index];
    final isExpanded = expandedFaqIndex == index;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: secondaryLightColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                expandedFaqIndex = isExpanded ? null : index;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      faq.question,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: primaryDarkColor,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: primaryDarkColor.withOpacity(0.7),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              decoration:  BoxDecoration(
                color: primaryLightColor.withOpacity(0.1),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Text(
                faq.answer,
                style: TextStyle(
                  fontSize: 13,
                  color: primaryDarkColor.withOpacity(0.7),
                  height: 1.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}