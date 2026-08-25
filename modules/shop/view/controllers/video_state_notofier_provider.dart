import 'package:adgo_mobile/modules/shop/model/video_form_model.dart';
import 'package:adgo_mobile/modules/shop/view/controllers/video_state_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final videoFormProvider = StateNotifierProvider<VideoFormNotifier, VideoFormModel>(
      (ref) => VideoFormNotifier(),
);
