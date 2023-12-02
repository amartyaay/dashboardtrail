// ignore_for_file: unused_result

import 'package:dashboardtrail/core/providers/shared_pref.dart';
import 'package:dashboardtrail/screens/home.dart';
import 'package:dashboardtrail/widgets/settings_page_rows.dart';
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
    final pathController = useTextEditingController();
    final jsonController = useTextEditingController();
    final nameAsyncValue = ref.watch(nameProvider);
    final columnsAsyncValue = ref.watch(columnsProvider);
    final rowsAsyncValue = ref.watch(rowsProvider);
    final pathAsyncvalue = ref.watch(xlPathProviderProvider);
    final jsonPathAsyncValue = ref.watch(jsonPathProvider);
    return nameAsyncValue.when(
        data: (name) {
          return columnsAsyncValue.when(
              data: (columns) {
                return rowsAsyncValue.when(
                    data: (rows) {
                      return pathAsyncvalue.when(
                          data: (path) {
                            return jsonPathAsyncValue.when(
                              data: (jsonPath) {
                                return Scaffold(
                                  appBar: AppBar(
                                    title: const Text('Settings'),
                                    centerTitle: true,
                                  ),
                                  body: Column(
                                    children: [
                                      customRow(
                                        controller: nameController,
                                        hintText: 'Name',
                                        icon: Icons.person,
                                        intialValue: name,
                                      ),
                                      customRow(
                                        controller: columnsController,
                                        hintText: 'Columns',
                                        icon: Icons.view_column,
                                        intialValue: columns.toString(),
                                      ),
                                      customRow(
                                        controller: rowsController,
                                        hintText: 'Rows',
                                        icon: Icons.view_list,
                                        intialValue: rows.toString(),
                                      ),
                                      customRow(
                                        controller: pathController,
                                        hintText: 'Excel File Path',
                                        icon: Icons.file_open,
                                        intialValue: path,
                                      ),
                                      customRow(
                                          controller: jsonController,
                                          hintText: 'Enter path for JSON Material File',
                                          icon: Icons.file_present,
                                          intialValue: jsonPath),
                                      ElevatedButton(
                                        onPressed: () async {
                                          final errors = await saveSettingsToSharedPreferences(
                                            nameController.text,
                                            columnsController.text,
                                            rowsController.text,
                                            pathController.text,
                                            jsonController.text,
                                          );
                                          if (errors.isEmpty) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Settings Saved'),
                                                ),
                                              );
                                            }
                                            ref.refresh(nameProvider);
                                            ref.refresh(columnsProvider);
                                            ref.refresh(rowsProvider);
                                            ref.refresh(storedMaterialProvider);
                                            if (context.mounted) {
                                              Navigator.of(context).pop();
                                            }
                                          } else {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(errors.join('\n')),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          }
                                        },
                                        child: const Text('Save'),
                                      ),
                                      const SizedBox(height: 10),
                                      ElevatedButton(
                                          onPressed: () async {
                                            final prefs = await SharedPreferences.getInstance();
                                            prefs.clear();
                                            ref.refresh(nameProvider);
                                            ref.refresh(xlPathProviderProvider);
                                            ref.refresh(columnsProvider);
                                            ref.refresh(rowsProvider);
                                            ref.refresh(storedMaterialProvider);
                                          },
                                          child: const Text('Delete all settings')),
                                    ],
                                  ),
                                );
                              },
                              error: (error, stackTrace) => buildError(error, context),
                              loading: () => const Center(child: CircularProgressIndicator()),
                            );
                          },
                          error: (e, _) => Center(
                                child: Text(e.toString()),
                              ),
                          loading: () => const Center(
                                child: CircularProgressIndicator(),
                              ));
                    },
                    error: (error, stackTrace) => Center(
                          child: Text(error.toString()),
                        ),
                    loading: () {
                      return const Center(child: CircularProgressIndicator());
                    });
              },
              error: (error, stackTrace) => Center(
                    child: Text(error.toString()),
                  ),
              loading: () {
                return const Center(child: CircularProgressIndicator());
              });
        },
        error: (error, stackTrace) => Center(
              child: Text(error.toString()),
            ),
        loading: () {
          return const Center(child: CircularProgressIndicator());
        });
  }
}

Future<List<String>> saveSettingsToSharedPreferences(
  String name,
  String columns,
  String rows,
  String path,
  String jsonPath,
) async {
  final errors = <String>[];

  // Validate and save Name
  if (name.trim().isEmpty) {
    errors.add('Name cannot be empty');
  } else {
    saveToSharedPreferences('name', name, 'String');
  }
  if (path.trim().isEmpty) {
    errors.add('Path cannot be empty');
  } else {
    saveToSharedPreferences('xlPath', path, 'String');
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
  if (jsonPath.trim().isNotEmpty) {
    saveToSharedPreferences('jsonPath', jsonPath, 'String');
  } else {
    errors.add('JSON Path is not valid');
  }
  if (errors.isEmpty) {
    final pref = await SharedPreferences.getInstance();
    List<String> dummy = List.filled(int.parse(rows) * int.parse(columns), '{}');
    await pref.setStringList('storedMaterial', dummy);
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

Widget buildError(Object e, BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('Error')),
    body: Column(
      children: [
        Text(e.toString()),
        const SizedBox(height: 5),
        const Text('Several Request Made to Excel file Simultanously'),
        const SizedBox(height: 5),
        IconButton(
            onPressed: () {
              Navigator.of(context)
                  .pushReplacement(MaterialPageRoute(builder: (context) => const HomePage()));
            },
            icon: const Icon(Icons.home_filled))
      ],
    ),
  );
}
