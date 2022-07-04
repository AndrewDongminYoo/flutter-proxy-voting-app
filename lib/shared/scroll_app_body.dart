// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import '../theme.dart';
import 'unfocused.dart';

class ScrollAppBody extends StatefulWidget {
  const ScrollAppBody(
      {Key? key,
      required this.body,
      this.canGoBack = true,
      this.floatingButton,
      this.actions})
      : super(key: key);
  final Widget body;
  final bool canGoBack;
  final Widget? floatingButton;
  final Widget? actions;

  @override
  // ignore: library_private_types_in_public_api
  _ScrollAppBodyState createState() => _ScrollAppBodyState();
}

class _ScrollAppBodyState extends State<ScrollAppBody> {
  onPress() async {
    // FirebaseAnalytics.instance.logEvent(name: 'email-subscription');
    // await launch("https://page.stibee.com/subscriptions/147053");
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

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
                          onPressed: () {
                            Get.back();
                          },
                          icon: Icon(
                            Icons.arrow_back_ios,
                            color: customColor[ColorType.white],
                          ),
                        )
                      : null,
                ),
                const Image(
                    image: AssetImage('assets/images/bside_web.png'), width: 55)
              ],
            ),
            // bottom: ProxyProgressIdicator(),
            backgroundColor: const Color.fromARGB(255, 66, 28, 94),
            actions: widget.actions != null ? [widget.actions!] : null,
          ),
          body: SizedBox(
            height: Get.height,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: bottom),
              child: Padding(
                padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
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
