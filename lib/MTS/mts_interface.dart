// // ignore_for_file: non_constant_identifier_names

// class AllTransaction {
//   String 거래일자;
//   String 거래시각;
//   String 거래유형;
//   String 적요;
//   String 종목명;
//   String 거래수량;
//   String 거래금액;
//   String 수수료;
//   String 금잔수량;
//   String 금잔금액;
//   String 금잔금액2;
//   String 통화코드;
//   String 정산금액;
//   String 외화거래금액;
//   String 세금;
//   String 원화거래금액;
//   String 국외수수료;
//   String 입금통장표시내용;
//   String 출금통장표시내용;
//   String 처리점;
//   String 입금은행;
//   String 입금계좌번호;
// }

// class DetailAccount {
//   String 상품명;
//   String 계좌번호;
//   String 상품코드;
//   String 상품유형코드;
//   String 상품_종목명;
//   String 상품_종목코드;
//   String 잔고유형;
//   String 수량;
//   String 현재가;
//   String 평균매입가;
//   String 매입금액;
//   String 평가금액;
//   String 평가손익;
//   String 수익률;
//   String 통화코드;
//   String 계좌번호확장;
// }

// class AllAccount {
//   String 계좌번호;
//   String 계좌번호표시용;
//   String 원금;
//   String 계좌명_유형;
//   String 매입금액;
//   String 대출금액;
//   String 평가금액;
//   String 평가손익;
//   String 출금가능금액;
//   String 예수금;
//   String 예수금_D1;
//   String 예수금_D2;
//   String 외화예수금;
//   String 수익률;
//   String 총자산;
// }

// class StockAccount {
//   String 계좌번호;
//   String 상품코드;
//   String 상품명;
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

// class Output {
//   String ErrorCode;
//   String ErrorMessage;
//   CustomResult Result;
// }

// class Certificate {
//   String 이름;
//   String 만료일자;
//   String 비밀번호;
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

// class Request {
//   String Module;
//   String Class;
//   String Job;
//   CustomInput Input;
// }

// class Response {
//   String Module;
//   String Class;
//   String Job;
//   CustomInput Input;
//   Output OutPut;
//   API_SEQ API_SEQ;
// }

abstract class MTSInterface {
  toDictionary() {
    throw UnimplementedError();
  }
}

class LoginRequest implements MTSInterface {
  @override
  toDictionary() {
    // TODO: implement toDictionary
    throw UnimplementedError();
  }
}
