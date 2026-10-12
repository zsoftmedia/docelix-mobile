import 'package:docelix_mobileapp/controllers/general_ledger_controller.dart';
import 'package:docelix_mobileapp/models/asset_model.dart';
import 'package:docelix_mobileapp/models/general_ledger_model.dart';
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GeneralLedgerScreen extends StatelessWidget {
  const GeneralLedgerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GeneralLedgerController());
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: colorsList.backgroundColor,
      appBar: AppBar(
        backgroundColor: colorsList.colorWhite,
        elevation: 0,
        surfaceTintColor: colorsList.colorWhite,
        leading: Obx(() {
          final searching = controller.isSearching.value;
          return IconButton(
            onPressed: () {
              if (searching) {
                controller.closeSearch();
              } else {
                Get.back();
              }
            },
            icon: Icon(
              searching
                  ? Icons.close_rounded
                  : Icons.arrow_back_ios_new_rounded,
              color: colorsList.iconColor,
              size: width * 0.05,
            ),
          );
        }),
        title: Obx(() {
          if (controller.isSearching.value) {
            return TextField(
              controller: controller.searchController,
              autofocus: true,
              onSubmitted: controller.applySearch,
              textInputAction: TextInputAction.search,
              style: TextStyle(
                color: colorsList.primaryText,
                fontSize: width * 0.04,
              ),
              decoration: InputDecoration(
                hintText: 'Search ledger...',
                hintStyle: TextStyle(
                  color: colorsList.mutedTextColor,
                  fontSize: width * 0.038,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            );
          }

          return Text(
            'General Ledger',
            style: TextStyle(
              color: colorsList.primaryText,
              fontSize: width * 0.048,
              fontWeight: FontWeight.w700,
            ),
          );
        }),
        centerTitle: false,
        actions: [
          Obx(() {
            if (controller.isSearching.value) {
              return IconButton(
                onPressed: () =>
                    controller.applySearch(controller.searchController.text),
                icon: Icon(
                  Icons.search_rounded,
                  color: colorsList.colorButton,
                  size: width * 0.06,
                ),
              );
            }

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: controller.openSearch,
                  icon: Icon(
                    Icons.search_rounded,
                    color: colorsList.iconColor,
                    size: width * 0.06,
                  ),
                ),
                Stack(
                  children: [
                    IconButton(
                      onPressed: () => _openFilters(controller),
                      icon: Icon(
                        Icons.tune_rounded,
                        color: colorsList.colorButton,
                        size: width * 0.055,
                      ),
                    ),
                    if (controller.hasActiveFilters)
                      Positioned(
                        right: 10,
                        top: 10,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: colorsList.colorButton,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            );
          }),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                width * 0.045,
                width * 0.03,
                width * 0.045,
                width * 0.02,
              ),
              child: Obx(
                () => Row(
                  children: [
                    Expanded(
                      child: _DateField(
                        label: controller.fromDateText,
                        onTap: () => controller.pickFromDate(context),
                      ),
                    ),
                    SizedBox(width: width * 0.025),
                    Expanded(
                      child: _DateField(
                        label: controller.toDateText,
                        onTap: () => controller.pickToDate(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.045),
              child: Obx(
                () => Row(
                  children: [
                    Expanded(
                      child: Text(
                        controller.accountFilterLabel(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colorsList.primaryText,
                          fontSize: width * 0.038,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.03,
                        vertical: width * 0.015,
                      ),
                      decoration: BoxDecoration(
                        color: colorsList.colorBoxDecoration,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${controller.entries.length} entries',
                        style: TextStyle(
                          color: colorsList.secondaryText,
                          fontSize: width * 0.028,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: width * 0.025),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.045),
              child: _SummaryStrip(controller: controller),
            ),
            SizedBox(height: width * 0.02),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.entries.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.entries.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: controller.loadReport,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: width * 0.25),
                        Icon(
                          Icons.menu_book_outlined,
                          size: width * 0.14,
                          color: colorsList.mutedTextColor,
                        ),
                        SizedBox(height: width * 0.04),
                        Text(
                          controller.searchQuery.value.trim().isNotEmpty
                              ? 'No entries match your search.'
                              : 'No ledger entries for this period.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: colorsList.secondaryText,
                            fontSize: width * 0.034,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.loadReport,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      width * 0.04,
                      width * 0.01,
                      width * 0.04,
                      width * 0.1,
                    ),
                    itemCount: controller.entries.length,
                    itemBuilder: (context, index) {
                      final entry = controller.entries[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: width * 0.025),
                        child: _LedgerEntryCard(
                          controller: controller,
                          entry: entry,
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _openFilters(GeneralLedgerController controller) {
    Get.bottomSheet(
      _FiltersSheet(controller: controller),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.03,
          vertical: width * 0.028,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colorsList.borderColor),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: width * 0.04,
              color: colorsList.iconColor,
            ),
            SizedBox(width: width * 0.02),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colorsList.primaryText,
                  fontSize: width * 0.032,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryStrip extends StatelessWidget {
  const _SummaryStrip({required this.controller});

  final GeneralLedgerController controller;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Obx(() {
      final opening = controller.formatMoney(controller.openingBalance);
      final debit = controller.formatMoney(controller.totalDebit);
      final credit = controller.formatMoney(controller.totalCredit);
      final closing = controller.formatMoney(controller.closingBalance);
      final sourceLabel = controller.sourceTypeFilterLabel();

      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _SummaryCard(label: 'Opening', value: opening),
              ),
              SizedBox(width: width * 0.02),
              Expanded(
                child: _SummaryCard(label: 'Debit', value: debit),
              ),
              SizedBox(width: width * 0.02),
              Expanded(
                child: _SummaryCard(label: 'Credit', value: credit),
              ),
              SizedBox(width: width * 0.02),
              Expanded(
                child: _SummaryCard(label: 'Closing', value: closing),
              ),
            ],
          ),
          if (sourceLabel != 'All Sources') ...[
            SizedBox(height: width * 0.02),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.025,
                  vertical: width * 0.012,
                ),
                decoration: BoxDecoration(
                  color: colorsList.lightBlue.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  sourceLabel,
                  style: TextStyle(
                    color: colorsList.colorButton,
                    fontSize: width * 0.026,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      );
    });
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.02,
        vertical: width * 0.022,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colorsList.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colorsList.mutedTextColor,
              fontSize: width * 0.022,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: width * 0.008),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colorsList.primaryText,
              fontSize: width * 0.026,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _LedgerEntryCard extends StatelessWidget {
  const _LedgerEntryCard({required this.controller, required this.entry});

  final GeneralLedgerController controller;
  final GeneralLedgerEntryGroup entry;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final dateParts = controller.parseDateParts(entry.entryDate);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () =>
            Get.toNamed('/JournalEntryDetailsScreen', arguments: entry),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(width * 0.035),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorsList.borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.025),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: width * 0.11,
                    child: Column(
                      children: [
                        Text(
                          dateParts['day']!,
                          style: TextStyle(
                            fontSize: width * 0.05,
                            fontWeight: FontWeight.w800,
                            color: colorsList.primaryText,
                            height: 1,
                          ),
                        ),
                        SizedBox(height: width * 0.005),
                        Text(
                          dateParts['month']!,
                          style: TextStyle(
                            fontSize: width * 0.026,
                            fontWeight: FontWeight.w700,
                            color: colorsList.secondaryText,
                            letterSpacing: 0.4,
                          ),
                        ),
                        Text(
                          dateParts['year']!,
                          style: TextStyle(
                            fontSize: width * 0.024,
                            color: colorsList.mutedTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: width * 0.03),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colorsList.primaryText,
                            fontSize: width * 0.034,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: width * 0.01),
                        Text(
                          'Ref #${entry.sourceId ?? '—'} · Journal #${entry.journalEntryId}',
                          style: TextStyle(
                            color: colorsList.secondaryText,
                            fontSize: width * 0.026,
                          ),
                        ),
                        SizedBox(height: width * 0.015),
                        Wrap(
                          spacing: width * 0.015,
                          runSpacing: width * 0.01,
                          children: [
                            _Badge(
                              label: entry.sourceTypeLabel,
                              foreground: colorsList.secondaryText,
                              background: colorsList.colorBoxDecoration,
                            ),
                            _Badge(
                              label: entry.status,
                              foreground: const Color(0xFF16A34A),
                              background: const Color(0xFFDCFCE7),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: width * 0.02),
                  Text(
                    controller.formatMoney(entry.totalAmount),
                    style: TextStyle(
                      color: colorsList.primaryText,
                      fontSize: width * 0.034,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              SizedBox(height: width * 0.03),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  onPressed: () => Get.toNamed(
                    '/JournalEntryDetailsScreen',
                    arguments: entry,
                  ),
                  icon: Icon(Icons.visibility_outlined, size: width * 0.04),
                  label: Text(
                    'View',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: width * 0.03,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorsList.colorButton,
                    side: BorderSide(color: colorsList.borderColor),
                    padding: EdgeInsets.symmetric(
                      horizontal: width * 0.035,
                      vertical: width * 0.02,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.foreground,
    required this.background,
  });

  final String label;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.02,
        vertical: width * 0.008,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: width * 0.022,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _FiltersSheet extends StatelessWidget {
  const _FiltersSheet({required this.controller});

  final GeneralLedgerController controller;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: EdgeInsets.only(top: width * 0.2),
      padding: EdgeInsets.fromLTRB(
        width * 0.045,
        width * 0.04,
        width * 0.045,
        bottom + width * 0.05,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Obx(() {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorsList.borderColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              SizedBox(height: width * 0.035),
              Text(
                'Filters',
                style: TextStyle(
                  color: colorsList.primaryText,
                  fontSize: width * 0.045,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: width * 0.04),
              _FieldLabel('Account'),
              _DropdownShell(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int?>(
                    isExpanded: true,
                    value: controller.selectedAccountId.value,
                    hint: const Text('All Accounts'),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('All Accounts'),
                      ),
                      ...controller.accounts.map(
                        (LedgerAccount account) => DropdownMenuItem<int?>(
                          value: account.id,
                          child: Text(
                            account.displayLabel,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                    onChanged: controller.setAccountFilter,
                  ),
                ),
              ),
              SizedBox(height: width * 0.03),
              _FieldLabel('Source Type'),
              _DropdownShell(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String?>(
                    isExpanded: true,
                    value: controller.selectedSourceType.value,
                    hint: const Text('All Sources'),
                    items: GeneralLedgerController.sourceTypeOptions
                        .map(
                          (option) => DropdownMenuItem<String?>(
                            value: option.key.isEmpty ? null : option.key,
                            child: Text(option.value),
                          ),
                        )
                        .toList(),
                    onChanged: controller.setSourceTypeFilter,
                  ),
                ),
              ),
              SizedBox(height: width * 0.05),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        controller.clearFilters();
                        Get.back();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: width * 0.035),
                        side: BorderSide(color: colorsList.borderColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Reset',
                        style: TextStyle(
                          color: colorsList.primaryText,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: width * 0.03),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: Get.back,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorsList.colorButton,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: width * 0.035),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Done',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.only(bottom: width * 0.015),
      child: Text(
        text,
        style: TextStyle(
          color: colorsList.secondaryText,
          fontSize: width * 0.028,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _DropdownShell extends StatelessWidget {
  const _DropdownShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: width * 0.03),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorsList.borderColor),
      ),
      child: child,
    );
  }
}
