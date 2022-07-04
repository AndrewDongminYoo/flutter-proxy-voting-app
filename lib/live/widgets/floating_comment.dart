// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 🌎 Project imports:
import '../firebase.dart';

class FloatingComment extends StatefulWidget {
  const FloatingComment({Key? key}) : super(key: key);

  @override
  State<FloatingComment> createState() => _FloatingCommentState();
}

class _FloatingCommentState extends State<FloatingComment> {
  String message = '라이브 채팅';

  @override
  Widget build(BuildContext context) {
    final Stream<DocumentSnapshot> commentStream =
        liveRef.doc('sm').snapshots();
    commentStream.listen((DocumentSnapshot snapshot) {
      if (snapshot['recentComment'] != message) {
        setState(() {
          message = snapshot['recentComment'];
        });
      }
    });

    return Positioned(
      right: 30,
      bottom: 100,
      child: SizedBox(
        child: DefaultTextStyle(
          style: const TextStyle(
            fontSize: 14.0,
          ),
          child: AnimatedTextKit(
              key: ValueKey<String>(message),
              repeatForever: true,
              animatedTexts: [
                FadeAnimatedText(message),
                FadeAnimatedText(''),
              ]),
        ),
      ),
    );
  }
}
