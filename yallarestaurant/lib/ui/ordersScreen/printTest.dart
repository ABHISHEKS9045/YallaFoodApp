// import 'dart:typed_data';
// import 'package:esc_pos_utils/esc_pos_utils.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:sunmi_printer_plus/column_maker.dart';
// import 'package:sunmi_printer_plus/enums.dart';
// import 'dart:async';
//
// import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';
// import 'package:sunmi_printer_plus/sunmi_style.dart';
//
//
//
//
// class PrintTestScreen extends StatefulWidget {
//   const PrintTestScreen({Key? key}) : super(key: key);
//
//   @override
//   _PrintTestScreenState createState() => _PrintTestScreenState();
// }
//
// class _PrintTestScreenState extends State<PrintTestScreen> {
//
//
//
//   static const platform = MethodChannel('samples.flutter.dev/q1Printer');
//
//   String resultValue = '.....';
//
//   Future<void> _goPrint() async {
//     String resultValue;
//     try {
//       final int result = await platform.invokeMethod('goPrint');
//       resultValue = 'printer result $result % .';
//     } on PlatformException catch (e) {
//       resultValue = "Failed to print: '${e.message}'.";
//     }
//
//     setState(() {
//       resultValue = resultValue;
//     });
//   }
//
//
//   /// must binding ur printer at first init in app
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: const Text('Sunmi printer Example'),
//         ),
//         body: Center(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 GestureDetector(
//                   onTap: _goPrint,
//                   child: Column(
//                     children: [
//                       Image.asset(
//                         'assets/images/app_logo.png',
//                         width: 100,
//                       ),
//                       const Text('Print this image from asset!')
//                     ],
//                   ),
//                 ),
//
//               ],
//             ),
//           ),
//         ));
//   }
// }
//
// Future<Uint8List> readFileBytes(String path) async {
//   ByteData fileData = await rootBundle.load(path);
//   Uint8List fileUnit8List = fileData.buffer
//       .asUint8List(fileData.offsetInBytes, fileData.lengthInBytes);
//   return fileUnit8List;
// }
//
// Future<Uint8List> _getImageFromAsset(String iconPath) async {
//   return await readFileBytes(iconPath);
// }
//
// Future<List<int>> _customEscPos() async {
//   final profile = await CapabilityProfile.load();
//   final generator = Generator(PaperSize.mm58, profile);
//   List<int> bytes = [];
//
//   bytes += generator.text(
//       'Regular: aA bB cC dD eE fF gG hH iI jJ kK lL mM nN oO pP qQ rR sS tT uU vV wW xX yY zZ');
//   bytes += generator.text('Special 1: àÀ èÈ éÉ ûÛ üÜ çÇ ôÔ',
//       styles: const PosStyles(codeTable: 'CP1252'));
//   bytes += generator.text('Special 2: blåbærgrød',
//       styles: const PosStyles(codeTable: 'CP1252'));
//
//   bytes += generator.text('Bold text', styles: const PosStyles(bold: true));
//   bytes +=
//       generator.text('Reverse text', styles: const PosStyles(reverse: true));
//   bytes += generator.text('Underlined text',
//       styles: const PosStyles(underline: true), linesAfter: 1);
//   bytes += generator.text('Align left',
//       styles: const PosStyles(align: PosAlign.left));
//   bytes += generator.text('Align center',
//       styles: const PosStyles(align: PosAlign.center));
//   bytes += generator.text('Align right',
//       styles: const PosStyles(align: PosAlign.right), linesAfter: 1);
//   bytes += generator.qrcode('Barcode by escpos',
//       size: QRSize.Size4, cor: QRCorrection.H);
//   bytes += generator.feed(2);
//
//   bytes += generator.row([
//     PosColumn(
//       text: 'col3',
//       width: 3,
//       styles: const PosStyles(align: PosAlign.center, underline: true),
//     ),
//     PosColumn(
//       text: 'col6',
//       width: 6,
//       styles: const PosStyles(align: PosAlign.center, underline: true),
//     ),
//     PosColumn(
//       text: 'col3',
//       width: 3,
//       styles: const PosStyles(align: PosAlign.center, underline: true),
//     ),
//   ]);
//
//   bytes += generator.text('Text size 200%',
//       styles: const PosStyles(
//         height: PosTextSize.size2,
//         width: PosTextSize.size2,
//       ));
//
//   bytes += generator.reset();
//   bytes += generator.cut();
//
//   return bytes;
// }
//
// class PrintTest2 extends StatefulWidget {
//   const PrintTest2({Key? key, required this.title}) : super(key: key);
//
//   final String title;
//
//   @override
//   State<PrintTest2> createState() => _PrintTest2State();
// }
//
// class _PrintTest2State extends State<PrintTest2> {
//   static const platform = MethodChannel('samples.flutter.dev/q1Printer');
//
//   String _resultValue = '.....';
//
//   Future<void> _goPrint() async {
//     String resultValue;
//     try {
//       final int result = await platform.invokeMethod('goPrint');
//
//       resultValue = 'printer result $result % .';
//     } on PlatformException catch (e) {
//       resultValue = "Failed to print: '${e.message}'.";
//     }
//
//     setState(() {
//       _resultValue = resultValue;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             ElevatedButton(
//               child: const Text('test print'),
//               onPressed: _goPrint,
//             ),
//             Text(_resultValue),
//           ],
//         ),
//       ),
//     );
//   }
// }
