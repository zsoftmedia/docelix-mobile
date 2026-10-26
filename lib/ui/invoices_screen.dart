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
        backgroundColor: colorsList.colorWhite,
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
                        childAspectRatio: rs.isLandscape ? 2.6 : 2.2,
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
    return Material(
      color: Colors.transparent,
      borderRadius: asGridTile ? BorderRadius.circular(context.s(12)) : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(context.s(12)),
        onTap: () async {
          final result = await Get.toNamed(
            '/InvoicesDetailsScreen',
            arguments: invoice,
          );

          if (result == true) {
            await invoicesController.refreshInvoices();
          }
        },
        child: asGridTile
            ? DecoratedBox(
                decoration: BoxDecoration(
                  color: colorsList.colorWhite,
                  borderRadius: BorderRadius.circular(context.s(12)),
                  border: Border.all(color: colorsList.borderColor),
                ),
                child: _invoiceCard(
                  context: context,
                  invoice: invoice,
                  asGridTile: true,
                ),
              )
            : Column(
                children: [
                  _invoiceCard(
                    context: context,
                    invoice: invoice,
                    asGridTile: false,
                  ),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFE9EDF3),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _invoiceCard({
    required BuildContext context,
    required InvoicesModel invoice,
    required bool asGridTile,
  }) {
    final rs = context.rs;
    final String status = invoice.status.toLowerCase();

    Color statusColor;

    if (status == 'paid') {
      statusColor = const Color(0xFF00B894);
    } else if (status == 'pending' || status == 'unpaid') {
      statusColor = const Color(0xFFF39C12);
    } else if (status == 'overdue') {
      statusColor = Colors.red;
    } else {
      statusColor = const Color(0xFF71829A);
    }

    final String displayStatus = status.isNotEmpty
        ? status[0].toUpperCase() + status.substring(1)
        : 'Unknown';

    return Container(
      color: asGridTile ? Colors.transparent : colorsList.colorWhite,
      padding: EdgeInsets.symmetric(
        horizontal: asGridTile ? rs.s(12) : rs.s(16),
        vertical: rs.s(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: rs.s(44),
            height: rs.s(44),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(rs.s(12)),
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              color: colorsList.iconColor,
              size: rs.s(28),
            ),
          ),
          SizedBox(width: rs.s(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  invoice.invoiceNumber ?? 'No Invoice Number',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colorsList.textColor,
                    fontSize: rs.sp(16),
                    fontWeight: FontWeight.normal,
                  ),
                ),
                SizedBox(height: rs.s(5)),
                Text(
                  invoice.issueDate ?? 'N/A',
                  style: TextStyle(
                    color: colorsList.textHintColor,
                    fontSize: rs.sp(12),
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: rs.s(8)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: rs.s(10),
                  vertical: rs.s(4),
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  displayStatus,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: rs.sp(12),
                  ),
                ),
              ),
              SizedBox(height: rs.s(4)),
              Text(
                'Paid: ${invoicesController.formatCurrency(
                  invoice.paidAmount,
                  invoice.currencyCode,
                )}',
                style: TextStyle(
                  color: const Color(0xFF16A34A),
                  fontSize: rs.sp(11),
                  fontWeight: FontWeight.normal,
                ),
              ),
              SizedBox(height: rs.s(2)),
              Text(
                invoicesController.formatCurrency(
                  invoice.grossAmount,
                  invoice.currencyCode,
                ),
                style: TextStyle(
                  color: colorsList.textColor,
                  fontSize: rs.sp(12),
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
