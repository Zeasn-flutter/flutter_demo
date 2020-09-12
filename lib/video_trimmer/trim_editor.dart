import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ap/dimen.dart';
import 'package:flutter_ap/video_trimmer/thumbnail_viewer.dart';
import 'package:flutter_ap/video_trimmer/trim_editor_painter.dart';
import 'package:flutter_ap/video_trimmer/video_trimmer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stacked/stacked.dart';
import 'package:video_player/video_player.dart';

VideoPlayerController videoPlayerController;

class TrimEditor extends StatefulWidget {
  /// For defining the total trimmer area width
  final double viewerWidth;

  /// For defining the total trimmer area height
  final double viewerHeight;

  /// For defining the image fit type of each thumbnail image.
  ///
  /// By default it is set to `BoxFit.fitHeight`.
  final BoxFit fit;

  /// For defining the maximum length of the output video.
  final Duration maxVideoLength;

  /// For specifying a size to the holder at the
  /// two ends of the video trimmer area, while it is `idle`.
  ///
  /// By default it is set to `5.0`.
  final double circleSize;

  /// For specifying a size to the holder at
  /// the two ends of the video trimmer area, while it is being
  /// `dragged`.
  ///
  /// By default it is set to `8.0`.
  final double circleSizeOnDrag;

  /// For specifying a color to the circle.
  ///
  /// By default it is set to `Colors.white`.
  final Color circlePaintColor;

  /// For specifying a color to the border of
  /// the trim area.
  ///
  /// By default it is set to `Colors.white`.
  final Color borderPaintColor;

  /// For specifying a color to the video
  /// scrubber inside the trim area.
  ///
  /// By default it is set to `Colors.white`.
  final Color scrubberPaintColor;

  /// For specifying the quality of each
  /// generated image thumbnail, to be displayed in the trimmer
  /// area.
  final int thumbnailQuality;

  /// For showing the start and the end point of the
  /// video on top of the trimmer area.
  ///
  /// By default it is set to `true`.
  final bool showDuration;

  /// For providing a `TextStyle` to the
  /// duration text.
  ///
  /// By default it is set to `TextStyle(color: Colors.white)`
  final TextStyle durationTextStyle;

  /// Callback to the video start position
  ///
  /// Returns the selected video start position in `milliseconds`.
  final Function(double startValue) onChangeStart;

  /// Callback to the video end position.
  ///
  /// Returns the selected video end position in `milliseconds`.
  final Function(double endValue) onChangeEnd;

  /// Callback to the video playback
  /// state to know whether it is currently playing or paused.
  ///
  /// Returns a `boolean` value. If `true`, video is currently
  /// playing, otherwise paused.
  final Function(bool isPlaying) onChangePlaybackState;

  /// Widget for displaying the video trimmer.
  ///
  /// This has frame wise preview of the video with a
  /// slider for selecting the part of the video to be
  /// trimmed.
  ///
  /// The required parameters are [viewerWidth] & [viewerHeight]
  ///
  /// * [viewerWidth] to define the total trimmer area width.
  ///
  ///
  /// * [viewerHeight] to define the total trimmer area height.
  ///
  ///
  /// The optional parameters are:
  ///
  /// * [fit] for specifying the image fit type of each thumbnail image.
  /// By default it is set to `BoxFit.fitHeight`.
  ///
  ///
  /// * [maxVideoLength] for specifying the maximum length of the
  /// output video.
  ///
  ///
  /// * [circleSize] for specifying a size to the holder at the
  /// two ends of the video trimmer area, while it is `idle`.
  /// By default it is set to `5.0`.
  ///
  ///
  /// * [circleSizeOnDrag] for specifying a size to the holder at
  /// the two ends of the video trimmer area, while it is being
  /// `dragged`. By default it is set to `8.0`.
  ///
  ///
  /// * [circlePaintColor] for specifying a color to the circle.
  /// By default it is set to `Colors.white`.
  ///
  ///
  /// * [borderPaintColor] for specifying a color to the border of
  /// the trim area. By default it is set to `Colors.white`.
  ///
  ///
  /// * [scrubberPaintColor] for specifying a color to the video
  /// scrubber inside the trim area. By default it is set to
  /// `Colors.white`.
  ///
  ///
  /// * [thumbnailQuality] for specifying the quality of each
  /// generated image thumbnail, to be displayed in the trimmer
  /// area.
  ///
  ///
  /// * [showDuration] for showing the start and the end point of the
  /// video on top of the trimmer area. By default it is set to `true`.
  ///
  ///
  /// * [durationTextStyle] is for providing a `TextStyle` to the
  /// duration text. By default it is set to
  /// `TextStyle(color: Colors.white)`
  ///
  ///
  /// * [onChangeStart] is a callback to the video start position.
  ///
  ///
  /// * [onChangeEnd] is a callback to the video end position.
  ///
  ///
  /// * [onChangePlaybackState] is a callback to the video playback
  /// state to know whether it is currently playing or paused.
  ///
  TrimEditor({
    @required this.viewerHeight,
    this.fit = BoxFit.fitHeight,
    this.maxVideoLength = const Duration(seconds: 15),
    this.circleSize = 5.0,
    this.circleSizeOnDrag = 8.0,
    this.circlePaintColor = Colors.white,
    this.borderPaintColor = Colors.white,
    this.scrubberPaintColor = Colors.white,
    this.thumbnailQuality = 75,
    this.showDuration = true,
    this.durationTextStyle = const TextStyle(
      color: Colors.white,
    ),
    this.onChangeStart,
    this.onChangeEnd,
    this.onChangePlaybackState,
    this.viewerWidth,
  })  : assert(viewerHeight != null),
        assert(fit != null),
        assert(maxVideoLength != null),
        assert(circleSize != null),
        assert(circleSizeOnDrag != null),
        assert(circlePaintColor != null),
        assert(borderPaintColor != null),
        assert(scrubberPaintColor != null),
        assert(thumbnailQuality != null),
        assert(showDuration != null),
        assert(durationTextStyle != null);

