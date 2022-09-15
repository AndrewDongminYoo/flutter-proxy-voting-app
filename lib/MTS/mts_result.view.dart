// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import '../shared/shared.dart';
import 'mts.dart';

class MTSShowResultPage extends StatefulWidget {
  const MTSShowResultPage({super.key});

  @override
  State<MTSShowResultPage> createState() => _MTSShowResultPageState();
}

class _MTSShowResultPageState extends State<MTSShowResultPage> {
  final MtsController _mtsController = MtsController.get();
  Set<Account>? accounts;

  @override
  void initState() {
    setState(() {
      accounts = _mtsController.accounts;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(text: '결과화면'),
      body: Container(
        padding: const EdgeInsets.all(36),
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(30),
            )),
        child: ListView(
            children: accounts!
                .map((Account account) => toDismissbleButton(context, account))
                .toList()),
      ),
    );
  }

  Dismissible toDismissbleButton(BuildContext context, Account account) {
    return Dismissible(
        key: UniqueKey(),
        background: Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              // boxShadow: kElevationToShadow[1],
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20)),
        ),
        onDismissed: (DismissDirection direction) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
              '${account.productName} 삭제되었습니다.',
            )),
          );
          setState(() {
            accounts!.remove(account);
          });
          _mtsController.accounts.remove(account);
        },
        child: AccountCard(account: account));
  }
}
