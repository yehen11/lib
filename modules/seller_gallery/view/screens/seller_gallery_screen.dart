import 'package:adgo_mobile/services/providers/shop_provider.dart';
import 'package:adgo_mobile/themes/utils.dart';
import 'package:adgo_mobile/widgets/GalleryItem.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SellerGalleryScreen extends ConsumerStatefulWidget {
  const SellerGalleryScreen({super.key});

  @override
  ConsumerState<SellerGalleryScreen> createState() =>
      _SellerGalleryScreenState();
}

class _SellerGalleryScreenState extends ConsumerState<SellerGalleryScreen> {
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString("userId");

    setState(() {
      userId = id;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final shopAsync = ref.watch(shopsByUserProvider(userId!));

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Seller Gallery'),
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        body: shopAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text("Error: $err")),
          data: (shops) {
            if (shops.isEmpty) {
              return const Center(child: Text("No shop found for this user."));
            }

            final shop = shops.first;

            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          backgroundImage: NetworkImage(
                            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQltIAHUYT6u7GKhj-UIX_fU1Pf0sySCFH_aw&s',
                          ),
                          radius: 80,
                        ),
                        const SizedBox(width: 15),

                        /// Only name is dynamic
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// DYNAMIC FIELD
                              Text(
                                shop.name,
                                style: TextStyle(
                                  color: primaryDarkColor,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              /// STATIC FIELDS
                              Text(
                                "@fini_productions",
                                style: TextStyle(
                                  color: primaryDarkColor.withOpacity(0.5),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "25 videos",
                                style: TextStyle(
                                  color: primaryDarkColor.withOpacity(0.5),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),
                    Divider(
                      color: primaryDarkColor.withOpacity(0.2),
                      thickness: 1,
                    ),
                    const SizedBox(height: 10),

                    /// STATIC GALLERY ITEMS
                    GalleryItem(
                      imageUrl:
                      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQltIAHUYT6u7GKhj-UIX_fU1Pf0sySCFH_aw&s',
                      title: 'Fanta from PS around Colombo',
                      duration: '15h 23min',
                      views: '26 k',
                      bookmarks: '236',
                    ),
                    const SizedBox(height: 10),
                    GalleryItem(
                      imageUrl:
                      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS2d7bF1q2WBQnHUhqaR2OuxjFiv_EIWBwqow&s',
                      title: 'Ice Cream from Fini around Colombo',
                      duration: '24h 00min',
                      views: '2 k',
                      bookmarks: '100',
                    ),
                    const SizedBox(height: 10),
                    GalleryItem(
                      imageUrl:
                      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSanZcPmlTnx5BIuKxqObWtFncZXQdkdpIp1A&s',
                      title: 'Rice from Fini around Colombo',
                      duration: '15h 23min',
                      views: '2 k',
                      bookmarks: '100',
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}