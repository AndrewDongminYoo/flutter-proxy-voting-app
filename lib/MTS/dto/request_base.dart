// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import '../../utils/channel.dart';

class CustomResponse {
  CustomResponse({
    required this.Module,
    required this.Job,
    required this.Class,
    required this.Input,
    required this.Output,
    required this.API_SEQ,
  });

  late String Module;
  late String Class;
  late String Job;
  late dynamic Input;
  late dynamic Output;
  late String API_SEQ;

  CustomResponse.fromJson(Map<String, dynamic> json) {
    Module = json['Module'];
    Class = json['Class'];
    Job = json['Job'];
    Input = json['Input'];
    Output = json['OutPut'];
    API_SEQ = json['API_SEQ'];
  }

  Map<String, dynamic> get data => {
        'Module': Module,
        'Job': Job,
        'Class': Class,
        'Input': Input,
        'OutPut': Output,
        'API_SEQ': API_SEQ,
      };
}

class CustomRequest {
  CustomRequest({
    required this.Module,
    required this.Job,
    this.Class = '증권서비스',
    required this.Input,
  }) : super();

  final String Module;
  final String Class;
  final String Job;
  final dynamic Input;

  dynamic get data => {
        'Module': Module,
        'Job': Job,
        'Class': Class,
        'Input': Input,
      };

  Future<CustomResponse> fetch() async {
    print('===========$Module ${Job.padLeft(6, ' ')}===========');
    var response = await channel.invokeMethod('getMTSData', {'data': data});
    return jsonDecode(response);
  }
}

// class CustomResult {
//   String 사용자아이디;
//   List<StockAccount> 증권보유계좌조회;
//   List<AllAccount> 전계좌조회;
//   List<DetailAccount> 계좌상세조회;
//   List<AllTransaction> 거래내역조회;
//   String 계좌번호;
//   String 예수금;
//   String 외화예수금;
//   String 평가금액;
// }

// class CustomOutput {
//   String ErrorCode;
//   String ErrorMessage;
//   CustomResult Result;
// }

// class CustomInput {
//   String 로그인방식;
//   String 사용자아이디;
//   String 사용자비밀번호;
//   Certificate 인증서;
//   String 조회구분;
//   String 통화코드출력여부;
//   String 계좌번호;
//   String 계좌비밀번호;
//   String 조회시작일;
//   String 조회종료일;
//   String 상품구분;
//   String 계좌번호확장;
// }