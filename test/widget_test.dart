import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hive_restaurant/core/storage.dart';
import 'package:hive_restaurant/core/theme.dart';
import 'package:hive_restaurant/data/api_service.dart';
import 'package:hive_restaurant/data/controllers/auth_controller.dart';
import 'package:hive_restaurant/screens/login_screen.dart';

void main() {
  testWidgets('Login screen renders the sign-in form', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final storage = AppStorage.forTesting(
      await SharedPreferences.getInstance(),
    );
    final api = ApiService(storage);
    Get.put<AppStorage>(storage);
    Get.put<ApiService>(api);
    Get.put<AuthController>(AuthController(api, storage));

    await tester.pumpWidget(
      GetMaterialApp(theme: AppTheme.light, home: const LoginScreen()),
    );

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);

    await Get.deleteAll(force: true);
  });
}
