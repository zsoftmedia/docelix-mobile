class ClientModel {
  final int id;
  final int companyId;
  final String name;
  final String? contactName;
  final String? email;
  final String? phone;
  final String? vatId;
  final String? taxId;
  final String? addressLine1;
  final String? addressLine2;
  final String? postalCode;
  final String? city;
  final String? country;
  final String? createdAt;
  final String? updatedAt;
  final String? lastInvoiceNumber;
  final String? lastInvoiceDate;
  final double? lastInvoiceTotal;
  final int invoicesCount;
  final double totalInvoicedAmount;

  ClientModel({
    required this.id,
    required this.companyId,
    required this.name,
    this.contactName,
    this.email,
    this.phone,
    this.vatId,
    this.taxId,
    this.addressLine1,
    this.addressLine2,
    this.postalCode,
    this.city,
    this.country,
    this.createdAt,
    this.updatedAt,
    this.lastInvoiceNumber,
    this.lastInvoiceDate,
    this.lastInvoiceTotal,
    required this.invoicesCount,
    required this.totalInvoicedAmount,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: json['id'] ?? 0,
      companyId: json['company_id'] ?? 0,
      name: json['name'] ?? '',
      contactName: json['contact_name'],
      email: json['email'],
      phone: json['phone'],
      vatId: json['vat_id'],
      taxId: json['tax_id'],
      addressLine1: json['address_line1'],
      addressLine2: json['address_line2'],
      postalCode: json['postal_code'],
      city: json['city'],
      country: json['country'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      lastInvoiceNumber: json['last_invoice_number'],
      lastInvoiceDate: json['last_invoice_date'],
      lastInvoiceTotal:
      (json['last_invoice_total'] as num?)?.toDouble(),
      invoicesCount: json['invoices_count'] ?? 0,
      totalInvoicedAmount:
      (json['total_invoiced_amount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}