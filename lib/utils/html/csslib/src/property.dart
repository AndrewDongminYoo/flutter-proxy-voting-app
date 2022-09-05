part of '../parser.dart';

abstract class _StyleProperty {
  String? get cssExpression;
}

abstract class CssColorBase {
  String toHexArgbString();

  int get argbValue;
}

class CssColor implements _StyleProperty, CssColorBase {
  final String _argb;

  CssColor(int rgb, [num? alpha])
      : _argb = CssColor._rgbToArgbString(rgb, alpha);

  CssColor.createRgba(int red, int green, int blue, [num? alpha])
      : _argb = CssColor.convertToHexString(
            CssColor._clamp(red, 0, 255),
            CssColor._clamp(green, 0, 255),
            CssColor._clamp(blue, 0, 255),
            alpha != null ? CssColor._clamp(alpha, 0, 1) : alpha);

  CssColor.css(String color) : _argb = CssColor._convertCssToArgb(color)!;

  CssColor.createHsla(
      num hueDegree, num saturationPercent, num lightnessPercent, [num? alpha])
      : _argb = Hsla(
                CssColor._clamp(hueDegree, 0, 360) / 360,
                CssColor._clamp(saturationPercent, 0, 100) / 100,
                CssColor._clamp(lightnessPercent, 0, 100) / 100,
                alpha != null ? CssColor._clamp(alpha, 0, 1) : alpha)
            .toHexArgbString();

  CssColor.hslaRaw(num hue, num saturation, num lightness, [num? alpha])
      : _argb = Hsla(
                CssColor._clamp(hue, 0, 1),
                CssColor._clamp(saturation, 0, 1),
                CssColor._clamp(lightness, 0, 1),
                alpha != null ? CssColor._clamp(alpha, 0, 1) : alpha)
            .toHexArgbString();

  const CssColor.hex(this._argb);

  @override
  String toString() => cssExpression;

  @override
  String get cssExpression {
    if (_argb.length == 6) {
      return '#$_argb';
    } else {
      num alpha = CssColor.hexToInt(_argb.substring(0, 2));
      String a = (alpha / 255).toStringAsPrecision(2);
      int r = CssColor.hexToInt(_argb.substring(2, 4));
      int g = CssColor.hexToInt(_argb.substring(4, 6));
      int b = CssColor.hexToInt(_argb.substring(6, 8));
      return 'rgba($r,$g,$b,$a)';
    }
  }

  CssRgba get rgba {
    int nextIndex = 0;
    num? a;
    if (_argb.length == 8) {
      int alpha = CssColor.hexToInt(_argb.substring(nextIndex, nextIndex + 2));

      a = double.parse((alpha / 255).toStringAsPrecision(2));
      nextIndex += 2;
    }
    int r = CssColor.hexToInt(_argb.substring(nextIndex, nextIndex + 2));
    nextIndex += 2;
    int g = CssColor.hexToInt(_argb.substring(nextIndex, nextIndex + 2));
    nextIndex += 2;
    int b = CssColor.hexToInt(_argb.substring(nextIndex, nextIndex + 2));
    return CssRgba(r, g, b, a);
  }

  Hsla get hsla => Hsla.fromRgba(rgba);

  @override
  int get argbValue => CssColor.hexToInt(_argb);

  @override
  bool operator ==(other) => CssColor.equal(this, other);

  @override
  String toHexArgbString() => _argb;

  CssColor darker(num amount) {
    CssRgba newRgba = CssColor._createNewTintShadeFromRgba(rgba, -amount);
    return CssColor.hex(newRgba.toHexArgbString());
  }

  CssColor lighter(num amount) {
    CssRgba newRgba = CssColor._createNewTintShadeFromRgba(rgba, amount);
    return CssColor.hex(newRgba.toHexArgbString());
  }

  static bool equal(CssColorBase curr, other) {
    if (other is CssColor) {
      CssColor o = other;
      return o.toHexArgbString() == curr.toHexArgbString();
    } else if (other is CssRgba) {
      CssRgba rgb = other;
      return rgb.toHexArgbString() == curr.toHexArgbString();
    } else if (other is Hsla) {
      Hsla hsla = other;
      return hsla.toHexArgbString() == curr.toHexArgbString();
    } else {
      return false;
    }
  }

