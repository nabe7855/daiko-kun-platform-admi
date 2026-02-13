import 'package:daiko_kun_platform_admin/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Platform admin app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: PlatformAdminApp()));

    // Verify that the app builds without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
