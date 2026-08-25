import 'package:adgo_mobile/modules/shop/view/controllers/shop_provider.dart';
import 'package:adgo_mobile/modules/shop/view/screens/welcome_screen.dart';
import 'package:adgo_mobile/themes/Utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShopLiveScreen extends ConsumerWidget {
  const ShopLiveScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shopForm = ref.read(shopFormProvider);
    final handle = shopForm.handle ?? 'defaultShop';
    final shopHandle = handle.startsWith('@') ? handle : '@$handle';
    final shopName = shopForm.name ?? 'Your Shop';
    
    return Scaffold(
      body: Center(
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: primaryDarkColor.withAlpha((0.3 * 255).toInt()),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Shop Live!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: primaryDarkColor,
                  ),
                ),
                const SizedBox(height: 20),
                
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Colors.lightGreen,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: whiteColor,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),
                
                Text(
                  '$shopName is now live!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: primaryDarkColor,
                  ),
                ),
                const SizedBox(height: 12),
                
                Text(
                  'Congratulations on setting up your shop.\nStart adding products to begin selling.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                  fontSize: 16,
                  color: primaryDarkColor..withAlpha((0.3 * 255).toInt()),
                  ),
                ),
                const SizedBox(height: 24),
                
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: shopHandle));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Shop handle copied to clipboard')),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: primaryDarkColor.withAlpha((0.1 * 255).toInt())),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      shopHandle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: primaryLightColor,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => WelcomeScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                  backgroundColor: primaryLightColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  minimumSize: const Size(double.infinity, 50), 
                  ),
                  child: Text(
                  'Visit My Shop',
                  style: TextStyle(
                    color: whiteColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  ),
                ),
                const SizedBox(height: 16),
                
              ],
            ),
          ),
        ),
      ),
    );
  }
}