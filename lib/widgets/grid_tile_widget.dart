import 'dart:async';

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
    final disbaleRequestButton = useState(false);
    final disbaleUrgentButton = useState(false);
    final numberController = useTextEditingController();
    print('$index $columns $rows');
    final binAddress = String.fromCharCode('A'.codeUnitAt(0) + index ~/ columns) +
        ((index % columns) + 1).toString();
    map.isNotEmpty ? numberController.text = map['number'] : numberController.text = '';
    String materialNumber = numberController.text;
    String materialName = map.isNotEmpty
        ? materialList[map['number']]!['description'] ?? 'Material Name'
        : 'Material Name';
    print(binAddress);
    return ref.watch(storedMaterialProvider).when(
          data: (data) {
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
                            child: ElevatedButton(
                              onPressed: disbaleRequestButton.value
                                  ? null
                                  : () async {
                                      if (numberController.text.isNotEmpty) {
                                        bool writeStatus = await writeExcel(
                                          context: context,
                                          materialNumber: materialNumber,
                                          address: address,
                                          requestType: 'Normal',
                                          requestTo: requestTo(address: address),
                                          ref: ref,
                                        );
                                        if (context.mounted && writeStatus) {
                                          showSnackBar(context, 'Request Sent', Colors.teal);
                                          disbaleRequestButton.value = true;
                                          Timer(const Duration(minutes: 2),
                                              () => disbaleRequestButton.value = false);
                                        }
                                      } else {
                                        showSnackBar(
                                            context,
                                            'Please Link Material Before Making Request',
                                            Colors.red);
                                      }
                                    },
                              child: Text(
                                'Request',
                                softWrap: false,
                                overflow: TextOverflow.fade,
                                maxLines: 1,
                                style: TextStyle(
                                  color: disbaleRequestButton.value ? Colors.grey : null,
                                ),
                              ),
                            ),
                          ),
                          Flexible(
                            child: ElevatedButton(
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
                                              softWrap: false,
                                              overflow: TextOverflow.fade,
                                              maxLines: 1)
                                          : const Text('Please Check Material Number',
                                              softWrap: false,
                                              overflow: TextOverflow.fade,
                                              maxLines: 1),
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
                            ),
                          ),
                          Flexible(
                            child: ElevatedButton(
                              onPressed: () async {
                                if (numberController.text.isNotEmpty) {
                                  bool writeStatus = await writeExcel(
                                    context: context,
                                    materialNumber: materialNumber,
                                    address: address,
                                    requestType: 'Urgent',
                                    requestTo: requestTo(address: address),
                                    ref: ref,
                                  );
                                  if (context.mounted && writeStatus) {
                                    showSnackBar(context, 'Request Sent', Colors.teal);
                                    disbaleRequestButton.value = true;
                                    Timer(const Duration(minutes: 2),
                                        () => disbaleRequestButton.value = false);
                                  }
                                } else {
                                  showSnackBar(context,
                                      'Please Link Material Before Making Request', Colors.red);
                                }
                              },
                              child: const Text(
                                'Urgent',
                                softWrap: false,
                                overflow: TextOverflow.fade,
                                maxLines: 1,
                              ),
                            ),
                          ),
                        ],
                      )),
                ],
              ),
            );
          },
          error: (e, _) => Center(child: Text(e.toString())),
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
        );
  }
}
