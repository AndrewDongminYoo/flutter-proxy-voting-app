import 'dart:ffi';

import 'package:bside/mts/mts.dart';
import 'package:bside/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';

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
    const line = Text('|', style: TextStyle(fontWeight: FontWeight.bold));
    return Scaffold(
      appBar: CustomAppBar(
        text: '조회결과',
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text('거래일자', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('거래유형', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('거래수량', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('거래금액', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('적요', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('종목명', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('수수료', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          ...account.transactions.map(
            (trans) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(trans.transactionDate.substring(4)),
                  line,
                  Text(trans.transactionType),
                  line,
                  Text(integer(trans.transactionCount)),
                  line,
                  Text(float(trans.transactionVolume)),
                  line,
                  Text(trans.briefs),
                  line,
                  Text(trans.issueName),
                  line,
                  Text(float(trans.commission)),
                ],
              );
            },
          ).toList()
        ],
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
