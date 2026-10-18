import 'package:docelix_mobileapp/components/app_button.dart';
import 'package:docelix_mobileapp/components/app_textfield.dart';
import 'package:docelix_mobileapp/controllers/add_client_controller.dart';
import 'package:docelix_mobileapp/core/responsive/responsive.dart';
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddCustomerScreen extends StatelessWidget {
  AddCustomerScreen({super.key});

  final AddClientController controller = Get.put(AddClientController());

  Widget _fieldBlock({
    required BuildContext context,
    required String label,
    required Widget field,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(context, label),
        SizedBox(height: context.s(8)),
        field,
      ],
    );
  }

  Widget _pairOrStack({
    required BuildContext context,
    required Widget left,
    required Widget right,
  }) {
    final twoCol = context.rs.formColumns >= 2;
    if (!twoCol) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          left,
          SizedBox(height: context.s(18)),
          right,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        SizedBox(width: context.s(12)),
        Expanded(child: right),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          onPressed: Get.back,
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colorsList.colorBackArrow,
            size: rs.s(20),
          ),
        ),
        title: Text(
          'Add Customer',
          style: TextStyle(
            color: colorsList.textColor,
            fontSize: rs.sp(20),
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: ResponsivePage(
          padding: EdgeInsets.symmetric(
            horizontal: rs.isPhone ? rs.wp(0.07) : rs.s(24),
            vertical: rs.s(15),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create a new customer and manage their information.',
                  style: TextStyle(
                    fontSize: rs.sp(16),
                    color: colorsList.textHintColor,
                  ),
                ),
                SizedBox(height: rs.s(30)),
                _sectionTitle(
                  context,
                  icon: Icons.business_outlined,
                  title: 'MASTER DATA',
                ),
                SizedBox(height: rs.s(18)),
                _pairOrStack(
                  context: context,
                  left: _fieldBlock(
                    context: context,
                    label: 'Name',
                    field: AppTextField(
                      controller: controller.nameController,
                      hintText: 'Customer name',
                      prefixIcon: Icons.business_outlined,
                    ),
                  ),
                  right: _fieldBlock(
                    context: context,
                    label: 'VAT ID',
                    field: AppTextField(
                      controller: controller.vatIdController,
                      hintText: 'e.g. ATU12345678',
                      prefixIcon: Icons.receipt_long_outlined,
                    ),
                  ),
                ),
                SizedBox(height: rs.s(30)),
                _sectionTitle(
                  context,
                  icon: Icons.receipt_long_outlined,
                  title: 'E-INVOICE (AT / PEPPOL)',
                ),
                SizedBox(height: rs.s(18)),
                _pairOrStack(
                  context: context,
                  left: _fieldBlock(
                    context: context,
                    label: 'Scheme ID',
                    field: Obx(
                      () => AppTextField(
                        isDropdown: true,
                        hintText: 'Select Scheme ID',
                        prefixIcon: Icons.tag_outlined,
                        dropdownItems: controller.schemeIds,
                        selectedValue: controller.selectedSchemeId.value,
                        onDropdownChanged: controller.selectSchemeId,
                      ),
                    ),
                  ),
                  right: _fieldBlock(
                    context: context,
                    label: 'Endpoint ID',
                    field: AppTextField(
                      controller: controller.endpointIdController,
                      hintText: 'Enter Endpoint ID',
                      prefixIcon: Icons.fingerprint_rounded,
                    ),
                  ),
                ),
                SizedBox(height: rs.s(30)),
                _sectionTitle(
                  context,
                  icon: Icons.account_balance_outlined,
                  title: 'PAYMENT',
                ),
                SizedBox(height: rs.s(18)),
                _pairOrStack(
                  context: context,
                  left: _fieldBlock(
                    context: context,
                    label: 'IBAN',
                    field: AppTextField(
                      controller: controller.ibanController,
                      hintText: 'Enter IBAN',
                      prefixIcon: Icons.account_balance_outlined,
                    ),
                  ),
                  right: _fieldBlock(
                    context: context,
                    label: 'Account Holder',
                    field: AppTextField(
                      controller: controller.accountHolderController,
                      hintText: 'Account holder name',
                      prefixIcon: Icons.person_outline_rounded,
                    ),
                  ),
                ),
                SizedBox(height: rs.s(30)),
                _sectionTitle(
                  context,
                  icon: Icons.contact_mail_outlined,
                  title: 'CONTACT',
                ),
                SizedBox(height: rs.s(18)),
                _pairOrStack(
                  context: context,
                  left: _fieldBlock(
                    context: context,
                    label: 'Email',
                    field: AppTextField(
                      controller: controller.emailController,
                      hintText: 'customer@example.com',
                      prefixIcon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                  right: _fieldBlock(
                    context: context,
                    label: 'Phone',
                    field: AppTextField(
                      controller: controller.phoneController,
                      hintText: 'Phone number',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                ),
                SizedBox(height: rs.s(30)),
                _sectionTitle(
                  context,
                  icon: Icons.location_on_outlined,
                  title: 'ADDRESS',
                ),
                SizedBox(height: rs.s(18)),
                _fieldBlock(
                  context: context,
                  label: 'Address 1',
                  field: AppTextField(
                    controller: controller.address1Controller,
                    hintText: 'Street and house number',
                    prefixIcon: Icons.location_on_outlined,
                  ),
                ),
                SizedBox(height: rs.s(18)),
                _fieldBlock(
                  context: context,
                  label: 'Address 2',
                  field: AppTextField(
                    controller: controller.address2Controller,
                    hintText: 'Apartment, floor, etc. (optional)',
                    prefixIcon: Icons.location_city_outlined,
                  ),
                ),
                SizedBox(height: rs.s(18)),
                _pairOrStack(
                  context: context,
                  left: _fieldBlock(
                    context: context,
                    label: 'ZIP',
                    field: AppTextField(
                      controller: controller.zipController,
                      hintText: 'ZIP / Postal code',
                      prefixIcon: Icons.markunread_mailbox_outlined,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  right: _fieldBlock(
                    context: context,
                    label: 'City',
                    field: AppTextField(
                      controller: controller.cityController,
                      hintText: 'City',
                      prefixIcon: Icons.location_city_outlined,
                    ),
                  ),
                ),
                SizedBox(height: rs.s(18)),
                _fieldBlock(
                  context: context,
                  label: 'Country',
                  field: Obx(
                    () => AppTextField(
                      isDropdown: true,
                      hintText: 'Select Country',
                      prefixIcon: Icons.public_outlined,
                      dropdownItems: controller.countries,
                      selectedValue: controller.selectedCountry.value,
                      onDropdownChanged: controller.selectCountry,
                    ),
                  ),
                ),
                SizedBox(height: rs.s(35)),
                Obx(
                  () => AppButton(
                    text: 'Save Customer',
                    icon: Icons.person_add_alt_1_rounded,
                    height: rs.s(52),
                    backgroundColor: colorsList.colorButton,
                    foregroundColor: Colors.white,
                    isLoading: controller.isLoading.value,
                    onPressed: controller.saveClient,
                  ),
                ),
                SizedBox(height: rs.s(30)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(
    BuildContext context, {
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: colorsList.iconColor,
          size: context.s(22),
        ),
        SizedBox(width: context.s(10)),
        Text(
          title,
          style: TextStyle(
            color: colorsList.textColor,
            fontSize: context.sp(16),
          ),
        ),
      ],
    );
  }

  Widget _label(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyle(
        color: colorsList.textColor,
        fontSize: context.sp(14),
      ),
    );
  }
}
