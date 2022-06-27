import 'package:bside/shared/custom_color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../shared/custom_text.dart';
import 'avatar.dart';

// https://www.youtube.com/watch?v=WgJ6TzNswEo
class ChattingPage extends StatefulWidget {
  ChattingPage({Key? key}) : super(key: key);

  @override
  State<ChattingPage> createState() => _ChattingPageState();
}

class _ChattingPageState extends State<ChattingPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        width: Get.width,
        height: Get.height * 0.5,
        color: customColor[ColorType.white],
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 35),
                physics: const BouncingScrollPhysics(),
                children: [
                  _itemChat(
                    avatar: 'assets/images/logo.png',
                    myself: false,
                    message:
                        'Lorem Ipsum is simply dummy text of the printing and typesetting industry.',
                    time: '18:00',
                  ),
                  _itemChat(
                    myself: true,
                    message: 'Okey 🐣',
                    time: '18:00',
                  ),
                  _itemChat(
                    avatar: 'assets/images/logo.png',
                    myself: false,
                    message: 'It has survived not only five centuries, 😀',
                    time: '18:00',
                  ),
                  _itemChat(
                    myself: true,
                    message:
                        'Contrary to popular belief, Lorem Ipsum is not simply random text. 😎',
                    time: '18:00',
                  ),
                  _itemChat(
                    avatar: 'assets/images/logo.png',
                    myself: false,
                    message:
                        'The generated Lorem Ipsum is therefore always free from repetition, injected humour, or non-characteristic words etc.',
                    time: '18:00',
                  ),
                  _itemChat(
                    avatar: 'assets/images/logo.png',
                    myself: false,
                    message: '😅 😂 🤣',
                    time: '18:00',
                  ),
                ],
              ),
            ),
            _formChat(),
          ],
        ));
    ;
  }
}

Widget _itemChat({bool? myself, String? avatar, message, time}) {
  return Row(
    mainAxisAlignment:
        myself == true ? MainAxisAlignment.end : MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      avatar != null
          ? Avatar(
              image: avatar,
              size: 50,
            )
          : CustomText(
              text: time,
              typoType: TypoType.label,
            ),
      Flexible(
        child: Container(
          margin: const EdgeInsets.only(left: 10, right: 10, top: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color:
                myself == true ? Colors.indigo.shade100 : Colors.indigo.shade50,
            borderRadius: myself == true
                ? const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                  )
                : const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
          ),
          child: CustomText(
            text: message,
            typoType: TypoType.label,
          ),
        ),
      ),
      myself == false
          ? CustomText(
              text: time,
              typoType: TypoType.label,
            )
          : const SizedBox(),
    ],
  );
}

Widget _formChat() {
  return Container(
    height: 120,
    padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
    color: customColor[ColorType.white],
    child: TextField(
      decoration: InputDecoration(
        hintText: 'Type your message...',
        suffixIcon: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: customColor[ColorType.deepPurple]),
          padding: const EdgeInsets.all(14),
          child: Icon(
            Icons.send_rounded,
            color: customColor[ColorType.white],
            size: 28,
          ),
        ),
        filled: true,
        fillColor: customColor[ColorType.lightGrey],
        labelStyle: const TextStyle(fontSize: 12),
        contentPadding: const EdgeInsets.all(20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
        ),
      ),
    ),
  );
}
