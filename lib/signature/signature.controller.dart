// 🎯 Dart imports:
import 'dart:typed_data' show Uint8List;

// 📦 Package imports:
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get/state_manager.dart' show Get;
import 'package:get/instance_manager.dart' show Get;

class SignController extends GetxController {
  static SignController get() => Get.isRegistered<SignController>()
      ? Get.find<SignController>()
      : Get.put(SignController());

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
