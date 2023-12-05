import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:foodie_restaurant/constants.dart';
import 'package:foodie_restaurant/main.dart';
import 'package:foodie_restaurant/model/VendorModel.dart';
import 'package:foodie_restaurant/services/helper.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';

class QrCodeGenerator extends StatefulWidget {
  const QrCodeGenerator({Key? key, required this.vendorModel}) : super(key: key);

  @override
  State<QrCodeGenerator> createState() => _QrCodeGeneratorState();

  final VendorModel vendorModel;
}

class _QrCodeGeneratorState extends State<QrCodeGenerator> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            backgroundColor: isDarkMode(context) ? Color(COLOR_DARK) : null,
            appBar: AppBar(
              elevation: 0,
              title: Text(
                "QR Information".tr(),
                style: TextStyle(fontFamily: "Poppins", letterSpacing: 0.5, fontWeight: FontWeight.normal, color: isDarkMode(context) ? Colors.white : Colors.black),
              ),
              centerTitle: false,
              automaticallyImplyLeading: false,
              leading: IconButton(
                icon: Icon(
                  Icons.chevron_left,
                  color: isDarkMode(context) ? Colors.white : Colors.black,
                  size: 40,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ), //isDarkMode(context) ? Color(COLOR_DARK) : null,
            body: Container(
                margin: EdgeInsets.only(left: 10, right: 10),
                child: Center(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                  new FutureBuilder<File>(
                      future: getQrFile(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Container(
                            child: Center(
                              child: CircularProgressIndicator.adaptive(
                                valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                              ),
                            ),
                          );
                        }
                        return Container(
                          child: Image.file(
                            snapshot.data!,
                            height: MediaQuery.of(context).size.width * 0.8,
                            width: MediaQuery.of(context).size.width * 0.8,
                          ),
                        );
                      }),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "${widget.vendorModel.title}",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: "Poppinssb", fontSize: 18, letterSpacing: 0.5, fontWeight: FontWeight.normal, color: isDarkMode(context) ? Colors.white : Colors.black),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.only(top: 12, bottom: 12), backgroundColor: Color(COLOR_PRIMARY),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: BorderSide(
                          color: Color(COLOR_PRIMARY),
                        ),
                      ),
                    ),
                    onPressed: () {
                      saveFile(context);
                    },
                    child: Text(
                      'Download this QR-Code'.tr(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode(context) ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
                ])))));
  }

  Future<File> getQrFile() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    print(appDocPath);
    return File('$appDocPath/barcode${MyAppState.currentUser!.vendorID}.png');
  }

  Future<Directory> getDirPath() async {
    return await getApplicationDocumentsDirectory();
  }

  Future<void> saveFile(BuildContext context) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    print(appDocPath);
    File imageFile = File('$appDocPath/barcode${MyAppState.currentUser!.vendorID}.png');

    await ImageGallerySaver.saveImage(imageFile.readAsBytesSync(), quality: 100, name: 'QrCode_${widget.vendorModel.title.toString().replaceAll(RegExp('\'[^A-Za-z0-9]'), "")}.png');

    SnackBar snack = SnackBar(
      content: Text(
        'Image saved successfully'.tr(),
        style: TextStyle(color: Colors.white),
      ),
      duration: Duration(seconds: 2),
      backgroundColor: Colors.black,
    );
    ScaffoldMessenger.of(context).showSnackBar(snack);
  }
}