  @override
  int get hashCode => _argb.hashCode;

  static String _rgbToArgbString(int rgba, num? alpha) {
    num? a;

    if (alpha != null) {
      a = (CssColor._clamp(alpha, 0, 1) * 255).round();
    }

    int r = (rgba & 0xff0000) >> 0x10;
    int g = (rgba & 0xff00) >> 8;
    int b = rgba & 0xff;

    return CssColor.convertToHexString(r, g, b, a);
  }

  static const int _rgbCss = 1;
  static const int _rgbaCss = 2;
  static const int _hslCss = 3;
  static const int _hslaCss = 4;

  static String? _convertCssToArgb(String value) {
    String color = value.trim().replaceAll('\\s', '');
    if (color[0] == '#') {
      String v = color.substring(1);
      CssColor.hexToInt(v);
      return v;
    } else if (color.isNotEmpty && color[color.length - 1] == ')') {
      int type;
      if (color.indexOf('rgb(') == 0 || color.indexOf('RGB(') == 0) {
        color = color.substring(4);
        type = _rgbCss;
      } else if (color.indexOf('rgba(') == 0 || color.indexOf('RGBA(') == 0) {
        type = _rgbaCss;
        color = color.substring(5);
      } else if (color.indexOf('hsl(') == 0 || color.indexOf('HSL(') == 0) {
        type = _hslCss;
        color = color.substring(4);
      } else if (color.indexOf('hsla(') == 0 || color.indexOf('HSLA(') == 0) {
        type = _hslaCss;
        color = color.substring(5);
      } else {
        throw UnsupportedError('CSS property not implemented');
      }

      color = color.substring(0, color.length - 1);

      List<num> args = <num>[];
      List<String> params = color.split(',');
      for (String param in params) {
        args.add(double.parse(param));
      }
      switch (type) {
        case _rgbCss:
          return CssColor.convertToHexString(
              args[0].toInt(), args[1].toInt(), args[2].toInt());
        case _rgbaCss:
          return CssColor.convertToHexString(
              args[0].toInt(), args[1].toInt(), args[2].toInt(), args[3]);
        case _hslCss:
          return Hsla(args[0], args[1], args[2]).toHexArgbString();
        case _hslaCss:
          return Hsla(args[0], args[1], args[2], args[3]).toHexArgbString();
        default:
          assert(false);
          break;
      }
    }
    return null;
  }

  static int hexToInt(String hex) => int.parse(hex, radix: 16);

  static String convertToHexString(int r, int g, int b, [num? a]) {
    String rHex = CssColor._numAs2DigitHex(CssColor._clamp(r, 0, 255));
    String gHex = CssColor._numAs2DigitHex(CssColor._clamp(g, 0, 255));
    String bHex = CssColor._numAs2DigitHex(CssColor._clamp(b, 0, 255));
    String aHex = (a != null)
        ? CssColor._numAs2DigitHex((CssColor._clamp(a, 0, 1) * 255).round())
        : '';

    return '$aHex$rHex$gHex$bHex'.toLowerCase();
  }

  static String _numAs2DigitHex(int v) => v.toRadixString(16).padLeft(2, '0');

  static T _clamp<T extends num>(T value, T min, T max) =>
      math.max(math.min(max, value), min);

  static CssRgba _createNewTintShadeFromRgba(CssRgba rgba, num amount) {
    int r, g, b;
    num tintShade = CssColor._clamp(amount, -1, 1);
    if (amount < 0 && rgba.r == 255 && rgba.g == 255 && rgba.b == 255) {
      r = CssColor._clamp((255 + (255 * tintShade)).round().toInt(), 0, 255);
      g = CssColor._clamp((255 + (255 * tintShade)).round().toInt(), 0, 255);
      b = CssColor._clamp((255 + (255 * tintShade)).round().toInt(), 0, 255);
    } else {
      r = CssColor._changeTintShadeColor(rgba.r, tintShade).round().toInt();
      g = CssColor._changeTintShadeColor(rgba.g, tintShade).round().toInt();
      b = CssColor._changeTintShadeColor(rgba.b, tintShade).round().toInt();
    }
    return CssRgba(r, g, b, rgba.a);
  }

