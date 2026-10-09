
import 'dart:io';

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
  // GET RECEIVALBLE INVOICES
  // ==============================

  Future<Response> getReceivableInvoices({
    required int companyId,
    required String accessToken,
  }) async {
    return await _dio.get(
      '${ApiConstants.baseUrl}/accounting/receivables/invoices',
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

  // ============================================================
// GET PAYABLE BILLS
// ============================================================

  Future<Response> getPayableBills({
    required int companyId,
    required String accessToken,
  }) async {
    return await _dio.get(
      '${ApiConstants.baseUrl}/accounting/payables/bills',
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
  // GET RECEIVABLE
  // ==============================

  Future<Response> getReceivablesDashboard({
    required int companyId,
    required String from,
    required String to,
    required String accessToken,
  }) async {
    return await _dio.get(
      '${ApiConstants.baseUrl}/accounting/receivables/dashboard',
      queryParameters: {
        'company_id': companyId,
        'from': from,
        'to': to,
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
  // PROFILE UPDATE
  // ==============================

  Future<Response> updateProfile({
    required String endpoint,
    required String accessToken,
    required String username,
    String? email,
    File? avatar,
  }) async {
    final Map<String, dynamic> data = {
      'username': username,
    };

    if (email != null && email.trim().isNotEmpty) {
      data['email'] = email.trim();
    }

    // Add avatar only when user selected a new image.
    if (avatar != null) {
      data['avatar'] = await MultipartFile.fromFile(
        avatar.path,
        filename: avatar.path.split('/').last,
      );
    }

    final formData = FormData.fromMap(data);

    final String url = endpoint.startsWith('http')
        ? endpoint
        : '${ApiConstants.baseUrl}$endpoint';

    return await _dio.patch(
      url,
      data: formData,
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
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
    int pageSize = 20,
    String sort = 'name',
    String dir = 'asc',
  }) async {
    return await _dio.get(
      '${ApiConstants.baseUrl}/clients',
      queryParameters: {
        'company_id': companyId,
        'sort': sort,
        'dir': dir,
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

  /*Future<Response> getClientsScreen({
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
  }*/

  // ==============================
  // GET CATALOG LIST
  // ==============================
  Future<Response> getCatalog({
    required int companyId,
    required String accessToken,
    int page = 1,
    int pageSize = 20,
    String sort = 'article_name',
    String dir = 'asc',
  }) async {
    return await _dio.get(
      '${ApiConstants.baseUrl}/catalog',
      queryParameters: {
        'company_id': companyId,
        'sort': sort,
        'dir': dir,
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
  // UPDATE INCOMING INVOICE
  // ==============================

  Future<Response> updateIncomingInvoice({
    required int invoiceId,
    required Map<String, dynamic> data,
    required String accessToken,
  }) async {
    return await _dio.patch(
      '${ApiConstants.baseUrl}/incoming-invoices/$invoiceId',
      data: data,
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
  }

  // ==============================
  // DELETE INVOICE
  // ==============================
  Future<Response> deleteInvoice({
    required int invoiceId,
    required String accessToken,
  }) async {
    return await _dio.delete(
      '${ApiConstants.baseUrl}/invoices/$invoiceId',
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
        },
      ),
    );
  }

  // ==============================
  // DELETE JOURNAL ENTRIES INVOICE
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

  // ==============================
// CREATE CLIENT
// ==============================
  Future<Response> createClient({
    required int companyId,
    required String accessToken,
    required Map<String, dynamic> data,
  }) async {
    return await _dio.post(
      '${ApiConstants.baseUrl}/clients',
      data: {
        'company_id': companyId,
        ...data,
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
  // GET COMPANIES
  // ==============================

  Future<Response> getCompanies({
    required String accessToken,
  }) async {
    return await _dio.get(
      '${ApiConstants.baseUrl}/companies',
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      ),
    );
  }

  // ==============================
  // GET UNITS
  // ==============================
  Future<Response> getUnits({
    required String accessToken,
  }) async {
    return await _dio.get(
      '${ApiConstants.baseUrl}/units',
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      ),
    );
  }

  // ==============================
  // CREATE INVOICE
  // ==============================
  Future<Response> createInvoice({
    required String accessToken,
    required Map<String, dynamic> data,
  }) async {
    return await _dio.post(
      '${ApiConstants.baseUrl}/invoices',
      data: data,
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      ),
    );
  }


  // ==============================
  // POST CATALOGUE ITEM
  // ==============================

  Future<Response> createCatalogItem({
    required Map<String, dynamic> data,
    required String accessToken,
  }) async {
    return await _dio.post(
      '${ApiConstants.baseUrl}/catalog',
      data: data,
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
  }

  // ==============================
  // UPDATE INVOICE STATUS
  // ==============================

  Future<Response> updateInvoiceStatus({
    required int invoiceId,
    required dynamic companyId,
    required String status,
    required String accessToken,
    bool isIncoming = false,
  }) async
  {
    final int companyIdInt = int.parse(companyId.toString());

    final String primaryEndpoint = isIncoming
        ? '${ApiConstants.baseUrl}/incoming-invoices/$invoiceId'
        : '${ApiConstants.baseUrl}/invoices/$invoiceId';

    final String fallbackEndpoint = isIncoming
        ? '${ApiConstants.baseUrl}/invoices/$invoiceId'
        : '${ApiConstants.baseUrl}/incoming-invoices/$invoiceId';

    final options = Options(
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    final payload = {
      'company_id': companyIdInt,
      'status': status,
    };

    final queryParams = {
      'company_id': companyIdInt,
    };

    try {
      return await _dio.patch(
        primaryEndpoint,
        data: payload,
        queryParameters: queryParams,
        options: options,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return await _dio.patch(
          fallbackEndpoint,
          data: payload,
          queryParameters: queryParams,
          options: options,
        );
      }
      rethrow;
    }
  }

// ==============================
// GET PDF
// ==============================


  Future<Response<List<int>>> downloadInvoicePdf({
    required int invoiceId,
    required String accessToken,
  }) async {
    return await _dio.get<List<int>>(
      '${ApiConstants.baseUrl}/invoices/$invoiceId/pdf',
      options: Options(
        responseType: ResponseType.bytes,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/pdf',
        },
      ),
    );
  }

  // ==============================
  // GET e Invoice PDF
  // ==============================

  Future<Response<List<int>>> downloadEInvoice({
    required int invoiceId,
    required String accessToken,
  }) async {
    return await _dio.get<List<int>>(
      '${ApiConstants.baseUrl}/invoices/$invoiceId/items',
      options: Options(
        responseType: ResponseType.bytes,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/xml',
        },
      ),
    );
  }

  // ============================================================
  // GET GENERAL LEDGER TRANSACTION
  // ============================================================

  Future<Response> getGeneralLedger({
    required int companyId,
    required String fromDate,
    required String toDate,
    required String accessToken,
  }) async {
    return await _dio.get(
      '${ApiConstants.baseUrl}/accounting/reports/general-ledger',
      queryParameters: {
        'company_id': companyId,
        'companyId': companyId,
        'fromDate': fromDate,
        'toDate': toDate,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
          'x-company-id': companyId.toString(),
        },
      ),
    );
  }

  // ==============================
  // SEND INVOICE REMINDER
  // ==============================

  Future<Response> sendInvoice({
    required int invoiceId,
    required int companyId,
    required String to,
    required String subject,
    required String text,
    required String accessToken,
  }) async {
    return await _dio.post(
      '${ApiConstants.baseUrl}/invoices/$invoiceId/send',
      data: {
        'to': to,
        'subject': subject,
        'text': text,
        'company_id': companyId,
        'file': '',
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );
  }

}