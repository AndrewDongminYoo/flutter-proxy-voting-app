// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart' show Get, GetNavigation;

// 🌎 Project imports:
import '../../shared/shared.dart';
import '../../theme.dart';

class ScrollAppBody extends StatefulWidget {
  const ScrollAppBody({
    Key? key,
    required this.body,
    this.canGoBack = true,
    this.floatingButton,
    this.actions,
  }) : super(key: key);
  final Widget body;
  final bool canGoBack;
  final Widget? floatingButton;
  final Widget? actions;

  @override
  ScrollAppBodyState createState() => ScrollAppBodyState();
}

class ScrollAppBodyState extends State<ScrollAppBody> {
  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    const bsideImage = AssetImage('assets/images/bside_web.png');

    return Unfocused(
      child: WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            leadingWidth: 150,
            leading: Row(
              children: [
                SizedBox(
                  width: 35,
                  child: widget.canGoBack
                      ? IconButton(
                          onPressed: goBack,
                          icon: Icon(
                            Icons.arrow_back_ios,
                            color: customColor[ColorType.white],
                          ),
                        )
                      : null,
                ),
                const Image(
                  image: bsideImage,
                  width: 55,
                )
              ],
            ),
            // bottom: ProxyProgressIdicator(),
            backgroundColor: const Color(0xFF421C5E),
            actions: widget.actions != null ? [widget.actions!] : null,
          ),
          body: SizedBox(
            height: Get.height,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: bottom),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 0, 20),
                child: widget.body,
              ),
            ),
          ),
          floatingActionButton: widget.floatingButton,
        ),
      ),
    );
  }
}
