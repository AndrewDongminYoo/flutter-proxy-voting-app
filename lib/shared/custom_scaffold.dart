import 'package:flutter/material.dart';

class CutomScaffold extends StatefulWidget {
  const CutomScaffold({Key? key}) : super(key: key);

  @override
  State<CutomScaffold> createState() => _CutomScaffoldState();
}

class _CutomScaffoldState extends State<CutomScaffold> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(),
          SliverToBoxAdapter(),
        ],
      ),
    );
  }
}
