import '../chatting/chatting.model.dart';
import '../shared/custom_color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../auth/auth.controller.dart';
import '../shared/custom_text.dart';
import 'avatar.dart';

// https://www.youtube.com/watch?v=WgJ6TzNswEo
class ChattingPage extends StatefulWidget {
  const ChattingPage({Key? key}) : super(key: key);

  @override
  State<ChattingPage> createState() => _ChattingPageState();
}

class _ChattingPageState extends State<ChattingPage> {
  final ScrollController _controller = ScrollController();
  AuthController authCtrl = Get.isRegistered<AuthController>()
      ? Get.find()
      : Get.put(AuthController());

  // FIXME: 스크롤이 끝까지 내려가지 않고 직전 아이템에서 멈춤
  updateChatList() {
    setState(() {
      _controller.animateTo(
        _controller.position.maxScrollExtent,
        duration: const Duration(seconds: 1),
        curve: Curves.fastOutSlowIn,
      );
    });
  }

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
            child: ListView.builder(
              controller: _controller,
              shrinkWrap: true,
              itemCount: authCtrl.chats.length,
              itemBuilder: (BuildContext context, int index) {
                return _itemChat(authCtrl.chats[index]);
              },
            ),
          ),
          FormChat(
            updateChatList: updateChatList,
          ),
        ],
      ),
    );
  }
}

Widget _itemChat(Chat chat) {
  return Row(
    mainAxisAlignment:
        chat.myself == true ? MainAxisAlignment.end : MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Avatar(
        image: chat.avatar,
        size: 50,
      ),
      Flexible(
        child: Container(
          margin: const EdgeInsets.only(left: 10, right: 10, top: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: chat.myself == true
                ? Colors.indigo.shade100
                : Colors.indigo.shade50,
            borderRadius: chat.myself == true
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
            text: chat.message,
            typoType: TypoType.label,
          ),
        ),
      ),
      chat.myself == false
          ? CustomText(
              text: chat.time.toString(),
              typoType: TypoType.label,
            )
          : const SizedBox(),
    ],
  );
}

class FormChat extends StatefulWidget {
  final Function() updateChatList;

  const FormChat({
    Key? key,
    required this.updateChatList,
  }) : super(key: key);

  @override
  State<FormChat> createState() => _FormChatState();
}

class _FormChatState extends State<FormChat> {
  TextEditingController chatController = TextEditingController();
  AuthController authCtrl = Get.isRegistered<AuthController>()
      ? Get.find()
      : Get.put(AuthController());

  onTap() {
    if (chatController.text != '') {
      authCtrl.addChat(chatController.text);
      chatController.value = const TextEditingValue(text: '');
      widget.updateChatList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height * 0.14,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      color: customColor[ColorType.white],
      child: TextField(
        controller: chatController,
        decoration: InputDecoration(
          hintText: 'Type your message...',
          suffixIcon: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: customColor[ColorType.deepPurple]),
              padding: const EdgeInsets.all(14),
              child: InkWell(
                  onTap: onTap,
                  child: Icon(
                    Icons.send_rounded,
                    color: customColor[ColorType.white],
                    size: 28,
                  ))),
          filled: true,
          fillColor: customColor[ColorType.lightGrey],
          labelStyle: const TextStyle(fontSize: 12),
          contentPadding: const EdgeInsets.all(20),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(40),
          ),
        ),
      ),
    );
  }
}
