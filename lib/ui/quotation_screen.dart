import 'package:docelix_mobileapp/ui/invoices_screen.dart';
import 'package:flutter/material.dart';

class QuotationScreen extends StatelessWidget {
  const QuotationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const InvoicesScreen(
      initialTab: 1,
      isEmbedded: false,
    );
  }
}