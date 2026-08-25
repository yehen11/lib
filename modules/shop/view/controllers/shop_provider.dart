import 'package:adgo_mobile/modules/shop/model/shop_form_model.dart';
import 'package:adgo_mobile/modules/shop/view/controllers/shop_state_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final shopFormProvider =
StateNotifierProvider<ShopFormNotifier, ShopFormModel>(
        (ref) => ShopFormNotifier());
