import 'package:docelix_mobileapp/introPages/Intro_screen.dart';
import 'package:docelix_mobileapp/models/purchase_invoices_model.dart';
import 'package:docelix_mobileapp/ui/accounts_payable_screen.dart';
import 'package:docelix_mobileapp/ui/accounts_receivable_screen.dart';
import 'package:docelix_mobileapp/ui/add_customer_screen.dart';
import 'package:docelix_mobileapp/ui/add_item_screen.dart';
import 'package:docelix_mobileapp/ui/accounting/general_ledger_screen.dart';
import 'package:docelix_mobileapp/ui/accounting/journal_entry_details_screen.dart';
import 'package:docelix_mobileapp/ui/assets/asset_details_screen.dart';
import 'package:docelix_mobileapp/ui/assets/create_asset_screen.dart';
import 'package:docelix_mobileapp/ui/assets/fixed_assets_screen.dart';
import 'package:docelix_mobileapp/ui/assets/fleet_dashboard_screen.dart';
import 'package:docelix_mobileapp/ui/assets/inventory_screen.dart';
import 'package:docelix_mobileapp/ui/assets/vehicle_details_screen.dart';
import 'package:docelix_mobileapp/ui/assets/vehicles_screen.dart';
import 'package:docelix_mobileapp/ui/catalogs_screen.dart';
import 'package:docelix_mobileapp/ui/customer_details_screen.dart';
import 'package:docelix_mobileapp/ui/customers_screen.dart';
import 'package:docelix_mobileapp/ui/create_purchase_invoices_screen.dart';
import 'package:docelix_mobileapp/ui/create_invoices_screen.dart';
import 'package:docelix_mobileapp/ui/dashboard_screen.dart';
import 'package:docelix_mobileapp/ui/purchase_invoices_details_screen.dart';
import 'package:docelix_mobileapp/ui/purchase_invoices_screen.dart';
import 'package:docelix_mobileapp/ui/invoices_details_screen.dart';
import 'package:docelix_mobileapp/ui/invoices_screen.dart';
import 'package:docelix_mobileapp/ui/land_screen.dart';
import 'package:docelix_mobileapp/ui/notification_screen.dart';
import 'package:docelix_mobileapp/ui/profile_screen.dart';
import 'package:docelix_mobileapp/ui/receivables_dashboard_screen.dart';
import 'package:docelix_mobileapp/ui/purchase_details_screen.dart';
import 'package:docelix_mobileapp/ui/scan_qr_screen.dart';
import 'package:docelix_mobileapp/ui/supplier_details_screen.dart';
import 'package:docelix_mobileapp/ui/suppliers_screen.dart';
import 'package:docelix_mobileapp/ui/transaction_screen.dart';
import 'package:docelix_mobileapp/ui/ui_auth/forgot_screen.dart';
import 'package:docelix_mobileapp/ui/ui_auth/login_screen.dart';
import 'package:docelix_mobileapp/ui/ui_auth/signup_screen.dart';
import 'package:docelix_mobileapp/ui/splash_screen.dart';
import 'package:docelix_mobileapp/config/api_constants.dart';
import 'package:docelix_mobileapp/ui/voice_recognition_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: ApiConstants.supabaseUrl,
    anonKey: ApiConstants.supabaseAnonKey,
  );

  await GetStorage.init();

  final box = GetStorage();

  final bool introCompleted = box.read('intro_completed') ?? false;

  runApp(MyApp(introCompleted: introCompleted));
}

class MyApp extends StatelessWidget {
  final bool introCompleted;

  const MyApp({super.key, required this.introCompleted});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,

      // First time → Intro
      // Already completed → Splash
      home: introCompleted ? const SplashScreen() : const IntroScreen(),

      getPages: [
        GetPage(name: '/SplashScreen', page: () => const SplashScreen()),
        GetPage(name: '/LoginScreen', page: () => LoginScreen()),
        GetPage(name: '/RegisterScreen', page: () => SignUpScreen()),
        GetPage(name: '/LandScreen', page: () => LandScreen()),
        GetPage(name: '/DashboardScreen', page: () => DashboardScreen()),
        GetPage(name: '/IncomingInvoicesScreen', page: () => PurchaseInvoicesScreen(),),
        GetPage(name: '/CreateIncomingInvoicesScreen', page: () => CreatePurchaseInvoicesScreen(),),
        GetPage(name: '/CustomersScreen', page: () => CustomersScreen()),
        GetPage(name: '/ForgotPasswordScreen', page: () => ForgotPasswordScreen()),
        GetPage(name: '/CustomerDetailsScreen', page: () => CustomerDetailsScreen(),),
        GetPage(name: '/AddCustomersScreen', page: () => AddCustomerScreen()),
        GetPage(name: '/IncomingInvoicesDetailsScreen', page: () => PurchaseInvoicesDetailsScreen(invoice: Get.arguments as PurchaseInvoicesModel,),),
        GetPage(name: '/InvoicesScreen', page: () => InvoicesScreen()),
        GetPage(name: '/InvoicesDetailsScreen', page: () => InvoicesDetailsScreen(),),
        GetPage(name: '/CreateInvoiceScreen', page: () => CreateInvoiceScreen(),),
        GetPage(name: '/VoiceRecognitionScreen', page: () => VoiceRecognitionScreen(),),
        // Items List Screen ==> Catalogs Screen
        GetPage(name: '/CatalogsScreen', page: () => CatalogsScreen()),
        GetPage(name: '/scanQrScreen', page: () => ScanQrScreen()),
        GetPage(name: '/ProfileScreen', page: () => ProfileScreen()),
        GetPage(name: '/NotificationScreen', page: () => NotificationScreen()),
        GetPage(name: '/AddItemScreen', page: () => AddItemScreen()),
        GetPage(name: '/TransactionScreen', page: () => TransationScreen()),
        GetPage(name: '/AccountReceivableScreen', page: () => AccountsReceivableScreen(),),
        GetPage(name: '/AccountsPayableScreen', page: () => AccountsPayableScreen(),),
        GetPage(name: '/ReceivablesDashboardScreen', page: () => ReceivablesDashboardScreen(),),
        GetPage(name: '/FixedAssetsScreen', page: () => const FixedAssetsScreen(),),
        GetPage(name: '/CreateAssetScreen', page: () => const CreateAssetScreen(),),
        GetPage(name: '/AssetDetailsScreen', page: () => const AssetDetailsScreen(),),
        GetPage(name: '/GeneralLedgerScreen', page: () => const GeneralLedgerScreen(),),
        GetPage(name: '/JournalEntryDetailsScreen', page: () => const JournalEntryDetailsScreen(),),
        GetPage(name: '/InventoryScreen', page: () => const InventoryScreen(),),
        GetPage(name: '/VehiclesLogbookScreen', page: () => const VehiclesScreen(),),
        GetPage(name: '/VehicleDetailsScreen', page: () => const VehicleDetailsScreen(),),
        GetPage(name: '/FleetDashboardScreen', page: () => const FleetDashboardScreen(),),
        GetPage(name: '/SuppliersScreen', page: () => const SuppliersScreen(),),
        GetPage(name: '/SupplierDetailsScreen', page: () => const SupplierDetailsScreen(),),
        GetPage(name: '/PurchaseDetailsScreen', page: () => const PurchaseDetailsScreen(),),
      ],
    );
  }
}
