import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import '../services/api_service.dart';

class CsvExporter {
  static Future<void> export(ApiService api) async {
    final result = await api.get('/transactions/export');
    final rows = (result as List)
        .map((j) => j as Map<String, dynamic>)
        .toList();

    final buffer = StringBuffer();
    buffer.writeln('类型,金额,分类,日期,时间,账户,备注');

    for (final row in rows) {
      final type = row['type'] == 'expense' ? '支出' : '收入';
      final amount = (row['amount'] as num).toDouble().toStringAsFixed(2);
      final category = row['category_name'] ?? '';
      final date = row['date'] ?? '';
      final time = row['time'] ?? '';
      final account = row['account_name'] ?? '';
      final note = row['note'] ?? '';

      final escapedNote = note.toString().contains(',') ? '"$note"' : note;
      buffer.writeln('$type,$amount,$category,$date,$time,$account,$escapedNote');
    }

    final now = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final fileName = '记账导出_$now.csv';

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsString(buffer.toString());
    await Share.shareXFiles([XFile(file.path)], subject: fileName);
  }
}
