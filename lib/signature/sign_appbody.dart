// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import '../shared/custom_appbar.dart';
import '../shared/custom_text.dart';

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
                CustomText(
                  text: widget.helpText,
                  typoType: TypoType.h1Bold,
                  textAlign: TextAlign.left,
                ),
                const Spacer(),
                const SizedBox(height: 40)
              ],
            ),
            CustomText(
              text: widget.informationString,
              typoType: TypoType.body,
              textAlign: TextAlign.left,
            ),
            widget.mainContent,
            widget.subContentList,
            const SizedBox(height: 50)
          ],
        ),
      ),
    );
  }
}
