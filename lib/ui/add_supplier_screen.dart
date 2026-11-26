import 'package:docelix_mobileapp/components/app_button.dart';
import 'package:docelix_mobileapp/controllers/add_supplier_controller.dart';
import 'package:docelix_mobileapp/core/responsive/responsive.dart';
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddSupplierScreen extends StatefulWidget {
  const AddSupplierScreen({super.key});

  @override
  State<AddSupplierScreen> createState() => _AddSupplierScreenState();
}

class _AddSupplierScreenState extends State<AddSupplierScreen> {
  final AddSupplierController controller = Get.put(AddSupplierController());

  static const Color _navyText = Color(0xFF0A2342);
  static const Color _secondaryText = Color(0xFF64748B);
  static const Color _cardBorder = Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;
    final isTab = rs.isTablet;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      // ==========================================================
      // APP BAR (OLD BACK BUTTON DESIGN & CLEAN HEADER)
      // ==========================================================
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Color(0xFFEFF6FF),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: Get.back,
            icon: const Icon(
              Icons.arrow_back_rounded,
              size: 18,
              color: _navyText,
            ),
          ),
        ),
        title: Text(
          'New supplier',
          style: TextStyle(
            color: _navyText,
            fontSize: rs.sp(17),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(
              Icons.close_rounded,
              color: _secondaryText,
              size: 22,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),

      // ==========================================================
      // BODY (RESPONSIVE FORM)
      // ==========================================================
      body: SafeArea(
        child: Column(
          children: [
            const Divider(height: 1, color: _cardBorder),

            Expanded(
              child: ResponsivePage(
                maxWidth: rs.isPhone ? null : double.infinity,
                padding: EdgeInsets.fromLTRB(
                  rs.isPhone ? rs.pagePaddingH : 16.0,
                  rs.s(8),
                  rs.isPhone ? rs.pagePaddingH : 16.0,
                  rs.s(32),
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // SUPPLIER NAME*
                      _formField(
                        context: context,
                        label: 'Supplier name*',
                        controller: controller.nameController,
                      ),

                      const SizedBox(height: 14),

                      // CONTACT PERSON | EMAIL
                      Row(
                        children: [
                          Expanded(
                            child: _formField(
                              context: context,
                              label: 'Contact person',
                              controller: controller.contactPersonController,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _formField(
                              context: context,
                              label: 'Email',
                              controller: controller.emailController,
                              keyboardType: TextInputType.emailAddress,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // PHONE | WEBSITE
                      Row(
                        children: [
                          Expanded(
                            child: _formField(
                              context: context,
                              label: 'Phone',
                              controller: controller.phoneController,
                              keyboardType: TextInputType.phone,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _formField(
                              context: context,
                              label: 'Website',
                              controller: controller.websiteController,
                              keyboardType: TextInputType.url,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // ADDRESS
                      _formField(
                        context: context,
                        label: 'Address',
                        controller: controller.addressController,
                      ),

                      const SizedBox(height: 14),

                      // POSTAL CODE | CITY
                      Row(
                        children: [
                          Expanded(
                            child: _formField(
                              context: context,
                              label: 'Postal code',
                              controller: controller.postalCodeController,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _formField(
                              context: context,
                              label: 'City',
                              controller: controller.cityController,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // COUNTRY
                      _formField(
                        context: context,
                        label: 'Country',
                        controller: controller.countryController,
                      ),

                      const SizedBox(height: 14),

                      // VAT ID | TAX ID
                      Row(
                        children: [
                          Expanded(
                            child: _formField(
                              context: context,
                              label: 'VAT ID',
                              controller: controller.vatIdController,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _formField(
                              context: context,
                              label: 'Tax ID',
                              controller: controller.taxIdController,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // IBAN | PAYMENT TERMS
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _formField(
                              context: context,
                              label: 'IBAN',
                              controller: controller.ibanController,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _formField(
                                  context: context,
                                  label: 'Payment terms (days)',
                                  controller: controller.paymentTermsController,
                                  keyboardType: TextInputType.number,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Sets the default due date of new purchases.',
                                  style: TextStyle(
                                    fontSize: isTab ? 11 : rs.sp(11),
                                    color: _secondaryText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // NOTES
                      _formField(
                        context: context,
                        label: 'Notes',
                        controller: controller.notesController,
                        maxLines: 3,
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),

            // ==========================================================
            // BOTTOM ACTION BUTTONS
            // ==========================================================
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                rs.isPhone ? rs.pagePaddingH : 16.0,
                12,
                rs.isPhone ? rs.pagePaddingH : 16.0,
                16,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: _cardBorder),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: rs.isPhone ? 12 : 14),
                        foregroundColor: _navyText,
                        side: const BorderSide(color: Color(0xFFD0D5DD)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: isTab ? 14 : rs.sp(14),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Obx(
                      () => AppButton(
                        text: controller.isLoading.value
                            ? 'Saving...'
                            : 'Save supplier',
                        height: rs.isPhone ? 46 : 48,
                        backgroundColor: colorsList.colorButton,
                        foregroundColor: Colors.white,
                        borderRadius: 10,
                        isLoading: controller.isLoading.value,
                        onPressed: controller.saveSupplier,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // FORM FIELD WIDGET
  // ================================================================
  Widget _formField({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    final rs = context.rs;
    final isTab = rs.isTablet;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: _navyText,
            fontSize: isTab ? 13 : rs.sp(13),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: TextStyle(
            color: _navyText,
            fontSize: isTab ? 13.5 : rs.sp(13.5),
          ),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _cardBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _cardBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.2),
            ),
          ),
        ),
      ],
    );
  }
}