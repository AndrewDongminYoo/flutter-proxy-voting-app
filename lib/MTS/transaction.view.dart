import 'package:bside/mts/mts.dart';
import 'package:bside/shared/shared.dart';
import 'package:flutter/material.dart';

class ShowTransactionPage extends StatefulWidget {
  const ShowTransactionPage({super.key, required this.account});
  final Account account;

  @override
  State<ShowTransactionPage> createState() => _ShowTransactionPageState();
}

class _ShowTransactionPageState extends State<ShowTransactionPage> {
  MtsController mtsController = MtsController.get();
  @override
  Widget build(BuildContext context) {
    Account account = widget.account;
    return Scaffold(
      appBar: CustomAppBar(
        text: '조회결과',
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
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
          ListView(
              children: account.transactions
                  .map((Transaction e) => TransactionCard(trans: e))
                  .toList()),
        ],
      ),
    );
  }
}

class TransactionCard extends StatefulWidget {
  const TransactionCard({super.key, required this.trans});
  final Transaction trans;

  @override
  State<TransactionCard> createState() => _TransactionCardState();
}

class _TransactionCardState extends State<TransactionCard> {
  @override
  Widget build(BuildContext context) {
    Transaction transaction = widget.trans;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(transaction.transactionDate),
        Text(transaction.transactionType),
        Text(transaction.transactionCount),
        Text(transaction.transactionVolume),
        Text(transaction.briefs),
        Text(transaction.issueName),
        Text(transaction.commission),
      ],
    );
  }
}
