import 'package:docelix_mobileapp/ui/purchase_invoices_screen.dart';
import 'package:flutter/material.dart';

class SuppliersScreen extends StatelessWidget {
  const SuppliersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PurchaseInvoicesScreen(
      initialTab: 1,
      isEmbedded: false,
    );
  }
}