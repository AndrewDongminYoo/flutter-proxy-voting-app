// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import '../shared/custom_appbar.dart';

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
      appBar: CustomAppBar(text: widget.titleString),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Text(widget.helpText,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                    )),
                const Spacer(),
                const SizedBox(height: 40)
              ],
            ),
            Text(widget.informationString),
            widget.mainContent,
            widget.subContentList,
            const SizedBox(height: 50)
          ],
        ),
      ),
    );
  }
}
