import 'dart:io';
import 'package:dashboardtrail/core/material_utils.dart';
import 'package:dashboardtrail/widgets/grid_tile_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ScrollableGridWidget extends HookConsumerWidget {
  final int columns;
  final int rows;
  final List<String>? storedMaterial;
  final String address;

  const ScrollableGridWidget(this.address, this.columns, this.rows, this.storedMaterial, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = useState<bool>(false);

    return !isLoading.value
        ? SingleChildScrollView(
            child: GridView.builder(
              gridDelegate: columns <= 3
                  ? const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 256)
                  : SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                    ),
              itemBuilder: (context, index) {
                Map map = getMaterialDataFromStoredList(storedMaterial, index);
                File imgFile = getImgFile(map);
                return GridTileWidget(
                  map: map,
                  imgFile: imgFile,
                  storedMaterial: storedMaterial,
                  index: index,
                  rows: rows,
                  columns: columns,
                  address: address,
                );
              },
              itemCount: columns * rows,
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
            ),
          )
        : const Center(
            child: CircularProgressIndicator(),
          );
  }
}
