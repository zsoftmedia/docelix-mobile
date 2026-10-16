class QuotationModel {
  final int id;
  final String offerNumber;
  final String createdAt;
  final String status;
  final int companyId;
  final int clientId;
  final String issueDate;
  final String? vortext;
  final String? schlusstext;
  final String? clientName;
  final String? clientEmail;
  final String? clientPhone;

  QuotationModel({
    this.id = 0,
    this.offerNumber = '',
    this.createdAt = '',
    this.status = 'draft',
    this.companyId = 0,
    this.clientId = 0,
    this.issueDate = '',
    this.vortext,
    this.schlusstext,
    this.clientName,
    this.clientEmail,
    this.clientPhone,
  });

  factory QuotationModel.fromJson(Map<String, dynamic>? json) {
    final data = json ?? {};
    final clientMap = data['client'] is Map ? data['client'] as Map : {};

    return QuotationModel(
      id: _toInt(data['id']),
      offerNumber: data['offer_number']?.toString() ?? '',
      createdAt: data['created_at']?.toString() ?? '',
      status: data['status']?.toString() ?? 'draft',
      companyId: _toInt(data['company_id']),
      clientId: _toInt(data['client_id']),
      issueDate: data['issue_date']?.toString() ?? '',
      vortext: data['vortext']?.toString(),
      schlusstext: data['schlusstext']?.toString(),
      clientName: clientMap['name']?.toString() ?? data['client_name']?.toString() ?? '—',
      clientEmail: clientMap['email']?.toString(),
      clientPhone: clientMap['phone']?.toString(),
    );
  }

  static int _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}