import 'dart:typed_data';
// firebase storage
import 'package:firebase_storage/firebase_storage.dart';
//// amazon s3 & lambda execute
// import 'signature.connect.dart' show SignatureRepository;
import 'package:get/get.dart';

FirebaseStorage storage = FirebaseStorage.instance;
Reference signatureStorage = storage.ref().child('signature');

class CustomSignatureController extends GetxController {
  // final SignatureRepository _repository = SignatureRepository();
  late Uint8List data;

  Future<void> uploadSignature(
      String company, String filename, Uint8List data) async {
    // var response = await _repository.getPresignedUrl(company, filename);
    // final form = FormData({
    //   "file": MultipartFile(data, filename: filename),
    //   "key": response.body['fields']['key'],
    //   "x-amz-algorithm": response.body['fields']['x-amz-algorithm'],
    //   "x-amz-credential": response.body['fields']['x-amz-credential'],
    //   "x-amz-date": response.body['fields']['x-amz-date'],
    //   "x-amz-security-token": response.body['fields']['x-amz-security-token'],
    //   "policy": response.body['fields']['policy'],
    //   "x-amz-signature": response.body['fields']['x-amz-signature'],
    // });
    // await _repository.putSignature(form);
    Reference storageReference = signatureStorage.child("$filename.png");
    UploadTask uploadTask = storageReference.putData(
        data, SettableMetadata(contentType: 'image/jpeg'));
    await uploadTask.whenComplete(() => null);
  }

  Future<String> getSignature(String company, String filename) async {
    Reference storageReference = signatureStorage.child("$filename.png");
    return await storageReference.getDownloadURL();
  }
}
