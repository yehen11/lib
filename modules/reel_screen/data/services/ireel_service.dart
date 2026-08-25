/*
@Author - Anuruddha
@Date - 2025/03/1
 */

import 'package:adgo_mobile/modules/reel_screen/model/reel.dart';
import '../repositories/reel_repository.dart';

abstract class IReelService {
  final ReelRepository repository;

  IReelService(this.repository);

  Future<List<Reel>> getReels();
}