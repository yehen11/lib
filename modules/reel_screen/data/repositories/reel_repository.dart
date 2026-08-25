/*
@Author - Anuruddha
@Date - 2025/03/1
 */


import 'package:adgo_mobile/modules/reel_screen/data/apis/ireelapi.dart';
import 'package:adgo_mobile/modules/reel_screen/model/reel.dart';

class ReelRepository {
  final IReelApi reelApi;

  ReelRepository(this.reelApi);

  Future<List<Reel>> getReels() async {
    return await reelApi.getReels(); 
  }
}
