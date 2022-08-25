// ignore_for_file: non_constant_identifier_names

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
