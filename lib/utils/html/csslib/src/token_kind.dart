// ignore_for_file: constant_identifier_names

part of '../parser.dart';

class CssTokenKind {
  static const int UNUSED = 0;
  static const int END_OF_FILE = 1;
  static const int LPAREN = 2;
  static const int RPAREN = 3;
  static const int LBRACK = 4;
  static const int RBRACK = 5;
  static const int LBRACE = 6;
  static const int RBRACE = 7;
  static const int DOT = 8;
  static const int SEMICOLON = 9;

  static const int AT = 10;
  static const int HASH = 11;
  static const int PLUS = 12;
  static const int GREATER = 13;
  static const int TILDE = 14;
  static const int ASTERISK = 15;
  static const int NAMESPACE = 16;
  static const int COLON = 17;
  static const int PRIVATE_NAME = 18;
  static const int COMMA = 19;
  static const int SPACE = 20;
  static const int TAB = 21;
  static const int NEWLINE = 22;
  static const int RETURN = 23;
  static const int PERCENT = 24;
  static const int SINGLE_QUOTE = 25;
  static const int DOUBLE_QUOTE = 26;
  static const int SLASH = 27;
  static const int EQUALS = 28;
  static const int CARET = 30;
  static const int DOLLAR = 31;
  static const int LESS = 32;
  static const int BANG = 33;
  static const int MINUS = 34;
  static const int BACKSLASH = 35;
  static const int AMPERSAND = 36;

  static const int INTEGER = 60;

  static const int HEX_INTEGER = 61;

  static const int DOUBLE = 62;

  static const int WHITESPACE = 63;

  static const int COMMENT = 64;

  static const int ERROR = 65;

  static const int INCOMPLETE_STRING = 66;

  static const int INCOMPLETE_COMMENT = 67;

  static const int VAR_DEFINITION = 400;
  static const int VAR_USAGE = 401;

  static const int STRING = 500;
  static const int STRING_PART = 501;
  static const int NUMBER = 502;
  static const int HEX_NUMBER = 503;
  static const int HTML_COMMENT = 504;
  static const int IMPORTANT = 505;
  static const int CDATA_START = 506;
  static const int CDATA_END = 507;
  static const int UNICODE_RANGE = 508;
  static const int HEX_RANGE = 509;
  static const int IDENTIFIER = 511;

  static const int SELECTOR_EXPRESSION = 512;
  static const int COMBINATOR_NONE = 513;
  static const int COMBINATOR_DESCENDANT = 514;
  static const int COMBINATOR_PLUS = 515;
  static const int COMBINATOR_GREATER = 516;
  static const int COMBINATOR_TILDE = 517;

  static const int UNARY_OP_NONE = 518;

  static const int INCLUDES = 530;
  static const int DASH_MATCH = 531;
  static const int PREFIX_MATCH = 532;
  static const int SUFFIX_MATCH = 533;
  static const int SUBSTRING_MATCH = 534;
  static const int NO_MATCH = 535;

  static const int UNIT_EM = 600;
  static const int UNIT_EX = 601;
  static const int UNIT_LENGTH_PX = 602;
  static const int UNIT_LENGTH_CM = 603;
  static const int UNIT_LENGTH_MM = 604;
  static const int UNIT_LENGTH_IN = 605;
  static const int UNIT_LENGTH_PT = 606;
  static const int UNIT_LENGTH_PC = 607;
  static const int UNIT_ANGLE_DEG = 608;
  static const int UNIT_ANGLE_RAD = 609;
  static const int UNIT_ANGLE_GRAD = 610;
  static const int UNIT_ANGLE_TURN = 611;
  static const int UNIT_TIME_MS = 612;
  static const int UNIT_TIME_S = 613;
  static const int UNIT_FREQ_HZ = 614;
  static const int UNIT_FREQ_KHZ = 615;
  static const int UNIT_PERCENT = 616;
  static const int UNIT_FRACTION = 617;
  static const int UNIT_RESOLUTION_DPI = 618;
  static const int UNIT_RESOLUTION_DPCM = 619;
  static const int UNIT_RESOLUTION_DPPX = 620;
  static const int UNIT_CH = 621;
  static const int UNIT_REM = 622;
  static const int UNIT_VIEWPORT_VW = 623;
  static const int UNIT_VIEWPORT_VH = 624;
  static const int UNIT_VIEWPORT_VMIN = 625;
  static const int UNIT_VIEWPORT_VMAX = 626;

