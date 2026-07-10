import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/storage.dart';
import 'core/theme.dart';
import 'data/api_service.dart';
import 'data/controllers/auth_controller.dart';
import 'data/controllers/orders_controller.dart';
import 'data/controllers/realtime_controller.dart';
import 'environment.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = AppStorage(await SharedPreferences.getInstance());
  final api = ApiService(storage);

  // Register the singletons the whole app shares. permanent: true keeps them
  // alive for the process lifetime (no auto-dispose between routes).
  Get.put<AppStorage>(storage, permanent: true);
  Get.put<ApiService>(api, permanent: true);
  final auth = Get.put<AuthController>(
    AuthController(api, storage),
    permanent: true,
  );
  final orders = Get.put<OrdersController>(
    OrdersController(api),
    permanent: true,
  );
  Get.put<RealtimeController>(
    RealtimeController(storage, orders, auth),
    permanent: true,
  );

  runApp(const RestaurantApp());
}

class RestaurantApp extends StatelessWidget {
  const RestaurantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: Environment.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const SplashScreen(),
    );
  }
}
