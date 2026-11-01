// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

final Set<String> _registeredViews = {};

Widget buildReelVideoView(String videoUrl, {required String viewId}) {
  final effectiveUrl = (videoUrl.isNotEmpty && videoUrl.startsWith('http'))
      ? videoUrl
      : 'https://vjs.zencdn.net/v/oceans.mp4';

  final uniqueId = 'reel-video-$viewId-${effectiveUrl.hashCode.abs()}';

  if (!_registeredViews.contains(uniqueId)) {
    _registeredViews.add(uniqueId);
    ui_web.platformViewRegistry.registerViewFactory(
      uniqueId,
      (int id) {
        final video = html.VideoElement()
          ..src = effectiveUrl
          ..autoplay = true
          ..controls = true
          ..loop = true
          ..muted = true
          ..preload = 'auto'
          ..setAttribute('playsinline', 'true')
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.objectFit = 'contain'
          ..style.backgroundColor = '#000000';

        video.onCanPlay.first.then((_) {
          video.play().catchError((e) {
            html.window.console.warn('Video auto-play deferred until user interaction: $e');
          });
        });

        return video;
      },
    );
  }

  return HtmlElementView(viewType: uniqueId);
}
