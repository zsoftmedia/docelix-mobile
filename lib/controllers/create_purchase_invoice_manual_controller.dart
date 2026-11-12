import 'package:get/get.dart';

class CreatePurchaseInvoiceManualController extends GetxController {
  final RxInt selectedTabIndex = 0.obs;

  static const tabs = <String>[
    'Invoice',
    'Receipt',
    'Credit note',
  ];

  void selectTab(int index) {
    selectedTabIndex.value = index;
  }
}