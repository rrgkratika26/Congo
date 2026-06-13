// app_globals.dart

import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../../util/sharedpreference/shared_preference.dart';

class AppGlobals {
  static String unit = "";
}


class AppController extends GetxController {
  var unit = "".obs;

  Future<void> loadUnit() async {
    unit.value = await AppSession.getUnit() ?? "";
  }
}