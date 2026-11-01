import 'package:flutter/material.dart';
import 'reel_video_player_stub.dart'
    if (dart.library.html) 'reel_video_player_web.dart';

Widget getReelVideoPlayer(String videoUrl, {required String viewId}) {
  return buildReelVideoView(videoUrl, viewId: viewId);
}

