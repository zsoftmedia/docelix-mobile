import 'package:docelix_mobileapp/components/app_button.dart';
import 'package:docelix_mobileapp/controllers/add_supplier_controller.dart';
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
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

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
            fontSize: width * 0.050,
            fontWeight: FontWeight.normal,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => Get.back(),
            icon: Icon(
              Icons.close_rounded,
              color: colorsList.iconColor,
              size: width * 0.06,
            ),
          ),
          SizedBox(width: width * 0.02),
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
                padding: EdgeInsets.fromLTRB(
                  width * 0.045,
                  height * 0.02,
                  width * 0.045,
                  height * 0.04,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --------------------------------------------------
                    // SUPPLIER NAME*
                    // --------------------------------------------------
                    _formField(
                      label: 'Supplier name*',
                      controller: controller.nameController,
                      width: width,
                    ),

                    SizedBox(height: height * 0.018),

                    // --------------------------------------------------
                    // CONTACT PERSON | EMAIL
                    // --------------------------------------------------
                    Row(
                      children: [
                        Expanded(
                          child: _formField(
                            label: 'Contact person',
                            controller: controller.contactPersonController,
                            width: width,
                          ),
                        ),
                        SizedBox(width: width * 0.03),
                        Expanded(
                          child: _formField(
                            label: 'Email',
                            controller: controller.emailController,
                            keyboardType: TextInputType.emailAddress,
                            width: width,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: height * 0.018),

                    // --------------------------------------------------
                    // PHONE | WEBSITE
                    // --------------------------------------------------
                    Row(
                      children: [
                        Expanded(
                          child: _formField(
                            label: 'Phone',
                            controller: controller.phoneController,
                            keyboardType: TextInputType.phone,
                            width: width,
                          ),
                        ),
                        SizedBox(width: width * 0.03),
                        Expanded(
                          child: _formField(
                            label: 'Website',
                            controller: controller.websiteController,
                            keyboardType: TextInputType.url,
                            width: width,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: height * 0.018),

                    // --------------------------------------------------
                    // ADDRESS
                    // --------------------------------------------------
                    _formField(
                      label: 'Address',
                      controller: controller.addressController,
                      width: width,
                    ),

                    SizedBox(height: height * 0.018),

                    // --------------------------------------------------
                    // POSTAL CODE | CITY
                    // --------------------------------------------------
                    Row(
                      children: [
                        Expanded(
                          child: _formField(
                            label: 'Postal code',
                            controller: controller.postalCodeController,
                            width: width,
                          ),
                        ),
                        SizedBox(width: width * 0.03),
                        Expanded(
                          child: _formField(
                            label: 'City',
                            controller: controller.cityController,
                            width: width,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: height * 0.018),

                    // --------------------------------------------------
                    // COUNTRY
                    // --------------------------------------------------
                    _formField(
                      label: 'Country',
                      controller: controller.countryController,
                      width: width,
                    ),

                    SizedBox(height: height * 0.018),

                    // --------------------------------------------------
                    // VAT ID | TAX ID
                    // --------------------------------------------------
                    Row(
                      children: [
                        Expanded(
                          child: _formField(
                            label: 'VAT ID',
                            controller: controller.vatIdController,
                            width: width,
                          ),
                        ),
                        SizedBox(width: width * 0.03),
                        Expanded(
                          child: _formField(
                            label: 'Tax ID',
                            controller: controller.taxIdController,
                            width: width,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: height * 0.018),

                    // --------------------------------------------------
                    // IBAN | PAYMENT TERMS
                    // --------------------------------------------------
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _formField(
                            label: 'IBAN',
                            controller: controller.ibanController,
                            width: width,
                          ),
                        ),
                        SizedBox(width: width * 0.03),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _formField(
                                label: 'Payment terms (days)',
                                controller: controller.paymentTermsController,
                                keyboardType: TextInputType.number,
                                width: width,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Sets the default due date of new purchases.',
                                style: TextStyle(
                                  fontSize: width * 0.026,
                                  color: colorsList.textHintColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: height * 0.018),

                    // --------------------------------------------------
                    // NOTES
                    // --------------------------------------------------
                    _formField(
                      label: 'Notes',
                      controller: controller.notesController,
                      maxLines: 3,
                      width: width,
                    ),

                    SizedBox(height: height * 0.03),
                  ],
                ),
              ),
            ),

            // ==========================================================
            // BOTTOM ACTION BUTTONS
            // ==========================================================

            Container(
              padding: EdgeInsets.fromLTRB(
                width * 0.045,
                height * 0.015,
                width * 0.045,
                height * 0.02,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Color(0xFFE5EAF0)),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size(double.infinity, height * 0.055),
                        foregroundColor: colorsList.textColor,
                        side: const BorderSide(color: Color(0xFFD0D5DD)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: width * 0.036,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: width * 0.03),

                  Expanded(
                    child: Obx(
                      () => AppButton(
                        text: controller.isLoading.value
                            ? 'Saving...'
                            : 'Save supplier',
                        height: height * 0.055,
                        backgroundColor: colorsList.primaryBlue,
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
    required String label,
    required TextEditingController controller,
    required double width,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colorsList.textColor,
            fontSize: width * 0.031,
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
            fontSize: width * 0.034,
          ),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(
              horizontal: width * 0.032,
              vertical: maxLines > 1 ? 12 : 11,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: colorsList.primaryBlue,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}