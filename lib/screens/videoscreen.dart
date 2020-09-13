import 'package:flutter/material.dart';
import '../widgets/twtvideoplayer.dart';

class VideoScreen extends StatelessWidget {
  final String title;

  @required
  final String videoURL;

  const VideoScreen({Key key, this.title, this.videoURL}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title ?? ''),
      ),
      body: Center(
        child: TwtAssetVideo(
          videoURL: videoURL,
          autoPlay: true,
        ),
      ),
    );
  }
}
