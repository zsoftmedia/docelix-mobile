import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:flutter/material.dart';

class GeneralLedgerScreen extends StatelessWidget {
  const GeneralLedgerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.book_outlined, size: 44, color: Color(0xFF94A3B8)),
          SizedBox(height: 12),
          Text(
            'General Ledger',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0A2342),
            ),
          ),
          SizedBox(height: 6),
          Text(
            'General ledger accounts view coming soon.',
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}