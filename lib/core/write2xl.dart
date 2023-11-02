// Import the excel package
import 'dart:io';
import 'dart:math';

import 'package:dashboardtrail/core/providers/shared_pref.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Import the path provider package

// Define the function
Future<bool> writeExcel({
  required BuildContext context,
  required String materialNumber,
  required String address,
  required String requestType,
  required String requestTo,
  required WidgetRef ref,
}) async {
  // Get the application directory
  try {
    // var directory = await getApplicationDocumentsDirectory();

    // // // Get the path of the Excel file
    String path = '';

    // path = '${directory.path}/excel_file.xlsx';
    ref.watch(xlPathProviderProvider).whenData(
          (value) => path = value ?? '',
        );
    if (path.isEmpty) throw Exception('Excel File path is Null');
    // Declare a variable to store the Excel document
    Excel excel;

    // Check if the file exists
    if (await File(path).exists()) {
      // Read the existing file
      excel = Excel.decodeBytes(File(path).readAsBytesSync());
    } else {
      // Create a new file
      excel = Excel.createExcel();
    }

    // Get the default sheet
    var sheet = excel['Sheet1'];

    // Check if the sheet is empty
    if (sheet.maxRows == 0) {
      // Write the header row
      sheet.cell(CellIndex.indexByString('A1')).value = 'ID';
      sheet.cell(CellIndex.indexByString('B1')).value = 'Material Number';
      sheet.cell(CellIndex.indexByString('C1')).value = 'Address';
      sheet.cell(CellIndex.indexByString('D1')).value = 'Request Type';
      sheet.cell(CellIndex.indexByString('E1')).value = 'Request To';
    }

    // Generate a unique identifier based on the current date and time
    var id = DateTime.now().millisecondsSinceEpoch.toString();

    // Write the arguments to the next row of the sheet cells
    final maxRow = sheet.maxRows;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: maxRow)).value = id;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: maxRow)).value = materialNumber;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: maxRow)).value = address;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: maxRow)).value = requestType;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: maxRow)).value = requestTo;

    // Save the Excel file
    var bytes = excel.encode();
    if (bytes != null) {
      File(path)
        ..createSync(recursive: true)
        ..writeAsBytes(bytes);
    } else {
      throw Exception('Bytes is null while writing');
    }
    return true;
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
    return false;
  }
  return false;
}
