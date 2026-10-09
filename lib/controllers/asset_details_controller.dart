import 'package:dio/dio.dart';
import 'package:docelix_mobileapp/components/app_snackbar.dart';
import 'package:docelix_mobileapp/models/asset_model.dart';
import 'package:docelix_mobileapp/services/dio_client.dart';
import 'package:docelix_mobileapp/utils/session_manager.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:intl/intl.dart';

class AssetDetailsController extends GetxController {
  AssetDetailsController({required AssetModel initialAsset})
    : asset = initialAsset.obs;

  final DioClient _dioClient = DioClient();

  final Rx<AssetModel> asset;
  final RxList<LedgerAccount> accounts = <LedgerAccount>[].obs;
  final RxList<AssetDocument> documents = <AssetDocument>[].obs;
  final RxList<AssetHistoryEntry> history = <AssetHistoryEntry>[].obs;
  final RxList<AssetJournalEntry> journalEntries = <AssetJournalEntry>[].obs;

  final RxBool isLoading = false.obs;
  final RxBool isLoadingDocuments = false.obs;
  final RxBool isLoadingHistory = false.obs;
  final RxBool isLoadingJournal = false.obs;
  final RxBool isUploading = false.obs;
  final RxBool isDeletingDocument = false.obs;

  final RxString selectedDocumentType = 'Purchase Invoice'.obs;

  static const documentTypes = [
    'Purchase Invoice',
    'Warranty',
    'Manual',
    'Insurance',
    'Photo',
    'Other',
  ];

  static const _assetSourceTypes = {
    'asset_purchase',
    'asset_depreciation',
    'asset_disposal',
  };

  String get currencyCode {
    return SessionManager.accessCorrencycode?.trim().toUpperCase() ?? 'EUR';
  }

  String get currencySymbol {
    switch (currencyCode) {
      case 'EUR':
        return '€';
      case 'USD':
        return '\$';
      case 'GBP':
        return '£';
      case 'PKR':
        return 'Rs ';
      default:
        return '$currencyCode ';
    }
  }

  LedgerAccount? get ledgerAccount {
    if (asset.value.assetAccount != null) return asset.value.assetAccount;
    final id = asset.value.assetAccountId;
    if (id == null) return null;
    for (final account in accounts) {
      if (account.id == id) return account;
    }
    return null;
  }

  LedgerAccount? get depreciationExpenseAccount {
    if (asset.value.depreciationExpenseAccount != null) {
      return asset.value.depreciationExpenseAccount;
    }
    final id = asset.value.depreciationExpenseAccountId;
    if (id == null) return null;
    for (final account in accounts) {
      if (account.id == id) return account;
    }
    return null;
  }

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  Future<void> loadAll() async {
    await Future.wait([
      refreshAsset(),
      loadAccounts(),
      loadDocuments(),
      loadHistory(),
      loadJournalEntries(),
    ]);
  }

