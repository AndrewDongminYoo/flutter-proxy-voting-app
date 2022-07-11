// 📦 Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  final bool myself;
  final String message;
  final DateTime time;

  Chat({
    required this.myself,
    required this.message,
    required this.time,
  });

  factory Chat.fromFireStore(
      QueryDocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    return Chat(
      myself: data['myself'],
      message: data['message'],
      time: (data['time'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'myself': myself,
      'message': message,
      'time': time,
    };
  }
}