  static const int DIRECTIVE_NONE = 640;
  static const int DIRECTIVE_IMPORT = 641;
  static const int DIRECTIVE_MEDIA = 642;
  static const int DIRECTIVE_PAGE = 643;
  static const int DIRECTIVE_CHARSET = 644;
  static const int DIRECTIVE_STYLET = 645;
  static const int DIRECTIVE_KEYFRAMES = 646;
  static const int DIRECTIVE_WEB_KIT_KEYFRAMES = 647;
  static const int DIRECTIVE_MOZ_KEYFRAMES = 648;
  static const int DIRECTIVE_MS_KEYFRAMES = 649;
  static const int DIRECTIVE_O_KEYFRAMES = 650;
  static const int DIRECTIVE_FONTFACE = 651;
  static const int DIRECTIVE_NAMESPACE = 652;
  static const int DIRECTIVE_HOST = 653;
  static const int DIRECTIVE_MIXIN = 654;
  static const int DIRECTIVE_INCLUDE = 655;
  static const int DIRECTIVE_CONTENT = 656;
  static const int DIRECTIVE_EXTEND = 657;
  static const int DIRECTIVE_MOZ_DOCUMENT = 658;
  static const int DIRECTIVE_SUPPORTS = 659;
  static const int DIRECTIVE_VIEWPORT = 660;
  static const int DIRECTIVE_MS_VIEWPORT = 661;

  static const int MEDIA_OP_ONLY = 665;
  static const int MEDIA_OP_NOT = 666;
  static const int MEDIA_OP_AND = 667;

  static const int MARGIN_DIRECTIVE_TOPLEFTCORNER = 670;
  static const int MARGIN_DIRECTIVE_TOPLEFT = 671;
  static const int MARGIN_DIRECTIVE_TOPCENTER = 672;
  static const int MARGIN_DIRECTIVE_TOPRIGHT = 673;
  static const int MARGIN_DIRECTIVE_TOPRIGHTCORNER = 674;
  static const int MARGIN_DIRECTIVE_BOTTOMLEFTCORNER = 675;
  static const int MARGIN_DIRECTIVE_BOTTOMLEFT = 676;
  static const int MARGIN_DIRECTIVE_BOTTOMCENTER = 677;
  static const int MARGIN_DIRECTIVE_BOTTOMRIGHT = 678;
  static const int MARGIN_DIRECTIVE_BOTTOMRIGHTCORNER = 679;
  static const int MARGIN_DIRECTIVE_LEFTTOP = 680;
  static const int MARGIN_DIRECTIVE_LEFTMIDDLE = 681;
  static const int MARGIN_DIRECTIVE_LEFTBOTTOM = 682;
  static const int MARGIN_DIRECTIVE_RIGHTTOP = 683;
  static const int MARGIN_DIRECTIVE_RIGHTMIDDLE = 684;
  static const int MARGIN_DIRECTIVE_RIGHTBOTTOM = 685;

  static const int CLASS_NAME = 700;
  static const int ELEMENT_NAME = 701;
  static const int HASH_NAME = 702;
  static const int ATTRIBUTE_NAME = 703;
  static const int PSEUDO_ELEMENT_NAME = 704;
  static const int PSEUDO_CLASS_NAME = 705;
  static const int NEGATION = 706;