  Future<void> refreshAsset() async {
    final accessToken = SessionManager.accessToken;
    final companyId = SessionManager.accessCompanyid;
    if (accessToken == null || companyId == null) return;

    try {
      isLoading.value = true;
      final response = await _dioClient.getAssetById(
        assetId: asset.value.id,
        companyId: companyId,
        accessToken: accessToken,
      );

      final data = response.data;
      Map<String, dynamic>? raw;
      if (data is Map) {
        final map = Map<String, dynamic>.from(data);
        if (map['data'] is Map) {
          raw = Map<String, dynamic>.from(map['data'] as Map);
        } else if (map['asset'] is Map) {
          raw = Map<String, dynamic>.from(map['asset'] as Map);
        } else if (map.containsKey('id')) {
          raw = map;
        }
      }

      if (raw != null) {
        asset.value = AssetModel.fromJson(raw);
      }
    } on DioException catch (e) {
      // Keep the list payload if detail endpoint is unavailable.
      if (e.response?.statusCode != 404) {
        AppSnackbar.error(
          title: 'Error',
          message: _errorMessage(e, 'Failed to refresh asset.'),
        );
      }
    } catch (_) {
      // Keep existing asset data.
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadAccounts() async {
    final accessToken = SessionManager.accessToken;
    final companyId = SessionManager.accessCompanyid;
    if (accessToken == null || companyId == null) return;

    try {
      final response = await _dioClient.getLedgerAccounts(
        companyId: companyId,
        accessToken: accessToken,
      );
      accounts.assignAll(_parseAccounts(response.data));
    } catch (_) {
      // Optional enrichment.
    }
  }

  Future<void> loadDocuments() async {
    final accessToken = SessionManager.accessToken;
    final companyId = SessionManager.accessCompanyid;
    if (accessToken == null || companyId == null) return;

    try {
      isLoadingDocuments.value = true;
      final response = await _dioClient.getAssetDocuments(
        assetId: asset.value.id,
        companyId: companyId,
        accessToken: accessToken,
      );
      documents.assignAll(_parseDocuments(response.data));
    } on DioException catch (e) {
      AppSnackbar.error(
        title: 'Error',
        message: _errorMessage(e, 'Failed to load documents.'),
      );
    } catch (_) {
      AppSnackbar.error(title: 'Error', message: 'Failed to load documents.');
    } finally {
      isLoadingDocuments.value = false;
    }
  }

  Future<void> loadHistory() async {
    final accessToken = SessionManager.accessToken;
    final companyId = SessionManager.accessCompanyid;
    if (accessToken == null || companyId == null) return;

    try {
      isLoadingHistory.value = true;
      final response = await _dioClient.getAssetHistory(
        assetId: asset.value.id,
        companyId: companyId,
        accessToken: accessToken,
      );
      history.assignAll(_parseHistory(response.data));
    } on DioException catch (e) {
      AppSnackbar.error(
        title: 'Error',
        message: _errorMessage(e, 'Failed to load history.'),
      );
    } catch (_) {
      AppSnackbar.error(title: 'Error', message: 'Failed to load history.');
    } finally {
      isLoadingHistory.value = false;
    }
  }

  Future<void> loadJournalEntries() async {
    final accessToken = SessionManager.accessToken;
    final companyId = SessionManager.accessCompanyid;
    if (accessToken == null || companyId == null) return;

    try {
      isLoadingJournal.value = true;
      final response = await _dioClient.getAssetJournalEntries(
        companyId: companyId,
        sourceId: asset.value.id,
        accessToken: accessToken,
      );

      final loaded = _parseJournalEntries(response.data)
          .where(
            (entry) =>
                entry.sourceId == asset.value.id &&
                _assetSourceTypes.contains(entry.sourceType),
          )
          .toList();
      journalEntries.assignAll(loaded);
    } on DioException catch (e) {
      AppSnackbar.error(
        title: 'Error',
        message: _errorMessage(e, 'Failed to load journal entries.'),
      );
    } catch (_) {
      AppSnackbar.error(
        title: 'Error',
        message: 'Failed to load journal entries.',
      );
    } finally {
      isLoadingJournal.value = false;
    }
  }

  Future<void> uploadDocument() async {
    final accessToken = SessionManager.accessToken;
    final companyId = SessionManager.accessCompanyid;
    if (accessToken == null || companyId == null) {
      AppSnackbar.error(title: 'Error', message: 'Session is not available.');
      return;
    }

    try {
      final List<PlatformFile> result = await FilePicker.pickFiles(
        type: FileType.any,
      );
      if (result.isEmpty) return;

      final file = result.first;
      if (file.path == null) {
        AppSnackbar.error(
          title: 'Error',
          message: 'Unable to access selected file.',
        );
        return;
      }

      isUploading.value = true;
      await _dioClient.uploadAssetDocument(
        assetId: asset.value.id,
        companyId: companyId,
        accessToken: accessToken,
        filePath: file.path!,
        fileName: file.name,
        documentType: selectedDocumentType.value,
      );

      AppSnackbar.success(
        title: 'Uploaded',
        message: 'Document uploaded successfully.',
      );
      await loadDocuments();
    } on DioException catch (e) {
      AppSnackbar.error(
        title: 'Error',
        message: _errorMessage(e, 'Failed to upload document.'),
      );
    } catch (_) {
      AppSnackbar.error(title: 'Error', message: 'Failed to upload document.');
    } finally {
      isUploading.value = false;
    }
  }

  Future<void> deleteDocument(AssetDocument document) async {
    final accessToken = SessionManager.accessToken;
    final companyId = SessionManager.accessCompanyid;
    if (accessToken == null || companyId == null) return;

    try {
      isDeletingDocument.value = true;
      await _dioClient.deleteAssetDocument(
        assetId: asset.value.id,
        documentId: document.id,
        companyId: companyId,
        accessToken: accessToken,
      );
      documents.removeWhere((item) => item.id == document.id);
      AppSnackbar.success(title: 'Deleted', message: 'Document removed.');
    } on DioException catch (e) {
      AppSnackbar.error(
        title: 'Error',
        message: _errorMessage(e, 'Failed to delete document.'),
      );
    } catch (_) {
      AppSnackbar.error(title: 'Error', message: 'Failed to delete document.');
    } finally {
      isDeletingDocument.value = false;
    }
  }

  String formatMoney(num value) {
    final formatter = NumberFormat('#,##0.00');
    return '$currencySymbol${formatter.format(value)}';
  }

  String formatDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '';
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    return DateFormat('dd/MM/yyyy').format(parsed.toLocal());
  }

  String formatDateTime(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '';
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    return DateFormat('dd/MM/yyyy, HH:mm:ss').format(parsed.toLocal());
  }

  String displayOrDash(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return '—';
    return trimmed;
  }

  List<LedgerAccount> _parseAccounts(dynamic data) {
    List<dynamic>? rawItems;
    if (data is List) {
      rawItems = data;
    } else if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      if (map['items'] is List) {
        rawItems = map['items'] as List;
      } else if (map['data'] is List) {
        rawItems = map['data'] as List;
      } else if (map['accounts'] is List) {
        rawItems = map['accounts'] as List;
      }
    }
    if (rawItems == null) return [];
    return rawItems
        .whereType<Map>()
        .map((item) => LedgerAccount.fromJson(Map<String, dynamic>.from(item)))
        .where((account) => account.id > 0)
        .toList();
  }

