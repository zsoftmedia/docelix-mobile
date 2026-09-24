import 'package:dio/dio.dart';
import 'package:docelix_mobileapp/components/app_snackbar.dart';
import 'package:docelix_mobileapp/models/invoice_item_model.dart';
import 'package:docelix_mobileapp/models/invoices_model.dart';
import 'package:docelix_mobileapp/services/dio_client.dart';
import 'package:docelix_mobileapp/utils/session_manager.dart';
import 'package:get/get.dart';

class InvoicesController extends GetxController {
  final dioClient = DioClient();
  final sessionManager = SessionManager();

  final RxBool isLoading = false.obs;

  /// Invoice list
  final RxList<InvoicesModel> invoices =
      <InvoicesModel>[].obs;


  /// Total invoices
  final RxInt totalInvoices = 0.obs;

  /// Pagination
  final RxInt currentPage = 1.obs;
  final RxInt limit = 20.obs;

  @override
  void onInit() {
    super.onInit();

    getInvoices();
  }

  // ============================================================
  // GET INVOICES
  // ============================================================

  Future<void> getInvoices() async {
    try {
      isLoading.value = true;

      final accessToken = SessionManager.accessToken;
      final companyId = SessionManager.accessCompanyid;

      // ----------------------------------------------------------
      // CHECK ACCESS TOKEN
      // ----------------------------------------------------------

      if (accessToken == null || accessToken.isEmpty) {

        AppSnackbar.error(
          title: 'Error',
          message: 'Access token is not available.',
        );

        return;
      }

      // ----------------------------------------------------------
      // CHECK COMPANY ID
      // ----------------------------------------------------------

      if (companyId == null) {

        AppSnackbar.error(
          title: 'Error',
          message: 'Company ID is not available.',
        );

        return;
      }

      final int parsedCompanyId =
      int.parse(companyId.toString());

      // ----------------------------------------------------------
      // API CALL
      // ----------------------------------------------------------

      final response = await dioClient.getInvoices(
        companyId: parsedCompanyId,
        accessToken: accessToken,
      );

      // ----------------------------------------------------------
      // HANDLE RESPONSE
      // ----------------------------------------------------------

      if (response.statusCode == 200 &&
          response.data != null) {
        final data = response.data;

        if (data is List) {
          invoices.value = data
              .map(
                (item) => InvoicesModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
              .toList();

          totalInvoices.value = invoices.length;

          /*print('================================');
          print('INVOICES LOADED');
          print('Total: ${totalInvoices.value}');
          print('Items: ${invoices.length}');
          print('================================');*/
        } else {
          invoices.clear();
          totalInvoices.value = 0;

          /*print('================================');
          print('INVALID INVOICES RESPONSE');
          print('Response: $data');
          print('================================');*/
        }
      }
    } on DioException catch (e) {
      /*print('================================');
      print('GET INVOICES ERROR');
      print('Status Code: ${e.response?.statusCode}');
      print('Response: ${e.response?.data}');
      print('Message: ${e.message}');
      print('================================');*/

      AppSnackbar.error(
        title: 'Error',
        message:  e.response?.data?['message']?.toString() ??
            e.message ??
            'Unable to load invoices.',
      );

    } catch (e) {
     /* print('================================');
      print('GET INVOICES EXCEPTION');
      print(e);
      print('================================');*/

      AppSnackbar.error(
        title: 'Error',
        message:  e.toString(),
      );

    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> refreshInvoices() async {
    currentPage.value = 1;
    await getInvoices();
  }
}