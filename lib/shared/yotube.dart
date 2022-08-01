// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

// 🌎 Project imports:
import 'package:bside/lib.dart';

class YoutubeApp extends StatefulWidget {
  const YoutubeApp({Key? key, campaign}) : super(key: key);

  @override
  State<YoutubeApp> createState() => _YoutubeAppState();
}

class _YoutubeAppState extends State<YoutubeApp> {
  final VoteController _voteCtrl = VoteController.get();
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    String youtubeUrl = _voteCtrl.campaign.youtubeUrl;

    _controller = YoutubePlayerController(
      initialVideoId: 'DQR8JgqvjUQ',
      params: YoutubePlayerParams(
        playlist: [youtubeUrl],
        startAt: const Duration(seconds: 30),
        showControls: true,
        showFullscreenButton: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerIFrame(
      controller: _controller,
      aspectRatio: 16 / 9,
    );
  }
}