  List<AssetDocument> _parseDocuments(dynamic data) {
    List<dynamic>? rawItems;
    if (data is List) {
      rawItems = data;
    } else if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      if (map['items'] is List) {
        rawItems = map['items'] as List;
      } else if (map['data'] is List) {
        rawItems = map['data'] as List;
      } else if (map['documents'] is List) {
        rawItems = map['documents'] as List;
      }
    }
    if (rawItems == null) return [];
    return rawItems
        .whereType<Map>()
        .map((item) => AssetDocument.fromJson(Map<String, dynamic>.from(item)))
        .where((doc) => doc.id > 0)
        .toList();
  }

  List<AssetHistoryEntry> _parseHistory(dynamic data) {
    List<dynamic>? rawItems;
    if (data is List) {
      rawItems = data;
    } else if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      if (map['items'] is List) {
        rawItems = map['items'] as List;
      } else if (map['data'] is List) {
        rawItems = map['data'] as List;
      } else if (map['history'] is List) {
        rawItems = map['history'] as List;
      }
    }
    if (rawItems == null) return [];
    return rawItems
        .whereType<Map>()
        .map(
          (item) => AssetHistoryEntry.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  List<AssetJournalEntry> _parseJournalEntries(dynamic data) {
    List<dynamic>? rawItems;
    if (data is List) {
      rawItems = data;
    } else if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      if (map['items'] is List) {
        rawItems = map['items'] as List;
      } else if (map['data'] is List) {
        rawItems = map['data'] as List;
      }
    }
    if (rawItems == null) return [];
    return rawItems
        .whereType<Map>()
        .map(
          (item) => AssetJournalEntry.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  String _errorMessage(DioException e, String fallback) {
    final data = e.response?.data;
    if (data is Map) {
      final message = data['message'] ?? data['error'] ?? data['detail'];
      if (message != null && message.toString().trim().isNotEmpty) {
        return message.toString();
      }
    }
    return fallback;
  }
}
