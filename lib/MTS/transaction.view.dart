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
      body: Padding(
        padding: EdgeInsets.all(padding),
        child: Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: {
            0: FixedColumnWidth(width * 0.65),
            1: FixedColumnWidth(width * 1.475),
            2: FixedColumnWidth(width * 0.675),
            3: FixedColumnWidth(width * 1.125),
            4: FixedColumnWidth(width * 1.125),
            5: FixedColumnWidth(width * 1.475),
            6: FixedColumnWidth(width * 0.575),
          },
          border: const TableBorder(
              verticalInside: BorderSide(
                color: Colors.white,
              ),
              horizontalInside: BorderSide(
                color: Colors.white,
              )),
          defaultColumnWidth: FlexColumnWidth(width),
          children: [
            const TableRow(
              children: [
                TableCell(
                    child: Text('거래일자',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold))),
                TableCell(
                    child: Text('거래유형',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold))),
                TableCell(
                    child: Text('거래수량',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold))),
                TableCell(
                    child: Text('거래금액',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold))),
                TableCell(
                    child: Text('적요',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold))),
                TableCell(
                    child: Text('종목명',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold))),
                TableCell(
                    child: Text('수수료',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
            ...account.transactions.map(
              (Transaction trans) {
                return TableRow(
                  children: [
                    TableCell(
                        child: Text(
                            textAlign: TextAlign.right,
                            overflow: TextOverflow.ellipsis,
                            trans.transactionDate.substring(4))),
                    TableCell(
                        child: Text(
                            textAlign: TextAlign.right,
                            overflow: TextOverflow.ellipsis,
                            trans.transactionType)),
                    TableCell(
                        child: Text(
                            textAlign: TextAlign.right,
                            overflow: TextOverflow.ellipsis,
                            integer(trans.transactionCount))),
                    TableCell(
                        child: Text(
                            textAlign: TextAlign.right,
                            overflow: TextOverflow.ellipsis,
                            float(trans.transactionVolume))),
                    TableCell(
                        child: Text(
                            textAlign: TextAlign.right,
                            overflow: TextOverflow.ellipsis,
                            trans.briefs)),
                    TableCell(
                        child: Text(
                            textAlign: TextAlign.right,
                            overflow: TextOverflow.ellipsis,
                            trans.issueName)),
                    TableCell(
                        child: Text(
                            textAlign: TextAlign.right,
                            overflow: TextOverflow.ellipsis,
                            float(trans.commission))),
                  ],
                );
              },
            ).toList()
          ],
        ),
      ),
    );
  }
}

String float(String num) {
  double? number = double.tryParse(num);
  double number2 = number!.roundToDouble();
  return number2.toString();
}

String integer(String num) {
  double? number = double.tryParse(num);
  int number2 = number!.round();
  return number2.toString();
}
