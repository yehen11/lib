import 'dart:io';

import 'package:adgo_mobile/modules/shop/model/shop_form_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShopFormNotifier extends StateNotifier<ShopFormModel> {
  ShopFormNotifier() : super(ShopFormModel());

  void updateShopId(String? shopId) => state = state..shopId = shopId;
  void updateName(String name) => state = state..name = name;
  void updateEmail(String email) => state = state..email = email;
  void updatePhone(String phone) => state = state..phone = phone;

  void updateFBLink(String facebook) => state = state..facebook = facebook;
  void updateInstaLink(String instagram) => state = state..instagram = instagram;
  void updateTWLink(String twitter) => state = state..twitter = twitter;

  void updateBannerImage(File? image) => state = state..bannerImage = image;
  void updateLogoImage(File? image) => state = state..logoImage = image;


  void updateHandle(String handle) => state = state..handle = handle;
  void updateBannerUrl(String url) => state = state..bannerUrl = url;
  void updateLogoUrl(String url) => state = state..logoUrl = url;
  void updateDescription(String description) => state = state..description = description;
  void updateCategory(String category) => state = state..category = category;
  void updateContact(String email, String phone, Map<String, String> socials) {
    state = state
      ..email = email
      ..phoneNumber = phone
      ..socialMediaLinks = socials;
  }

  void updateAll(ShopFormModel newState) => state = newState;

  void reset() => state = ShopFormModel();
}
