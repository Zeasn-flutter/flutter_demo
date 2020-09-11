import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ap/BottomSheetWidget.dart';
import 'package:flutter_ap/HomeViewModel.dart';
import 'package:flutter_ap/trimmer_view.dart';
import 'package:flutter_ap/video_trimmer/video_trimmer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stacked/stacked.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        cursorColor: Colors.brown, // Add the 3 lines from here...
        primaryColor: Colors.orange,
      ),
      title: 'Flutter Demo',
      home: HomeTrimmerPage(),
    );
  }
}

class HomeTrimmerPage extends StatelessWidget {
  final Trimmer _trimmer = Trimmer();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        child: RaisedButton(
          child: Text("LOAD VIDEO"),
          onPressed: () async {
//            File file = await ImagePicker.pickVideo(
//              source: ImageSource.gallery,
//            );
//            print("file.path ===" + file.path);
//            File file = new File(
//                "/data/user/0/com.example.flutter_ap/cache/image_picker3631397302260407409.jpg");
//            File file = new File(
//                "/data/user/0/com.example.flutter_ap/cache/image_picker2546732214910810454.jpg");
            File file = new File(
                "/storage/emulated/0/DCIM/Camera/VID_20200908_190316.mp4");
            if (file != null) {
              await _trimmer.loadVideo(videoFile: file);
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return TrimmerView(_trimmer);
              }));
            }
          },
        ),
      ),
    );
  }
}
