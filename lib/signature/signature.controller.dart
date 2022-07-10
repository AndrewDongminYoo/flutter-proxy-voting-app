// 🎯 Dart imports:
import 'dart:typed_data' show Uint8List;

// 📦 Package imports:
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';

class CustomSignController extends GetxController {
  FirebaseStorage storage = FirebaseStorage.instance;

  Future<String> uploadSignature(
      String company, String filename, Uint8List data, String category) async {
    Reference agendaStorage = storage.ref().child(category).child(company);
    Reference storageReference = agendaStorage.child(filename);
    await storageReference.putData(
        data, SettableMetadata(contentType: 'image/jpg'));
    return await storageReference.getDownloadURL();
  }
}