  @override
  _TrimEditorState createState() => _TrimEditorState();
}

class _TrimEditorState extends State<TrimEditor> with TickerProviderStateMixin {
  File _videoFile;

  double _videoStartPos = 0.0;
  double _videoEndPos = 0.0;

  bool _canUpdateStart = true;
  bool _isLeftDrag = true;

  Offset _startPos = Offset(0, 0);
  Offset _endPos = Offset(0, 0);

  double _startFraction = 0.0;
  double _endFraction = 1.0;

  int _videoDuration = 0;
  int _currentPosition = 0;

  double _thumbnailViewerScrolloffset = 0;
  double _thumbnailViewerH = 0.0;

  int _numberOfThumbnails = 0;

  double _circleSize;

  double fraction;
  double maxLengthPixels;

  ThumbnailViewer thumbnailWidget;

  Future<void> _initializeVideoController() async {
    if (_videoFile != null) {
      videoPlayerController.addListener(() {
        final bool isPlaying = videoPlayerController.value.isPlaying;

        if (isPlaying) {
          widget.onChangePlaybackState(true);
          setState(() {
            _currentPosition =
                videoPlayerController.value.position.inMilliseconds;

            if (_currentPosition > _videoEndPos.toInt()) {
              widget.onChangePlaybackState(false);
              videoPlayerController.pause();
            }
          });
        } else {
          if (videoPlayerController.value.initialized)
            widget.onChangePlaybackState(false);
        }
      });

      videoPlayerController.setVolume(1.0);
      _videoDuration = videoPlayerController.value.duration.inMilliseconds;
      print(_videoFile.path);

      _videoEndPos = fraction != null
          ? _videoDuration.toDouble() * fraction
          : _videoDuration.toDouble();

      widget.onChangeEnd(_videoEndPos);
    }
  }

  void _setVideoStartPosition(DragUpdateDetails details) async {
    if (!(_startPos.dx + details.delta.dx < 0) &&
        !(_startPos.dx + details.delta.dx > _thumbnailViewerScrolloffset) &&
        !(_startPos.dx + details.delta.dx > _endPos.dx)) {
      if (maxLengthPixels != null) {
        if (!(_endPos.dx - _startPos.dx - details.delta.dx > maxLengthPixels)) {
          setState(() {
            _startPos.dx + details.delta.dx < 0
                ? null
                : _startPos += details.delta;

            _videoStartPos = (scrollOffset + _startPos.dx) / offsetSeconds ;

            widget.onChangeStart(_videoStartPos);
          });
          await videoPlayerController.pause();
          await videoPlayerController
              .seekTo(Duration(milliseconds: _videoStartPos.toInt()));
        }
      } else {
        setState(() {
          _startPos.dx + details.delta.dx < 0
              ? null
              : _startPos += details.delta;

          _videoStartPos = (scrollOffset + _startPos.dx) / offsetSeconds ;

          widget.onChangeStart(_videoStartPos);
        });
        await videoPlayerController.pause();
        await videoPlayerController
            .seekTo(Duration(milliseconds: _videoStartPos.toInt()));
      }
    }
  }

