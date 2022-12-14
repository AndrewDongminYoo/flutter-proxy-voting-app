// π Project imports:
import '../mts.dart';

class Account implements IOBase {
  late CustomModule module;
  late String idOrCert;
  late String accountNum;
  late String productCode;
  late String productName;
  late List<Stock> stocks = [];
  late List<Transaction> transactions = [];

  Account({
    required this.module,
    required this.idOrCert,
    required this.accountNum,
    required this.productCode,
    required this.productName,
  });

  @override
  Map<String, dynamic> get json => {
        'μ¦κΆμ¬λͺ': module.korName,
        'μμ΄λ/μΈμ¦μ': idOrCert,
        'κ³μ’λ²νΈ': accountNum,
        'μνμ½λ': productCode,
        'μνλͺ': productName,
      };
}

class Stock implements IOBase {
  late String productName; // μνλͺ
  late String productTypeCode; // μνμ νμ½λ
  late String productIssueName; // μν_μ’λͺ©λͺ
  late String quantity; // μλ
  late String presentValue; // νμ¬κ°
  late String averageValue; // νκ· λ§€μκ°
  late String evaluationAmount; // νκ°κΈμ‘
  late String valuationGain; // νκ°μμ΅
  late String yields; // μμ΅λ₯ 

  Stock.from(BankAccountDetail detail) {
    productName = detail.productName;
    productTypeCode = detail.productTypeCode;
    productIssueName = detail.productIssueName;
    quantity = detail.quantity;
    presentValue = detail.presentValue;
    averageValue = detail.averageValue;
    evaluationAmount = detail.evaluationAmount;
    valuationGain = detail.valuationGain;
    yields = detail.yields;
  }

  @override
  Map<String, dynamic> get json => {
        'μνλͺ': productName,
        'μνμ νμ½λ': productTypeCode,
        'μν_μ’λͺ©λͺ': productIssueName,
        'μλ': quantity,
        'νμ¬κ°': presentValue,
        'νκ· λ§€μκ°': averageValue,
        'νκ°κΈμ‘': evaluationAmount,
        'νκ°μμ΅': valuationGain,
        'μμ΅λ₯ ': yields,
      };
}

class Transaction implements IOBase {
  late String transactionDate; // κ±°λμΌμ
  late String transactionType; // κ±°λμ ν
  late String transactionCount; // κ±°λμλ
  late String transactionVolume; // κ±°λκΈμ‘
  late String briefs; // μ μ
  late String issueName; // μ’λͺ©λͺ
  late String commission; // μμλ£

  Transaction.from(BankAccountTransaction detail) {
    transactionDate = detail.transactionDate;
    transactionType = detail.transactionType;
    briefs = detail.briefs;
    issueName = detail.issueName;
    transactionCount = detail.transactionCount;
    transactionVolume = detail.transactionVolume;
    commission = detail.commission;
  }

  @override
  Map<String, dynamic> get json => {
        'κ±°λμΌμ': transactionDate,
        'κ±°λμ ν': transactionType,
        'κ±°λμλ': transactionCount,
        'κ±°λκΈμ‘': transactionVolume,
        'μ μ': briefs,
        'μ’λͺ©λͺ': issueName,
        'μμλ£': commission,
      };
}
