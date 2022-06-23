import 'dart:typed_data';
import 'signature.service.dart' show SignatureRepository;
import 'package:get/get.dart';

class CustomSignatureController extends GetxController {
  final SignatureRepository _repository = SignatureRepository();

  Future<void> uploadSignature(
      String company, String filename, Uint8List data) async {
    Response res = await _repository.getPresignedUrl(company, filename);
    var response = res.body;
    var uploadUrl = response['uploadURL'];
    print(response['uploadURL']);
    final file = MultipartFile(data, filename: filename);
    final formData = FormData({'file': file});
    await _repository.putSignature(formData, uploadUrl);
  }

  Future<String> getSignature(
    String company,
    String filename,
  ) async {
    return await _repository
        .getPresignedUrl(company, filename)
        .then((response) => response.body['fields']['key']);
  }
}
