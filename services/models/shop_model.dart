class ContactModel {
  final String email;
  final String phoneNumber;
  final Map<String, String> socialMediaLinks;

  ContactModel({
    required this.email,
    required this.phoneNumber,
    required this.socialMediaLinks,
  });

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    final socialLinks = json['socialMediaLinks'] as Map<String, dynamic>? ?? {};
    return ContactModel(
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      socialMediaLinks:
          socialLinks.map((key, value) => MapEntry(key, value.toString())),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'phoneNumber': phoneNumber,
      'socialMediaLinks': socialMediaLinks,
    };
  }
}

class ShopModel {
  final String shopId;
  final String ownerId;
  final String name;
  final String handle;
  final String bannerUrl;
  final String logoUrl;
  final String description;
  final String category;
  final ContactModel contact;
  final bool active;
  final double? createdDate;

  ShopModel({
    required this.shopId,
    required this.ownerId,
    required this.name,
    required this.handle,
    required this.bannerUrl,
    required this.logoUrl,
    required this.description,
    required this.category,
    required this.contact,
    required this.active,
    this.createdDate,
  });

  factory ShopModel.fromJson(Map<String, dynamic> json) {
    return ShopModel(
      shopId: json['shopId'] ?? '',
      ownerId: json['ownerId'] ?? '',
      name: json['name'] ?? '',
      handle: json['handle'] ?? '',
      bannerUrl: json['bannerUrl'] ?? '',
      logoUrl: json['logoUrl'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      contact: ContactModel.fromJson(json['contact'] ?? {}),
      active: json['active'] ?? false,
      createdDate: json['createdDate']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shopId': shopId,
      'ownerId': ownerId,
      'name': name,
      'handle': handle,
      'bannerUrl': bannerUrl,
      'logoUrl': logoUrl,
      'description': description,
      'category': category,
      'contact': contact.toJson(),
      'active': active,
      if (createdDate != null) 'createdDate': createdDate,
    };
  }
}
