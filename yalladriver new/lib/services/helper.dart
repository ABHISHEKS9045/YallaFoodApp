import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:foodie_driver/constants.dart';
import 'package:foodie_driver/model/OrderModel.dart';
import 'package:foodie_driver/model/TaxModel.dart';
import 'package:foodie_driver/model/withdrawHistoryModel.dart';
import 'package:foodie_driver/services/FirebaseHelper.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:progress_dialog/progress_dialog.dart';

String? validateName(String? value) {
  String pattern = r'(^[a-zA-Z ]*$)';
  RegExp regExp = RegExp(pattern);
  if (value?.length == 0) {
    return 'Name is required'.tr();
  } else if (!regExp.hasMatch(value ?? '')) {
    return 'Name must be valid'.tr();
  }
  return null;
}

String? validateMobile(String? value) {
  String pattern = r'(^\+?[0-9]*$)';
  RegExp regExp = RegExp(pattern);
  if (value?.length == 0) {
    return 'Mobile is required'.tr();
  } else if (!regExp.hasMatch(value ?? '')) {
    return 'Mobile Number must be digits'.tr();
  } else if (value!.length < 10 || value.length > 10) {
    return 'please enter valid number'.tr();
  }
  return null;
}

String? validateOthers(String? value) {
  if (value?.length == 0) {
    return '*required'.tr();
  }
  return null;
}

String? validatePassword(String? value) {
  if ((value?.length ?? 0) < 6)
    return 'Password length must be more than 6 chars.'.tr();
  else
    return null;
}

String? validateEmail(String? value) {
  String pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regex = RegExp(pattern);
  if (!regex.hasMatch(value ?? ''))
    return 'Please use a valid mail'.tr();
  else
    return null;
}

String? validateConfirmPassword(String? password, String? confirmPassword) {
  if (password != confirmPassword) {
    return 'Password must match'.tr();
  } else if (confirmPassword?.length == 0) {
    return 'Confirm password is required'.tr();
  } else {
    return null;
  }
}

String? validateEmptyField(String? text) => text == null || text.isEmpty ? "NotEmpty".tr() : null;

//helper method to show progress
late ProgressDialog progressDialog;

showProgress(BuildContext context, String message, bool isDismissible) async {
  progressDialog = ProgressDialog(context, type: ProgressDialogType.Normal, isDismissible: isDismissible);
  progressDialog.style(
      message: message,
      borderRadius: 10.0,
      backgroundColor: Color(0xff3DAE7D),
      progressWidget: Container(
        padding: EdgeInsets.all(8.0),
        child: CircularProgressIndicator.adaptive(
          backgroundColor: Colors.white,
          valueColor: AlwaysStoppedAnimation(
            Color(0xff3DAE7D),
          ),
        ),
      ),
      elevation: 10.0,
      insetAnimCurve: Curves.easeInOut,
      messageTextStyle: TextStyle(color: Colors.white, fontSize: 19.0, fontWeight: FontWeight.w600));

  await progressDialog.show();
}

updateProgress(String message) {
  progressDialog.update(message: message);
}

hideProgress() async {
  await progressDialog.hide();
}

//helper method to show alert dialog
showAlertDialog(BuildContext context, String title, String content, bool addOkButton) {
  // set up the AlertDialog
  Widget? okButton;
  if (addOkButton) {
    okButton = TextButton(
      child: Text('OK').tr(),
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

pushReplacement(BuildContext context, Widget destination) {
  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => destination));
}

push(BuildContext context, Widget destination) {
  Navigator.of(context).push(MaterialPageRoute(builder: (context) => destination));
}

pushAndRemoveUntil(BuildContext context, Widget destination, bool predict) {
  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => destination), (Route<dynamic> route) => predict);
}

String setLastSeen(int seconds) {
  var format = DateFormat('hh:mm a');
  var date = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
  var diff = DateTime.now().millisecondsSinceEpoch - (seconds * 1000);
  if (diff < 24 * HOUR_MILLIS) {
    return format.format(date);
  } else if (diff < 48 * HOUR_MILLIS) {
    return 'Yesterday At {}'.tr(args: ['${format.format(date)}']);
  } else {
    format = DateFormat('d MMM');
    return '${format.format(date)}';
  }
}

Widget displayCircleImage(String picUrl, double size, hasBorder) => CachedNetworkImage(
    height: size,
    width: size,
    imageBuilder: (context, imageProvider) => _getCircularImageProvider(imageProvider, size, hasBorder),
    imageUrl: picUrl,
    placeholder: (context, url) => _getPlaceholderOrErrorImage(size, hasBorder),
    errorWidget: (context, url, error) => _getPlaceholderOrErrorImage(size, hasBorder));

Widget _getPlaceholderOrErrorImage(double size, hasBorder) => ClipOval(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
            color: const Color(COLOR_ACCENT),
            borderRadius: BorderRadius.all(Radius.circular(size / 2)),
            border: Border.all(
              color: Colors.white,
              style: hasBorder ? BorderStyle.solid : BorderStyle.none,
              width: 2.0,
            ),
            image: DecorationImage(
                image: Image.asset(
              'assets/images/placeholder.jpg',
              fit: BoxFit.cover,
              height: size,
              width: size,
            ).image)),
      ),
    );

