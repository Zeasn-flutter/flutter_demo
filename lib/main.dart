import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ap/trimmer_view.dart';
import 'package:flutter_ap/video_trimmer/video_trimmer.dart';
import 'package:flutter_screenutil/screenutil.dart';

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
    ScreenUtil.init(context, width: 750, height: 1624, allowFontScaling: true);
    return Center(
      child: Container(
        child: RaisedButton(
          child: Text("LOAD VIDEO"),
          onPressed: () async {
            File file = new File(
                "/storage/emulated/0/DCIM/Camera/VID_20200910_191255.mp4");
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
