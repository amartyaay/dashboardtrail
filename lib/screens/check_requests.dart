import 'package:dashboardtrail/core/providers/shared_pref.dart';
import 'package:dashboardtrail/core/providers/xl_list_provider.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class RequestsScreen extends HookConsumerWidget {
  const RequestsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(xlPathProviderProvider).when(
        data: (path) {
          return ref.watch(xlListProvider(path ?? '')).when(
              data: (data) {
                return Scaffold(
                  appBar: AppBar(
                    title: const Text('Requests'),
                  ),
                  // body: ListView.builder(itemBuilder: ),
                );
              },
              error: (e, _) => Center(
                    child: Text(e.toString()),
                  ),
              loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ));
        },
        error: (e, _) => Center(
              child: Text(e.toString()),
            ),
        loading: () => const Center(
              child: CircularProgressIndicator(),
            ));
  }
}
