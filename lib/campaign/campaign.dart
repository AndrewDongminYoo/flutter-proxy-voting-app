import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'campaign.controller.dart';
import 'campaign.model.dart';

class CampaignPage extends StatefulWidget {
  const CampaignPage({Key? key}) : super(key: key);

  @override
  State<CampaignPage> createState() => _CampaignPageState();
}

class _CampaignPageState extends State<CampaignPage> {
  goBack() {
    Get.back();
  }

  final CampaignController _controller = Get.isRegistered<CampaignController>()
      ? Get.find()
      : Get.put(CampaignController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: const Color(0xFF5E3F74),
          elevation: 0,
          leading: IconButton(
            tooltip: "뒤로가기",
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white),
            onPressed: goBack,
          )),
      body: Stack(fit: StackFit.expand, children: [
        gradientLayer(),
        SizedBox(
          height: Get.height,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  campaignHeader(_controller.campaign),
                  campaignInfoInRow(_controller.campaign),
                  campaignAgendaList(_controller.campaign),
                ],
              ),
            ),
          ),
        )
      ]),
    );
  }
}

Widget gradientLayer() {
  return Positioned.fill(
      child: Container(
    width: Get.width,
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF5E3F74),
          Color(0xFF82A5E1),
        ],
      ),
    ),
  ));
}

Widget campaignHeader(Campaign campaign) {
  return Row(
    children: [
      Expanded(
        child: Text(
          campaign.slogan,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      CircleAvatar(
          backgroundImage: NetworkImage(campaign.logoImg),
          backgroundColor: Colors.white,
          radius: 25)
    ],
  );
}

Widget campaignInfoInRow(Campaign campaign) {
  final actionMenuList = <ActionMenu>[
    ActionMenu(
        icon: Icons.book_rounded,
        color: Colors.deepOrange,
        label: '전자위임',
        onTap: () {
          Get.toNamed('/vote');
        }),
    ActionMenu(
        icon: Icons.group_add_rounded,
        color: Colors.deepPurple,
        label: '라운지',
        onTap: () {}),
    ActionMenu(
        icon: Icons.attach_file_rounded,
        color: Colors.deepPurple,
        label: '공시서류',
        onTap: () {}),
    ActionMenu(
        icon: Icons.history_rounded,
        color: Colors.deepPurple,
        label: '이전기록',
        onTap: () {}),
  ];

  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(campaign.companyName,
          style: const TextStyle(color: Colors.white, fontSize: 18)),
      Text("${campaign.moderator} | 주주총회 일정: ${campaign.date}",
          style: const TextStyle(color: Colors.white, fontSize: 16)),
      SizedBox(
        height: 72,
        child: ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: actionMenuList.length + 1,
            itemBuilder: (BuildContext context, int index) => index == 0
                ? const SizedBox(
                    width: 41,
                  )
                : iconButton(actionMenuList[index - 1])),
      ),
      const SizedBox(height: 20),
      const Text('캠페인 설명', style: TextStyle(color: Colors.white, fontSize: 16))
    ],
  );
}

Widget iconButton(ActionMenu actionMenu) {
  return InkWell(
    onTap: actionMenu.onTap,
    child: Container(
      width: 82,
      height: 72,
      margin: const EdgeInsets.only(right: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(
          actionMenu.icon,
          color: actionMenu.color,
        ),
        Text(actionMenu.label)
      ]),
    ),
  );
}

Widget campaignAgendaList(Campaign campaign) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('주주총회 의안',
          style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              height: 2)),
      Column(
          children: campaign.agendaList.map((item) {
        return Card(
          child: ListTile(
            title: Text(item.section),
            subtitle: Text(item.head),
            trailing:
                TextButton(onPressed: () => {}, child: Text(item.agendaFrom)),
          ),
        );
      }).toList())
    ],
  );
}
