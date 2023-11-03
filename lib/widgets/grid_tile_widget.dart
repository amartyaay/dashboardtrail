import 'dart:async';

import 'package:dashboardtrail/core/providers/xl_list_provider.dart';
import 'package:dashboardtrail/widgets/get_details_from_Addres.dart';
import 'package:dashboardtrail/widgets/snackbar_widget.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:dashboardtrail/core/db/material_list.dart';
import 'package:dashboardtrail/core/material_utils.dart';
import 'package:dashboardtrail/core/providers/shared_pref.dart';
import 'package:dashboardtrail/core/write2xl.dart';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class GridTileWidget extends HookConsumerWidget {
  const GridTileWidget({
    super.key,
    required this.map,
    required this.imgFile,
    required this.storedMaterial,
    required this.index,
    required this.rows,
    required this.columns,
    required this.address,
  });

  final Map map;
  final File imgFile;
  final List<String>? storedMaterial;
  final int index;
  final int rows;
  final int columns;
  final String address;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(storedMaterialProvider).when(
        data: (data) =>
            buildCard(context, ref, data ?? []), // Use a method to build the card widget
        error: (e, _) => buildError(e), // Use a method to build the error widget
        loading: () =>
            buildLoadingIndicator()); // Use a method to build the loading indicator widget
  }

  // A method that returns a Card widget with an image, a text field, and some buttons
  Widget buildCard(BuildContext context, WidgetRef ref, List<String> data) {
    // Use state hooks to manage the button states
    final disbaleRequestButton = useState(false);
    final disbaleUrgentButton = useState(false);

    // Use a text editing controller hook to manage the text field input
    final numberController = useTextEditingController();

    // Use some variables to store the relevant data for the current item
    final binAddress = String.fromCharCode('A'.codeUnitAt(0) + index ~/ columns) +
        ((index % columns) + 1).toString();
    map.isNotEmpty ? numberController.text = map['number'] : numberController.text = '';
    String materialNumber = numberController.text;
    String materialName = map.isNotEmpty
        ? materialList[map['number']]!['description'] ?? 'Material Name'
        : 'Material Name';

    // Return early if there is no data
    if (data.isEmpty) {
      return const SizedBox();
    }

    print(data);

    // Use the original layout for larger screens
    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Stack(
              alignment: AlignmentDirectional.topStart,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    image: map.isNotEmpty
                        ? DecorationImage(
                            image: FileImage(imgFile),
                            fit: BoxFit.cover,
                          )
                        : const DecorationImage(
                            image: AssetImage('assets/default1.jpg'),
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                Text(
                  binAddress,
                  style: TextStyle(backgroundColor: Colors.teal.shade100),
                ),
                Positioned(
                  bottom: 0,
                  child: Text(
                    materialName,
                    style: TextStyle(
                      backgroundColor: Colors.teal.shade100,
                      overflow: TextOverflow.fade,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
              child: TextField(
                controller: numberController,
                decoration: const InputDecoration(
                  hintText: 'Material Number',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ),
          Padding(
              padding: const EdgeInsets.all(4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Flexible(
                    child: buildRequestButton(
                        context,
                        ref,
                        disbaleRequestButton,
                        materialNumber,
                        binAddress,
                        'Request'), // Call the method with 'Request' as the request type
                  ),
                  Flexible(
                    child: buildLinkButton(
                        context, ref, numberController), // Use a method to build the link button
                  ),
                  Flexible(
                    child: buildRequestButton(context, ref, disbaleUrgentButton, materialNumber,
                        binAddress, 'Urgent'), // Call the method with 'Urgent' as the request type
                  ),
                ],
              )),
        ],
      ),
    );
  }

  // A method that returns an ElevatedButton widget for requesting a material
  Widget buildRequestButton(BuildContext context, WidgetRef ref, ValueNotifier<bool> buttonState,
      String materialNumber, String binAddress, String requestType) {
    return ElevatedButton(
      onPressed: buttonState.value
          ? null
          : () async {
              if (materialNumber.isNotEmpty) {
                bool writeStatus = await writeExcel(
                  context: context,
                  materialNumber: materialNumber,
                  address: address,
                  requestType: requestType, // Pass the request type as a parameter
                  requestTo: requestTo(address: address),
                  ref: ref,
                  binAddress: binAddress,
                );
                if (context.mounted && writeStatus) {
                  showSnackBar(context, 'Request Sent', Colors.teal);
                  buttonState.value = true;
                  Timer(const Duration(minutes: 2), () => buttonState.value = false);
                  Timer(const Duration(milliseconds: 10), () => ref.refresh(xlListProvider));
                }
              } else {
                showSnackBar(context, 'Please Link Material Before Making Request', Colors.red);
              }
            },
      child: Text(
        requestType, // Use the request type as the button text
        softWrap: false,
        overflow: TextOverflow.fade,
        maxLines: 1,
        style: TextStyle(
          color: buttonState.value ? Colors.grey : null,
        ),
      ),
    );
  }

  // A method that returns an ElevatedButton widget for linking a material
  Widget buildLinkButton(
      BuildContext context, WidgetRef ref, TextEditingController numberController) {
    return ElevatedButton(
      onPressed: () async {
        bool saveStatus = await linkBtn(
          index,
          map,
          storedMaterial,
          numberController.text,
          rows,
          columns,
        );
        if (saveStatus) ref.refresh(storedMaterialProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: saveStatus
                  ? const Text('Linked Successfully',
                      softWrap: false, overflow: TextOverflow.fade, maxLines: 1)
                  : const Text('Please Check Material Number',
                      softWrap: false, overflow: TextOverflow.fade, maxLines: 1),
              backgroundColor: saveStatus ? Colors.teal : Colors.red,
            ),
          );
        }
      },
      child: const Text(
        'Link',
        softWrap: false,
        overflow: TextOverflow.fade,
        maxLines: 1,
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
  Widget buildError(Object e) {
    return Center(
      child: Text(e.toString()),
    );
  }
}
