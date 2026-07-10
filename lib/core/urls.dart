import '../environment.dart';

/// Restaurant API endpoints (all under the `restaurant/` prefix on the
/// backend — see routes/api.php).
class Urls {
  static const String baseUrl = '${Environment.domainUrl}/api/';

  static const String login = 'restaurant/login';
  static const String register = 'restaurant/register';
  static const String orders = 'restaurant/orders';
  static const String orderDetails = 'restaurant/orders/details/'; // + {id}
  static const String acceptOrder = 'restaurant/orders/accept/'; // + {id}
  static const String readyOrder = 'restaurant/orders/ready/'; // + {id}
  static const String rejectOrder = 'restaurant/orders/reject/'; // + {id}
  static const String setOpen = 'restaurant/set-open';
  static const String menu = 'restaurant/menu';
  static const String menuStore = 'restaurant/menu/store';
  static const String menuUpdate = 'restaurant/menu/update/'; // + {id}
  static const String menuDelete = 'restaurant/menu/delete/'; // + {id}
  static const String menuToggle = 'restaurant/menu/toggle/'; // + {id}
  static const String saveDeviceToken = 'restaurant/save-device-token';
  static const String pusherAuth = 'restaurant/pusher/auth/'; // + {socketId}/{channel}
  static const String logout = 'restaurant/logout';
}
