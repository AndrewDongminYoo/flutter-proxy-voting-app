// ignore_for_file: non_constant_identifier_names
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

  late CustomModule Module;
  late String Class;
  late String Job;
  late dynamic Input;
  late CustomOutput Output;
  late String API_SEQ;

  CustomResponse.from(Map<String, dynamic> json) {
    Module = CustomModule(json['Module']);
    Class = json['Class'];
    Job = json['Job'];
    Input = json['Input'];
    Output = CustomOutput.from(json['Output']);
    API_SEQ = json['API_SEQ'];
  }

  Map<String, dynamic> get data => {
        'Module': Module.toString(),
        'Job': Job,
        'Class': Class,
        'Input': Input,
        'Output': Output.json,
        'API_SEQ': API_SEQ,
      };

  Future<void> fetchDataAndUploadFB() async {
    final firestore = FirebaseFirestore.instance;
    CollectionReference col = firestore.collection('transactions');
    DocumentReference dbRef = col.doc('${Module}_$Job');
    await dbRef.collection(today()).add(data);
    if (Output.ErrorCode != '00000000') return;
    Output.Result.forEach((String key, dynamic value) {
      if (value is List<Map<String, dynamic>>) {
        for (Map<String, dynamic> result in value) {
          print(key);
          result.forEach((k1, v1) {
            print('$k1: $v1');
          });
        }
      } else if (value is Map<String, dynamic>) {
        value.forEach((k1, v1) {
          print('$k1: $v1');
        });
      }
    });
  }

  @override
  String toString() => data.toString();
}

class CustomRequest {
  CustomRequest({
    required this.Module,
    required this.Job,
    this.Class = '증권서비스',
    required this.Input,
  }) : super();

  final CustomModule Module;
  final String Class;
  final String Job;
  final CustomInput Input;

  dynamic get data => {
        'Module': Module.toString(),
        'Job': Job,
        'Class': Class,
        'Input': Input.json,
      };

  Future<CustomResponse> fetch() async {
    print('===========$Module ${Job.padLeft(6, ' ')}===========');
    String? response = await channel.invokeMethod('getMTSData', {'data': data});
    dynamic json = jsonDecode(response!);
    return CustomResponse.from(json);
  }

  Future<Set<String>> collectResult(List<String> output) async {
    CustomResponse response = await fetch();
    await response.fetchDataAndUploadFB();
    Set<String> accounts = {};
    output.add('=====================================');
    dynamic jobResult = response.Output.Result[Job];
    switch (jobResult.runtimeType) {
      case List:
        for (Map<String, dynamic> element in jobResult) {
          element.forEach((key, value) {
            if (key == '계좌번호') {
              if (!accounts.contains(value)) {
                accounts.add(value);
                output.add('$key: ${hypen(value)}');
              }
            } else if (key.contains('일자')) {
              output.add('$key: ${dayOf(value)}');
            } else if (key.contains('수익률')) {
              output.add('$key: ${comma(value)}%');
            } else if (key != '상품코드') {
              output.add('$key: ${comma(value)}');
            }
          });
          if (output.last != '-') {
            output.add('-');
          }
        }
        return accounts;
      case Map:
        jobResult.forEach((key, value) {
          if (key == '계좌번호') {
            if (!accounts.contains(value)) {
              accounts.add(value);
              output.add('$key: ${hypen(value)}');
            }
          } else {
            output.add('$key: ${comma(value)}');
          }
        });
        return accounts;
      default:
        return accounts;
    }
  }

  @override
  String toString() => data.toString();
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

class CustomOutput {
  late String ErrorCode; // '00000000' 외에 모두 오류
  late String ErrorMessage;
  late Map<String, dynamic> Result;

  CustomOutput({
    this.ErrorCode = '00000000',
    this.ErrorMessage = '오류 메세지',
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

  @override
  String toString() => ErrorCode;
}

class CustomInput {
  late String idOrCert; //로그인방식;
  late String userid; //사용자아이디;
  late String password; //사용자비밀번호;
  late String queryCode; //조회구분;
  late String showISO; //통화코드출력여부;
  late String accountNum; //계좌번호;
  late String accountPin; //계좌비밀번호;
  late String start; //조회시작일;
  late String end; //조회종료일;
  late String type; //상품구분;
  late String accountExt; //계좌번호확장;
  late Map<String, String> Certificate;

  CustomInput({
    this.idOrCert = '', //로그인방식
    this.userid = '', //사용자아이디
    this.password = '', //사용자비밀번호
    this.queryCode = '', //조회구분
    this.showISO = '', //통화코드출력여부
    this.accountNum = '', //계좌번호
    this.accountPin = '', //계좌비밀번호
    this.start = '', //조회시작일
    this.end = '', //조회종료일
    this.type = '', //상품구분
    this.accountExt = '', //계좌번호확장
  });

  get json => {
        '로그인방식': idOrCert,
        '사용자아이디': userid,
        '사용자비밀번호': password,
        '조회구분': queryCode,
        '통화코드출력여부': showISO,
        '계좌번호': accountNum,
        '계좌비밀번호': accountPin,
        '조회시작일': start,
        '조회종료일': end,
        '상품구분': type,
        '계좌번호확장': accountExt,
      };

  CustomInput.from(dynamic input) {
    idOrCert = input['로그인방식'] ?? '';
    userid = input['사용자아이디'] ?? input['사용자이름'] ?? '';
    password = input['사용자비밀번호'] ?? '';
    queryCode = input['조회구분'] ?? '';
    showISO = input['통화코드출력여부'] ?? '';
    accountNum = input['계좌번호'] ?? '';
    accountPin = input['계좌비밀번호'] ?? '';
    start = input['조회시작일'] ?? '';
    end = input['조회종료일'] ?? '';
    type = input['상품구분'] ?? '';
    accountExt = input['계좌번호확장'] ?? '';
  }

  @override
  String toString() {
    return json.toString();
  }
}

// class Certificate {
//   String 이름;
//   String 만료일자;
//   String 비밀번호;
// }

class CustomModule {
  const CustomModule(this.firmName);
  final String firmName;
  @override
  String toString() => firmName;
}
