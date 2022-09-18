// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:get/route_manager.dart';

// 📦 Package imports:
import '../shared/custom_appbar.dart';
import 'models/acccount.model.dart';

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
        text: '조회결과',
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
                  THead(data: '거래일자'),
                  THead(data: '거래유형'),
                  THead(data: '거래수량'),
                  THead(data: '거래금액'),
                  THead(data: '적요'),
                  THead(data: '종목명'),
                  THead(data: '수수료'),
                ],
              ),
              ...account.transactions.map(
                (Transaction trans) {
                  return TableRow(
                    children: [
                      TBody(data: date(trans.transactionDate)), // 거래일자
                      TBody(data: trans.transactionType), // 거래유형
                      TBody(data: integer(trans.transactionCount)), // 거래수량
                      TBody(data: float(trans.transactionVolume)), // 거래금액
                      TBody(data: trans.briefs), // 적요
                      TBody(data: trans.issueName), // 종목명
                      TBody(data: float(trans.commission)), // 수수료
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
