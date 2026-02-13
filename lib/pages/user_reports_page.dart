import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/platform_provider.dart';

class UserReportsPage extends ConsumerWidget {
  const UserReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('通報一覧'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<UserReport>>(
        future: ref.read(platformProvider.notifier).fetchReports(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('エラーが発生しました: ${snapshot.error}'));
          }
          final reports = snapshot.data ?? [];
          if (reports.isEmpty) {
            return const Center(child: Text('通報はありません'));
          }

          return ListView.separated(
            itemCount: reports.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final report = reports[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: report.reporterRole == 'customer'
                      ? Colors.orange
                      : Colors.blue,
                  child: Icon(
                    report.reporterRole == 'customer'
                        ? Icons.person
                        : Icons.local_taxi,
                    color: Colors.white,
                  ),
                ),
                title: Text(
                  report.reason,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('通報者: ${report.reporterRole} (${report.reporterId})'),
                    Text('対象者: ${report.reportedUserId}'),
                    Text(
                      '日時: ${DateFormat('yyyy/MM/dd HH:mm').format(report.createdAt)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                trailing: Chip(
                  label: Text(report.status),
                  backgroundColor: report.status == 'pending'
                      ? Colors.red[100]
                      : Colors.green[100],
                ),
                onTap: () {
                  // 詳細表示やステータス変更のロジックをここに追加可能
                },
              );
            },
          );
        },
      ),
    );
  }
}
