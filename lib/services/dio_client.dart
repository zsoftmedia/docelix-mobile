
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

  // ==============================
  // GET INVOICE ITEMS
  // ==============================

  Future<Response> getInvoiceItems({
    required int invoiceId,
    required String accessToken,
  }) async {
    return await _dio.get(
      '${ApiConstants.baseUrl}/invoices/$invoiceId/items',
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      ),
    );
  }

    // ==============================
    // GET CLIENTS
    // ==============================

  Future<Response> getClients({
    required int companyId,
    required String accessToken,
  }) async {
    return await _dio.get(
      '${ApiConstants.baseUrl}/clients',
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

  // ==============================
  // GET CLIENTS FOR CLIENTS SCREEN
  // ==============================

  Future<Response> getClientsScreen({
    required int companyId,
    required String accessToken,
    int page = 1,
    int pageSize = 10,
  }) async {
    return await _dio.get(
      '${ApiConstants.baseUrl}/clients',
      queryParameters: {
        'company_id': companyId,
        'page': page,
        'pageSize': pageSize,
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
  // GET CATALOG LIST
  // ==============================
  Future<Response> getCatalog({
    required int companyId,
    required String accessToken,
    required int page,
    required int pageSize,
  }) async {
    return await _dio.get(
      '${ApiConstants.baseUrl}/catalog',
      queryParameters: {
        'company_id': companyId,
        'page': page,
        'pageSize': pageSize,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      ),
    );
  }

    // ==============================
    // DELETE INCOMING INVOICE
    // ==============================

  Future<Response> deleteIncomingInvoice({
    required int invoiceId,
    required String accessToken,
  }) async {
    return await _dio.delete(
      '${ApiConstants.baseUrl}/incoming-invoices/$invoiceId',
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      ),
    );
  }

  // ==============================
  // DELETE INVOICE
  // ==============================
  Future<Response> deleteInvoiceJournalEntries({
    required int companyId,
    required int sourceId,
    required String sourceType,
    required String accessToken,
  }) async {
    return await _dio.delete(
      '${ApiConstants.baseUrl}/ledger/journal-entries',
      queryParameters: {
        'company_id': companyId,
        'source_id': sourceId,
        'source_type': sourceType,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      ),
    );
  }

}