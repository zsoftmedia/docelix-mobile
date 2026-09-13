
class ApiConstants {

  // Must be the SAME Supabase project as the Express API.
  // The values below point at a different project. Users that exist
  // on production/web will get invalid_credentials here.

  // Production
  /*static const String baseUrl = 'https://docelix.onrender.com/api';
  static const String supabaseUrl = 'https://uqhufdevsnstdpcbgace.supabase.co';
  static const String supabaseAnonKey = 'sb_publishable_tkHwDn4vg2Fx4yyRDBibJg_tqw5IRVw';*/


  // Staging
  static const String baseUrl = 'https://docelix-staging.onrender.com/api';
  static const String supabaseUrl = 'https://owytoejxgqxvevjsrfjj.supabase.co';
  static const String supabaseAnonKey = 'sb_publishable_Ti3w86g2K9d6QVCu6ioxjA_DP1u-VMW';

  // Staging API
 // static const String baseUrl = 'https://docelix-staging.onrender.com';

  static const String createUser = '/users';

  static const String me = '/me';
}