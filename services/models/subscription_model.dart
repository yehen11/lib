class Subscription {
  final int id;
  final String name;
  final String description;
  final double actualMonthlyPrice;
  final double actualYearlyPrice;
  final double discountMonthlyPrice;
  final double discountYearlyPrice;
  final double discountPercentage;
  final List<String> features;

  Subscription({
    required this.id,
    required this.name,
    required this.description,
    required this.actualMonthlyPrice,
    required this.actualYearlyPrice,
    required this.discountMonthlyPrice,
    required this.discountYearlyPrice,
    required this.discountPercentage,
    required this.features,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      actualMonthlyPrice: json['actualMonthlyPrice'].toDouble(),
      actualYearlyPrice: json['actualYearlyPrice'].toDouble(),
      discountMonthlyPrice: json['discountMonthlyPrice'].toDouble(),
      discountYearlyPrice: json['discountYearlyPrice'].toDouble(),
      discountPercentage: json['discountPercentage'].toDouble(),
      features: List<String>.from(json['features'] ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'actualMonthlyPrice': actualMonthlyPrice,
      'actualYearlyPrice': actualYearlyPrice,
      'discountMonthlyPrice': discountMonthlyPrice,
      'discountYearlyPrice': discountYearlyPrice,
      'discountPercentage': discountPercentage,
      'features': features,
    };
  }
}