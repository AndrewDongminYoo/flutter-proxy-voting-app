import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:signature/signature.dart';
import 'package:get/get.dart';

class SignaturePage extends StatefulWidget {
  const SignaturePage({Key? key}) : super(key: key);

  @override
  State<SignaturePage> createState() => _SignaturePageState();
}

class _SignaturePageState extends State<SignaturePage> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.deepPurpleAccent.shade100,
  );

  final LottieBuilder lottie = Lottie.network(
    'https://assets9.lottiefiles.com/packages/lf20_vaqzminx.json',
    width: Get.width,
    height: 300,
  );

  bool showLottie = true;
  onTap() {
    setState(() {
      showLottie = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Signature',
      color: Colors.white,
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: Scaffold(
        appBar: AppBar(
            leading: IconButton(
              icon: const Icon(IconData(0xf05bc, fontFamily: 'MaterialIcons')),
              onPressed: () => Get.back(),
            ),
            title: const Text('전자서명'),
            backgroundColor: const Color(0xFF572E67),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_rounded),
                onPressed: () {},
              )
            ]),
        body: Column(children: [
          Container(
            margin: const EdgeInsets.all(15),
            alignment: Alignment.topLeft,
            child: Column(
              children: [
                Row(
                  children: [
                    const Text('전자 서명을 등록해주세요.',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        )),
                    const Spacer(),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButtonTheme.of(context).style,
                      child: const Text('문의하기'),
                    ),
                  ],
                ),
                const Text(
                    '전자서명을 저장하고 다음에 간편하게 불러올 수 있어요.\n모든 개인정보는 안전하게 보관되며 지정된 용도 이외에 절대 사용되지 않습니다.')
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.deepOrange,
                width: 3,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadiusDirectional.circular(30),
            ),
            child: showLottie
                ? GestureDetector(
                    onTap: onTap,
                    child: lottie,
                  )
                : Signature(
                    controller: _controller,
                    backgroundColor: Colors.transparent,
                    width: Get.width,
                    height: 300,
                  ),
          ),
          // Container(
          //   padding: const EdgeInsets.all(10),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: [
          //       OutlinedButton(
          //         style: OutlinedButtonTheme.of(context).style,
          //         onPressed: () async {
          //           if (_controller.isNotEmpty) {
          //             final Uint8List? result = await _controller.toPngBytes();
          //             if (result != null) {
          //               await Navigator.of(context).push(MaterialPageRoute(
          //                 builder: (context) {
          //                   return Scaffold(
          //                     body: Center(
          //                       child: Image.memory(result),
          //                     ),
          //                   );
          //                 },
          //               ));
          //             }
          //           }
          //         },
          //         child: const Text('저장하기'),
          //       ),
          //       //CLEAR CANVAS
          //       OutlinedButton(
          //         style: OutlinedButtonTheme.of(context).style,
          //         onPressed: () {
          //           setState(() => _controller.clear());
          //         },
          //         child: const Text('다시쓰기'),
          //       ),
          //     ],
          //   ),
          // ),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              fixedSize: Size(Get.width - 30, 50),
              primary: Colors.deepOrange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              side: const BorderSide(
                color: Colors.deepOrange,
                width: 3,
              ),
            ),
            child: const Text(
              '서명 불러오기',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 10, 50, 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Row(
                  children: [
                    Checkbox(value: true, onChanged: (value) {}),
                    const Text('전자서명 저장에 동의합니다.'),
                  ],
                ),
                Row(
                  children: [
                    Checkbox(value: true, onChanged: (value) {}),
                    const Text('에스엠 측에 대한 기존 위임을 철회합니다.'),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              fixedSize: Size(Get.width - 30, 50),
              primary: Colors.purple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: () async {
              if (_controller.isNotEmpty) {
                final Uint8List? result = await _controller.toPngBytes();
                if (result != null) {
                  await Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) {
                      return Scaffold(
                        body: Center(
                          child: Image.memory(result),
                        ),
                      );
                    },
                  ));
                }
              }
            },
            child: const Text(
              '등록',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