  static num _changeTintShadeColor(num v, num delta) =>
      CssColor._clamp(((1 - delta) * v + (delta * 255)).round(), 0, 255);

  static const CssColor transparent = CssColor.hex('00ffffff');
  static const CssColor aliceBlue = CssColor.hex('0f08ff');
  static const CssColor antiqueWhite = CssColor.hex('0faebd7');
  static const CssColor aqua = CssColor.hex('00ffff');
  static const CssColor aquaMarine = CssColor.hex('7fffd4');
  static const CssColor azure = CssColor.hex('f0ffff');
  static const CssColor beige = CssColor.hex('f5f5dc');
  static const CssColor bisque = CssColor.hex('ffe4c4');
  static const CssColor black = CssColor.hex('000000');
  static const CssColor blanchedAlmond = CssColor.hex('ffebcd');
  static const CssColor blue = CssColor.hex('0000ff');
  static const CssColor blueViolet = CssColor.hex('8a2be2');
  static const CssColor brown = CssColor.hex('a52a2a');
  static const CssColor burlyWood = CssColor.hex('deb887');
  static const CssColor cadetBlue = CssColor.hex('5f9ea0');
  static const CssColor chartreuse = CssColor.hex('7fff00');
  static const CssColor chocolate = CssColor.hex('d2691e');
  static const CssColor coral = CssColor.hex('ff7f50');
  static const CssColor cornFlowerBlue = CssColor.hex('6495ed');
  static const CssColor cornSilk = CssColor.hex('fff8dc');
  static const CssColor crimson = CssColor.hex('dc143c');
  static const CssColor cyan = CssColor.hex('00ffff');
  static const CssColor darkBlue = CssColor.hex('00008b');
  static const CssColor darkCyan = CssColor.hex('008b8b');
  static const CssColor darkGoldenRod = CssColor.hex('b8860b');
  static const CssColor darkGray = CssColor.hex('a9a9a9');
  static const CssColor darkGreen = CssColor.hex('006400');
  static const CssColor darkGrey = CssColor.hex('a9a9a9');
  static const CssColor darkKhaki = CssColor.hex('bdb76b');
  static const CssColor darkMagenta = CssColor.hex('8b008b');
  static const CssColor darkOliveGreen = CssColor.hex('556b2f');
  static const CssColor darkOrange = CssColor.hex('ff8c00');
  static const CssColor darkOrchid = CssColor.hex('9932cc');
  static const CssColor darkRed = CssColor.hex('8b0000');
  static const CssColor darkSalmon = CssColor.hex('e9967a');
  static const CssColor darkSeaGreen = CssColor.hex('8fbc8f');
  static const CssColor darkSlateBlue = CssColor.hex('483d8b');
  static const CssColor darkSlateGray = CssColor.hex('2f4f4f');
  static const CssColor darkSlateGrey = CssColor.hex('2f4f4f');
  static const CssColor darkTurquoise = CssColor.hex('00ced1');
  static const CssColor darkViolet = CssColor.hex('9400d3');
  static const CssColor deepPink = CssColor.hex('ff1493');
  static const CssColor deepSkyBlue = CssColor.hex('00bfff');
  static const CssColor dimGray = CssColor.hex('696969');
  static const CssColor dimGrey = CssColor.hex('696969');
  static const CssColor dodgerBlue = CssColor.hex('1e90ff');
  static const CssColor fireBrick = CssColor.hex('b22222');
  static const CssColor floralWhite = CssColor.hex('fffaf0');
  static const CssColor forestGreen = CssColor.hex('228b22');
  static const CssColor fuchsia = CssColor.hex('ff00ff');
  static const CssColor gainsboro = CssColor.hex('dcdcdc');
  static const CssColor ghostWhite = CssColor.hex('f8f8ff');
  static const CssColor gold = CssColor.hex('ffd700');
  static const CssColor goldenRod = CssColor.hex('daa520');
  static const CssColor gray = CssColor.hex('808080');
  static const CssColor green = CssColor.hex('008000');
  static const CssColor greenYellow = CssColor.hex('adff2f');
  static const CssColor grey = CssColor.hex('808080');
  static const CssColor honeydew = CssColor.hex('f0fff0');
  static const CssColor hotPink = CssColor.hex('ff69b4');
  static const CssColor indianRed = CssColor.hex('cd5c5c');
  static const CssColor indigo = CssColor.hex('4b0082');
  static const CssColor ivory = CssColor.hex('fffff0');
  static const CssColor khaki = CssColor.hex('f0e68c');
  static const CssColor lavender = CssColor.hex('e6e6fa');
  static const CssColor lavenderBlush = CssColor.hex('fff0f5');
  static const CssColor lawnGreen = CssColor.hex('7cfc00');
  static const CssColor lemonChiffon = CssColor.hex('fffacd');
  static const CssColor lightBlue = CssColor.hex('add8e6');
  static const CssColor lightCoral = CssColor.hex('f08080');
  static const CssColor lightCyan = CssColor.hex('e0ffff');
  static const CssColor lightGoldenRodYellow = CssColor.hex('fafad2');
  static const CssColor lightGray = CssColor.hex('d3d3d3');
  static const CssColor lightGreen = CssColor.hex('90ee90');
  static const CssColor lightGrey = CssColor.hex('d3d3d3');
  static const CssColor lightPink = CssColor.hex('ffb6c1');
  static const CssColor lightSalmon = CssColor.hex('ffa07a');
  static const CssColor lightSeaGreen = CssColor.hex('20b2aa');
  static const CssColor lightSkyBlue = CssColor.hex('87cefa');
  static const CssColor lightSlateGray = CssColor.hex('778899');
  static const CssColor lightSlateGrey = CssColor.hex('778899');
  static const CssColor lightSteelBlue = CssColor.hex('b0c4de');
  static const CssColor lightYellow = CssColor.hex('ffffe0');
  static const CssColor lime = CssColor.hex('00ff00');
  static const CssColor limeGreen = CssColor.hex('32cd32');
  static const CssColor linen = CssColor.hex('faf0e6');
  static const CssColor magenta = CssColor.hex('ff00ff');
  static const CssColor maroon = CssColor.hex('800000');
  static const CssColor mediumAquaMarine = CssColor.hex('66cdaa');
  static const CssColor mediumBlue = CssColor.hex('0000cd');
  static const CssColor mediumOrchid = CssColor.hex('ba55d3');
  static const CssColor mediumPurple = CssColor.hex('9370db');
  static const CssColor mediumSeaGreen = CssColor.hex('3cb371');
  static const CssColor mediumSlateBlue = CssColor.hex('7b68ee');
  static const CssColor mediumSpringGreen = CssColor.hex('00fa9a');
  static const CssColor mediumTurquoise = CssColor.hex('48d1cc');
  static const CssColor mediumVioletRed = CssColor.hex('c71585');
  static const CssColor midnightBlue = CssColor.hex('191970');
  static const CssColor mintCream = CssColor.hex('f5fffa');
  static const CssColor mistyRose = CssColor.hex('ffe4e1');
  static const CssColor moccasin = CssColor.hex('ffe4b5');
  static const CssColor navajoWhite = CssColor.hex('ffdead');
  static const CssColor navy = CssColor.hex('000080');
  static const CssColor oldLace = CssColor.hex('fdf5e6');
  static const CssColor olive = CssColor.hex('808000');
  static const CssColor oliveDrab = CssColor.hex('6b8e23');
  static const CssColor orange = CssColor.hex('ffa500');
  static const CssColor orangeRed = CssColor.hex('ff4500');
  static const CssColor orchid = CssColor.hex('da70d6');
  static const CssColor paleGoldenRod = CssColor.hex('eee8aa');
  static const CssColor paleGreen = CssColor.hex('98fb98');
  static const CssColor paleTurquoise = CssColor.hex('afeeee');
  static const CssColor paleVioletRed = CssColor.hex('db7093');
  static const CssColor papayaWhip = CssColor.hex('ffefd5');
  static const CssColor peachPuff = CssColor.hex('ffdab9');
  static const CssColor peru = CssColor.hex('cd85ef');
  static const CssColor pink = CssColor.hex('ffc0cb');
  static const CssColor plum = CssColor.hex('dda0dd');
  static const CssColor powderBlue = CssColor.hex('b0e0e6');
  static const CssColor purple = CssColor.hex('800080');
  static const CssColor red = CssColor.hex('ff0000');
  static const CssColor rosyBrown = CssColor.hex('bc8f8f');
  static const CssColor royalBlue = CssColor.hex('4169e1');
  static const CssColor saddleBrown = CssColor.hex('8b4513');
  static const CssColor salmon = CssColor.hex('fa8072');
  static const CssColor sandyBrown = CssColor.hex('f4a460');
  static const CssColor seaGreen = CssColor.hex('2e8b57');
  static const CssColor seashell = CssColor.hex('fff5ee');
  static const CssColor sienna = CssColor.hex('a0522d');
  static const CssColor silver = CssColor.hex('c0c0c0');
  static const CssColor skyBlue = CssColor.hex('87ceeb');
  static const CssColor slateBlue = CssColor.hex('6a5acd');
  static const CssColor slateGray = CssColor.hex('708090');
  static const CssColor slateGrey = CssColor.hex('708090');
  static const CssColor snow = CssColor.hex('fffafa');
  static const CssColor springGreen = CssColor.hex('00ff7f');
  static const CssColor steelBlue = CssColor.hex('4682b4');
  static const CssColor tan = CssColor.hex('d2b48c');
  static const CssColor teal = CssColor.hex('008080');
  static const CssColor thistle = CssColor.hex('d8bfd8');
  static const CssColor tomato = CssColor.hex('ff6347');
  static const CssColor turquoise = CssColor.hex('40e0d0');
  static const CssColor violet = CssColor.hex('ee82ee');
  static const CssColor wheat = CssColor.hex('f5deb3');
  static const CssColor white = CssColor.hex('ffffff');
  static const CssColor whiteSmoke = CssColor.hex('f5f5f5');
  static const CssColor yellow = CssColor.hex('ffff00');
  static const CssColor yellowGreen = CssColor.hex('9acd32');
}

