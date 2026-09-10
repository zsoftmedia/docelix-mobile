class UserModel {
  int? id;
  String? userId;
  String? email;
  String? username;
  int? roleId;
  String? createdAt;
  String? updatedAt;
  Role? role;
  dynamic avatar;
  List<Company>? companies;
  dynamic avatarData;
  dynamic avatarMimeType;

  UserModel({
    this.id,
    this.userId,
    this.email,
    this.username,
    this.roleId,
    this.createdAt,
    this.updatedAt,
    this.role,
    this.avatar,
    this.companies,
    this.avatarData,
    this.avatarMimeType,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      userId: json['user_id'],
      email: json['email'],
      username: json['username'],
      roleId: json['role_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],

      role: json['role'] != null
          ? Role.fromJson(json['role'])
          : null,

      avatar: json['avatar'],

      companies: json['companies'] != null
          ? List<Company>.from(
        json['companies'].map(
              (x) => Company.fromJson(x),
        ),
      )
          : [],

      avatarData: json['avatar_data'],
      avatarMimeType: json['avatar_mime_type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'email': email,
      'username': username,
      'role_id': roleId,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'role': role?.toJson(),
      'avatar': avatar,
      'companies': companies?.map((x) => x.toJson()).toList(),
      'avatar_data': avatarData,
      'avatar_mime_type': avatarMimeType,
    };
  }
}


// ============================================================
// ROLE
// ============================================================

class Role {
  String? name;
  String? description;

  Role({
    this.name,
    this.description,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      name: json['name'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
    };
  }
}


// ============================================================
// COMPANY
// ============================================================

class Company {
  int? id;
  String? name;
  dynamic logo;
  dynamic logoMimeType;
  dynamic taxId;
  dynamic iban;
  dynamic bic;
  dynamic phoneNumber;
  dynamic telNumber;
  dynamic contactEmail;
  dynamic website;
  dynamic addressLine1;
  dynamic addressLine2;
  dynamic postalCode;
  dynamic city;
  dynamic country;
  dynamic footer;
  String? createdAt;
  String? updatedAt;
  String? userId;
  String? defaultLocale;
  dynamic logoSizeBytes;
  dynamic logoWidth;
  dynamic logoHeight;
  String? logoUpdatedAt;
  dynamic fnNumber;
  dynamic gerichtsstand;
  String? currencyCode;
  dynamic industryId;
  dynamic customIndustryName;
  dynamic legalName;
  dynamic registrationNumber;
  dynamic registrationCourt;
  dynamic registrationDate;
  dynamic gisaNumber;
  dynamic legalForm;
  dynamic companyStatus;
  dynamic businessActivity;
  bool? vatRegistered;
  dynamic vatNumber;
  dynamic vatExemptionText;
  dynamic fiscalYear;
  dynamic accountingMethod;
  String? vatAccountingMethod;
  String? myRole;
  MyPlanFeatures? myPlanFeatures;

  Company({
    this.id,
    this.name,
    this.logo,
    this.logoMimeType,
    this.taxId,
    this.iban,
    this.bic,
    this.phoneNumber,
    this.telNumber,
    this.contactEmail,
    this.website,
    this.addressLine1,
    this.addressLine2,
    this.postalCode,
    this.city,
    this.country,
    this.footer,
    this.createdAt,
    this.updatedAt,
    this.userId,
    this.defaultLocale,
    this.logoSizeBytes,
    this.logoWidth,
    this.logoHeight,
    this.logoUpdatedAt,
    this.fnNumber,
    this.gerichtsstand,
    this.currencyCode,
    this.industryId,
    this.customIndustryName,
    this.legalName,
    this.registrationNumber,
    this.registrationCourt,
    this.registrationDate,
    this.gisaNumber,
    this.legalForm,
    this.companyStatus,
    this.businessActivity,
    this.vatRegistered,
    this.vatNumber,
    this.vatExemptionText,
    this.fiscalYear,
    this.accountingMethod,
    this.vatAccountingMethod,
    this.myRole,
    this.myPlanFeatures,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'],
      name: json['name'],
      logo: json['logo'],
      logoMimeType: json['logo_mime_type'],
      taxId: json['tax_id'],
      iban: json['iban'],
      bic: json['bic'],
      phoneNumber: json['phone_number'],
      telNumber: json['tel_number'],
      contactEmail: json['contact_email'],
      website: json['website'],
      addressLine1: json['address_line1'],
      addressLine2: json['address_line2'],
      postalCode: json['postal_code'],
      city: json['city'],
      country: json['country'],
      footer: json['footer'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      userId: json['user_id'],
      defaultLocale: json['default_locale'],
      logoSizeBytes: json['logo_size_bytes'],
      logoWidth: json['logo_width'],
      logoHeight: json['logo_height'],
      logoUpdatedAt: json['logo_updated_at'],
      fnNumber: json['fn_number'],
      gerichtsstand: json['gerichtsstand'],
      currencyCode: json['currency_code'],
      industryId: json['industry_id'],
      customIndustryName: json['custom_industry_name'],
      legalName: json['legal_name'],
      registrationNumber: json['registration_number'],
      registrationCourt: json['registration_court'],
      registrationDate: json['registration_date'],
      gisaNumber: json['gisa_number'],
      legalForm: json['legal_form'],
      companyStatus: json['company_status'],
      businessActivity: json['business_activity'],
      vatRegistered: json['vat_registered'],
      vatNumber: json['vat_number'],
      vatExemptionText: json['vat_exemption_text'],
      fiscalYear: json['fiscal_year'],
      accountingMethod: json['accounting_method'],
      vatAccountingMethod: json['vat_accounting_method'],
      myRole: json['my_role'],

      myPlanFeatures: json['my_plan_features'] != null
          ? MyPlanFeatures.fromJson(json['my_plan_features'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logo': logo,
      'logo_mime_type': logoMimeType,
      'tax_id': taxId,
      'iban': iban,
      'bic': bic,
      'phone_number': phoneNumber,
      'tel_number': telNumber,
      'contact_email': contactEmail,
      'website': website,
      'address_line1': addressLine1,
      'address_line2': addressLine2,
      'postal_code': postalCode,
      'city': city,
      'country': country,
      'footer': footer,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'user_id': userId,
      'default_locale': defaultLocale,
      'logo_size_bytes': logoSizeBytes,
      'logo_width': logoWidth,
      'logo_height': logoHeight,
      'logo_updated_at': logoUpdatedAt,
      'fn_number': fnNumber,
      'gerichtsstand': gerichtsstand,
      'currency_code': currencyCode,
      'industry_id': industryId,
      'custom_industry_name': customIndustryName,
      'legal_name': legalName,
      'registration_number': registrationNumber,
      'registration_court': registrationCourt,
      'registration_date': registrationDate,
      'gisa_number': gisaNumber,
      'legal_form': legalForm,
      'company_status': companyStatus,
      'business_activity': businessActivity,
      'vat_registered': vatRegistered,
      'vat_number': vatNumber,
      'vat_exemption_text': vatExemptionText,
      'fiscal_year': fiscalYear,
      'accounting_method': accountingMethod,
      'vat_accounting_method': vatAccountingMethod,
      'my_role': myRole,
      'my_plan_features': myPlanFeatures?.toJson(),
    };
  }
}


// ============================================================
// MY PLAN FEATURES
// ============================================================

class MyPlanFeatures {
  bool? hasFinance;
  bool? hasTaxes;
  bool? hasReports;
  bool? hasAssets;
  bool? hasAI;
  bool? hasMail;
  bool? hasTeamAccess;
  bool? hasActivityLog;
  dynamic maxIncomingInvoices;

  MyPlanFeatures({
    this.hasFinance,
    this.hasTaxes,
    this.hasReports,
    this.hasAssets,
    this.hasAI,
    this.hasMail,
    this.hasTeamAccess,
    this.hasActivityLog,
    this.maxIncomingInvoices,
  });

  factory MyPlanFeatures.fromJson(Map<String, dynamic> json) {
    return MyPlanFeatures(
      hasFinance: json['hasFinance'],
      hasTaxes: json['hasTaxes'],
      hasReports: json['hasReports'],
      hasAssets: json['hasAssets'],
      hasAI: json['hasAI'],
      hasMail: json['hasMail'],
      hasTeamAccess: json['hasTeamAccess'],
      hasActivityLog: json['hasActivityLog'],
      maxIncomingInvoices: json['maxIncomingInvoices'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hasFinance': hasFinance,
      'hasTaxes': hasTaxes,
      'hasReports': hasReports,
      'hasAssets': hasAssets,
      'hasAI': hasAI,
      'hasMail': hasMail,
      'hasTeamAccess': hasTeamAccess,
      'hasActivityLog': hasActivityLog,
      'maxIncomingInvoices': maxIncomingInvoices,
    };
  }
}

