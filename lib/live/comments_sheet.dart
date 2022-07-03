import 'dart:async';

import 'package:bside/live/firebase.dart';
import 'package:bside/shared/custom_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:paginate_firestore/paginate_firestore.dart';

import '../theme.dart';

class CommentsSheet extends StatefulWidget {
  final String name;
  const CommentsSheet({Key? key, required this.name}) : super(key: key);

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
  late FocusNode commentFocusNode;
  TextEditingController commentsController = TextEditingController();
  final Query commentStream = liveRef
      .doc('sm')
      .collection('chat')
      .limit(10)
      .orderBy('createdAt', descending: true);

  @override
  void initState() {
    super.initState();
    commentFocusNode = FocusNode();
  }

  // 폼이 삭제될 때 호출
  @override
  void dispose() {
    commentFocusNode.dispose();
    super.dispose();
  }

  Future<void> addComment() async {
    var ref = liveRef.doc('sm').collection('chat').doc();
    ref.set({
      'id': ref.id,
      'author': widget.name,
      'comment': commentsController.text.trim(),
      'createdAt': DateTime.now(),
      'favoriteCount': 0,
    });
    liveRef.doc('sm').update({'recentComment': commentsController.text.trim()});
  }

  String readTimestamp(Timestamp timestamp) {
    return DateFormat.jm().format(timestamp.toDate());
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        commentsController.clear();
      },
      child: Container(
        height: 400,
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0))),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
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
                        borderRadius: BorderRadius.circular(4)),
                  ),
                ),
                SizedBox(
                  height: 300,
                  child: PaginateFirestore(
                    query: commentStream,
                    isLive: true,
                    reverse: true,
                    itemBuilder: (BuildContext context, snapshot, index) {
                      final data = snapshot[index].data() as Map?;
                      DateTime time =
                          (data!['createdAt'] as Timestamp).toDate();
                      return Container(
                        //   height: 100,
                        decoration: const BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    color: Color(0xFFF4F4F7), width: 5))),
                        padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child:
                            //   Text(data.toString()),
                            Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomText(
                              text: '${data['nickname'] ?? data['author']}: ',
                              typoType: TypoType.body,
                            ),
                            Expanded(
                                flex: 4,
                                child: Text(data['comment'].toString())),
                            Text(
                              readTimestamp(data['createdAt']),
                              style: TextStyle(
                                  color: customColor[ColorType.black],
                                  fontSize: 12),
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
                        padding: const EdgeInsets.only(top: 0.0, left: 10),
                        decoration: const BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                          color: Color.fromRGBO(224, 224, 224, 1),
                        ))),
                        child: TextField(
                            maxLines: 1,
                            controller: commentsController,
                            autofocus: true,
                            focusNode: commentFocusNode,
                            enableInteractiveSelection: false,
                            onChanged: (_) {
                              setState(() {});
                            },
                            cursorColor: customColor[ColorType.deepPurple],
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
                                hintStyle: TextStyle(fontSize: 14))),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                        onTap: commentsController.text.isEmpty
                            ? null
                            : () async {
                                await addComment().then(
                                    (value) => commentsController.clear());
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
                                    color: Color.fromRGBO(0, 0, 0, .16))
                              ],
                            ),
                            child: const Icon(
                              Icons.send,
                              size: 20.0,
                              color: Colors.white,
                            ))),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
