/*
@Author - Anuruddha
@Date - 2025/05/09
 */


import 'package:adgo_mobile/services/models/ping_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/user_repository.dart';

final userRepoProvider = Provider<UserRepository>((ref) => UserRepository());

final pingProvider = FutureProvider<PingModel>((ref) async {
  final repo = ref.read(userRepoProvider);
  return repo.getPing();
});
