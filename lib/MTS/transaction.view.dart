// π¦ Flutter imports:
import 'package:flutter/material.dart';

// π Project imports:
import 'package:get/route_manager.dart';

// π¦ Package imports:
import '../shared/custom_appbar.dart';
import 'models/account.model.dart';

class ShowTransactionPage extends StatefulWidget {
  const ShowTransactionPage({super.key, required this.account});
  final Account account;

  @override
  State<ShowTransactionPage> createState() => _ShowTransactionPageState();
}

class _ShowTransactionPageState extends State<ShowTransactionPage> {
  @override
  Widget build(BuildContext context) {
    Account account = widget.account;
    double padding = 24.00;
    double width = (Get.width - (2 * padding)) / 7;
    return Scaffold(
      appBar: CustomAppBar(
        text: 'μ‘°νκ²°κ³Ό',
      ),
      body: SingleChildScrollView(
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(padding),
          child: Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            columnWidths: {
              0: FixedColumnWidth(width * 0.675),
              1: FixedColumnWidth(width * 1.475),
              2: FixedColumnWidth(width * 0.675),
              3: FixedColumnWidth(width * 1.125),
              4: FixedColumnWidth(width * 1.0),
              5: FixedColumnWidth(width * 1.6),
              6: FixedColumnWidth(width * 0.55),
            },
            border: const TableBorder(
              horizontalInside: BorderSide(
                color: Colors.red,
                width: 0.25,
              ),
              verticalInside: BorderSide(
                color: Colors.black,
                width: 0.125,
              ),
            ),
            defaultColumnWidth: FlexColumnWidth(width),
            children: [
              const TableRow(
                children: [
                  THead(data: 'κ±°λμΌμ'),
                  THead(data: 'κ±°λμ ν'),
                  THead(data: 'κ±°λμλ'),
                  THead(data: 'κ±°λκΈμ‘'),
                  THead(data: 'μ μ'),
                  THead(data: 'μ’λͺ©λͺ'),
                  THead(data: 'μμλ£'),
                ],
              ),
              ...account.transactions.map(
                (Transaction trans) {
                  return TableRow(
                    children: [
                      TBody(data: date(trans.transactionDate)), // κ±°λμΌμ
                      TBody(data: trans.transactionType), // κ±°λμ ν
                      TBody(data: integer(trans.transactionCount)), // κ±°λμλ
                      TBody(data: float(trans.transactionVolume)), // κ±°λκΈμ‘
                      TBody(data: trans.briefs), // μ μ
                      TBody(data: trans.issueName), // μ’λͺ©λͺ
                      TBody(data: float(trans.commission)), // μμλ£
                    ],
                  );
                },
              ).toList()
            ],
          ),
        ),
      ),
    );
  }
}

class THead extends StatelessWidget {
  const THead({
    super.key,
    required this.data,
  });
  final String data;
  @override
  Widget build(BuildContext context) {
    return TableCell(
        child: Text(
      data,
      textAlign: TextAlign.center,
      style: const TextStyle(fontWeight: FontWeight.bold),
    ));
  }
}

class TBody extends StatelessWidget {
  const TBody({
    super.key,
    required this.data,
  });
  final String data;
  @override
  Widget build(BuildContext context) {
    return TableCell(
        child: Text(
      textAlign: TextAlign.right,
      overflow: TextOverflow.visible,
      data,
    ));
  }
}

String date(String str) {
  DateTime dt = DateTime.parse(str);
  String month = dt.month.toString();
  String day = dt.day.toString().padLeft(2, '0');
  return '$month/$day';
}

String float(String num) {
  double? number = double.tryParse(num);
  double number2 = number!.roundToDouble();
  if (number2 == 0) return '0';
  return number2.toString();
}

String integer(String num) {
  double? number = double.tryParse(num);
  int number2 = number!.round();
  if (number2 == 0) return '0';
  return number2.toString();
}
