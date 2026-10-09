
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

  // ==============================
  // ASSETS
  // ==============================

  Future<Response> getAssets({
    required int companyId,
    required String accessToken,
    String? name,
    String? status,
    int? assetCategoryId,
    int? assetAccountId,
  }) async {
    return await _dio.get(
      '${ApiConstants.baseUrl}/assets',
      queryParameters: {
        'company_id': companyId,
        if (name != null && name.trim().isNotEmpty) 'name': name.trim(),
        if (status != null && status.trim().isNotEmpty) 'status': status.trim(),
        if (assetCategoryId != null) 'asset_category_id': assetCategoryId,
        if (assetAccountId != null) 'asset_account_id': assetAccountId,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'x-company-id': companyId.toString(),
        },
      ),
    );
  }

  Future<Response> getAssetCategories({
    required int companyId,
    required String accessToken,
  }) async {
    return await _dio.get(
      '${ApiConstants.baseUrl}/assets/categories',
      queryParameters: {
        'company_id': companyId,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'x-company-id': companyId.toString(),
        },
      ),
    );
  }

  Future<Response> getLedgerAccounts({
    required int companyId,
    required String accessToken,
  }) async {
    return await _dio.get(
      '${ApiConstants.baseUrl}/ledger/accounts',
      queryParameters: {
        'company_id': companyId,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'x-company-id': companyId.toString(),
        },
      ),
    );
  }

  Future<Response> searchDepreciationEngine({
    required String query,
    required String accessToken,
    int? companyId,
  }) async {
    return await _dio.get(
      '${ApiConstants.baseUrl}/assets/depreciation-engine/search',
      queryParameters: {
        'query': query,
        if (companyId != null) 'company_id': companyId,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          if (companyId != null) 'x-company-id': companyId.toString(),
        },
      ),
    );
  }

  Future<Response> createAsset({
    required Map<String, dynamic> body,
    required String accessToken,
    required int companyId,
  }) async {
    return await _dio.post(
      '${ApiConstants.baseUrl}/assets',
      data: body,
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'x-company-id': companyId.toString(),
        },
      ),
    );
  }

  Future<Response> getAssetById({
    required int assetId,
    required int companyId,
    required String accessToken,
  }) async {
    return await _dio.get(
      '${ApiConstants.baseUrl}/assets/$assetId',
      queryParameters: {
        'company_id': companyId,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'x-company-id': companyId.toString(),
        },
      ),
    );
  }

  Future<Response> getAssetDocuments({
    required int assetId,
    required int companyId,
    required String accessToken,
  }) async {
    return await _dio.get(
      '${ApiConstants.baseUrl}/assets/$assetId/documents',
      queryParameters: {
        'company_id': companyId,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'x-company-id': companyId.toString(),
        },
      ),
    );
  }

  Future<Response> uploadAssetDocument({
    required int assetId,
    required int companyId,
    required String accessToken,
    required String filePath,
    required String fileName,
    required String documentType,
  }) async {
    final formData = FormData.fromMap({
      'company_id': companyId,
      'document_type': documentType,
      'file': await MultipartFile.fromFile(
        filePath,
        filename: fileName,
      ),
    });

    return await _dio.post(
      '${ApiConstants.baseUrl}/assets/$assetId/documents',
      data: formData,
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'x-company-id': companyId.toString(),
        },
        contentType: 'multipart/form-data',
      ),
    );
  }

  Future<Response> deleteAssetDocument({
    required int assetId,
    required int documentId,
    required int companyId,
    required String accessToken,
  }) async {
    return await _dio.delete(
      '${ApiConstants.baseUrl}/assets/$assetId/documents/$documentId',
      data: {
        'company_id': companyId,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'x-company-id': companyId.toString(),
        },
      ),
    );
  }

  Future<Response> getAssetHistory({
    required int assetId,
    required int companyId,
    required String accessToken,
  }) async {
    return await _dio.get(
      '${ApiConstants.baseUrl}/assets/$assetId/history',
      queryParameters: {
        'company_id': companyId,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'x-company-id': companyId.toString(),
        },
      ),
    );
  }

  Future<Response> getAssetJournalEntries({
    required int companyId,
    required int sourceId,
    required String accessToken,
    int page = 1,
    int limit = 100,
  }) async {
    return await _dio.get(
      '${ApiConstants.baseUrl}/ledger/journal-entries',
      queryParameters: {
        'company_id': companyId,
        'page': page,
        'limit': limit,
        'source_id': sourceId,
        'source_type':
            'asset_purchase,asset_depreciation,asset_disposal',
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'x-company-id': companyId.toString(),
        },
      ),
    );
  }

  // ==============================
  // ACCOUNTING REPORTS
  // ==============================

  Future<Response> getGeneralLedger({
    required int companyId,
    required String accessToken,
    required String fromDate,
    required String toDate,
    int? accountId,
    String? search,
    String? sourceType,
    int page = 1,
    int pageSize = 50,
  }) async {
    return await _dio.get(
      '${ApiConstants.baseUrl}/accounting/reports/general-ledger',
      queryParameters: {
        'company_id': companyId,
        'fromDate': fromDate,
        'toDate': toDate,
        'page': page,
        'pageSize': pageSize,
        if (accountId != null) 'accountId': accountId,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (sourceType != null && sourceType.trim().isNotEmpty)
          'sourceType': sourceType.trim(),
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'x-company-id': companyId.toString(),
        },
      ),
    );
  }

  // ==============================
  // INVENTORY
  // ==============================

  Future<Response> getInventoryItems({
    required int companyId,
    required String accessToken,
    int page = 1,
    int limit = 25,
    String? search,
  }) async {
    final query = search?.trim();
    final params = <String, dynamic>{
      'company_id': companyId,
      'page': page,
      'limit': limit,
    };
    if (query != null && query.isNotEmpty) {
      params['q'] = query;
    }

    final response = await _dio.get(
      '${ApiConstants.baseUrl}/inventory/items',
      queryParameters: params,
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'x-company-id': companyId.toString(),
        },
      ),
    );
    print('[Inventory Dio] ${response.requestOptions.uri}');
    return response;
  }

  Future<Response> getInventoryMovements({
    required int itemId,
    required int companyId,
    required String accessToken,
  }) async {
    return await _dio.get(
      '${ApiConstants.baseUrl}/inventory/items/$itemId/movements',
      queryParameters: {
        'company_id': companyId,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'x-company-id': companyId.toString(),
        },
      ),
    );
  }

  Future<Response> createInventoryMovement({
    required int itemId,
    required Map<String, dynamic> body,
    required String accessToken,
    required int companyId,
  }) async {
    return await _dio.post(
      '${ApiConstants.baseUrl}/inventory/items/$itemId/movements',
      data: body,
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'x-company-id': companyId.toString(),
        },
      ),
    );
  }

  // ==============================
  // VEHICLES
  // ==============================

  Future<Response> getVehicles({
    required int companyId,
    required String accessToken,
    int page = 1,
    int limit = 25,
    String? search,
  }) async {
    final query = search?.trim();
    final params = <String, dynamic>{
      'company_id': companyId,
      'page': page,
      'limit': limit,
    };
    if (query != null && query.isNotEmpty) {
      params['q'] = query;
    }

    return await _dio.get(
      '${ApiConstants.baseUrl}/vehicles',
      queryParameters: params,
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'x-company-id': companyId.toString(),
        },
      ),
    );
  }

  Future<Response> getVehicleById({
    required int vehicleId,
    required int companyId,
    required String accessToken,
  }) async {
    return await _dio.get(
      '${ApiConstants.baseUrl}/vehicles/$vehicleId',
      queryParameters: {
        'company_id': companyId,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'x-company-id': companyId.toString(),
        },
      ),
    );
  }

  Future<Response> createVehicle({
    required Map<String, dynamic> body,
    required String accessToken,
    required int companyId,
  }) async {
    return await _dio.post(
      '${ApiConstants.baseUrl}/vehicles',
      data: {
        'company_id': companyId,
        ...body,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'x-company-id': companyId.toString(),
        },
      ),
    );
  }

  Future<Response> getVehiclesDashboard({
    required int companyId,
    required String accessToken,
  }) async {
    return await _dio.get(
      '${ApiConstants.baseUrl}/vehicles/dashboard',
      queryParameters: {
        'company_id': companyId,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'x-company-id': companyId.toString(),
        },
      ),
    );
  }

  Future<Response> getVehicleTrips({
    required int vehicleId,
    required int companyId,
    required String accessToken,
  }) async {
    return await _dio.get(
      '${ApiConstants.baseUrl}/vehicles/$vehicleId/trips',
      queryParameters: {'company_id': companyId},
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'x-company-id': companyId.toString(),
        },
      ),
    );
  }

  Future<Response> calculateVehicleDistance({
    required String startAddress,
    required String destination,
    required int companyId,
    required String accessToken,
  }) async {
    return await _dio.post(
      '${ApiConstants.baseUrl}/vehicles/calculate-distance',
      data: {
        'company_id': companyId,
        'start_address': startAddress,
        'destination': destination,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'x-company-id': companyId.toString(),
        },
      ),
    );
  }

  Future<Response> getVehicleLocations({
    required int companyId,
    required String accessToken,
  }) async {
    return await _dio.get(
      '${ApiConstants.baseUrl}/vehicles/locations',
      queryParameters: {'company_id': companyId},
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'x-company-id': companyId.toString(),
        },
      ),
    );
  }

  Future<Response> createVehicleLocation({
    required String name,
    required String address,
    required int companyId,
    required String accessToken,
    String placeId = '',
  }) async {
    return await _dio.post(
      '${ApiConstants.baseUrl}/vehicles/locations',
      data: {
        'company_id': companyId,
        'name': name,
        'address': address,
        'place_id': placeId,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'x-company-id': companyId.toString(),
        },
      ),
    );
  }

  Future<Response> createVehicleTrip({
    required Map<String, dynamic> body,
    required int companyId,
    required String accessToken,
  }) async {
    return await _dio.post(
      '${ApiConstants.baseUrl}/vehicles/trips',
      data: {
        'company_id': companyId,
        ...body,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'x-company-id': companyId.toString(),
        },
      ),
    );
  }

  Future<Response> deleteVehicleTrip({
    required int vehicleId,
    required String tripId,
    required int companyId,
    required String accessToken,
  }) async {
    return await _dio.delete(
      '${ApiConstants.baseUrl}/vehicles/$vehicleId/trips/$tripId',
      queryParameters: {'company_id': companyId},
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'x-company-id': companyId.toString(),
        },
      ),
    );
  }

  Future<Response> getVehicleFuelLogs({
    required int vehicleId,
    required int companyId,
    required String accessToken,
  }) async {
    return await _dio.get(
      '${ApiConstants.baseUrl}/vehicles/$vehicleId/fuel',
      queryParameters: {'company_id': companyId},
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'x-company-id': companyId.toString(),
        },
      ),
    );
  }

  Future<Response> createVehicleFuelLog({
    required int vehicleId,
    required Map<String, dynamic> body,
    required int companyId,
    required String accessToken,
  }) async {
    return await _dio.post(
      '${ApiConstants.baseUrl}/vehicles/$vehicleId/fuel',
      data: {
        'company_id': companyId,
        ...body,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'x-company-id': companyId.toString(),
        },
      ),
    );
  }

  Future<Response> uploadVehicleFuelReceipt({
    required int vehicleId,
    required int companyId,
    required String accessToken,
    required String filePath,
    required String fileName,
  }) async {
    final formData = FormData.fromMap({
      'company_id': companyId,
      'file': await MultipartFile.fromFile(
        filePath,
        filename: fileName,
      ),
    });

    return await _dio.post(
      '${ApiConstants.baseUrl}/vehicles/$vehicleId/fuel-receipt',
      data: formData,
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'x-company-id': companyId.toString(),
        },
        contentType: 'multipart/form-data',
      ),
    );
  }

  Future<Response> getVehicleServices({
    required int vehicleId,
    required int companyId,
    required String accessToken,
  }) async {
    return await _dio.get(
      '${ApiConstants.baseUrl}/vehicles/$vehicleId/services',
      queryParameters: {'company_id': companyId},
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'x-company-id': companyId.toString(),
        },
      ),
    );
  }

  Future<Response> createVehicleService({
    required int vehicleId,
    required Map<String, dynamic> body,
    required int companyId,
    required String accessToken,
  }) async {
    return await _dio.post(
      '${ApiConstants.baseUrl}/vehicles/$vehicleId/services',
      data: {
        'company_id': companyId,
        'vehicle_id': vehicleId,
        ...body,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'x-company-id': companyId.toString(),
        },
      ),
    );
  }

  Future<Response> getVehicleInsurance({
    required int vehicleId,
    required int companyId,
    required String accessToken,
  }) async {
    return await _dio.get(
      '${ApiConstants.baseUrl}/vehicles/$vehicleId/insurance',
      queryParameters: {'company_id': companyId},
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'x-company-id': companyId.toString(),
        },
      ),
    );
  }

  Future<Response> createVehicleInsurance({
    required int vehicleId,
    required Map<String, dynamic> body,
    required int companyId,
    required String accessToken,
  }) async {
    return await _dio.post(
      '${ApiConstants.baseUrl}/vehicles/$vehicleId/insurance',
      data: {
        'company_id': companyId,
        'vehicle_id': vehicleId,
        ...body,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'x-company-id': companyId.toString(),
        },
      ),
    );
  }

  Future<Response> getVehicleDocuments({
    required int vehicleId,
    required int companyId,
    required String accessToken,
  }) async {
    return await _dio.get(
      '${ApiConstants.baseUrl}/vehicles/$vehicleId/documents',
      queryParameters: {'company_id': companyId},
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'x-company-id': companyId.toString(),
        },
      ),
    );
  }

  Future<Response> createVehicleDocument({
    required int vehicleId,
    required Map<String, dynamic> body,
    required int companyId,
    required String accessToken,
  }) async {
    return await _dio.post(
      '${ApiConstants.baseUrl}/vehicles/$vehicleId/documents',
      data: {
        'company_id': companyId,
        'vehicle_id': vehicleId,
        ...body,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'x-company-id': companyId.toString(),
        },
      ),
    );
  }

  Future<Response> getVehicleDrivers({
    required int companyId,
    required String accessToken,
  }) async {
    return await _dio.get(
      '${ApiConstants.baseUrl}/vehicles/drivers',
      queryParameters: {'company_id': companyId},
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'x-company-id': companyId.toString(),
        },
      ),
    );
  }

  Future<Response> createVehicleDriver({
    required String name,
    required int companyId,
    required String accessToken,
  }) async {
    return await _dio.post(
      '${ApiConstants.baseUrl}/vehicles/drivers',
      data: {
        'company_id': companyId,
        'name': name,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'x-company-id': companyId.toString(),
        },
      ),
    );
  }

  Future<Response> assignVehicleDriver({
    required int vehicleId,
    required int driverId,
    required bool isPrimary,
    required int companyId,
    required String accessToken,
  }) async {
    return await _dio.post(
      '${ApiConstants.baseUrl}/vehicles/$vehicleId/assignments',
      data: {
        'company_id': companyId,
        'driver_id': driverId,
        'is_primary': isPrimary,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'x-company-id': companyId.toString(),
        },
      ),
    );
  }

  Future<Response> deleteVehicleAssignment({
    required int vehicleId,
    required int assignmentId,
    required int companyId,
    required String accessToken,
  }) async {
    return await _dio.delete(
      '${ApiConstants.baseUrl}/vehicles/$vehicleId/assignments/$assignmentId',
      queryParameters: {'company_id': companyId},
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'x-company-id': companyId.toString(),
        },
      ),
    );
  }

}