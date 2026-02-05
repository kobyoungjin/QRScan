import 'package:hive_flutter/hive_flutter.dart';
import 'package:gf_qr/core/action_resolver.dart';

class HistoryItem {
  final String data;
  final String timestamp;
  final QRDataType type;

  HistoryItem({required this.data, required this.timestamp, required this.type});
}

class HistoryService {
  static const String boxName = 'scan_history';

  static Future<void> init() async {
    await Hive.initFlutter();
    // In a real app, you would store this key securely (e.g. Flutter Secure Storage)
    final encryptionKey = Hive.generateSecureKey();
    await Hive.openBox(boxName, encryptionCipher: HiveAesCipher(encryptionKey));
  }

  static Future<void> add(ScanResult result) async {
    final box = Hive.box(boxName);
    final item = {
      'data': result.data,
      'type': result.type.name,
      'timestamp': DateTime.now().toIso8601String(),
    };
    await box.add(item);
  }

  static List<dynamic> getAll() {
    final box = Hive.box(boxName);
    return box.values.toList().reversed.toList();
  }
}
