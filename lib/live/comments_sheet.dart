// 🎯 Dart imports:
import 'dart:async' show Future;

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart' show DateFormat;

// 🌎 Project imports:
import '../shared/custom_text.dart';
import '../theme.dart';
import '../utils/firebase.dart';
import 'widget/widget.dart';

class CommentsSheet extends StatefulWidget {
  final String name;
  const CommentsSheet({Key? key, required this.name}) : super(key: key);

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
  late FocusNode _commentFocusNode;
  final TextEditingController _commentsController = TextEditingController();
  final Query _commentStream = liveRef
      .doc('sm')
      .collection('chat')
      .limit(10)
      .orderBy('createdAt', descending: true);

  @override
  void initState() {
    super.initState();
    _commentFocusNode = FocusNode();
  }

  // 폼이 삭제될 때 호출
  @override
  void dispose() {
    _commentFocusNode.dispose();
    super.dispose();
  }

  Future<void> _addComment() async {
    var ref = liveRef.doc('sm').collection('chat').doc();
    ref.set({
      'id': ref.id,
      'author': widget.name,
      'comment': _commentsController.text.trim(),
      'createdAt': DateTime.now(),
      'favoriteCount': 0,
    });
    liveRef.doc('sm').update({
      'recentComment': _commentsController.text.trim(),
    });
  }

  String _readTimestamp(Timestamp ts) => DateFormat.jm().format(ts.toDate());

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          _commentsController.clear();
        },
        child: Container(
            height: 400,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
            ),
            child: SingleChildScrollView(
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(children: [
                      Container(
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.only(
                          bottom: 25,
                        ),
                        child: Container(
                          height: 7,
                          width: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey[350],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 300,
                        child: PaginateFirestore(
                          query: _commentStream,
                          isLive: true,
                          reverse: true,
                          itemBuilder: (BuildContext context, snapshot, index) {
                            final data = snapshot[index].data() as Map?;
                            return Container(
                              //   height: 100,
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Color(0xFFF4F4F7),
                                    width: 5,
                                  ),
                                ),
                              ),
                              padding:
                                  const EdgeInsets.only(top: 5.0, bottom: 5.0),
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  CustomText(
                                    text:
                                        '${data!['nickname'] ?? data['author']}: ',
                                    typoType: TypoType.body,
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: CustomText(
                                      text: data['comment'].toString(),
                                    ),
                                  ),
                                  CustomText(
                                    text: _readTimestamp(data['createdAt']),
                                    typoType: TypoType.label,
                                  )
                                ],
                              ),
                            );
                          },
                          itemBuilderType: PaginateBuilderType.listView,
                        ),
                      ),
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CustomText(
                              text: '${widget.name} :',
                              typoType: TypoType.body,
                            ),
                            Expanded(
                              flex: 4,
                              child: Container(
                                padding:
                                    const EdgeInsets.only(top: 0.0, left: 10),
                                decoration: const BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                  color: Color(0xFFE0E0E0),
                                ))),
                                child: TextField(
                                  maxLines: 1,
                                  controller: _commentsController,
                                  autofocus: true,
                                  focusNode: _commentFocusNode,
                                  enableInteractiveSelection: false,
                                  onChanged: (_) {
                                    setState(() {});
                                  },
                                  cursorColor:
                                      customColor[ColorType.deepPurple],
                                  keyboardType: TextInputType.multiline,
                                  textInputAction: TextInputAction.send,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.never,
                                    hintText: '채팅을 남겨주세요',
                                    hintStyle: TextStyle(fontSize: 14),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                                onTap: _commentsController.text.isEmpty
                                    ? null
                                    : () async {
                                        await _addComment().then(
                                          (value) =>
                                              _commentsController.clear(),
                                        );
                                      },
                                child: Container(
                                    alignment: Alignment.center,
                                    height: 36,
                                    width: 36,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: customColor[ColorType.deepPurple],
                                      boxShadow: const [
                                        BoxShadow(
                                          offset: Offset(0, 2),
                                          blurRadius: 3,
                                          color: Color(0x28000000),
                                        )
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.send,
                                      size: 20.0,
                                      color: Colors.white,
                                    )))
                          ])
                    ])))));
  }
}
