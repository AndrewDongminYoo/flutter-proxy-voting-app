// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import '../theme.dart';
import '../auth/auth.controller.dart';
import '../contact_us/contact_us.model.dart';
import '../shared/custom_text.dart';

// https://www.youtube.com/watch?v=WgJ6TzNswEo
class ContactUsPage extends StatefulWidget {
  const ContactUsPage({Key? key}) : super(key: key);

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  final ScrollController _controller = ScrollController();
  final AuthController _authCtrl = AuthController.get();

  _updateChatList() {
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
              itemCount: _authCtrl.chats.length,
              itemBuilder: (BuildContext context, int index) {
                return _itemChat(_authCtrl.chats[index]);
              },
            ),
          ),
          FormChat(
            updateChatList: _updateChatList,
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
  final TextEditingController _chatController = TextEditingController();
  final AuthController _authCtrl = AuthController.get();

  _onTap() {
    if (_chatController.text != '') {
      _authCtrl.contactUs(_chatController.text);
      _chatController.value = const TextEditingValue(text: '');
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
        controller: _chatController,
        decoration: InputDecoration(
          hintText: '문의사항을 남겨주세요',
          suffixIcon: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: customColor[ColorType.deepPurple]),
              padding: const EdgeInsets.all(14),
              child: InkWell(
                  onTap: _onTap,
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
