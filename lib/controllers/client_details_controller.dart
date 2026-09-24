import 'package:docelix_mobileapp/components/app_snackbar.dart';
import 'package:docelix_mobileapp/models/clients_screen_model.dart';
import 'package:get/get.dart';

class ClientDetailsController extends GetxController {
  late final ClientScreenModel client;

  @override
  void onInit() {
    super.onInit();

    final arguments = Get.arguments;

    if (arguments is ClientScreenModel) {
      client = arguments;
    } else {
      Get.back();

      AppSnackbar.error(
        title: 'Error',
        message:'Client information is not available.',
      );

    }
  }
}