  void _setVideoEndPosition(DragUpdateDetails details) async {
    if (!(_endPos.dx + details.delta.dx > _thumbnailViewerScrolloffset) &&
        !(_endPos.dx + details.delta.dx < 0) &&
        !(_endPos.dx + details.delta.dx < _startPos.dx)) {
      if (maxLengthPixels != null) {
        if (!(_endPos.dx - _startPos.dx + details.delta.dx > maxLengthPixels)) {
          setState(() {
            _endPos += details.delta;
//            _endFraction = _endPos.dx / _thumbnailViewerScrolloffset;
//
//            _videoEndPos = _videoDuration * _endFraction;
            _videoEndPos = (scrollOffset + _endPos.dx) / offsetSeconds;
            widget.onChangeEnd(_videoEndPos);
          });
          await videoPlayerController.pause();
          await videoPlayerController
              .seekTo(Duration(milliseconds: _videoEndPos.toInt()));
        }
      } else {
        setState(() {
          _endPos += details.delta;
//          _endFraction = _endPos.dx / _thumbnailViewerScrolloffset;
//
//          _videoEndPos = _videoDuration * _endFraction;
          _videoEndPos = (scrollOffset + _endPos.dx) / offsetSeconds;
          widget.onChangeEnd(_videoEndPos);
        });
        await videoPlayerController.pause();
        await videoPlayerController
            .seekTo(Duration(milliseconds: _videoEndPos.toInt()));
      }
    }
  }

  ///每一秒所占用的偏移量
  double offsetSeconds;

  @override
  void initState() {
    super.initState();
    _circleSize = widget.circleSize;

    _videoFile = Trimmer.currentVideoFile;

    Duration totalDuration = videoPlayerController.value.duration;

    int milliSecond = totalDuration.inMilliseconds;

    ///计算宽度基准值
    int datumLength = widget.maxVideoLength.inMilliseconds + 5000;

    print('datumLength==' + datumLength.toString());

    if (milliSecond >= datumLength) {
      double widgetWidth = (ScreenUtil.screenWidth - Dimen.w_30 * 2);
      print('widgetWidth==' + widgetWidth.toString());

      ///每秒占用的长度
      offsetSeconds = widgetWidth / datumLength;

      _thumbnailViewerScrolloffset = offsetSeconds * milliSecond;
    } else {
      _thumbnailViewerScrolloffset = (ScreenUtil.screenWidth - Dimen.w_30 * 2);
    }
    print('scrollWidth==' + _thumbnailViewerScrolloffset.toString());

    _thumbnailViewerH = widget.viewerHeight;

    _numberOfThumbnails = _thumbnailViewerScrolloffset ~/ _thumbnailViewerH;

    if (widget.maxVideoLength > Duration(milliseconds: 0) &&
        widget.maxVideoLength < totalDuration) {
      fraction =
          widget.maxVideoLength.inMilliseconds / totalDuration.inMilliseconds;

      maxLengthPixels = _thumbnailViewerScrolloffset * fraction;

      print('fraction==' +
          fraction.toString() +
          " ,maxLengthPixels==" +
          maxLengthPixels.toString());
    }

    if (maxLengthPixels == null) maxLengthPixels = _thumbnailViewerScrolloffset;
    _initializeVideoController();
    _endPos = Offset(
      maxLengthPixels != null ? maxLengthPixels : _thumbnailViewerScrolloffset,
      _thumbnailViewerH,
    );

    thumbnailWidget = ThumbnailViewer(
      videoFile: _videoFile,
      videoDuration: _videoDuration,
      fit: widget.fit,
      thumbnailHeight: _thumbnailViewerH,
      numberOfThumbnails: _numberOfThumbnails,
      quality: widget.thumbnailQuality,
      scrollOffsetBuilder: (offset) {
        scrollOffset=offset;
        _computeOffset();
      },
    );
  }

  double scrollOffset=0;

  _computeOffset() async {
    setState(() {
      _videoStartPos = (scrollOffset + _startPos.dx) / offsetSeconds ;
      _videoEndPos = (scrollOffset + _endPos.dx) / offsetSeconds;

      widget.onChangeStart(_videoStartPos);
      widget.onChangeEnd(_videoEndPos);
    });
    if (videoPlayerController.value.isPlaying)
      await videoPlayerController.pause();
    await videoPlayerController
        .seekTo(Duration(milliseconds: _videoStartPos.toInt()));
  }