  static const List<Map<String, dynamic>> _DIRECTIVES = [
    {'type': CssTokenKind.DIRECTIVE_IMPORT, 'value': 'import'},
    {'type': CssTokenKind.DIRECTIVE_MEDIA, 'value': 'media'},
    {'type': CssTokenKind.DIRECTIVE_PAGE, 'value': 'page'},
    {'type': CssTokenKind.DIRECTIVE_CHARSET, 'value': 'charset'},
    {'type': CssTokenKind.DIRECTIVE_STYLET, 'value': 'stylet'},
    {'type': CssTokenKind.DIRECTIVE_KEYFRAMES, 'value': 'keyframes'},
    {
      'type': CssTokenKind.DIRECTIVE_WEB_KIT_KEYFRAMES,
      'value': '-webkit-keyframes'
    },
    {'type': CssTokenKind.DIRECTIVE_MOZ_KEYFRAMES, 'value': '-moz-keyframes'},
    {'type': CssTokenKind.DIRECTIVE_MS_KEYFRAMES, 'value': '-ms-keyframes'},
    {'type': CssTokenKind.DIRECTIVE_O_KEYFRAMES, 'value': '-o-keyframes'},
    {'type': CssTokenKind.DIRECTIVE_FONTFACE, 'value': 'font-face'},
    {'type': CssTokenKind.DIRECTIVE_NAMESPACE, 'value': 'namespace'},
    {'type': CssTokenKind.DIRECTIVE_HOST, 'value': 'host'},
    {'type': CssTokenKind.DIRECTIVE_MIXIN, 'value': 'mixin'},
    {'type': CssTokenKind.DIRECTIVE_INCLUDE, 'value': 'include'},
    {'type': CssTokenKind.DIRECTIVE_CONTENT, 'value': 'content'},
    {'type': CssTokenKind.DIRECTIVE_EXTEND, 'value': 'extend'},
    {'type': CssTokenKind.DIRECTIVE_MOZ_DOCUMENT, 'value': '-moz-document'},
    {'type': CssTokenKind.DIRECTIVE_SUPPORTS, 'value': 'supports'},
    {'type': CssTokenKind.DIRECTIVE_VIEWPORT, 'value': 'viewport'},
    {'type': CssTokenKind.DIRECTIVE_MS_VIEWPORT, 'value': '-ms-viewport'},
  ];

  static const List<Map<String, dynamic>> MEDIA_OPERATORS = [
    {'type': CssTokenKind.MEDIA_OP_ONLY, 'value': 'only'},
    {'type': CssTokenKind.MEDIA_OP_NOT, 'value': 'not'},
    {'type': CssTokenKind.MEDIA_OP_AND, 'value': 'and'},
  ];

  static const List<Map<String, dynamic>> MARGIN_DIRECTIVES = [
    {
      'type': CssTokenKind.MARGIN_DIRECTIVE_TOPLEFTCORNER,
      'value': 'top-left-corner'
    },
    {'type': CssTokenKind.MARGIN_DIRECTIVE_TOPLEFT, 'value': 'top-left'},
    {'type': CssTokenKind.MARGIN_DIRECTIVE_TOPCENTER, 'value': 'top-center'},
    {'type': CssTokenKind.MARGIN_DIRECTIVE_TOPRIGHT, 'value': 'top-right'},
    {
      'type': CssTokenKind.MARGIN_DIRECTIVE_TOPRIGHTCORNER,
      'value': 'top-right-corner'
    },
    {
      'type': CssTokenKind.MARGIN_DIRECTIVE_BOTTOMLEFTCORNER,
      'value': 'bottom-left-corner'
    },
    {'type': CssTokenKind.MARGIN_DIRECTIVE_BOTTOMLEFT, 'value': 'bottom-left'},
    {
      'type': CssTokenKind.MARGIN_DIRECTIVE_BOTTOMCENTER,
      'value': 'bottom-center'
    },
    {
      'type': CssTokenKind.MARGIN_DIRECTIVE_BOTTOMRIGHT,
      'value': 'bottom-right'
    },
    {
      'type': CssTokenKind.MARGIN_DIRECTIVE_BOTTOMRIGHTCORNER,
      'value': 'bottom-right-corner'
    },
    {'type': CssTokenKind.MARGIN_DIRECTIVE_LEFTTOP, 'value': 'left-top'},
    {'type': CssTokenKind.MARGIN_DIRECTIVE_LEFTMIDDLE, 'value': 'left-middle'},
    {'type': CssTokenKind.MARGIN_DIRECTIVE_LEFTBOTTOM, 'value': 'right-bottom'},
    {'type': CssTokenKind.MARGIN_DIRECTIVE_RIGHTTOP, 'value': 'right-top'},
    {
      'type': CssTokenKind.MARGIN_DIRECTIVE_RIGHTMIDDLE,
      'value': 'right-middle'
    },
    {
      'type': CssTokenKind.MARGIN_DIRECTIVE_RIGHTBOTTOM,
      'value': 'right-bottom'
    },
  ];

