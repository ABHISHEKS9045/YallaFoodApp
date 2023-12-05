import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_facebook_keyhash/flutter_facebook_keyhash.dart';
import 'package:foodie_restaurant/constants.dart';
import 'package:foodie_restaurant/main.dart';
import 'package:foodie_restaurant/model/User.dart';
import 'package:foodie_restaurant/model/VendorModel.dart';
import 'package:foodie_restaurant/services/FirebaseHelper.dart';
import 'package:foodie_restaurant/services/helper.dart';
import 'package:foodie_restaurant/ui/DineIn/DineInRequest.dart';
import 'package:foodie_restaurant/ui/auth/AuthScreen.dart';
import 'package:foodie_restaurant/ui/chat_screen/inbox_screen.dart';
import 'package:foodie_restaurant/ui/ordersScreen/OrdersScreen.dart';
import 'package:foodie_restaurant/ui/ordersScreen/printTest.dart';
import 'package:foodie_restaurant/ui/pastOrdersScreen/PastOrdersScreen.dart';
import 'package:foodie_restaurant/ui/privacy_policy/privacy_policy.dart';
import 'package:foodie_restaurant/ui/profile/ProfileScreen.dart';
import 'package:foodie_restaurant/ui/termsAndCondition/terms_and_codition.dart';

import '../Language/language_choose_screen.dart';

enum DrawerSelection { Orders, PastOrders, DineIn, DineInReq, ManageProducts, AddRestauarnt, createTable, addStory, Offers, SpecialOffer, inbox, WorkingHours, Profile, Wallet, BankInfo, termsCondition, privacyPolicy, /*chooseLanguage,*/ Logout, chooseLanguage }

// ignore: must_be_immutable
class ContainerScreen extends StatefulWidget {
  final User? user;

  final Widget currentWidget;
  final String appBarTitle;
  final DrawerSelection drawerSelection;
  String? userId = "";
  bool? isDineInReq = false;

  ContainerScreen({Key? key, this.user, this.userId, this.isDineInReq, appBarTitle, currentWidget, this.drawerSelection = DrawerSelection.Orders})
      : this.appBarTitle = appBarTitle ?? 'Orders'.tr(),
        this.currentWidget = currentWidget ?? OrdersScreen(),
        super(key: key);

  @override
  _ContainerScreen createState() {
    return _ContainerScreen();
  }
}

