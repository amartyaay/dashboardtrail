import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends HookConsumerWidget {
  const SettingsScreen({Key? key}) : super(key: key); // Fixed the super constructor

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = useTextEditingController();
    final columnsController = useTextEditingController();
    final rowsController = useTextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          customRow(nameController, 'Name', Icons.person),
          customRow(columnsController, 'Columns', Icons.view_column),
          customRow(rowsController, 'Rows', Icons.view_list),
          ElevatedButton(
            onPressed: () {
              final errors = saveSettingsToSharedPreferences(
                nameController.text,
                columnsController.text,
                rowsController.text,
              );

              if (errors.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Settings Saved'),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(errors.join('\n')),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

Widget customRow(TextEditingController controller, String hintText, IconData icon) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    child: Row(
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(width: 16.0),
        Text(
          hintText,
          style: const TextStyle(fontSize: 16, color: Colors.black),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hintText,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

List<String> saveSettingsToSharedPreferences(String name, String columns, String rows) {
  final errors = <String>[];

  // Validate and save Name
  if (name.trim().isEmpty) {
    errors.add('Name cannot be empty');
  } else {
    saveToSharedPreferences('name', name, 'String');
  }

  // Validate and save Columns
  if (int.tryParse(columns) != null) {
    saveToSharedPreferences('columns', int.parse(columns), 'int');
  } else {
    errors.add('Columns must be a valid integer');
  }

  // Validate and save Rows
  if (int.tryParse(rows) != null) {
    saveToSharedPreferences('rows', int.parse(rows), 'int');
  } else {
    errors.add('Rows must be a valid integer');
  }

  return errors;
}

Future<void> saveToSharedPreferences(String variableName, dynamic value, String valueType) async {
  final prefs = await SharedPreferences.getInstance();
  switch (valueType) {
    case 'bool':
      await prefs.setBool(variableName, value);
      break;
    case 'int':
      await prefs.setInt(variableName, value);
      break;
    case 'double':
      await prefs.setDouble(variableName, value);
      break;
    case 'String':
      await prefs.setString(variableName, value);
      break;
    case 'StringList':
      await prefs.setStringList(variableName, value);
      break;
    default:
      throw Exception('Invalid value type');
  }
}
