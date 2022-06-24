import '../shared/back_button.dart';
import '../shared/notice_button.dart';
import 'package:flutter/material.dart';

class AppBodyPage extends StatefulWidget {
  const AppBodyPage({
    Key? key,
    required this.titleString,
    required this.helpText,
    required this.informationString,
    required this.mainContent,
    required this.subContentList,
  }) : super(key: key);

  final String titleString;
  final String helpText;
  final String informationString;
  final Widget mainContent;
  final Widget subContentList;

  @override
  State<AppBodyPage> createState() => _AppBodyPageState();
}

class _AppBodyPageState extends State<AppBodyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: const CustomBackButton(),
          title: Text(widget.titleString),
          backgroundColor: const Color(0xFF572E67),
          actions: const [
            NoticeButton(),
          ]),
      body: ListView(
        children: [
          Container(
            margin: const EdgeInsets.all(15),
            alignment: Alignment.topLeft,
            child: Column(
              children: [
                Row(
                  children: [
                    Text(widget.helpText,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        )),
                    const Spacer(),
                    OutlinedButton(
                      onPressed: () {
                        // 문의하기 페이지 구현
                      },
                      style: OutlinedButton.styleFrom(
                        primary: const Color(0xFF572E67),
                      ),
                      child: const Text('문의하기'),
                    ),
                  ],
                ),
                Text(widget.informationString),
              ],
            ),
          ),
          widget.mainContent,
          const Spacer(),
          widget.subContentList,
        ],
      ),
    );
  }
}
