import 'package:flutter/material.dart';

class Chat {
  final String avatar;
  final bool myself;
  final String message;
  final String time;

  Chat({
    required this.avatar,
    required this.myself,
    required this.message,
    required this.time,
  });
}
