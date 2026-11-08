import 'package:docelix_mobileapp/controllers/invoices_controller.dart';
import 'package:docelix_mobileapp/core/responsive/responsive.dart';
import 'package:docelix_mobileapp/models/invoices_model.dart';
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  final InvoicesController invoicesController = Get.put(InvoicesController());

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;

    return Scaffold(
      backgroundColor: colorsList.backgroundColor,
      appBar: AppBar(
        backgroundColor: colorsList.backgroundColor,
        elevation: 0,
        leading: Obx(() {
          final bool searching = invoicesController.isSearching.value;

          return IconButton(
            onPressed: () {
              if (searching) {
                invoicesController.closeSearch();
              } else {
                Get.back();
              }
            },
            icon: Icon(
              searching
                  ? Icons.close_rounded
                  : Icons.arrow_back_ios_new_rounded,
              color: colorsList.iconColor,
              size: rs.s(20),
            ),
          );
        }),
        title: Obx(() {
          if (invoicesController.isSearching.value) {
            return TextField(
              autofocus: true,
              onChanged: invoicesController.searchInvoices,
              style: TextStyle(
                color: colorsList.textColor,
                fontSize: rs.sp(16),
              ),
              decoration: const InputDecoration(
                hintText: 'Search invoices...',
                border: InputBorder.none,
                isDense: true,
              ),
            );
          }

          return Text(
            'Invoices',
            style: TextStyle(
              color: colorsList.textColor,
              fontSize: rs.sp(20),
              fontWeight: FontWeight.normal,
            ),
          );
        }),
        centerTitle: false,
        actions: [
          Obx(() {
            if (invoicesController.isSearching.value) {
              return const SizedBox.shrink();
            }

            return IconButton(
              onPressed: invoicesController.openSearch,
              icon: Icon(
                Icons.search_rounded,
                color: colorsList.iconColor,
                size: rs.s(24),
              ),
            );
          }),
          SizedBox(width: rs.s(8)),
        ],
      ),
      body: SafeArea(
        child: ResponsivePage(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: rs.pagePaddingH,
                  vertical: rs.s(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'All Invoices',
                      style: TextStyle(
                        color: colorsList.textColor,
                        fontSize: rs.sp(18),
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: rs.s(14),
                        vertical: rs.s(6),
                      ),
                      decoration: BoxDecoration(
                        color: colorsList.colorBoxDecoration,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Obx(() {
                        return Text(
                          '${invoicesController.invoices.length} Invoices',
                          style: TextStyle(
                            color: colorsList.textColor,
                            fontSize: rs.sp(14),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Obx(() {
                  if (invoicesController.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (invoicesController.filteredInvoices.isEmpty) {
                    final bool hasSearch = invoicesController
                        .searchQuery.value
                        .trim()
                        .isNotEmpty;

                    return RefreshIndicator(
                      onRefresh: invoicesController.refreshInvoices,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(height: rs.s(150)),
                          Center(
                            child: Text(
                              hasSearch
                                  ? 'No invoices found.'
                                  : 'No invoices found.',
                              style: TextStyle(
                                color: colorsList.textHintColor,
                                fontSize: rs.sp(15),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final cols = rs.listColumns;
                  final invoices = invoicesController.filteredInvoices;

                  if (cols <= 1) {
                    return RefreshIndicator(
                      onRefresh: invoicesController.refreshInvoices,
                      child: ListView.builder(
                        padding: EdgeInsets.only(
                          top: rs.s(4),
                          left: rs.pagePaddingH,
                          right: rs.pagePaddingH,
                          bottom: rs.s(96),
                        ),
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: invoices.length,
                        itemBuilder: (context, index) {
                          return _invoiceTile(
                            context: context,
                            invoice: invoices[index],
                            asGridTile: false,
                          );
                        },
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: invoicesController.refreshInvoices,
                    child: GridView.builder(
                      padding: EdgeInsets.only(
                        left: rs.pagePaddingH,
                        right: rs.pagePaddingH,
                        bottom: rs.s(96),
                      ),
                      physics: const AlwaysScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: cols,
                        crossAxisSpacing: rs.s(12),
                        mainAxisSpacing: rs.s(12),
                        childAspectRatio: rs.isLandscape ? 2.6 : 1.8,
                      ),
                      itemCount: invoices.length,
                      itemBuilder: (context, index) {
                        return _invoiceTile(
                          context: context,
                          invoice: invoices[index],
                          asGridTile: true,
                        );
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Get.toNamed(
            '/CreateInvoiceScreen',
            arguments: 'Create Invoices Screen',
          );

          if (result != null) {
            invoicesController.refreshInvoices();
          }
        },
        backgroundColor: colorsList.colorButton,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(
          Icons.add_rounded,
        ),
        label: Text(
          'Add Invoice',
          style: TextStyle(
            fontSize: rs.sp(15),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _invoiceTile({
    required BuildContext context,
    required InvoicesModel invoice,
    required bool asGridTile,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () async {
        final result = await Get.toNamed(
          '/InvoicesDetailsScreen',
          arguments: invoice,
        );

        if (result == true) {
          await invoicesController.refreshInvoices();
        }
      },
      child: _invoiceCard(
        context: context,
        invoice: invoice,
      ),
    );
  }

  void _showInvoiceActions(BuildContext context, InvoicesModel invoice) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ResponsiveSheetBody(
        padding: EdgeInsets.zero,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.visibility_outlined, color: Color(0xFF2563EB)),
                  title: const Text('View Invoice Details'),
                  onTap: () {
                    Navigator.pop(ctx);
                    Get.toNamed('/InvoicesDetailsScreen', arguments: invoice);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _invoiceCard({
    required BuildContext context,
    required InvoicesModel invoice,
  }) {
    final rs = context.rs;
    final String status = invoice.status.toLowerCase().trim();

    Color pillBg;
    Color pillBorder;
    Color pillText;

    if (status == 'paid') {
      pillBg = const Color(0xFFECFDF5);
      pillBorder = const Color(0xFFA7F3D0);
      pillText = const Color(0xFF059669);
    } else if (status == 'pending' || status == 'unpaid' || status == 'draft') {
      pillBg = const Color(0xFFFFFBEB);
      pillBorder = const Color(0xFFFDE68A);
      pillText = const Color(0xFFD97706);
    } else if (status == 'overdue') {
      pillBg = const Color(0xFFFEF2F2);
      pillBorder = const Color(0xFFFECACA);
      pillText = const Color(0xFFDC2626);
    } else {
      pillBg = const Color(0xFFF8FAFC);
      pillBorder = const Color(0xFFE2E8F0);
      pillText = const Color(0xFF64748B);
    }

    final String displayStatus = status.isNotEmpty
        ? status[0].toUpperCase() + status.substring(1)
        : 'Paid';

    final String formattedNet = invoicesController.formatCurrency(
      invoice.grossAmount,
      invoice.currencyCode,
    );

    final String formattedTotal = invoicesController.formatCurrency(
      invoice.grossAmount,
      invoice.currencyCode,
    );

    return Container(
      margin: EdgeInsets.only(bottom: rs.s(14)),
      padding: EdgeInsets.all(rs.s(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorsList.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. TOP HEADER ROW (INVOICE NUMBER + STATUS PILL + MORE MENU)
          Row(
            children: [
              Expanded(
                child: Text(
                  invoice.invoiceNumber.isNotEmpty
                      ? invoice.invoiceNumber
                      : 'Invoice #${invoice.id}',
                  style: TextStyle(
                    color: const Color(0xFF0A2342),
                    fontSize: rs.sp(17),
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: rs.s(12),
                  vertical: rs.s(4),
                ),
                decoration: BoxDecoration(
                  color: pillBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: pillBorder),
                ),
                child: Text(
                  displayStatus,
                  style: TextStyle(
                    color: pillText,
                    fontSize: rs.sp(12),
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              SizedBox(width: rs.s(4)),
              IconButton(
                onPressed: () {
                  _showInvoiceActions(context, invoice);
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.more_horiz_rounded,
                  color: Color(0xFF94A3B8),
                  size: 20,
                ),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),

          // 2. MIDDLE DETAILS 2X2 GRID
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LEFT COLUMN (CUSTOMER & DUE DATE)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CUSTOMER',
                      style: TextStyle(
                        fontSize: rs.sp(10),
                        fontWeight: FontWeight.normal,
                        color: const Color(0xFF94A3B8),
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: rs.s(2)),
                    Text(
                      invoice.clientId > 0
                          ? 'Client #${invoice.clientId}'
                          : 'no9r',
                      style: TextStyle(
                        fontSize: rs.sp(13),
                        fontWeight: FontWeight.normal,
                        color: const Color(0xFF0A2342),
                      ),
                    ),
                    SizedBox(height: rs.s(10)),
                    Text(
                      'DUE DATE',
                      style: TextStyle(
                        fontSize: rs.sp(10),
                        fontWeight: FontWeight.normal,
                        color: const Color(0xFF94A3B8),
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: rs.s(2)),
                    Row(
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 14,
                          color: Color(0xFF16A34A),
                        ),
                        SizedBox(width: rs.s(4)),
                        Text(
                          invoice.dueDate?.isNotEmpty == true
                              ? invoice.dueDate!
                              : '—',
                          style: TextStyle(
                            fontSize: rs.sp(13),
                            color: const Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // RIGHT COLUMN (DATE & REMINDERS)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DATE',
                      style: TextStyle(
                        fontSize: rs.sp(10),
                        fontWeight: FontWeight.normal,
                        color: const Color(0xFF94A3B8),
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: rs.s(2)),
                    Text(
                      invoice.issueDate.isNotEmpty
                          ? invoice.issueDate
                          : 'DD.MM.YYYY',
                      style: TextStyle(
                        fontSize: rs.sp(13),
                        fontWeight: FontWeight.normal,
                        color: const Color(0xFF0A2342),
                      ),
                    ),
                    SizedBox(height: rs.s(10)),
                    Text(
                      'REMINDERS',
                      style: TextStyle(
                        fontSize: rs.sp(10),
                        fontWeight: FontWeight.normal,
                        color: const Color(0xFF94A3B8),
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: rs.s(2)),
                    Text(
                      invoice.reminderCount > 0
                          ? '${invoice.reminderCount}'
                          : '—',
                      style: TextStyle(
                        fontSize: rs.sp(13),
                        color: const Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),

          // 3. BOTTOM AMOUNTS ROW (NET | VAT | TOTAL)
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Net',
                    style: TextStyle(
                      fontSize: rs.sp(10),
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                  SizedBox(height: rs.s(2)),
                  Text(
                    formattedNet,
                    style: TextStyle(
                      fontSize: rs.sp(13),
                      fontWeight: FontWeight.normal,
                      color: const Color(0xFF0A2342),
                    ),
                  ),
                ],
              ),
              SizedBox(width: rs.s(12)),
              Container(
                width: 1,
                height: rs.s(24),
                color: const Color(0xFFE2E8F0),
              ),
              SizedBox(width: rs.s(12)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'VAT (0%)',
                    style: TextStyle(
                      fontSize: rs.sp(10),
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                  SizedBox(height: rs.s(2)),
                  Text(
                    '${invoicesController.getCurrencySymbol(invoice.currencyCode)}0.00',
                    style: TextStyle(
                      fontSize: rs.sp(13),
                      fontWeight: FontWeight.normal,
                      color: const Color(0xFF0A2342),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'TOTAL',
                    style: TextStyle(
                      fontSize: rs.sp(10),
                      fontWeight: FontWeight.normal,
                      color: const Color(0xFF94A3B8),
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: rs.s(2)),
                  Text(
                    formattedTotal,
                    style: TextStyle(
                      fontSize: rs.sp(15),
                      fontWeight: FontWeight.normal,
                      color: const Color(0xFF0A2342),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}