  static const List<Map<String, dynamic>> _UNITS = [
    {'unit': CssTokenKind.UNIT_EM, 'value': 'em'},
    {'unit': CssTokenKind.UNIT_EX, 'value': 'ex'},
    {'unit': CssTokenKind.UNIT_LENGTH_PX, 'value': 'px'},
    {'unit': CssTokenKind.UNIT_LENGTH_CM, 'value': 'cm'},
    {'unit': CssTokenKind.UNIT_LENGTH_MM, 'value': 'mm'},
    {'unit': CssTokenKind.UNIT_LENGTH_IN, 'value': 'in'},
    {'unit': CssTokenKind.UNIT_LENGTH_PT, 'value': 'pt'},
    {'unit': CssTokenKind.UNIT_LENGTH_PC, 'value': 'pc'},
    {'unit': CssTokenKind.UNIT_ANGLE_DEG, 'value': 'deg'},
    {'unit': CssTokenKind.UNIT_ANGLE_RAD, 'value': 'rad'},
    {'unit': CssTokenKind.UNIT_ANGLE_GRAD, 'value': 'grad'},
    {'unit': CssTokenKind.UNIT_ANGLE_TURN, 'value': 'turn'},
    {'unit': CssTokenKind.UNIT_TIME_MS, 'value': 'ms'},
    {'unit': CssTokenKind.UNIT_TIME_S, 'value': 's'},
    {'unit': CssTokenKind.UNIT_FREQ_HZ, 'value': 'hz'},
    {'unit': CssTokenKind.UNIT_FREQ_KHZ, 'value': 'khz'},
    {'unit': CssTokenKind.UNIT_FRACTION, 'value': 'fr'},
    {'unit': CssTokenKind.UNIT_RESOLUTION_DPI, 'value': 'dpi'},
    {'unit': CssTokenKind.UNIT_RESOLUTION_DPCM, 'value': 'dpcm'},
    {'unit': CssTokenKind.UNIT_RESOLUTION_DPPX, 'value': 'dppx'},
    {'unit': CssTokenKind.UNIT_CH, 'value': 'ch'},
    {'unit': CssTokenKind.UNIT_REM, 'value': 'rem'},
    {'unit': CssTokenKind.UNIT_VIEWPORT_VW, 'value': 'vw'},
    {'unit': CssTokenKind.UNIT_VIEWPORT_VH, 'value': 'vh'},
    {'unit': CssTokenKind.UNIT_VIEWPORT_VMIN, 'value': 'vmin'},
    {'unit': CssTokenKind.UNIT_VIEWPORT_VMAX, 'value': 'vmax'},
  ];

  static const int ASCII_UPPER_A = 65;
  static const int ASCII_UPPER_Z = 90;

