// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import '../../campaign/agenda.model.dart';
import '../vote.model.dart';

final voteButtonList = [
  VoteButton(
      bgColor: Colors.deepPurple,
      borderColor: Colors.deepPurple,
      textColor: Colors.white,
      label: '찬성',
      value: VoteType.agree),
  VoteButton(
      bgColor: Colors.deepOrange,
      borderColor: Colors.deepOrange,
      textColor: Colors.white,
      label: '반대',
      value: VoteType.disagree),
  VoteButton(
      bgColor: Colors.white,
      borderColor: Colors.deepPurple,
      textColor: Colors.black,
      label: '기권',
      value: VoteType.abstention),
];

final noneButton = VoteButton(
    bgColor: Colors.white,
    borderColor: Colors.deepPurple,
    textColor: Colors.black,
    label: '미선택',
    value: VoteType.none);

class VoteSelector extends StatefulWidget {
  const VoteSelector({
    Key? key,
    required this.agendaItem,
    required this.index,
    required this.onVote,
    this.initialValue = VoteType.none,
  }) : super(key: key);
  final AgendaItem agendaItem;
  final int index;
  final void Function(int, VoteType) onVote;
  final VoteType initialValue;

  @override
  State<VoteSelector> createState() => _VoteSelectorState();
}

class _VoteSelectorState extends State<VoteSelector> {
  VoteButton curButton = noneButton;

  onSelected(VoteButton selected) {
    if (mounted) {
      setState(() {
        curButton = selected;
      });
    }
    widget.onVote(widget.index, selected.value);
  }

  @override
  void initState() {
    super.initState();
    switch (widget.initialValue) {
      case VoteType.agree:
        curButton = voteButtonList[0];
        break;
      case VoteType.disagree:
        curButton = voteButtonList[1];
        break;
      case VoteType.abstention:
        curButton = voteButtonList[2];
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 8.0,
        ),
        child: Column(children: [
          ListTile(
            title: Text(widget.agendaItem.section),
            subtitle: Text(widget.agendaItem.head),
            trailing: TextButton(
              onPressed: () => {},
              child: Text(
                widget.agendaItem.agendaFrom,
              ),
            ),
          ),
          Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFFF4F4F4),
                borderRadius: BorderRadius.all(
                  Radius.circular(24.0),
                ),
              ),
              child: Stack(children: [
                voteSelectorGroup(onSelected),
                selectedLabel(curButton)
              ]))
        ]),
      ),
    );
  }
}

Widget voteSelectorGroup(void Function(VoteButton) setValue) {
  return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: voteButtonList.map((item) {
        return Expanded(
          child: GestureDetector(
              onTap: () => setValue(item),
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text(
                  item.label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              )),
        );
      }).toList());
}

Widget selectedLabel(VoteButton button) {
  if (button.value == VoteType.none) {
    return Container();
  }

  var alignment = Alignment(button.value.value.toDouble(), 1);

  return SizedBox(
    width: Get.width,
    child: AnimatedAlign(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
      alignment: alignment,
      child: Material(
        elevation: 5,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          width: Get.width / 4,
          height: 32,
          decoration: BoxDecoration(
              border: Border.all(color: button.borderColor),
              borderRadius: BorderRadius.circular(30),
              color: button.bgColor),
          child: Center(
            child: Text(
              button.label,
              style: TextStyle(fontSize: 16, color: button.textColor),
            ),
          ),
        ),
      ),
    ),
  );
}
