import 'package:adgo_mobile/modules/reel_screen/data/repositories/reel_repository.dart';
import 'package:adgo_mobile/modules/reel_screen/data/services/ireel_service.dart';
import 'package:adgo_mobile/modules/reel_screen/model/reel.dart';

class ReelService implements IReelService{

  @override
  final ReelRepository repository;

  ReelService(this.repository);

  @override
  Future<List<Reel>> getReels() async {
    return await repository.getReels();
  }
}
