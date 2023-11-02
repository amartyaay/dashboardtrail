import 'dart:io';

import 'package:excel/excel.dart';

Future<List<Map<String, dynamic>>?> readExcelFile(String path) async {
  // Open the Excel file from the specified path
  final file = File(path);

  if (!file.existsSync()) {
    return null; // File doesn't exist
  }

  final bytes = file.readAsBytesSync();
  final excel = Excel.decodeBytes(bytes);

  if (excel.tables.isEmpty) {
    return null; // No tables in the Excel file
  }

  final sheet = excel.tables[excel.tables.keys.first]!; // Use the first sheet

  final titleRow = sheet.rows[0]; // Assume the first row contains titles

  final data = <Map<String, dynamic>>[];

  for (var i = 1; i < sheet.maxRows; i++) {
    final row = sheet.rows[i];
    final rowData = <String, dynamic>{};

    for (var j = 0; j < titleRow.length; j++) {
      // Ensure that both the title and value in the row are not null
      if (titleRow[j] != null && row[j] != null) {
        rowData[titleRow[j]!.value.toString()] = row[j]!.value;
      }
    }

    data.add(rowData);
  }

  return data;
}
