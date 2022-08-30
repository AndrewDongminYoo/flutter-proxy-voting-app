// ignore_for_file: non_constant_identifier_names

import '../mts.dart';

class Certificate implements IOBase {
  String certName; // 이름
  String certExpire; // 만료일자
  String certPassword; // 비밀번호

  Certificate({
    required this.certName,
    required this.certExpire,
    required this.certPassword,
  });

  @override
  Map<String, dynamic> get json => {
        '이름': certName,
        '만료일자': certExpire,
        '비밀번호': certPassword,
      };
}

class CustomOutput implements IOBase {
  late String ErrorCode; // '00000000' 외에 모두 오류
  late String ErrorMessage;
  late CustomResult Result;

  CustomOutput({
    this.ErrorCode = '00000000',
    this.ErrorMessage = '오류 메세지',
    required this.Result,
  });

  CustomOutput.from(dynamic output) {
    ErrorCode = output['ErrorCode'];
    ErrorMessage = output['ErrorMessage'];
    Result = CustomResult.from(output['Result']);
  }

  @override
  Map<String, dynamic> get json => {
        'ErrorCode': ErrorCode,
        'ErrorMessage': ErrorMessage,
        'Result': Result.json,
      };

  @override
  String toString() => ErrorCode;
}

class CustomInput implements IOBase {
  late String idOrCert; //로그인방식
  late String userid; //사용자아이디
  late String password; //사용자비밀번호
  late String queryCode; //조회구분
  late String showISO; //통화코드출력여부
  late String accountNum; //계좌번호
  late String accountPin; //계좌비밀번호
  late String start; //조회시작일
  late String end; //조회종료일
  late String type; //상품구분
  late String accountExt; //계좌번호확장
  late Certificate certificate; // 인증서

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

  @override
  Map<String, dynamic> get json {
    Map<String, dynamic> input = {
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
    input.removeWhere((k, v) => v.isEmpty);
    return input;
  }

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

class CustomResult implements IOBase {
  late String username; // 사용자아이디
  late List accountStock; // 증권보유계좌조회
  late List accountAll; // 전계좌조회
  late List accountDetail; // 계좌상세조회
  late List accountTransaction; // 거래내역조회
  late String accountNum; // 계좌번호
  late String depositReceived; // 예수금
  late String foriegnDeposit; // 외화예수금
  late String amountValuation; // 평가금액

  CustomResult.from(dynamic output) {
    if (output is Map<String, dynamic>) {
      username = output['사용자아이디'] ?? '';
      accountNum = output['계좌번호'] ?? '';
      depositReceived = output['예수금'] ?? '';
      foriegnDeposit = output['외화예수금'] ?? '';
      amountValuation = output['평가금액'] ?? '';
      accountStock = output['증권보유계좌조회'] ?? [];
      accountAll = output['전계좌조회'] ?? [];
      accountDetail = output['계좌상세조회'] ?? [];
      accountTransaction = output['거래내역조회'] ?? [];
    } else {
      username = '';
      accountNum = '';
      depositReceived = '';
      foriegnDeposit = '';
      amountValuation = '';
      accountStock = [];
      accountAll = [];
      accountDetail = [];
      accountTransaction = [];
    }
  }

  @override
  Map<String, dynamic> get json {
    Map<String, dynamic> result = {
      '사용자아이디': username,
      '계좌번호': accountNum,
      '예수금': depositReceived,
      '외화예수금': foriegnDeposit,
      '평가금액': amountValuation,
      '증권보유계좌조회': accountStock,
      '전계좌조회': accountAll,
      '계좌상세조회': accountDetail,
      '거래내역조회': accountTransaction,
    };
    result.removeWhere((k, v) => v.isEmpty);
    return result;
  }
}
