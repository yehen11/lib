import 'dart:io';

class VideoFormModel {
  File? thumbnailFile;
  File? videoFile;
  String? thumbnailKey;
  String? videoKey;
  String? title;
  String? description;
  String? phone;
  String? website;
  String? address;
  String? userId;
  List<String>? tags;

  VideoFormModel({
    this.thumbnailFile,
    this.videoFile,
    this.thumbnailKey,
    this.videoKey,
    this.title,
    this.description,
    this.phone,
    this.website,
    this.address,
    this.userId,
    this.tags
  });

  VideoFormModel copyWith({
    File? thumbnailFile,
    File? videoFile,
    String? thumbnailKey,
    String? videoKey,
    String? title,
    String? description,
    String? phone,
    String? website,
    String? address,
    String? userId,
    List<String>? tags
  }) {
    return VideoFormModel(
      thumbnailFile: thumbnailFile ?? this.thumbnailFile,
      videoFile: videoFile ?? this.videoFile,
      thumbnailKey: thumbnailKey ?? this.thumbnailKey,
      videoKey: videoKey ?? this.videoKey,
      title: title ?? this.title,
      description: description ?? this.description,
      phone: phone ?? this.phone,
      website: website ?? this.website,
      address: address ?? this.address,
      userId: userId ?? this.userId,
      tags: tags ?? this.tags
    );
  }
}
