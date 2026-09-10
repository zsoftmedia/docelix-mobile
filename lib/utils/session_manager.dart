import 'package:get_storage/get_storage.dart';

class SessionManager {

  static final GetStorage _storage = GetStorage();

  // Storage keys
  static const String _accessTokenKey = 'access_token';
  static const String _userIdKey = 'user_id';
  static const String _companyidKey = 'company_id';
  static const String _emailKey = 'email';
  static const String _usernameKey = 'username';
  static const String _roleKey = 'role';
  static const String _roleId = 'role_id';
  static const String _rolenameKey = 'role_name';
  static const String _roledescriptionKey = 'role_description';
  static const String _companynameKey = 'company_name';
  static const String _correncycodeKey = 'corrency_code';
  static const String _userDataKey = 'user_data';

  // ==============================
  // ACCESS TOKEN
  // ==============================

  static Future<void> saveAccessToken(String token) async {
    await _storage.write(
      _accessTokenKey,
      token,
    );
  }

  static String? get accessToken {
    return _storage.read<String>(_accessTokenKey);
  }

  // ==============================
  // USER ID
  // ==============================

  static Future<void> saveUserId(String userId) async {
    await _storage.write(
      _userIdKey,
      userId,
    );
  }

  static String? get userId {
    return _storage.read<String>(_userIdKey);
  }

  // ==============================
  // EMAIL
  // ==============================

  static Future<void> saveEmail(String email) async {
    await _storage.write(
      _emailKey,
      email,
    );
  }

  static String? get email {
    return _storage.read<String>(_emailKey);
  }

  // ==============================
  // USERNAME
  // ==============================

  static Future<void> saveUsername(String username) async {
    await _storage.write(
      _usernameKey,
      username,
    );
  }

  static String? get username {
    return _storage.read<String>(_usernameKey);
  }

  // ==============================
  // ROLE
  // ==============================

  static Future<void> saveRole(String role) async {
    await _storage.write(
      _roleKey,
      role,
    );
  }

  static String? get role {
    return _storage.read<String>(_roleKey);
  }

  // ==============================
  // USER DATA
  // ==============================

  static Future<void> saveUserData(
      Map<String, dynamic> data,
      ) async {
    await _storage.write(
      _userDataKey,
      data,
    );
  }

  static Map<String, dynamic>? get userData {
    final data = _storage.read(_userDataKey);

    if (data == null) {
      return null;
    }

    return Map<String, dynamic>.from(data);
  }

  // ==============================
  // ACCESS ROLE NAME
  // ==============================

  static Future<void> saveRolename(String rolename) async {
    await _storage.write(
      _rolenameKey,
      rolename,
    );
  }

  static String? get accessRolename {
    return _storage.read<String>(_rolenameKey);
  }

  // ==============================
  // ACCESS ROLE DESCRIPTION
  // ==============================

  static Future<void> saveRoledescription(String roledescription) async {
    await _storage.write(
      _roledescriptionKey,
      roledescription,
    );
  }

  static String? get accessRoledescription {
    return _storage.read<String>(_roledescriptionKey);
  }

  // ==============================
  // ACCESS COMPANY ID
  // ==============================

  static Future<void> saveCompanyid(int companyid) async {
    await _storage.write(
      _companyidKey,
      companyid,
    );
  }

  static int? get accessCompanyid {
    return _storage.read<int>(_companyidKey);
  }

  // ==============================
  // ACCESS COMPANY NAME
  // ==============================

  static Future<void> saveCompanyname(String companyname) async {
    await _storage.write(
      _companynameKey,
      companyname,
    );
  }

  static String? get accessCompanyname {
    return _storage.read<String>(_companynameKey);
  }

  // ==============================
  // ACCESS CORRENCY CODE
  // ==============================

  static Future<void> saveCorrencycode(String correncycode) async {
    await _storage.write(
      _correncycodeKey,
      correncycode,
    );
  }

  static String? get accessCorrencycode {
    return _storage.read<String>(_correncycodeKey);
  }


  // ==============================
  // CHECK LOGIN
  // ==============================

  static bool get isLoggedIn {
    return accessToken != null &&
        accessToken!.isNotEmpty;
  }

  // ==============================
  // CLEAR SESSION
  // ==============================

  static Future<void> clearSession() async {
    await _storage.remove(_accessTokenKey);
    await _storage.remove(_userIdKey);
    await _storage.remove(_emailKey);
    await _storage.remove(_usernameKey);
    await _storage.remove(_roleKey);
    await _storage.remove(_userDataKey);
  }
}