class CssRgba implements _StyleProperty, CssColorBase {
  final int r;
  final int g;
  final int b;
  final num? a;

  CssRgba(int red, int green, int blue, [num? alpha])
      : r = CssColor._clamp(red, 0, 255),
        g = CssColor._clamp(green, 0, 255),
        b = CssColor._clamp(blue, 0, 255),
        a = (alpha != null) ? CssColor._clamp(alpha, 0, 1) : alpha;

  factory CssRgba.fromString(String hexValue) =>
      CssColor.css('#${CssColor._convertCssToArgb(hexValue)}').rgba;

  factory CssRgba.fromColor(CssColor color) => color.rgba;

  factory CssRgba.fromArgbValue(num value) {
    return CssRgba(
        ((value.toInt() & 0xff000000) >> 0x18),
        ((value.toInt() & 0xff0000) >> 0x10),
        ((value.toInt() & 0xff00) >> 8),
        ((value.toInt() & 0xff)));
  }

  factory CssRgba.fromHsla(Hsla hsla) {
    num h = hsla.hue;
    num s = hsla.saturation;
    num l = hsla.lightness;
    num? a = hsla.alpha;

    int r;
    int g;
    int b;

    if (s == 0) {
      r = (l * 255).round().toInt();
      g = r;
      b = r;
    } else {
      num var2;

      if (l < 0.5) {
        var2 = l * (1 + s);
      } else {
        var2 = (l + s) - (s * l);
      }
      num var1 = 2 * l - var2;

      r = (255 * CssRgba._hueToRGB(var1, var2, h + (1 / 3))).round().toInt();
      g = (255 * CssRgba._hueToRGB(var1, var2, h)).round().toInt();
      b = (255 * CssRgba._hueToRGB(var1, var2, h - (1 / 3))).round().toInt();
    }

    return CssRgba(r, g, b, a);
  }

