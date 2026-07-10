import 'package:get/get.dart';

import '../../core/urls.dart';
import '../api_service.dart';
import '../models/menu_item.dart';

/// Loads and mutates the restaurant's own menu (scoped server-side to the
/// authenticated restaurant). Photos are managed on the web portal; the app
/// handles name/price/description and the sold-out toggle.
class RestaurantMenuController extends GetxController {
  RestaurantMenuController(this._api);

  final ApiService _api;

  final RxList<FoodMenuItem> items = <FoodMenuItem>[].obs;
  final RxBool loading = false.obs;
  final RxBool saving = false.obs;
  final RxnString error = RxnString();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load({bool silent = false}) async {
    if (!silent) loading.value = true;
    error.value = null;
    try {
      final res = await _api.get(Urls.menu);
      if (!res.success) {
        if (!silent) {
          error.value = res.firstMessage.isNotEmpty ? res.firstMessage : 'Could not load your menu.';
        }
        return;
      }
      final paginator = res.data['items'];
      final rows = (paginator is Map ? paginator['data'] : null) as List? ?? const [];
      items.assignAll(
        rows.whereType<Map>().map((e) => FoodMenuItem.fromJson(e.cast<String, dynamic>())),
      );
    } finally {
      if (!silent) loading.value = false;
    }
  }

  Future<String?> save({
    int? id,
    required String name,
    String? description,
    required double price,
  }) async {
    saving.value = true;
    try {
      final url = id == null ? Urls.menuStore : '${Urls.menuUpdate}$id';
      final res = await _api.post(url, {
        'name': name,
        'description': description ?? '',
        'price': price,
      }, auth: true);
      if (res.success) {
        await load(silent: true);
        return null;
      }
      return res.firstMessage.isNotEmpty ? res.firstMessage : 'Could not save the item.';
    } finally {
      saving.value = false;
    }
  }

  Future<String?> toggle(int id) async {
    final res = await _api.post('${Urls.menuToggle}$id', {}, auth: true);
    if (res.success) {
      await load(silent: true);
      return null;
    }
    return res.firstMessage.isNotEmpty ? res.firstMessage : 'Could not update availability.';
  }

  Future<String?> remove(int id) async {
    final res = await _api.post('${Urls.menuDelete}$id', {}, auth: true);
    if (res.success) {
      await load(silent: true);
      return null;
    }
    return res.firstMessage.isNotEmpty ? res.firstMessage : 'Could not delete the item.';
  }
}
