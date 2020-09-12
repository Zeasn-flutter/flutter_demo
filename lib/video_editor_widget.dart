import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_ap/video_trimmer/trim_editor.dart';
import 'package:flutter_ap/video_trimmer/video_trimmer.dart';
import 'package:stacked/stacked.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import 'dimen.dart';

//VideoPlayerController videoPlayerController;

class VideoEditorWidget extends StatefulWidget {
  ///整个控件的宽度
  double width;

  ///整个控件高度
  double height;

  ///拖动的宽度
  double dragWidth;

  ///视频最大的剪辑长度
  int maxEditorMilliSeconds;

  ///内层颜色
  Color dragInnerColor;

  ///外层颜色
  Color dragOutterColor;

  ///剪辑区域变化回调
  Function(double videoStartIndex, double videoEndIndex) onEditorIndexChanged;

  Function(bool isPlay) onChangePlaybackState;

  VideoEditorWidget(this.width, this.height,
      {@required this.maxEditorMilliSeconds: 15000,
      this.dragWidth: 17,
      this.dragInnerColor: Colors.white,
      this.dragOutterColor: Colors.greenAccent,
      this.onEditorIndexChanged,
      this.onChangePlaybackState});

  @override
  State createState() => _VideoEditorState();
}

class _VideoEditorState extends State<VideoEditorWidget> {
  ///剪辑视频的总长度
  int _totalMilliSecond;

  ///每一秒所占用的偏移量
  double _offsetSeconds;

  ///缩略图长廊的总偏移量
  double _thumbGalleryScrolloffset = 0;

  ///缩略图的高度
  double _thumbHeight;

  ///生成缩略图的数量
  int _numberOfThumbnails;

  ///剪辑框可滑动最大距离比例换算
  double fraction;

  ///剪辑框可滑动最大距离
  double maxEditLengthPixels;

  ///当然播放位置
  int _currentVideoIndex = 0;

  ///当前剪辑框的头部index
  double _videoStartIndex = 0.0;

  ///当前剪辑框的尾部index
  double _videoEndIndex = 0.0;

  ///剪辑框左侧移动的偏移量
  Offset _startIndexOffset = Offset(0, 0);

  ///剪辑框右侧移动的偏移量
  Offset _endIndeOffset = Offset(0, 0);

  ///缩略图滚动controller
  ScrollController _scrollController = new ScrollController();

  ///当然缩略图偏移量
  double scrollOffset = 0;

  bool _isLeftDrag = true;
  bool _canUpdateStart = true;

  ///用来刷新拖动区域
  BaseViewModel editorViewModel = BaseViewModel();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (videoPlayerController == null) {
      throw UnimplementedError("videoPlayerController 还未被初始化");
    }

    ///获取剪辑视频的总长度
    _totalMilliSecond = videoPlayerController.value.duration.inMilliseconds;

    ///计算宽度基准值 5秒为多余出来的偏移量
    int datumLength = widget.maxEditorMilliSeconds + 5000;

    if (_totalMilliSecond >= datumLength) {
      _offsetSeconds = widget.width / datumLength;
      _thumbGalleryScrolloffset = _offsetSeconds * _totalMilliSecond;
    } else
      _thumbGalleryScrolloffset = widget.width;
    print('_thumbGalleryScrolloffset==' + _thumbGalleryScrolloffset.toString());
    _thumbHeight = widget.height;

    _numberOfThumbnails = _thumbGalleryScrolloffset ~/ _thumbHeight;

    ///计算当前可剪辑框的最大宽度
    if (widget.maxEditorMilliSeconds > 0 &&
        widget.maxEditorMilliSeconds < _totalMilliSecond) {
      fraction = widget.maxEditorMilliSeconds / _totalMilliSecond;
      maxEditLengthPixels = _thumbGalleryScrolloffset * fraction;
    }
    if (maxEditLengthPixels == null)
      maxEditLengthPixels = _thumbGalleryScrolloffset;

    ///videoEditorPlayerController回调监听添加
    videoPlayerController.addListener(() {
      final bool isPlaying = videoPlayerController.value.isPlaying;
      if (isPlaying) {
        _onChangePlaybackState(true);
        _currentVideoIndex =
            videoPlayerController.value.position.inMilliseconds;
        if (_currentVideoIndex > _videoEndIndex.toInt()) {
          _onChangePlaybackState(false);
          videoPlayerController.pause();
        }
      } else {
        if (videoPlayerController.value.initialized)
          _onChangePlaybackState(false);
      }
    });
    videoPlayerController.setVolume(1.0);
    _videoEndIndex = fraction != null
        ? _totalMilliSecond.toDouble() * fraction
        : _totalMilliSecond.toDouble();

    _onChangeEditorIndex(0, _videoEndIndex);

