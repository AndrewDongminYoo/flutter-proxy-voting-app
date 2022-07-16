part of '../parser.dart';

abstract class _StyleProperty {
  String? get cssExpression;
}

abstract class ColorBase {
  String toHexArgbString();

  int get argbValue;
}

class Color implements _StyleProperty, ColorBase {
  final String _argb;

  Color(int rgb, [num? alpha]) : _argb = Color._rgbToArgbString(rgb, alpha);

  Color.createRgba(int red, int green, int blue, [num? alpha])
      : _argb = Color.convertToHexString(
            Color._clamp(red, 0, 255),
            Color._clamp(green, 0, 255),
            Color._clamp(blue, 0, 255),
            alpha != null ? Color._clamp(alpha, 0, 1) : alpha);

  Color.css(String color) : _argb = Color._convertCssToArgb(color)!;

  Color.createHsla(num hueDegree, num saturationPercent, num lightnessPercent,
      [num? alpha])
      : _argb = Hsla(
                Color._clamp(hueDegree, 0, 360) / 360,
                Color._clamp(saturationPercent, 0, 100) / 100,
                Color._clamp(lightnessPercent, 0, 100) / 100,
                alpha != null ? Color._clamp(alpha, 0, 1) : alpha)
            .toHexArgbString();

  Color.hslaRaw(num hue, num saturation, num lightness, [num? alpha])
      : _argb = Hsla(
                Color._clamp(hue, 0, 1),
                Color._clamp(saturation, 0, 1),
                Color._clamp(lightness, 0, 1),
                alpha != null ? Color._clamp(alpha, 0, 1) : alpha)
            .toHexArgbString();

  const Color.hex(this._argb);

  @override
  String toString() => cssExpression;

  @override
  String get cssExpression {
    if (_argb.length == 6) {
      return '#$_argb';
    } else {
      num alpha = Color.hexToInt(_argb.substring(0, 2));
      var a = (alpha / 255).toStringAsPrecision(2);
      var r = Color.hexToInt(_argb.substring(2, 4));
      var g = Color.hexToInt(_argb.substring(4, 6));
      var b = Color.hexToInt(_argb.substring(6, 8));
      return 'rgba($r,$g,$b,$a)';
    }
  }

  Rgba get rgba {
    var nextIndex = 0;
    num? a;
    if (_argb.length == 8) {
      var alpha = Color.hexToInt(_argb.substring(nextIndex, nextIndex + 2));

      a = double.parse((alpha / 255).toStringAsPrecision(2));
      nextIndex += 2;
    }
    var r = Color.hexToInt(_argb.substring(nextIndex, nextIndex + 2));
    nextIndex += 2;
    var g = Color.hexToInt(_argb.substring(nextIndex, nextIndex + 2));
    nextIndex += 2;
    var b = Color.hexToInt(_argb.substring(nextIndex, nextIndex + 2));
    return Rgba(r, g, b, a);
  }

  Hsla get hsla => Hsla.fromRgba(rgba);

  @override
  int get argbValue => Color.hexToInt(_argb);

  @override
  bool operator ==(other) => Color.equal(this, other);

  @override
  String toHexArgbString() => _argb;

  Color darker(num amount) {
    var newRgba = Color._createNewTintShadeFromRgba(rgba, -amount);
    return Color.hex(newRgba.toHexArgbString());
  }

  Color lighter(num amount) {
    var newRgba = Color._createNewTintShadeFromRgba(rgba, amount);
    return Color.hex(newRgba.toHexArgbString());
  }

  static bool equal(ColorBase curr, other) {
    if (other is Color) {
      var o = other;
      return o.toHexArgbString() == curr.toHexArgbString();
    } else if (other is Rgba) {
      var rgb = other;
      return rgb.toHexArgbString() == curr.toHexArgbString();
    } else if (other is Hsla) {
      var hsla = other;
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
      a = (Color._clamp(alpha, 0, 1) * 255).round();
    }

    var r = (rgba & 0xff0000) >> 0x10;
    var g = (rgba & 0xff00) >> 8;
    var b = rgba & 0xff;

    return Color.convertToHexString(r, g, b, a);
  }

  static const int _rgbCss = 1;
  static const int _rgbaCss = 2;
  static const int _hslCss = 3;
  static const int _hslaCss = 4;

