import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:foodie_restaurant/constants.dart';
import 'package:foodie_restaurant/main.dart';
import 'package:foodie_restaurant/model/User.dart';
import 'package:foodie_restaurant/model/VendorModel.dart';
import 'package:foodie_restaurant/services/FirebaseHelper.dart';
import 'package:foodie_restaurant/services/helper.dart';
import 'package:foodie_restaurant/ui/fullScreenImageViewer/FullScreenImageViewer.dart';
import 'package:foodie_restaurant/ui/reauthScreen/reauth_user_screen.dart';
import 'package:image_picker/image_picker.dart';

import '../../phoneinput/src/utils/phone_number.dart';
import '../../phoneinput/src/utils/selector_config.dart';
import '../../phoneinput/src/widgets/input_widget.dart';

class AccountDetailsScreen extends StatefulWidget {
  // final User user;
  final VendorModel? vendor;

  AccountDetailsScreen({Key? key, /*required this.user,*/ required this.vendor}) : super(key: key);

  @override
  _AccountDetailsScreenState createState() {
    return _AccountDetailsScreenState();
  }
}

class _AccountDetailsScreenState extends State<AccountDetailsScreen> {
  User? user;
  VendorModel? vendor;
  GlobalKey<FormState> _key = new GlobalKey();
  AutovalidateMode _validate = AutovalidateMode.disabled;

  final TextEditingController firstName = TextEditingController();
  final TextEditingController lastName = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController mobile = TextEditingController();

  List<dynamic> _mediaFiles = [];
  final ImagePicker _imagePicker = ImagePicker();
  FireStoreUtils fireStoreUtils = FireStoreUtils();
  bool? isLoader = false;

