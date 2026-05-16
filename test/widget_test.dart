// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gravity_ai/main.dart';

void main() {
  testWidgets('Landing page asks for credentials before dashboard',
      (WidgetTester tester) async {
    await tester.pumpWidget(const GravityApp());

    expect(find.byKey(const ValueKey('landing-user-login')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('landing-user-login')));
    await tester.pump(const Duration(milliseconds: 300));

    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byKey(const ValueKey('gravity-login-page')), findsOneWidget);
    expect(find.byKey(const ValueKey('login-user-id')), findsOneWidget);
    expect(find.byKey(const ValueKey('login-password')), findsOneWidget);
  });

  testWidgets('Mobile landing opens responsive login page',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const GravityApp());

    expect(find.byKey(const ValueKey('landing-user-login-mobile')),
        findsOneWidget);

    await tester.pumpWidget(const MaterialApp(home: LoginPage()));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byKey(const ValueKey('gravity-login-page')), findsOneWidget);
    expect(find.byKey(const ValueKey('login-user-id')), findsOneWidget);
    expect(find.byKey(const ValueKey('login-password')), findsOneWidget);
  });
}
