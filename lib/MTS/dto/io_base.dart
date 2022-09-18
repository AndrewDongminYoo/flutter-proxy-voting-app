// ignore_for_file: non_constant_identifier_names
// 🌎 Project imports:
import '../../utils/exception.dart';
import '../mts.dart';

class CertDto implements IOBase {
  String certName; // 이름
  String certExpire; // 만료일자
  String certPassword; // 비밀번호

  CertDto({
    required this.certName,
    required this.certExpire,
    required this.certPassword,
  });

  @override
  Map<String, dynamic> get json {
    Map<String, String> temp = {
      '이름': certName,
      '만료일자': certExpire,
      '비밀번호': certPassword,
    };
    temp.removeWhere((String key, String value) => value.isEmpty);
    return temp;
  }
}

class CustomOutput implements IOBase {
  late String ErrorCode; // '00000000' 외에 모두 오류
  late String ErrorMessage;
  late CustomResult Result;

  CustomOutput({
    this.ErrorCode = '00000000',
    this.ErrorMessage = '오류 메세지',
    required this.Result,
  }) : super() {
    if (ErrorCode != '00000000') throwError();
  }

  CustomOutput.from(Map<String, dynamic> output) {
    ErrorCode = (output['ErrorCode']) as String;
    ErrorMessage = (output['ErrorMessage']) as String;
    if (ErrorCode != '00000000') throwError();
    Result = CustomResult.from(output['Result'] as Map<String, dynamic>?);
  }

  @override
  Map<String, dynamic> get json {
    Map<String, dynamic> temp = {
      'ErrorCode': ErrorCode,
      'ErrorMessage': ErrorMessage,
      'Result': Result.isEmpty ? {} : Result.json,
    };
    temp.removeWhere((String k, dynamic v) {
      if (v is String) {
        return v.isEmpty;
      } else if (v is Map) {
        return v.isEmpty;
      }
      return true;
    });
    return temp;
  }

  @override
  String toString() => ErrorCode;

  void throwError() {
    if (errorMsg.containsKey(ErrorCode)) {
      throw CustomException(errorMsg[ErrorCode]);
    } else {
      throw CustomException(ErrorMessage);
    }
  }
}

class CustomInput implements IOBase {
  late String idOrCert; //로그인방식
  late String userId; //사용자아이디
  late String password; //사용자비밀번호
  late String queryCode; //조회구분
  late String showISO; //통화코드출력여부
  late String accountNum; //계좌번호
  late String accountPin; //계좌비밀번호
  late String start; //조회시작일
  late String end; //조회종료일
  late String type; //상품구분
  late String accountExt; //계좌번호확장
  late CertDto? certificate; // 인증서

  CustomInput({
    this.idOrCert = '', //로그인방식
    this.userId = '', //사용자아이디
    this.password = '', //사용자비밀번호
    this.queryCode = '', //조회구분
    this.showISO = '', //통화코드출력여부
    this.accountNum = '', //계좌번호
    this.accountPin = '', //계좌비밀번호
    this.start = '', //조회시작일
    this.end = '', //조회종료일
    this.type = '', //상품구분
    this.accountExt = '', //계좌번호확장
    this.certificate,
  });

  @override
  Map<String, dynamic> get json {
    Map<String, dynamic> temp = {
      '로그인방식': idOrCert,
      '사용자아이디': userId,
      '사용자비밀번호': password,
      '조회구분': queryCode,
      '통화코드출력여부': showISO,
      '계좌번호': accountNum,
      '계좌비밀번호': accountPin,
      '조회시작일': start,
      '조회종료일': end,
      '상품구분': type,
      '계좌번호확장': accountExt,
      '인증서': certificate?.json,
    };
    temp.removeWhere((String k, dynamic v) => v == null || v.isEmpty == true);
    return temp;
  }

