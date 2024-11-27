 
class TextItem {
  final String id;
  final String content;
  final double x;
  final double y;
  final int fontSize;
  final String color;
  final String fontFamily;
  final bool isBold;
  final bool isItalic;
  final bool isUnderline;

  TextItem({
    required this.id,
    this.content = '',
    this.x = 0,
    this.y = 0,
    this.fontSize = 16,
    this.color = '#000000',
    this.fontFamily = 'Arial',
    this.isBold = false,
    this.isItalic = false,
    this.isUnderline = false,
  });

  TextItem copyWith({
    String? content,
    double? x,
    double? y,
    int? fontSize,
    String? color,
    String? fontFamily,
    bool? isBold,
    bool? isItalic,
    bool? isUnderline,
  }) {
    return TextItem(
      id: id,
      content: content ?? this.content,
      x: x ?? this.x,
      y: y ?? this.y,
      fontSize: fontSize ?? this.fontSize,
      color: color ?? this.color,
      fontFamily: fontFamily ?? this.fontFamily,
      isBold: isBold ?? this.isBold,
      isItalic: isItalic ?? this.isItalic,
      isUnderline: isUnderline ?? this.isUnderline,
    );
  }

  TextItem printTextItem() {
    print('TextItem: $id, $content, $x, $y, $fontSize, $color, $fontFamily, $isBold, $isItalic, $isUnderline');
    return this;
  }
}
