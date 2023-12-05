import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:bluetooth_thermal_printer/bluetooth_thermal_printer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodie_restaurant/constants.dart';
import 'package:foodie_restaurant/main.dart';
import 'package:foodie_restaurant/model/OrderModel.dart';
import 'package:foodie_restaurant/model/OrderProductModel.dart';
import 'package:foodie_restaurant/model/User.dart';
import 'package:foodie_restaurant/model/VendorModel.dart';
import 'package:foodie_restaurant/model/variant_info.dart';
import 'package:foodie_restaurant/services/FirebaseHelper.dart';
import 'package:foodie_restaurant/services/helper.dart';
import 'package:foodie_restaurant/services/pushnotification.dart';
import 'package:foodie_restaurant/ui/chat_screen/chat_screen.dart';
import 'package:foodie_restaurant/ui/reviewScreen.dart';

class PastOrdersScreen extends StatefulWidget {
  @override
  _PastOrdersScreenState createState() => _PastOrdersScreenState();
}

class _PastOrdersScreenState extends State<PastOrdersScreen> {
  String TAG = "_OrdersScreenState";

  FireStoreUtils _fireStoreUtils = FireStoreUtils();
  late Future<List<OrderModel>> ordersFuture;

  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  final audioPlayer = AudioPlayer(playerId: "playerId");
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    setCurrency();
    ordersFuture = _fireStoreUtils.getVendorOrders(MyAppState.currentUser!.vendorID);
    final pushNotificationService = PushNotificationService(_firebaseMessaging);
    pushNotificationService.initialise();
  }

  setCurrency() async {
    await FireStoreUtils().getCurrency().then((value) {
      for (var element in value) {
        if (element.isactive = true) {
          debugPrint("$TAG get Currency from firebase =======> ${element.toJson().toString()}");
          symbol = element.symbol;
          isRight = element.symbolatright;
          currName = element.code;
          decimal = element.decimal;
          currencyData = element;
        }
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _fireStoreUtils.closeOrdersStream();
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode(context) ? Color(DARK_VIEWBG_COLOR) : Color(0XFFFFFFFF),
      body: SingleChildScrollView(
        child: FutureBuilder<List<OrderModel>>(
          future: ordersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return Container(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            print("$TAG order data length ======> ${snapshot.data!.length}");
            if (!snapshot.hasData || (snapshot.data?.isEmpty ?? true)) {
              return Center(
                child: showEmptyState('No Orders'.tr(), 'New order requests will show up here'.tr()),
              );
            } else {
              return ListView.builder(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                itemCount: snapshot.data!.length,
                padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
                itemBuilder: (context, index) => buildOrderItem(snapshot.data![index], index, (index != 0) ? snapshot.data![index - 1] : null),
              );
            }
          },
        ),
      ),
    );
  }

  Widget buildOrderItem(OrderModel orderModel, int index, OrderModel? prevModel) {
    double total = 0.0;
    total = 0.0;
    String photo = '';
    String foodName = '';
    orderModel.orderProduct.forEach((element) {
      if (orderModel.status == ORDER_STATUS_PLACED) {
        playSound();
      }

      try {
        if (element.extrasPrice!.isNotEmpty && double.parse(element.extrasPrice!) != 0.0) {
          total += element.quantity * double.parse(element.extrasPrice!);
        }
        total += element.quantity * double.parse(element.price);
        List addOnVal = [];
        if (element.extras == null) {
          addOnVal.clear();
        } else {
          if (element.extras is String) {
            if (element.extras == '[]') {
              addOnVal.clear();
            } else {
              String extraDecode = element.extras.toString().replaceAll("[", "").replaceAll("]", "").replaceAll("\"", "");
              if (extraDecode.contains(",")) {
                addOnVal = extraDecode.split(",");
              } else {
                if (extraDecode.trim().isNotEmpty) {
                  addOnVal = [extraDecode];
                }
              }
            }
          }
          if (element.extras is List) {
            addOnVal = List.from(element.extras);
          }
        }
        // for (int i = 0; i < addOnVal.length; i++) {}

        photo = element.photo;
        foodName = element.name;
      } catch (ex) {
        debugPrint("$TAG build Order Item =======> $ex");
      }
    });

    log("extra add on ${(orderModel.author!.firstName + ' ' + orderModel.author!.lastName)}  id is ${orderModel.id}");
    if (orderModel.deliveryCharge != null && orderModel.deliveryCharge!.isNotEmpty) {
      total += double.parse(orderModel.deliveryCharge!);
    }

    if (orderModel.tax != null && orderModel.tax != "") {
      total += double.parse(orderModel.tax.toString());
    }

    if (orderModel.discount != null && orderModel.discount != "") {
      total -= double.parse(orderModel.discount.toString());
    }

    String date = DateFormat('dd-MMM-yyyy').format(DateTime.fromMillisecondsSinceEpoch(orderModel.createdAt.millisecondsSinceEpoch));
    String date2 = "";
    if (prevModel != null) {
      date2 = DateFormat('dd-MMM-yyyy').format(DateTime.fromMillisecondsSinceEpoch(prevModel.createdAt.millisecondsSinceEpoch));
    }
    print("cond1 ${(index == 0)} cond 2 ${(index != 0 && prevModel != null && date != date2)}");
    return Column(
      children: [
        Visibility(
          visible: index == 0 || (index != 0 && prevModel != null && date != date2),
          child: Wrap(
            children: [
              Container(
                height: 50.0,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: isDarkMode(context) ? Color(DARK_CARD_BG_COLOR) : Colors.grey.shade300,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$date',
                  style: TextStyle(fontSize: 16, color: isDarkMode(context) ? Colors.white : Colors.black, letterSpacing: 0.5, fontFamily: 'Poppinsm'),
                ),
              )
            ],
          ),
        ),
        Card(
          elevation: 3,
          margin: EdgeInsets.only(bottom: 10, top: 10),
          color: isDarkMode(context) ? Color(DARK_CARD_BG_COLOR) : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // if you need this
            side: BorderSide(
              color: Colors.grey.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.only(bottom: 10.0, top: 5),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(left: 10),
                  child: Row(
                    children: [
                      Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: NetworkImage((photo.isNotEmpty) ? photo : placeholderImage),
                            fit: BoxFit.cover,
                            // colorFilter: ColorFilter.mode(
                            //     Colors.black.withOpacity(0.5), BlendMode.darken),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          SizedBox(
                            height: 5,
                          ),

                          Text(
                            orderModel.author!.firstName + ' ' + orderModel.author!.lastName,
                            style: TextStyle(fontSize: 18, color: isDarkMode(context) ? Colors.white : Color(0XFF000000), letterSpacing: 0.5, fontFamily: 'Poppinsm'),
                          ),

                          // Text(
                          //   foodName,
                          //   style: TextStyle(fontSize: 18, color: isDarkMode(context) ? Colors.white : Color(0XFF000000), letterSpacing: 0.5, fontFamily: 'Poppinsm'),
                          // ),
                          SizedBox(
                            height: 7,
                          ),

                          orderModel.takeAway!
                              ? Text(
                                  'Takeaway'.tr(),
                                  style: TextStyle(fontSize: 15, color: isDarkMode(context) ? Colors.white : Color(0XFF555353), letterSpacing: 0.5, fontFamily: 'Poppinsl'),
                                )
                              : Row(children: [
                                  Icon(Icons.location_pin, size: 17, color: Colors.grey),
                                  SizedBox(
                                    width: 2,
                                  ),
                                  Text(
                                    'Deliver to:'.tr(),
                                    style: TextStyle(fontSize: 15, color: isDarkMode(context) ? Colors.white : Color(0XFF555353), letterSpacing: 0.5, fontFamily: 'Poppinsl'),
                                  ),
                                ]),
                          orderModel.takeAway!
                              ? Container()
                              : Container(
                                  padding: EdgeInsets.only(bottom: 8),
                                  constraints: BoxConstraints(maxWidth: 200),
                                  child: Text(
                                    '${orderModel.deliveryAddress()}',
                                    maxLines: 1,
                                    style: TextStyle(color: isDarkMode(context) ? Colors.white : Color(0XFF555353), fontSize: 15, letterSpacing: 0.5, fontFamily: 'Poppinsr'),
                                  ),
                                ),
                        ],
                      ),
                    ],
                  ),
                ),
                // SizedBox(height: 10,),
                Divider(
                  color: Color(0XFFD7DDE7),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(10.0, 5.0, 5.0, 5.0),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Text(
                        'ORDER ID:'.tr(),
                        style: TextStyle(fontSize: 14, color: Color(0XFF9091A4), letterSpacing: 0.5, fontFamily: 'Poppinsm'),
                      ),
                      Text(
                        " ${orderModel.id}",
                        style: TextStyle(fontSize: 14, color: Color(0XFF9091A4), letterSpacing: 0.5, fontFamily: 'Poppinsm'),
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: Color(0XFFD7DDE7),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'ORDER LIST'.tr(),
                    style: TextStyle(fontSize: 14, color: Color(0XFF9091A4), letterSpacing: 0.5, fontFamily: 'Poppinsm'),
                  ),
                ),

                ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: orderModel.orderProduct.length,
                  padding: EdgeInsets.only(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    OrderProductModel product = orderModel.orderProduct[index];
                    VariantInfo? variantIno = product.variantInfo;
                    List<dynamic>? addon = product.extras;
                    String extrasDisVal = '';
                    for (int i = 0; i < addon!.length; i++) {
                      extrasDisVal += '${addon[i].toString().replaceAll("\"", "")} ${(i == addon.length - 1) ? "" : ","}';
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          minLeadingWidth: 10,
                          contentPadding: EdgeInsets.only(left: 10, right: 10),
                          visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                          leading: CircleAvatar(
                            radius: 13,
                            backgroundColor: Color(COLOR_PRIMARY),
                            child: Text(
                              '${product.quantity}',
                              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(
                            product.name,
                            style: TextStyle(color: isDarkMode(context) ? Colors.white : Color(0XFF333333), fontSize: 18, letterSpacing: 0.5, fontFamily: 'Poppinsr'),
                          ),
                          trailing: Text(
                            symbol != ''
                                ? symbol + double.parse((product.extrasPrice!.isNotEmpty && double.parse(product.extrasPrice!) != 0.0) ? (double.parse(product.extrasPrice!) + double.parse(product.price)).toString() : product.price).toStringAsFixed(decimal)
                                : '$symbol${double.parse((product.extrasPrice!.isNotEmpty && double.parse(product.extrasPrice!) != 0.0) ? (double.parse(product.extrasPrice!) + double.parse(product.price)).toString() : product.price).toStringAsFixed(2)}',
                            style: TextStyle(color: isDarkMode(context) ? Colors.grey.shade200 : Color(0XFF333333), fontSize: 17, letterSpacing: 0.5, fontFamily: 'Poppinsr'),
                          ),
                        ),
                        variantIno == null || variantIno.variantOptions!.isEmpty
                            ? Container()
                            : Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                child: Wrap(
                                  spacing: 6.0,
                                  runSpacing: 6.0,
                                  children: List.generate(
                                    variantIno.variantOptions!.length,
                                    (i) {
                                      return _buildChip("${variantIno.variantOptions!.keys.elementAt(i)} : ${variantIno.variantOptions![variantIno.variantOptions!.keys.elementAt(i)]}", i);
                                    },
                                  ).toList(),
                                ),
                              ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 55, right: 10),
                          child: extrasDisVal.isEmpty
                              ? Container()
                              : Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    extrasDisVal,
                                    style: TextStyle(fontSize: 16, color: Colors.grey, fontFamily: 'Poppinsr'),
                                  ),
                                ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(child: Container()),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  elevation: 0.0,
                                  backgroundColor: Colors.white,
                                  padding: EdgeInsets.all(8),
                                  side: BorderSide(color: Color(COLOR_PRIMARY), width: 0.4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(2),
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  push(
                                      context,
                                      ReviewScreen(
                                        product: product,
                                        orderId: orderModel.id,
                                      ));
                                },
                                child: Text(
                                  'View Rating'.tr(),
                                  style: TextStyle(letterSpacing: 0.5, color: isDarkMode(context) ? Colors.black : Color(COLOR_PRIMARY), fontFamily: 'Poppinsm'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  padding: EdgeInsets.only(bottom: 8, top: 8, left: 10, right: 10),
                  color: isDarkMode(context) ? null : Color(0XFFF4F4F5),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Order Total'.tr(),
                        style: TextStyle(fontSize: 15, color: isDarkMode(context) ? Colors.white : Color(0XFF333333), letterSpacing: 0.5, fontFamily: 'Poppinsr'),
                      ),
                      Text(
                        symbol != '' ? symbol + total.toDouble().toStringAsFixed(decimal) : '$symbol${total.toDouble().toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 18, color: Color(COLOR_PRIMARY), letterSpacing: 0.5, fontFamily: 'Poppinssm'),
                      ),
                    ],
                  ),
                ),
                orderModel.notes!.isEmpty
                    ? Container()
                    : SizedBox(
                        height: 10,
                      ),
                orderModel.notes!.isEmpty
                    ? Container()
                    : Container(
                        padding: EdgeInsets.only(bottom: 8, top: 8, left: 10, right: 10),
                        color: isDarkMode(context) ? null : Colors.white,
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Remark'.tr(),
                              style: TextStyle(fontSize: 15, color: isDarkMode(context) ? Colors.white : Color(0XFF333333), letterSpacing: 0.5, fontFamily: 'Poppinsr'),
                            ),

                            // ElevatedButton(
                            //     onPressed: (){
                            //       final url = "https://soundcloud.com/scutoidmusic/darren-styles-dougal-gammer-party-dont-stop-scutoids-sus-edit?utm_source=clipboard&utm_medium=text&utm_campaign=social_sharing";
                            //       if(!isPlaying){
                            //         audioPlayer.play(UrlSource(url),
                            //             mode: PlayerMode.mediaPlayer, );
                            //       }else{
                            //         audioPlayer.stop();
                            //       }
                            //     },
                            //     child: Text("pay done !!")
                            // ),

                            InkWell(
                              onTap: () {
                                showModalBottomSheet(
                                  isScrollControlled: true,
                                  isDismissible: true,
                                  context: context,
                                  backgroundColor: Colors.transparent,
                                  enableDrag: true,
                                  builder: (BuildContext context) => viewNoteSheet(orderModel.notes!),
                                );
                              },
                              child: Text(
                                "View".tr(),
                                style: TextStyle(fontSize: 18, color: Color(COLOR_PRIMARY), letterSpacing: 0.5, fontFamily: 'Poppinsm'),
                              ),
                            ),
                          ],
                        ),
                      ),
                Container(
                  padding: EdgeInsets.only(left: 10, right: 10, top: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (orderModel.status == ORDER_STATUS_PLACED)
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 0.0,
                              backgroundColor: Colors.white,
                              padding: EdgeInsets.all(8),
                              side: BorderSide(color: Color(COLOR_PRIMARY), width: 0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(2),
                                ),
                              ),
                            ),
                            onPressed: () {
                              audioPlayer.stop();
                              orderModel.status = ORDER_STATUS_ACCEPTED;
                              FireStoreUtils.updateOrder(orderModel);
                              FireStoreUtils.sendFcmMessage("Your Order has Accepted".tr(), '${orderModel.vendor.title}' + ' ' + 'has Accepted Your Order'.tr(), orderModel.author!.fcmToken, 'order');

                              if (orderModel.status == ORDER_STATUS_PLACED && !orderModel.takeAway!) {
                                FireStoreUtils.sendFcmMessage("New Delivery!".tr(), 'New Delivery Request'.tr(), orderModel.driver!.fcmToken, 'order');
                              }
                              setState(() {});
                            },
                            child: Text(
                              'ACCEPT'.tr(),
                              style: TextStyle(letterSpacing: 0.5, color: isDarkMode(context) ? Colors.black : Color(COLOR_PRIMARY), fontFamily: 'Poppinsm'),
                            ),
                          ),
                        ),
                      SizedBox(
                        width: 20
                      ),
                      if (orderModel.status == ORDER_STATUS_PLACED)
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 0.0,
                              backgroundColor: Colors.white,
                              padding: EdgeInsets.all(8),
                              side: BorderSide(color: Color(0XFF63605F), width: 0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(2),
                                ),
                              ),
                            ),
                            onPressed: () {
                              audioPlayer.stop();
                              orderModel.status = ORDER_STATUS_REJECTED;
                              FireStoreUtils.updateOrder(orderModel);
                              FireStoreUtils.sendFcmMessage("Your Order has Rejected".tr(), '${orderModel.vendor.title}' + ' ' + 'has Rejected Your Order'.tr(), orderModel.author!.fcmToken, 'order');
                              if (orderModel.paymentMethod!.toLowerCase() != 'cod') {
                                FireStoreUtils.createPaymentId().then((value) {
                                  final paymentID = value;
                                  FireStoreUtils.topUpWalletAmount(paymentMethod: "Refund Amount".tr(), userId: orderModel.author!.userID, amount: total.toDouble(), id: paymentID).then((value) {
                                    FireStoreUtils.updateWalletAmount(userId: orderModel.author!.userID, amount: total.toDouble()).then((value) {});
                                  });
                                });
                              }

                              if (orderModel.status == ORDER_STATUS_REJECTED && !orderModel.takeAway!) {
                                FireStoreUtils.sendFcmMessage("Reject Order!".tr(), 'Reject Order Request'.tr(), orderModel.driver!.fcmToken, 'order');
                              }
                              setState(() {});
                            },
                            child: Text(
                              'REJECT'.tr(),
                              style: TextStyle(letterSpacing: 0.5, color: Color(0XFF63605F), fontFamily: 'Poppinsm'),
                            ),
                          ),
                        ),
                      if (orderModel.status == ORDER_STATUS_COMPLETED) PrintTicket(orderModel: orderModel),
                      if (orderModel.status != ORDER_STATUS_PLACED && !orderModel.takeAway!)
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(6),
                                ),
                              ),
                              side: BorderSide(
                                color: getOrderStatusColor(orderModel.status),
                              ),
                            ),
                            onPressed: () => null,
                            child: Text(
                              '${orderModel.status}'.tr(),
                              style: TextStyle(
                                color: getOrderStatusColor(orderModel.status),
                                fontWeight: getFontWeight(orderModel.status),
                              ),
                            ),
                          ),
                        ),
                      orderModel.status == ORDER_STATUS_ACCEPTED && orderModel.takeAway!
                          ? Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  orderModel.status = ORDER_STATUS_COMPLETED;
                                  FireStoreUtils.updateOrder(orderModel);
                                  updateWallateAmount(orderModel);
                                  FireStoreUtils.sendFcmMessage("Your Order has been Completed".tr(), '${orderModel.vendor.title}' + ' ' + 'has Completed Your Order'.tr(), orderModel.author!.fcmToken, 'order');
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width * 0.4,
                                  // height: 50,
                                  padding: EdgeInsets.only(top: 8, bottom: 8, left: 8, right: 8),
                                  // primary: Colors.white,

                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), border: Border.all(width: 0.8, color: Color(COLOR_PRIMARY))),
                                  child: Text(
                                    'Delivered'.tr().toUpperCase(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: isDarkMode(context) ? Color(0xffFFFFFF) : Color(COLOR_PRIMARY), fontFamily: "Poppinsm", fontSize: 15
                                        // fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                              ),
                            )
                          : orderModel.status == ORDER_STATUS_COMPLETED && orderModel.takeAway!
                              ? Expanded(
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      padding: EdgeInsets.all(16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(6),
                                        ),
                                      ),
                                      side: BorderSide(
                                        color: Color(COLOR_PRIMARY),
                                      ),
                                    ),
                                    onPressed: () => null,
                                    child: Text(
                                      '${orderModel.status}'.tr(),
                                      style: TextStyle(
                                        color: Color(COLOR_PRIMARY),
                                      ),
                                    ),
                                  ),
                                )
                              : orderModel.status == ORDER_STATUS_REJECTED && orderModel.takeAway!
                                  ? Expanded(
                                      child: OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          padding: EdgeInsets.all(16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(6),
                                            ),
                                          ),
                                          side: BorderSide(
                                            color: Color(COLOR_PRIMARY),
                                          ),
                                        ),
                                        onPressed: () => null,
                                        child: Text(
                                          '${orderModel.status}'.tr(),
                                          style: TextStyle(
                                            color: Color(COLOR_PRIMARY),
                                          ),
                                        ),
                                      ),
                                    )
                                  : Container(),
                      SizedBox(width: 10,),
                      Visibility(
                        visible: orderModel.status == ORDER_STATUS_ACCEPTED ||
                            orderModel.status == ORDER_STATUS_SHIPPED ||
                            orderModel.status == ORDER_STATUS_DRIVER_PENDING ||
                            orderModel.status == ORDER_STATUS_DRIVER_REJECTED ||
                            orderModel.status == ORDER_STATUS_IN_TRANSIT ||
                            orderModel.status == ORDER_STATUS_SHIPPED,
                        child: Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: InkWell(
                            onTap: () async {
                              await showProgress(context, "Please wait".tr(), false);

                              User? customer = await FireStoreUtils.getCurrentUser(orderModel.authorID);
                              User? restaurantUser = await FireStoreUtils.getCurrentUser(orderModel.vendor.author);
                              VendorModel? vendorModel = await FireStoreUtils.getVendor(restaurantUser!.vendorID.toString());

                              hideProgress();
                              push(
                                context,
                                ChatScreens(
                                  customerName: '${customer!.firstName + " " + customer.lastName}',
                                  restaurantName: vendorModel!.title,
                                  orderId: orderModel.id,
                                  restaurantId: restaurantUser.userID,
                                  customerId: customer.userID,
                                  customerProfileImage: customer.profilePictureURL,
                                  restaurantProfileImage: vendorModel.photo,
                                  token: customer.fcmToken,
                                ),
                              );
                            },
                            child: Image(
                              image: AssetImage("assets/images/user_chat.png"),
                              height: 30,
                              color: Color(COLOR_PRIMARY),
                              width: 30,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  viewNoteSheet(String notes) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height / 4.3, left: 25, right: 25),
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(color: Colors.transparent, border: Border.all(style: BorderStyle.none)),
      child: Column(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 0.3),
                color: Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 25,
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: isDarkMode(context) ? Color(COLOR_DARK) : Colors.white,
              ),
              alignment: Alignment.center,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                        padding: EdgeInsets.only(top: 20),
                        child: Text(
                          'Remark'.tr(),
                          style: TextStyle(
                            fontFamily: 'Poppinssb',
                            color: isDarkMode(context) ? Colors.white60 : Colors.white,
                            fontSize: 16,
                          ),
                        )),
                    Container(
                      padding: EdgeInsets.only(left: 20, right: 20, top: 20),
                      // height: 120,
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        child: Container(
                          padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
                          color: isDarkMode(context) ? Color(0XFF2A2A2A) : Color(0XFFF1F4F7),
                          // height: 120,
                          alignment: Alignment.center,
                          child: Text(
                            notes,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isDarkMode(context) ? Colors.white60 : Colors.black,
                              fontFamily: 'Poppinsm',
                            ),
                          ),
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
    );
  }

  buildDetails({required IconData iconsData, required String title, required String value}) {
    return ListTile(
      enabled: false,
      dense: true,
      contentPadding: EdgeInsets.only(left: 8),
      horizontalTitleGap: 0.0,
      visualDensity: VisualDensity.comfortable,
      leading: Icon(
        iconsData,
        color: isDarkMode(context) ? Colors.white : Colors.black87,
      ),
      title: Text(
        title,
        style: TextStyle(fontSize: 16, color: isDarkMode(context) ? Colors.white : Colors.black87),
      ),
      subtitle: Text(
        value,
        style: TextStyle(color: isDarkMode(context) ? Colors.white : Colors.black54),
      ),
    );
  }

  playSound() async {
    final path = await rootBundle.load("assets/audio/mixkit-happy-bells-notification-937.mp3");

    audioPlayer.setSourceBytes(
      path.buffer.asUint8List(),
    );
    audioPlayer.setReleaseMode(ReleaseMode.loop);
    //audioPlayer.setSourceUrl(url);
    audioPlayer.play(
      BytesSource(
        path.buffer.asUint8List(),
      ),
      volume: 15,
      ctx: AudioContext(
        android: AudioContextAndroid(
          contentType: AndroidContentType.music,
          isSpeakerphoneOn: true,
          stayAwake: true,
          usageType: AndroidUsageType.alarm,
          audioFocus: AndroidAudioFocus.gainTransient,
        ),
        iOS: AudioContextIOS(
          defaultToSpeaker: true,
          category: AVAudioSessionCategory.playback,
          options: [],
        ),
      ),
    );
  }

  Color getOrderStatusColor(String status) {
    if(status.toLowerCase() == "Order Accepted".toLowerCase()) {
      return Colors.green;
    } else if(status.toLowerCase() == "Order Rejected".toLowerCase()) {
      return Color(COLOR_PRIMARY);
    } else {
      return Color(COLOR_PRIMARY);
    }
  }

  FontWeight getFontWeight(String status) {
    if(status.toLowerCase() == "Order Accepted".toLowerCase()) {
      return FontWeight.bold;
    } else if(status.toLowerCase() == "Order Rejected".toLowerCase()) {
      return FontWeight.bold;
    } else {
      return FontWeight.normal;
    }
  }

}

