import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:zxing2/qrcode.dart';
import 'package:zxing2/zxing2.dart';
import 'package:vibration/vibration.dart';
import 'package:QR_Code/core/action_resolver.dart';
import 'package:QR_Code/ui/atoms/glass_container.dart';
import 'package:QR_Code/ui/molecules/scan_line.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:QR_Code/features/history/history_service.dart';

class CameraView extends StatefulWidget {
  const CameraView({super.key});

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  // Unified Camera Controller
  CameraController? _controller;
  Timer? _scanTimer;
  bool _isScanning = false;
  bool _isInitialized = false;
  String? _initError;

  @override
  void initState() {
    super.initState();
    _initScanner();
  }

  Future<void> _initScanner() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _initError = 'No cameras found on this device');
        return;
      }

      debugPrint('Available cameras: ${cameras.length}');
      for (var i = 0; i < cameras.length; i++) {
        debugPrint('Camera $i: ${cameras[i].name} (${cameras[i].lensDirection})');
      }

      // Selection logic: Prefer back on mobile, first available on Windows
      CameraDescription selectedCamera = cameras.first;
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        try {
          selectedCamera = cameras.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.back,
          );
        } catch (_) {
          selectedCamera = cameras.first;
        }
      }

      _controller = CameraController(
        selectedCamera,
        ResolutionPreset.medium, // Start with medium for better compatibility on Windows
        enableAudio: false,
      );

      try {
        await _controller!.initialize();
      } catch (e) {
        debugPrint('Failed to initialize with medium preset, trying low: $e');
        // Retry with lower resolution
        _controller = CameraController(
          selectedCamera,
          ResolutionPreset.low,
          enableAudio: false,
        );
        await _controller!.initialize();
      }

      if (!mounted) return;

      setState(() {
        _isInitialized = true;
        _initError = null;
      });

      // Start periodic scanning
      _scanTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
        if (mounted && _isInitialized) {
          _scanFrame();
        }
      });
    } catch (e) {
      debugPrint('Critical error initializing camera: $e');
      if (mounted) {
        setState(() => _initError = 'Camera Error: $e');
      }
    }
  }

  Future<void> _scanFrame() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isScanning) return;

    _isScanning = true;
    try {
      final XFile imageFile = await _controller!.takePicture();
      final bytes = await imageFile.readAsBytes();
      
      // Decode image in background to keep UI responsive
      final decodedText = await compute(_decodeQR, bytes);
      
      if (decodedText != null && decodedText.isNotEmpty) {
        _handleDetection(decodedText);
      }
      
      // Clean up temporary image file
      await File(imageFile.path).delete();
    } catch (e) {
      debugPrint('Error scanning frame: $e');
    } finally {
      _isScanning = false;
    }
  }

  // Top-level or static function for compute()
  static String? _decodeQR(Uint8List bytes) {
    try {
      final img.Image? bitmap = img.decodeImage(bytes);
      if (bitmap == null) return null;
      
      final luminanceSource = _RGBLuminanceSource(bitmap);
      final binarizer = HybridBinarizer(luminanceSource);
      final binaryBitmap = BinaryBitmap(binarizer);
      
      final reader = QRCodeReader();
      final result = reader.decode(binaryBitmap);
      return result.text;
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _scanTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_initError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                _initError!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _initScanner,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized || _controller == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        CameraPreview(_controller!),
        _buildScannerOverlay(),
        Positioned(
          top: 40,
          left: 0,
          right: 0,
          child: Center(
            child: Chip(
              label: Text(kIsWeb || !Platform.isWindows ? 'Scanning Mode' : 'Windows PC Mode'),
              backgroundColor: Colors.black45,
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

  Widget _buildScannerOverlay() {
    return Center(
      child: Container(
        width: 350,
        height: 350,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white.withAlpha(76), width: 1.0),
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
    );
  }

  Widget _buildTorchButton() {
    if (_controller == null || !_controller!.value.isInitialized) return const SizedBox();
    
    final bool hasFlash = _controller!.value.description.lensDirection != CameraLensDirection.front;
    if (!hasFlash) return const SizedBox();

    return GlassContainer(
      borderRadius: 50.0,
      opacity: 0.2,
      child: IconButton(
        icon: const Icon(Icons.flash_on, color: Colors.white),
        onPressed: () async {
          // Flash toggle logic can be complex with CameraController, simplified here
          _controller!.setFlashMode(
            _controller!.value.flashMode == FlashMode.torch ? FlashMode.off : FlashMode.torch
          );
        },
      ),
    );
  }

  void _handleDetection(String code) {
    final result = ActionResolver.resolve(code);
    HistoryService.add(result);
    
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      try {
        Vibration.vibrate(duration: 50, amplitude: 128);
      } catch (_) {}
    }
    
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

  IconData _getIconForType(QRDataType type) {
    switch (type) {
      case QRDataType.url: return Icons.language;
      case QRDataType.wifi: return Icons.wifi;
      case QRDataType.contact: return Icons.person;
      case QRDataType.text: return Icons.text_fields;
    }
  }
}

class _RGBLuminanceSource extends LuminanceSource {
  final img.Image _image;

  _RGBLuminanceSource(this._image) : super(_image.width, _image.height);

  @override
  Int8List getMatrix() {
    final Int8List matrix = Int8List(width * height);
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final pixel = _image.getPixel(x, y);
        // Calculate luminance: Y = 0.299R + 0.587G + 0.114B
        final r = pixel.r;
        final g = pixel.g;
        final b = pixel.b;
        matrix[y * width + x] = (0.299 * r + 0.587 * g + 0.114 * b).toInt();
      }
    }
    return matrix;
  }

  @override
  Int8List getRow(int y, Int8List? row) {
    if (y < 0 || y >= height) {
      throw ArgumentError('Requested row is outside the image: $y');
    }
    final int width = this.width;
    if (row == null || row.length < width) {
      row = Int8List(width);
    }
    for (int x = 0; x < width; x++) {
      final pixel = _image.getPixel(x, y);
      final r = pixel.r;
      final g = pixel.g;
      final b = pixel.b;
      row[x] = (0.299 * r + 0.587 * g + 0.114 * b).toInt();
    }
    return row;
  }

  @override
  LuminanceSource crop(int left, int top, int width, int height) {
    return _RGBLuminanceSource(img.copyCrop(_image, x: left, y: top, width: width, height: height));
  }

  @override
  bool get isCropSupported => true;

  @override
  LuminanceSource rotateCounterClockwise() {
    return _RGBLuminanceSource(img.copyRotate(_image, angle: -90));
  }

  @override
  bool get isRotateSupported => true;
}
