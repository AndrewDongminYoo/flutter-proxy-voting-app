import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'custom_appbar.dart';

class CustomScaffold extends StatelessWidget {
  final Widget body;
  final String title;
  final Color appBarColor;
  const CustomScaffold({
    Key? key,
    required this.body,
    required this.title,
    this.appBarColor = const Color(0xFF572E67),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(title: title, bgColor: appBarColor),
        body: Container(
            height: Get.height,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(child: body)));
  }
}
