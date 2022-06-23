import 'package:flutter/material.dart';

class NoticeButton extends StatelessWidget {
  const NoticeButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.notifications_rounded),
      onPressed: () {
        // TODO: 알림 탭 구현
      },
    );
  }
}