  CustomInput.from(Map<String, dynamic> input) {
    idOrCert = (input['로그인방식'] ?? '') as String;
    userId = (input['사용자아이디'] ?? '') as String;
    password = (input['사용자비밀번호'] ?? '') as String;
    queryCode = (input['조회구분'] ?? '') as String;
    showISO = (input['통화코드출력여부'] ?? '') as String;
    accountNum = (input['계좌번호'] ?? '') as String;
    accountPin = (input['계좌비밀번호'] ?? '') as String;
    start = (input['조회시작일'] ?? '') as String;
    end = (input['조회종료일'] ?? '') as String;
    type = (input['상품구분'] ?? '') as String;
    accountExt = (input['계좌번호확장'] ?? '') as String;
    certificate = CertDto(
      certName: (input['인증서']?['이름'] ?? '') as String,
      certPassword: (input['인증서']?['비밀번호'] ?? '') as String,
      certExpire: (input['인증서']?['만료일자'] ?? '') as String,
    );
  }

  @override
  String toString() {
    return json.toString();
  }
}

class CustomResult implements IOBase {
  String userId = ''; // 사용자아이디
  String username = ''; // 사용자이름
  List<BankAccountAll> accountAll = []; // 전계좌조회
  List<StockAccount> accountStock = []; // 증권보유계좌조회
  List<BankAccountDetail> accountDetail = []; // 계좌상세조회
  List<BankAccountTransaction> accountTransaction = []; // 거래내역조회
  String accountNum = ''; // 계좌번호
  String depositReceived = ''; // 예수금
  String foriegnDeposit = ''; // 외화예수금
  String amountValuation = ''; // 평가금액

  CustomResult.from(Map<String, dynamic>? output) {
    if (output != null) {
      userId = (output['사용자아이디'] ?? '') as String;
      username = (output['사용자이름'] ?? '') as String;
      accountNum = (output['계좌번호'] ?? '') as String;
      depositReceived = (output['예수금'] ?? '') as String;
      foriegnDeposit = (output['외화예수금'] ?? '') as String;
      amountValuation = (output['평가금액'] ?? '') as String;
      final dynamic stock = output['증권보유계좌조회'];
      if (stock is List) {
        accountStock = stock
            .map((dynamic e) => StockAccount.from(e as Map<String, dynamic>))
            .toList();
      }
      final dynamic all = output['전계좌조회'];
      if (all is List) {
        accountAll = all
            .map((dynamic e) => BankAccountAll.from(e as Map<String, dynamic>))
            .toList();
      }
      final dynamic detail = output['계좌상세조회'];
      if (detail is List) {
        accountDetail = detail
            .map((dynamic e) =>
                BankAccountDetail.from(e as Map<String, dynamic>))
            .toList();
      }
      final dynamic transaction = output['거래내역조회'];
      if (transaction is List) {
        accountTransaction = transaction
            .map((dynamic e) =>
                BankAccountTransaction.from(e as Map<String, dynamic>))
            .toList();
      }
    }
  }

  bool get isEmpty => (userId.isEmpty &&
      username.isEmpty &&
      accountNum.isEmpty &&
      depositReceived.isEmpty &&
      foriegnDeposit.isEmpty &&
      amountValuation.isEmpty &&
      accountStock.isEmpty &&
      accountAll.isEmpty &&
      accountDetail.isEmpty &&
      accountTransaction.isEmpty);

  @override
  Map<String, dynamic> get json {
    Map<String, dynamic> temp = {
      '사용자아이디': userId,
      '사용자이름': username,
      '계좌번호': accountNum,
      '예수금': depositReceived,
      '외화예수금': foriegnDeposit,
      '평가금액': amountValuation,
      '증권보유계좌조회': accountStock.map((StockAccount e) => e.json).toList(),
      '전계좌조회': accountAll.map((BankAccountAll e) => e.json).toList(),
      '계좌상세조회': accountDetail.map((BankAccountDetail e) => e.json).toList(),
      '거래내역조회':
          accountTransaction.map((BankAccountTransaction e) => e.json).toList(),
    };
    temp.removeWhere((String k, dynamic v) => v == null || v.isEmpty == true);
    return temp;
  }
}