  static num _hueToRGB(num v1, num v2, num vH) {
    if (vH < 0) {
      vH += 1;
    }

    if (vH > 1) {
      vH -= 1;
    }

    if ((6 * vH) < 1) {
      return (v1 + (v2 - v1) * 6 * vH);
    }

    if ((2 * vH) < 1) {
      return v2;
    }

    if ((3 * vH) < 2) {
      return (v1 + (v2 - v1) * ((2 / 3 - vH) * 6));
    }

    return v1;
  }

  @override
  bool operator ==(other) => CssColor.equal(this, other);

  @override
  String get cssExpression {
    if (a == null) {
      return '#${CssColor.convertToHexString(r, g, b)}';
    } else {
      return 'rgba($r,$g,$b,$a)';
    }
  }

  @override
  String toHexArgbString() => CssColor.convertToHexString(r, g, b, a);

  @override
  int get argbValue {
    int value = 0;
    if (a != null) {
      value = (a!.toInt() << 0x18);
    }
    value += (r << 0x10);
    value += (g << 0x08);
    value += b;
    return value;
  }

  CssColor get color => CssColor.createRgba(r, g, b, a);
  Hsla get hsla => Hsla.fromRgba(this);

  CssRgba darker(num amount) =>
      CssColor._createNewTintShadeFromRgba(this, -amount);
  CssRgba lighter(num amount) =>
      CssColor._createNewTintShadeFromRgba(this, amount);

