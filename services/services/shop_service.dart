/*
@Author - Anuruddha
@Date - 2025/05/09
 */

import 'package:adgo_mobile/services/core/api_client.dart';
import 'package:adgo_mobile/services/core/endpoints.dart';
import 'package:dio/dio.dart';

class ShopService {
  final _dio = ApiClient.dio;


  Future<Response> setShop({
    required String name,
    required String handle,
    required String ownerId,
    required String bannerUrl,
    required String logoUrl,
    required String description,
    required String category,
    required String email,
    required String phoneNumber,
    required Map<String, String> socialMediaLinks,
    required bool active,
  }) {

    return _dio.post(
      Endpoints.setShop,
      data: {
        'name': name,
        'handle': handle,
        'ownerId': ownerId,
        'bannerUrl': bannerUrl,
        'logoUrl': logoUrl,
        'description': description,
        'category': category,
        'contact': {
          'email': email,
          'phoneNumber': phoneNumber,
          'socialMediaLinks': socialMediaLinks
        },
      }
    );
  }



  /// Update an existing shop
  Future<Response> updateShop({
    required String shopId,
    String? ownerId,
    String? name,
    String? handle,
    String? bannerUrl,
    String? logoUrl,
    String? description,
    String? category,
    String? email,
    String? phoneNumber,
    Map<String, String>? socialMediaLinks,
    bool? active,
  }) {
    return _dio.post(
      Endpoints.updateShop,
      data: {
        'shopId': shopId,
        if (ownerId != null) 'ownerId': ownerId,
        if (name != null) 'name': name,
        if (handle != null) 'handle': handle,
        if (bannerUrl != null) 'bannerUrl': bannerUrl,
        if (logoUrl != null) 'logoUrl': logoUrl,
        if (description != null) 'description': description,
        if (category != null) 'category': category,
        if (email != null || phoneNumber != null || socialMediaLinks != null)
          'contact': {
            if (email != null) 'email': email,
            if (phoneNumber != null) 'phoneNumber': phoneNumber,
            if (socialMediaLinks != null) 'socialMediaLinks': socialMediaLinks,
          },
        if (active != null) 'active': active,
      },
    );
  }

  /// Delete a shop by ID
  Future<Response> deleteShop(String shopId) {
    return _dio.post(
      Endpoints.deleteShop,
      queryParameters: {
        'shopId': shopId,
      },
    );
  }

  /// Get shops by a list of shop IDs
  Future<Response> getShopsByShopIDs({
    required Set<String> shopIds,
    bool? active,
    String? createdDate, // ISO 8601
  }) {
    return _dio.get(
      Endpoints.getShopsByShopIDs,
      queryParameters: {
        'shopIds': shopIds.toList(),
        if (active != null) 'active': active,
        if (createdDate != null) 'createdDate': createdDate,
      },
    );
  }

  /// Get shops by user ID
  Future<Response> getShopsByUserID({
    required String userId,
    bool? active,
    String? createdDate,
  }) {
    return _dio.get(
      Endpoints.getShopsByUserID,
      queryParameters: {
        'userId': userId,
        if (active != null) 'active': active,
        if (createdDate != null) 'createdDate': createdDate,
      },
    );
  }


  /// Get presigned upload URL for shop logo
  Future<Response> getShopLogoUploadUrl({
    required String userId,
    required String logoName,
  }) {
    return _dio.get(
      Endpoints.getShopLogoUploadUrl,
      queryParameters: {
        'userId': userId,
        'logoName': logoName,
      },
    );
  }

  /// Get presigned download URL for shop logo
  Future<Response> getShopLogoDownloadUrl({
    required String logoKey,
  }) {
    return _dio.get(
      Endpoints.getShopLogoDownloadUrl,
      queryParameters: {
        'logoKey': logoKey,
      },
    );
  }

  /// Get presigned upload URL for shop banner
  Future<Response> getShopBannerUploadUrl({
    required String userId,
    required String bannerName,
  }) {
    return _dio.get(
      Endpoints.getShopBannerUploadUrl,
      queryParameters: {
        'userId': userId,
        'bannerName': bannerName,
      },
    );
  }

  /// Get presigned download URL for shop banner
  Future<Response> getShopBannerDownloadUrl({
    required String bannerKey,
  }) {
    return _dio.get(
      Endpoints.getShopBannerDownloadUrl,
      queryParameters: {
        'bannerKey': bannerKey,
      },
    );
  }



}
