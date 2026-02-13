import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class AdminState {
  final String id;
  final String name;
  final String role;

  AdminState({required this.id, required this.name, required this.role});
}

class AuthNotifier extends Notifier<AdminState?> {
  @override
  AdminState? build() {
    return null; // 初期は未ログイン
  }

  Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/admin/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['role'] != 'super_admin') return false; // スーパー管理者以外は拒否

        state = AdminState(
          id: data['id'],
          name: data['name'],
          role: data['role'],
        );
        return true;
      }
    } catch (e) {
      print('Login error: $e');
    }
    return false;
  }

  void logout() {
    state = null;
  }
}

final authProvider = NotifierProvider<AuthNotifier, AdminState?>(
  AuthNotifier.new,
);
