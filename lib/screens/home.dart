import 'dart:developer';

import 'package:dashboardtrail/core/providers/shared_pref.dart';
import 'package:dashboardtrail/screens/check_requests.dart';
import 'package:dashboardtrail/screens/settings.dart';
import 'package:dashboardtrail/widgets/grid_widget.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameAsyncValue = ref.watch(nameProvider);
    final columnsAsyncValue = ref.watch(columnsProvider);
    final rowsAsyncValue = ref.watch(rowsProvider);

    return nameAsyncValue.when(
      data: (name) {
        return columnsAsyncValue.when(
          data: (columns) {
            return rowsAsyncValue.when(
              data: (rows) {
                return ref.watch(storedMaterialProvider).when(data: (storedMaterial) {
                  log('printing stored material list -> $storedMaterial');
                  if (name != null && name.isNotEmpty) {
                    return Scaffold(
                      appBar: AppBar(
                        centerTitle: true,
                        title: Text(name),
                        actions: <Widget>[
                          IconButton(
                            icon: const Icon(Icons.settings),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => const SettingsScreen()),
                              );
                            },
                          ),
                          Padding(
                              padding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width / 30,
                          )),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const RequestsScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Requests',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                      body: ScrollableGridWidget(columns ?? 5, rows ?? 5, storedMaterial),
                    );
                  } else {
                    // Redirect to the settings page if the name is absent or null.
                    return const SettingsScreen();
                  }
                }, error: (error, stackTrace) {
                  return Center(child: Text(error.toString()));
                }, loading: () {
                  return const Center(child: CircularProgressIndicator());
                });
              },
              loading: () {
                return const Center(child: CircularProgressIndicator());
              },
              error: (error, stackTrace) {
                return Center(child: Text(error.toString()));
              },
            );
          },
          loading: () {
            return const Center(child: CircularProgressIndicator());
          },
          error: (error, stackTrace) {
            return const Center(child: Text('An error occurred'));
          },
        );
      },
      loading: () {
        return const Center(child: CircularProgressIndicator());
      },
      error: (error, stackTrace) {
        return const Center(child: Text('An error occurred'));
      },
    );
  }
}