  static const List<Map> _EXTENDED_COLOR_NAMES = [
    {'name': 'aliceblue', 'value': 0xF08FF},
    {'name': 'antiquewhite', 'value': 0xFAEBD7},
    {'name': 'aqua', 'value': 0x00FFFF},
    {'name': 'aquamarine', 'value': 0x7FFFD4},
    {'name': 'azure', 'value': 0xF0FFFF},
    {'name': 'beige', 'value': 0xF5F5DC},
    {'name': 'bisque', 'value': 0xFFE4C4},
    {'name': 'black', 'value': 0x000000},
    {'name': 'blanchedalmond', 'value': 0xFFEBCD},
    {'name': 'blue', 'value': 0x0000FF},
    {'name': 'blueviolet', 'value': 0x8A2BE2},
    {'name': 'brown', 'value': 0xA52A2A},
    {'name': 'burlywood', 'value': 0xDEB887},
    {'name': 'cadetblue', 'value': 0x5F9EA0},
    {'name': 'chartreuse', 'value': 0x7FFF00},
    {'name': 'chocolate', 'value': 0xD2691E},
    {'name': 'coral', 'value': 0xFF7F50},
    {'name': 'cornflowerblue', 'value': 0x6495ED},
    {'name': 'cornsilk', 'value': 0xFFF8DC},
    {'name': 'crimson', 'value': 0xDC143C},
    {'name': 'cyan', 'value': 0x00FFFF},
    {'name': 'darkblue', 'value': 0x00008B},
    {'name': 'darkcyan', 'value': 0x008B8B},
    {'name': 'darkgoldenrod', 'value': 0xB8860B},
    {'name': 'darkgray', 'value': 0xA9A9A9},
    {'name': 'darkgreen', 'value': 0x006400},
    {'name': 'darkgrey', 'value': 0xA9A9A9},
    {'name': 'darkkhaki', 'value': 0xBDB76B},
    {'name': 'darkmagenta', 'value': 0x8B008B},
    {'name': 'darkolivegreen', 'value': 0x556B2F},
    {'name': 'darkorange', 'value': 0xFF8C00},
    {'name': 'darkorchid', 'value': 0x9932CC},
    {'name': 'darkred', 'value': 0x8B0000},
    {'name': 'darksalmon', 'value': 0xE9967A},
    {'name': 'darkseagreen', 'value': 0x8FBC8F},
    {'name': 'darkslateblue', 'value': 0x483D8B},
    {'name': 'darkslategray', 'value': 0x2F4F4F},
    {'name': 'darkslategrey', 'value': 0x2F4F4F},
    {'name': 'darkturquoise', 'value': 0x00CED1},
    {'name': 'darkviolet', 'value': 0x9400D3},
    {'name': 'deeppink', 'value': 0xFF1493},
    {'name': 'deepskyblue', 'value': 0x00BFFF},
    {'name': 'dimgray', 'value': 0x696969},
    {'name': 'dimgrey', 'value': 0x696969},
    {'name': 'dodgerblue', 'value': 0x1E90FF},
    {'name': 'firebrick', 'value': 0xB22222},
    {'name': 'floralwhite', 'value': 0xFFFAF0},
    {'name': 'forestgreen', 'value': 0x228B22},
    {'name': 'fuchsia', 'value': 0xFF00FF},
    {'name': 'gainsboro', 'value': 0xDCDCDC},
    {'name': 'ghostwhite', 'value': 0xF8F8FF},
    {'name': 'gold', 'value': 0xFFD700},
    {'name': 'goldenrod', 'value': 0xDAA520},
    {'name': 'gray', 'value': 0x808080},
    {'name': 'green', 'value': 0x008000},
    {'name': 'greenyellow', 'value': 0xADFF2F},
    {'name': 'grey', 'value': 0x808080},
    {'name': 'honeydew', 'value': 0xF0FFF0},
    {'name': 'hotpink', 'value': 0xFF69B4},
    {'name': 'indianred', 'value': 0xCD5C5C},
    {'name': 'indigo', 'value': 0x4B0082},
    {'name': 'ivory', 'value': 0xFFFFF0},
    {'name': 'khaki', 'value': 0xF0E68C},
    {'name': 'lavender', 'value': 0xE6E6FA},
    {'name': 'lavenderblush', 'value': 0xFFF0F5},
    {'name': 'lawngreen', 'value': 0x7CFC00},
    {'name': 'lemonchiffon', 'value': 0xFFFACD},
    {'name': 'lightblue', 'value': 0xADD8E6},
    {'name': 'lightcoral', 'value': 0xF08080},
    {'name': 'lightcyan', 'value': 0xE0FFFF},
    {'name': 'lightgoldenrodyellow', 'value': 0xFAFAD2},
    {'name': 'lightgray', 'value': 0xD3D3D3},
    {'name': 'lightgreen', 'value': 0x90EE90},
    {'name': 'lightgrey', 'value': 0xD3D3D3},
    {'name': 'lightpink', 'value': 0xFFB6C1},
    {'name': 'lightsalmon', 'value': 0xFFA07A},
    {'name': 'lightseagreen', 'value': 0x20B2AA},
    {'name': 'lightskyblue', 'value': 0x87CEFA},
    {'name': 'lightslategray', 'value': 0x778899},
    {'name': 'lightslategrey', 'value': 0x778899},
    {'name': 'lightsteelblue', 'value': 0xB0C4DE},
    {'name': 'lightyellow', 'value': 0xFFFFE0},
    {'name': 'lime', 'value': 0x00FF00},
    {'name': 'limegreen', 'value': 0x32CD32},
    {'name': 'linen', 'value': 0xFAF0E6},
    {'name': 'magenta', 'value': 0xFF00FF},
    {'name': 'maroon', 'value': 0x800000},
    {'name': 'mediumaquamarine', 'value': 0x66CDAA},
    {'name': 'mediumblue', 'value': 0x0000CD},
    {'name': 'mediumorchid', 'value': 0xBA55D3},
    {'name': 'mediumpurple', 'value': 0x9370DB},
    {'name': 'mediumseagreen', 'value': 0x3CB371},
    {'name': 'mediumslateblue', 'value': 0x7B68EE},
    {'name': 'mediumspringgreen', 'value': 0x00FA9A},
    {'name': 'mediumturquoise', 'value': 0x48D1CC},
    {'name': 'mediumvioletred', 'value': 0xC71585},
    {'name': 'midnightblue', 'value': 0x191970},
    {'name': 'mintcream', 'value': 0xF5FFFA},
    {'name': 'mistyrose', 'value': 0xFFE4E1},
    {'name': 'moccasin', 'value': 0xFFE4B5},
    {'name': 'navajowhite', 'value': 0xFFDEAD},
    {'name': 'navy', 'value': 0x000080},
    {'name': 'oldlace', 'value': 0xFDF5E6},
    {'name': 'olive', 'value': 0x808000},
    {'name': 'olivedrab', 'value': 0x6B8E23},
    {'name': 'orange', 'value': 0xFFA500},
    {'name': 'orangered', 'value': 0xFF4500},
    {'name': 'orchid', 'value': 0xDA70D6},
    {'name': 'palegoldenrod', 'value': 0xEEE8AA},
    {'name': 'palegreen', 'value': 0x98FB98},
    {'name': 'paleturquoise', 'value': 0xAFEEEE},
    {'name': 'palevioletred', 'value': 0xDB7093},
    {'name': 'papayawhip', 'value': 0xFFEFD5},
    {'name': 'peachpuff', 'value': 0xFFDAB9},
    {'name': 'peru', 'value': 0xCD853F},
    {'name': 'pink', 'value': 0xFFC0CB},
    {'name': 'plum', 'value': 0xDDA0DD},
    {'name': 'powderblue', 'value': 0xB0E0E6},
    {'name': 'purple', 'value': 0x800080},
    {'name': 'red', 'value': 0xFF0000},
    {'name': 'rosybrown', 'value': 0xBC8F8F},
    {'name': 'royalblue', 'value': 0x4169E1},
    {'name': 'saddlebrown', 'value': 0x8B4513},
    {'name': 'salmon', 'value': 0xFA8072},
    {'name': 'sandybrown', 'value': 0xF4A460},
    {'name': 'seagreen', 'value': 0x2E8B57},
    {'name': 'seashell', 'value': 0xFFF5EE},
    {'name': 'sienna', 'value': 0xA0522D},
    {'name': 'silver', 'value': 0xC0C0C0},
    {'name': 'skyblue', 'value': 0x87CEEB},
    {'name': 'slateblue', 'value': 0x6A5ACD},
    {'name': 'slategray', 'value': 0x708090},
    {'name': 'slategrey', 'value': 0x708090},
    {'name': 'snow', 'value': 0xFFFAFA},
    {'name': 'springgreen', 'value': 0x00FF7F},
    {'name': 'steelblue', 'value': 0x4682B4},
    {'name': 'tan', 'value': 0xD2B48C},
    {'name': 'teal', 'value': 0x008080},
    {'name': 'thistle', 'value': 0xD8BFD8},
    {'name': 'tomato', 'value': 0xFF6347},
    {'name': 'turquoise', 'value': 0x40E0D0},
    {'name': 'violet', 'value': 0xEE82EE},
    {'name': 'wheat', 'value': 0xF5DEB3},
    {'name': 'white', 'value': 0xFFFFFF},
    {'name': 'whitesmoke', 'value': 0xF5F5F5},
    {'name': 'yellow', 'value': 0xFFFF00},
    {'name': 'yellowgreen', 'value': 0x9ACD32},
  ];

