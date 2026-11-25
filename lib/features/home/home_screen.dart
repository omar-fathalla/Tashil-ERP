import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/providers.dart';

/// Placeholder dashboard until the POS and goods-receipt screens land (step 3).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lowStock = ref.watch(lowStockProvider);
    final pending = ref.watch(pendingSyncCountProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('تسهيل ERP')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.cloud_upload_outlined),
              title: const Text('عمليات في انتظار المزامنة'),
              trailing: Text(
                pending.when(
                  data: (n) => '$n',
                  loading: () => '…',
                  error: (_, _) => '!',
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'أصناف وصلت للحد الأدنى',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          ...lowStock.when(
            data: (items) => items.isEmpty
                ? [const ListTile(title: Text('لا يوجد'))]
                : [
                    for (final p in items)
                      ListTile(
                        title: Text(p.nameAr ?? p.name),
                        subtitle: Text('الحد الأدنى: ${p.minStock}'),
                        trailing: Text('${p.currentStock} ${p.unit}'),
                      ),
                  ],
            loading: () => [const LinearProgressIndicator()],
            error: (e, _) => [Text('$e')],
          ),
        ],
      ),
    );
  }
}