Widget _getCircularImageProvider(ImageProvider provider, double size, bool hasBorder) {
  return ClipOval(
      child: Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(size / 2)),
        border: Border.all(
          color: Colors.white,
          style: hasBorder ? BorderStyle.solid : BorderStyle.none,
          width: 1.0,
        ),
        image: DecorationImage(
          image: provider,
          fit: BoxFit.cover,
        )),
  ));
}

Widget displayCarImage(String picUrl, double size, hasBorder) => CachedNetworkImage(
    height: size,
    width: size,
    imageBuilder: (context, imageProvider) => _getCircularImageProvider(imageProvider, size, hasBorder),
    imageUrl: picUrl,
    placeholder: (context, url) => ClipOval(
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
                color: const Color(COLOR_ACCENT),
                borderRadius: BorderRadius.all(Radius.circular(size / 2)),
                border: Border.all(
                  color: Colors.white,
                  style: hasBorder ? BorderStyle.solid : BorderStyle.none,
                  width: 2.0,
                ),
                image: DecorationImage(
                    image: Image.asset(
                  'assets/images/car_default_image.png',
                  fit: BoxFit.cover,
                  height: size,
                  width: size,
                ).image)),
          ),
        ),
    errorWidget: (context, url, error) => ClipOval(
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
                color: const Color(COLOR_ACCENT),
                borderRadius: BorderRadius.all(Radius.circular(size / 2)),
                border: Border.all(
                  color: Colors.white,
                  style: hasBorder ? BorderStyle.solid : BorderStyle.none,
                  width: 2.0,
                ),
                image: DecorationImage(
                    image: Image.asset(
                  'assets/images/car_default_image.png',
                  fit: BoxFit.cover,
                  height: size,
                  width: size,
                ).image)),
          ),
        ));

bool isDarkMode(BuildContext context) {
  if (Theme.of(context).brightness == Brightness.light) {
    return false;
  } else {
    return true;
  }
}

Future<Position> getCurrentLocation() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.

  serviceEnabled = await Geolocator.isLocationServiceEnabled();

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied'.tr());
    }
  }

  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    Location location = Location();
    await location.requestService();
    // return Future.error('Location services are disabled.');
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error('Location permissions are permanently denied, we cannot request permissions.'.tr());
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition();
}

String audioMessageTime(Duration audioDuration) {
  String twoDigits(int n) {
    if (n >= 10) return '$n';
    return '0$n';
  }

  String twoDigitsHours(int n) {
    if (n >= 10) return '$n:';
    if (n == 0) return '';
    return '0$n:';
  }

  String twoDigitMinutes = twoDigits(audioDuration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(audioDuration.inSeconds.remainder(60));
  return '${twoDigitsHours(audioDuration.inHours)}$twoDigitMinutes:$twoDigitSeconds';
}

String updateTime(Timer timer) {
  Duration callDuration = Duration(seconds: timer.tick);
  String twoDigits(int n) {
    if (n >= 10) return '$n';
    return '0$n';
  }

  String twoDigitsHours(int n) {
    if (n >= 10) return '$n:';
    if (n == 0) return '';
    return '0$n:';
  }

  String twoDigitMinutes = twoDigits(callDuration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(callDuration.inSeconds.remainder(60));
  return '${twoDigitsHours(callDuration.inHours)}$twoDigitMinutes:$twoDigitSeconds';
}

Widget showEmptyState(String title, {String? description, String? buttonTitle, bool? isDarkMode, VoidCallback? action}) {
  return Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
      const SizedBox(height: 30),
      Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black.withOpacity(0.40))),
      const SizedBox(height: 15),
      Text(
        description == null ? "" : description.toString(),
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 16),
      ),
      const SizedBox(height: 25),
      if (action != null)
        Padding(
          padding: const EdgeInsets.only(left: 24.0, right: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: double.infinity),
            child: ElevatedButton(
                child: Text(
                  buttonTitle!,
                  style: TextStyle(color: isDarkMode! ? Colors.black.withOpacity(0.60) : Colors.white, fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Color(COLOR_PRIMARY),
                ),
                onPressed: action),
          ),
        )
    ]),
  );
}

String orderDate(Timestamp timestamp) {
  return DateFormat('EEE MMM d yyyy').format(DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch));
}

