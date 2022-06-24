import 'dart:convert';

import 'package:get/get.dart';

class VoteService extends GetConnect {
  String baseURL = "https://api.bside.ai/onboarding";

  String getURL(String url) => baseURL + url;

  Future<Response> findSharesByName(String company, String name) {
    return get(getURL('/shareholders'),
        query: {'company': company, 'name': name});
  }

  Future<Response> validateShareholder(int id) {
    return put(getURL('/shareholders/$id'), jsonEncode({}));
  }
}
