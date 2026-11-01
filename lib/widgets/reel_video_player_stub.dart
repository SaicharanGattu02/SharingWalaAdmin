import 'package:flutter/material.dart';

Widget buildReelVideoView(String videoUrl, {required String viewId}) {
  return Container(
    color: Colors.black,
    child: const Center(
      child: Text(
        'Video playback is enabled on Web',
        style: TextStyle(color: Colors.white70),
      ),
    ),
  );
}

