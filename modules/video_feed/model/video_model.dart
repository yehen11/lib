class VideoModel {
  final String id;
  final String thumbnail;
  final String videoUrl;
  final String title;
  final String? shopId;
  final String? shopHandle;
  final String? description;
  
  VideoModel({
    required this.id,
    required this.thumbnail,
    required this.videoUrl,
    required this.title,
    this.shopId,
    this.shopHandle,
    this.description,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'],
      thumbnail: json['thumbnail'],
      videoUrl: json['videoUrl'],
      title: json['title'],
      shopId: json['shopId'],
      shopHandle: json['shopHandle'],
      description: json['description'],
    );
  }
}
