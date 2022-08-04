const stockTradingFirms = [
  {
    'id': 0,
    'module': 'secNHqv',
    'name': 'NH투자증권',
    'image':
        'https://s3.ap-northeast-2.amazonaws.com/lounge.bside.ai/logos/%E1%84%80%E1%85%B3%E1%86%B7%E1%84%8B%E1%85%B2%E1%86%BC%E1%84%8B%E1%85%A1%E1%84%8B%E1%85%B5%E1%84%8F%E1%85%A9%E1%86%AB_PNG_%E1%84%82%E1%85%A9%E1%86%BC%E1%84%92%E1%85%A7%E1%86%B8.png',
  },
  {
    'id': 1,
    'module': 'secDaishin',
    'name': '대신증권',
    'image':
        'https://s3.ap-northeast-2.amazonaws.com/lounge.bside.ai/logos/%E1%84%80%E1%85%B3%E1%86%B7%E1%84%8B%E1%85%B2%E1%86%BC%E1%84%8B%E1%85%A1%E1%84%8B%E1%85%B5%E1%84%8F%E1%85%A9%E1%86%AB_PNG_%E1%84%83%E1%85%A2%E1%84%89%E1%85%B5%E1%86%AB%E1%84%8C%E1%85%B3%E1%86%BC%E1%84%80%E1%85%AF%E1%86%AB.png',
  },
  {
    'id': 2,
    'module': 'secSamsung',
    'name': '삼성증권',
    'image':
        'https://s3.ap-northeast-2.amazonaws.com/lounge.bside.ai/logos/%E1%84%80%E1%85%B3%E1%86%B7%E1%84%8B%E1%85%B2%E1%86%BC%E1%84%8B%E1%85%A1%E1%84%8B%E1%85%B5%E1%84%8F%E1%85%A9%E1%86%AB_PNG_%E1%84%89%E1%85%A1%E1%86%B7%E1%84%89%E1%85%A5%E1%86%BC.png',
  },
  {
    'id': 3,
    'module': 'secMyasset',
    'name': '유안타증권',
    'image':
        'https://s3.ap-northeast-2.amazonaws.com/lounge.bside.ai/logos/%E1%84%80%E1%85%B3%E1%86%B7%E1%84%8B%E1%85%B2%E1%86%BC%E1%84%8B%E1%85%A1%E1%84%8B%E1%85%B5%E1%84%8F%E1%85%A9%E1%86%AB_PNG_%E1%84%8B%E1%85%B2%E1%84%8B%E1%85%A1%E1%86%AB%E1%84%90%E1%85%A1.png',
  },
  {
    'id': 4,
    'module': 'secHanaw',
    'name': '하나금융투자',
    'image':
        'https://s3.ap-northeast-2.amazonaws.com/lounge.bside.ai/logos/%E1%84%80%E1%85%B3%E1%86%B7%E1%84%8B%E1%85%B2%E1%86%BC%E1%84%8B%E1%85%A1%E1%84%8B%E1%85%B5%E1%84%8F%E1%85%A9%E1%86%AB_PNG_%E1%84%92%E1%85%A1%E1%84%82%E1%85%A1.png',
  },
  {
    'id': 5,
    'module': 'secKyobo',
    'name': '교보증권',
    'image':
        'https://s3.ap-northeast-2.amazonaws.com/lounge.bside.ai/logos/%E1%84%80%E1%85%B3%E1%86%B7%E1%84%8B%E1%85%B2%E1%86%BC%E1%84%8B%E1%85%A1%E1%84%8B%E1%85%B5%E1%84%8F%E1%85%A9%E1%86%AB_PNG_%E1%84%80%E1%85%AD%E1%84%87%E1%85%A9.png',
  },
  {
    'id': 6,
    'module': 'secImeritz',
    'name': '메리츠종금증권',
    'image':
        'https://s3.ap-northeast-2.amazonaws.com/lounge.bside.ai/logos/%E1%84%80%E1%85%B3%E1%86%B7%E1%84%8B%E1%85%B2%E1%86%BC%E1%84%8B%E1%85%A1%E1%84%8B%E1%85%B5%E1%84%8F%E1%85%A9%E1%86%AB_PNG_%E1%84%86%E1%85%A6%E1%84%85%E1%85%B5%E1%84%8E%E1%85%B3.png',
  },
  {
    'id': 7,
    'module': 'secCape',
    'name': '케이프투자증권',
    'image':
        'https://s3.ap-northeast-2.amazonaws.com/lounge.bside.ai/logos/%E1%84%80%E1%85%B3%E1%86%B7%E1%84%8B%E1%85%B2%E1%86%BC%E1%84%8B%E1%85%A1%E1%84%8B%E1%85%B5%E1%84%8F%E1%85%A9%E1%86%AB_PNG_%E1%84%8F%E1%85%A6%E1%84%8B%E1%85%B5%E1%84%91%E1%85%B3.jpeg',
  },
  {
    'id': 8,
    'module': 'secIbk',
    'name': 'IBK투자증권',
    'image':
        'https://s3.ap-northeast-2.amazonaws.com/lounge.bside.ai/logos/%E1%84%80%E1%85%B3%E1%86%B7%E1%84%8B%E1%85%B2%E1%86%BC%E1%84%8B%E1%85%A1%E1%84%8B%E1%85%B5%E1%84%8F%E1%85%A9%E1%86%AB_PNG_IBK.png',
  },
  {
    'id': 9,
    'module': 'secWoori',
    'name': '우리종합금융',
    'image':
        'https://s3.ap-northeast-2.amazonaws.com/lounge.bside.ai/logos/%E1%84%80%E1%85%B3%E1%86%B7%E1%84%8B%E1%85%B2%E1%86%BC%E1%84%8B%E1%85%A1%E1%84%8B%E1%85%B5%E1%84%8F%E1%85%A9%E1%86%AB_PNG_%E1%84%8B%E1%85%AE%E1%84%85%E1%85%B5.png',
  },
  {
    'id': 10,
    'module': 'secHi',
    'name': '하이투자증권',
    'image':
        'https://s3.ap-northeast-2.amazonaws.com/lounge.bside.ai/logos/%E1%84%80%E1%85%B3%E1%86%B7%E1%84%8B%E1%85%B2%E1%86%BC%E1%84%8B%E1%85%A1%E1%84%8B%E1%85%B5%E1%84%8F%E1%85%A9%E1%86%AB_PNG_DGB.png',
  },
  {
    'id': 11,
    'module': 'secHmc',
    'name': '현대차투자증권',
    'image':
        'https://s3.ap-northeast-2.amazonaws.com/lounge.bside.ai/logos/%E1%84%80%E1%85%B3%E1%86%B7%E1%84%8B%E1%85%B2%E1%86%BC%E1%84%8B%E1%85%A1%E1%84%8B%E1%85%B5%E1%84%8F%E1%85%A9%E1%86%AB_PNG_%E1%84%92%E1%85%A7%E1%86%AB%E1%84%83%E1%85%A2%E1%84%8E%E1%85%A1%E1%84%8C%E1%85%B3%E1%86%BC%E1%84%80%E1%85%AF%E1%86%AB.png',
  },
  {
    'id': 12,
    'module': 'secNamuh',
    'name': 'NH나무증권',
    'image':
        'https://s3.ap-northeast-2.amazonaws.com/lounge.bside.ai/logos/%E1%84%80%E1%85%B3%E1%86%B7%E1%84%8B%E1%85%B2%E1%86%BC%E1%84%8B%E1%85%A1%E1%84%8B%E1%85%B5%E1%84%8F%E1%85%A9%E1%86%AB_PNG_%E1%84%82%E1%85%A1%E1%84%86%E1%85%AE.png',
  },
  {
    'id': 13,
    'module': 'secFoss',
    'name': '포스증권',
    'image':
        'https://s3.ap-northeast-2.amazonaws.com/lounge.bside.ai/logos/%E1%84%80%E1%85%B3%E1%86%B7%E1%84%8B%E1%85%B2%E1%86%BC%E1%84%8B%E1%85%A1%E1%84%8B%E1%85%B5%E1%84%8F%E1%85%A9%E1%86%AB_PNG_%E1%84%92%E1%85%A1%E1%86%AB%E1%84%80%E1%85%AE%E1%86%A8%E1%84%91%E1%85%A9%E1%84%89%E1%85%B3.png',
  },
  {
    'id': 14,
    'module': 'secSKs',
    'name': 'SK증권',
    'image':
        'https://s3.ap-northeast-2.amazonaws.com/lounge.bside.ai/logos/%E1%84%80%E1%85%B3%E1%86%B7%E1%84%8B%E1%85%B2%E1%86%BC%E1%84%8B%E1%85%A1%E1%84%8B%E1%85%B5%E1%84%8F%E1%85%A9%E1%86%AB_PNG_SK.png',
  },
  {
    'id': 15,
    'module': 'secMirae',
    'name': '미래에셋증권',
    'image':
        'https://s3.ap-northeast-2.amazonaws.com/lounge.bside.ai/logos/%E1%84%80%E1%85%B3%E1%86%B7%E1%84%8B%E1%85%B2%E1%86%BC%E1%84%8B%E1%85%A1%E1%84%8B%E1%85%B5%E1%84%8F%E1%85%A9%E1%86%AB_PNG_%E1%84%86%E1%85%B5%E1%84%85%E1%85%A2%E1%84%8B%E1%85%A6%E1%84%89%E1%85%A6%E1%86%BA.png',
  },
  {
    'id': 16,
    'module': 'secShinhan',
    'name': '신한금융투자',
    'image':
        'https://s3.ap-northeast-2.amazonaws.com/lounge.bside.ai/logos/%E1%84%80%E1%85%B3%E1%86%B7%E1%84%8B%E1%85%B2%E1%86%BC%E1%84%8B%E1%85%A1%E1%84%8B%E1%85%B5%E1%84%8F%E1%85%A9%E1%86%AB_PNG_%E1%84%89%E1%85%B5%E1%86%AB%E1%84%92%E1%85%A1%E1%86%AB.png',
  },
  {
    'id': 17,
    'module': 'secKiwoom',
    'name': '키움증권',
    'image':
        'https://s3.ap-northeast-2.amazonaws.com/lounge.bside.ai/logos/%E1%84%80%E1%85%B3%E1%86%B7%E1%84%8B%E1%85%B2%E1%86%BC%E1%84%8B%E1%85%A1%E1%84%8B%E1%85%B5%E1%84%8F%E1%85%A9%E1%86%AB_PNG_%E1%84%8F%E1%85%B5%E1%84%8B%E1%85%AE%E1%86%B7.png',
  },
  {
    'id': 18,
    'module': 'secKB',
    'name': 'KB증권',
    'image':
        'https://s3.ap-northeast-2.amazonaws.com/lounge.bside.ai/logos/%E1%84%80%E1%85%B3%E1%86%B7%E1%84%8B%E1%85%B2%E1%86%BC%E1%84%8B%E1%85%A1%E1%84%8B%E1%85%B5%E1%84%8F%E1%85%A9%E1%86%AB_PNG_KB.png',
  },
  {
    'id': 19,
    'module': 'secDBfi',
    'name': 'DB금융투자증권',
    'image':
        'https://s3.ap-northeast-2.amazonaws.com/lounge.bside.ai/logos/%E1%84%80%E1%85%B3%E1%86%B7%E1%84%8B%E1%85%B2%E1%86%BC%E1%84%8B%E1%85%A1%E1%84%8B%E1%85%B5%E1%84%8F%E1%85%A9%E1%86%AB_PNG_DB.png',
  },
  {
    'id': 20,
    'module': 'secHanwhawm',
    'name': '한화투자증권',
    'image':
        'https://s3.ap-northeast-2.amazonaws.com/lounge.bside.ai/logos/%E1%84%80%E1%85%B3%E1%86%B7%E1%84%8B%E1%85%B2%E1%86%BC%E1%84%8B%E1%85%A1%E1%84%8B%E1%85%B5%E1%84%8F%E1%85%A9%E1%86%AB_PNG_%E1%84%92%E1%85%A1%E1%86%AB%E1%84%92%E1%85%AA.png',
  },
  {
    'id': 21,
    'module': 'secEugenefn',
    'name': '유진투자증권',
    'image':
        'https://s3.ap-northeast-2.amazonaws.com/lounge.bside.ai/logos/%E1%84%80%E1%85%B3%E1%86%B7%E1%84%8B%E1%85%B2%E1%86%BC%E1%84%8B%E1%85%A1%E1%84%8B%E1%85%B5%E1%84%8F%E1%85%A9%E1%86%AB_PNG_%E1%84%8B%E1%85%B2%E1%84%8C%E1%85%B5%E1%86%AB.png',
  },
  {
    'id': 22,
    'module': 'secKtb',
    'name': 'KTB투자증권',
    'image':
        'https://s3.ap-northeast-2.amazonaws.com/lounge.bside.ai/logos/%E1%84%80%E1%85%B3%E1%86%B7%E1%84%8B%E1%85%B2%E1%86%BC%E1%84%8B%E1%85%A1%E1%84%8B%E1%85%B5%E1%84%8F%E1%85%A9%E1%86%AB_PNG_KTB%E1%84%90%E1%85%AE%E1%84%8C%E1%85%A1%E1%84%8C%E1%85%B3%E1%86%BC%E1%84%80%E1%85%AF%E1%86%AB.png',
  },
  {
    'id': 23,
    'module': 'secEBest',
    'name': '이베스트투자',
    'image':
        'https://s3.ap-northeast-2.amazonaws.com/lounge.bside.ai/logos/%E1%84%80%E1%85%B3%E1%86%B7%E1%84%8B%E1%85%B2%E1%86%BC%E1%84%8B%E1%85%A1%E1%84%8B%E1%85%B5%E1%84%8F%E1%85%A9%E1%86%AB_PNG_%E1%84%8B%E1%85%B5%E1%84%87%E1%85%A6%E1%84%89%E1%85%B3%E1%84%90%E1%85%B3.png',
  },
  {
    'id': 24,
    'module': 'secKorea',
    'name': '한국투자증권',
    'image':
        'https://s3.ap-northeast-2.amazonaws.com/lounge.bside.ai/logos/%E1%84%80%E1%85%B3%E1%86%B7%E1%84%8B%E1%85%B2%E1%86%BC%E1%84%8B%E1%85%A1%E1%84%8B%E1%85%B5%E1%84%8F%E1%85%A9%E1%86%AB_PNG_%E1%84%92%E1%85%A1%E1%86%AB%E1%84%80%E1%85%AE%E1%86%A8%E1%84%90%E1%85%AE%E1%84%8C%E1%85%A1.png',
  },
  {
    'id': 25,
    'module': 'secShinyoung',
    'name': '신영증권',
    'image':
        'https://s3.ap-northeast-2.amazonaws.com/lounge.bside.ai/logos/%E1%84%80%E1%85%B3%E1%86%B7%E1%84%8B%E1%85%B2%E1%86%BC%E1%84%8B%E1%85%A1%E1%84%8B%E1%85%B5%E1%84%8F%E1%85%A9%E1%86%AB_PNG_%E1%84%89%E1%85%B5%E1%86%AB%E1%84%8B%E1%85%A7%E1%86%BC%E1%84%8C%E1%85%B3%E1%86%BC%E1%84%80%E1%85%AF%E1%86%AB.png',
  },
  {
    'id': 26,
    'module': 'secCreon',
    'name': '크레온증권',
    'image':
        'https://s3.ap-northeast-2.amazonaws.com/lounge.bside.ai/logos/%E1%84%80%E1%85%B3%E1%86%B7%E1%84%8B%E1%85%B2%E1%86%BC%E1%84%8B%E1%85%A1%E1%84%8B%E1%85%B5%E1%84%8F%E1%85%A9%E1%86%AB_PNG_%E1%84%8F%E1%85%B3%E1%84%85%E1%85%A6%E1%84%8B%E1%85%A9%E1%86%AB.png',
  },
];
