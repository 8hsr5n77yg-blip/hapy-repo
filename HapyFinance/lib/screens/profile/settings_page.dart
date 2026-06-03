import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../utils/constants.dart';
import '../../utils/csv_exporter.dart';
import 'about_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        children: const [
          SizedBox(height: 16),
          _ExportTile(),
          Divider(height: 1, indent: 56),
          _ClearDataTile(),
          Divider(height: 1, indent: 56),
          _AboutTile(),
        ],
      ),
    );
  }
}

class _ExportTile extends StatelessWidget {
  const _ExportTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Colors.white,
      leading: _IconBox(
        icon: Icons.file_download,
        color: AppColors.primary,
      ),
      title: const Text('导出 CSV',
          style: TextStyle(fontWeight: FontWeight.w500)),
      subtitle: const Text('导出全部账单记录为 CSV 文件',
          style: TextStyle(fontSize: 12, color: AppColors.subtitle)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.subtitle),
      onTap: () async {
        try {
          final api = context.read<AuthProvider>().api;
          await CsvExporter.export(api);
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('导出失败: $e')),
            );
          }
        }
      },
    );
  }
}

class _ClearDataTile extends StatelessWidget {
  const _ClearDataTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Colors.white,
      leading: const _IconBox(icon: Icons.delete_forever, color: Colors.red),
      title: const Text('清除所有数据',
          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.red)),
      subtitle: const Text('删除所有账单记录（账户保留）',
          style: TextStyle(fontSize: 12, color: AppColors.subtitle)),
      onTap: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('确认清除'),
            content: const Text(
                '此操作将删除所有账单记录，但保留账户信息。\n\n此操作不可恢复，确定继续吗？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child:
                    const Text('确认清除', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );

        if (confirmed == true && context.mounted) {
          await context.read<TransactionProvider>().deleteAllTransactions();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('数据已清除')),
            );
          }
        }
      },
    );
  }
}

class _AboutTile extends StatelessWidget {
  const _AboutTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Colors.white,
      leading: _IconBox(
        icon: Icons.info_outline,
        color: AppColors.subtitle,
      ),
      title:
          const Text('关于', style: TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.subtitle),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AboutPage()),
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _IconBox({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}
