class Reel {
  final String id;
  final String videoUrl;
  final String title;
  final String? shopId;
  final String? shopHandle;
  final String? description;
  
  Reel({
    required this.id,
    required this.videoUrl,
    required this.title, 
    this.shopId, 
    this.shopHandle,
    this.description,
  });

  factory Reel.fromJson(Map<String, dynamic> json) {
    return Reel(
      id: json['id'],
      videoUrl: json['videoUrl'],
      title: json['title'],
      shopId: json['shopId'],
      shopHandle: json['shopHandle'],
      description: json['description'],
    );
  }
}
