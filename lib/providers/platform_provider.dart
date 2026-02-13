import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class PlatformStats {
  final int totalCompanies;
  final int totalDrivers;
  final int totalRequests;
  final double totalSales;
  final double platformRevenue;

  PlatformStats({
    required this.totalCompanies,
    required this.totalDrivers,
    required this.totalRequests,
    required this.totalSales,
    required this.platformRevenue,
  });

  factory PlatformStats.fromJson(Map<String, dynamic> json) {
    return PlatformStats(
      totalCompanies: json['total_companies'] ?? 0,
      totalDrivers: json['total_drivers'] ?? 0,
      totalRequests: json['total_requests'] ?? 0,
      totalSales: (json['total_sales'] ?? 0).toDouble(),
      platformRevenue: (json['platform_revenue'] ?? 0).toDouble(),
    );
  }
}

class Company {
  final String id;
  final String name;
  final String status;
  final double commissionRate;

  Company({
    required this.id,
    required this.name,
    required this.status,
    required this.commissionRate,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'],
      name: json['name'],
      status: json['status'],
      commissionRate: (json['commission_rate'] ?? 0).toDouble(),
    );
  }
}

class CompanySettlement {
  final String companyId;
  final String companyName;
  final double totalSales;
  final double platformFee;
  final double netProfit;
  final int completedRides;

  CompanySettlement({
    required this.companyId,
    required this.companyName,
    required this.totalSales,
    required this.platformFee,
    required this.netProfit,
    required this.completedRides,
  });

  factory CompanySettlement.fromJson(Map<String, dynamic> json) {
    return CompanySettlement(
      companyId: json['company_id'],
      companyName: json['company_name'],
      totalSales: (json['total_sales'] ?? 0).toDouble(),
      platformFee: (json['platform_fee'] ?? 0).toDouble(),
      netProfit: (json['net_profit'] ?? 0).toDouble(),
      completedRides: json['completed_rides'] ?? 0,
    );
  }
}

class PlatformNotifier extends AsyncNotifier<PlatformStats?> {
  @override
  Future<PlatformStats?> build() async {
    return fetchStats();
  }

  Future<PlatformStats?> fetchStats() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/admin/platform/stats'),
      );
      if (response.statusCode == 200) {
        return PlatformStats.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      print('Error fetching stats: $e');
    }
    return null;
  }

  Future<List<Company>> fetchCompanies() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/admin/platform/companies'),
      );
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((item) => Company.fromJson(item)).toList();
      }
    } catch (e) {
      print('Error fetching companies: $e');
    }
    return [];
  }

  Future<List<CompanySettlement>> fetchSettlements({
    String? year,
    String? month,
  }) async {
    try {
      String url = 'http://localhost:8080/admin/platform/settlements';
      if (year != null && month != null) {
        url += '?year=$year&month=$month';
      }
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((item) => CompanySettlement.fromJson(item)).toList();
      }
    } catch (e) {
      print('Error fetching settlements: $e');
    }
    return [];
  }

  Future<bool> updateCompanyStatus(String id, String status) async {
    try {
      final response = await http.patch(
        Uri.parse('http://localhost:8080/admin/platform/companies/$id/status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': status}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error updating company status: $e');
      return false;
    }
  }

  Future<List<UserReport>> fetchReports() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/admin/platform/reports'),
      );
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((item) => UserReport.fromJson(item)).toList();
      }
    } catch (e) {
      print('Error fetching reports: $e');
    }
    return [];
  }
}

class UserReport {
  final String id;
  final String rideId;
  final String reporterId;
  final String reportedUserId;
  final String reporterRole;
  final String reason;
  final String status;
  final DateTime createdAt;

  UserReport({
    required this.id,
    required this.rideId,
    required this.reporterId,
    required this.reportedUserId,
    required this.reporterRole,
    required this.reason,
    required this.status,
    required this.createdAt,
  });

  factory UserReport.fromJson(Map<String, dynamic> json) {
    return UserReport(
      id: json['id'],
      rideId: json['ride_id'],
      reporterId: json['reporter_id'],
      reportedUserId: json['reported_user_id'],
      reporterRole: json['reporter_role'],
      reason: json['reason'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

final platformProvider =
    AsyncNotifierProvider<PlatformNotifier, PlatformStats?>(
      PlatformNotifier.new,
    );
