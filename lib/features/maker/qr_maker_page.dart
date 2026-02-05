import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:QR_Code/ui/atoms/glass_container.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image/image.dart' as img;

enum QRType { profile, website, banking }

class QRMakerPage extends StatefulWidget {
  const QRMakerPage({super.key});

  @override
  State<QRMakerPage> createState() => _QRMakerPageState();
}

class _QRMakerPageState extends State<QRMakerPage> {
  QRType _selectedType = QRType.website;
  final TextEditingController _primaryController = TextEditingController();
  final TextEditingController _secondaryController = TextEditingController();
  String _qrData = "";
  final GlobalKey _qrKey = GlobalKey();

  @override
  void dispose() {
    _primaryController.dispose();
    _secondaryController.dispose();
    super.dispose();
  }

  void _generateQR() {
    setState(() {
      switch (_selectedType) {
        case QRType.website:
          _qrData = _primaryController.text;
          break;
        case QRType.profile:
          _qrData = "PROFILE:${_primaryController.text}";
          break;
        case QRType.banking:
          _qrData = "BANK:BANK_NAME:${_primaryController.text};ACC_NUM:${_secondaryController.text}";
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR MAKER')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildTypeSelector(),
            const SizedBox(height: 24),
            _buildInputFields(),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _generateQR,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('GENERATE QR'),
            ),
            const SizedBox(height: 40),
            if (_qrData.isNotEmpty) _buildQRDisplay(),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: QRType.values.map((type) {
          final isSelected = _selectedType == type;
          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: ChoiceChip(
              label: Text(type.name.toUpperCase()),
              selected: isSelected,
              onSelected: (val) => setState(() => _selectedType = type),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInputFields() {
    String primaryLabel = "URL / Website";
    if (_selectedType == QRType.profile) primaryLabel = "Social Name / ID";
    if (_selectedType == QRType.banking) primaryLabel = "Bank Name";

    return Column(
      children: [
        TextField(
          controller: _primaryController,
          decoration: InputDecoration(
            labelText: primaryLabel,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        if (_selectedType == QRType.banking) ...[
          const SizedBox(height: 16),
          TextField(
            controller: _secondaryController,
            decoration: InputDecoration(
              labelText: "Account Number",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildQRDisplay() {
    return Column(
      children: [
        RepaintBoundary(
          key: _qrKey,
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(24.0),
            child: QrImageView(
              data: _qrData,
              version: QrVersions.auto,
              size: 200.0,
              eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.circle, color: Colors.black),
              dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.circle, color: Colors.black),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: _shareQR,
              icon: const Icon(Icons.share),
              tooltip: 'Share QR Code',
            ),
            const SizedBox(width: 24),
            IconButton(
              onPressed: _saveQR,
              icon: const Icon(Icons.download),
              tooltip: 'Save QR Code',
            ),
          ],
        )
      ],
    );
  }

  Future<File?> _captureQRImage() async {
    try {
      final RenderRepaintBoundary boundary =
          _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = await getTemporaryDirectory();
      final String filePath =
          '${directory.path}/qr_code_${DateTime.now().millisecondsSinceEpoch}.png';
      final File file = File(filePath);
      await file.writeAsBytes(pngBytes);
      return file;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error capturing QR code: $e')),
        );
      }
      return null;
    }
  }

  Future<void> _saveQR() async {
    final file = await _captureQRImage();
    if (file == null) return;

    try {
      Directory? directory;
      if (!kIsWeb && Platform.isWindows) {
        directory = await getDownloadsDirectory();
      }
      
      // Fallback to documents if downloads is unavailable
      directory ??= await getApplicationDocumentsDirectory();

      final now = DateTime.now();
      final timestamp = "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_"
                        "${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}";
      
      final String savePath = '${directory.path}/QR_Code_$timestamp.png';
      final File savedFile = await file.copy(savePath);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('QR code saved to: ${savedFile.path}'),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Open Folder',
              onPressed: () {
                if (Platform.isWindows) {
                  Process.run('explorer.exe', ['/select,', savedFile.path]);
                }
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving QR code: $e')),
        );
      }
    }
  }

  Future<void> _shareQR() async {
    final file = await _captureQRImage();
    if (file == null) return;

    try {
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'QR Code',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing QR code: $e')),
        );
      }
    }
  }
}
