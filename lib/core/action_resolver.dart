enum QRDataType { url, wifi, contact, text }

class ScanResult {
  final QRDataType type;
  final String data;
  final Map<String, String>? metadata;

  ScanResult({required this.type, required this.data, this.metadata});
}

class ActionResolver {
  static ScanResult resolve(String rawData) {
    if (rawData.startsWith('http://') || rawData.startsWith('https://')) {
      return ScanResult(type: QRDataType.url, data: rawData);
    }
    
    if (rawData.startsWith('WIFI:')) {
      final Map<String, String> wifiData = {};
      final parts = rawData.substring(5).split(';');
      for (var part in parts) {
        final pair = part.split(':');
        if (pair.length == 2) {
          wifiData[pair[0]] = pair[1];
        }
      }
      return ScanResult(
        type: QRDataType.wifi, 
        data: wifiData['S'] ?? 'Unknown',
        metadata: wifiData,
      );
    }
    
    if (rawData.contains('BEGIN:VCARD')) {
      return ScanResult(type: QRDataType.contact, data: rawData);
    }

    return ScanResult(type: QRDataType.text, data: rawData);
  }
}
