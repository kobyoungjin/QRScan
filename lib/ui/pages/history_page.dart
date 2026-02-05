import 'package:flutter/material.dart';
import 'package:gf_qr/features/history/history_service.dart';
import 'package:gf_qr/ui/atoms/glass_container.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final history = HistoryService.getAll();

    return Scaffold(
      appBar: AppBar(title: const Text('HISTORY')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: history.length,
        itemBuilder: (context, index) {
          final item = history[index] as Map;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: GlassContainer(
              opacity: 0.1,
              child: ListTile(
                leading: Icon(_getIconForType(item['type'])),
                title: Text(item['data'], maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(item['timestamp'].toString().substring(0, 10)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'url': return Icons.language;
      case 'wifi': return Icons.wifi;
      case 'contact': return Icons.person;
      default: return Icons.text_fields;
    }
  }
}
