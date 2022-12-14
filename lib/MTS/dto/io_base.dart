// ignore_for_file: non_constant_identifier_names
// ๐ Project imports:
import '../../utils/exception.dart';
import '../mts.dart';

class CertDto implements IOBase {
  String certName; // ์ด๋ฆ
  String certExpire; // ๋ง๋ฃ์ผ์
  String certPassword; // ๋น๋ฐ๋ฒํธ

  CertDto({
    required this.certName,
    required this.certExpire,
    required this.certPassword,
  });

  @override
  Map<String, dynamic> get json {
    Map<String, String> temp = {
      '์ด๋ฆ': certName,
      '๋ง๋ฃ์ผ์': certExpire,
      '๋น๋ฐ๋ฒํธ': certPassword,
    };
    temp.removeWhere((String key, String value) => value.isEmpty);
    return temp;
  }
}

class CustomOutput implements IOBase {
  late String ErrorCode; // '00000000' ์ธ์ ๋ชจ๋ ์ค๋ฅ
  late String ErrorMessage;
  late CustomResult Result;

  CustomOutput({
    this.ErrorCode = '00000000',
    this.ErrorMessage = '์ค๋ฅ ๋ฉ์ธ์ง',
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
  late String idOrCert; //๋ก๊ทธ์ธ๋ฐฉ์
  late String userId; //์ฌ์ฉ์์์ด๋
  late String password; //์ฌ์ฉ์๋น๋ฐ๋ฒํธ
  late String queryCode; //์กฐํ๊ตฌ๋ถ
  late String showISO; //ํตํ์ฝ๋์ถ๋?ฅ์ฌ๋ถ
  late String accountNum; //๊ณ์ข๋ฒํธ
  late String accountPin; //๊ณ์ข๋น๋ฐ๋ฒํธ
  late String start; //์กฐํ์์์ผ
  late String end; //์กฐํ์ข๋ฃ์ผ
  late String type; //์ํ๊ตฌ๋ถ
  late String accountExt; //๊ณ์ข๋ฒํธํ์ฅ
  late CertDto? certificate; // ์ธ์ฆ์

  CustomInput({
    this.idOrCert = '', //๋ก๊ทธ์ธ๋ฐฉ์
    this.userId = '', //์ฌ์ฉ์์์ด๋
    this.password = '', //์ฌ์ฉ์๋น๋ฐ๋ฒํธ
    this.queryCode = '', //์กฐํ๊ตฌ๋ถ
    this.showISO = '', //ํตํ์ฝ๋์ถ๋?ฅ์ฌ๋ถ
    this.accountNum = '', //๊ณ์ข๋ฒํธ
    this.accountPin = '', //๊ณ์ข๋น๋ฐ๋ฒํธ
    this.start = '', //์กฐํ์์์ผ
    this.end = '', //์กฐํ์ข๋ฃ์ผ
    this.type = '', //์ํ๊ตฌ๋ถ
    this.accountExt = '', //๊ณ์ข๋ฒํธํ์ฅ
    this.certificate,
  });

  @override
  Map<String, dynamic> get json {
    Map<String, dynamic> temp = {
      '๋ก๊ทธ์ธ๋ฐฉ์': idOrCert,
      '์ฌ์ฉ์์์ด๋': userId,
      '์ฌ์ฉ์๋น๋ฐ๋ฒํธ': password,
      '์กฐํ๊ตฌ๋ถ': queryCode,
      'ํตํ์ฝ๋์ถ๋?ฅ์ฌ๋ถ': showISO,
      '๊ณ์ข๋ฒํธ': accountNum,
      '๊ณ์ข๋น๋ฐ๋ฒํธ': accountPin,
      '์กฐํ์์์ผ': start,
      '์กฐํ์ข๋ฃ์ผ': end,
      '์ํ๊ตฌ๋ถ': type,
      '๊ณ์ข๋ฒํธํ์ฅ': accountExt,
      '์ธ์ฆ์': certificate?.json,
    };
    temp.removeWhere((String k, dynamic v) => v == null || v.isEmpty == true);
    return temp;
  }

  CustomInput.from(Map<String, dynamic> input) {
    idOrCert = (input['๋ก๊ทธ์ธ๋ฐฉ์'] ?? '') as String;
    userId = (input['์ฌ์ฉ์์์ด๋'] ?? '') as String;
    password = (input['์ฌ์ฉ์๋น๋ฐ๋ฒํธ'] ?? '') as String;
    queryCode = (input['์กฐํ๊ตฌ๋ถ'] ?? '') as String;
    showISO = (input['ํตํ์ฝ๋์ถ๋?ฅ์ฌ๋ถ'] ?? '') as String;
    accountNum = (input['๊ณ์ข๋ฒํธ'] ?? '') as String;
    accountPin = (input['๊ณ์ข๋น๋ฐ๋ฒํธ'] ?? '') as String;
    start = (input['์กฐํ์์์ผ'] ?? '') as String;
    end = (input['์กฐํ์ข๋ฃ์ผ'] ?? '') as String;
    type = (input['์ํ๊ตฌ๋ถ'] ?? '') as String;
    accountExt = (input['๊ณ์ข๋ฒํธํ์ฅ'] ?? '') as String;
    certificate = CertDto(
      certName: (input['์ธ์ฆ์']?['์ด๋ฆ'] ?? '') as String,
      certPassword: (input['์ธ์ฆ์']?['๋น๋ฐ๋ฒํธ'] ?? '') as String,
      certExpire: (input['์ธ์ฆ์']?['๋ง๋ฃ์ผ์'] ?? '') as String,
    );
  }

  @override
  String toString() {
    return json.toString();
  }
}

class CustomResult implements IOBase {
  String userId = ''; // ์ฌ์ฉ์์์ด๋
  String username = ''; // ์ฌ์ฉ์์ด๋ฆ
  List<BankAccountAll> accountAll = []; // ์?๊ณ์ข์กฐํ
  List<StockAccount> accountStock = []; // ์ฆ๊ถ๋ณด์?๊ณ์ข์กฐํ
  List<BankAccountDetail> accountDetail = []; // ๊ณ์ข์์ธ์กฐํ
  List<BankAccountTransaction> accountTransaction = []; // ๊ฑฐ๋๋ด์ญ์กฐํ
  String accountNum = ''; // ๊ณ์ข๋ฒํธ
  String depositReceived = ''; // ์์๊ธ
  String foriegnDeposit = ''; // ์ธํ์์๊ธ
  String amountValuation = ''; // ํ๊ฐ๊ธ์ก

  CustomResult.from(Map<String, dynamic>? output) {
    if (output != null) {
      userId = (output['์ฌ์ฉ์์์ด๋'] ?? '') as String;
      username = (output['์ฌ์ฉ์์ด๋ฆ'] ?? '') as String;
      accountNum = (output['๊ณ์ข๋ฒํธ'] ?? '') as String;
      depositReceived = (output['์์๊ธ'] ?? '') as String;
      foriegnDeposit = (output['์ธํ์์๊ธ'] ?? '') as String;
      amountValuation = (output['ํ๊ฐ๊ธ์ก'] ?? '') as String;
      final dynamic stock = output['์ฆ๊ถ๋ณด์?๊ณ์ข์กฐํ'];
      if (stock is List) {
        accountStock = stock
            .map((dynamic e) => StockAccount.from(e as Map<String, dynamic>))
            .toList();
      }
      final dynamic all = output['์?๊ณ์ข์กฐํ'];
      if (all is List) {
        accountAll = all
            .map((dynamic e) => BankAccountAll.from(e as Map<String, dynamic>))
            .toList();
      }
      final dynamic detail = output['๊ณ์ข์์ธ์กฐํ'];
      if (detail is List) {
        accountDetail = detail
            .map((dynamic e) =>
                BankAccountDetail.from(e as Map<String, dynamic>))
            .toList();
      }
      final dynamic transaction = output['๊ฑฐ๋๋ด์ญ์กฐํ'];
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
      '์ฌ์ฉ์์์ด๋': userId,
      '์ฌ์ฉ์์ด๋ฆ': username,
      '๊ณ์ข๋ฒํธ': accountNum,
      '์์๊ธ': depositReceived,
      '์ธํ์์๊ธ': foriegnDeposit,
      'ํ๊ฐ๊ธ์ก': amountValuation,
      '์ฆ๊ถ๋ณด์?๊ณ์ข์กฐํ': accountStock.map((StockAccount e) => e.json).toList(),
      '์?๊ณ์ข์กฐํ': accountAll.map((BankAccountAll e) => e.json).toList(),
      '๊ณ์ข์์ธ์กฐํ': accountDetail.map((BankAccountDetail e) => e.json).toList(),
      '๊ฑฐ๋๋ด์ญ์กฐํ':
          accountTransaction.map((BankAccountTransaction e) => e.json).toList(),
    };
    temp.removeWhere((String k, dynamic v) => v == null || v.isEmpty == true);
    return temp;
  }
}
