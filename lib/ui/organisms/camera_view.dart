import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:vibration/vibration.dart';
import 'package:gf_qr/core/action_resolver.dart';
import 'package:gf_qr/ui/atoms/glass_container.dart';
import 'package:gf_qr/ui/molecules/scan_line.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gf_qr/features/history/history_service.dart';

class CameraView extends StatefulWidget {
  const CameraView({super.key});

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
  );

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MobileScanner(
          controller: controller,
          onDetect: (capture) {
            final List<Barcode> barcodes = capture.barcodes;
            if (barcodes.isNotEmpty) {
              final barcode = barcodes.first;
              final String? code = barcode.rawValue;
              _handleAutoZoom(barcode);
              if (code != null) {
                _handleDetection(code);
              }
            }
          },
        ),
        Center(
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.0),
              borderRadius: BorderRadius.circular(24.0),
            ),
            child: const ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(24.0)),
              child: Stack(
                children: [
                   ScanLine(),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 32,
          left: 0,
          right: 0,
          child: Center(
            child: _buildTorchButton(),
          ),
        ),
      ],
    );
  }

  Widget _buildTorchButton() {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        final state = controller.value.torchState;
        return GlassContainer(
          borderRadius: 50.0,
          opacity: 0.2,
          child: IconButton(
            icon: Icon(
              state == TorchState.on ? Icons.flash_on : Icons.flash_off,
              color: state == TorchState.on ? Colors.yellow : Colors.white,
            ),
            onPressed: () => controller.toggleTorch(),
          ),
        );
      },
    );
  }

  void _handleDetection(String code) {
    final result = ActionResolver.resolve(code);
    HistoryService.add(result);
    Vibration.vibrate(duration: 50, amplitude: 128);
    _showResultDialog(result);
  }

  void _showResultDialog(ScanResult result) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return GlassContainer(
          borderRadius: 24.0,
          opacity: 0.3,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_getIconForType(result.type), size: 48, color: Colors.blueAccent),
                const SizedBox(height: 16),
                Text(
                  result.type.name.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(result.data, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    _performAction(result);
                    Navigator.pop(context);
                  },
                  child: Text(_getActionLabel(result.type)),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getActionLabel(QRDataType type) {
    switch (type) {
      case QRDataType.url: return 'Open Browser';
      case QRDataType.wifi: return 'Connect to Wi-Fi';
      case QRDataType.contact: return 'Add to Contacts';
      case QRDataType.text: return 'Copy to Clipboard';
    }
  }

  Future<void> _performAction(ScanResult result) async {
    switch (result.type) {
      case QRDataType.url:
        final Uri uri = Uri.parse(result.data);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        }
        break;
      case QRDataType.wifi:
        break;
      case QRDataType.contact:
        break;
      case QRDataType.text:
        break;
    }
  }

  void _handleAutoZoom(Barcode barcode) {
    final corners = barcode.corners;
    if (corners != null && corners.length >= 2) {
      final width = (corners[0].dx - corners[1].dx).abs();
      if (width < 100) {
        controller.setZoomScale(0.5); 
      }
    }
  }

  IconData _getIconForType(QRDataType type) {
    switch (type) {
      case QRDataType.url: return Icons.language;
      case QRDataType.wifi: return Icons.wifi;
      case QRDataType.contact: return Icons.person;
      case QRDataType.text: return Icons.text_fields;
    }
  }
}
