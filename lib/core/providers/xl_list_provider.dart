import 'package:dashboardtrail/core/read_excel.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final xlListProvider =
    FutureProvider.family<List<Map<String, dynamic>>?, String>((ref, String path) async {
  final xlList = await readExcelFile(path);
  return xlList;
});
