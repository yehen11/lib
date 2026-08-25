class VideoEntry {
  final String videoId;
  final String authorUserId;
  final String title;
  final String? description;
  final String? thumbnailUrl;
  final String? videoUrl;
  final List<String>? tags;
  final int? views;
  final bool? verified;
  final DateTime? verifiedDate;
  final DateTime? publishedDate;
  final bool? active;

  VideoEntry({
    required this.videoId,
    required this.authorUserId,
    required this.title,
    this.description,
    this.thumbnailUrl,
    this.videoUrl,
    this.tags,
    this.views,
    this.verified,
    this.verifiedDate,
    this.publishedDate,
    this.active,
  });

  factory VideoEntry.fromJson(Map<String, dynamic> json) {
    return VideoEntry(
      videoId: json['videoId'],
      authorUserId: json['authorUserId'],
      title: json['title'],
      description: json['description'],
      thumbnailUrl: json['thumbnailUrl'],
      videoUrl: json['videoUrl'],
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList(),
      views: json['views'],
      verified: json['verified'],
      verifiedDate: json['verifiedDate'] != null
          ? DateTime.tryParse(json['verifiedDate'])
          : null,
      publishedDate: json['publishedDate'] != null
          ? DateTime.tryParse(json['publishedDate'])
          : null,
      active: json['active'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'videoId': videoId,
      'authorUserId': authorUserId,
      'title': title,
      if (description != null) 'description': description,
      if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
      if (videoUrl != null) 'videoUrl': videoUrl,
      if (tags != null) 'tags': tags,
      if (views != null) 'views': views,
      if (verified != null) 'verified': verified,
      if (verifiedDate != null) 'verifiedDate': verifiedDate!.toIso8601String(),
      if (publishedDate != null) 'publishedDate': publishedDate!.toIso8601String(),
      if (active != null) 'active': active,
    };
  }
}