  @override
  void initState() {
    super.initState();
    vendor = widget.vendor;
    if (vendor != null) {
      if (vendor!.photos.isNotEmpty == true) {
        _mediaFiles.addAll(widget.vendor!.photos);
      }
    }
    FireStoreUtils.getCurrentUser(MyAppState.currentUser!.userID).then((value) {
      setState(() {
        user = value!;

        firstName.text = MyAppState.currentUser!.firstName;
        lastName.text = MyAppState.currentUser!.lastName;
        email.text = MyAppState.currentUser!.email;
        mobile.text = MyAppState.currentUser!.phoneNumber;

        MyAppState.currentUser = value;
        _mediaFiles.addAll(user!.photos);
        isLoader = true;
      });
    }).whenComplete(() {
      _mediaFiles.add(null);
    });
    //user = widget.user;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode(context) ? Color(DARK_VIEWBG_COLOR) : Colors.white,
      appBar: AppBar(
        title: Text(
          'Account Details'.tr(),
          style: TextStyle(
            color: isDarkMode(context) ? Color(0xFFFFFFFF) : Color(0Xff333333),
          ),
        ),
        automaticallyImplyLeading: false,
        leading: GestureDetector(
            onTap: () {
              Navigator.pop(context, true);
            },
            child: Icon(Icons.arrow_back)),
      ),
      body: Builder(
        builder: (buildContext) => !isLoader!
            ? Center(
                child: CircularProgressIndicator(color: Color(COLOR_PRIMARY)),
              )
            : SingleChildScrollView(
                child: Form(
                  key: _key,
                  autovalidateMode: _validate,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, right: 16, bottom: 8, top: 24),
                        child: Text(
                          'PUBLIC INFO',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ).tr(),
                      ),
                      Material(
                        elevation: 2,
                        color: isDarkMode(context) ? Color(DARK_CARD_BG_COLOR) : Colors.white,
                        child: ListView(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          children: ListTile.divideTiles(context: buildContext, tiles: [
                            ListTile(
                              title: Text(
                                'firstName'.tr(),
                                style: TextStyle(
                                  color: isDarkMode(context) ? Colors.white : Colors.black,
                                ),
                              ).tr(),
                              trailing: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 100),
                                child: TextFormField(
                                  controller: firstName,
                                  validator: validateName,
                                  textInputAction: TextInputAction.next,
                                  textAlign: TextAlign.end,
                                  style: TextStyle(fontSize: 18, color: isDarkMode(context) ? Colors.white : Colors.black),
                                  cursorColor: const Color(COLOR_ACCENT),
                                  textCapitalization: TextCapitalization.words,
                                  keyboardType: TextInputType.text,
                                  decoration: InputDecoration(border: InputBorder.none, hintText: 'firstName'.tr(), contentPadding: const EdgeInsets.symmetric(vertical: 5)),
                                ),
                              ),
                            ),
                            ListTile(
                              title: Text(
                                'lastName'.tr(),
                                style: TextStyle(color: isDarkMode(context) ? Colors.white : Colors.black),
                              ).tr(),
                              trailing: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 100),
                                child: TextFormField(
                                  controller: lastName,
                                  validator: validateName,
                                  textInputAction: TextInputAction.next,
                                  textAlign: TextAlign.end,
                                  style: TextStyle(fontSize: 18, color: isDarkMode(context) ? Colors.white : Colors.black),
                                  cursorColor: const Color(COLOR_ACCENT),
                                  textCapitalization: TextCapitalization.words,
                                  keyboardType: TextInputType.text,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'lastName'.tr(),
                                    contentPadding: const EdgeInsets.symmetric(vertical: 5),
                                  ),
                                ),
                              ),
                            ),
                          ]).toList(),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, right: 16, bottom: 8, top: 24),
                        child: Text(
                          'PRIVATE DETAILS',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ).tr(),
                      ),
                      Material(
                        elevation: 2,
                        color: isDarkMode(context) ? Color(DARK_CARD_BG_COLOR) : Colors.white,
                        child: ListView(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            children: ListTile.divideTiles(
                              context: buildContext,
                              tiles: [
                                ListTile(
                                  title: Text(
                                    'emailAddress'.tr(),
                                    style: TextStyle(color: isDarkMode(context) ? Colors.white : Colors.black),
                                  ).tr(),
                                  trailing: ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 200),
                                    child: TextFormField(
                                      controller: email,
                                      validator: validateEmail,
                                      textInputAction: TextInputAction.next,
                                      textAlign: TextAlign.end,
                                      style: TextStyle(fontSize: 18, color: isDarkMode(context) ? Colors.white : Colors.black),
                                      cursorColor: const Color(COLOR_ACCENT),
                                      keyboardType: TextInputType.emailAddress,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'emailAddress'.tr(),
                                        contentPadding: const EdgeInsets.symmetric(vertical: 5),
                                      ),
                                    ),
                                  ),
                                ),
                                ListTile(
                                  title: Text(
                                    'phoneNumber'.tr(),
                                    style: TextStyle(color: isDarkMode(context) ? Colors.white : Colors.black),
                                  ).tr(),
                                  trailing: InkWell(
                                    onTap: () {
                                      // showMobileAlertDialog(context);
                                    },
                                    child: Text(MyAppState.currentUser!.phoneNumber),
                                  ),
                                ),
                              ],
                            ).toList()),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, right: 16, bottom: 8, top: 24),
                        child: Text(
                          'ADD RESTAURANT PHOTOS',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ).tr(),
                      ),
                      ConstrainedBox(
                        constraints: const BoxConstraints(minWidth: double.infinity),
                        child: Material(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16, top: 8, right: 8, bottom: 20),
                            child: SizedBox(
                              height: 100,
                              child: ListView.builder(
                                itemCount: _mediaFiles.length,
                                itemBuilder: (context, index) => _imageBuilder(_mediaFiles[index]),
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 32.0, bottom: 16),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minWidth: double.infinity),
                          child: Material(
                            elevation: 2,
                            color: isDarkMode(context) ? Color(DARK_CARD_BG_COLOR) : Colors.white,
                            child: CupertinoButton(
                              padding: const EdgeInsets.all(12.0),
                              onPressed: () async {
                                _validateAndSave(buildContext);
                              },
                              child: Text(
                                'Save',
                                style: TextStyle(fontSize: 18, color: Color(COLOR_PRIMARY)),
                              ).tr(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  bool _isPhoneValid = false;
  String? _phoneNumber = "";

  showMobileAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: const Text("Cancel").tr(),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: const Text("continue").tr(),
      onPressed: () {
        if (_isPhoneValid) {
          setState(() {
            MyAppState.currentUser!.phoneNumber = _phoneNumber.toString();
            mobile.text = _phoneNumber.toString();
          });
          Navigator.pop(context);
        }
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Change Phone Number").tr(),
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          shape: BoxShape.rectangle,
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: InternationalPhoneNumberInput(
          onInputChanged: (value) {
            _phoneNumber = "${value.phoneNumber}";
          },
          onInputValidated: (bool value) => _isPhoneValid = value,
          ignoreBlank: true,
          maxLength: 11,
          selectionEnable: false,
          autoValidateMode: AutovalidateMode.onUserInteraction,
          inputDecoration: InputDecoration(
            hintText: 'Phone Number'.tr(),
            border: const OutlineInputBorder(
              borderSide: BorderSide.none,
            ),
            isDense: true,
            errorBorder: const OutlineInputBorder(
              borderSide: BorderSide.none,
            ),
          ),
          inputBorder: const OutlineInputBorder(
            borderSide: BorderSide.none,
          ),
          initialValue: PhoneNumber(isoCode: 'ZA'),
          selectorConfig: const SelectorConfig(selectorType: PhoneInputSelectorType.DIALOG),
        ),
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Widget _imageBuilder(dynamic image) {
    bool isLastItem = image == null;
    return GestureDetector(
      onTap: () {
        isLastItem ? _pickImage() : _viewOrDeleteImage(image);
      },
      child: Container(
        width: 100,
        child: Card(
          shape: RoundedRectangleBorder(
            side: BorderSide.none,
            borderRadius: BorderRadius.circular(12),
          ),
          color: isLastItem
              ? Color(COLOR_PRIMARY)
              : isDarkMode(context)
                  ? Color(DARK_CARD_BG_COLOR)
                  : Colors.white,
          child: isLastItem
              ? Icon(
                  CupertinoIcons.camera,
                  size: 40,
                  color: isDarkMode(context) ? Colors.black : Colors.white,
                )
              : ClipRRect(
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
      actions: [
        CupertinoActionSheetAction(
          onPressed: () async {
            Navigator.pop(context);
            _mediaFiles.removeLast();
            if (image is File) {
              _mediaFiles.removeWhere((value) => value is File && value.path == image.path);
            } else {
              _mediaFiles.removeWhere((value) => value is String && value == image);
            }
            _mediaFiles.add(null);
            setState(() {});
          },
          child: Text('Remove picture').tr(),
          isDestructiveAction: true,
        ),
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
            push(context, image is File ? FullScreenImageViewer(imageFile: image) : FullScreenImageViewer(imageUrl: image));
          },
          isDefaultAction: true,
          child: Text('View picture').tr(),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text('Cancel').tr(),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
    showCupertinoModalPopup(context: context, builder: (context) => action);
  }

  _pickImage() {
    final action = CupertinoActionSheet(
      message: Text(
        'Add Picture',
        style: TextStyle(fontSize: 15.0),
      ).tr(),
      actions: <Widget>[
        CupertinoActionSheetAction(
          child: Text('Choose image from gallery'),
          isDefaultAction: false,
          onPressed: () async {
            Navigator.pop(context);
            XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
            if (image != null) {
              _mediaFiles.removeLast();
              _mediaFiles.add(File(image.path));
              _mediaFiles.add(null);
              setState(() {});
            }
          },
        ),
        CupertinoActionSheetAction(
          child: Text('Take a picture'),
          isDestructiveAction: false,
          onPressed: () async {
            Navigator.pop(context);
            XFile? image = await _imagePicker.pickImage(source: ImageSource.camera);
            if (image != null) {
              _mediaFiles.removeLast();
              _mediaFiles.add(File(image.path));
              _mediaFiles.add(null);
              setState(() {});
            }
          },
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text('Cancel').tr(),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
    showCupertinoModalPopup(context: context, builder: (context) => action);
  }

  _validateAndSave(BuildContext buildContext) async {
    if (_key.currentState?.validate() ?? false) {
      _key.currentState?.save();
      if (user!.email != email) {
        bool emailLogin = false;
        List<auth.UserInfo> userInfoList = auth.FirebaseAuth.instance.currentUser?.providerData ?? [];
        await Future.forEach(userInfoList, (auth.UserInfo info) {
          if (info.providerId == 'password') {
            emailLogin = true;
          }
        });
        if (emailLogin) {
          TextEditingController _passwordController = new TextEditingController();
          showDialog(
            context: context,
            builder: (context) => Dialog(
              elevation: 16,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      "changeToEmailEnterPassword",
                      style: TextStyle(color: Colors.red, fontSize: 17),
                      textAlign: TextAlign.start,
                    ).tr(),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(hintText: 'Password'.tr()),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(COLOR_ACCENT),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(12),
                            ),
                          ),
                        ),
                        onPressed: () async {
                          if (_passwordController.text.isEmpty) {
                            showAlertDialog(context, 'Empty Password'.tr(), 'Password is required to update email'.tr(), true);
                          } else {
                            Navigator.pop(context);
                            showProgress(context, 'Verifying...'.tr(), false);
                            auth.UserCredential? result = await FireStoreUtils.reAuthUser(AuthProviders.PASSWORD, email: user!.email, password: _passwordController.text);
                            if (result == null) {
                              hideProgress();
                              showAlertDialog(context, "notVerify".tr(), 'Please double check the password and try again.'.tr(), true);
                            } else {
                              _passwordController.dispose();
                              if (result.user != null) {
                                await result.user?.updateEmail(email.text);
                                updateProgress('Saving details...'.tr());
                                await _updateUser(buildContext);
                                hideProgress();
                              } else {
                                hideProgress();
                                ScaffoldMessenger.of(buildContext).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Couldn't verify, Please try again.",
                                      style: TextStyle(fontSize: 17),
                                    ),
                                  ),
                                );
                              }
                            }
                          }
                        },
                        child: Text(
                          'Verify',
                          style: TextStyle(color: isDarkMode(context) ? Colors.black : Colors.white),
                        ).tr(),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        } else {
          showProgress(context, 'Saving details...'.tr(), false);
          await _updateUser(buildContext);
          hideProgress();
        }
      } else {
        showProgress(context, 'Saving details...'.tr(), false);
        await _updateUser(buildContext);
        hideProgress();
      }
    } else {
      setState(() {
        _validate = AutovalidateMode.onUserInteraction;
      });
    }
  }

  _updateUser(BuildContext buildContext) async {
    List<String> mediaFilesURLs = _mediaFiles.where((element) => element is String).toList().cast<String>();
    List<File> imagesToUpload = _mediaFiles.where((element) => element is File).toList().cast<File>();
    if (imagesToUpload.isNotEmpty) {
      updateProgress(
        'Uploading Restaurant Images {} of {}'.tr(args: ['1', '${imagesToUpload.length}']),
      );
      for (int i = 0; i < imagesToUpload.length; i++) {
        if (i != 0)
          updateProgress(
            'Uploading Restaurant Images {} of {}'.tr(
              args: ['${i + 1}', '${imagesToUpload.length}'],
            ),
          );
        String url = await fireStoreUtils.uploadProductImage(
          imagesToUpload[i],
          'Uploading Restaurant Images {} of {}'.tr(
            args: ['${i + 1}', '${imagesToUpload.length}'],
          ),
        );
        mediaFilesURLs.add(url);
      }
    }
    vendor!.photos = mediaFilesURLs;
    user!.firstName = firstName.text;
    user!.lastName = lastName.text;
    user!.email = email.text;
    user!.phoneNumber = mobile.text;
    var updatedUser = await FireStoreUtils.updateCurrentUser(user!);
    var updatedVendor = await FireStoreUtils.updateVendor(vendor!);
    if (updatedUser != null || updatedVendor != null) {
      MyAppState.currentUser = user;
      ScaffoldMessenger.of(buildContext).showSnackBar(SnackBar(
          content: Text(
        'Details saved successfully',
        style: TextStyle(fontSize: 17),
      ).tr()));
    } else {
      ScaffoldMessenger.of(buildContext).showSnackBar(SnackBar(
          content: Text(
        "notSaveDetailsTryAgain",
        style: TextStyle(fontSize: 17),
      ).tr()));
    }
  }
}
