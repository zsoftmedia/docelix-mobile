import 'package:docelix_mobileapp/components/app_button.dart';
import 'package:docelix_mobileapp/components/app_textfield.dart';
import 'package:docelix_mobileapp/controllers/create_invoice_controller.dart';
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateInvoiceScreen extends StatefulWidget {
  const CreateInvoiceScreen({super.key});

  @override
  State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {

  final CreateInvoiceController controller = Get.put(CreateInvoiceController());

  bool autoGenerate = true;
  bool enableVat = false;
  bool recurringInvoice = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(),
        title: const Text(
          'Create Invoice',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(
                color: Color(0xFFE1E7EE),
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: AppButton(
                  text: 'Cancel',
                  height: 48,
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  onPressed: () {
                    Get.back();
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppButton(
                  text: 'Save',
                  icon: Icons.save_outlined,
                  height: 48,
                  backgroundColor: colorsList.colorGray_1100,
                  foregroundColor: Colors.white,
                  isLoading: controller.isLoading.value,
                  onPressed: controller.saveData,
                ),
              ),
            ],
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [

              // ============================================================
              // SENDER DETAILS
              // ============================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: const Color(0xFFE1E7EE),
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const Text(
                      'From: Sender Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 16),

                    AppTextField(
                      isDropdown: true,
                      hintText: 'Select sender',
                      prefixIcon: Icons.business_outlined,
                      dropdownItems: controller.senders,
                      selectedValue: controller.selectedSender.value,
                      onDropdownChanged: controller.selectSender,
                    ),

                    const SizedBox(height: 10),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.email_outlined,
                            size: 16,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'anees.irshad@berrinex.com',
                            style: TextStyle(
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ============================================================
              // CLIENT DETAILS
              // ============================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: const Color(0xFFE1E7EE),
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const Text(
                      'Client details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 16),

                    InkWell(
                      onTap: controller.selectClient,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F8FB),
                          border: Border.all(
                            color: const Color(0xFF21679A),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.add,
                              size: 18,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Select client',
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      'Customer / Company',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF52657A),
                      ),
                    ),

                    const SizedBox(height: 6),

                    AppTextField(
                      controller: controller.customerController,
                      hintText: 'Customer / Company',
                      prefixIcon: Icons.business_outlined,
                    ),

                    const SizedBox(height: 14),

                    const Text(
                      'Street / Address',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF52657A),
                      ),
                    ),

                    const SizedBox(height: 6),

                    AppTextField(
                      controller: controller.addressController,
                      hintText: 'Street / Address',
                      prefixIcon: Icons.location_on_outlined,
                    ),

                    const SizedBox(height: 14),

                    Row(
                      children: [

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'ZIP',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF52657A),
                                ),
                              ),
                              const SizedBox(height: 6),
                              AppTextField(
                                controller: controller.zipController,
                                hintText: 'ZIP',
                                prefixIcon:
                                Icons.markunread_mailbox_outlined,
                                keyboardType:
                                TextInputType.number,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'City',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF52657A),
                                ),
                              ),
                              const SizedBox(height: 6),
                              AppTextField(
                                controller: controller.cityController,
                                hintText: 'City',
                                prefixIcon:
                                Icons.location_city_outlined,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    const Text(
                      'Attn',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF52657A),
                      ),
                    ),

                    const SizedBox(height: 6),

                    AppTextField(
                      controller: controller.attnController,
                      hintText: 'Attn',
                      prefixIcon: Icons.person_outline,
                    ),

                    const SizedBox(height: 14),

                    const Text(
                      'Email',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF52657A),
                      ),
                    ),

                    const SizedBox(height: 6),

                    AppTextField(
                      controller: controller.emailController,
                      hintText: 'Email',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),

                    const SizedBox(height: 14),

                    const Text(
                      'Phone',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF52657A),
                      ),
                    ),

                    const SizedBox(height: 6),

                    AppTextField(
                      controller: controller.phoneController,
                      hintText: 'Phone',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ============================================================
              // INVOICE DETAILS
              // ============================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: const Color(0xFFE1E7EE),
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const Text(
                      'Invoice details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F9FC),
                        border: Border.all(
                          color: const Color(0xFFE1E7EE),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Auto-generate number',
                            ),
                          ),
                          Switch(
                            value: autoGenerate,
                            onChanged: (value) {
                              setState(() {
                                autoGenerate = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      'Invoice number',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF52657A),
                      ),
                    ),

                    const SizedBox(height: 6),

                    AppTextField(
                      controller:
                      controller.invoiceNumberController,
                      hintText: 'Invoice number',
                      prefixIcon: Icons.numbers_outlined,
                    ),

                    const SizedBox(height: 14),

                    const Text(
                      'Invoice date',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF52657A),
                      ),
                    ),

                    const SizedBox(height: 6),

                    AppTextField(
                      controller:
                      controller.invoiceDateController,
                      hintText: 'Invoice date',
                      prefixIcon:
                      Icons.calendar_today_outlined,
                      readOnly: true,
                      onTap: controller.selectInvoiceDate,
                    ),

                    const SizedBox(height: 14),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F9FC),
                        border: Border.all(
                          color: const Color(0xFFE1E7EE),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Enable VAT',
                            ),
                          ),
                          Switch(
                            value: enableVat,
                            onChanged: (value) {
                              setState(() {
                                enableVat = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ============================================================
// LINE ITEMS
// ============================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: const Color(0xFFE1E7EE),
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ========================================================
                    // HEADER
                    // ========================================================

                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Line Items',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.visibility_outlined,
                            size: 20,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Items',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ========================================================
                    // NEW LINE ITEM INPUT
                    // ========================================================

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        border: Border.all(
                          color: const Color(0xFFE1E7EE),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          // --------------------------------------------------
                          // DESCRIPTION
                          // --------------------------------------------------

                          const Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF52657A),
                            ),
                          ),

                          const SizedBox(height: 6),

                          AppTextField(
                            controller:
                            controller.descriptionController,
                            hintText: 'Service or product',
                            prefixIcon:
                            Icons.description_outlined,
                          ),

                          const SizedBox(height: 14),

                          // --------------------------------------------------
                          // QUANTITY + UNIT
                          // --------------------------------------------------

                          Row(
                            children: [

                              Expanded(
                                child: AppTextField(
                                  controller:
                                  controller.quantityController,
                                  hintText: 'Qty',
                                  prefixIcon:
                                  Icons.numbers_outlined,
                                  keyboardType:
                                  TextInputType.number,
                                ),
                              ),

                              const SizedBox(width: 8),

                              Expanded(
                                child: AppTextField(
                                  isDropdown: true,
                                  hintText: 'Unit',
                                  prefixIcon:
                                  Icons.straighten_outlined,
                                  dropdownItems:
                                  controller.units,
                                  selectedValue:
                                  controller.selectedUnit.value,
                                  onDropdownChanged:
                                  controller.selectUnit,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // --------------------------------------------------
                          // UNIT PRICE
                          // --------------------------------------------------

                          const Text(
                            'Unit Price',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF52657A),
                            ),
                          ),

                          const SizedBox(height: 6),

                          AppTextField(
                            controller:
                            controller.unitPriceController,
                            hintText: '0.00',
                            prefixIcon:
                            Icons.euro_outlined,
                            keyboardType:
                            const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),

                          const SizedBox(height: 14),

                          // --------------------------------------------------
                          // CURRENT TOTAL
                          // --------------------------------------------------

                          Row(
                            children: const [

                              Expanded(
                                child: Text(
                                  'Total',
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                              ),

                              Text(
                                '€ 0,00',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ========================================================
                    // ADD LINE BUTTON
                    // ========================================================

                    AppButton(
                      text: 'Add line',
                      icon: Icons.add,
                      height: 44,
                      backgroundColor: Colors.white,
                      foregroundColor:
                      colorsList.colorGray_1100,
                      onPressed:
                      controller.addLine,
                    ),

                    // ========================================================
                    // SAVED LINE ITEMS
                    // ========================================================

                    Obx(
                          () {
                        if (controller.lineItems.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        return Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [

                            const SizedBox(height: 18),

                            const Text(
                              'Added Items',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: 10),

                            ...List.generate(
                              controller.lineItems.length,
                                  (index) {

                                final item =
                                controller.lineItems[index];

                                final description =
                                    item['description']
                                        ?.toString() ??
                                        '';

                                final quantity =
                                    (item['quantity'] as num?)
                                        ?.toDouble() ??
                                        0;

                                final unit =
                                    item['unit']
                                        ?.toString() ??
                                        '';

                                final unitPrice =
                                    (item['unitPrice'] as num?)
                                        ?.toDouble() ??
                                        0;

                                final total =
                                    (item['total'] as num?)
                                        ?.toDouble() ??
                                        0;

                                return Container(
                                  width: double.infinity,
                                  margin:
                                  const EdgeInsets.only(
                                    bottom: 10,
                                  ),
                                  padding:
                                  const EdgeInsets.all(12),
                                  decoration:
                                  BoxDecoration(
                                    color: Colors.white,
                                    border:
                                    Border.all(
                                      color:
                                      const Color(
                                        0xFFE1E7EE,
                                      ),
                                    ),
                                    borderRadius:
                                    BorderRadius.circular(
                                      8,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [

                                      // --------------------------------------
                                      // DESCRIPTION + DELETE
                                      // --------------------------------------

                                      Row(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [

                                          Expanded(
                                            child: Text(
                                              description,
                                              style:
                                              const TextStyle(
                                                fontSize: 14,
                                                fontWeight:
                                                FontWeight.w600,
                                              ),
                                            ),
                                          ),

                                          IconButton(
                                            onPressed: () {
                                              controller
                                                  .removeLine(
                                                index,
                                              );
                                            },
                                            padding:
                                            EdgeInsets.zero,
                                            constraints:
                                            const BoxConstraints(),
                                            icon:
                                            const Icon(
                                              Icons
                                                  .delete_outline,
                                              size: 20,
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 8),

                                      // --------------------------------------
                                      // QUANTITY + UNIT
                                      // --------------------------------------

                                      Row(
                                        children: [

                                          Expanded(
                                            child: Text(
                                              'Qty: ${quantity.toString().replaceAll('.0', '')}',
                                              style:
                                              const TextStyle(
                                                fontSize: 13,
                                                color:
                                                Color(
                                                  0xFF52657A,
                                                ),
                                              ),
                                            ),
                                          ),

                                          Expanded(
                                            child: Text(
                                              'Unit: $unit',
                                              style:
                                              const TextStyle(
                                                fontSize: 13,
                                                color:
                                                Color(
                                                  0xFF52657A,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 5),

                                      // --------------------------------------
                                      // UNIT PRICE + TOTAL
                                      // --------------------------------------

                                      Row(
                                        children: [

                                          Expanded(
                                            child: Text(
                                              'Unit Price: € ${unitPrice.toStringAsFixed(2).replaceAll('.', ',')}',
                                              style:
                                              const TextStyle(
                                                fontSize: 13,
                                                color:
                                                Color(
                                                  0xFF52657A,
                                                ),
                                              ),
                                            ),
                                          ),

                                          Text(
                                            '€ ${total.toStringAsFixed(2).replaceAll('.', ',')}',
                                            style:
                                            const TextStyle(
                                              fontSize: 14,
                                              fontWeight:
                                              FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),

                    // ========================================================
                    // SUBTOTAL
                    // ========================================================

                    Obx(
                          () {
                        if (controller.lineItems.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        return Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.end,
                          children: [

                            const SizedBox(height: 8),

                            Text(
                              'Subtotal: € ${controller.subtotal.toStringAsFixed(2).replaceAll('.', ',')}',
                              textAlign:
                              TextAlign.right,
                              style:
                              const TextStyle(
                                fontSize: 14,
                                fontWeight:
                                FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: 5),

                            const Text(
                              'VAT exempt – small business under § 6(1)(27) UStG',
                              textAlign:
                              TextAlign.right,
                              style: TextStyle(
                                fontSize: 12,
                                fontStyle:
                                FontStyle.italic,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ============================================================
              // CLOSING TEXT
              // ============================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: const Color(0xFFE1E7EE),
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [

                    const Text(
                      'Closing text (Schlusstext)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 16),

                    AppTextField(
                      controller:
                      controller.closingTextController,
                      hintText: 'Enter closing text',
                      prefixIcon: Icons.notes_outlined,
                      maxLines: 5,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ============================================================
              // RECURRING INVOICE
              // ============================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: const Color(0xFFE1E7EE),
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [

                    const Expanded(
                      child: Text(
                        'Enable recurring invoice',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),

                    Switch(
                      value: recurringInvoice,
                      onChanged: (value) {
                        setState(() {
                          recurringInvoice = value;
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}