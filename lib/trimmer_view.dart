import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ap/color.dart';
import 'package:flutter_ap/dimen.dart';
import 'package:flutter_ap/video_editor_widget.dart';
import 'package:flutter_ap/video_trimmer/trim_editor.dart';
import 'package:flutter_ap/video_trimmer/video_trimmer.dart';
import 'package:flutter_ap/video_trimmer/video_viewer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stacked/stacked.dart';

class TrimmerView extends StatefulWidget {
  final Trimmer _trimmer;

  TrimmerView(this._trimmer);

  @override
  _TrimmerViewState createState() => _TrimmerViewState();
}

class _TrimmerViewState extends State<TrimmerView> {
  double _startValue = 0.0;
  double _endValue = 0.0;

  bool _isPlaying = false;
  bool _progressVisibility = false;

  Future<String> _saveVideo() async {
    setState(() {
      _progressVisibility = true;
    });

    String _value;

    await widget._trimmer
        .saveTrimmedVideo(startValue: _startValue, endValue: _endValue)
        .then((value) {
      setState(() {
        _progressVisibility = false;
        _value = value;
      });
    });

    return _value;
  }

  double _videoStartPos = 0;
  double _videoEndPos = 0;

  BaseViewModel baseViewModel = BaseViewModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (context) => Center(
          child: Container(
            padding: EdgeInsets.all(Dimen.w_30),
            color: Colors.blue,
            child: Column(
              children: <Widget>[
                Visibility(
                  visible: _progressVisibility,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.brown,
                  ),
                ),
                RaisedButton(
                  onPressed: _progressVisibility
                      ? null
                      : () async {
                          _saveVideo().then((outputPath) {
                            print('OUTPUT PATH: $outputPath');

                            File file = new File(outputPath);

                            print('OUTPUT PATH === : ' +
                                file.existsSync().toString());

                            final snackBar = SnackBar(
                              content: Text('Video Saved successfully'),
                            );
                            Scaffold.of(context).showSnackBar(snackBar);
                          });
                        },
                  child: Text("SAVE"),
                ),

                ////下面重头戏

                Expanded(
                  child: VideoViewer(),
                ),

                ViewModelBuilder.reactive(
                    builder: (_, __, ___) => Container(
                          padding:
                              EdgeInsets.fromLTRB(Dimen.w_30, 0, Dimen.w_30, 0),
                          alignment: Alignment(1, 0),
                          height: Dimen.h_60,
                          color: Colors.deepPurple,
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Text(
                                Duration(milliseconds: _videoStartPos.toInt())
                                    .toString()
                                    .split('.')[0],
                              ),
                              Text(
                                Duration(milliseconds: _videoEndPos.toInt())
                                    .toString()
                                    .split('.')[0],
                              ),
                            ],
                          ),
                        ),
                    viewModelBuilder: () => baseViewModel),
                Center(
                  child: VideoEditorWidget(
                    ScreenUtil.screenWidth - (Dimen.w_30 * 2),
                    Dimen.h_158,
                    dragWidth: Dimen.w_35,
                    dragInnerColor: Colors.white,
                    dragOutterColor: MyColors.colorIndicatorS,
                    maxEditorMilliSeconds: 15000,
                    onEditorIndexChanged: (start, end) {
                      _videoStartPos = start;
                      _videoEndPos = end;
                      baseViewModel.notifyListeners();
                    },
                  ),
                ),

                ///视频剪切框
//                Center(
//                  child: TrimEditor(
//                    fit: BoxFit.fill,
//                    viewerHeight: Dimen.h_158,
//                    maxVideoLength: Duration(seconds: 15),
//                    onChangeStart: (value) {
//                      _startValue = value;
//                    },
//                    onChangeEnd: (value) {
//                      _endValue = value;
//                    },
//                    onChangePlaybackState: (value) {
//                      setState(() {
//                        _isPlaying = value;
//                      });
//                    },
//                  ),
//                ),

                ///播放
                FlatButton(
                  child: _isPlaying
                      ? Icon(
                          Icons.pause,
                          size: 80.0,
                          color: Colors.white,
                        )
                      : Icon(
                          Icons.play_arrow,
                          size: 80.0,
                          color: Colors.white,
                        ),
                  onPressed: () async {
                    bool playbackState =
                        await widget._trimmer.videPlaybackControl(
                      startValue: _startValue,
                      endValue: _endValue,
                    );
                    setState(() {
                      _isPlaying = playbackState;
                    });
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
