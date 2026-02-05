import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:gf_qr/ui/atoms/glass_container.dart';

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
        GlassContainer(
          borderRadius: 24,
          opacity: 0.1,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: QrImageView(
              data: _qrData,
              version: QrVersions.auto,
              size: 200.0,
              eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.circle, color: Colors.white),
              dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.circle, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.share)),
            const SizedBox(width: 24),
            IconButton(onPressed: () {}, icon: const Icon(Icons.download)),
          ],
        )
      ],
    );
  }
}
