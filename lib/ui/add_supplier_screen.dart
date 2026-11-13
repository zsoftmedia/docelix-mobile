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

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;
    final isTab = rs.isTablet;

    return Scaffold(
      backgroundColor: Colors.white,

      // ==========================================================
      // APP BAR
      // ==========================================================

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        title: Text(
          'New supplier',
          style: TextStyle(
            color: colorsList.textColor,
            fontSize: isTab ? 18 : rs.sp(18),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(
              Icons.close_rounded,
              color: colorsList.iconColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),

      // ==========================================================
      // BODY (FORM)
      // ==========================================================

      body: SafeArea(
        child: Column(
          children: [
            const Divider(height: 1, color: Color(0xFFE5EAF0)),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: rs.pagePaddingH,
                  vertical: rs.s(16),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: rs.sheetMaxWidth),
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
                                      color: colorsList.textHintColor,
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

                        const SizedBox(height: 24),
                      ],
                    ),
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
                rs.pagePaddingH,
                12,
                rs.pagePaddingH,
                16,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Color(0xFFE5EAF0)),
                ),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: rs.sheetMaxWidth),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Get.back(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            foregroundColor: colorsList.textColor,
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
                            height: 46,
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
            color: colorsList.textColor,
            fontSize: isTab ? 13 : rs.sp(13),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: TextStyle(
            color: colorsList.textColor,
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
          ),
        ),
      ],
    );
  }
}