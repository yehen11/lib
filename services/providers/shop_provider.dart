/*
@Author - Anuruddha
@Date - 2025/05/09
*/

import 'package:adgo_mobile/services/models/shop_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/shop_repository.dart';

final shopRepoProvider = Provider<ShopRepository>((ref) => ShopRepository());





/// 🔹 Fetch shops by userId
final shopsByUserProvider = FutureProvider.family<List<ShopModel>, String>((ref, userId) async {
  final repo = ref.read(shopRepoProvider);
  final response = await repo.getShopsByUserID(userId: userId);
  final data = response.data as List;
  return data.map((json) => ShopModel.fromJson(json)).toList();
});

/// 🔹 Fetch shops by shopIds
final shopsByShopIdsProvider = FutureProvider.family<List<ShopModel>, Set<String>>((ref, shopIds) async {
  final repo = ref.read(shopRepoProvider);
  final response = await repo.getShopsByShopIDs(shopIds: shopIds);
  final data = response.data as List;
  return data.map((json) => ShopModel.fromJson(json)).toList();
});
/*
/// 🔹 Set shop
final setShopProvider = FutureProvider.family<void, Map<String, dynamic>>((ref, shopDTO) async {
  final repo = ref.read(shopRepoProvider);
  await repo.setShop(shopDTO);
});

/// 🔹 Update shop
final updateShopProvider = FutureProvider.family<void, Map<String, dynamic>>((ref, shopDTO) async {
  final repo = ref.read(shopRepoProvider);
  await repo.updateShop(shopDTO);
});

/// 🔹 Delete shop
final deleteShopProvider = FutureProvider.family<void, String>((ref, shopId) async {
  final repo = ref.read(shopRepoProvider);
  await repo.deleteShop(shopId);
});*/