  @override
  int get hashCode => toHexArgbString().hashCode;
}

class Hsla implements _StyleProperty, CssColorBase {
  final num _h;
  final num _s;
  final num _l;
  final num? _a;

  Hsla(num hue, num saturation, num lightness, [num? alpha])
      : _h = (hue == 1) ? 0 : CssColor._clamp(hue, 0, 1),
        _s = CssColor._clamp(saturation, 0, 1),
        _l = CssColor._clamp(lightness, 0, 1),
        _a = (alpha != null) ? CssColor._clamp(alpha, 0, 1) : alpha;

  factory Hsla.fromString(String hexValue) {
    CssRgba rgba =
        CssColor.css('#${CssColor._convertCssToArgb(hexValue)}').rgba;
    return _createFromRgba(rgba.r, rgba.g, rgba.b, rgba.a);
  }

  factory Hsla.fromColor(CssColor color) {
    CssRgba rgba = color.rgba;
    return _createFromRgba(rgba.r, rgba.g, rgba.b, rgba.a);
  }

  factory Hsla.fromArgbValue(num value) {
    num a = (value.toInt() & 0xff000000) >> 0x18;
    int r = (value.toInt() & 0xff0000) >> 0x10;
    int g = (value.toInt() & 0xff00) >> 8;
    int b = value.toInt() & 0xff;

    a = double.parse((a / 255).toStringAsPrecision(2));

    return _createFromRgba(r, g, b, a);
  }

  factory Hsla.fromRgba(CssRgba rgba) =>
      _createFromRgba(rgba.r, rgba.g, rgba.b, rgba.a);

  static Hsla _createFromRgba(num r, num g, num b, num? a) {
    r /= 255;
    g /= 255;
    b /= 255;
    num h;
    num s;
    num l;

    num minRgb = math.min(r, math.min(g, b));
    num maxRgb = math.max(r, math.max(g, b));
    l = (maxRgb + minRgb) / 2;
    if (l <= 0) {
      return Hsla(0, 0, l);
    }

    num vm = maxRgb - minRgb;
    s = vm;
    if (s > 0) {
      s /= (l < 0.5) ? (maxRgb + minRgb) : (2 - maxRgb - minRgb);
    } else {
      return Hsla(0, 0, l);
    }

    num r2, g2, b2;
    r2 = (maxRgb - r) / vm;
    g2 = (maxRgb - g) / vm;
    b2 = (maxRgb - b) / vm;
    if (r == maxRgb) {
      h = (g == minRgb) ? 5.0 + b2 : 1 - g2;
    } else if (g == maxRgb) {
      h = (b == minRgb) ? 1 + r2 : 3 - b2;
    } else {
      h = (r == minRgb) ? 3 + g2 : 5 - r2;
    }
    h /= 6;

    return Hsla(h, s, l, a);
  }

  num get hue => _h;

  num get saturation => _s;

