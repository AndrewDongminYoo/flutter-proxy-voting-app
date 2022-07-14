// 🎯 Dart imports:
import 'dart:convert' show jsonEncode;

// 📦 Package imports:
import 'package:get/get.dart' show GetConnect, Response;

class VoteService extends GetConnect {
  final String _baseURL = 'https://api.bside.ai/onboarding';

  String _getURL(String url) => _baseURL + url;

  Future<Response> queryAgenda(int uid, String company) {
    return get(_getURL('/agenda?uid=$uid&company=$company'));
  }

  Future<Response> findSharesByName(String company, String name) {
    return get(_getURL('/shareholders'),
        query: {'company': company, 'name': name});
  }

  Future<Response> validateShareholder(int id) {
    return put(_getURL('/shareholders/$id'), jsonEncode({}));
  }

  Future<Response> postResult(
    int uid,
    int shareholderId,
    String deviceName,
    int agenda1,
    int agenda2,
    int agenda3,
    int agenda4,
  ) {
    return post(
      _getURL('/agenda/vote'),
      jsonEncode(
        {
          'uid': uid,
          'agenda': {
            'company': 'tli',
            'shareholderId': shareholderId,
            'deviceName': deviceName,
            'agenda1': agenda1,
            'agenda2': agenda2,
            'agenda3': agenda3,
            'agenda4': agenda4,
            'agenda5': 0,
            'agenda6': 0,
            'agenda7': 0,
            'agenda8': 0,
            'agenda9': 0,
            'agenda10': 0
          }
        },
      ),
    );
  }

  Future<Response> postSignature(int agendaId, String signature) {
    return put(_getURL('/agenda/signature'),
        jsonEncode({'agendaId': agendaId, 'signature': signature}));
  }

  Future<Response> postIdCard(int agendaId, String idCard) {
    return put(_getURL('/agenda/idcard'),
        jsonEncode({'agendaId': agendaId, 'idCard': idCard}));
  }

  Future<Response> postTakeBackNumberAt(int agendaId, String takeBackNumberAt) {
    return put(
        _getURL('/agenda/idcard'),
        jsonEncode(
            {'agendaId': agendaId, 'takeBackNumberAt': takeBackNumberAt}));
  }
}
