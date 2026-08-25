import '../../model/reel.dart';

abstract class IReelApi {

  IReelApi();
  Future<List<Reel>> getReels();
}