  num get lightness => _l;

  num get hueDegrees => (_h * 360).round();

  num get saturationPercentage => (_s * 100).round();

  num get lightnessPercentage => (_l * 100).round();

  num? get alpha => _a;

  @override
  bool operator ==(other) => CssColor.equal(this, other);

  @override
  String get cssExpression => (_a == null)
      ? 'hsl($hueDegrees,$saturationPercentage,$lightnessPercentage)'
      : 'hsla($hueDegrees,$saturationPercentage,$lightnessPercentage,$_a)';

  @override
  String toHexArgbString() => CssRgba.fromHsla(this).toHexArgbString();

  @override
  int get argbValue => CssColor.hexToInt(toHexArgbString());

  CssColor get color => CssColor.createHsla(_h, _s, _l, _a);
  CssRgba get rgba => CssRgba.fromHsla(this);

  Hsla darker(num amount) =>
      Hsla.fromRgba(CssRgba.fromHsla(this).darker(amount));

  Hsla lighter(num amount) =>
      Hsla.fromRgba(CssRgba.fromHsla(this).lighter(amount));

  @override
  int get hashCode => toHexArgbString().hashCode;
}

class PointXY implements _StyleProperty {
  final num x, y;
  const PointXY(this.x, this.y);

  @override
  String? get cssExpression {
    return null;
  }
}

class CBorder implements _StyleProperty {
  final int? top, left, bottom, right;

  const CBorder([this.top, this.left, this.bottom, this.right]);

  CBorder.uniform(int amount)
      : top = amount,
        left = amount,
        bottom = amount,
        right = amount;

  int get width => left! + right!;
  int get height => top! + bottom!;

  @override
  String get cssExpression {
    return (top == left && bottom == right && top == right)
        ? '${left}px'
        : "${top != null ? '$top' : '0'}px "
            "${right != null ? '$right' : '0'}px "
            "${bottom != null ? '$bottom' : '0'}px "
            "${left != null ? '$left' : '0'}px";
  }
}

class CssFontStyle {
  static const String normal = 'normal';

  static const String italic = 'italic';

  static const String oblique = 'oblique';
}

class FontVariant {
  static const String normal = 'normal';

  static const String smallCaps = 'small-caps';
}

class CssFontWeight {
  static const int normal = 400;

  static const int bold = 700;

  static const int wt100 = 100;
  static const int wt200 = 200;
  static const int wt300 = 300;
  static const int wt400 = 400;
  static const int wt500 = 500;
  static const int wt600 = 600;
  static const int wt700 = 700;
  static const int wt800 = 800;
  static const int wt900 = 900;
}

class FontGeneric {
  static const String sansSerif = 'sans-serif';

  static const String serif = 'serif';

  static const monospace = 'monospace';

  static const String cursive = 'cursive';

  static const String fantasy = 'fantasy';
}

class FontFamily {
  static const String arial = 'arial';

  static const String arialBlack = 'arial black';

  static const String geneva = 'geneva';

  static const String verdana = 'verdana';

  static const String helvetica = 'helvetica';

  static const String georgia = 'georgia';

  static const String times = 'times';

  static const String timesNewRoman = 'times new roman';

  static const String courier = 'courier';

  static const String courierNew = 'courier new';

  static const String comicSansMs = 'comic sans ms';

  static const String textile = 'textile';

  static const String appleChancery = 'apple chancery';

  static const String zaphChancery = 'zaph chancery';

  static const String impact = 'impact';

  static const String webdings = 'webdings';
}

class LineHeight {
  final num height;
  final bool inPixels;
  const LineHeight(this.height, {this.inPixels = true});
}

class CssFont implements _StyleProperty {
  static const List<String> sansSerif = [
    FontFamily.arial,
    FontFamily.verdana,
    FontFamily.geneva,
    FontFamily.helvetica,
    FontGeneric.sansSerif
  ];

  static const List<String> serif = [
    FontFamily.georgia,
    FontFamily.timesNewRoman,
    FontFamily.times,
    FontGeneric.serif
  ];

  static const List<String> monospace = [
    FontFamily.courierNew,
    FontFamily.courier,
    FontGeneric.monospace
  ];

