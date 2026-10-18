import 'package:docelix_mobileapp/core/responsive/responsive.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanQrScreen extends StatefulWidget {
  const ScanQrScreen({super.key});

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  bool isScanned = false;

  void _onDetect(BarcodeCapture capture) {
    if (isScanned) {
      return;
    }

    if (capture.barcodes.isEmpty) {
      return;
    }

    final String? value = capture.barcodes.first.rawValue;

    if (value == null || value.isEmpty) {
      return;
    }

    isScanned = true;

    Navigator.pop(
      context,
      value,
    );
  }

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;
    final frameSize = (rs.shortestSide * 0.55).clamp(220.0, 340.0);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            onDetect: _onDetect,
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: rs.s(16),
                vertical: rs.s(10),
              ),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: rs.s(22),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Scan QR Code',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: rs.sp(18),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: rs.s(48)),
                ],
              ),
            ),
          ),
          Center(
            child: Container(
              width: frameSize,
              height: frameSize,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(rs.s(20)),
              ),
            ),
          ),
          Positioned(
            left: rs.s(30),
            right: rs.s(30),
            bottom: rs.s(70),
            child: Column(
              children: [
                Text(
                  'Scan QR Code',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: rs.sp(20),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: rs.s(8)),
                Text(
                  'Position the QR code inside the frame',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: rs.sp(14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
