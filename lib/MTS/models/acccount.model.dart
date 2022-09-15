// 🌎 Project imports:
import 'mts_firm.model.dart';

class Account {
  late CustomModule module;
  late String idOrCert;
  late String accountNum;
  late String productCode;
  late String productName;

  Account({
    required this.module,
    required this.idOrCert,
    required this.accountNum,
    required this.productCode,
    required this.productName,
  });
}
