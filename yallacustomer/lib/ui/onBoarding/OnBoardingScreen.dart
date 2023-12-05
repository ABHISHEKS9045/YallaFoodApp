import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easy_localization/easy_localization.dart' as easyLocal;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foodie_customer/constants.dart';
import 'package:foodie_customer/services/helper.dart';
import 'package:foodie_customer/ui/auth/AuthScreen.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../../model/User.dart';
import '../../services/FirebaseHelper.dart';
import '../../services/localDatabase.dart';
import '../container/ContainerScreen.dart';

class OnBoardingScreen extends StatefulWidget {
  @override
  _OnBoardingScreenState createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {

  static const String TAG = "_OnBoardingScreenState";

  PageController pageController = PageController();

  final List<String> _titlesList = [
    // easyLocal.tr('Welcome to Yalla'),
    // 'Order Food'.tr(),
    'Yalla Delivery app'.tr(),
    'Yalla Delivery'.tr(),
    'The fastest delivery!'.tr(),
  ];

  final List<String> _subtitlesList = [
    'A qualitative leap in the world of delivery Best prices for meal delivery'.tr(),
    'Get food delivered to your doorstep business from the best local restaurants'.tr(),
    'Fast delivery for whatever you desire! Pizza, burger, sushi, schnitzel, shawarma and…'.tr(),
  ];

  final List<dynamic> _imageList = [
    'assets/images/intro_1.png',
    'assets/images/intro_2.png',
    'assets/images/intro_3.png',
  ];
  final List<dynamic> _darkimageList = [
    'assets/images/intro_1_dark.png',
    'assets/images/intro_2_dark.png',
    'assets/images/intro_3_dark.png',
  ];
  int _currentIndex = 0;
  var result;

  Future<void> checkConnectivity() async {
    var response = await Connectivity().checkConnectivity();
    setState(() {
      result = response;
    });
  }

  @override
  void initState() {
    checkConnectivity();
    super.initState();
    debugPrint("$TAG initState called ===========>");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode(context) ? Color(0XFF151618) : null,
      body: Stack(
        children: <Widget>[
          PageView.builder(
            itemBuilder: (context, index) {
              return getPage(isDarkMode(context) ? _darkimageList[index] : _imageList[index], _titlesList[index], _subtitlesList[index], context, isDarkMode(context) ? (index + 1) == _darkimageList.length : (index + 1) == _imageList.length);
            },
            controller: pageController,
            itemCount: isDarkMode(context) ? _darkimageList.length : _imageList.length,
            onPageChanged: (int index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          Visibility(
            visible: _currentIndex + 1 == _imageList.length,
            child: Positioned(
              right: 13,
              bottom: 17,
              child: Container(
                width: MediaQuery
                    .of(context)
                    .size
                    .width * 0.94,
                height: MediaQuery
                    .of(context)
                    .size
                    .height * 0.08,
                padding: EdgeInsets.all(10),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    backgroundColor: Color(COLOR_PRIMARY),
                  ),
                  child: Text(
                    "GET STARTED".tr(),
                    style: TextStyle(fontSize: 16),
                  ),
                  onPressed: () {
                    // setFinishedOnBoarding();
                    // pushReplacement(context, AuthScreen());
                    debugPrint("$TAG result ========> $result");
                    if(result == ConnectivityResult.none) {
                      showToastMsg(context);
                    } else {
                      hasFinishedOnBoarding(context);
                    }
                  },
                ),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 130),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: SmoothPageIndicator(
                  controller: pageController,
                  count: _imageList.length,
                  effect: ScrollingDotsEffect(
                    spacing: 20,
                    activeDotColor: Color(COLOR_PRIMARY),
                    dotColor: Color(0XFFFBDBD1),
                    dotWidth: 7,
                    dotHeight: 7,
                    fixedCenter: false,
                  ),
                ),
              ),
            ),
          ),
          Visibility(
            visible: _currentIndex + 1 == _imageList.length,
            child: Positioned(
              left: 15,
              top: 30,
              child: GestureDetector(
                onTap: () {
                  pageController.previousPage(duration: Duration(milliseconds: 100), curve: Curves.bounceIn);
                },
                child: Icon(
                  Icons.chevron_left,
                  size: 40,
                  color: isDarkMode(context) ? Color(0xffFFFFFF) : null,
                ),
              ),
            ),
          ),
          Visibility(
            visible: _currentIndex + 2 == _imageList.length,
            child: Positioned(
              left: 15,
              top: 30,
              child: GestureDetector(
                onTap: () {
                  pageController.previousPage(duration: Duration(milliseconds: 100), curve: Curves.bounceIn);
                },
                child: Icon(
                  Icons.chevron_left,
                  size: 40,
                  color: isDarkMode(context) ? Color(0xffFFFFFF) : null,
                ),
              ),
            ),
          ),
          Visibility(
            visible: _currentIndex + 1 != _imageList.length,
            child: Positioned(
              right: 20,
              top: 40,
              child: InkWell(
                onTap: () {
                  // setFinishedOnBoarding();
                  // pushReplacement(context, AuthScreen());
                  debugPrint("$TAG result ========> $result");
                  if(result == ConnectivityResult.none) {
                    showToastMsg(context);
                  } else {
                    hasFinishedOnBoarding(context);
                  }
                },
                child: Text(
                  "SKIP".tr(),
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(COLOR_PRIMARY),
                    fontFamily: 'Poppinsm',
                  ),
                ),
              ),
            ),
          ),
          Visibility(
            visible: _currentIndex + 1 != _imageList.length,
            child: Positioned(
              right: 13,
              bottom: 17,
              child: InkWell(
                onTap: () {},
                child: Container(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width * 0.94,
                  height: MediaQuery
                      .of(context)
                      .size
                      .height * 0.08,
                  padding: EdgeInsets.all(10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      backgroundColor: Color(COLOR_PRIMARY),
                    ),
                    child: Text(
                      "NEXT".tr(),
                      style: TextStyle(
                        fontSize: 16,
                        color: isDarkMode(context) ? Color(0xffFFFFFF) : Color(0XFF333333),
                      ),
                    ),
                    onPressed: () {
                      pageController.nextPage(duration: Duration(milliseconds: 100), curve: Curves.bounceIn);
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getPage(dynamic image, _titlesList, _subtitlesList, BuildContext context, bool isLastPage) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // image is String ?
          Expanded(
            child: Container(
              //  height:  MediaQuery.of(context).size.height*0.55,
              width: MediaQuery
                  .of(context)
                  .size
                  .width * 1,
              decoration: BoxDecoration(
                color: isDarkMode(context) ? Color(0XFF242528) : Color(0XFFFCEEE9),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.elliptical(400, 180),
                  bottomRight: Radius.elliptical(400, 180),
                ),
              ),
              child: Container(
                margin: EdgeInsets.only(right: 40, left: 40, top: 30),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(image),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: MediaQuery
              .of(context)
              .size
              .height * 0.08),
          Text(
            _titlesList,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDarkMode(context) ? Color(0xffFFFFFF) : Color(0XFF333333),
              fontFamily: 'Poppinsm',
              fontSize: 20,
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(right: 35, left: 35, top: 30),
            child: Text(
              _subtitlesList,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDarkMode(context) ? Color(0xffFFFFFF) : Color(0XFF333333),
                fontFamily: 'Poppinsl',
                height: 2,
                letterSpacing: 1.2,
              ),
            ),
          ),
          SizedBox(height: MediaQuery
              .of(context)
              .size
              .height * 0.25),
        ],
      ),
    );
  }

  // on client request change this function on 14-06-2023 by nilesh
  Future<bool> setFinishedOnBoarding() async {
    return true;
    // final SharedPreferences prefs = await SharedPreferences.getInstance();
    // return prefs.setBool(FINISHED_ON_BOARDING, true);
  }

  // on client request changed login and app intro flow on 16-06-2023 by nilesh
  Future hasFinishedOnBoarding(BuildContext context) async {
    auth.User? firebaseUser = auth.FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      User? user = await FireStoreUtils.getCurrentUser(firebaseUser.uid);
      //debugPrint(user!.toJson().toString());
      if (user != null && user.role == USER_ROLE_CUSTOMER) {
        if (user.active) {
          user.active = true;
          user.role = USER_ROLE_CUSTOMER;
          user.fcmToken = await FireStoreUtils.firebaseMessaging.getToken() ?? '';
          await FireStoreUtils.updateCurrentUser(user);
          MyAppState.currentUser = user;
          pushReplacement(context, ContainerScreen(user: user));
        } else {
          user.lastOnlineTimestamp = Timestamp.now();
          user.fcmToken = "";
          await FireStoreUtils.updateCurrentUser(user);
          await auth.FirebaseAuth.instance.signOut();
          MyAppState.currentUser = null;

          Provider.of<CartDatabase>(context, listen: false).deleteAllProducts();
          pushAndRemoveUntil(context, AuthScreen(), false);
        }
      } else {
        pushReplacement(context, AuthScreen());
      }
    } else {
      pushReplacement(context, AuthScreen());
    }
  }


  void showToastMsg(BuildContext context) {
    FToast fToast = FToast();
    fToast.init(context);
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Color(COLOR_PRIMARY),
      ),
      child: Text(
        "Please check your internet connection".tr(),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.CENTER,
      toastDuration: Duration(seconds: 4),
    );
  }
}
