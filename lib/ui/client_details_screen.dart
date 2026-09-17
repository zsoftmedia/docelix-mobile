import 'package:docelix_mobileapp/controllers/client_details_controller.dart';
import 'package:docelix_mobileapp/models/clients_screen_model.dart';
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ClientDetailsScreen extends StatefulWidget {
  const ClientDetailsScreen({super.key});

  @override
  State<ClientDetailsScreen> createState() => _ClientDetailsScreenState();
}

class _ClientDetailsScreenState extends State<ClientDetailsScreen> {
  final ClientDetailsController controller =
  Get.put(ClientDetailsController());

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final client = controller.client;

    final String clientName = client.name.trim().isNotEmpty
        ? client.name.trim()
        : 'Unnamed Client';

    return Scaffold(
      backgroundColor: colorsList.backgroundColor,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,

        leading: IconButton(
          onPressed: Get.back,
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colorsList.primaryColor,
            size: 20,
          ),
        ),

        title: const Text(
          'Client Details',
          style: TextStyle(
            color: colorsList.primaryColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),

        centerTitle: false,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            width * 0.05,
            20,
            width * 0.05,
            30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ====================================================
              // CLIENT PROFILE
              // ====================================================

              _profileHeader(
                clientName: clientName,
                contactName: client.contactName,
              ),

              const SizedBox(height: 24),

              // ====================================================
              // CONTACT INFORMATION
              // ====================================================

              _sectionTitle('Contact Information'),

              const SizedBox(height: 10),

              _informationCard(
                children: [
                  _detailRow(
                    icon: Icons.email_outlined,
                    label: 'Email address',
                    value: client.email,
                  ),
                  _detailDivider(),
                  _detailRow(
                    icon: Icons.phone_outlined,
                    label: 'Phone number',
                    value: client.phone,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ====================================================
              // ADDRESS
              // ====================================================

              _sectionTitle('Address'),

              const SizedBox(height: 10),

              _informationCard(
                children: [
                  _detailRow(
                    icon: Icons.location_on_outlined,
                    label: 'Address',
                    value: _addressValue(client),
                  ),
                  _detailDivider(),
                  _detailRow(
                    icon: Icons.location_city_outlined,
                    label: 'City',
                    value: client.city,
                  ),
                  _detailDivider(),
                  _detailRow(
                    icon: Icons.public_outlined,
                    label: 'Country',
                    value: client.country,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ====================================================
              // INVOICE SUMMARY
              // ====================================================

              _sectionTitle('Invoice Summary'),

              const SizedBox(height: 10),

              _invoiceSummary(client),

              const SizedBox(height: 24),

              // ====================================================
              // ADDITIONAL INFORMATION
              // ====================================================

              _sectionTitle('Additional Information'),

              const SizedBox(height: 10),

              _informationCard(
                children: [
                  _detailRow(
                    icon: Icons.badge_outlined,
                    label: 'VAT ID',
                    value: client.vatId,
                  ),
                  _detailDivider(),
                  _detailRow(
                    icon: Icons.receipt_long_outlined,
                    label: 'Tax ID',
                    value: client.taxId,
                  ),
                  _detailDivider(),
                  _detailRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Created date',
                    value: _formatDate(client.createdAt),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================================================================
  // PROFILE HEADER
  // ================================================================

  Widget _profileHeader({
    required String clientName,
    required String? contactName,
  })
  {
    final hasContactName =
        contactName != null && contactName.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 24,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorsList.borderColor,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: colorsList.iconBackgroundColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: colorsList.secondaryTextColor,
              size: 36,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            clientName,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: colorsList.textColor,
              fontSize: 21,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),

          if (hasContactName) ...[
            const SizedBox(height: 6),
            Text(
              contactName!.trim(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: colorsList.secondaryTextColor,
                fontSize: 13,
                height: 1.2,
              ),
            ),
          ],

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Client ID: ${controller.client.id}',
              style: const TextStyle(
                color: colorsList.secondaryTextColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // SECTION TITLE
  // ================================================================

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: colorsList.primaryColor,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  // ================================================================
  // INFORMATION CARD
  // ================================================================

  Widget _informationCard({
    required List<Widget> children,
  })
  {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorsList.borderColor,
          width: 1,
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  // ================================================================
  // DETAIL ROW
  // ================================================================

  Widget _detailRow({
    required IconData icon,
    required String label,
    required String? value,
  })
  {
    final bool hasValue = value != null && value.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: colorsList.iconBackgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 18,
              color: colorsList.secondaryTextColor,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: colorsList.mutedTextColor,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  hasValue ? value!.trim() : 'Not available',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: hasValue ? colorsList.textColor : colorsList.mutedTextColor,
                    fontSize: 14,
                    fontWeight:
                    hasValue ? FontWeight.w500 : FontWeight.normal,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // INVOICE SUMMARY
  // ================================================================

  Widget _invoiceSummary(ClientScreenModel client) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorsList.borderColor,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _summaryItem(
                  icon: Icons.receipt_long_outlined,
                  label: 'Invoices',
                  value: client.invoicesCount?.toString() ?? '0',
                ),
              ),

              Container(
                width: 1,
                height: 42,
                color: colorsList.borderColor,
              ),

              Expanded(
                child: _summaryItem(
                  icon: Icons.payments_outlined,
                  label: 'Total invoiced',
                  value: client.totalInvoicedAmount != null
                      ? client.totalInvoicedAmount!.toStringAsFixed(2)
                      : '0.00',
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          const Divider(
            height: 1,
            thickness: 1,
            color: colorsList.borderColor,
          ),

          const SizedBox(height: 4),

          _detailRow(
            icon: Icons.description_outlined,
            label: 'Last invoice',
            value: client.lastInvoiceNumber,
          ),

          _detailRow(
            icon: Icons.calendar_today_outlined,
            label: 'Invoice date',
            value: _formatDate(client.lastInvoiceDate),
          ),
        ],
      ),
    );
  }

  Widget _summaryItem({
    required IconData icon,
    required String label,
    required String value,
  })
  {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 20,
          color: colorsList.secondaryTextColor,
        ),

        const SizedBox(width: 9),

        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: colorsList.mutedTextColor,
                  fontSize: 11.5,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: colorsList.textColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ================================================================
  // DIVIDER
  // ================================================================

  Widget _detailDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: colorsList.borderColor,
    );
  }

  // ================================================================
  // ADDRESS VALUE
  // ================================================================

  String? _addressValue(ClientScreenModel client) {
    final address = [
      client.addressLine1,
      client.addressLine2,
      client.city,
      client.postalCode,
    ]
        .where(
          (value) => value != null && value.trim().isNotEmpty,
    )
        .map(
          (value) => value!.trim(),
    )
        .join(', ');

    return address.isNotEmpty ? address : null;
  }

  // ================================================================
  // DATE FORMAT
  // ================================================================

  String? _formatDate(String? date) {
    if (date == null || date.trim().isEmpty) {
      return null;
    }

    try {
      final parsedDate = DateTime.parse(date);

      return '${parsedDate.day.toString().padLeft(2, '0')}/'
          '${parsedDate.month.toString().padLeft(2, '0')}/'
          '${parsedDate.year}';
    } catch (_) {
      return date;
    }
  }
}