class _ContainerScreen extends State<ContainerScreen> {
  User? user;
  late String _appBarTitle;
  final fireStoreUtils = FireStoreUtils();
  Widget _currentWidget = OrdersScreen();
  DrawerSelection _drawerSelection = DrawerSelection.Orders;
  String _keyHash = 'Unknown';
  VendorModel? vendorModel;

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> getKeyHash() async {
    String keyHash;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      keyHash = await FlutterFacebookKeyhash.getFaceBookKeyHash ?? 'Unknown platform KeyHash'.tr();
    } on PlatformException {
      keyHash = 'Failed to get Kay Hash.'.tr();
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _keyHash = keyHash;
      print("::::KEYHASH::::");
      print(_keyHash);
    });
  }

  final audioPlayer = AudioPlayer(playerId: "playerId");

  @override
  void initState() {
    super.initState();
    setCurrency();
    FireStoreUtils.getCurrentUser(MyAppState.currentUser == null ? widget.userId! : MyAppState.currentUser!.userID).then((value) {
      setState(() {
        user = value!;
        MyAppState.currentUser = value;
      });
    });
    if (MyAppState.currentUser!.vendorID.isNotEmpty) {
      FireStoreUtils.getVendor(MyAppState.currentUser!.vendorID).then((value) {
        if (value != null) {
          vendorModel = value;
          setState(() {});
        }
      });
    }

    getSpecialDiscount();

    //getKeyHash();
    _appBarTitle = 'Orders'.tr();
    fireStoreUtils.getplaceholderimage();
    // print(MyAppState.currentUser!.vendorID);

    /// On iOS, we request notification permissions, Does nothing and returns null on Android
    FireStoreUtils.firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  setCurrency() async {
    await FireStoreUtils().getCurrency().then((value) {
      for (var element in value) {
        if (element.isactive = true) {
          symbol = element.symbol;
          isRight = element.symbolatright;
          currName = element.code;
          decimal = element.decimal;
          currencyData = element;
        }
      }
    });

    print("------------->");
    print(decimal);
  }

  bool specialDiscountEnable = false;
  bool storyEnable = false;

  getSpecialDiscount() async {
    await FirebaseFirestore.instance.collection(Setting).doc('specialDiscountOffer').get().then((value) {
      specialDiscountEnable = value.data()!['isEnable'];
    });
    await FirebaseFirestore.instance.collection(Setting).doc('story').get().then((value) {
      storyEnable = value.data()!['isEnabled'];
    });
    setState(() {});
  }

  DateTime preBackpress = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: _drawerSelection == DrawerSelection.Wallet ? true : false,
      backgroundColor: isDarkMode(context) ? Color(COLOR_DARK) : null,
      drawer: Drawer(
          child: Container(
        color: isDarkMode(context) ? Color(COLOR_DARK) : null,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            user == null
                ? Container()
                : DrawerHeader(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        displayCircleImage(user!.profilePictureURL, 75, false),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            user!.fullName(),
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              user!.email,
                              style: TextStyle(color: Colors.white),
                            )),
                      ],
                    ),
                    decoration: BoxDecoration(
                      color: Color(COLOR_PRIMARY),
                    ),
                  ),
            ListTileTheme(
              style: ListTileStyle.drawer,
              selectedColor: Color(COLOR_PRIMARY),
              child: ListTile(
                selected: _drawerSelection == DrawerSelection.Orders,
                title: Text('Orders').tr(),
                onTap: () {
                  Navigator.pop(context);
                  setState(
                    () {
                      _drawerSelection = DrawerSelection.Orders;
                      _appBarTitle = 'Orders'.tr();
                      _currentWidget = OrdersScreen();
                    },
                  );
                },
                leading: Image.asset(
                  'assets/images/app_logo.png',
                  width: 24,
                  height: 24,
                ),
              ),
            ),
            // ListTileTheme(
            //   style: ListTileStyle.drawer,
            //   selectedColor: Color(COLOR_PRIMARY),
            //   child: ListTile(
            //     // selected: _drawerSelection == DrawerSelection.Orders,
            //     title: Text('printTest').tr(),
            //     onTap: () {
            //       Navigator.pop(context);
            //       setState(
            //         () {
            //           // _drawerSelection = DrawerSelection.Orders;
            //           _appBarTitle = 'Print Test'.tr();
            //           _currentWidget = PrintTest2(title: 'print',);
            //         },
            //       );
            //     },
            //     leading: Image.asset(
            //       'assets/images/app_logo.png',
            //       width: 24,
            //       height: 24,
            //     ),
            //   ),
            // ),
            ListTileTheme(
              style: ListTileStyle.drawer,
              selectedColor: Color(COLOR_PRIMARY),
              child: ListTile(
                selected: _drawerSelection == DrawerSelection.PastOrders,
                title: Text('Order History').tr(),
                onTap: () {
                  Navigator.pop(context);
                  setState(
                        () {
                      _drawerSelection = DrawerSelection.PastOrders;
                      _appBarTitle = 'Order History'.tr();
                      _currentWidget = PastOrdersScreen();
                    },
                  );
                },
                leading: Image.asset(
                  'assets/images/app_logo.png',
                  width: 24,
                  height: 24,
                ),
              ),
            ),
            Visibility(
              visible: isDineInEnable,
              child: ListTileTheme(
                style: ListTileStyle.drawer,
                selectedColor: Color(COLOR_PRIMARY),
                child: ListTile(
                  selected: _drawerSelection == DrawerSelection.DineInReq,
                  title: Text('Dine-in Requests').tr(),
                  onTap: () {
                    Navigator.pop(context);
                    setState(
                      () {
                        _drawerSelection = DrawerSelection.DineInReq;
                        _appBarTitle = 'Dine-in Requests'.tr();
                        _currentWidget = DineInRequest();
                      },
                    );
                  },
                  leading: Icon(Icons.restaurant_menu),
                ),
              ),
            ),
            // ListTileTheme(
            //   style: ListTileStyle.drawer,
            //   selectedColor: Color(COLOR_PRIMARY),
            //   child: ListTile(
            //     selected: _drawerSelection == DrawerSelection.DineIn,
            //     leading: Icon(Icons.restaurant_outlined),
            //     title: Text('Add Restaurant').tr(),
            //     onTap: () {
            //       Navigator.pop(context);
            //       setState(() {
            //         _drawerSelection = DrawerSelection.DineIn;
            //         _appBarTitle = 'Add Restaurant'.tr();
            //         _currentWidget = AddRestaurantScreen();
            //       });
            //     },
            //   ),
            // ),
            // Visibility(
            //   visible: isDineInEnable,
            //   child: ListTileTheme(
            //     style: ListTileStyle.drawer,
            //     selectedColor: Color(COLOR_PRIMARY),
            //     child: ListTile(
            //       selected: _drawerSelection == DrawerSelection.AddRestauarnt,
            //       leading: Icon(Icons.restaurant_outlined),
            //       title: Text('Dine-in').tr(),
            //       onTap: () {
            //         Navigator.pop(context);
            //         setState(() {
            //           _drawerSelection = DrawerSelection.AddRestauarnt;
            //           _appBarTitle = 'Dine-in'.tr();
            //           _currentWidget = AddDineIn();
            //         });
            //       },
            //     ),
            //   ),
            // ),
            // ListTileTheme(
            //   style: ListTileStyle.drawer,
            //   selectedColor: Color(COLOR_PRIMARY),
            //   child: ListTile(
            //     selected: _drawerSelection == DrawerSelection.ManageProducts,
            //     leading: FaIcon(FontAwesomeIcons.pizzaSlice),
            //     title: Text('Manage Products').tr(),
            //     onTap: () {
            //       Navigator.pop(context);
            //       setState(() {
            //         _drawerSelection = DrawerSelection.ManageProducts;
            //         _appBarTitle = 'Your Products'.tr();
            //         _currentWidget = ManageProductsScreen();
            //       });
            //     },
            //   ),
            // ),
            // // ListTileTheme(
            // //   style: ListTileStyle.drawer,
            // //   selectedColor: Color(COLOR_PRIMARY),
            // //   child: ListTile(
            // //     selected: _drawerSelection == DrawerSelection.createTable,
            // //     title: Text('Create Table'.tr()),
            // //     onTap: () {
            // //       Navigator.pop(context);
            // //       setState(
            // //         () {
            // //           _drawerSelection = DrawerSelection.createTable;
            // //           _appBarTitle = 'Create Table'.tr();
            // //           _currentWidget = const CreateTable();
            // //         },
            // //       );
            // //     },
            // //     leading: const Icon(CupertinoIcons.table_badge_more),
            // //   ),
            // // ),
            // ListTileTheme(
            //   style: ListTileStyle.drawer,
            //   selectedColor: Color(COLOR_PRIMARY),
            //   child: ListTile(
            //     selected: _drawerSelection == DrawerSelection.Offers,
            //     leading: Icon(Icons.local_offer_outlined),
            //     title: Text('Offers').tr(),
            //     onTap: () {
            //       Navigator.pop(context);
            //       setState(() {
            //         _drawerSelection = DrawerSelection.Offers;
            //         _appBarTitle = 'Offers'.tr();
            //         _currentWidget = OffersScreen();
            //       });
            //     },
            //   ),
            // ),
            // ListTileTheme(
            //   style: ListTileStyle.drawer,
            //   selectedColor: Color(COLOR_PRIMARY),
            //   child: ListTile(
            //     selected: _drawerSelection == DrawerSelection.WorkingHours,
            //     leading: Icon(Icons.access_time_sharp),
            //     title: Text('Working Hours').tr(),
            //     onTap: () {
            //       Navigator.pop(context);
            //       setState(() {
            //         if (MyAppState.currentUser!.vendorID.isNotEmpty) {
            //           _drawerSelection = DrawerSelection.WorkingHours;
            //           _appBarTitle = 'Working Hours'.tr();
            //           _currentWidget = WorkingHoursScreen();
            //         } else {
            //           final snackBar = SnackBar(
            //             content: const Text('Please add restaurant first.'),
            //           );
            //           ScaffoldMessenger.of(context).showSnackBar(snackBar);
            //         }
            //       });
            //     },
            //   ),
            // ),
            // Visibility(
            //   visible: storyEnable == true?true:false,
            //   child: ListTileTheme(
            //     style: ListTileStyle.drawer,
            //     selectedColor: Color(COLOR_PRIMARY),
            //     child: ListTile(
            //       selected: _drawerSelection == DrawerSelection.addStory,
            //       leading: Icon(Icons.ad_units),
            //       title: Text('Add Story').tr(),
            //       onTap: () {
            //         Navigator.pop(context);
            //         setState(() {
            //           if (MyAppState.currentUser!.vendorID.isNotEmpty) {
            //             _drawerSelection = DrawerSelection.addStory;
            //             _appBarTitle = 'Add Story'.tr();
            //             _currentWidget = AddStoryScreen();
            //           } else {
            //             final snackBar = SnackBar(
            //               content: const Text('Please add restaurant first.'),
            //             );
            //             ScaffoldMessenger.of(context).showSnackBar(snackBar);
            //           }
            //         });
            //       },
            //     ),
            //   ),
            // ),
            // ListTileTheme(
            //   style: ListTileStyle.drawer,
            //   selectedColor: Color(COLOR_PRIMARY),
            //   child: ListTile(
            //     selected: _drawerSelection == DrawerSelection.SpecialOffer,
            //     leading: Icon(Icons.local_offer_outlined),
            //     title: Text('special_discount').tr(),
            //     onTap: () {
            //       Navigator.pop(context);
            //       setState(() {
            //         if (specialDiscountEnable) {
            //           _drawerSelection = DrawerSelection.SpecialOffer;
            //           _appBarTitle = 'special_discount'.tr();
            //           _currentWidget = SpecialOfferScreen();
            //         } else {
            //           final snackBar = SnackBar(
            //             content: const Text('This feature is not enable by admin.'),
            //           );
            //           ScaffoldMessenger.of(context).showSnackBar(snackBar);
            //         }
            //       });
            //     },
            //   ),
            // ),
            ListTileTheme(
              style: ListTileStyle.drawer,
              selectedColor: Color(COLOR_PRIMARY),
              child: ListTile(
                selected: _drawerSelection == DrawerSelection.inbox,
                leading: Icon(CupertinoIcons.chat_bubble_2_fill),
                title: Text('Inbox').tr(),
                onTap: () {
                  if (MyAppState.currentUser == null) {
                    Navigator.pop(context);
                    push(context, AuthScreen());
                  } else {
                    Navigator.pop(context);
                    setState(() {
                      _drawerSelection = DrawerSelection.inbox;
                      _appBarTitle = 'My Inbox'.tr();
                      _currentWidget = InboxScreen();
                    });
                  }
                },
              ),
            ),
            ListTileTheme(
              style: ListTileStyle.drawer,
              selectedColor: Color(COLOR_PRIMARY),
              child: ListTile(
                selected: _drawerSelection == DrawerSelection.Profile,
                leading: Icon(CupertinoIcons.person),
                title: Text('Profile').tr(),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _drawerSelection = DrawerSelection.Profile;
                    _appBarTitle = 'Profile'.tr();
                    _currentWidget = ProfileScreen(
                      user: user!,
                    );
                  });
                },
              ),
            ),
            // ListTileTheme(
            //   style: ListTileStyle.drawer,
            //   selectedColor: Color(COLOR_PRIMARY),
            //   child: ListTile(
            //     selected: _drawerSelection == DrawerSelection.Wallet,
            //     leading: Icon(Icons.account_balance_wallet_sharp),
            //     title: Text('Wallet').tr(),
            //     onTap: () {
            //       Navigator.pop(context);
            //       setState(() {
            //         _drawerSelection = DrawerSelection.Wallet;
            //         _appBarTitle = 'Wallet'.tr();
            //         _currentWidget = WalletScreen();
            //       });
            //     },
            //   ),
            // ),
            // ListTileTheme(
            //   style: ListTileStyle.drawer,
            //   selectedColor: Color(COLOR_PRIMARY),
            //   child: ListTile(
            //     selected: _drawerSelection == DrawerSelection.BankInfo,
            //     leading: Icon(Icons.account_balance),
            //     title: Text('Bank Details').tr(),
            //     onTap: () {
            //       Navigator.pop(context);
            //       setState(() {
            //         _drawerSelection = DrawerSelection.BankInfo;
            //         _appBarTitle = 'Bank Info'.tr();
            //         _currentWidget = BankDetailsScreen();
            //       });
            //     },
            //   ),
            // ),
            ListTileTheme(
              style: ListTileStyle.drawer,
              selectedColor: Color(COLOR_PRIMARY),
              child: ListTile(
                selected: _drawerSelection == DrawerSelection.chooseLanguage,
                leading: Icon(
                  Icons.language,
                  color: _drawerSelection == DrawerSelection.chooseLanguage
                      ? Color(COLOR_PRIMARY)
                      : isDarkMode(context)
                          ? Colors.grey.shade200
                          : Colors.grey.shade600,
                ),
                title: const Text('Language').tr(),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _drawerSelection = DrawerSelection.chooseLanguage;
                    _appBarTitle = 'Language'.tr();
                    _currentWidget = LanguageChooseScreen(
                      isContainer: true,
                    );
                  });
                },
              ),
            ),
            ListTileTheme(
              style: ListTileStyle.drawer,
              selectedColor: Color(COLOR_PRIMARY),
              child: ListTile(
                selected: _drawerSelection == DrawerSelection.termsCondition,
                leading: const Icon(Icons.policy),
                title: const Text('Terms and Condition').tr(),
                onTap: () async {
                  push(context, const TermsAndCondition());
                },
              ),
            ),
            ListTileTheme(
              style: ListTileStyle.drawer,
              selectedColor: Color(COLOR_PRIMARY),
              child: ListTile(
                selected: _drawerSelection == DrawerSelection.privacyPolicy,
                leading: const Icon(Icons.privacy_tip),
                title: const Text('Privacy policy').tr(),
                onTap: () async {
                  push(context, const PrivacyPolicyScreen());
                },
              ),
            ),

            ListTileTheme(
              style: ListTileStyle.drawer,
              selectedColor: Color(COLOR_PRIMARY),
              child: ListTile(
                selected: _drawerSelection == DrawerSelection.Logout,
                leading: Icon(Icons.logout),
                title: Text('Log out').tr(),
                onTap: () async {
                  audioPlayer.stop();
                  Navigator.pop(context);
                  //user.active = false;
                  user!.lastOnlineTimestamp = Timestamp.now();
                  await FireStoreUtils.firestore.collection(USERS).doc(user!.userID).update({"fcmToken": ""});
                  if (user!.vendorID.isNotEmpty) {
                    await FireStoreUtils.firestore.collection(VENDORS).doc(user!.vendorID).update({"fcmToken": ""});
                  }
                  // await FireStoreUtils.updateCurrentUser(user);
                  await auth.FirebaseAuth.instance.signOut();
                  await FacebookAuth.instance.logOut();
                  MyAppState.currentUser = null;
                  pushAndRemoveUntil(context, AuthScreen(), false);
                },
              ),
            ),
          ],
        ),
      )),
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: _drawerSelection == DrawerSelection.Wallet
              ? Colors.white
              : isDarkMode(context)
                  ? Colors.white
                  : Colors.black,
        ),
        centerTitle: _drawerSelection == DrawerSelection.Wallet ? true : false,
        backgroundColor: _drawerSelection == DrawerSelection.Wallet
            ? Colors.transparent
            : isDarkMode(context)
                ? Color(DARK_VIEWBG_COLOR)
                : Colors.white,
        actions: [
          // if (_currentWidget is ManageProductsScreen)
          // IconButton(
          //   icon: Icon(
          //     CupertinoIcons.add_circled,
          //     color: Color(COLOR_PRIMARY),
          //   ),
          //   onPressed: () => push(
          //     context,
          //     AddOrUpdateProductScreen(product: null),
          //   ),
          // ),
        ],
        title: Text(
          _appBarTitle,
          style: TextStyle(
            fontSize: 20,
            color: _drawerSelection == DrawerSelection.Wallet
                ? Colors.white
                : isDarkMode(context)
                    ? Colors.white
                    : Colors.black,
          ),
        ),
      ),
      body: WillPopScope(
          onWillPop: () async {
            final timeGap = DateTime.now().difference(preBackpress);
            final cantExit = timeGap >= Duration(seconds: 2);
            preBackpress = DateTime.now();
            if (cantExit) {
              //show snackbar
              final snack = SnackBar(
                content: Text(
                  'Press Back button again to Exit',
                  style: TextStyle(color: Colors.white),
                ),
                duration: Duration(seconds: 2),
                backgroundColor: Colors.black,
              );
              ScaffoldMessenger.of(context).showSnackBar(snack);
              return false; // false will do nothing when back press
            } else {
              return true; // true will exit the app
            }
          },
          child: _currentWidget),
    );
  }
}
