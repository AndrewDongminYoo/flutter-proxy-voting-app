// ignore_for_file: non_constant_identifier_names
// ๐ Project imports:
import '../mts.dart';

CustomRequest? makeFunction(
  CustomModule Module,
  String Job, {
  String Class = '์ฆ๊ถ์๋น์ค',
  bool? idLogin,
  String? userId,
  String? certUsername,
  String? password,
  String? certPassword,
  String? queryCode,
  String? certExpire,
  String? accountNum,
  String? accountPin,
  String? accountExt,
  String? accountType,
  String? showISO,
  String? start,
  String? end,
}) {
  switch (Job) {
    case '๋ก๊ทธ์ธ':
      if (idLogin!) {
        return CustomRequest(
            Module: Module,
            Job: Job,
            Input: CustomInput(
              idOrCert: 'ID',
              userId: userId!,
              password: password!,
              certificate: null,
              accountPin: accountPin!,
            ));
      } else {
        return CustomRequest(
            Module: Module,
            Job: Job,
            Input: CustomInput(
              idOrCert: 'CERT', // CERT: ์ธ์ฆ์, ID: ์์ด๋
              userId: userId!, // IBK, KTB ํ์ ์๋ ฅ
              password: certPassword!, // IBK, KTB ํ์ ์๋ ฅ
              accountPin: accountPin!,
              certificate: CertDto(
                certName: certUsername!,
                certExpire: certExpire!,
                certPassword: certPassword,
              ),
            ));
      }
    case '์ฆ๊ถ๋ณด์ ๊ณ์ข์กฐํ':
      return CustomRequest(
        Module: Module,
        Job: Job,
        Input: CustomInput(),
      );
    case '์ ๊ณ์ข์กฐํ':
      return CustomRequest(
          Module: Module,
          Job: Job,
          Input: CustomInput(
            password: password!, // ํค์ ์ฆ๊ถ๋ง ์ฌ์ฉ "S": ํค์ ๊ฐํธ์กฐํ, ๋ฉ๋ฆฌ์ธ  ์ ์ฒด๊ณ์ข, ์ผ์ฑ ๊ณ์ข์๊ณ 
            queryCode: queryCode!, // // ์์: ํค์ ์ผ๋ฐ์กฐํ, ๋ฉ๋ฆฌ์ธ  ๊ณ์ขํ๊ฐ, ์ผ์ฑ ์ขํฉ์๊ณ ํ๊ฐ
          )); // "D": ๋์ ,ํฌ๋ ์จ ์ขํฉ๋ฒํธ+๊ณ์ข๋ฒํธ, ์์: ์ผ๋ฐ์กฐํ
    case '๊ณ์ข์์ธ์กฐํ':
      return CustomRequest(
          Module: Module,
          Job: Job,
          Input: CustomInput(
            accountNum: accountNum!,
            accountPin: accountPin!, // ์๋ ฅ ์ํด๋ ๋์ง๋ง ์ํ๋ฉด ๊ตฌ๋งค์ข๋ชฉ ์๋์ด.
            queryCode: queryCode!, // ์ผ์ฑ "K": ์ธํ๋ง, ์์: ๊ธฐ๋ณธ์กฐํ
            showISO: showISO!, // KB "2": ํตํ์ฝ๋,ํ์ฌ๊ฐ,๋งค์ํ๊ท ๊ฐ ๋ฏธ์ถ๋ ฅ, ์์: ๋ชจ๋์ถ๋ ฅ
          ));
    case '๊ฑฐ๋๋ด์ญ์กฐํ':
      if (!['000', '001', '002', ''].contains(accountExt)) break;
      if (!['01', '02', '05', ''].contains(accountType)) break;
      if (!['1', '2', 'D'].contains(queryCode)) break;
      if (start!.isEmpty) start = sixAgo(start); // 180์ผ ์ 
      if (end!.isEmpty) end = today(); // ์ค๋
      return CustomRequest(
          Module: Module,
          Job: Job,
          Input: CustomInput(
            type: accountType!, // "01"์ํ "02"ํ๋ "05"CMA
            queryCode: queryCode!, // "1"์ขํฉ๊ฑฐ๋๋ด์ญ "2"์์ถ๊ธ๋ด์ญ "D"์ขํฉ๊ฑฐ๋๋ด์ญ ๊ฐ๋จํ
            accountNum: accountNum!,
            accountPin: accountPin!,
            accountExt: accountExt!, // ํ๋์ฆ๊ถ๋ง ์ฌ์ฉ("000"~"002")
            start: start, // YYYYMMDD
            end: end, // YYYYMMDD
          ));
    case '๋ก๊ทธ์์':
      return CustomRequest(
        Module: Module,
        Job: Job,
        Input: CustomInput(),
      );
  }
  return null;
}
