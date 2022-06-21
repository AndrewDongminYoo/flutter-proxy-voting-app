import 'package:flutter/material.dart';

import 'agenda.model.dart';
import 'campaign.model.dart';

final campaigns = <Campaign>[
  Campaign(
      companyName: '에스엠',
      moderator: '얼라인파트너스',
      date: '22년 3월 31일',
      color: Colors.deepPurpleAccent,
      slogan: '에스엠, 저평가 해소를 위한 첫 걸음',
      youtubeUrl: 'ic1BKge_d8s',
      agendaList: smAgendaList,
      status: '종료',
      backgroundImg: 'assets/images/home_back_sm.png',
      logoImg:
          'https://ww.namu.la/s/787256d0ed159737f315038b38e92a6c936c1be03f864489cde02c98863b24e8c7f44635ae2bf8e9a6be332f38025bfb305fc22e2fef3f9a467e7f6475f19fe867311767d935d57c26fd4e95c21a010e'),
  Campaign(
      companyName: '티엘아이',
      moderator: '턴어라운드 조합',
      date: '22년 7월 7일',
      color: Colors.deepOrangeAccent,
      slogan: "시스템반도체 전문 '주식회사 티엘아이' 의 주인은 창업주가 아닌 주주",
      youtubeUrl: '',
      agendaList: tliAgendaList,
      status: '준비중',
      backgroundImg: 'assets/images/home_back_tli.png',
      logoImg:
          'https://d2u3dcdbebyaiu.cloudfront.net/img/companyPage_kr/logo_8569.jpg'),
  Campaign(
      companyName: '사조산업',
      moderator: '소액주주연대',
      date: '22년 3월 24일',
      color: Colors.blue,
      slogan: '당신이 참치캔에 투자해도 수익이 없는 진짜 이유',
      youtubeUrl: 'fAjFO5sQeE4',
      agendaList: sajoAgendaList,
      status: '종료',
      backgroundImg: 'assets/images/home_back_sajo.png',
      logoImg:
          'http://res.heraldm.com/content/image/2021/06/01/20210601000254_0.jpg'),
];

const sajoAgendaList = [
  AgendaItem(
    section: "제1호 의안",
    agendaFrom: "이사회안",
    head: "재무제표 승인의 건, 이익잉여금 처분 계산서 제외",
    body: "이익잉여금 처분 계산서 제외",
  ),
  AgendaItem(
    section: "제1-2-1호 의안",
    agendaFrom: "이사회안",
    head: "이익잉여금처분계산서 승인의 건, 주당 300원 배당",
    body: "주당 300원 배당",
    defaultOption: -1,
  ),
  AgendaItem(
    section: "제1-2-2호 의안",
    agendaFrom: "주주제안",
    head: "이익잉여금처분계산서 승인의 건, 주당 1500원 배당",
    body: "주당 1500원 배당",
    defaultOption: 1,
  ),
  AgendaItem(
    section: "제2호 의안",
    agendaFrom: "이사회안",
    head: "이사 보수 한도액 승인의 건",
    body: "제51기 10억 -> 제52기 12억",
    defaultOption: -1,
  ),
];

const smAgendaList = [
  AgendaItem(
    section: "제1호 의안",
    agendaFrom: "이사회안",
    head: "제27기 재무제표 승인의 건",
    body: "배당금: 1주당 200원",
  ),
  AgendaItem(
      section: "제2호 의안",
      agendaFrom: "이사회안",
      head: "사외이사 이장우 선임의 건",
      body: "세부 내용이 없습니다.",
      defaultOption: -1),
  AgendaItem(
    section: "제3-1호 의안",
    agendaFrom: "이사회안",
    head: "감사 임기영 선임의 건",
    body: "감사위원은 1명만 찬성이 가능합니다.",
    defaultOption: -1,
  ),
  AgendaItem(
    section: "제3-2호 의안",
    agendaFrom: "주주제안",
    head: "감사 곽준호 선임의 건",
    body: "감사위원은 1명만 찬성이 가능합니다.",
    defaultOption: 1,
  ),
  AgendaItem(
    section: "제4호 의안",
    agendaFrom: "이사회안",
    head: "이사 보수한도 승인의 건",
    body: "최대 한도: 60억원",
  ),
  AgendaItem(
    section: "제5호 의안",
    agendaFrom: "이사회안",
    head: "감사 보수한도 승인의 건",
    body: "최대 한도: 2억원",
  ),
  AgendaItem(
      section: "제6호 의안",
      agendaFrom: "이사회안",
      head: "정관 일부 변경의 건 (철회)",
      defaultOption: 0),
  AgendaItem(
      section: "제7호 의안",
      agendaFrom: "이사회안",
      head: "사내이사 최정민 선임의 건",
      defaultOption: -1),
];

const tliAgendaList = [
  AgendaItem(
    section: "제1호 의안",
    agendaFrom: "김달수",
    head: "사내이사 김달수 선임의 건",
    body: "",
  ),
  AgendaItem(
      section: "제2호 의안",
      agendaFrom: "턴어라운드 조합",
      head: "사외이사 고영상 선임의 건",
      body: "",
      defaultOption: 1),
  AgendaItem(
    section: "제3호 의안",
    agendaFrom: "턴어라운드 조합",
    head: "사내이사 조상준 선임의 건",
    body: "",
    defaultOption: 1,
  ),
  AgendaItem(
    section: "제4호 의안",
    agendaFrom: "김달수",
    head: "사내이사 박우전 선임의 건",
    body: "",
    defaultOption: -1,
  ),
];
