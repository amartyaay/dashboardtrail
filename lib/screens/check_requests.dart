import 'dart:async';

import 'package:dashboardtrail/core/providers/shared_pref.dart';
import 'package:dashboardtrail/core/providers/xl_list_provider.dart';
import 'package:dashboardtrail/core/write2xl.dart';
import 'package:dashboardtrail/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class RequestsScreen extends HookConsumerWidget {
  const RequestsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Timer.periodic(const Duration(minutes: 30), (Timer t) {
      ref.refresh(xlListProvider);
    });
    return ref.watch(xlListProvider).when(
        data: (requests) => ref.watch(nameProvider).when(
            data: (operatorName) => buildScaffold(context, ref, requests ?? [], operatorName ?? ''),
            error: (e, _) => buildError(e, context),
            loading: () => buildLoadingIndicator()),
        error: (e, _) => buildError(e, context),
        loading: () => buildLoadingIndicator());
  }

  // A method that returns a Scaffold widget with an app bar and a body
  Widget buildScaffold(BuildContext context, WidgetRef ref, List<Map<String, dynamic>> requests,
      String operatorName) {
    if (requests.isEmpty) {
      return const SizedBox();
    }
    print(requests);
    return Scaffold(
      appBar: buildAppBar(ref),
      body: buildBody(context, ref, requests, operatorName),
    );
  }

  // A method that returns an AppBar widget with a title
  PreferredSizeWidget buildAppBar(WidgetRef ref) {
    return AppBar(
      centerTitle: true,
      title: const Text('Requests'),
      actions: [
        ElevatedButton(onPressed: () => ref.refresh(xlListProvider), child: const Text('Refresh')),
      ],
    );
  }

  // A method that returns a ListView widget with cards for each request
  Widget buildBody(BuildContext context, WidgetRef ref, List<Map<String, dynamic>> requests,
      String operatorName) {
    return ListView.builder(
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        // Get the data for the current item

        return (request['Production Operator'].toString().toLowerCase() ==
                    operatorName.toString().toLowerCase() &&
                ((request['Status'].toString().toLowerCase() != 'Completed'.toLowerCase() &&
                        request['Status'].toString().toLowerCase() != 'Cancelled'.toLowerCase()) ||
                    DateTime.now()
                            .difference(DateTime.parse(request['Date Generated'].toString())) <
                        const Duration(minutes: 30)))
            ? buildRequestCard(context, ref, request)
            : const SizedBox(
                height: 0,
                width: 0,
              );
      },
    );
  }

  // A method that returns a Card widget for a given request
  Widget buildRequestCard(BuildContext context, WidgetRef ref, Map<String, dynamic> request) {
    // Use a card widget to make each item look more professional
    return Card(
      child: ListTile(
        leading: Icon(
          // Use an icon to indicate the request type
          request['Request Type'].toString().toLowerCase() == 'Normal'.toLowerCase()
              ? Icons.circle_notifications_outlined
              : Icons.warning, // Use a different icon for urgent requests
          color: request['Request Type'].toString().toLowerCase() == 'Normal'.toLowerCase()
              ? Colors.green
              : Colors.red, // Use a different color for urgent requests
        ),
        title: Text(
            'Material Number: ${request['Material Number']}'), // Replace 'Material Number' with your column name
        subtitle: Column(
          // Use a column widget to display more fields
          crossAxisAlignment: CrossAxisAlignment.start, // Align the text to the left
          children: [
            Text(
                'Material Description: ${request['Material Description']}'), // Replace 'Material Description' with your column name
            Text(
                'Request To: ${request['Request To']}'), // Replace 'Request To' with your column name
            Text('Status: ${request['Status']}'), // Replace 'Status' with your column name
            Text(
                'Date Generated: ${request['Date Generated']}'), // Replace 'Date Generated' with your column name
            Text(
                'Bin Address: ${request['Bin Address']}'), // Replace 'Bin Address' with your column name
            Text(
                'Line Address: ${request['Line Address']}'), // Replace 'Line Address' with your column name
          ],
        ),
        trailing: ElevatedButton(
          // Use a button widget to allow the user to cancel the request
          onPressed: () async {
            // Write your logic to cancel the request here
            bool edit = await editExcel(
              context: context,
              id: request['ID'].toString(),
              status: 'Cancelled',
              ref: ref,
            );
            if (edit) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Request Cancelled'),
                  ),
                );
              }
              Timer(const Duration(seconds: 1), () => ref.refresh(xlListProvider));
            }
          },
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  // A method that returns a Center widget with a CircularProgressIndicator widget
  Widget buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  // A method that returns a Center widget with a Text widget showing an error message
  Widget buildError(Object e, BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Column(
        children: [
          Text(e.toString()),
          const SizedBox(
            height: 5,
          ),
          const Text('Several Request Made to Excel file simultaneously'),
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
}