  static bool isPredefinedName(String name) {
    int nameLen = name.length;
    if (matchUnits(name, 0, nameLen) == -1 ||
        matchDirectives(name, 0, nameLen) == -1 ||
        matchMarginDirectives(name, 0, nameLen) == -1 ||
        matchColorName(name) == null) {
      return false;
    }

    return true;
  }

  static int matchList(Iterable<Map<String, dynamic>> identList,
      String tokenField, String text, int offset, int length) {
    for (final Map entry in identList) {
      final String ident = entry['value'] as String;

      if (length == ident.length) {
        int idx = offset;
        bool match = true;
        for (int i = 0; i < ident.length; i++) {
          int identChar = ident.codeUnitAt(i);
          int char = text.codeUnitAt(idx++);
          match = match &&
              (char == identChar ||
                  ((char >= ASCII_UPPER_A && char <= ASCII_UPPER_Z) &&
                      (char + 32) == identChar));
          if (!match) {
            break;
          }
        }

        if (match) {
          return entry[tokenField] as int;
        }
      }
    }

    return -1;
  }

  static int matchUnits(String text, int offset, int length) {
    return matchList(_UNITS, 'unit', text, offset, length);
  }

  static int matchDirectives(String text, int offset, int length) {
    return matchList(_DIRECTIVES, 'type', text, offset, length);
  }

