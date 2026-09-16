
import 'package:dio/dio.dart';
import 'package:docelix_mobileapp/config/api_constants.dart';

class DioClient {

  final Dio _dio = Dio();

  // ==============================
  // GET USER
  // ==============================
  Future<Response> getMe(String url, String accessToken) async {
    return await _dio.get(
      '${ApiConstants.baseUrl}$url',
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      ),
    );
  }

// ==============================
// GET DASHBOARD ACCOUNTING
// ==============================

  Future<Response> getDashboardAccounting({
    required int companyId,
    required String from,
    required String to,
    required String compareFrom,
    required String compareTo,
    required String groupBy,
    required String accessToken,
  }) async {
    return await _dio.get( '${ApiConstants.baseUrl}/dashboard/accounting',
      queryParameters: {
      'company_id': companyId,
        'from': from,
        'to': to,
        'compareFrom': compareFrom,
        'compareTo': compareTo,
        'groupBy': groupBy,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      ),
    );
  }

// ==============================
// UPLOAD INCOMING INVOICE
// ==============================

  Future<Response> uploadIncomingInvoice({
    required int companyId,
    required String filePath,
    required String fileName,
    required String accessToken,
    String expenseCategory = 'other',
  }) async {
    final formData = FormData.fromMap({
      'company_id': companyId,
      'file': await MultipartFile.fromFile(
        filePath,
        filename: fileName,
      ),
      'expense_category': expenseCategory,
    });

    return await _dio.post(
      '${ApiConstants.baseUrl}/incoming-invoices/upload',
      data: formData,
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
        contentType: 'multipart/form-data',
      ),
    );
  }

  // ==============================
  // GET INCOMING INVOICES
  // ==============================

  Future<Response> getIncomingInvoices({
    required int companyId,
    required int page,
    required int limit,
    required String accessToken,
  }) async {
    return await _dio.get(
      '${ApiConstants.baseUrl}/incoming-invoices',
      queryParameters: {
        'company_id': companyId,
        'page': page,
        'limit': limit,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      ),
    );
  }


  // ==============================
  // GET INVOICES
  // ==============================

  Future<Response> getInvoices({
    required int companyId,
    required String accessToken,
  }) async {
    return await _dio.get(
      '${ApiConstants.baseUrl}/invoices',
      queryParameters: {
        'company_id': companyId,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      ),
    );
  }
}