    _endIndeOffset = Offset(
      maxEditLengthPixels,
      _thumbHeight,
    );

    ///滚动回调
    _scrollController.addListener(() {
      scrollOffset = _scrollController.offset;
      _computeOffset();
    });
  }

  ///偏移量逻辑处理
  _computeOffset() async {
    _videoStartIndex = (scrollOffset + _startIndexOffset.dx) / _offsetSeconds;
    _videoEndIndex = (scrollOffset + _endIndeOffset.dx) / _offsetSeconds;
    _onChangeEditorIndex(_videoStartIndex, _videoEndIndex);
    if (videoPlayerController.value.isPlaying)
      await videoPlayerController.pause();
    await videoPlayerController
        .seekTo(Duration(milliseconds: _videoStartIndex.toInt()));
  }

  @override
  void dispose() {
    videoPlayerController.pause();
    _onChangePlaybackState(false);
    if (Trimmer.currentVideoFile != null) {
      videoPlayerController.setVolume(0.0);
      videoPlayerController.pause();
      videoPlayerController.dispose();
      _onChangePlaybackState(false);
    }
    super.dispose();
  }

  ///回调视频状态
  _onChangePlaybackState(bool isPlaying) {
    if (widget.onChangePlaybackState != null)
      widget.onChangePlaybackState(isPlaying);
  }

  ///回调当前区域
  _onChangeEditorIndex(double startIndex, double endIndex) {
    if (widget.onEditorIndexChanged != null)
      widget.onEditorIndexChanged(startIndex, endIndex);
  }

  ///获取缩略图数组
  Stream<List<Uint8List>> generateThumbnail() async* {
    final String _videoPath = Trimmer.currentVideoFile.path;
    double _eachPart = _totalMilliSecond / _numberOfThumbnails;
    List<Uint8List> _byteList = [];
    for (int i = 1; i <= _numberOfThumbnails; i++) {
      Uint8List _bytes;
      _bytes = await VideoThumbnail.thumbnailData(
        video: _videoPath,
        imageFormat: ImageFormat.JPEG,
        timeMs: (_eachPart * i).toInt(),
        quality: 75,
      );
      _byteList.add(_bytes);
      yield _byteList;
    }
  }

  void _setVideoStartPosition(DragUpdateDetails details) async {
    if (!(_startIndexOffset.dx + details.delta.dx < 0) &&
        !(_startIndexOffset.dx + details.delta.dx >
            _thumbGalleryScrolloffset) &&
        !(_startIndexOffset.dx + details.delta.dx > _endIndeOffset.dx)) {
      if (maxEditLengthPixels != null) {
        if (!(_endIndeOffset.dx - _startIndexOffset.dx - details.delta.dx >
            maxEditLengthPixels)) {
          _startIndexOffset.dx + details.delta.dx < 0
              ? null
              : _startIndexOffset += details.delta;
          _videoStartIndex =
              (scrollOffset + _startIndexOffset.dx) / _offsetSeconds;

          _onChangeEditorIndex(_videoStartIndex, _videoEndIndex);
          editorViewModel.notifyListeners();

          await videoPlayerController.pause();
          await videoPlayerController
              .seekTo(Duration(milliseconds: _videoStartIndex.toInt()));
        }
      } else {
        _startIndexOffset.dx + details.delta.dx < 0
            ? null
            : _startIndexOffset += details.delta;

        _videoStartIndex =
            (scrollOffset + _startIndexOffset.dx) / _offsetSeconds;

        _onChangeEditorIndex(_videoStartIndex, _videoEndIndex);
        editorViewModel.notifyListeners();

        await videoPlayerController.pause();
        await videoPlayerController
            .seekTo(Duration(milliseconds: _videoStartIndex.toInt()));
      }
    }
  }

  void _setVideoEndPosition(DragUpdateDetails details) async {
    if (!(_endIndeOffset.dx + details.delta.dx > _thumbGalleryScrolloffset) &&
        !(_endIndeOffset.dx + details.delta.dx < 0) &&
        !(_endIndeOffset.dx + details.delta.dx < _startIndexOffset.dx)) {
      if (maxEditLengthPixels != null) {
        if (!(_endIndeOffset.dx - _startIndexOffset.dx + details.delta.dx >
            maxEditLengthPixels)) {
          _endIndeOffset += details.delta;
          _videoEndIndex = (scrollOffset + _endIndeOffset.dx) / _offsetSeconds;
          _onChangeEditorIndex(_videoStartIndex, _videoEndIndex);
          editorViewModel.notifyListeners();
          await videoPlayerController.pause();
          await videoPlayerController
              .seekTo(Duration(milliseconds: _videoEndIndex.toInt()));
        }
      } else {
        _endIndeOffset += details.delta;
        _videoEndIndex = (scrollOffset + _endIndeOffset.dx) / _offsetSeconds;
        _onChangeEditorIndex(_videoStartIndex, _videoEndIndex);
        editorViewModel.notifyListeners();
        await videoPlayerController.pause();
        await videoPlayerController
            .seekTo(Duration(milliseconds: _videoEndIndex.toInt()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    if (videoPlayerController == null || Trimmer.currentVideoFile == null)
      return SizedBox();
    return Stack(
      children: [
        Container(
            height: _thumbHeight,
            width: double.infinity,
            child: StreamBuilder(
              stream: generateThumbnail(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<Uint8List> _imageBytes = snapshot.data;
                  return ListView.builder(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, index) {
                        return Container(
                          height: _thumbHeight,
                          width: _thumbHeight,
                          child: Image(
                            image: MemoryImage(_imageBytes[index]),
                            fit: BoxFit.cover,
                          ),
                        );
                      });
                } else {
                  return SizedBox();
                }
              },
            )),
        ViewModelBuilder.reactive(
            builder: (_, __, ___) => GestureDetector(
                onHorizontalDragStart: (DragStartDetails details) {
                  print("START");
                  print(details.localPosition);
                  print(
                      (_startIndexOffset.dx - details.localPosition.dx).abs());
                  print((_endIndeOffset.dx - details.localPosition.dx).abs());

                  if (_endIndeOffset.dx >= _startIndexOffset.dx) {
                    if ((_startIndexOffset.dx - details.localPosition.dx)
                            .abs() >
                        (_endIndeOffset.dx - details.localPosition.dx).abs()) {
                      _canUpdateStart = false;
                      editorViewModel.notifyListeners();
                    } else {
                      _canUpdateStart = true;
                      editorViewModel.notifyListeners();
                    }
                  } else {
                    if (_startIndexOffset.dx > details.localPosition.dx) {
                      _isLeftDrag = true;
                    } else {
                      _isLeftDrag = false;
                    }
                  }
                },
                onHorizontalDragUpdate: (DragUpdateDetails details) {
                  if (_endIndeOffset.dx >= _startIndexOffset.dx) {
                    print('left a');
                    _isLeftDrag = false;
                    if (_canUpdateStart &&
                        _startIndexOffset.dx + details.delta.dx > 0) {
                      print('left c');
                      _isLeftDrag = false; // To prevent from scrolling over
                      _setVideoStartPosition(details);
                    } else if (!_canUpdateStart &&
                        _endIndeOffset.dx + details.delta.dx <
                            _thumbGalleryScrolloffset) {
                      print('left d');
                      _isLeftDrag = true; // To prevent from scrolling over
                      _setVideoEndPosition(details);
                    }
                  } else {
                    print('left b');
                    if (_isLeftDrag &&
                        _startIndexOffset.dx + details.delta.dx > 0) {
                      _setVideoStartPosition(details);
                    } else if (!_isLeftDrag &&
                        _endIndeOffset.dx + details.delta.dx <
                            _thumbGalleryScrolloffset) {
                      _setVideoEndPosition(details);
                    }
                  }
                },
                child: Container(
                    height: _thumbHeight,
                    child: Stack(
                      children: [
                        Container(
                          margin: EdgeInsets.fromLTRB(
                              _startIndexOffset.dx, 0, 0, 0),
                          color: widget.dragOutterColor,
                          width: widget.dragWidth,
                          height: _thumbHeight,
                          alignment: Alignment(0, 0),
                          child: Container(
                              width: Dimen.w_4,
                              height: Dimen.w_64,
                              color: widget.dragInnerColor),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(
                              _endIndeOffset.dx - widget.dragWidth < 0
                                  ? 0
                                  : _endIndeOffset.dx - widget.dragWidth,
                              0,
                              0,
                              0),
                          color: widget.dragOutterColor,
                          width: widget.dragWidth,
                          height: _thumbHeight,
                          alignment: Alignment(0, 0),
                          child: Container(
                              width: Dimen.w_4,
                              height: Dimen.w_64,
                              color: widget.dragInnerColor),
                        ),
                        Container(
                            margin: EdgeInsets.fromLTRB(
                                _startIndexOffset.dx, 0, 0, 0),
                            color: widget.dragOutterColor,
                            width: (_endIndeOffset.dx - _startIndexOffset.dx),
                            height: Dimen.h_6),
                        Container(
                            margin: EdgeInsets.fromLTRB(_startIndexOffset.dx,
                                _thumbHeight - Dimen.h_6, 0, 0),
                            color: widget.dragOutterColor,
                            width: (_endIndeOffset.dx - _startIndexOffset.dx),
                            height: Dimen.h_6),
                      ],
                    ))),
            viewModelBuilder: () => editorViewModel)
      ],
    );
  }
}
