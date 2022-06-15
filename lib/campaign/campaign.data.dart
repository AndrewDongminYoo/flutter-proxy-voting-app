import 'package:flutter/material.dart';

import 'campaign.model.dart';

final campaigns = <Campaign>[
  Campaign(
      companyName: '에스엠',
      moderator: '얼라인파트너스',
      date: '22년 3월',
      color: Colors.deepPurpleAccent,
      slogan: '에스엠, 저평가 해소를 위한 첫 걸음',
      backgroundImg:
          'https://economist.co.kr/data/photo/202202/04/25d75cbd-4555-4cfe-ae1e-537b660c478c.jpg',
      logoImg:
          'https://ww.namu.la/s/787256d0ed159737f315038b38e92a6c936c1be03f864489cde02c98863b24e8c7f44635ae2bf8e9a6be332f38025bfb305fc22e2fef3f9a467e7f6475f19fe867311767d935d57c26fd4e95c21a010e'),
  Campaign(
      companyName: '사조산업',
      moderator: '소액주주연대',
      date: '22년 3월',
      color: Colors.blue,
      slogan: '당신이 참치캔에 투자해도 수익이 없는 진짜 이유',
      backgroundImg:
          'https://www.sisajournal.com/news/photo/202103/214628_122327_2652.png',
      logoImg:
          'http://res.heraldm.com/content/image/2021/06/01/20210601000254_0.jpg'),
  Campaign(
      companyName: '티엘아이',
      moderator: '소액주주연대',
      date: '22년 7월 7일',
      color: Colors.deepOrangeAccent,
      slogan: '티엘아이 슬로건',
      backgroundImg:
          'https://img.etnews.com/photonews/0910/091028061936_801060011_b.jpg',
      logoImg:
          'https://d2u3dcdbebyaiu.cloudfront.net/img/companyPage_kr/logo_8569.jpg'),
];