  static int matchMarginDirectives(String text, int offset, int length) {
    return matchList(MARGIN_DIRECTIVES, 'type', text, offset, length);
  }

  static int matchMediaOperator(String text, int offset, int length) {
    return matchList(MEDIA_OPERATORS, 'type', text, offset, length);
  }

  static String? idToValue(Iterable<Object?> identList, int tokenId) {
    for (Object? entry in identList) {
      entry as Map<String, Object?>;
      if (tokenId == entry['type']) {
        return entry['value'] as String?;
      }
    }

    return null;
  }

  static String? unitToString(int unitTokenToFind) {
    if (unitTokenToFind == CssTokenKind.PERCENT) {
      return '%';
    } else {
      for (final Map entry in _UNITS) {
        final int unit = entry['unit'] as int;
        if (unit == unitTokenToFind) {
          return entry['value'] as String?;
        }
      }
    }

    return '<BAD UNIT>';
  }

  static Map? matchColorName(String text) {
    String name = text.toLowerCase();
    for (Map<dynamic, dynamic> color in _EXTENDED_COLOR_NAMES) {
      if (color['name'] == name) return color;
    }
    return null;
  }

  static int colorValue(Map entry) {
    return entry['value'] as int;
  }

  static String? hexToColorName(hexValue) {
    for (final Map entry in _EXTENDED_COLOR_NAMES) {
      if (entry['value'] == hexValue) {
        return entry['name'] as String?;
      }
    }

    return null;
  }

  static String decimalToHex(int number, [int minDigits = 1]) {
    const HEXDIGITS = '0123456789abcdef';

    List<String> result = <String>[];

    int dividend = number >> 4;
    int remain = number % 16;
    result.add(HEXDIGITS[remain]);
    while (dividend != 0) {
      remain = dividend % 16;
      dividend >>= 4;
      result.add(HEXDIGITS[remain]);
    }

    StringBuffer invertResult = StringBuffer();
    int paddings = minDigits - result.length;
    while (paddings-- > 0) {
      invertResult.write('0');
    }
    for (int i = result.length - 1; i >= 0; i--) {
      invertResult.write(result[i]);
    }

    return invertResult.toString();
  }

  static String kindToString(int kind) {
    switch (kind) {
      case CssTokenKind.UNUSED:
        return 'ERROR';
      case CssTokenKind.END_OF_FILE:
        return 'end of file';
      case CssTokenKind.LPAREN:
        return '(';
      case CssTokenKind.RPAREN:
        return ')';
      case CssTokenKind.LBRACK:
        return '[';
      case CssTokenKind.RBRACK:
        return ']';
      case CssTokenKind.LBRACE:
        return '{';
      case CssTokenKind.RBRACE:
        return '}';
      case CssTokenKind.DOT:
        return '.';
      case CssTokenKind.SEMICOLON:
        return ';';
      case CssTokenKind.AT:
        return '@';
      case CssTokenKind.HASH:
        return '#';
      case CssTokenKind.PLUS:
        return '+';
      case CssTokenKind.GREATER:
        return '>';
      case CssTokenKind.TILDE:
        return '~';
      case CssTokenKind.ASTERISK:
        return '*';
      case CssTokenKind.NAMESPACE:
        return '|';
      case CssTokenKind.COLON:
        return ':';
      case CssTokenKind.PRIVATE_NAME:
        return '_';
      case CssTokenKind.COMMA:
        return ',';
      case CssTokenKind.SPACE:
        return ' ';
      case CssTokenKind.TAB:
        return '\t';
      case CssTokenKind.NEWLINE:
        return '\n';
      case CssTokenKind.RETURN:
        return '\r';
      case CssTokenKind.PERCENT:
        return '%';
      case CssTokenKind.SINGLE_QUOTE:
        return "'";
      case CssTokenKind.DOUBLE_QUOTE:
        return '"';
      case CssTokenKind.SLASH:
        return '/';
      case CssTokenKind.EQUALS:
        return '=';
      case CssTokenKind.CARET:
        return '^';
      case CssTokenKind.DOLLAR:
        return '\$';
      case CssTokenKind.LESS:
        return '<';
      case CssTokenKind.BANG:
        return '!';
      case CssTokenKind.MINUS:
        return '-';
      case CssTokenKind.BACKSLASH:
        return '\\';
      default:
        throw 'Unknown TOKEN';
    }
  }

