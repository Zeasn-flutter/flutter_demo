import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class ThumbnailViewer extends StatefulWidget {
  final videoFile;
  final videoDuration;
  final thumbnailHeight;
  final fit;
  final int numberOfThumbnails;
  final int quality;

  Function(double scrollOffse) scrollOffsetBuilder;

  @override
  _ThumbnailViewerState createState() => _ThumbnailViewerState();

  /// For showing the thumbnails generated from the video,
  /// like a frame by frame preview
  ThumbnailViewer({
    @required this.videoFile,
    @required this.videoDuration,
    @required this.thumbnailHeight,
    @required this.numberOfThumbnails,
    @required this.scrollOffsetBuilder,
    @required this.fit,
    this.quality = 75,
  })  : assert(videoFile != null),
        assert(videoDuration != null),
        assert(thumbnailHeight != null),
        assert(numberOfThumbnails != null),
        assert(quality != null);
}

class _ThumbnailViewerState extends State<ThumbnailViewer> {
  ScrollController scrollController = new ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    scrollController.addListener(() {
      print("=========================" + scrollController.offset.toString());
      if (widget.scrollOffsetBuilder != null)
        widget.scrollOffsetBuilder(scrollController.offset);
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return StreamBuilder(
      stream: generateThumbnail(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Uint8List> _imageBytes = snapshot.data;
          return ListView.builder(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                return Container(
                  height: widget.thumbnailHeight,
                  width: widget.thumbnailHeight,
                  child: Image(
                    image: MemoryImage(_imageBytes[index]),
                    fit: widget.fit,
                  ),
                );
              });
        } else {
          return Container(
            color: Colors.yellowAccent,
            height: widget.thumbnailHeight,
            width: double.maxFinite,
          );
        }
      },
    );
  }

  Duration mDuration = const Duration(milliseconds: 450);

  Stream<List<Uint8List>> generateThumbnail() async* {
    final String _videoPath = widget.videoFile.path;

    double _eachPart = widget.videoDuration / widget.numberOfThumbnails;

    List<Uint8List> _byteList = [];

    for (int i = 1; i <= widget.numberOfThumbnails; i++) {
      Uint8List _bytes;
      _bytes = await VideoThumbnail.thumbnailData(
        video: _videoPath,
        imageFormat: ImageFormat.JPEG,
        timeMs: (_eachPart * i).toInt(),
        quality: widget.quality,
      );

      _byteList.add(_bytes);

      yield _byteList;
    }
  }
}
