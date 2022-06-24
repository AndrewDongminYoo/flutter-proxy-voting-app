import 'package:get/get_connect.dart';

class SignatureRepository extends GetConnect {
  String lambdaURL =
      "https://4znb391us4.execute-api.ap-northeast-2.amazonaws.com/default/signature";

  Future<Response> getPresignedUrl(String company, String filename) {
    final query = {
      'company': company,
      'filename': filename,
    };
    return get(lambdaURL, query: query);
  }

  Future<Response> putSignature(FormData formData, String presignedUrl) async {
    return await put(presignedUrl, formData,
        contentType: "multipart/form-data");
  }

  Future<Response> postSignature(MultipartFile file) async {
    String presignedUrl =
        "https://bside-korea-private.s3.ap-northeast-2.amazonaws.com/";
    return await put(presignedUrl, file, contentType: "multipart/form-data");
  }
}
