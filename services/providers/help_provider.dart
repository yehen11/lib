import 'package:adgo_mobile/services/models/help_model.dart';
import 'package:adgo_mobile/services/repositories/help_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final helpRepositoryProvider = Provider<HelpRepository>((ref) {
  return HelpRepository();
});

final helpDataProvider = FutureProvider<HelpModel>((ref) async {
  final repository = ref.read(helpRepositoryProvider);
  return await repository.getHelpInfo();
});