class PrintTicket extends StatefulWidget {
  final OrderModel orderModel;

  const PrintTicket({Key? key, required this.orderModel}) : super(key: key);

  @override
  State<PrintTicket> createState() => PrintTicketState();
}

class PrintTicketState extends State<PrintTicket> {
  double total = 0.0;
  var discount;

  @override
  void initState() {
    widget.orderModel.orderProduct.forEach((element) {
      if (element.extrasPrice != null && element.extrasPrice!.isNotEmpty && double.parse(element.extrasPrice!) != 0.0) {
        total += element.quantity * double.parse(element.extrasPrice!);
      }
      total += element.quantity * double.parse(element.price);
      discount = widget.orderModel.discount;
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(6),
            ),
          ),
          side: BorderSide(
            color: Color(COLOR_PRIMARY),
          ),
        ),
        onPressed: () => printTicket(),
        child: Text(
          'Print Invoice',
          style: TextStyle(
            color: Color(COLOR_PRIMARY),
          ),
        ),
      ),
    );
  }

  Future<void> printTicket() async {
    String? isConnected = await BluetoothThermalPrinter.connectionStatus;
    print("Uday");
    print(isConnected);
    if (isConnected == "true") {
      List<int> bytes = await getTicket();
      log(bytes.toString());
      String base64Image = base64Encode(bytes);

      log(base64Image.toString());

      final result = await BluetoothThermalPrinter.writeBytes(bytes);
      if (result == "true") {
        showAlertDialog(context, "Successfully", "Invoice print successfully", true);
      }
    } else {
      getBluetooth();
    }
  }

  Future<List<int>> getTicket() async {
    List<int> bytes = [];
    CapabilityProfile profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);

    bytes += generator.text("Invoice",
        styles: const PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
        linesAfter: 1);

    bytes += generator.text(widget.orderModel.vendor.title, styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text('Tel: ${widget.orderModel.vendor.phonenumber}', styles: const PosStyles(align: PosAlign.center));

    bytes += generator.hr();
    bytes += generator.row([
      PosColumn(text: 'No', width: 1, styles: const PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(text: 'Item', width: 7, styles: const PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(text: 'Qty', width: 2, styles: const PosStyles(align: PosAlign.center, bold: true)),
      PosColumn(text: 'Total', width: 2, styles: const PosStyles(align: PosAlign.right, bold: true)),
    ]);

    List<OrderProductModel> products = widget.orderModel.orderProduct;
    for (int i = 0; i < products.length; i++) {
      bytes += generator.row([
        PosColumn(text: (i + 1).toString(), width: 1),
        PosColumn(
            text: products[i].name,
            width: 7,
            styles: const PosStyles(
              align: PosAlign.left,
            )),
        PosColumn(text: products[i].quantity.toString(), width: 2, styles: const PosStyles(align: PosAlign.center)),
        PosColumn(text: products[i].price.toString(), width: 2, styles: const PosStyles(align: PosAlign.right)),
      ]);
    }

    bytes += generator.hr();

    bytes += generator.row([
      PosColumn(
          text: 'Subtotal'.tr(),
          width: 6,
          styles: const PosStyles(
            align: PosAlign.left,
            height: PosTextSize.size4,
            width: PosTextSize.size4,
          )),
      PosColumn(
          text: total.toDouble().toStringAsFixed(decimal),
          width: 6,
          styles: const PosStyles(
            align: PosAlign.right,
            height: PosTextSize.size4,
            width: PosTextSize.size4,
          )),
    ]);

    bytes += generator.row([
      PosColumn(
          text: 'Discount'.tr(),
          width: 6,
          styles: const PosStyles(
            align: PosAlign.left,
            height: PosTextSize.size4,
            width: PosTextSize.size4,
          )),
      PosColumn(
          text: discount.toDouble().toStringAsFixed(decimal),
          width: 6,
          styles: const PosStyles(
            align: PosAlign.right,
            height: PosTextSize.size4,
            width: PosTextSize.size4,
          )),
    ]);

    bytes += generator.row([
      PosColumn(
          text: 'Delivery charges'.tr(),
          width: 6,
          styles: const PosStyles(
            align: PosAlign.left,
            height: PosTextSize.size4,
            width: PosTextSize.size4,
          )),
      PosColumn(
          text: widget.orderModel.deliveryCharge == null ? symbol + "0.0" : symbol + widget.orderModel.deliveryCharge!,
          width: 6,
          styles: const PosStyles(
            align: PosAlign.right,
            height: PosTextSize.size4,
            width: PosTextSize.size4,
          )),
    ]);

    bytes += generator.row([
      PosColumn(
          text: 'Tip Amount'.tr(),
          width: 6,
          styles: const PosStyles(
            align: PosAlign.left,
            height: PosTextSize.size4,
            width: PosTextSize.size4,
          )),
      PosColumn(
          text: widget.orderModel.tipValue!.isEmpty ? symbol + "0.0" : symbol + widget.orderModel.tipValue!,
          width: 6,
          styles: const PosStyles(
            align: PosAlign.right,
            height: PosTextSize.size4,
            width: PosTextSize.size4,
          )),
    ]);
    bytes += generator.row([
      PosColumn(
          text: widget.orderModel.taxModel!.taxLabel ?? "10",
          width: 6,
          styles: const PosStyles(
            align: PosAlign.left,
            height: PosTextSize.size4,
            width: PosTextSize.size4,
          )),
      PosColumn(
          text: symbol + ((widget.orderModel.taxModel == null) ? "0" : getTaxValue(widget.orderModel.taxModel, total - discount).toString()),
          width: 6,
          styles: const PosStyles(
            align: PosAlign.right,
            height: PosTextSize.size4,
            width: PosTextSize.size4,
          )),
    ]);

    if (widget.orderModel.notes != null && widget.orderModel.notes!.isNotEmpty) {
      bytes += generator.row([
        PosColumn(
            text: "Remark".tr(),
            width: 6,
            styles: const PosStyles(
              align: PosAlign.left,
              height: PosTextSize.size4,
              width: PosTextSize.size4,
            )),
        PosColumn(
            text: widget.orderModel.notes!,
            width: 6,
            styles: const PosStyles(
              align: PosAlign.right,
              height: PosTextSize.size4,
              width: PosTextSize.size4,
            )),
      ]);
    }
    double tipValue = widget.orderModel.tipValue!.isEmpty ? 0.0 : double.parse(widget.orderModel.tipValue!);
    var taxAmount = (widget.orderModel.taxModel == null) ? 0 : getTaxValue(widget.orderModel.taxModel, total - discount);
    var totalamount = widget.orderModel.deliveryCharge == null || widget.orderModel.deliveryCharge!.isEmpty ? total + taxAmount - discount : total + taxAmount + double.parse(widget.orderModel.deliveryCharge!) + tipValue - discount;

    bytes += generator.row([
      PosColumn(
          text: 'Order Total'.tr(),
          width: 6,
          styles: const PosStyles(
            align: PosAlign.left,
            height: PosTextSize.size4,
            width: PosTextSize.size4,
          )),
      PosColumn(
          text: totalamount.toDouble().toStringAsFixed(decimal),
          width: 6,
          styles: const PosStyles(
            align: PosAlign.right,
            height: PosTextSize.size4,
            width: PosTextSize.size4,
          )),
    ]);

    bytes += generator.hr(ch: '=', linesAfter: 1);
    // ticket.feed(2);
    bytes += generator.text('Thank you!', styles: const PosStyles(align: PosAlign.center, bold: true));
    bytes += generator.cut();

    return bytes;
  }

  List availableBluetoothDevices = [];

  Future<void> getBluetooth() async {
    final List? bluetooths = await BluetoothThermalPrinter.getBluetooths;
    print("Print $bluetooths");
    setState(() {
      availableBluetoothDevices = bluetooths!;
      showLoadingAlert();
    });
  }

  showLoadingAlert() {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          title: const Text('Connect Bluetooth device').tr(),
          content: SizedBox(
            width: double.maxFinite,
            child: availableBluetoothDevices.isEmpty
                ? Center(child: Text("connect-from-setting".tr()))
                : ListView.builder(
                    itemCount: availableBluetoothDevices.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: () {
                          Navigator.pop(context);
                          String select = availableBluetoothDevices[index];
                          List list = select.split("#");
                          // String name = list[0];
                          String mac = list[1];
                          setConnect(mac);
                        },
                        title: Text('${availableBluetoothDevices[index]}'),
                        subtitle: Text("Click to connect".tr()),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }

  Future<void> setConnect(String mac) async {
    // final String? result = await BluetoothThermalPrinter.connect(mac);
    // print("state connected $result");
    // if (result == "true") {
    //   printTicket();
    // }
    // print("djjd 1");
    try {
      printTicket();
      final String? result = await BluetoothThermalPrinter.connect(mac);
      BluetoothThermalPrinter.connect(mac).catchError((error) {
        print(error.toString());
        log(error.toString());
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Done!!")));
      printTicket();
      print("state connected $result");
      if (result == "true") {
        printTicket();
      }
    } catch (e) {
      print("dod 1");
      print(e.toString());
    }
  }
}

Widget _buildChip(String label, int attributesOptionIndex) {
  return Container(
    decoration: BoxDecoration(color: const Color(0xffEEEDED), borderRadius: BorderRadius.circular(4)),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.black,
        ),
      ),
    ),
  );
}
