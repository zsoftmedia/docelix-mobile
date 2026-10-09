import 'package:docelix_mobileapp/controllers/asset_details_controller.dart';
import 'package:docelix_mobileapp/controllers/general_ledger_controller.dart';
import 'package:docelix_mobileapp/models/asset_model.dart';
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class AssetDetailsScreen extends StatefulWidget {
  const AssetDetailsScreen({super.key});

  @override
  State<AssetDetailsScreen> createState() => _AssetDetailsScreenState();
}

class _AssetDetailsScreenState extends State<AssetDetailsScreen>
    with SingleTickerProviderStateMixin {
  late final AssetDetailsController controller;
  late final TabController tabController;

  static const _tabs = [
    'Overview',
    'Accounting',
    'Depreciation',
    'Journals',
    'Documents',
    'History',
  ];

  @override
  void initState() {
    super.initState();
    final arg = Get.arguments;
    final initial = arg is AssetModel
        ? arg
        : const AssetModel(
            id: 0,
            companyId: 0,
            name: 'Asset',
            status: 'Active',
            purchasePrice: 0,
            currentBookValue: 0,
          );

    controller = Get.put(
      AssetDetailsController(initialAsset: initial),
      tag: 'asset_${initial.id}',
    );
    tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    Get.delete<AssetDetailsController>(
      tag: 'asset_${controller.asset.value.id}',
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: colorsList.backgroundColor,
      appBar: AppBar(
        backgroundColor: colorsList.colorWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: colorsList.colorWhite,
        leading: IconButton(
          onPressed: Get.back,
          icon: Icon(
            Icons.close_rounded,
            color: colorsList.iconColor,
            size: width * 0.055,
          ),
        ),
        title: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                controller.asset.value.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colorsList.primaryText,
                  fontSize: width * 0.042,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if ((controller.asset.value.assetNumber ?? '').isNotEmpty)
                Text(
                  controller.asset.value.assetNumber!,
                  style: TextStyle(
                    color: colorsList.secondaryText,
                    fontSize: width * 0.026,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {
              Get.snackbar(
                'Coming soon',
                'Edit asset will be available in a later update.',
                snackPosition: SnackPosition.BOTTOM,
                margin: const EdgeInsets.all(16),
              );
            },
            icon: Icon(
              Icons.edit_outlined,
              color: colorsList.colorButton,
              size: width * 0.055,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: colorsList.colorWhite,
            padding: EdgeInsets.fromLTRB(
              width * 0.04,
              0,
              width * 0.04,
              width * 0.03,
            ),
            child: _SummaryCard(controller: controller),
          ),
          Container(
            color: colorsList.colorWhite,
            child: TabBar(
              controller: tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              padding: EdgeInsets.symmetric(horizontal: width * 0.02),
              labelPadding: EdgeInsets.symmetric(horizontal: width * 0.035),
              labelColor: colorsList.colorButton,
              unselectedLabelColor: colorsList.mutedTextColor,
              indicatorColor: colorsList.colorButton,
              indicatorWeight: 2.5,
              indicatorSize: TabBarIndicatorSize.label,
              dividerColor: colorsList.borderColor,
              labelStyle: TextStyle(
                fontSize: width * 0.032,
                fontWeight: FontWeight.w700,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: width * 0.032,
                fontWeight: FontWeight.w500,
              ),
              tabs: _tabs.map((t) => Tab(height: 40, text: t)).toList(),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                _OverviewTab(controller: controller),
                _AccountingTab(controller: controller),
                _DepreciationTab(controller: controller),
                _JournalEntriesTab(controller: controller),
                _DocumentsTab(controller: controller),
                _HistoryTab(controller: controller),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.controller});

  final AssetDetailsController controller;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Obx(() {
      final asset = controller.asset.value;
      final statusColor = _statusColor(asset.status);

      return Container(
        padding: EdgeInsets.all(width * 0.035),
        decoration: BoxDecoration(
          color: colorsList.colorBoxDecoration.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colorsList.borderColor),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: width * 0.1,
                  height: width * 0.1,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(color: colorsList.borderColor),
                  ),
                  child: Icon(
                    Icons.inventory_2_outlined,
                    color: colorsList.colorButton,
                    size: width * 0.048,
                  ),
                ),
                SizedBox(width: width * 0.03),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        asset.categoryName,
                        style: TextStyle(
                          color: colorsList.secondaryText,
                          fontSize: width * 0.028,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: width * 0.008),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: width * 0.022,
                          vertical: width * 0.007,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          asset.status,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: width * 0.024,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: width * 0.03),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.01,
                vertical: width * 0.02,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorsList.borderColor),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _MetricCell(
                      label: 'Purchase Price',
                      value: controller.formatMoney(asset.purchasePrice),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: width * 0.08,
                    color: colorsList.borderColor,
                  ),
                  Expanded(
                    child: _MetricCell(
                      label: 'Book Value',
                      value: controller.formatMoney(asset.currentBookValue),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: width * 0.08,
                    color: colorsList.borderColor,
                  ),
                  Expanded(
                    child: _MetricCell(
                      label: 'Purchase Date',
                      value: controller.formatDate(asset.purchaseDate).isEmpty
                          ? '—'
                          : controller.formatDate(asset.purchaseDate),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _MetricCell extends StatelessWidget {
  const _MetricCell({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * 0.015),
      child: Column(
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colorsList.mutedTextColor,
              fontSize: width * 0.02,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: width * 0.01),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colorsList.primaryText,
              fontSize: width * 0.028,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.controller});

  final AssetDetailsController controller;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Obx(() {
      final asset = controller.asset.value;
      final fields = <_DetailItem>[
        _DetailItem('Ownership Type', asset.ownershipType),
        _DetailItem('Supplier', asset.supplierName),
        _DetailItem('Invoice Reference', asset.invoiceReference),
        _DetailItem('Serial Number', asset.serialNumber),
        _DetailItem('Location', asset.location),
        _DetailItem(
          'Warranty Until',
          asset.warrantyUntil == null || asset.warrantyUntil!.trim().isEmpty
              ? null
              : controller.formatDate(asset.warrantyUntil),
        ),
        _DetailItem('Notes', asset.notes),
      ].where((item) => item.hasValue).toList();

      return ListView(
        padding: EdgeInsets.fromLTRB(
          width * 0.04,
          width * 0.035,
          width * 0.04,
          width * 0.08,
        ),
        children: [
          if (fields.isEmpty)
            _EmptyDetailsCard(message: 'No overview details available.')
          else
            _DetailsPanel(
              children: [
                for (var i = 0; i < fields.length; i += 2)
                  _DetailRowPair(
                    left: fields[i],
                    right: i + 1 < fields.length ? fields[i + 1] : null,
                  ),
              ],
            ),
        ],
      );
    });
  }
}

class _AccountingTab extends StatelessWidget {
  const _AccountingTab({required this.controller});

  final AssetDetailsController controller;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Obx(() {
      final asset = controller.asset.value;
      final ledger = controller.ledgerAccount;
      final depExpense = controller.depreciationExpenseAccount;
      final rate = asset.annualDepreciationRate;
      final startDate = controller.formatDate(asset.depreciationStartDate);
      final purchaseDate = controller.formatDate(asset.purchaseDate);

      final fullWidth = <_DetailItem>[
        _DetailItem('Ledger Account', ledger?.displayLabel),
        _DetailItem('Depreciation Expense Account', depExpense?.displayLabel),
      ].where((item) => item.hasValue).toList();

      final paired = <_DetailItem>[
        _DetailItem('Depreciation Method', asset.depreciationMethod),
        _DetailItem(
          'Depreciation Start',
          startDate.isNotEmpty
              ? startDate
              : (purchaseDate.isEmpty ? null : purchaseDate),
        ),
        _DetailItem(
          'Useful Life',
          asset.usefulLifeYears == null
              ? null
              : '${asset.usefulLifeYears} years',
        ),
        _DetailItem(
          'Annual Rate',
          rate == null ? null : '${rate.toStringAsFixed(2)}%',
        ),
        _DetailItem('Cost Center', asset.costCenter),
      ].where((item) => item.hasValue).toList();

      return ListView(
        padding: EdgeInsets.fromLTRB(
          width * 0.04,
          width * 0.035,
          width * 0.04,
          width * 0.08,
        ),
        children: [
          if (fullWidth.isEmpty && paired.isEmpty)
            _EmptyDetailsCard(message: 'No accounting details available.')
          else
            _DetailsPanel(
              children: [
                ...fullWidth.map(
                  (item) => _DetailTile(item: item, fullWidth: true),
                ),
                for (var i = 0; i < paired.length; i += 2)
                  _DetailRowPair(
                    left: paired[i],
                    right: i + 1 < paired.length ? paired[i + 1] : null,
                  ),
              ],
            ),
        ],
      );
    });
  }
}

class _DepreciationTab extends StatelessWidget {
  const _DepreciationTab({required this.controller});

  final AssetDetailsController controller;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Obx(() {
      final rows = controller.asset.value.depreciationSchedule;
      final total = rows.fold<double>(0, (sum, row) => sum + row.depreciation);

      return ListView(
        padding: EdgeInsets.all(width * 0.045),
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colorsList.borderColor),
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.035,
                    vertical: width * 0.03,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text('YEAR', style: _headerStyle(width)),
                      ),
                      Expanded(
                        flex: 4,
                        child: Text(
                          'DEPRECIATION',
                          textAlign: TextAlign.right,
                          style: _headerStyle(width),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Text(
                          'ENDING BOOK VALUE',
                          textAlign: TextAlign.right,
                          style: _headerStyle(width),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                if (rows.isEmpty)
                  Padding(
                    padding: EdgeInsets.all(width * 0.06),
                    child: Text(
                      'No depreciation schedule available.',
                      style: TextStyle(
                        color: colorsList.secondaryText,
                        fontSize: width * 0.032,
                      ),
                    ),
                  )
                else
                  ...rows.map((row) {
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.035,
                        vertical: width * 0.03,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Row(
                              children: [
                                Text(
                                  '${row.year}',
                                  style: TextStyle(
                                    color: colorsList.primaryText,
                                    fontSize: width * 0.032,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (row.isCurrent) ...[
                                  SizedBox(width: width * 0.015),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: width * 0.018,
                                      vertical: width * 0.006,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorsList.lightBlue,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'Current',
                                      style: TextStyle(
                                        color: colorsList.colorButton,
                                        fontSize: width * 0.022,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: Text(
                              '-${controller.formatMoney(row.depreciation)}',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: colorsList.primaryText,
                                fontSize: width * 0.03,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: Text(
                              controller.formatMoney(row.endingBookValue),
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: colorsList.primaryText,
                                fontSize: width * 0.03,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                if (rows.isNotEmpty) ...[
                  const Divider(height: 1),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: width * 0.035,
                      vertical: width * 0.03,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            'Total',
                            style: TextStyle(
                              color: colorsList.primaryText,
                              fontSize: width * 0.032,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Text(
                            '-${controller.formatMoney(total)}',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: colorsList.primaryText,
                              fontSize: width * 0.032,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const Expanded(flex: 4, child: SizedBox()),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      );
    });
  }

  TextStyle _headerStyle(double width) {
    return TextStyle(
      color: colorsList.mutedTextColor,
      fontSize: width * 0.022,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.3,
    );
  }
}

class _JournalEntriesTab extends StatelessWidget {
  const _JournalEntriesTab({required this.controller});

  final AssetDetailsController controller;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Obx(() {
      if (controller.isLoadingJournal.value &&
          controller.journalEntries.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.journalEntries.isEmpty) {
        return Center(
          child: Text(
            'No journal entries for this asset.',
            style: TextStyle(
              color: colorsList.secondaryText,
              fontSize: width * 0.034,
            ),
          ),
        );
      }

      return ListView.separated(
        padding: EdgeInsets.all(width * 0.045),
        itemCount: controller.journalEntries.length,
        separatorBuilder: (_, _) => SizedBox(height: width * 0.03),
        itemBuilder: (context, index) {
          final entry = controller.journalEntries[index];
          return _JournalEntryCard(
            entry: entry,
            money: controller.formatMoney,
            date: controller.formatDate(entry.entryDate),
            onOpenLedger: () {
              if (Get.isRegistered<GeneralLedgerController>()) {
                Get.delete<GeneralLedgerController>(force: true);
              }
              Get.toNamed(
                '/GeneralLedgerScreen',
                arguments: {
                  'journalEntryId': entry.id,
                },
              );
            },
          );
        },
      );
    });
  }
}

class _JournalEntryCard extends StatelessWidget {
  const _JournalEntryCard({
    required this.entry,
    required this.money,
    required this.date,
    required this.onOpenLedger,
  });

  final AssetJournalEntry entry;
  final String Function(num value) money;
  final String date;
  final VoidCallback onOpenLedger;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.all(width * 0.035),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorsList.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: width * 0.02,
                      runSpacing: width * 0.01,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: width * 0.02,
                            vertical: width * 0.008,
                          ),
                          decoration: BoxDecoration(
                            color: colorsList.colorBoxDecoration,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            entry.sourceTypeLabel,
                            style: TextStyle(
                              color: colorsList.secondaryText,
                              fontSize: width * 0.022,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          entry.status,
                          style: TextStyle(
                            color: colorsList.green,
                            fontSize: width * 0.024,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: width * 0.02),
                    Text(
                      entry.description,
                      style: TextStyle(
                        color: colorsList.primaryText,
                        fontSize: width * 0.034,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (date.isNotEmpty) ...[
                      SizedBox(height: width * 0.008),
                      Text(
                        date,
                        style: TextStyle(
                          color: colorsList.secondaryText,
                          fontSize: width * 0.026,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    money(entry.totalAmount),
                    style: TextStyle(
                      color: colorsList.primaryText,
                      fontSize: width * 0.036,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: width * 0.015),
                  InkWell(
                    onTap: onOpenLedger,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: EdgeInsets.all(width * 0.015),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: colorsList.borderColor),
                      ),
                      child: Icon(
                        Icons.open_in_new_rounded,
                        size: width * 0.045,
                        color: colorsList.secondaryText,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (entry.lines.isNotEmpty) ...[
            SizedBox(height: width * 0.03),
            const Divider(height: 1),
            SizedBox(height: width * 0.02),
            ...entry.lines.map((line) {
              return Padding(
                padding: EdgeInsets.only(bottom: width * 0.02),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        line.accountLabel,
                        style: TextStyle(
                          color: colorsList.primaryText,
                          fontSize: width * 0.028,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: width * 0.22,
                      child: Text(
                        line.debit > 0 ? money(line.debit) : '',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: colorsList.primaryText,
                          fontSize: width * 0.028,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: width * 0.22,
                      child: Text(
                        line.credit > 0 ? money(line.credit) : '',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: colorsList.primaryText,
                          fontSize: width * 0.028,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}

class _DocumentsTab extends StatelessWidget {
  const _DocumentsTab({required this.controller});

  final AssetDetailsController controller;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Obx(() {
      return ListView(
        padding: EdgeInsets.all(width * 0.045),
        children: [
          Container(
            padding: EdgeInsets.all(width * 0.035),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colorsList.borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Document type',
                  style: TextStyle(
                    color: colorsList.secondaryText,
                    fontSize: width * 0.028,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: width * 0.015),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: width * 0.03,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: colorsList.borderColor),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: controller.selectedDocumentType.value,
                                items: AssetDetailsController.documentTypes
                                    .map(
                                      (type) => DropdownMenuItem(
                                        value: type,
                                        child: Text(type),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    controller.selectedDocumentType.value =
                                        value;
                                  }
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: width * 0.015),
                          Text(
                            'Images, PDF, or any other file.',
                            style: TextStyle(
                              color: colorsList.mutedTextColor,
                              fontSize: width * 0.024,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: width * 0.025),
                    ElevatedButton.icon(
                      onPressed: controller.isUploading.value
                          ? null
                          : controller.uploadDocument,
                      icon: controller.isUploading.value
                          ? SizedBox(
                              width: width * 0.04,
                              height: width * 0.04,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Icon(
                              Icons.cloud_upload_outlined,
                              size: width * 0.045,
                            ),
                      label: Text(
                        'Upload',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: width * 0.03,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorsList.colorButton,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: width * 0.03,
                          vertical: width * 0.035,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: width * 0.035),
          if (controller.isLoadingDocuments.value &&
              controller.documents.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (controller.documents.isEmpty)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: width * 0.12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: colorsList.borderColor,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: width * 0.14,
                    height: width * 0.14,
                    decoration: BoxDecoration(
                      color: colorsList.lightBlue,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.folder_outlined,
                      color: colorsList.secondaryText,
                      size: width * 0.07,
                    ),
                  ),
                  SizedBox(height: width * 0.03),
                  Text(
                    'No documents attached.',
                    style: TextStyle(
                      color: colorsList.secondaryText,
                      fontSize: width * 0.034,
                    ),
                  ),
                ],
              ),
            )
          else
            ...controller.documents.map((doc) {
              return Padding(
                padding: EdgeInsets.only(bottom: width * 0.025),
                child: _DocumentCard(
                  document: doc,
                  date: controller.formatDate(doc.createdAt),
                  onPreview: () => _openPreview(context, doc),
                  onDelete: () => _confirmDelete(context, doc),
                ),
              );
            }),
        ],
      );
    });
  }

  void _openPreview(BuildContext context, AssetDocument document) {
    final url = document.previewUrl;
    if (url == null || url.isEmpty) {
      Get.snackbar(
        'Unavailable',
        'No preview URL for this document.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    Get.to(
      () => Scaffold(
        backgroundColor: colorsList.backgroundColor,
        appBar: AppBar(
          backgroundColor: colorsList.colorWhite,
          title: Text(
            document.documentType,
            style: TextStyle(
              color: colorsList.primaryText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: document.isPdf
            ? SfPdfViewer.network(url)
            : document.isImage
            ? InteractiveViewer(
                child: Center(
                  child: Image.network(
                    url,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (_, _, _) => Center(
                      child: Text(
                        'Unable to load preview.',
                        style: TextStyle(color: colorsList.secondaryText),
                      ),
                    ),
                  ),
                ),
              )
            : Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.insert_drive_file_outlined,
                        size: 48,
                        color: colorsList.secondaryText,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Preview is not available for this file type.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: colorsList.secondaryText,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    AssetDocument document,
  ) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete document?'),
        content: Text('Remove "${document.documentType}" from this asset?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text('Delete', style: TextStyle(color: colorsList.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await controller.deleteDocument(document);
    }
  }
}

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({
    required this.document,
    required this.date,
    required this.onPreview,
    required this.onDelete,
  });

  final AssetDocument document;
  final String date;
  final VoidCallback onPreview;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.all(width * 0.035),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorsList.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: width * 0.11,
            height: width * 0.11,
            decoration: BoxDecoration(
              color: colorsList.lightBlue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              document.isPdf
                  ? Icons.picture_as_pdf_outlined
                  : document.isImage
                  ? Icons.image_outlined
                  : Icons.insert_drive_file_outlined,
              color: colorsList.colorButton,
              size: width * 0.05,
            ),
          ),
          SizedBox(width: width * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document.documentType,
                  style: TextStyle(
                    color: colorsList.primaryText,
                    fontSize: width * 0.034,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (date.isNotEmpty) ...[
                  SizedBox(height: width * 0.008),
                  Text(
                    date,
                    style: TextStyle(
                      color: colorsList.secondaryText,
                      fontSize: width * 0.026,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: onPreview,
            icon: Icon(
              Icons.visibility_outlined,
              color: colorsList.secondaryText,
              size: width * 0.055,
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: Icon(
              Icons.delete_outline_rounded,
              color: colorsList.secondaryText,
              size: width * 0.055,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryTab extends StatelessWidget {
  const _HistoryTab({required this.controller});

  final AssetDetailsController controller;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Obx(() {
      if (controller.isLoadingHistory.value && controller.history.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.history.isEmpty) {
        return Center(
          child: Text(
            'No history yet.',
            style: TextStyle(
              color: colorsList.secondaryText,
              fontSize: width * 0.034,
            ),
          ),
        );
      }

      return ListView(
        padding: EdgeInsets.all(width * 0.045),
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.035,
              vertical: width * 0.02,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colorsList.borderColor),
            ),
            child: Column(
              children: controller.history.map((entry) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: width * 0.025),
                  child: Row(
                    children: [
                      Container(
                        width: width * 0.022,
                        height: width * 0.022,
                        decoration: const BoxDecoration(
                          color: colorsList.colorButton,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: width * 0.03),
                      Expanded(
                        child: Text(
                          entry.title,
                          style: TextStyle(
                            color: colorsList.primaryText,
                            fontSize: width * 0.034,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        controller.formatDateTime(entry.changedAt),
                        style: TextStyle(
                          color: colorsList.secondaryText,
                          fontSize: width * 0.026,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      );
    });
  }
}

class _DetailItem {
  const _DetailItem(this.label, this.rawValue);

  final String label;
  final String? rawValue;

  bool get hasValue {
    final value = rawValue?.trim();
    return value != null && value.isNotEmpty && value != '—';
  }

  String get value => rawValue!.trim();
}

class _EmptyDetailsCard extends StatelessWidget {
  const _EmptyDetailsCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: width * 0.1),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorsList.borderColor),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: colorsList.secondaryText,
          fontSize: width * 0.033,
        ),
      ),
    );
  }
}

class _DetailsPanel extends StatelessWidget {
  const _DetailsPanel({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.035,
        vertical: width * 0.01,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorsList.borderColor),
      ),
      child: Column(children: children),
    );
  }
}

class _DetailRowPair extends StatelessWidget {
  const _DetailRowPair({required this.left, this.right});

  final _DetailItem left;
  final _DetailItem? right;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.symmetric(vertical: width * 0.028),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colorsList.borderColor.withValues(alpha: 0.8),
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _DetailTile(item: left)),
          SizedBox(width: width * 0.04),
          Expanded(
            child: right == null
                ? const SizedBox.shrink()
                : _DetailTile(item: right!),
          ),
        ],
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({required this.item, this.fullWidth = false});

  final _DetailItem item;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      width: fullWidth ? double.infinity : null,
      padding: fullWidth
          ? EdgeInsets.symmetric(vertical: width * 0.028)
          : EdgeInsets.zero,
      decoration: fullWidth
          ? BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: colorsList.borderColor.withValues(alpha: 0.8),
                ),
              ),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.label.toUpperCase(),
            style: TextStyle(
              color: colorsList.mutedTextColor,
              fontSize: width * 0.021,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.35,
            ),
          ),
          SizedBox(height: width * 0.01),
          Text(
            item.value,
            style: TextStyle(
              color: colorsList.primaryText,
              fontSize: width * 0.033,
              fontWeight: FontWeight.w600,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

Color _statusColor(String status) {
  switch (status.toLowerCase().replaceAll(' ', '_')) {
    case 'active':
      return colorsList.green;
    case 'under_repair':
      return colorsList.orange;
    case 'sold':
      return colorsList.blue;
    case 'scrapped':
    case 'archived':
      return colorsList.secondaryText;
    default:
      return colorsList.colorButton;
  }
}
