import 'package:docelix_mobileapp/components/app_snackbar.dart';
import 'package:docelix_mobileapp/controllers/ledger_controller.dart';
import 'package:docelix_mobileapp/core/responsive/responsive.dart';
import 'package:docelix_mobileapp/models/ledger_account_model.dart';
import 'package:docelix_mobileapp/ui/add_ledger_account_screen.dart';
import 'package:docelix_mobileapp/ui/bank_transactions_screen.dart';
import 'package:docelix_mobileapp/ui/edit_ledger_account_screen.dart';
import 'package:docelix_mobileapp/ui/general_ledger_screen.dart';
import 'package:docelix_mobileapp/ui/journal_entries_screen.dart';
import 'package:docelix_mobileapp/ui/kfz_steuerrechner_screen.dart';
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LedgerScreen extends StatefulWidget {
  const LedgerScreen({super.key});

  @override
  State<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends State<LedgerScreen> {
  final LedgerController controller = Get.put(LedgerController());

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;

    return Scaffold(
      backgroundColor: colorsList.backgroundColor,
      body: SafeArea(
        child: ResponsivePage(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ======================================================
              // 1. TOP HEADER BAR
              // ======================================================
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: rs.pagePaddingH,
                  vertical: rs.s(12),
                ),
                child: Row(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFE2ECF8),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: Color(0xFF063C70),
                          size: 20,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Ledger',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFF0A2342),
                          fontSize: rs.sp(18),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        AppSnackbar.info(title: 'Coming Soon', message: 'Import statement feature is coming soon.');
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: const Icon(Icons.upload_file_outlined, size: 14, color: Color(0xFF475569)),
                      label: const Text('Import', style: TextStyle(fontSize: 12, color: Color(0xFF475569))),
                    ),
                  ],
                ),
              ),

              // ======================================================
              // 2. PAGE TITLE & SUBTITLE
              // ======================================================
              Padding(
                padding: EdgeInsets.symmetric(horizontal: rs.pagePaddingH),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ledger',
                      style: TextStyle(
                        color: const Color(0xFF0A2342),
                        fontSize: rs.sp(22),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: rs.s(2)),
                    Text(
                      'Double-entry bookkeeping foundation for this company.',
                      style: TextStyle(
                        color: const Color(0xFF64748B),
                        fontSize: rs.sp(12),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: rs.s(14)),

              // ======================================================
              // 3. 5 SCROLLABLE TABS HEADER (MATCHING SCREENSHOT)
              // ======================================================
              Padding(
                padding: EdgeInsets.symmetric(horizontal: rs.pagePaddingH),
                child: Container(
                  height: rs.s(42),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Obx(() {
                    final selectedIndex = controller.selectedTabIndex.value;

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: List.generate(
                          LedgerController.tabs.length,
                          (index) {
                            final isSelected = selectedIndex == index;
                            final tabLabel = LedgerController.tabs[index];

                            return GestureDetector(
                              onTap: () => controller.selectTab(index),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: EdgeInsets.symmetric(
                                  horizontal: rs.s(16),
                                  vertical: rs.s(6),
                                ),
                                margin: EdgeInsets.only(right: rs.s(4)),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? colorsList.colorButton
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  tabLabel,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : const Color(0xFF64748B),
                                    fontSize: rs.sp(12),
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }),
                ),
              ),

              SizedBox(height: rs.s(14)),

              // ======================================================
              // 4. SELECTED TAB CONTENT
              // ======================================================
              Expanded(
                child: Obx(() {
                  switch (controller.selectedTabIndex.value) {
                    case 0:
                      return _buildQuickExpenseAndAccountsTab(context);
                    case 1:
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: rs.pagePaddingH),
                        child: const GeneralLedgerScreen(),
                      );
                    case 2:
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: rs.pagePaddingH),
                        child: const JournalEntriesScreen(),
                      );
                    case 3:
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: rs.pagePaddingH),
                        child: const BankTransactionsScreen(),
                      );
                    case 4:
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: rs.pagePaddingH),
                        child: const KfzSteuerrechnerScreen(),
                      );
                    default:
                      return _buildQuickExpenseAndAccountsTab(context);
                  }
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================================================================
  // TAB 1: LEDGER & QUICK EXPENSE ENTRY
  // ================================================================

  Widget _buildQuickExpenseAndAccountsTab(BuildContext context) {
    final rs = context.rs;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(rs.pagePaddingH, 0, rs.pagePaddingH, rs.s(40)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // QUICK EXPENSE ENTRY BOX (SCREENSHOT 1)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quick Expense Entry',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0A2342)),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Supplier invoices, receipts and other expenses are recorded in Purchases: upload the document, check the draft, then post it to the ledger.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Get.toNamed('/CreateIncomingInvoicesScreen');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF063C70),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.upload_file_rounded, size: 16),
                      label: const Text('Upload a document', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () {
                        Get.toNamed('/CreateIncomingInvoicesScreen');
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF334155),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text('Enter manually', style: TextStyle(fontSize: 13)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // FILTER CONTROLS BAR (SEARCH + TYPES + STATUSES) [SCREENSHOTS 1, 2, 3]
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                // SEARCH BAR
                TextField(
                  onChanged: controller.onSearchChanged,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF0A2342)),
                  decoration: InputDecoration(
                    hintText: 'Search code, name or group...',
                    hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                    prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Color(0xFF94A3B8)),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.2),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // ROW DROPDOWNS: TYPES & STATUSES & ADD ACCOUNT
                Row(
                  children: [
                    // TYPES DROPDOWN (SCREENSHOT 2)
                    Expanded(
                      flex: 4,
                      child: Container(
                        height: 38,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: Obx(
                            () => DropdownButton<String>(
                              value: controller.selectedAccountType.value,
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                              items: LedgerController.accountTypeOptions.map((typeOpt) {
                                return DropdownMenuItem<String>(
                                  value: typeOpt,
                                  child: Text(typeOpt, style: const TextStyle(fontSize: 12, color: Color(0xFF0A2342))),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) controller.selectAccountType(val);
                              },
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // STATUSES DROPDOWN (SCREENSHOT 3)
                    Expanded(
                      flex: 4,
                      child: Container(
                        height: 38,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: Obx(
                            () => DropdownButton<String>(
                              value: controller.selectedStatus.value,
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                              items: LedgerController.statusOptions.map((stOpt) {
                                return DropdownMenuItem<String>(
                                  value: stOpt,
                                  child: Text(stOpt, style: const TextStyle(fontSize: 12, color: Color(0xFF0A2342))),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) controller.selectStatus(val);
                              },
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // ADD ACCOUNT BUTTON
                    ElevatedButton(
                      onPressed: () {
                       // Get.to(() => const AddLedgerAccountScreen());

                        Get.toNamed(
                          '/AddLedgerAccountScreen',
                          arguments: 'Add Ledger Account Screen',
                        );

                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF063C70),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('+ Add', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ACCOUNTS COUNT HEADER
          Obx(
            () => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Text(
                '${controller.filteredAccounts.length} accounts',
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // ACCOUNTS LIST CARDS
          Obx(() {
            if (controller.isLoading.value && controller.accounts.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final list = controller.filteredAccounts;

            if (list.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.search_off_rounded, size: 36, color: Color(0xFF94A3B8)),
                    SizedBox(height: 8),
                    Text('No accounts found.', style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
                  ],
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final account = list[index];
                return _buildAccountCard(context, account);
              },
            );
          }),
        ],
      ),
    );
  }

  // ================================================================
  // ACCOUNT CARD ITEM
  // ================================================================

  Widget _buildAccountCard(BuildContext context, LedgerAccountModel account) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EAED)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TOP ROW: CODE + NAME + SYSTEM BADGE + STATUS + ACTIONS MENU (SCREENSHOT 4)
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  account.code,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0A2342)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        account.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0A2342)),
                      ),
                    ),
                    if (account.isSystem) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: const Text('System', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: account.isActive ? const Color(0xFFECFDF5) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: account.isActive ? const Color(0xFFA7F3D0) : const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: account.isActive ? const Color(0xFF059669) : const Color(0xFF64748B),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      account.isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: account.isActive ? const Color(0xFF059669) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _showAccountActions(context, account),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.more_horiz_rounded, color: Color(0xFF94A3B8), size: 20),
              ),
            ],
          ),

          if (account.subhead?.isNotEmpty == true || account.mainHead?.isNotEmpty == true) ...[
            const SizedBox(height: 8),
            Text(
              '${account.mainHead?.toUpperCase() ?? ''} · ${account.subhead ?? ''}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
            ),
          ],

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),

          // BOTTOM ROW: TYPE & NORMAL SIDE
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Type: ${account.displayType}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF475569), fontWeight: FontWeight.w500),
              ),
              Text(
                'Normal side: ${account.displayNormalSide}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF475569), fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAccountActions(BuildContext context, LedgerAccountModel account) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ResponsiveSheetBody(
        padding: EdgeInsets.zero,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${account.code} - ${account.name}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0A2342)),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                ListTile(
                  leading: const Icon(Icons.edit_outlined, color: Color(0xFF0A2342)),
                  title: const Text('Edit account', style: TextStyle(fontSize: 14)),
                  onTap: () {
                    Navigator.pop(ctx);
                    Get.to(() => const EditLedgerAccountScreen(), arguments: account);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.power_settings_new_rounded, color: Color(0xFF0A2342)),
                  title: Text(
                    account.isActive ? 'Deactivate' : 'Activate',
                    style: const TextStyle(fontSize: 14),
                  ),
                  subtitle: Text(
                    account.isActive
                        ? 'Hide from account pickers; history stays.'
                        : 'Show in account pickers.',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    controller.toggleAccountActive(account);
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.delete_outline_rounded,
                    color: account.isSystem ? const Color(0xFF94A3B8) : const Color(0xFFDC2626),
                  ),
                  title: Text(
                    'Delete account',
                    style: TextStyle(
                      fontSize: 14,
                      color: account.isSystem ? const Color(0xFF94A3B8) : const Color(0xFFDC2626),
                    ),
                  ),
                  subtitle: Text(
                    account.isSystem
                        ? 'Standard chart accounts are protected.'
                        : 'Remove this custom account.',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    if (account.isSystem) {
                      AppSnackbar.error(
                        title: 'Protected Account',
                        message: 'Standard chart accounts are protected and cannot be deleted.',
                      );
                    } else {
                      _confirmDeleteAccount(context, account);
                    }
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context, LedgerAccountModel account) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Account', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0A2342))),
        content: Text('Are you sure you want to delete "${account.code} - ${account.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteAccount(account);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}