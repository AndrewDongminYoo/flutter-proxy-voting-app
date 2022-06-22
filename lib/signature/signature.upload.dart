import 'dart:typed_data';
import 'signature.service.dart' show SignatureRepository;
import 'package:get/get.dart';

class CustomSignatureController extends GetxController {
  final SignatureRepository _repository = SignatureRepository();
  late Uint8List data;

  Future<void> uploadSignature(
      String company, String filename, Uint8List data) async {
    Response res = await _repository.getPresignedUrl(company, filename);
    Map<String, dynamic> response = res.body;
    String presigned = response['url'];
    final form = FormData({
      "File": MultipartFile(data, filename: filename),
      "Key": filename,
      "X-Amz-Algorithm": response['X-Amz-Algorithm'],
      "X-Amz-Credential": response['X-Amz-Credential'],
      "X-Amz-Date": response['X-Amz-Date'],
      "X-Amz-Security-Token": response['X-Amz-Security-Token'],
      "Policy": response['Policy'],
      "X-Amz-Signature": response['X-Amz-Signature'],
    });
    await _repository.putSignature(form, presigned);
  }

  Future<String> getSignature(
    String company,
    String filename,
  ) async {
    return await _repository
        .getPresignedUrl(
      company,
      filename,
    )
        .then((response) {
      return response.body['fields']['key'];
    });
  }
}
