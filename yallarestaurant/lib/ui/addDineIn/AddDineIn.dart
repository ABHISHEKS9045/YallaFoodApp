import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodie_restaurant/constants.dart';
import 'package:foodie_restaurant/main.dart';
import 'package:foodie_restaurant/model/VendorModel.dart';
import 'package:foodie_restaurant/services/FirebaseHelper.dart';
import 'package:foodie_restaurant/services/helper.dart';
import 'package:foodie_restaurant/ui/fullScreenImageViewer/FullScreenImageViewer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class AddDineIn extends StatefulWidget {
  const AddDineIn({Key? key}) : super(key: key);

  @override
  State<AddDineIn> createState() => _AddDineInState();
}

class _AddDineInState extends State<AddDineIn> {
  final _formKey = GlobalKey<FormState>();
  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;
  final dineInFor2price = TextEditingController();
  TextEditingController time1 = TextEditingController();
  TextEditingController time2 = TextEditingController();
  bool isTimeValid = false, isDineActive = false;
  final ImagePicker _imagePicker = ImagePicker();
  List<dynamic> _mediaFiles = [];
  VendorModel? vendors;
  var downloadUrl;

  @override
  void initState() {
    super.initState();
    if (MyAppState.currentUser!.vendorID.isNotEmpty) {
      FireStoreUtils.getVendor(MyAppState.currentUser!.vendorID).then((value) {
        if (value != null) {
          vendors = value;
          dineInFor2price.text = vendors!.restaurantCost.toString();

          if (vendors!.openDineTime.isNotEmpty) {
            time1.text = vendors!.openDineTime.toString();
          }
          if (vendors!.closeDineTime.isNotEmpty) {
            time2.text = vendors!.closeDineTime.toString();
          }

          isDineActive = vendors!.enabledDiveInFuture;

          _mediaFiles.addAll(vendors!.restaurantMenuPhotos);

          setState(() {});
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: isDarkMode(context) ? Color(COLOR_DARK) : null,
        body: (MyAppState.currentUser!.vendorID.isEmpty)
            ? Container(
                alignment: Alignment.center,
                child: showEmptyState('', 'Please add a restaurant first'.tr()),
              )
            : SingleChildScrollView(
                child: Padding(
                    padding: EdgeInsets.only(left: 20, right: 20, top: 20),
                    child: Form(
                        key: _formKey,
                        autovalidateMode: _autoValidateMode,
                        child: Column(
                          children: [
                            Container(
                                alignment: AlignmentDirectional.centerStart,
                                child: Text(
                                  "Price (approx for two)".tr(),
                                  style: TextStyle(fontSize: 17, fontFamily: "Poppinsl", color: isDarkMode(context) ? Colors.white : Color(0Xff696A75)),
                                )),
                            Container(
                              padding: const EdgeInsetsDirectional.only(start: 2, end: 20, bottom: 10),
                              child: TextFormField(
                                  controller: dineInFor2price,
                                  textAlignVertical: TextAlignVertical.center,
                                  textInputAction: TextInputAction.next,
                                  validator: (text) {
                                    if (text == null || text.isEmpty) {
                                      return "notBeEmpty".tr();
                                    }
                                    if (int.parse(text) == 0) {
                                      return 'Invalid Value'.tr();
                                    }
                                    return null;
                                  },
                                  // onSaved: (text) => line1 = text,
                                  style: TextStyle(fontSize: 18.0),
                                  keyboardType: TextInputType.number,
                                  maxLength: 5,
                                  cursorColor: Color(COLOR_PRIMARY),
                                  inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                                  decoration: InputDecoration(
                                    hintText: 'Price (approx for two)'.tr(),
                                    hintStyle: TextStyle(color: isDarkMode(context) ? Colors.white : Color(0Xff333333), fontSize: 17, fontFamily: "Poppinsm"),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Color(COLOR_PRIMARY)),
                                    ),
                                    prefix: Text('$symbol'),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Color(0XFFCCD6E2)),
                                      // borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  )),
                            ),
                            Container(
                                alignment: AlignmentDirectional.centerStart,
                                child: Text(
                                  "Timing".tr(),
                                  style: TextStyle(fontSize: 17, fontFamily: "Poppinsl", color: isDarkMode(context) ? Colors.white : Color(0Xff696A75)),
                                )),
                            Row(children: [
                              Flexible(
                                  child: Padding(
                                      padding: EdgeInsets.only(right: 10),
                                      child: TextFormField(
                                          onTap: () async {
                                            TimeOfDay? pickedTime = await showTimePicker(
                                              initialTime: TimeOfDay.now(),
                                              context: context,
                                            );

                                            if (pickedTime != null) {
                                              print(pickedTime.format(context)); //output 10:51 PM

                                              setState(() {
                                                time1.text = pickedTime.format(context); //set the value of text field.
                                              });
                                            } else {
                                              print("Time is not selected".tr());
                                            }
                                          },
                                          readOnly: true,
                                          textAlignVertical: TextAlignVertical.center,
                                          textInputAction: TextInputAction.next,
                                          controller: time1,
                                          // initialValue: time1.text,
                                          validator: validateEmptyField,
                                          style: TextStyle(fontSize: 18.0),
                                          keyboardType: TextInputType.streetAddress,
                                          cursorColor: Color(COLOR_PRIMARY),
                                          decoration: InputDecoration(
                                            suffixIcon: Icon(Icons.keyboard_arrow_down),
                                            hintText: '10:00 AM',
                                            hintStyle: TextStyle(color: isDarkMode(context) ? Colors.white : Color(0Xff333333), fontSize: 17, fontFamily: "Poppinsm"),
                                            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0XFFB1BCCA))),
                                          )))),
                              SizedBox(
                                width: 40,
                              ),
                              Flexible(
                                  child: TextFormField(
                                      onTap: () async {
                                        TimeOfDay? pickedTime = await showTimePicker(
                                          initialTime: TimeOfDay.now(),
                                          context: context,
                                        );
                                        if (pickedTime != null) {
                                          time2.text = pickedTime.format(context);
                                          print(time2.text.toString());

                                          DateTime startDate = DateFormat("hh:mm a").parse(time1.text.toString());
                                          DateTime endDate = DateFormat("hh:mm a").parse(time2.text.toString());

                                          if (endDate.isAfter(startDate)) {
                                            setState(() {
                                              isTimeValid = true;
                                            });
                                          } else {
                                            setState(() {
                                              isTimeValid = false;
                                            });
                                          }
                                        } else {
                                          print("Time is not selected".tr());
                                        }
                                      },
                                      readOnly: true,
                                      textAlignVertical: TextAlignVertical.center,
                                      textInputAction: TextInputAction.next,
                                      controller: time2,
                                      validator: validateEmptyField,
                                      style: TextStyle(fontSize: 18.0),
                                      keyboardType: TextInputType.streetAddress,
                                      cursorColor: Color(COLOR_PRIMARY),
                                      decoration: InputDecoration(
                                        suffixIcon: Icon(Icons.keyboard_arrow_down),
                                        hintText: '10:00 PM',
                                        hintStyle: TextStyle(color: isDarkMode(context) ? Colors.white : Color(0Xff333333), fontSize: 17, fontFamily: "Poppinsm"),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: Color(0XFFB1BCCA)),
                                        ),
                                      ))),
                            ]),
                            SizedBox(
                              height: 10,
                            ),
                            InkWell(
                                onTap: () {
                                  _pickImage();
                                },
                                child: Image(
                                  image: AssetImage("assets/images/add_img.png"),
                                  width: MediaQuery.of(context).size.width * 1,
                                  height: MediaQuery.of(context).size.height * 0.2,
                                )),
                            _mediaFiles.isEmpty == true
                                ? Container()
                                : SizedBox(
                                    height: 150,
                                    child: ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: _mediaFiles.length,
                                        scrollDirection: Axis.horizontal,
                                        padding: const EdgeInsets.all(12),
                                        itemBuilder: (context, index) => _imageBuilder(_mediaFiles[index])),
                                  ),
                            Card(
                              elevation: 2,
                              color: isDarkMode(context) ? Color(DARK_CARD_BG_COLOR) : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10), // if you need this
                                side: BorderSide(
                                  color: Colors.grey.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              margin: EdgeInsets.only(top: 10),
                              child: SwitchListTile.adaptive(
                                  activeColor: Color(COLOR_ACCENT),
                                  title: Text(
                                    'Activate'.tr(),
                                    style: TextStyle(fontSize: 17, color: isDarkMode(context) ? Colors.white : Colors.black, fontFamily: "Poppinsm"),
                                  ).tr(),
                                  value: isDineActive,
                                  onChanged: (bool newValue) {
                                    isDineActive = newValue;
                                    setState(() {});
                                  }),
                            )
                          ],
                        ))),
              ),
        bottomNavigationBar: (MyAppState.currentUser!.vendorID.isEmpty)
            ? null
            : Padding(
                padding: const EdgeInsets.all(20.0),
                child: ElevatedButton(
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
                    validate();
                  },
                  child: Text(
                    'CONTINUE'.tr(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode(context) ? Colors.black : Colors.white,
                    ),
                  ),
                ),
              ));
  }

  validate() async {
    if (MyAppState.currentUser!.vendorID != '') {
      if (_formKey.currentState?.validate() ?? false) {
        if (_mediaFiles.isNotEmpty) {
          await showProgress(context, 'Updating Photo...'.tr(), false);
          List menuPhotos = [];
          for (int pos = 0; pos < _mediaFiles.length; pos++) {
            if (_mediaFiles[pos] is File) {
              var uniqueID = Uuid().v4();
              Reference upload = FirebaseStorage.instance.ref().child('Foodie/menuimages/$uniqueID' '.png');
              UploadTask uploadTask = upload.putFile(_mediaFiles[pos]);
              uploadTask.whenComplete(() {}).catchError((onError) {
                print((onError as PlatformException).message);
              });
              var storageRef = (await uploadTask.whenComplete(() {})).ref;
              downloadUrl = await storageRef.getDownloadURL();
              downloadUrl.toString();
              menuPhotos.add(downloadUrl);
              await hideProgress();
            } else {
              if (_mediaFiles[pos] != null) {
                menuPhotos.add(_mediaFiles[pos]);
              }
            }
          }
          vendors!.restaurantMenuPhotos = menuPhotos;
        }

        await showProgress(context, 'Updating Restaurant...'.tr(), false);
        vendors!.restaurantCost = int.parse(dineInFor2price.text);
        vendors!.enabledDiveInFuture = isDineActive;
        vendors!.openDineTime = time1.text;
        vendors!.closeDineTime = time2.text;
        await FireStoreUtils.updateVendor(vendors!);
        await hideProgress();
        print(isTimeValid.toString() + "====TINME");
      }
    } else {
      setState(() {
        _autoValidateMode = AutovalidateMode.onUserInteraction;
      });
    }
  }

  _pickImage() {
    final action = CupertinoActionSheet(
      message: Text(
        'Add Picture'.tr(),
        style: TextStyle(fontSize: 15.0),
      ),
      actions: <Widget>[
        CupertinoActionSheetAction(
          child: Text('Choose image from gallery'.tr()),
          isDefaultAction: false,
          onPressed: () async {
            Navigator.pop(context);
            XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
            if (image != null) {
              // _mediaFiles.removeLast();
              _mediaFiles.add(File(image.path));
              // _mediaFiles.add(null);
              setState(() {});
            }
          },
        ),
        CupertinoActionSheetAction(
          child: Text('Take a picture'.tr()),
          isDestructiveAction: false,
          onPressed: () async {
            Navigator.pop(context);
            XFile? image = await _imagePicker.pickImage(source: ImageSource.camera);
            if (image != null) {
              // _mediaFiles.removeLast();
              _mediaFiles.add(File(image.path));
              // _mediaFiles.add(null);
              setState(() {});
            }
          },
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text('Cancel'.tr()),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
    showCupertinoModalPopup(context: context, builder: (context) => action);
  }

  _imageBuilder(dynamic image) {
    // bool isLastItem = image == null;

    print("image ${image is File}");
    return GestureDetector(
      onTap: () {
        _viewOrDeleteImage(image);
      },
      child: Container(
        width: 100,
        height: 100,
        child: Card(
          shape: RoundedRectangleBorder(
            side: BorderSide.none,
            borderRadius: BorderRadius.circular(12),
          ),
          color: isDarkMode(context) ? Colors.black : Colors.white,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: image is File
                ? Image.file(
                    image,
                    fit: BoxFit.cover,
                  )
                : displayImage(image),
          ),
        ),
      ),
    );
  }

  _viewOrDeleteImage(dynamic image) {
    final action = CupertinoActionSheet(
      actions: <Widget>[
        CupertinoActionSheetAction(
          onPressed: () async {
            Navigator.pop(context);
            // _mediaFiles.removeLast();
            if (image is File) {
              _mediaFiles.removeWhere((value) => value is File && value.path == image.path);
            } else {
              _mediaFiles.removeWhere((value) => value is String && value == image);
            }
            // _mediaFiles.add(null);
            setState(() {});
          },
          child: Text('Remove picture'.tr()),
          isDestructiveAction: true,
        ),
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
            push(context, image is File ? FullScreenImageViewer(imageFile: image) : FullScreenImageViewer(imageUrl: image));
          },
          isDefaultAction: true,
          child: Text('View picture'.tr()),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text('Cancel'.tr()),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
    showCupertinoModalPopup(context: context, builder: (context) => action);
  }

  showimgAlertDialog(BuildContext context, String title, String content, bool addOkButton) {
    Widget? okButton;
    if (addOkButton) {
      okButton = TextButton(
        child: Text('OK'.tr()),
        onPressed: () {
          Navigator.pop(context);
        },
      );
    }

    if (Platform.isIOS) {
      CupertinoAlertDialog alert = CupertinoAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [if (okButton != null) okButton],
      );
      showCupertinoDialog(
          context: context,
          builder: (context) {
            return alert;
          });
    } else {
      AlertDialog alert = AlertDialog(title: Text(title), content: Text(content), actions: [if (okButton != null) okButton]);

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
    }
  }
}