  static const List<String> cursive = [
    FontFamily.textile,
    FontFamily.appleChancery,
    FontFamily.zaphChancery,
    FontGeneric.fantasy
  ];

  static const List<String> fantasy = [
    FontFamily.comicSansMs,
    FontFamily.impact,
    FontFamily.webdings,
    FontGeneric.fantasy
  ];

  final num? size;

  final List<String>? family;

  final int? weight;

  final String? style;

  final String? variant;

  final LineHeight? lineHeight;

  const CssFont(
      {this.size,
      this.family,
      this.weight,
      this.style,
      this.variant,
      this.lineHeight});

  static CssFont? merge(CssFont? a, CssFont? b) {
    if (a == null) return b;
    if (b == null) return a;
    return CssFont._merge(a, b);
  }

  CssFont._merge(CssFont a, CssFont b)
      : size = _mergeVal(a.size, b.size),
        family = _mergeVal(a.family, b.family),
        weight = _mergeVal(a.weight, b.weight),
        style = _mergeVal(a.style, b.style),
        variant = _mergeVal(a.variant, b.variant),
        lineHeight = _mergeVal(a.lineHeight, b.lineHeight);

  @override
  String get cssExpression {
    if (weight != null) {
      if (lineHeight != null) {
        return '$weight ${size}px/$lineHeightInPixels $_fontsAsString';
      }
      return '$weight ${size}px $_fontsAsString';
    }

    return '${size}px $_fontsAsString';
  }

  CssFont scale(num ratio) => CssFont(
      size: size! * ratio,
      family: family,
      weight: weight,
      style: style,
      variant: variant);

  num? get lineHeightInPixels {
    if (lineHeight != null) {
      if (lineHeight!.inPixels) {
        return lineHeight!.height;
      } else {
        return (size != null) ? lineHeight!.height * size! : null;
      }
    } else {
      return (size != null) ? size! * 1.2 : null;
    }
  }

  @override
  int get hashCode {
    return size!.toInt() % family![0].hashCode;
  }

  @override
  bool operator ==(other) {
    if (other is! CssFont) return false;
    return other.size == size &&
        other.family == family &&
        other.weight == weight &&
        other.lineHeight == lineHeight &&
        other.style == style &&
        other.variant == variant;
  }

  String get _fontsAsString {
    String fonts = family.toString();
    return fonts.length > 2 ? fonts.substring(1, fonts.length - 1) : '';
  }
}

class CssBoxEdge {
  final num? left;

  final num? top;

  final num? right;

  final num? bottom;

  const CssBoxEdge([this.left, this.top, this.right, this.bottom]);

  const CssBoxEdge.clockwiseFromTop(
      this.top, this.right, this.bottom, this.left);

  const CssBoxEdge.uniform(num size)
      : top = size,
        left = size,
        bottom = size,
        right = size;

  factory CssBoxEdge.nonNull(CssBoxEdge? other) {
    if (other == null) return const CssBoxEdge(0, 0, 0, 0);
    num? left = other.left;
    num? top = other.top;
    num? right = other.right;
    num? bottom = other.bottom;
    bool make = false;
    if (left == null) {
      make = true;
      left = 0;
    }
    if (top == null) {
      make = true;
      top = 0;
    }
    if (right == null) {
      make = true;
      right = 0;
    }
    if (bottom == null) {
      make = true;
      bottom = 0;
    }
    return make ? CssBoxEdge(left, top, right, bottom) : other;
  }

  static CssBoxEdge? merge(CssBoxEdge? x, CssBoxEdge? y) {
    if (x == null) return y;
    if (y == null) return x;
    return CssBoxEdge._merge(x, y);
  }

  CssBoxEdge._merge(CssBoxEdge x, CssBoxEdge y)
      : left = _mergeVal(x.left, y.left),
        top = _mergeVal(x.top, y.top),
        right = _mergeVal(x.right, y.right),
        bottom = _mergeVal(x.bottom, y.bottom);

  num get width => (left ?? 0) + (right ?? 0);

  num get height => (top ?? 0) + (bottom ?? 0);
}

T _mergeVal<T>(T x, T y) => y ?? x;
