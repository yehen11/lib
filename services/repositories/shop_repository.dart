/*
@Author - Anuruddha
@Date - 2025/05/09
 */

import 'package:dio/dio.dart';
import '../services/shop_service.dart';

class ShopRepository {
  final ShopService _shopService = ShopService();


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
  }) async {
    try {
      final response = await _shopService.setShop(
        name: name,
        handle: handle,
        ownerId: ownerId,
        bannerUrl: bannerUrl,
        logoUrl: logoUrl,
        description: description,
        category: category,
        email: email,
        phoneNumber: phoneNumber,
        socialMediaLinks: socialMediaLinks,
        active: active
      );
      return response;
    } catch (e, stackTrace) {
      rethrow;
    }
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
  }) async {
    try {
      final response = await _shopService.updateShop(
        shopId: shopId,
        ownerId: ownerId,
        name: name,
        handle: handle,
        bannerUrl: bannerUrl,
        logoUrl: logoUrl,
        description: description,
        category: category,
        email: email,
        phoneNumber: phoneNumber,
        socialMediaLinks: socialMediaLinks,
        active: active,
      );
      return response;
    } catch (e, stackTrace) {
      rethrow;
    }
  }

  /// Delete a shop
  Future<Response> deleteShop(String shopId) async {
    try {
      final response = await _shopService.deleteShop(shopId);
      return response;
    } catch (e, stackTrace) {
      rethrow;
    }
  }

  /// Get shops by a list of shop IDs
  Future<Response> getShopsByShopIDs({
    required Set<String> shopIds,
    bool? active,
    String? createdDate,
  }) async {
    try {
      final response = await _shopService.getShopsByShopIDs(
        shopIds: shopIds,
        active: active,
        createdDate: createdDate,
      );
      return response;
    } catch (e, stackTrace) {
      rethrow;
    }
  }

  /// Get shops by user ID
  Future<Response> getShopsByUserID({
    required String userId,
    bool? active,
    String? createdDate,
  }) async {
    try {
      final response = await _shopService.getShopsByUserID(
        userId: userId,
        active: active,
        createdDate: createdDate,
      );
      return response;
    } catch (e, stackTrace) {
      rethrow;
    }
  }

  //Get logo upload URL
  Future<Response> getShopLogoUploadUrl({
    required String userId,
    required String logoName,
  }) async {
    try {
      return await _shopService.getShopLogoUploadUrl(
        userId: userId,
        logoName: logoName,
      );
    } catch (e, stackTrace) {
      rethrow;
    }
  }

  //Get logo download URL
  Future<Response> getShopLogoDownloadUrl({
    required String logoKey,
  }) async {
    try {
      return await _shopService.getShopLogoDownloadUrl(
        logoKey: logoKey,
      );
    } catch (e, stackTrace) {
      rethrow;
    }
  }

  //Get banner upload URL
  Future<Response> getShopBannerUploadUrl({
    required String userId,
    required String bannerName,
  }) async {
    try {
      return await _shopService.getShopBannerUploadUrl(
        userId: userId,
        bannerName: bannerName,
      );
    } catch (e, stackTrace) {
      rethrow;
    }
  }

  //Get banner download URL
  Future<Response> getShopBannerDownloadUrl({
    required String bannerKey,
  }) async {
    try {
      return await _shopService.getShopBannerDownloadUrl(
        bannerKey: bannerKey,
      );
    } catch (e, stackTrace) {
      rethrow;
    }
  }

}
