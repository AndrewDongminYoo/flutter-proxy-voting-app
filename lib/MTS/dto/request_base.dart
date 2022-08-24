// ignore_for_file: non_constant_identifier_names
// 🎯 Dart imports:
import 'dart:convert';

// 📦 Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';

// 🌎 Project imports:
import '../../utils/channel.dart';
import '../widgets/formatters.dart';

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
  late CustomOutput Output;
  late String API_SEQ;

  CustomResponse.from(Map<String, dynamic> json) {
    Module = json['Module'];
    Class = json['Class'];
    Job = json['Job'];
    Input = json['Input'];
    Output = CustomOutput.from(json['Output']);
    API_SEQ = json['API_SEQ'];
  }

  Map<String, dynamic> get data => {
        'Module': Module,
        'Job': Job,
        'Class': Class,
        'Input': Input,
        'Output': Output.json,
        'API_SEQ': API_SEQ,
      };

  Future<void> fetchDataAndUploadFB() async {
    final firestore = FirebaseFirestore.instance;
    CollectionReference col = firestore.collection('transactions');
    DocumentReference dbRef = col.doc('${Input["사용자아이디"]}_$Module');
    await dbRef.collection(today()).add(data);
    Output.Result.forEach((key, value) {
      if (value is List<Map<String, String>>) {
        for (var element in value) {
          print(key);
          element.forEach((key1, value1) {
            print('$key1: $value1');
          });
        }
      } else {
        print('$key: $value');
      }
    });
  }
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
    var json = jsonDecode(response);
    return CustomResponse.from(json);
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
// }a

class CustomOutput {
  late String ErrorCode;
  late String ErrorMessage;
  late Map<String, dynamic> Result;

  CustomOutput({
    this.ErrorCode = '',
    this.ErrorMessage = '',
    required this.Result,
  });

  CustomOutput.from(dynamic output) {
    ErrorCode = output['ErrorCode'];
    ErrorMessage = output['ErrorMessage'];
    Result = output['Result'];
  }

  get json => {
        'ErrorCode': ErrorCode,
        'ErrorMessage': ErrorMessage,
        'Result': Result,
      };
}

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
