import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DragDropContainer extends StatelessWidget {
  const DragDropContainer({Key? key, required this.onDrag}) : super(key: key);

  final Function onDrag;

  void getFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      allowedExtensions: [".aes"],
    );
    if (result == null) return;
    List<File> files = result.paths.map((path) => File(path!)).toList();
    onDrag(files);
  }

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = const TextStyle(color: Colors.white, fontSize: 20);

    return GestureDetector(
      onTap: () => getFiles(),
      child: DropTarget(
        onDragDone: (detail) {
          onDrag(detail.files.map((xFile) => File(xFile.path)).toList());
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Drag and Drop", style: textStyle),
              const SizedBox(height: 10),
              Row (
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("or", style: textStyle),
                  const SizedBox(width: 5),
                  SvgPicture.asset("assets/icons/click.svg", color: Colors.white, width: 20),
                  const SizedBox(width: 5),
                  Text("Click", style: textStyle),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                  'to Upload File(s)',
                  style: textStyle
              ),
              const SizedBox(height: 20),
              const Icon(Icons.upload_rounded, color: Colors.white, size: 50)
            ],
          ),
        ),
      ),
    );
  }
}