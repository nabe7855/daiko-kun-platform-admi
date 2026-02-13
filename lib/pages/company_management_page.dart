import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/platform_provider.dart';

class CompanyManagementPage extends ConsumerStatefulWidget {
  const CompanyManagementPage({super.key});

  @override
  ConsumerState<CompanyManagementPage> createState() =>
      _CompanyManagementPageState();
}

class _CompanyManagementPageState extends ConsumerState<CompanyManagementPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('加盟会社管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: FutureBuilder(
        future: ref.read(platformProvider.notifier).fetchCompanies(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final companies = snapshot.data ?? [];
          if (companies.isEmpty) {
            return const Center(child: Text('登録済みの会社はありません'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: companies.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final company = companies[index];
              return Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.business)),
                  title: Text(
                    company.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '状態: ${company.status} / 手数料: ${company.commissionRate}%',
                  ),
                  trailing: _buildStatusAction(company),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusAction(Company company) {
    if (company.status == 'pending') {
      return ElevatedButton(
        onPressed: () => _updateStatus(company.id, 'active'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        child: const Text('承認する'),
      );
    } else if (company.status == 'active') {
      return OutlinedButton(
        onPressed: () => _updateStatus(company.id, 'suspended'),
        style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
        child: const Text('一時停止'),
      );
    } else {
      return TextButton(
        onPressed: () => _updateStatus(company.id, 'active'),
        child: const Text('再開する'),
      );
    }
  }

  Future<void> _updateStatus(String id, String status) async {
    final success = await ref
        .read(platformProvider.notifier)
        .updateCompanyStatus(id, status);
    if (success && mounted) {
      setState(() {});
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('ステータスを $status に更新しました')));
    }
  }
}
