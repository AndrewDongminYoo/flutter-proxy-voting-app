// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// 🌎 Project imports:
import '../auth/auth.controller.dart';
import '../contact_us/contact_us.model.dart';
import '../shared/custom_text.dart';
import '../theme.dart';
import 'custom_card.dart';

const formFieldStyle = TextStyle(
  letterSpacing: 2.0,
  fontSize: 20,
  fontWeight: FontWeight.w900,
);

class CustomFloatingButton extends StatefulWidget {
  const CustomFloatingButton({Key? key}) : super(key: key);

  @override
  State<CustomFloatingButton> createState() => _CustomFloatingButtonState();
}

class _CustomFloatingButtonState extends State<CustomFloatingButton> {
  bool hasNew = false;
  bool isOpend = false;
  AuthController authCtrl = Get.isRegistered<AuthController>()
      ? Get.find()
      : Get.put(AuthController());

  @override
  void initState() {
    super.initState();
    authCtrl.getChat();
    // TODO: 메세지를 확인하여 hasNew 갱신 여부 결정
  }

  onPressed() async {
    setState(() {
      hasNew = false;
      isOpend = true;
    });
    await Get.dialog(const ChatScreen());
    setState(() {
      isOpend = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: customColor[ColorType.yellow],
      child: isOpend
          ? const Icon(Icons.close_outlined)
          : const Icon(Icons.chat_rounded),
    );
  }
}

// Reference: https://github.com/flyerhq/flutter_chat_ui
class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _controller = ScrollController();
  AuthController authCtrl = Get.isRegistered<AuthController>()
      ? Get.find()
      : Get.put(AuthController());

  Widget _buildBsideChat(Chat chat) {
    return Container(
      margin: const EdgeInsets.only(top: 18),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              backgroundImage: AssetImage('assets/images/logo_only_b.png'),
              maxRadius: 16,
            ),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomCard(
                    child: CustomText(
                  text: chat.message,
                  typoType: TypoType.body,
                  colorType: ColorType.white,
                )),
                const SizedBox(height: 6),
                CustomText(
                    typoType: TypoType.label,
                    colorType: ColorType.black,
                    text: DateFormat('yyyy년 MM월 dd일 HH:mm').format(chat.time))
              ],
            )
          ]),
    );
  }

  Widget _buildUserChat(Chat chat) {
    return Container(
      margin: const EdgeInsets.only(top: 18),
      child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            CustomCard(
                bgColor: ColorType.orange,
                child: CustomText(
                  text: chat.message,
                  typoType: TypoType.body,
                  colorType: ColorType.white,
                )),
            const SizedBox(height: 6),
            CustomText(
                typoType: TypoType.label,
                colorType: ColorType.black,
                text: DateFormat('yyyy년 MM월 dd일 HH:mm').format(chat.time))
          ],
        )
      ]),
    );
  }

  Widget _buildChat(Chat chat, index) {
    if (index % 2 == 0) {
      return _buildBsideChat(chat);
    }
    return _buildUserChat(chat);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Container(
            width: Get.width,
            height: Get.height * 0.7,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
                color: customColor[ColorType.white],
                border: Border.all(
                    width: 2, color: customColor[ColorType.deepPurple]!),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x0000004D),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3))
                ]),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                      shrinkWrap: true,
                      controller: _controller,
                      itemCount: authCtrl.chats.length,
                      padding: const EdgeInsets.only(bottom: 100),
                      itemBuilder: (BuildContext context, int index) {
                        return _buildChat(authCtrl.chats[index], index);
                      }),
                ),
                TextFormField(
                  autofocus: true,
                  style: formFieldStyle,
                )
              ],
            )),
      ),
    );
  }
}
