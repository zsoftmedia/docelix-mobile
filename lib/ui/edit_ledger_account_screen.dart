import 'package:docelix_mobileapp/controllers/edit_ledger_account_controller.dart';
import 'package:docelix_mobileapp/core/responsive/responsive.dart';
import 'package:docelix_mobileapp/models/ledger_account_model.dart';
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditLedgerAccountScreen extends StatefulWidget {
  const EditLedgerAccountScreen({super.key});

  @override
  State<EditLedgerAccountScreen> createState() => _EditLedgerAccountScreenState();
}

class _EditLedgerAccountScreenState extends State<EditLedgerAccountScreen> {
  final EditLedgerAccountController controller = Get.put(EditLedgerAccountController());

  @override
  void initState() {
    super.initState();
    final dynamic target = Get.arguments;
    if (target is LedgerAccountModel) {
      controller.initAccount(target);
    }
  }

  void _showAccountTypeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return ResponsiveSheetBody(
          padding: EdgeInsets.zero,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Account type',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0A2342),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  ...EditLedgerAccountController.accountTypeOptions.map((opt) {
                    final isSelected = controller.selectedAccountType.value == opt;

                    return Container(
                      color: isSelected ? const Color(0xFFEFF6FF) : Colors.transparent,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                        title: Text(
                          opt,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF0A2342),
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_rounded, color: Color(0xFF2563EB), size: 20)
                            : null,
                        onTap: () {
                          controller.selectAccountType(opt);
                          Navigator.of(ctx).pop();
                        },
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showNormalSideSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return ResponsiveSheetBody(
          padding: EdgeInsets.zero,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Normal side',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0A2342),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  ...EditLedgerAccountController.normalSideOptions.map((opt) {
                    final isSelected = controller.selectedNormalSide.value == opt;

                    return Container(
                      color: isSelected ? const Color(0xFFEFF6FF) : Colors.transparent,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                        title: Text(
                          opt,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF0A2342),
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_rounded, color: Color(0xFF2563EB), size: 20)
                            : null,
                        onTap: () {
                          controller.selectNormalSide(opt);
                          Navigator.of(ctx).pop();
                        },
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Edit ledger account',
              style: TextStyle(
                color: Color(0xFF0A2342),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Update the account details.',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(
              Icons.close_rounded,
              color: Color(0xFF64748B),
              size: 22,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ======================================================
              // ROW 1: CODE & ACCOUNT TYPE (SCREENSHOT 1 & 2)
              // ======================================================
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _FieldLabel(text: 'Code'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: controller.codeController,
                          decoration: _inputDecoration(''),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _FieldLabel(text: 'Account type'),
                        const SizedBox(height: 6),
                        Obx(
                          () => InkWell(
                            onTap: () => _showAccountTypeSheet(context),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: colorsList.borderColor),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    controller.selectedAccountType.value,
                                    style: const TextStyle(fontSize: 14, color: Color(0xFF0A2342)),
                                  ),
                                  const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ======================================================
              // ROW 2: ACCOUNT NAME (SCREENSHOT 1)
              // ======================================================
              const _FieldLabel(text: 'Account name'),
              const SizedBox(height: 6),
              TextFormField(
                controller: controller.nameController,
                decoration: _inputDecoration(''),
              ),

              const SizedBox(height: 16),

              // ======================================================
              // ROW 3: GERMAN NAME & ARABIC NAME (SCREENSHOT 1)
              // ======================================================
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _FieldLabel(text: 'German name (optional)'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: controller.germanNameController,
                          decoration: _inputDecoration(''),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _FieldLabel(text: 'Arabic name (optional)'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: controller.arabicNameController,
                          textDirection: TextDirection.rtl,
                          decoration: _inputDecoration(''),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ======================================================
              // ROW 4: NORMAL SIDE & CURRENCY (SCREENSHOT 1 & 3)
              // ======================================================
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _FieldLabel(text: 'Normal side'),
                        const SizedBox(height: 6),
                        Obx(
                          () => InkWell(
                            onTap: () => _showNormalSideSheet(context),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: colorsList.borderColor),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    controller.selectedNormalSide.value,
                                    style: const TextStyle(fontSize: 14, color: Color(0xFF0A2342)),
                                  ),
                                  const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _FieldLabel(text: 'Currency'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: controller.currencyController,
                          decoration: _inputDecoration(''),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ======================================================
              // PURCHASE CATEGORY INFO NOTE (SCREENSHOT 1)
              // ======================================================
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 16, color: Color(0xFF64748B)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Not offered as a purchase category. Purchases book to expense accounts or to fixed assets (codes starting with 0).',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.3),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ======================================================
              // CHECKBOX: ACCOUNT IS ACTIVE (SCREENSHOT 1)
              // ======================================================
              Obx(
                () => CheckboxListTile(
                  value: controller.isActive.value,
                  onChanged: (val) => controller.isActive.value = val ?? false,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: const Color(0xFF063C70),
                  title: const Text(
                    'Account is active',
                    style: TextStyle(fontSize: 14, color: Color(0xFF0A2342), fontWeight: FontWeight.w500),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ======================================================
              // BOTTOM ACTION BUTTONS (CANCEL & SAVE CHANGES) [SCREENSHOT 1]
              // ======================================================
              Obx(() {
                final isSubmitting = controller.isSubmitting.value;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: isSubmitting ? null : () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF334155),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: isSubmitting ? null : controller.updateAccount,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF063C70),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Save changes',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                    ),
                  ],
                );
              }),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: colorsList.borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: colorsList.borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.2),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        color: Color(0xFF475569),
        fontWeight: FontWeight.w500,
      ),
    );
  }
}