import 'package:flutter/material.dart';
import 'package:gf_qr/ui/pages/scanner_page.dart';
import 'package:gf_qr/features/maker/qr_maker_page.dart';
import 'package:gf_qr/ui/atoms/glass_container.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const ScannerPage(),
    const QRMakerPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _pages[_currentIndex],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0),
        child: GlassContainer(
          borderRadius: 32.0,
          opacity: 0.15,
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              indicatorColor: Colors.purple.withOpacity(0.3),
              labelTextStyle: WidgetStateProperty.all(
                const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
            child: NavigationBar(
              height: 70,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.qr_code_scanner),
                  label: 'Scan',
                ),
                NavigationDestination(
                  icon: Icon(Icons.add_box_outlined),
                  selectedIcon: Icon(Icons.add_box),
                  label: 'Create',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