updateWallateAmount(OrderModel orderModel) {
  double total = 0.0;
  var discount;
  orderModel.products.forEach((element) {
    if (element.extras_price != null && element.extras_price!.isNotEmpty && double.parse(element.extras_price!) != 0.0) {
      total += element.quantity * double.parse(element.extras_price!);
    }
    total += element.quantity * double.parse(element.price);
  });
  discount = orderModel.discount;
  var totalamount = total - discount;
  double adminComm = (orderModel.adminCommissionType == 'Percent') ? (totalamount * double.parse(orderModel.adminCommission!)) / 100 : double.parse(orderModel.adminCommission!);
  var finalAmount = (totalamount - adminComm).toStringAsFixed(2);
  num driverAmount = 0;
  if (orderModel.paymentMethod.toLowerCase() != "cod") {
    driverAmount += (double.parse(orderModel.deliveryCharge!) + double.parse(orderModel.tipValue!));
  } else {
    num taxVal = (orderModel.taxModel == null) ? 0 : getTaxValue(orderModel.taxModel, totalamount);
    driverAmount += -num.parse(finalAmount) - num.parse(adminComm.toStringAsFixed(2)) - taxVal;
  }
  FireStoreUtils.updateWalletAmount(userId: orderModel.driverID!, amount: num.parse(driverAmount.toStringAsFixed(2)));
  FireStoreUtils.orderTransaction(orderModel: orderModel, amount: double.parse(finalAmount), driveramount: double.parse(driverAmount.toStringAsFixed(2)));
  FireStoreUtils.updateWalletAmount(userId: orderModel.vendor.author, amount: num.parse(double.parse(finalAmount).toStringAsFixed(2))).then((value) {});
  // FireStoreUtils.getVendor(orderModel.vendorID).then((value){
  //   if(value!=null){
  //     value.walletAmount=num.parse((value.walletAmount + double.parse(finalAmount)).toStringAsFixed(2));
  //     // FireStoreUtils.updateVendor(value);
  //
  //   }
  // });
}

double getTaxValue(TaxModel? taxModel, double amount) {
  double taxVal = 0;
  if (taxModel != null) {
    if (taxModel.taxType == "fix") {
      taxVal = taxModel.taxAmount!.toDouble();
    } else {
      taxVal = (amount * taxModel.taxAmount!.toDouble()) / 100;
    }
  }
  return double.parse(taxVal.toStringAsFixed(2));
}

showWithdrawalModelSheet(BuildContext context, WithdrawHistoryModel withdrawHistoryModel) {
  final size = MediaQuery.of(context).size;
  return showModalBottomSheet(
      backgroundColor: isDarkMode(context) ? Color(DARK_VIEWBG_COLOR) : Colors.white,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
      ),
      builder: (context) {
        return Container(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 5, left: 10, right: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      'Withdrawal Details'.tr(),
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: "Poppinsm",
                      ),
                    ),
                  ),
                ),
                Card(
                  color: isDarkMode(context) ? Color(DARK_CARD_BG_COLOR) : Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: size.width * 0.75,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: SizedBox(
                              width: size.width * 0.52,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Transaction ID".tr(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 17,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Opacity(
                                    opacity: 0.55,
                                    child: Text(
                                      withdrawHistoryModel.id,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 17,
                                        color: isDarkMode(context) ? Colors.white : Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  color: isDarkMode(context) ? Color(DARK_CARD_BG_COLOR) : Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipOval(
                          child: Container(
                            color: Colors.green.withOpacity(0.06),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Icon(Icons.account_balance_wallet_rounded, size: 28, color: Color(0xFF00B761)),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: size.width * 0.75,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 5.0),
                                    child: SizedBox(
                                      width: size.width * 0.52,
                                      child: Text(
                                        "${DateFormat('MMM dd, yyyy').format(withdrawHistoryModel.paidDate.toDate()).toUpperCase()}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 17,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Opacity(
                                    opacity: 0.75,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 5.0),
                                      child: Text(
                                        withdrawHistoryModel.paymentStatus,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 17,
                                          color: withdrawHistoryModel.paymentStatus == "Success" ? Colors.green : Colors.deepOrangeAccent,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 3.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      " $symbol${double.parse(withdrawHistoryModel.amount.toString()).toStringAsFixed(decimal)}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: withdrawHistoryModel.paymentStatus == "Success" ? Colors.green : Colors.deepOrangeAccent,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  color: isDarkMode(context) ? Color(DARK_CARD_BG_COLOR) : Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Date".tr(),
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 17,
                          ),
                        ),
                        Opacity(
                          opacity: 0.75,
                          child: Text(
                            "${DateFormat('MMM dd, yyyy, KK:mm a').format(withdrawHistoryModel.paidDate.toDate()).toUpperCase()}",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  color: isDarkMode(context) ? Color(DARK_CARD_BG_COLOR) : Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Visibility(
                        visible: withdrawHistoryModel.note.isNotEmpty,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 15),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Note".tr(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 17,
                                ),
                              ),
                              Opacity(
                                opacity: 0.75,
                                child: Text(
                                  withdrawHistoryModel.note,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Visibility(
                        visible: withdrawHistoryModel.note.isNotEmpty && withdrawHistoryModel.adminNote.isNotEmpty,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Divider(
                            thickness: 2,
                            height: 1,
                            color: isDarkMode(context) ? Colors.grey.shade700 : Colors.grey.shade300,
                          ),
                        ),
                      ),
                      Visibility(
                          visible: withdrawHistoryModel.adminNote.isNotEmpty,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Admin Note".tr(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 17,
                                  ),
                                ),
                                Opacity(
                                  opacity: 0.75,
                                  child: Text(
                                    withdrawHistoryModel.adminNote,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ))
                    ],
                  ),
                ),
              ],
            ));
      });
}
