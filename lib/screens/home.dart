import 'package:dashboardtrail/core/providers/shared_pref.dart';
import 'package:dashboardtrail/screens/settings.dart';
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
                        TextButton(
                          onPressed: () {
                            // Handle Requests button functionality here
                          },
                          child: const Text(
                            'Requests',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    body: ScrollableGridWidget(columns ?? 5, rows ?? 5),
                  );
                } else {
                  // Redirect to the settings page if the name is absent or null.
                  return const SettingsScreen();
                }
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

class ScrollableGridWidget extends StatelessWidget {
  final int columns;
  final int rows;

  const ScrollableGridWidget(this.columns, this.rows, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
        ),
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.all(4),
            color: Colors.blue,
            child: Center(
              child: Text(
                'Item $index',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );
        },
        itemCount: columns * rows,
        shrinkWrap: true, // This allows the GridView to adapt to its content's size
        physics: const ClampingScrollPhysics(), // Optional, prevents over-scrolling
      ),
    );
  }
}