  @override
  void dispose() {
    videoPlayerController.pause();
    widget.onChangePlaybackState(false);
    if (_videoFile != null) {
      videoPlayerController.setVolume(0.0);
      videoPlayerController.pause();
      videoPlayerController.dispose();
      widget.onChangePlaybackState(false);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('_strartPos=' +
        _videoStartPos.toString() +
        " ,end==" +
        _videoEndPos.toString());
    return Stack(
      children: [
        Container(
            margin: EdgeInsets.fromLTRB(0, Dimen.h_60, 0, 0),
            color: Colors.yellowAccent,
            height: _thumbnailViewerH,
            width: double.infinity,
            child: thumbnailWidget),
        widget.showDuration
            ? Container(
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
                      style: widget.durationTextStyle,
                    ),
                    Text(
                      Duration(milliseconds: _videoEndPos.toInt())
                          .toString()
                          .split('.')[0],
                      style: widget.durationTextStyle,
                    ),
                  ],
                ),
              )
            : Container(),
        GestureDetector(
            onHorizontalDragStart: (DragStartDetails details) {
              print("START");
              print(details.localPosition);
              print((_startPos.dx - details.localPosition.dx).abs());
              print((_endPos.dx - details.localPosition.dx).abs());

              if (_endPos.dx >= _startPos.dx) {
                if ((_startPos.dx - details.localPosition.dx).abs() >
                    (_endPos.dx - details.localPosition.dx).abs()) {
                  setState(() {
                    _canUpdateStart = false;
                  });
                } else {
                  setState(() {
                    _canUpdateStart = true;
                  });
                }
              } else {
                if (_startPos.dx > details.localPosition.dx) {
                  _isLeftDrag = true;
                } else {
                  _isLeftDrag = false;
                }
              }
            },
            onHorizontalDragEnd: (DragEndDetails details) {
              setState(() {
                _circleSize = widget.circleSize;
              });
            },
            onHorizontalDragUpdate: (DragUpdateDetails details) {
              _circleSize = widget.circleSizeOnDrag;

              if (_endPos.dx >= _startPos.dx) {
                print('left a');
                _isLeftDrag = false;
                if (_canUpdateStart && _startPos.dx + details.delta.dx > 0) {
                  print('left c');
                  _isLeftDrag = false; // To prevent from scrolling over
                  _setVideoStartPosition(details);
                } else if (!_canUpdateStart &&
                    _endPos.dx + details.delta.dx <
                        _thumbnailViewerScrolloffset) {
                  print('left d');
                  _isLeftDrag = true; // To prevent from scrolling over
                  _setVideoEndPosition(details);
                }
              } else {
                print('left b');
                if (_isLeftDrag && _startPos.dx + details.delta.dx > 0) {
                  _setVideoStartPosition(details);
                } else if (!_isLeftDrag &&
                    _endPos.dx + details.delta.dx <
                        _thumbnailViewerScrolloffset) {
                  _setVideoEndPosition(details);
                }
              }
            },
            child: Container(
                margin: EdgeInsets.fromLTRB(0, Dimen.h_60, 0, 0),
                height: _thumbnailViewerH,
                child: Stack(
                  children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(_startPos.dx, 0, 0, 0),
                      color: Colors.greenAccent,
                      width: Dimen.w_35,
                      height: _thumbnailViewerH,
                      alignment: Alignment(0, 0),
                      child: Container(
                          width: Dimen.w_4,
                          height: Dimen.w_64,
                          color: Colors.white),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(_endPos.dx, 0, 0, 0),
                      color: Colors.greenAccent,
                      width: Dimen.w_35,
                      height: _thumbnailViewerH,
                      alignment: Alignment(0, 0),
                      child: Container(
                          width: Dimen.w_4,
                          height: Dimen.w_64,
                          color: Colors.white),
                    ),
                    Container(
                        margin: EdgeInsets.fromLTRB(_startPos.dx, 0, 0, 0),
                        color: Colors.greenAccent,
                        width: (_endPos.dx - _startPos.dx),
                        height: Dimen.h_6),
                    Container(
                        margin: EdgeInsets.fromLTRB(
                            _startPos.dx, _thumbnailViewerH - Dimen.h_6, 0, 0),
                        color: Colors.greenAccent,
                        width: (_endPos.dx - _startPos.dx),
                        height: Dimen.h_6),
                  ],
                )))
      ],
    );
  }

  double strokeWidth = 16;
}
