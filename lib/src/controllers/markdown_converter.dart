// import 'package:rich_field_controller/src/models/rich_text_node.dart';
// import 'package:rich_field_controller/src/models/r_text_style.dart';
// import 'package:rich_field_controller/src/models/style_types.dart';
// import 'package:uuid/uuid.dart';
// import 'package:yaml/yaml.dart';

// class MarkdownConverter {
//   static const String _frontmatterStart = '---\n';
//   static const String _frontmatterEnd = '\n---\n';

//   RichTextNode fromMarkdown(String markdown) {
//     final styles = <RTextStyle>[];
//     String id;
//     String content;

//     // Extract frontmatter if present
//     if (markdown.startsWith(_frontmatterStart)) {
//       final endIndex = markdown.indexOf(_frontmatterEnd);
//       if (endIndex != -1) {
//         final frontmatter = markdown.substring(_frontmatterStart.length, endIndex);
//         final yamlMap = loadYaml(frontmatter) as YamlMap;
//         id = yamlMap['id'] as String? ?? const Uuid().v4();
//         content = markdown.substring(endIndex + _frontmatterEnd.length);
//       } else {
//         id = const Uuid().v4();
//         content = markdown;
//       }
//     } else {
//       id = const Uuid().v4();
//       content = markdown;
//     }

//     var text = content;
//     int offset = 0;

//     for (final style in StyleTypes.values) {
//       if (style.markdown.isNotEmpty) {
//         switch (style) {
//           case StyleTypes.unorderedList:
//             final unorderedListPattern = RegExp(r'^ {0,3}- (.+)$', multiLine: true);
//             text = text.replaceAllMapped(unorderedListPattern, (match) {
//               final start = match.start - offset;
//               final end = start + match[1]!.length;
//               styles.add(RTextStyle(start: start, end: end, style: style));
//               offset += 2; // Remove '- ' from the beginning
//               return match[1]!;
//             });
//             break;
//           case StyleTypes.link:
//             final linkPattern = RegExp(r'\[([^\]]+)\]\(([^\)]+)\)');
//             text = text.replaceAllMapped(linkPattern, (match) {
//               final start = match.start - offset;
//               final end = start + match[1]!.length;
//               styles.add(RTextStyle(
//                 start: start,
//                 end: end,
//                 style: style,
//                 data: {'url': match[2]},
//               ));
//               offset += match[0]!.length - match[1]!.length;
//               return match[1]!;
//             });
//             break;
//           case StyleTypes.image:
//             final imagePattern = RegExp(r'!\[([^\]]*)\]\(([^\)]+)\)');
//             text = text.replaceAllMapped(imagePattern, (match) {
//               final start = match.start - offset;
//               final end = start + match[1]!.length;
//               styles.add(RTextStyle(
//                 start: start,
//                 end: end,
//                 style: style,
//                 data: {'url': match[2], 'alt': match[1] ?? ''},
//               ));
//               offset += match[0]!.length - match[1]!.length;
//               return match[1]!;
//             });
//             break;
//           case StyleTypes.codeBlock:
//             final codeBlockPattern = RegExp(r'```(\w*)\n([\s\S]*?)\n```');
//             text = text.replaceAllMapped(codeBlockPattern, (match) {
//               final start = match.start - offset;
//               final end = start + match[2]!.length;
//               styles.add(RTextStyle(
//                 start: start,
//                 end: end,
//                 style: style,
//                 data: {'language': match[1] ?? ''},
//               ));
//               offset += match[0]!.length - match[2]!.length;
//               return match[2]!;
//             });
//             break;
//           default:
//             if (style.isBlock) {
//               final blockPattern =
//                   RegExp(r'^ {0,3}' + RegExp.escape(style.markdown) + r'(.+)$', multiLine: true);
//               text = text.replaceAllMapped(blockPattern, (match) {
//                 final start = match.start - offset;
//                 final end = start + match[1]!.length;
//                 styles.add(RTextStyle(start: start, end: end, style: style));
//                 offset += style.markdown.length;
//                 return match[1]!;
//               });
//             } else {
//               final pattern =
//                   RegExp(RegExp.escape(style.markdown) + r'(.*?)' + RegExp.escape(style.markdown));
//               text = text.replaceAllMapped(pattern, (match) {
//                 final start = match.start - offset;
//                 final end = start + match[1]!.length;
//                 styles.add(RTextStyle(start: start, end: end, style: style));
//                 offset += style.markdown.length * 2;
//                 return match[1]!;
//               });
//             }
//         }
//       }
//     }

//     return RichTextNode(id: id, text: text, styles: styles);
//   }

//   String toMarkdown(RichTextNode node) {
//     final buffer = StringBuffer();

//     // Add frontmatter with id
//     buffer.write(_frontmatterStart);
//     buffer.write('id: ${node.id}\n');
//     buffer.write(_frontmatterEnd);

//     int lastIndex = 0;

//     for (final style in node.styles) {
//       buffer.write(node.text.substring(lastIndex, style.start));
//       switch (style.style) {
//         case StyleTypes.unorderedList:
//           buffer.write('- ');
//           buffer.write(node.text.substring(style.start, style.end));
//           buffer.write('\n');
//           break;
//         case StyleTypes.link:
//           buffer.write(
//               '[${node.text.substring(style.start, style.end)}](${style.data?['url'] ?? ''})');
//           break;
//         case StyleTypes.image:
//           buffer.write('![${style.data?['alt'] ?? ''}](${style.data?['url'] ?? ''})');
//           break;
//         case StyleTypes.codeBlock:
//           buffer.write('```${style.data?['language'] ?? ''}\n');
//           buffer.write(node.text.substring(style.start, style.end));
//           buffer.write('\n```');
//           break;
//         default:
//           if (style.style.isBlock) {
//             buffer.write(style.style.markdown);
//             buffer.write(node.text.substring(style.start, style.end));
//             buffer.write('\n');
//           } else {
//             buffer.write(style.style.markdown);
//             buffer.write(node.text.substring(style.start, style.end));
//             buffer.write(style.style.markdown);
//           }
//       }
//       lastIndex = style.end;
//     }

//     buffer.write(node.text.substring(lastIndex));
//     return buffer.toString();
//   }
// }