  static bool isKindIdentifier(int kind) {
    switch (kind) {
      case CssTokenKind.DIRECTIVE_IMPORT:
      case CssTokenKind.DIRECTIVE_MEDIA:
      case CssTokenKind.DIRECTIVE_PAGE:
      case CssTokenKind.DIRECTIVE_CHARSET:
      case CssTokenKind.DIRECTIVE_STYLET:
      case CssTokenKind.DIRECTIVE_KEYFRAMES:
      case CssTokenKind.DIRECTIVE_WEB_KIT_KEYFRAMES:
      case CssTokenKind.DIRECTIVE_MOZ_KEYFRAMES:
      case CssTokenKind.DIRECTIVE_MS_KEYFRAMES:
      case CssTokenKind.DIRECTIVE_O_KEYFRAMES:
      case CssTokenKind.DIRECTIVE_FONTFACE:
      case CssTokenKind.DIRECTIVE_NAMESPACE:
      case CssTokenKind.DIRECTIVE_HOST:
      case CssTokenKind.DIRECTIVE_MIXIN:
      case CssTokenKind.DIRECTIVE_INCLUDE:
      case CssTokenKind.DIRECTIVE_CONTENT:
      case CssTokenKind.UNIT_EM:
      case CssTokenKind.UNIT_EX:
      case CssTokenKind.UNIT_LENGTH_PX:
      case CssTokenKind.UNIT_LENGTH_CM:
      case CssTokenKind.UNIT_LENGTH_MM:
      case CssTokenKind.UNIT_LENGTH_IN:
      case CssTokenKind.UNIT_LENGTH_PT:
      case CssTokenKind.UNIT_LENGTH_PC:
      case CssTokenKind.UNIT_ANGLE_DEG:
      case CssTokenKind.UNIT_ANGLE_RAD:
      case CssTokenKind.UNIT_ANGLE_GRAD:
      case CssTokenKind.UNIT_TIME_MS:
      case CssTokenKind.UNIT_TIME_S:
      case CssTokenKind.UNIT_FREQ_HZ:
      case CssTokenKind.UNIT_FREQ_KHZ:
      case CssTokenKind.UNIT_FRACTION:
        return true;
      default:
        return false;
    }
  }

  static bool isIdentifier(int kind) {
    return kind == IDENTIFIER;
  }
}

class CssTokenChar {
  static const int UNUSED = -1;
  static const int END_OF_FILE = 0;
  static const int LPAREN = 0x28;
  static const int RPAREN = 0x29;
  static const int LBRACK = 0x5b;
  static const int RBRACK = 0x5d;
  static const int LBRACE = 0x7b;
  static const int RBRACE = 0x7d;
  static const int DOT = 0x2e;
  static const int SEMICOLON = 0x3b;
  static const int AT = 0x40;
  static const int HASH = 0x23;
  static const int PLUS = 0x2b;
  static const int GREATER = 0x3e;
  static const int TILDE = 0x7e;
  static const int ASTERISK = 0x2a;
  static const int NAMESPACE = 0x7c;
  static const int COLON = 0x3a;
  static const int PRIVATE_NAME = 0x5f;
  static const int COMMA = 0x2c;
  static const int SPACE = 0x20;
  static const int TAB = 0x9;
  static const int NEWLINE = 0xa;
  static const int RETURN = 0xd;
  static const int BACKSPACE = 0x8;
  static const int FF = 0xc;
  static const int VT = 0xb;
  static const int PERCENT = 0x25;
  static const int SINGLE_QUOTE = 0x27;
  static const int DOUBLE_QUOTE = 0x22;
  static const int SLASH = 0x2f;
  static const int EQUALS = 0x3d;
  static const int OR = 0x7c;
  static const int CARET = 0x5e;
  static const int DOLLAR = 0x24;
  static const int LESS = 0x3c;
  static const int BANG = 0x21;
  static const int MINUS = 0x2d;
  static const int BACKSLASH = 0x5c;
  static const int AMPERSAND = 0x26;
}
