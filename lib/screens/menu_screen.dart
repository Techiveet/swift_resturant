import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../core/format.dart';
import '../core/theme.dart';
import '../data/api_service.dart';
import '../data/controllers/menu_controller.dart';
import '../data/models/menu_item.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final menu = Get.put(RestaurantMenuController(Get.find<ApiService>()));

    return Scaffold(
      appBar: AppBar(title: const Text('Menu')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context, menu),
        icon: const Icon(Icons.add),
        label: const Text('Add item'),
      ),
      body: Obx(() {
        if (menu.loading.value && menu.items.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (menu.error.value != null && menu.items.isEmpty) {
          return _centered(
            Icons.cloud_off,
            menu.error.value!,
            action: ElevatedButton(
              onPressed: menu.load,
              child: const Text('Retry'),
            ),
          );
        }
        if (menu.items.isEmpty) {
          return _centered(
            Icons.restaurant_menu,
            'No menu items yet.\nTap "Add item" to create your first one.',
          );
        }
        return RefreshIndicator(
          onRefresh: () => menu.load(silent: true),
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: menu.items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _MenuTile(
              item: menu.items[i],
              onEdit: () => _openForm(context, menu, item: menu.items[i]),
              onToggle: () => _run(menu.toggle(menu.items[i].id)),
              onDelete: () => _confirmDelete(context, menu, menu.items[i]),
            ),
          ),
        );
      }),
    );
  }

  Future<void> _openForm(
    BuildContext context,
    RestaurantMenuController menu, {
    FoodMenuItem? item,
  }) async {
    final nameC = TextEditingController(text: item?.name ?? '');
    final priceC = TextEditingController(
      text: item != null ? item.price.toStringAsFixed(2) : '',
    );
    final descC = TextEditingController(text: item?.description ?? '');
    final arC = TextEditingController(text: item?.arModelUrl ?? '');
    final arIosC = TextEditingController(text: item?.arIosModelUrl ?? '');
    XFile? selectedImage;
    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setFormState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  item == null ? 'Add menu item' : 'Edit item',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final source = await showModalBottomSheet<ImageSource>(
                      context: ctx,
                      builder: (_) => SafeArea(
                        child: Wrap(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.photo_camera),
                              title: const Text('Take food photo'),
                              onTap: () =>
                                  Navigator.pop(ctx, ImageSource.camera),
                            ),
                            ListTile(
                              leading: const Icon(Icons.photo_library),
                              title: const Text('Choose from gallery'),
                              onTap: () =>
                                  Navigator.pop(ctx, ImageSource.gallery),
                            ),
                          ],
                        ),
                      ),
                    );
                    if (source != null) {
                      final picked = await ImagePicker().pickImage(
                        source: source,
                        imageQuality: 85,
                        maxWidth: 1600,
                      );
                      if (picked != null) {
                        setFormState(() => selectedImage = picked);
                      }
                    }
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: AppColors.scaffold,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: selectedImage != null
                        ? Image.file(
                            File(selectedImage!.path),
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : item?.imageUrl != null
                        ? Image.network(
                            item!.imageUrl!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add_a_photo_outlined, size: 36),
                                SizedBox(height: 8),
                                Text('Add a food photo'),
                              ],
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: nameC,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: priceC,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Price'),
                  validator: (v) {
                    final p = double.tryParse((v ?? '').trim());
                    return (p == null || p <= 0) ? 'Enter a valid price' : null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descC,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                  ),
                ),
                const SizedBox(height: 12),
                ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: const Text('Augmented reality (optional)'),
                  subtitle: const Text('Add restaurant-hosted 3D model links'),
                  children: [
                    TextFormField(
                      controller: arC,
                      keyboardType: TextInputType.url,
                      decoration: const InputDecoration(
                        labelText: 'Android GLB/GLTF model URL',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: arIosC,
                      keyboardType: TextInputType.url,
                      decoration: const InputDecoration(
                        labelText: 'iPhone USDZ model URL',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Obx(
                  () => SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: menu.saving.value
                          ? null
                          : () async {
                              if (!formKey.currentState!.validate()) return;
                              final error = await menu.save(
                                id: item?.id,
                                name: nameC.text.trim(),
                                description: descC.text.trim(),
                                price: double.parse(priceC.text.trim()),
                                image: selectedImage,
                                arModelUrl: arC.text.trim(),
                                arIosModelUrl: arIosC.text.trim(),
                              );
                              if (ctx.mounted && error == null) {
                                Navigator.pop(ctx);
                              }
                              _toast(
                                error ??
                                    (item == null
                                        ? 'Item added'
                                        : 'Item updated'),
                                error == null,
                              );
                            },
                      child: menu.saving.value
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                valueColor: AlwaysStoppedAnimation(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(item == null ? 'Add Item' : 'Save Changes'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    RestaurantMenuController menu,
    FoodMenuItem item,
  ) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete item?'),
        content: Text('Remove "${item.name}" from your menu?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
    if (yes == true) _run(menu.remove(item.id));
  }

  Future<void> _run(Future<String?> future) async {
    final error = await future;
    _toast(error ?? 'Done', error == null);
  }

  void _toast(String message, bool ok) {
    Get.snackbar(
      ok ? 'Done' : 'Something went wrong',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: ok ? AppColors.primary : AppColors.danger,
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
    );
  }

  Widget _centered(IconData icon, String text, {Widget? action}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 60, color: AppColors.muted),
            const SizedBox(height: 16),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted),
            ),
            if (action != null) ...[const SizedBox(height: 20), action],
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.item,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  final FoodMenuItem item;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: item.imageUrl != null
                ? Image.network(
                    item.imageUrl!,
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _placeholder(),
                  )
                : _placeholder(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Opacity(
                  opacity: item.available ? 1 : 0.5,
                  child: Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  money(item.price),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.available ? 'Available' : 'Sold out',
                  style: TextStyle(
                    fontSize: 12,
                    color: item.available
                        ? AppColors.success
                        : AppColors.danger,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'edit') onEdit();
              if (v == 'toggle') onToggle();
              if (v == 'delete') onDelete();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(
                value: 'toggle',
                child: Text(
                  item.available ? 'Mark sold out' : 'Mark available',
                ),
              ),
              const PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(
    width: 52,
    height: 52,
    color: AppColors.scaffold,
    child: const Icon(Icons.fastfood_outlined, color: AppColors.muted),
  );
}
