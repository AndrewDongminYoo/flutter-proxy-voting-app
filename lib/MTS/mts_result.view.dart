// π¦ Flutter imports:
import 'package:flutter/material.dart';

// π Project imports:
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
      appBar: CustomAppBar(text: 'κ²°κ³Όνλ©΄'),
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
        onDismissed: (DismissDirection _) => onDismissed(context, account),
        child: AccountCard(
          onDismissed: () => onDismissed(context, account),
          account: account,
        ));
  }

  onDismissed(BuildContext context, Account account) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
        '${account.productName} μ­μ λμμ΅λλ€.',
      )),
    );
    setState(() {
      accounts!.remove(account);
    });
    _mtsController.accounts.remove(account);
  }
}
