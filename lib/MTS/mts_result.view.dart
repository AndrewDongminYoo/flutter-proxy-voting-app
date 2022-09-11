// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import '../shared/shared.dart';
import 'mts.controller.dart';
import 'utils/result_array.dart';

class MTSShowResultPage extends StatefulWidget {
  const MTSShowResultPage({super.key});

  @override
  State<MTSShowResultPage> createState() => _MTSShowResultPageState();
}

class _MTSShowResultPageState extends State<MTSShowResultPage> {
  final MtsController _mtsController = MtsController.get();
  TextList resultList = TextList();

  @override
  void initState() {
    setState(() {
      resultList = _mtsController.texts;
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
          child: ListView(children: resultList)),
    );
  }
}
