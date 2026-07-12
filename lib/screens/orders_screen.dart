import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/format.dart';
import '../core/theme.dart';
import '../data/controllers/auth_controller.dart';
import '../data/controllers/orders_controller.dart';
import '../data/controllers/realtime_controller.dart';
import '../data/models/food_order.dart';
import 'login_screen.dart';
import 'menu_screen.dart';
import 'restaurant_pictures_screen.dart';
import 'order_detail_screen.dart';
import 'order_status_chip.dart';
import '../widgets/in_app_announcement_host.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final _auth = Get.find<AuthController>();
  final _orders = Get.find<OrdersController>();
  final _realtime = Get.find<RealtimeController>();
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _orders.syncOpenFromAuth();
      _orders.refreshOrders();
      _orders.startPolling();
      _realtime.start();
    });
  }

  @override
  void dispose() {
    _scroll
      ..removeListener(_onScroll)
      ..dispose();
    _orders.stopPolling();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 240) {
      _orders.loadMore();
    }
  }

  Future<void> _toggleOpen() async {
    final next = !_orders.isOpen.value;
    final error = await _orders.setOpen(next);
    if (!mounted) return;
    Get.snackbar(
      error == null
          ? (next ? 'Open for orders' : 'Now closed')
          : 'Could not update',
      error ?? (next ? 'Customers can order again.' : 'New orders are paused.'),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: error == null ? AppColors.primary : AppColors.danger,
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
    );
  }

  Future<void> _confirmLogout() async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You will need to sign in again to view orders.'),
        actions: [
          const InAppAnnouncementHost(),
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Log out',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
    if (yes == true) {
      await _realtime.stop();
      await _auth.logout();
      Get.offAll<void>(() => const LoginScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _auth.restaurant.value?.name ?? 'Orders',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Text(
                'Live orders',
                style: TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
        ),
        actions: [
          Obx(() {
            final open = _orders.isOpen.value;
            return GestureDetector(
              onTap: _toggleOpen,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: open ? AppColors.success : Colors.white24,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      open ? Icons.check_circle : Icons.pause_circle_filled,
                      size: 15,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      open ? 'Open' : 'Closed',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          IconButton(
            tooltip: 'Menu',
            icon: const Icon(Icons.restaurant_menu),
            onPressed: () => Get.to<void>(() => const MenuScreen()),
          ),
          IconButton(
            tooltip: 'Restaurant pictures',
            icon: const Icon(Icons.add_photo_alternate_outlined),
            onPressed: () =>
                Get.to<void>(() => const RestaurantPicturesScreen()),
          ),
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () => _orders.refreshOrders(),
          ),
          IconButton(
            tooltip: 'Log out',
            icon: const Icon(Icons.logout),
            onPressed: _confirmLogout,
          ),
        ],
      ),
      body: Obx(() {
        if (_orders.loading.value && _orders.orders.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (_orders.error.value != null && _orders.orders.isEmpty) {
          return _ErrorState(
            message: _orders.error.value!,
            onRetry: () => _orders.refreshOrders(),
          );
        }
        if (_orders.orders.isEmpty) {
          return const _EmptyState();
        }
        return RefreshIndicator(
          onRefresh: () => _orders.refreshOrders(silent: true),
          child: ListView.separated(
            controller: _scroll,
            padding: const EdgeInsets.all(16),
            itemCount: _orders.orders.length + (_orders.hasMore ? 1 : 0),
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              if (i >= _orders.orders.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return _OrderCard(order: _orders.orders[i]);
            },
          ),
        );
      }),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final FoodOrder order;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Get.to<void>(() => OrderDetailScreen(orderId: order.id)),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.reference,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: AppColors.ink,
                          ),
                        ),
                        if (order.isLive &&
                            order.restaurantStatus !=
                                KitchenStatus.rejected) ...[
                          const SizedBox(height: 2),
                          Text(
                            order.kitchenLabel,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  OrderStatusChip(status: order.status),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 16,
                    color: AppColors.muted,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      order.customer?.name ?? 'Customer',
                      style: const TextStyle(color: AppColors.muted),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.receipt_long_outlined,
                    size: 16,
                    color: AppColors.muted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${order.itemCount} item(s)',
                    style: const TextStyle(color: AppColors.muted),
                  ),
                  const Spacer(),
                  Text(
                    money(order.amount),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              if (order.createdAt != null) ...[
                const SizedBox(height: 8),
                Text(
                  prettyDateTime(order.createdAt),
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inbox_outlined, size: 64, color: AppColors.muted),
                  SizedBox(height: 16),
                  Text(
                    'No orders yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'New orders will appear here automatically.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.muted),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 56, color: AppColors.muted),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 160,
              child: ElevatedButton(
                onPressed: onRetry,
                child: const Text('Retry'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
