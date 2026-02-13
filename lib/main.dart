import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'pages/company_management_page.dart';
import 'pages/login_page.dart';
import 'pages/settlement_account_page.dart';
import 'pages/super_dashboard_page.dart';
import 'pages/user_reports_page.dart';
import 'providers/auth_provider.dart';

void main() {
  runApp(const ProviderScope(child: PlatformAdminApp()));
}

class PlatformAdminApp extends StatelessWidget {
  const PlatformAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daiko-kun Platform Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    if (authState == null) {
      return const PlatformLoginPage();
    }
    return const PlatformDashboard();
  }
}

class PlatformDashboard extends ConsumerStatefulWidget {
  const PlatformDashboard({super.key});

  @override
  ConsumerState<PlatformDashboard> createState() => _PlatformDashboardState();
}

class _PlatformDashboardState extends ConsumerState<PlatformDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const SuperDashboardPage(),
    const CompanyManagementPage(),
    const SettlementAccountPage(),
    const UserReportsPage(),
    const Center(child: Text('リアルタイム監視 (実装予定)')),
  ];

  @override
  Widget build(BuildContext context) {
    final admin = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('運営事務局ポータル'),
        backgroundColor: Colors.teal.shade50,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Text(
                '運営: ${admin?.name}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.analytics_outlined),
                selectedIcon: Icon(Icons.analytics),
                label: Text('全体統計'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.business_outlined),
                selectedIcon: Icon(Icons.business),
                label: Text('加盟会社'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.payments_outlined),
                selectedIcon: Icon(Icons.payments),
                label: Text('精算管理'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.report_problem_outlined),
                selectedIcon: Icon(Icons.report_problem),
                label: Text('通報確認'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.monitor_heart_outlined),
                selectedIcon: Icon(Icons.monitor_heart),
                label: Text('監視'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: _pages[_selectedIndex]),
        ],
      ),
    );
  }
}
