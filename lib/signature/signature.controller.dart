// 🎯 Dart imports:
import 'dart:typed_data' show Uint8List;

// 📦 Package imports:
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/state_manager.dart';
import 'package:get/instance_manager.dart';

class CustomSignController extends GetxController {
  static CustomSignController get() => Get.isRegistered<CustomSignController>()
      ? Get.find<CustomSignController>()
      : Get.put(CustomSignController());

  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadSignature(
      String company, String filename, Uint8List data, String category) async {
    Reference agendaStorage = _storage.ref().child(category).child(company);
    Reference storageReference = agendaStorage.child(filename);
    await storageReference.putData(
        data, SettableMetadata(contentType: 'image/jpg'));
    return await storageReference.getDownloadURL();
  }
}
