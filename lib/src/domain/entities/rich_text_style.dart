import 'package:equatable/equatable.dart';

class RichTextStyle extends Equatable {
  final bool isBold;
  final bool isItalic;
  final bool isStrikethrough;
  final bool isUnderline;
  final bool isCode;
  final int? headerLevel;
  final bool isBlockquote;
  final bool isLink;
  final String? linkUrl;
  final String? linkTitle;
  final bool isImage;
  final String? imageUrl;
  final String? imageAlt;
  final String? imageTitle;
  final bool isList;
  final bool isOrderedList;
  final int listIndent;
  final bool isCheckbox;
  final bool? checkboxStatus;
  final bool isHorizontalRule;
  final bool isSuperscript;
  final String? tableColumnAlignment;
  final bool isTableHeader;

  const RichTextStyle({
    this.isBold = false,
    this.isItalic = false,
    this.isStrikethrough = false,
    this.isUnderline = false,
    this.isCode = false,
    this.headerLevel,
    this.isBlockquote = false,
    this.isLink = false,
    this.linkUrl,
    this.linkTitle,
    this.isImage = false,
    this.imageUrl,
    this.imageAlt,
    this.imageTitle,
    this.isList = false,
    this.isOrderedList = false,
    this.listIndent = 0,
    this.isCheckbox = false,
    this.checkboxStatus,
    this.isHorizontalRule = false,
    this.isSuperscript = false,
    this.tableColumnAlignment,
    this.isTableHeader = false,
  });

  @override
  List<Object?> get props => [
        isBold,
        isItalic,
        isStrikethrough,
        isUnderline,
        isCode,
        headerLevel,
        isBlockquote,
        isLink,
        linkUrl,
        linkTitle,
        isImage,
        imageUrl,
        imageAlt,
        imageTitle,
        isList,
        isOrderedList,
        listIndent,
        isCheckbox,
        checkboxStatus,
        isHorizontalRule,
        isSuperscript,
        tableColumnAlignment,
        isTableHeader,
      ];
  RichTextStyle merge(RichTextStyle other) {
    return RichTextStyle(
      isBold: isBold || other.isBold,
      isItalic: isItalic || other.isItalic,
      isStrikethrough: isStrikethrough || other.isStrikethrough,
      isUnderline: isUnderline || other.isUnderline,
      isCode: isCode || other.isCode,
      headerLevel: other.headerLevel ?? headerLevel,
      isBlockquote: isBlockquote || other.isBlockquote,
      isLink: isLink || other.isLink,
      linkUrl: other.linkUrl ?? linkUrl,
      linkTitle: other.linkTitle ?? linkTitle,
      isImage: isImage || other.isImage,
      imageUrl: other.imageUrl ?? imageUrl,
      imageAlt: other.imageAlt ?? imageAlt,
      imageTitle: other.imageTitle ?? imageTitle,
      isList: isList || other.isList,
      isOrderedList: isOrderedList || other.isOrderedList,
      listIndent: listIndent > other.listIndent ? listIndent : other.listIndent,
      isCheckbox: isCheckbox || other.isCheckbox,
      checkboxStatus: other.checkboxStatus ?? checkboxStatus,
      isHorizontalRule: isHorizontalRule || other.isHorizontalRule,
      isSuperscript: isSuperscript || other.isSuperscript,
      tableColumnAlignment: tableColumnAlignment ?? other.tableColumnAlignment,
      isTableHeader: isTableHeader || other.isTableHeader,
    );
  }

  RichTextStyle copyWith({
    bool? isBold,
    bool? isItalic,
    bool? isStrikethrough,
    bool? isUnderline,
    bool? isCode,
    int? headerLevel,
    bool? isBlockquote,
    bool? isLink,
    String? linkUrl,
    String? linkTitle,
    bool? isImage,
    String? imageUrl,
    String? imageAlt,
    String? imageTitle,
    bool? isList,
    bool? isOrderedList,
    int? listIndent,
    bool? isCheckbox,
    bool? checkboxStatus,
    bool? isHorizontalRule,
    bool? isSuperscript,
    String? tableColumnAlignment,
    bool? isTableHeader,
  }) {
    return RichTextStyle(
      isBold: isBold ?? this.isBold,
      isItalic: isItalic ?? this.isItalic,
      isStrikethrough: isStrikethrough ?? this.isStrikethrough,
      isUnderline: isUnderline ?? this.isUnderline,
      isCode: isCode ?? this.isCode,
      headerLevel: headerLevel ?? this.headerLevel,
      isBlockquote: isBlockquote ?? this.isBlockquote,
      isLink: isLink ?? this.isLink,
      linkUrl: linkUrl ?? this.linkUrl,
      linkTitle: linkTitle ?? this.linkTitle,
      isImage: isImage ?? this.isImage,
      imageUrl: imageUrl ?? this.imageUrl,
      imageAlt: imageAlt ?? this.imageAlt,
      imageTitle: imageTitle ?? this.imageTitle,
      isList: isList ?? this.isList,
      isOrderedList: isOrderedList ?? this.isOrderedList,
      listIndent: listIndent ?? this.listIndent,
      isCheckbox: isCheckbox ?? this.isCheckbox,
      checkboxStatus: checkboxStatus ?? this.checkboxStatus,
      isHorizontalRule: isHorizontalRule ?? this.isHorizontalRule,
      isSuperscript: isSuperscript ?? this.isSuperscript,
      tableColumnAlignment: tableColumnAlignment ?? this.tableColumnAlignment,
      isTableHeader: isTableHeader ?? this.isTableHeader,
    );
  }
}
