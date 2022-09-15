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
      body: ListView(
          children: account.transactions
              .map((Transaction e) => TransactionCard(trans: e))
              .toList()),
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
    return Text(transaction.json.toString());
  }
}
