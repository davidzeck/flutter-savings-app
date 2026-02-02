import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:enterprise_flutter_mobile_app/features/auth/login/login_view.dart';
import 'package:enterprise_flutter_mobile_app/features/auth/login/login_viewmodel.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:enterprise_flutter_mobile_app/data/repositories/user_repository.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  testWidgets('Login screen displays email and password fields',
      (WidgetTester tester) async {
    final mockUserRepo = MockUserRepository();
    final viewModel = LoginViewModel(mockUserRepo);

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<LoginViewModel>.value(
          value: viewModel,
          child: const LoginView(),
        ),
      ),
    );

    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('Login'), findsWidgets);
  });
}
