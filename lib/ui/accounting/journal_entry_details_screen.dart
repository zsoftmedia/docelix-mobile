import 'package:docelix_mobileapp/models/general_ledger_model.dart';
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:docelix_mobileapp/utils/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class JournalEntryDetailsScreen extends StatelessWidget {
  const JournalEntryDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final entry = Get.arguments;
    if (entry is! GeneralLedgerEntryGroup) {
      return Scaffold(
        backgroundColor: colorsList.backgroundColor,
        appBar: AppBar(
          backgroundColor: colorsList.colorWhite,
          title: const Text('Journal'),
        ),
        body: const Center(child: Text('Journal entry not found.')),
      );
    }

    final width = MediaQuery.of(context).size.width;
    final isBalanced = (entry.totalDebit - entry.totalCredit).abs() < 0.0001;
    final statusLabel = _titleCase(entry.status);
    final sourceLabel = _friendlySource(entry.sourceType);
    final dateLabel = _formatLongDate(entry.entryDate);
    final postedLabel = _formatPostedAt(entry.postedAt);

    return Scaffold(
      backgroundColor: colorsList.backgroundColor,
      appBar: AppBar(
        backgroundColor: colorsList.colorWhite,
        elevation: 0,
        surfaceTintColor: colorsList.colorWhite,
        leading: IconButton(
          onPressed: Get.back,
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colorsList.iconColor,
            size: width * 0.045,
          ),
        ),
        title: Text(
          'Journal #${entry.journalEntryId}',
          style: TextStyle(
            color: colorsList.primaryText,
            fontSize: width * 0.045,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Copy reference',
            onPressed: () async {
              await Clipboard.setData(
                ClipboardData(text: 'JE-${entry.journalEntryId}'),
              );
              Get.snackbar(
                'Copied',
                'Reference JE-${entry.journalEntryId} copied.',
                snackPosition: SnackPosition.BOTTOM,
                margin: const EdgeInsets.all(16),
              );
            },
            icon: Icon(
              Icons.copy_outlined,
              color: colorsList.iconColor,
              size: width * 0.055,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          width * 0.045,
          width * 0.035,
          width * 0.045,
          width * 0.12,
        ),
        children: [
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.description,
                  style: TextStyle(
                    color: colorsList.primaryText,
                    fontSize: width * 0.042,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: width * 0.025),
                Wrap(
                  spacing: width * 0.02,
                  runSpacing: width * 0.015,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _StatusChip(label: statusLabel),
                    Text(
                      dateLabel,
                      style: TextStyle(
                        color: colorsList.secondaryText,
                        fontSize: width * 0.03,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '·',
                      style: TextStyle(color: colorsList.mutedTextColor),
                    ),
                    Text(
                      sourceLabel,
                      style: TextStyle(
                        color: colorsList.secondaryText,
                        fontSize: width * 0.03,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: width * 0.03),
                Row(
                  children: [
                    Expanded(
                      child: _AmountTile(
                        label: 'Total Debit',
                        value: _money(entry.totalDebit),
                      ),
                    ),
                    SizedBox(width: width * 0.025),
                    Expanded(
                      child: _AmountTile(
                        label: 'Total Credit',
                        value: _money(entry.totalCredit),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: width * 0.04),
          _SectionTitle('Journal Information'),
          SizedBox(height: width * 0.02),
          _Card(
            child: Column(
              children: [
                _MetaRow(label: 'Reference', value: 'JE-${entry.journalEntryId}'),
                _Divider(),
                _MetaRow(label: 'Date', value: dateLabel),
                _Divider(),
                _MetaRow(label: 'Source', value: sourceLabel),
                _Divider(),
                _MetaRow(
                  label: 'Status',
                  valueWidget: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF16A34A),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: width * 0.015),
                      Text(
                        statusLabel,
                        style: TextStyle(
                          color: colorsList.primaryText,
                          fontSize: width * 0.033,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                _Divider(),
                _MetaRow(
                  label: 'Posted at',
                  value: postedLabel.isEmpty ? '—' : postedLabel,
                ),
                _Divider(),
                _MetaRow(
                  label: 'Posted by',
                  value: (entry.postedBy == null || entry.postedBy!.isEmpty)
                      ? 'System'
                      : entry.postedBy!,
                ),
                if (entry.sourceId != null) ...[
                  _Divider(),
                  _MetaRow(
                    label: 'Source document',
                    value: '$sourceLabel #${entry.sourceId}',
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: width * 0.04),
          Row(
            children: [
              Expanded(child: _SectionTitle('Double Entry')),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.025,
                  vertical: width * 0.012,
                ),
                decoration: BoxDecoration(
                  color: isBalanced
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isBalanced
                          ? Icons.check_circle_rounded
                          : Icons.error_outline_rounded,
                      size: width * 0.04,
                      color: isBalanced
                          ? const Color(0xFF16A34A)
                          : colorsList.red,
                    ),
                    SizedBox(width: width * 0.01),
                    Text(
                      isBalanced ? 'Balanced' : 'Unbalanced',
                      style: TextStyle(
                        color: isBalanced
                            ? const Color(0xFF16A34A)
                            : colorsList.red,
                        fontSize: width * 0.028,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: width * 0.02),
          _Card(
            child: Column(
              children: [
                for (var i = 0; i < entry.lines.length; i++) ...[
                  if (i > 0) _Divider(),
                  _LedgerLineTile(line: entry.lines[i]),
                ],
                _Divider(),
                Padding(
                  padding: EdgeInsets.only(top: width * 0.01),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Totals',
                          style: TextStyle(
                            color: colorsList.primaryText,
                            fontSize: width * 0.034,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Debit  ${_money(entry.totalDebit)}',
                            style: TextStyle(
                              color: colorsList.primaryText,
                              fontSize: width * 0.03,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: width * 0.01),
                          Text(
                            'Credit  ${_money(entry.totalCredit)}',
                            style: TextStyle(
                              color: colorsList.primaryText,
                              fontSize: width * 0.03,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _money(num value) {
    final code =
        SessionManager.accessCorrencycode?.trim().toUpperCase() ?? 'EUR';
    final symbol = switch (code) {
      'EUR' => '€',
      'USD' => '\$',
      'GBP' => '£',
      'PKR' => 'Rs ',
      _ => '$code ',
    };
    return '$symbol${NumberFormat('#,##0.00').format(value)}';
  }

  static String _formatLongDate(String? raw) {
    if (raw == null || raw.isEmpty) return '—';
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    return DateFormat('dd MMM yyyy').format(parsed);
  }

  static String _formatPostedAt(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    return DateFormat('d MMM yyyy, HH:mm').format(parsed.toLocal());
  }

  static String _titleCase(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1).toLowerCase();
  }

  static String _friendlySource(String sourceType) {
    switch (sourceType) {
      case 'asset_purchase':
      case 'asset_depreciation':
      case 'asset_disposal':
        return 'Fixed asset';
      case 'invoice_issue':
        return 'Invoice issue';
      case 'invoice_payment':
        return 'Invoice payment';
      case 'incoming_invoice_expense_unpaid':
        return 'Incoming invoice';
      case 'bank_transaction':
        return 'Bank transaction';
      case 'cash_transaction':
        return 'Cash transaction';
      default:
        return sourceType.replaceAll('_', ' ');
    }
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(width * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorsList.borderColor),
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Text(
      text,
      style: TextStyle(
        color: colorsList.primaryText,
        fontSize: width * 0.036,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.025,
        vertical: width * 0.01,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: Color(0xFF16A34A),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: width * 0.015),
          Text(
            label,
            style: TextStyle(
              color: const Color(0xFF16A34A),
              fontSize: width * 0.028,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _AmountTile extends StatelessWidget {
  const _AmountTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.03,
        vertical: width * 0.025,
      ),
      decoration: BoxDecoration(
        color: colorsList.colorBoxDecoration,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: colorsList.mutedTextColor,
              fontSize: width * 0.024,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: width * 0.01),
          Text(
            value,
            style: TextStyle(
              color: colorsList.primaryText,
              fontSize: width * 0.034,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.label,
    this.value,
    this.valueWidget,
  });

  final String label;
  final String? value;
  final Widget? valueWidget;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: width * 0.018),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: width * 0.32,
            child: Text(
              label,
              style: TextStyle(
                color: colorsList.mutedTextColor,
                fontSize: width * 0.03,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: valueWidget ??
                Text(
                  value ?? '—',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: colorsList.primaryText,
                    fontSize: width * 0.033,
                    fontWeight: FontWeight.w600,
                  ),
                ),
          ),
        ],
      ),
    );
  }
}

class _LedgerLineTile extends StatelessWidget {
  const _LedgerLineTile({required this.line});

  final GeneralLedgerTransaction line;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDebit = line.debit > 0;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: width * 0.02),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            line.account?.displayLabel ?? 'Account #${line.accountId}',
            style: TextStyle(
              color: colorsList.primaryText,
              fontSize: width * 0.033,
              fontWeight: FontWeight.w700,
            ),
          ),
          if ((line.lineDescription ?? '').isNotEmpty) ...[
            SizedBox(height: width * 0.01),
            Text(
              line.lineDescription!,
              style: TextStyle(
                color: colorsList.secondaryText,
                fontSize: width * 0.028,
              ),
            ),
          ],
          SizedBox(height: width * 0.02),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.02,
                  vertical: width * 0.008,
                ),
                decoration: BoxDecoration(
                  color: isDebit
                      ? colorsList.lightBlue.withValues(alpha: 0.55)
                      : colorsList.colorBoxDecoration,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isDebit ? 'Debit' : 'Credit',
                  style: TextStyle(
                    color: isDebit
                        ? colorsList.colorButton
                        : colorsList.secondaryText,
                    fontSize: width * 0.024,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                JournalEntryDetailsScreen._money(
                  isDebit ? line.debit : line.credit,
                ),
                style: TextStyle(
                  color: colorsList.primaryText,
                  fontSize: width * 0.036,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, color: colorsList.borderColor);
  }
}
