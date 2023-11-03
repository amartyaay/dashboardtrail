import 'package:dashboardtrail/core/read_excel.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final xlListProvider = FutureProvider<List<Map<String, dynamic>>?>((ref) async {
  final xlList = await readExcelFile();
  return xlList;
});
