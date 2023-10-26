import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dashboardtrail/core/db/material_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScrollableGridWidget extends HookConsumerWidget {
  final int columns;
  final int rows;
  final List<String>? storedMaterial;

  const ScrollableGridWidget(this.columns, this.rows, this.storedMaterial, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = useState<bool>(false);
    return !isLoading.value
        ? SingleChildScrollView(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
              ),
              itemBuilder: (context, index) {
                Map map = getMaterialDataFromStoredList(storedMaterial, index);
                File imgFile = getImgFile(map);
                return SizedBox(
                  height: MediaQuery.of(context).size.height * 0.01,
                  width: MediaQuery.of(context).size.width * 0.01,
                  child: GridContainer(
                    map: map,
                    imgFile: imgFile,
                    storedMaterial: storedMaterial,
                    rows: rows,
                    columns: columns,
                    index: index,
                  ),
                );
              },
              itemCount: columns * rows,
              shrinkWrap: true, // This allows the GridView to adapt to its content's size
              physics: const ClampingScrollPhysics(), // Optional, prevents over-scrolling
            ),
          )
        : const Center(
            child: CircularProgressIndicator(),
          );
  }
}

class GridContainer extends HookConsumerWidget {
  const GridContainer({
    super.key,
    required this.map,
    required this.imgFile,
    required this.storedMaterial,
    required this.rows,
    required this.columns,
    required this.index,
  });

  final Map map;
  final File imgFile;
  final List<String>? storedMaterial;
  final int rows;
  final int columns;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final numberController = useTextEditingController();
    map.isNotEmpty ? numberController.text = map['number'] : numberController.text = '';
    return Container(
      margin: EdgeInsets.all(MediaQuery.of(context).size.width * 0.01),
      decoration: BoxDecoration(border: Border.all()),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(border: Border.all()),
              child: map.isNotEmpty
                  ? Image.file(imgFile)
                  : const SizedBox(
                      height: 0,
                      width: 0,
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: numberController,
              decoration: const InputDecoration(
                hintText: 'Material Number',
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              bool saveStatus = await linkBtn(
                index,
                map,
                storedMaterial,
                numberController.text,
                rows,
                columns,
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: saveStatus
                        ? const Text('Linked Successfully')
                        : const Text('Please Check Material Number'),
                    backgroundColor: saveStatus ? Colors.teal : Colors.red,
                  ),
                );
              }
            },
            child: Container(
              decoration: BoxDecoration(border: Border.all()),
              child: const Center(
                child: Text('Link'),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {},
                  child: Container(
                    decoration: BoxDecoration(border: Border.all()),
                    child: const Center(
                      child: Text('Request'),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () {},
                  child: Container(
                    decoration: BoxDecoration(border: Border.all()),
                    child: const Center(
                      child: Text('Urgent'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

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
  const imgPath = "d:/media/";
  File? file;
  try {
    file = File('${imgPath + map['number']}.jpg');
    try {
      file = File('${imgPath + map['number']}.jpeg');
      try {
        file = File('${imgPath + map['number']}.png');
      } catch (_) {}
    } catch (_) {}
  } catch (_) {}
  return file ?? (file = File('${imgPath}default.png'));
}

Future<bool> linkBtn(
    int index, Map map, List<String>? storedList, String number, int rows, int columns) async {
  if (materialList.containsKey(number)) {
    try {
      storedList![index] = jsonEncode({"number": number});
      final pref = await SharedPreferences.getInstance();
      await pref.setStringList('storedMaterial', storedList);
      log('Link Btn Function -? ->   ${pref.getStringList('storedMaterial')}');
      return true;
    } catch (e) {
      log('Link Btn function -> $e');
    }
  }
  return false;
}
