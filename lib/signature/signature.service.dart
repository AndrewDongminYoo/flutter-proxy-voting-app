import 'package:get/get_connect.dart';

class SignatureRepository extends GetConnect {
  String lambdaURL =
      "https://bbbbbbbb.execute-api.ap-northeast-2.amazonaws.com/api";
  String s3URL = "https://bbbbbbbbbbbbbbbbbbbbbbbbb.s3.amazonaws.com/";

  Future<Response> getPresignedUrl(String company, String filename) {
    return get('$lambdaURL/$company/$filename');
  }

  Future<Response> putSignature(FormData formData) async {
    return post(s3URL, formData);
  }
}
