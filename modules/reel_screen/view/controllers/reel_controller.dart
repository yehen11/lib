/*
@Author - Anuruddha
@Date - 2025/03/1
 */

import 'package:adgo_mobile/modules/reel_screen/data/apis/reel_api.dart';
import 'package:adgo_mobile/modules/reel_screen/data/repositories/reel_repository.dart';
import 'package:adgo_mobile/modules/reel_screen/data/services/reel_service.dart';
import 'package:adgo_mobile/modules/reel_screen/model/reel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final _reelApiProvider = Provider<ReelApi>((ref) => ReelApi());

final reelRepositoryProvider = Provider<ReelRepository>((ref) {
  return ReelRepository(ref.read(_reelApiProvider));
});

final reelServiceProvider = Provider<ReelService>((ref) {
  return ReelService(ref.read(reelRepositoryProvider));
});

final reelsProvider = FutureProvider<List<Reel>>((ref) async {
  return await ref.read(reelServiceProvider).getReels();
});


