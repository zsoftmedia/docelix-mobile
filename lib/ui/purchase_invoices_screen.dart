import 'package:docelix_mobileapp/controllers/purchase_invoices_controller.dart';
import 'package:docelix_mobileapp/core/responsive/responsive.dart';
import 'package:docelix_mobileapp/models/purchase_invoices_model.dart';
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PurchaseInvoicesScreen extends StatefulWidget {
  const PurchaseInvoicesScreen({super.key});

  @override
  State<PurchaseInvoicesScreen> createState() => _PurchaseInvoicesScreenState();
}

class _PurchaseInvoicesScreenState extends State<PurchaseInvoicesScreen> {
  final PurchaseInvoicesController incomingInvoicesController =
      Get.put(PurchaseInvoicesController());

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;

    return Scaffold(
      backgroundColor: colorsList.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Obx(() {
          final bool searching = incomingInvoicesController.isSearching.value;

          return IconButton(
            onPressed: () {
              if (searching) {
                incomingInvoicesController.closeSearch();
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
          if (incomingInvoicesController.isSearching.value) {
            return TextField(
              autofocus: true,
              onChanged: incomingInvoicesController.searchIncomingInvoices,
              textInputAction: TextInputAction.search,
              style: TextStyle(
                color: colorsList.textColor,
                fontSize: rs.sp(16),
              ),
              decoration: const InputDecoration(
                hintText: 'Search purchase invoice...',
                hintStyle: TextStyle(
                  color: colorsList.textHintColor,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            );
          }

          return Text(
            'Purchase Invoice',
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
            if (incomingInvoicesController.isSearching.value) {
              return const SizedBox.shrink();
            }

            return IconButton(
              onPressed: incomingInvoicesController.openSearch,
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
                      'All Purchase Invoices',
                      style: TextStyle(
                        color: colorsList.textColor,
                        fontSize: rs.sp(17),
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: rs.s(14),
                        vertical: rs.s(6),
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF3FB),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Obx(() {
                        return Text(
                          '${incomingInvoicesController.invoices.length} Invoices',
                          style: TextStyle(
                            color: colorsList.textColor,
                            fontSize: rs.sp(12),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Obx(() {
                  if (incomingInvoicesController.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (incomingInvoicesController.filteredInvoices.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: incomingInvoicesController.refreshInvoices,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(height: rs.s(150)),
                          Center(
                            child: Text(
                              'No purchase invoices found.',
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
                  final invoices =
                      incomingInvoicesController.filteredInvoices;

                  if (cols <= 1) {
                    return RefreshIndicator(
                      onRefresh: incomingInvoicesController.refreshInvoices,
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
                    onRefresh: incomingInvoicesController.refreshInvoices,
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
            '/CreateIncomingInvoicesScreen',
            arguments: 'Create Incoming Invoices Screen',
          );

          if (result == true) {
            await incomingInvoicesController.refreshInvoices();
          }
        },
        backgroundColor: colorsList.colorButton,
        foregroundColor: colorsList.colorWhite,
        elevation: 4,
        icon: const Icon(
          Icons.add_rounded,
        ),
        label: Text(
          'Add Invoice',
          style: TextStyle(
            fontSize: rs.sp(15),
            fontWeight: FontWeight.w700,
            color: colorsList.colorWhite,
          ),
        ),
      ),
    );
  }

  Widget _invoiceTile({
    required BuildContext context,
    required PurchaseInvoicesModel invoice,
    required bool asGridTile,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: asGridTile ? BorderRadius.circular(context.s(12)) : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(context.s(12)),
        onTap: () async {
          final result = await Get.toNamed(
            '/IncomingInvoicesDetailsScreen',
            arguments: invoice,
          );

          if (result == true) {
            await incomingInvoicesController.refreshInvoices();
          }
        },
        child: asGridTile
            ? DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
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
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: colorsList.dividerColor,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _invoiceCard({
    required BuildContext context,
    required PurchaseInvoicesModel invoice,
    required bool asGridTile,
  }) {
    final rs = context.rs;
    final String status = invoice.status.toLowerCase();

    Color statusColor;

    if (status == 'paid') {
      statusColor = const Color(0xFF00B894);
    } else if (status == 'pending' || status == 'unpaid') {
      statusColor = const Color(0xFFF39C12);
    } else if (status == 'draft') {
      statusColor = const Color(0xFF71829A);
    } else if (status == 'overdue') {
      statusColor = Colors.red;
    } else {
      statusColor = const Color(0xFF71829A);
    }

    final String displayStatus = status.isNotEmpty
        ? status[0].toUpperCase() + status.substring(1)
        : 'Unknown';

    return Container(
      color: asGridTile ? Colors.transparent : Colors.white,
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
              Icons.receipt_long_sharp,
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
                    fontSize: rs.sp(14),
                  ),
                ),
                SizedBox(height: rs.s(5)),
                Text(
                  invoice.supplierName ?? 'Unknown Supplier',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colorsList.textHintColor,
                    fontSize: rs.sp(12),
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
              SizedBox(height: rs.s(5)),
              Text(
                incomingInvoicesController.formatCurrency(
                  invoice.totalAmount,
                  invoice.currency,
                ),
                style: TextStyle(
                  color: colorsList.textColor,
                  fontSize: rs.sp(14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