  static String? _convertCssToArgb(String value) {
    var color = value.trim().replaceAll('\\s', '');
    if (color[0] == '#') {
      var v = color.substring(1);
      Color.hexToInt(v);
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

      var args = <num>[];
      var params = color.split(',');
      for (var param in params) {
        args.add(double.parse(param));
      }
      switch (type) {
        case _rgbCss:
          return Color.convertToHexString(
              args[0].toInt(), args[1].toInt(), args[2].toInt());
        case _rgbaCss:
          return Color.convertToHexString(
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
    var rHex = Color._numAs2DigitHex(Color._clamp(r, 0, 255));
    var gHex = Color._numAs2DigitHex(Color._clamp(g, 0, 255));
    var bHex = Color._numAs2DigitHex(Color._clamp(b, 0, 255));
    var aHex = (a != null)
        ? Color._numAs2DigitHex((Color._clamp(a, 0, 1) * 255).round())
        : '';

    return '$aHex$rHex$gHex$bHex'.toLowerCase();
  }

  static String _numAs2DigitHex(int v) => v.toRadixString(16).padLeft(2, '0');

  static T _clamp<T extends num>(T value, T min, T max) =>
      math.max(math.min(max, value), min);

  static Rgba _createNewTintShadeFromRgba(Rgba rgba, num amount) {
    int r, g, b;
    var tintShade = Color._clamp(amount, -1, 1);
    if (amount < 0 && rgba.r == 255 && rgba.g == 255 && rgba.b == 255) {
      r = Color._clamp((255 + (255 * tintShade)).round().toInt(), 0, 255);
      g = Color._clamp((255 + (255 * tintShade)).round().toInt(), 0, 255);
      b = Color._clamp((255 + (255 * tintShade)).round().toInt(), 0, 255);
    } else {
      r = Color._changeTintShadeColor(rgba.r, tintShade).round().toInt();
      g = Color._changeTintShadeColor(rgba.g, tintShade).round().toInt();
      b = Color._changeTintShadeColor(rgba.b, tintShade).round().toInt();
    }
    return Rgba(r, g, b, rgba.a);
  }

  static num _changeTintShadeColor(num v, num delta) =>
      Color._clamp(((1 - delta) * v + (delta * 255)).round(), 0, 255);

  static const Color transparent = Color.hex('00ffffff');
  static const Color aliceBlue = Color.hex('0f08ff');
  static const Color antiqueWhite = Color.hex('0faebd7');
  static const Color aqua = Color.hex('00ffff');
  static const Color aquaMarine = Color.hex('7fffd4');
  static const Color azure = Color.hex('f0ffff');
  static const Color beige = Color.hex('f5f5dc');
  static const Color bisque = Color.hex('ffe4c4');
  static const Color black = Color.hex('000000');
  static const Color blanchedAlmond = Color.hex('ffebcd');
  static const Color blue = Color.hex('0000ff');
  static const Color blueViolet = Color.hex('8a2be2');
  static const Color brown = Color.hex('a52a2a');
  static const Color burlyWood = Color.hex('deb887');
  static const Color cadetBlue = Color.hex('5f9ea0');
  static const Color chartreuse = Color.hex('7fff00');
  static const Color chocolate = Color.hex('d2691e');
  static const Color coral = Color.hex('ff7f50');
  static const Color cornFlowerBlue = Color.hex('6495ed');
  static const Color cornSilk = Color.hex('fff8dc');
  static const Color crimson = Color.hex('dc143c');
  static const Color cyan = Color.hex('00ffff');
  static const Color darkBlue = Color.hex('00008b');
  static const Color darkCyan = Color.hex('008b8b');
  static const Color darkGoldenRod = Color.hex('b8860b');
  static const Color darkGray = Color.hex('a9a9a9');
  static const Color darkGreen = Color.hex('006400');
  static const Color darkGrey = Color.hex('a9a9a9');
  static const Color darkKhaki = Color.hex('bdb76b');
  static const Color darkMagenta = Color.hex('8b008b');
  static const Color darkOliveGreen = Color.hex('556b2f');
  static const Color darkOrange = Color.hex('ff8c00');
  static const Color darkOrchid = Color.hex('9932cc');
  static const Color darkRed = Color.hex('8b0000');
  static const Color darkSalmon = Color.hex('e9967a');
  static const Color darkSeaGreen = Color.hex('8fbc8f');
  static const Color darkSlateBlue = Color.hex('483d8b');
  static const Color darkSlateGray = Color.hex('2f4f4f');
  static const Color darkSlateGrey = Color.hex('2f4f4f');
  static const Color darkTurquoise = Color.hex('00ced1');
  static const Color darkViolet = Color.hex('9400d3');
  static const Color deepPink = Color.hex('ff1493');
  static const Color deepSkyBlue = Color.hex('00bfff');
  static const Color dimGray = Color.hex('696969');
  static const Color dimGrey = Color.hex('696969');
  static const Color dodgerBlue = Color.hex('1e90ff');
  static const Color fireBrick = Color.hex('b22222');
  static const Color floralWhite = Color.hex('fffaf0');
  static const Color forestGreen = Color.hex('228b22');
  static const Color fuchsia = Color.hex('ff00ff');
  static const Color gainsboro = Color.hex('dcdcdc');
  static const Color ghostWhite = Color.hex('f8f8ff');
  static const Color gold = Color.hex('ffd700');
  static const Color goldenRod = Color.hex('daa520');
  static const Color gray = Color.hex('808080');
  static const Color green = Color.hex('008000');
  static const Color greenYellow = Color.hex('adff2f');
  static const Color grey = Color.hex('808080');
  static const Color honeydew = Color.hex('f0fff0');
  static const Color hotPink = Color.hex('ff69b4');
  static const Color indianRed = Color.hex('cd5c5c');
  static const Color indigo = Color.hex('4b0082');
  static const Color ivory = Color.hex('fffff0');
  static const Color khaki = Color.hex('f0e68c');
  static const Color lavender = Color.hex('e6e6fa');
  static const Color lavenderBlush = Color.hex('fff0f5');
  static const Color lawnGreen = Color.hex('7cfc00');
  static const Color lemonChiffon = Color.hex('fffacd');
  static const Color lightBlue = Color.hex('add8e6');
  static const Color lightCoral = Color.hex('f08080');
  static const Color lightCyan = Color.hex('e0ffff');
  static const Color lightGoldenRodYellow = Color.hex('fafad2');
  static const Color lightGray = Color.hex('d3d3d3');
  static const Color lightGreen = Color.hex('90ee90');
  static const Color lightGrey = Color.hex('d3d3d3');
  static const Color lightPink = Color.hex('ffb6c1');
  static const Color lightSalmon = Color.hex('ffa07a');
  static const Color lightSeaGreen = Color.hex('20b2aa');
  static const Color lightSkyBlue = Color.hex('87cefa');
  static const Color lightSlateGray = Color.hex('778899');
  static const Color lightSlateGrey = Color.hex('778899');
  static const Color lightSteelBlue = Color.hex('b0c4de');
  static const Color lightYellow = Color.hex('ffffe0');
  static const Color lime = Color.hex('00ff00');
  static const Color limeGreen = Color.hex('32cd32');
  static const Color linen = Color.hex('faf0e6');
  static const Color magenta = Color.hex('ff00ff');
  static const Color maroon = Color.hex('800000');
  static const Color mediumAquaMarine = Color.hex('66cdaa');
  static const Color mediumBlue = Color.hex('0000cd');
  static const Color mediumOrchid = Color.hex('ba55d3');
  static const Color mediumPurple = Color.hex('9370db');
  static const Color mediumSeaGreen = Color.hex('3cb371');
  static const Color mediumSlateBlue = Color.hex('7b68ee');
  static const Color mediumSpringGreen = Color.hex('00fa9a');
  static const Color mediumTurquoise = Color.hex('48d1cc');
  static const Color mediumVioletRed = Color.hex('c71585');
  static const Color midnightBlue = Color.hex('191970');
  static const Color mintCream = Color.hex('f5fffa');
  static const Color mistyRose = Color.hex('ffe4e1');
  static const Color moccasin = Color.hex('ffe4b5');
  static const Color navajoWhite = Color.hex('ffdead');
  static const Color navy = Color.hex('000080');
  static const Color oldLace = Color.hex('fdf5e6');
  static const Color olive = Color.hex('808000');
  static const Color oliveDrab = Color.hex('6b8e23');
  static const Color orange = Color.hex('ffa500');
  static const Color orangeRed = Color.hex('ff4500');
  static const Color orchid = Color.hex('da70d6');
  static const Color paleGoldenRod = Color.hex('eee8aa');
  static const Color paleGreen = Color.hex('98fb98');
  static const Color paleTurquoise = Color.hex('afeeee');
  static const Color paleVioletRed = Color.hex('db7093');
  static const Color papayaWhip = Color.hex('ffefd5');
  static const Color peachPuff = Color.hex('ffdab9');
  static const Color peru = Color.hex('cd85ef');
  static const Color pink = Color.hex('ffc0cb');
  static const Color plum = Color.hex('dda0dd');
  static const Color powderBlue = Color.hex('b0e0e6');
  static const Color purple = Color.hex('800080');
  static const Color red = Color.hex('ff0000');
  static const Color rosyBrown = Color.hex('bc8f8f');
  static const Color royalBlue = Color.hex('4169e1');
  static const Color saddleBrown = Color.hex('8b4513');
  static const Color salmon = Color.hex('fa8072');
  static const Color sandyBrown = Color.hex('f4a460');
  static const Color seaGreen = Color.hex('2e8b57');
  static const Color seashell = Color.hex('fff5ee');
  static const Color sienna = Color.hex('a0522d');
  static const Color silver = Color.hex('c0c0c0');
  static const Color skyBlue = Color.hex('87ceeb');
  static const Color slateBlue = Color.hex('6a5acd');
  static const Color slateGray = Color.hex('708090');
  static const Color slateGrey = Color.hex('708090');
  static const Color snow = Color.hex('fffafa');
  static const Color springGreen = Color.hex('00ff7f');
  static const Color steelBlue = Color.hex('4682b4');
  static const Color tan = Color.hex('d2b48c');
  static const Color teal = Color.hex('008080');
  static const Color thistle = Color.hex('d8bfd8');
  static const Color tomato = Color.hex('ff6347');
  static const Color turquoise = Color.hex('40e0d0');
  static const Color violet = Color.hex('ee82ee');
  static const Color wheat = Color.hex('f5deb3');
  static const Color white = Color.hex('ffffff');
  static const Color whiteSmoke = Color.hex('f5f5f5');
  static const Color yellow = Color.hex('ffff00');
  static const Color yellowGreen = Color.hex('9acd32');
}

class Rgba implements _StyleProperty, ColorBase {
  final int r;
  final int g;
  final int b;
  final num? a;

  Rgba(int red, int green, int blue, [num? alpha])
      : r = Color._clamp(red, 0, 255),
        g = Color._clamp(green, 0, 255),
        b = Color._clamp(blue, 0, 255),
        a = (alpha != null) ? Color._clamp(alpha, 0, 1) : alpha;

  factory Rgba.fromString(String hexValue) =>
      Color.css('#${Color._convertCssToArgb(hexValue)}').rgba;

  factory Rgba.fromColor(Color color) => color.rgba;

  factory Rgba.fromArgbValue(num value) {
    return Rgba(
        ((value.toInt() & 0xff000000) >> 0x18),
        ((value.toInt() & 0xff0000) >> 0x10),
        ((value.toInt() & 0xff00) >> 8),
        ((value.toInt() & 0xff)));
  }

  factory Rgba.fromHsla(Hsla hsla) {
    var h = hsla.hue;
    var s = hsla.saturation;
    var l = hsla.lightness;
    var a = hsla.alpha;

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
      var var1 = 2 * l - var2;

      r = (255 * Rgba._hueToRGB(var1, var2, h + (1 / 3))).round().toInt();
      g = (255 * Rgba._hueToRGB(var1, var2, h)).round().toInt();
      b = (255 * Rgba._hueToRGB(var1, var2, h - (1 / 3))).round().toInt();
    }

    return Rgba(r, g, b, a);
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
  bool operator ==(other) => Color.equal(this, other);

  @override
  String get cssExpression {
    if (a == null) {
      return '#${Color.convertToHexString(r, g, b)}';
    } else {
      return 'rgba($r,$g,$b,$a)';
    }
  }

  @override
  String toHexArgbString() => Color.convertToHexString(r, g, b, a);

  @override
  int get argbValue {
    var value = 0;
    if (a != null) {
      value = (a!.toInt() << 0x18);
    }
    value += (r << 0x10);
    value += (g << 0x08);
    value += b;
    return value;
  }

  Color get color => Color.createRgba(r, g, b, a);
  Hsla get hsla => Hsla.fromRgba(this);

  Rgba darker(num amount) => Color._createNewTintShadeFromRgba(this, -amount);
  Rgba lighter(num amount) => Color._createNewTintShadeFromRgba(this, amount);

  @override
  int get hashCode => toHexArgbString().hashCode;
}

class Hsla implements _StyleProperty, ColorBase {
  final num _h;
  final num _s;
  final num _l;
  final num? _a;

  Hsla(num hue, num saturation, num lightness, [num? alpha])
      : _h = (hue == 1) ? 0 : Color._clamp(hue, 0, 1),
        _s = Color._clamp(saturation, 0, 1),
        _l = Color._clamp(lightness, 0, 1),
        _a = (alpha != null) ? Color._clamp(alpha, 0, 1) : alpha;

  factory Hsla.fromString(String hexValue) {
    var rgba = Color.css('#${Color._convertCssToArgb(hexValue)}').rgba;
    return _createFromRgba(rgba.r, rgba.g, rgba.b, rgba.a);
  }

  factory Hsla.fromColor(Color color) {
    var rgba = color.rgba;
    return _createFromRgba(rgba.r, rgba.g, rgba.b, rgba.a);
  }

  factory Hsla.fromArgbValue(num value) {
    num a = (value.toInt() & 0xff000000) >> 0x18;
    var r = (value.toInt() & 0xff0000) >> 0x10;
    var g = (value.toInt() & 0xff00) >> 8;
    var b = value.toInt() & 0xff;

    a = double.parse((a / 255).toStringAsPrecision(2));

    return _createFromRgba(r, g, b, a);
  }

  factory Hsla.fromRgba(Rgba rgba) =>
      _createFromRgba(rgba.r, rgba.g, rgba.b, rgba.a);

  static Hsla _createFromRgba(num r, num g, num b, num? a) {
    r /= 255;
    g /= 255;
    b /= 255;

    num h;
    num s;
    num l;

    var minRgb = math.min(r, math.min(g, b));
    var maxRgb = math.max(r, math.max(g, b));
    l = (maxRgb + minRgb) / 2;
    if (l <= 0) {
      return Hsla(0, 0, l);
    }

    var vm = maxRgb - minRgb;
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
  bool operator ==(other) => Color.equal(this, other);

  @override
  String get cssExpression => (_a == null)
      ? 'hsl($hueDegrees,$saturationPercentage,$lightnessPercentage)'
      : 'hsla($hueDegrees,$saturationPercentage,$lightnessPercentage,$_a)';

  @override
  String toHexArgbString() => Rgba.fromHsla(this).toHexArgbString();

  @override
  int get argbValue => Color.hexToInt(toHexArgbString());

  Color get color => Color.createHsla(_h, _s, _l, _a);
  Rgba get rgba => Rgba.fromHsla(this);

  Hsla darker(num amount) => Hsla.fromRgba(Rgba.fromHsla(this).darker(amount));

  Hsla lighter(num amount) =>
      Hsla.fromRgba(Rgba.fromHsla(this).lighter(amount));

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

class Border implements _StyleProperty {
  final int? top, left, bottom, right;

  const Border([this.top, this.left, this.bottom, this.right]);

  Border.uniform(int amount)
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

class FontStyle {
  static const String normal = 'normal';

  static const String italic = 'italic';

  static const String oblique = 'oblique';
}

class FontVariant {
  static const String normal = 'normal';

  static const String smallCaps = 'small-caps';
}

class FontWeight {
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

class Font implements _StyleProperty {
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

  const Font(
      {this.size,
      this.family,
      this.weight,
      this.style,
      this.variant,
      this.lineHeight});

  static Font? merge(Font? a, Font? b) {
    if (a == null) return b;
    if (b == null) return a;
    return Font._merge(a, b);
  }

  Font._merge(Font a, Font b)
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

  Font scale(num ratio) => Font(
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
    if (other is! Font) return false;
    return other.size == size &&
        other.family == family &&
        other.weight == weight &&
        other.lineHeight == lineHeight &&
        other.style == style &&
        other.variant == variant;
  }

  String get _fontsAsString {
    var fonts = family.toString();
    return fonts.length > 2 ? fonts.substring(1, fonts.length - 1) : '';
  }
}

class BoxEdge {
  final num? left;

  final num? top;

  final num? right;

  final num? bottom;

  const BoxEdge([this.left, this.top, this.right, this.bottom]);

  const BoxEdge.clockwiseFromTop(this.top, this.right, this.bottom, this.left);

  const BoxEdge.uniform(num size)
      : top = size,
        left = size,
        bottom = size,
        right = size;

  factory BoxEdge.nonNull(BoxEdge? other) {
    if (other == null) return const BoxEdge(0, 0, 0, 0);
    var left = other.left;
    var top = other.top;
    var right = other.right;
    var bottom = other.bottom;
    var make = false;
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
    return make ? BoxEdge(left, top, right, bottom) : other;
  }

  static BoxEdge? merge(BoxEdge? x, BoxEdge? y) {
    if (x == null) return y;
    if (y == null) return x;
    return BoxEdge._merge(x, y);
  }

  BoxEdge._merge(BoxEdge x, BoxEdge y)
      : left = _mergeVal(x.left, y.left),
        top = _mergeVal(x.top, y.top),
        right = _mergeVal(x.right, y.right),
        bottom = _mergeVal(x.bottom, y.bottom);

  num get width => (left ?? 0) + (right ?? 0);

  num get height => (top ?? 0) + (bottom ?? 0);
}

T _mergeVal<T>(T x, T y) => y ?? x;
