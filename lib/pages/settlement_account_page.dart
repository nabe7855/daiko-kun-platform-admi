import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/platform_provider.dart';

class SettlementAccountPage extends ConsumerStatefulWidget {
  const SettlementAccountPage({super.key});

  @override
  ConsumerState<SettlementAccountPage> createState() =>
      _SettlementAccountPageState();
}

class _SettlementAccountPageState extends ConsumerState<SettlementAccountPage> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final year = _selectedDate.year.toString();
    final month = _selectedDate.month.toString();

    return Scaffold(
      appBar: AppBar(
        title: const Text('精算・売上管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'CSVエクスポート',
            onPressed: () {
              // Simulating export
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$year年$month月の精算CSVを書き出しました')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: Column(
        children: [
          // 月選択エリア
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    setState(() {
                      _selectedDate = DateTime(
                        _selectedDate.year,
                        _selectedDate.month - 1,
                      );
                    });
                  },
                ),
                Text(
                  '$year年 $month月',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    setState(() {
                      _selectedDate = DateTime(
                        _selectedDate.year,
                        _selectedDate.month + 1,
                      );
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<CompanySettlement>>(
              future: ref
                  .read(platformProvider.notifier)
                  .fetchSettlements(year: year, month: month),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final settlements = snapshot.data ?? [];
                if (settlements.isEmpty) {
                  return const Center(child: Text('この月のデータはありません'));
                }

                final formatter = NumberFormat.currency(
                  locale: 'ja_JP',
                  symbol: '¥',
                  decimalDigits: 0,
                );

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '加盟会社別 売上・手数料内訳',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: settlements.length,
                        itemBuilder: (context, index) {
                          final item = settlements[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        item.companyName,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Chip(
                                        label: Text(
                                          '${item.completedRides} 配車完了',
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(),
                                  _SettlementRow(
                                    label: '総売上',
                                    value: formatter.format(item.totalSales),
                                    color: Colors.black87,
                                  ),
                                  _SettlementRow(
                                    label: 'プラットフォーム手数料',
                                    value:
                                        '- ${formatter.format(item.platformFee)}',
                                    color: Colors.red.shade700,
                                  ),
                                  const Divider(),
                                  _SettlementRow(
                                    label: '加盟会社 振込額',
                                    value: formatter.format(item.netProfit),
                                    color: Colors.green.shade700,
                                    isBold: true,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SettlementRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isBold;

  const _SettlementRow({
    required this.label,
    required this.value,
    required this.color,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade700)),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }
}
