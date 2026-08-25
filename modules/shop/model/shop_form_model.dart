import 'dart:io';

class ShopFormModel {
  String? name;
  String? handle;
  String? shopId;
  String? bannerUrl;
  String? logoUrl;
  String? description;
  String? category;
  String? email;
  String? phoneNumber;

  String? phone;
  String? facebook;
  String? instagram;
  String? twitter;

  File? bannerImage;
  File? logoImage;

  Map<String, String> socialMediaLinks = {};
  bool? active;

  ShopFormModel();
}
