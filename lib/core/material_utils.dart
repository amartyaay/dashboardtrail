import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dashboardtrail/screens/settings.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Map<String, dynamic> getMaterialDataFromStoredList(List<String>? storedMaterial, int index) {
  try {
    if (storedMaterial != null && index >= 0 && index < storedMaterial.length) {
      Map<String, dynamic> map = jsonDecode(storedMaterial[index]);
      if (map.isNotEmpty) {
        return map;
      }
    }
  } catch (e) {
    log('Error from get material from stored list: $e');
  }
  return {};
}

File getImgFile(Map map) {
  const imgPath = "media/";
  List<String> imageExtensions = ['jpg', 'jpeg', 'png'];

  File? file;

  try {
    for (var extension in imageExtensions) {
      file = File('$imgPath${map['number']}.$extension');
      if (file.existsSync()) {
        return file;
      }
    }
  } catch (_) {
    // Handle any other exceptions if needed.
  }

  // If none of the image files are found, return the default image.
  return File('$imgPath/default.png');
}

Future<bool> linkBtn(int index, Map map, List<String>? storedList, String number, int rows,
    int columns, BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  final jsonPath = prefs.getString('jsonPath');
  if (jsonPath == null) {
    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const SettingsScreen()),
      );
    }
    return false;
  }
  String jsonContent = File(jsonPath).readAsStringSync();
  final materialListJSON = json.decode(jsonContent);

  final materialList = materialListJSON['materials'];

  if (materialList.containsKey(number)) {
    try {
      storedList![index] = jsonEncode({"number": number});
      final pref = await SharedPreferences.getInstance();
      await pref.setStringList('storedMaterial', storedList);
      log('Link Btn Function -> ${pref.getStringList('storedMaterial')}');
      return true;
    } catch (e) {
      log('Link Btn function -> $e');
    }
  }
  return false;
}
