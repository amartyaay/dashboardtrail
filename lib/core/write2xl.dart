// Import the excel package
import 'dart:io';
import 'package:dashboardtrail/core/db/material_list.dart';
import 'package:dashboardtrail/widgets/get_details_from_Addres.dart';
import 'package:dashboardtrail/widgets/snackbar_widget.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import the path provider package

// Define the function
Future<bool> writeExcel({
  required BuildContext context,
  required String materialNumber,
  required String address,
  required String requestType,
  required String requestTo,
  required WidgetRef ref,
  required String binAddress,
}) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('xlPath');
    if (path == null || path.isEmpty) throw Exception('Excel File path is Null');
    // Declare a variable to store the Excel document
    print(path);
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
      sheet.cell(CellIndex.indexByString('C1')).value = 'Material Description';
      sheet.cell(CellIndex.indexByString('D1')).value = 'Production Operator';
      sheet.cell(CellIndex.indexByString('E1')).value = 'Request Type';
      sheet.cell(CellIndex.indexByString('F1')).value = 'Request To';
      sheet.cell(CellIndex.indexByString('G1')).value = 'Status';
      sheet.cell(CellIndex.indexByString('H1')).value = 'Date Generated';
      sheet.cell(CellIndex.indexByString('I1')).value = 'Date Acknoledged';
      sheet.cell(CellIndex.indexByString('J1')).value = 'Date Completed';
      sheet.cell(CellIndex.indexByString('K1')).value = 'Bin Address';
      sheet.cell(CellIndex.indexByString('L1')).value = 'Line Address';
    }

    // Generate a unique identifier based on the current date and time
    var id = DateTime.now().millisecondsSinceEpoch.toString();

    // Write the arguments to the next row of the sheet cells
    final maxRow = sheet.maxRows;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: maxRow)).value = id;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: maxRow)).value = materialNumber;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: maxRow)).value =
        materialList[materialNumber]?['description'];
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: maxRow)).value = address;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: maxRow)).value = requestType;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: maxRow)).value = requestTo;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: maxRow)).value =
        'Not Acknowledged';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: maxRow)).value =
        DateTime.now().toString();
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: maxRow)).value = -1;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: maxRow)).value = -1;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: maxRow)).value = binAddress;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 11, rowIndex: maxRow)).value =
        getLineAddress(address: address);

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
      showSnackBar(context, e.toString(), Colors.red);
    }
    return false;
  }
}

// Define the function
Future<bool> editExcel({
  required BuildContext context,
  required String id,
  required String status,
  required WidgetRef ref,
}) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('xlPath');
    print(path);

    if (path == null || path.isEmpty) throw Exception('Excel File path is Null');
    // Declare a variable to store the Excel document
    Excel excel;

    // Check if the file exists
    if (await File(path).exists()) {
      // Read the existing file
      excel = Excel.decodeBytes(File(path).readAsBytesSync());
    } else {
      // Throw an exception if the file does not exist
      throw Exception('Excel File does not exist');
    }

    // Get the default sheet
    var sheet = excel['Sheet1'];

    // Check if the sheet is empty
    if (sheet.maxRows == 0) {
      // Throw an exception if the sheet is empty
      throw Exception('Excel Sheet is empty');
    }

    // Find the row index that matches the id argument
    var rowIndex = -1;
    for (var i = 0; i < sheet.maxRows; i++) {
      if (sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i)).value.toString() ==
          id.toString()) {
        rowIndex = i;
        break;
      }
    }

    // Check if the row index is valid
    if (rowIndex == -1) {
      // Throw an exception if the id is not found
      throw Exception('ID not found in Excel Sheet');
    }

    // Edit the status column of the row with the new status argument
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex)).value =
        status.toString();

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
    print(e.toString());
    if (context.mounted) showSnackBar(context, e.toString(), Colors.red);
    return false;
  }
}
