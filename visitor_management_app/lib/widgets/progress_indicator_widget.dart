import 'package:flutter_easyloading/flutter_easyloading.dart';

class ShowToastDialog {
  static void showLoader([String message = "Please wait..."]) {
    EasyLoading.show(status: message, maskType: EasyLoadingMaskType.black);
  }

  static void closeLoader() {
    EasyLoading.dismiss();
  }
}
