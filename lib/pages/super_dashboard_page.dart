import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/platform_provider.dart';

class SuperDashboardPage extends ConsumerWidget {
  const SuperDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(platformProvider);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'プラットフォーム全体統計',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          statsAsync.when(
            data: (stats) {
              if (stats == null)
                return const Center(child: Text('データを取得できませんでした'));

              final formatter = NumberFormat.currency(
                locale: 'ja_JP',
                symbol: '¥',
                decimalDigits: 0,
              );

              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _StatCard(
                    title: 'プラットフォーム収益',
                    value: formatter.format(stats.platformRevenue),
                    color: Colors.teal,
                    icon: Icons.account_balance_wallet,
                  ),
                  _StatCard(
                    title: '総流通額 (GTV)',
                    value: formatter.format(stats.totalSales),
                    color: Colors.blue,
                    icon: Icons.trending_up,
                  ),
                  _StatCard(
                    title: '提携会社数',
                    value: '${stats.totalCompanies} 社',
                    color: Colors.orange,
                    icon: Icons.business,
                  ),
                  _StatCard(
                    title: '総配車完了数',
                    value: '${stats.totalRequests} 件',
                    color: Colors.purple,
                    icon: Icons.check_circle,
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('エラーが発生しました: $err')),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border(left: BorderSide(color: color, width: 6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(icon, color: color.withOpacity(0.8), size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
