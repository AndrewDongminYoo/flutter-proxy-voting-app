import 'package:flutter/material.dart';

import 'agenda.model.dart';
import 'campaign.model.dart';

final campaigns = <Campaign>[
  Campaign(
      koName: '에스엠',
      enName: 'sm',
      moderator: '얼라인파트너스',
      date: '22년 3월 31일',
      color: const Color(0xFFEC9296),
      slogan: '저평가 해소를 위한 첫 걸음',
      details:
          '주주제안 감사 선임에 유효의결권 중 81%의 압도적인 찬성표를 주시는 등 당사의 예상을 훨씬 뛰어넘는 많은 주주분들의 뜨거운 지지에 깊이 감사드리면서, 한편으로는 무거운 책임감을 느낍니다. 당사는 장기 투자자이자 적극적 관여를 통한 가치창출을 추구하는 운용사로서 앞으로 에스엠 경영진과 지속적으로 소통하면서 에스엠에 실질적 변화가 있을수 있도록 끈질기게 치밀하게 실행해 나가겠습니다.',
      youtubeUrl: 'ic1BKge_d8s',
      agendaList: smAgendaList,
      status: '종료',
      dartUrl: 'https://dart.fss.or.kr/dsaf001/main.do?rcpNo=20220325000498',
      backgroundImg: 'assets/images/home_back_sm.png',
      logoImg:
          'https://ww.namu.la/s/787256d0ed159737f315038b38e92a6c936c1be03f864489cde02c98863b24e8c7f44635ae2bf8e9a6be332f38025bfb305fc22e2fef3f9a467e7f6475f19fe867311767d935d57c26fd4e95c21a010e'),
  Campaign(
      koName: '티엘아이',
      enName: 'tli',
      moderator: '턴어라운드 조합',
      date: '22년 7월 7일',
      color: const Color(0xFFE5657F),
      slogan: "시스템반도체 전문\n'주식회사 티엘아이'의\n주인은 창업주가 아닌 주주",
      details:
          '정기주주 총회에서 창업주의 재선임을 부결시켰음에도 불구하고, 또 다시 임시 주주총회에서 창업주와 분쟁을 하게 되었습니다. 이번 임시 주주총회에서도 주주 여러분들의 도움으로 반드시 승리할 것이며, 계속 지켜봐 주시고, 앞으로도 주주 여러분의 많은 관심과 성원 부탁드립니다.',
      youtubeUrl: '',
      agendaList: tliAgendaList,
      status: '더보기',
      dartUrl: 'https://dart.fss.or.kr/dsaf001/main.do?rcpNo=20220624000088',
      backgroundImg: 'assets/images/home_back_tli.png',
      logoImg:
          'https://d2u3dcdbebyaiu.cloudfront.net/img/companyPage_kr/logo_8569.jpg'),
  Campaign(
      koName: '사조산업',
      enName: 'sajo',
      moderator: '소액주주연대',
      date: '22년 3월 24일',
      color: const Color(0xFF85A8E9),
      slogan: '당신이 참치캔에 투자해도 수익이 없는 진짜 이유',
      details:
          '사조산업은 사조그룹의 지주사로, 사조대림, 사조요양, 사조씨푸드, 사조동아원의 상장 자회사를 비롯하여 20여개의 비상장 자회사를 통해 300억~500억의 순이익을 내는 아주 탄탄한 기업입니다.',
      youtubeUrl: 'fAjFO5sQeE4',
      agendaList: sajoAgendaList,
      status: '종료',
      backgroundImg: 'assets/images/home_back_sajo.png',
      dartUrl: 'https://dart.fss.or.kr/dsaf001/main.do?rcpNo=20220302000474',
      logoImg:
          'http://res.heraldm.com/content/image/2021/06/01/20210601000254_0.jpg'),
];

const sajoAgendaList = [
  AgendaItem(
    section: '제1호 의안',
    agendaFrom: '이사회안',
    head: '재무제표 승인의 건, 이익잉여금 처분 계산서 제외',
    body: '이익잉여금 처분 계산서 제외',
  ),
  AgendaItem(
    section: '제1-2-1호 의안',
    agendaFrom: '이사회안',
    head: '이익잉여금처분계산서 승인의 건, 주당 300원 배당',
    body: '주당 300원 배당',
    defaultOption: -1,
  ),
  AgendaItem(
    section: '제1-2-2호 의안',
    agendaFrom: '주주제안',
    head: '이익잉여금처분계산서 승인의 건, 주당 1500원 배당',
    body: '주당 1500원 배당',
    defaultOption: 1,
  ),
  AgendaItem(
    section: '제2호 의안',
    agendaFrom: '이사회안',
    head: '이사 보수 한도액 승인의 건',
    body: '제51기 10억 -> 제52기 12억',
    defaultOption: -1,
  ),
];

const smAgendaList = [
  AgendaItem(
    section: '제1호 의안',
    agendaFrom: '이사회안',
    head: '제27기 재무제표 승인의 건',
    body: '배당금: 1주당 200원',
  ),
  AgendaItem(
      section: '제2호 의안',
      agendaFrom: '이사회안',
      head: '사외이사 이장우 선임의 건',
      body: '세부 내용이 없습니다.',
      defaultOption: -1),
  AgendaItem(
    section: '제3-1호 의안',
    agendaFrom: '이사회안',
    head: '감사 임기영 선임의 건',
    body: '감사위원은 1명만 찬성이 가능합니다.',
    defaultOption: -1,
  ),
  AgendaItem(
    section: '제3-2호 의안',
    agendaFrom: '주주제안',
    head: '감사 곽준호 선임의 건',
    body: '감사위원은 1명만 찬성이 가능합니다.',
    defaultOption: 1,
  ),
  AgendaItem(
    section: '제4호 의안',
    agendaFrom: '이사회안',
    head: '이사 보수한도 승인의 건',
    body: '최대 한도: 60억원',
  ),
  AgendaItem(
    section: '제5호 의안',
    agendaFrom: '이사회안',
    head: '감사 보수한도 승인의 건',
    body: '최대 한도: 2억원',
  ),
  AgendaItem(
      section: '제6호 의안',
      agendaFrom: '이사회안',
      head: '정관 일부 변경의 건 (철회)',
      defaultOption: 0),
  AgendaItem(
      section: '제7호 의안',
      agendaFrom: '이사회안',
      head: '사내이사 최정민 선임의 건',
      defaultOption: -1),
];

const tliAgendaList = [
  AgendaItem(
      section: '제1호 의안',
      agendaFrom: '김달수',
      head: '사내이사 김달수 선임의 건',
      body: '',
      defaultOption: -1),
  AgendaItem(
      section: '제2호 의안',
      agendaFrom: '턴어라운드 조합',
      head: '사외이사 고영상 선임의 건',
      body: '',
      defaultOption: 1),
  AgendaItem(
    section: '제3호 의안',
    agendaFrom: '턴어라운드 조합',
    head: '사내이사 조상준 선임의 건',
    body: '',
    defaultOption: 1,
  ),
  AgendaItem(
    section: '제4호 의안',
    agendaFrom: '김달수',
    head: '사내이사 박우전 선임의 건',
    body: '',
    defaultOption: -1,
  ),
];
