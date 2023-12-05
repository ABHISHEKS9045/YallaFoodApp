import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:foodie_driver/constants.dart';
import 'package:foodie_driver/services/FirebaseHelper.dart';
import 'package:foodie_driver/services/helper.dart';
import 'package:foodie_driver/ui/auth/AuthScreen.dart';
import 'package:foodie_driver/ui/container/ContainerScreen.dart';
import 'package:foodie_driver/ui/onBoarding/OnBoardingScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'model/User.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    await EasyLocalization.ensureInitialized();
    SharedPreferences sp = await SharedPreferences.getInstance();
    String savedLang = sp.getString("languageCode").toString();
    if(savedLang == "null"){
      Lang = "ar";
    } else {
      Lang = savedLang;
    }

    FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    FirebaseCrashlytics.instance.sendUnsentReports();
    // await FirebaseAppCheck.instance.activate(
    //   webRecaptchaSiteKey: 'recaptcha-v3-site-key',
    // );

    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    // The following lines are the same as previously explained in "Handling uncaught errors"
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

    runApp(
      EasyLocalization(
        supportedLocales: [Locale('en'), Locale('ar'),Locale("he")],
        path: 'assets/translations',
        fallbackLocale: Locale('en'),
        useOnlyLangCode: true,
        startLocale: Locale(Lang),
        useFallbackTranslations: true,
        saveLocale: true,

        child: MyApp(),
      ),
    );
  }, (error, stack) => FirebaseCrashlytics.instance.recordError(error, stack));
}

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> with WidgetsBindingObserver {
  String TAG = "MyAppState";

  /// this key is used to navigate to the appropriate screen when the
  /// notification is clicked from the system tray
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey(debugLabel: 'Main Navigator');

  static User? currentUser;
  late StreamSubscription tokenStream;

  // Set default `_initialized` and `_error` state to false
  bool _initialized = false, isColorLoad = false;
  bool _error = false;
  var result;

  Future<void> setupInteractedMessage(BuildContext context) async {
    initialize(context);
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('$TAG Message also contained a notification: ${initialMessage.notification!.body}');
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('$TAG Got a message whilst in the foreground!');
      debugPrint('$TAG Message data: ${message.data}');

      if (message.notification != null) {
        debugPrint('$TAG Message data 1 : ${message.data}');
        display(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('$TAG On message app');
      debugPrint('$TAG Message data: ${message.data}');

      if (message.notification != null) {
        display(message);
      }
    });
  }

  Future<void> initialize(BuildContext context) async {
    AndroidNotificationChannel channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      importance: Importance.high,
    );

    await FlutterLocalNotificationsPlugin().resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
  }

  void display(RemoteMessage message) async {
    debugPrint("$TAG display notification message ========> ${message.toMap()}");
    print(message.notification!.title);
    print(message.notification!.body);
    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      const NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          "01",
          "Yalla_driver",
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: Color(0xFFFF683A),
          channelShowBadge: true,
          enableLights: true,
          enableVibration: true,
        ),
      );

      await FlutterLocalNotificationsPlugin().show(
        id,
        message.notification!.title,
        message.notification!.body,
        notificationDetails,
        payload: jsonEncode(message.data),
      );
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  // Define an async function to initialize FlutterFire
  void initializeFlutterFire() async {
    try {
      /// get token of firebase
      FireStoreUtils.firebaseMessaging.getToken().then((value) => {debugPrint("$TAG notification getToken event ==========> $value")});

      /// listen to firebase token changes and update the user object in the
      /// database with it's new token
      tokenStream = FireStoreUtils.firebaseMessaging.onTokenRefresh.listen((String event) {
        debugPrint("$TAG notification onTokenRefresh event ==========> $event");
        if (currentUser != null) {
          currentUser!.fcmToken = event;
          FireStoreUtils.updateCurrentUser(currentUser!);
        }
      });

      await FirebaseFirestore.instance.collection(Setting).doc("globalSettings").get().then((dineinresult) {
        if (dineinresult.exists && dineinresult.data() != null && dineinresult.data()!.containsKey("website_color")) {
          COLOR_PRIMARY = int.parse(dineinresult.data()!["website_color"].replaceFirst("#", "0xff"));

          setState(() {
            isColorLoad = true;
          });
        }
      });

      setState(() {
        _initialized = true;
      });
    } catch (e) {
      // Set `_error` state to true if Firebase initialization fails
      setState(() {
        _error = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show error message no internet connection
    if (result == ConnectivityResult.none) {
      return MaterialApp(
        locale: context.locale,
        supportedLocales: context.supportedLocales,
        localizationsDelegates: context.localizationDelegates,
        debugShowMaterialGrid: false,
        home: Scaffold(
          body: Container(
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/no_internet.png',
                  width: 70,
                  height: 70,
                  color: Colors.red,
                ),
                SizedBox(height: 40),
                Text(
                  'No internet connection.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 25,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Please check internet connection and restart app again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'OR',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 50),
                ElevatedButton(
                  onPressed: () {
                    retryCall();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.red,
                    minimumSize: Size(100, 40),
                  ),
                  child: Container(
                    child: Text(
                      "Retry",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Show error message if initialization failed
    if (_error) {
      return MaterialApp(
        debugShowMaterialGrid: false,
        home: Scaffold(
          body: Container(
            color: Colors.white,
            child: Center(
              child: Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 25,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Failed to load. \n Please try to close and reopen app.',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 25,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Show a loader until FlutterFire is initialized
    if (!_initialized || !isColorLoad) {
      return Container(
        color: Colors.white,
        child: Center(
          child: CircularProgressIndicator.adaptive(
            valueColor: AlwaysStoppedAnimation(
              Color(COLOR_PRIMARY),
            ),
          ),
        ),
      );
    }

    return  MaterialApp(
        navigatorKey: navigatorKey,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        debugShowMaterialGrid: false,
        title: 'Yalla Driver',
        theme: ThemeData(
            appBarTheme: AppBarTheme(
              centerTitle: true,
              color: Colors.transparent,
              elevation: 0,
              actionsIconTheme: IconThemeData(color: Color(COLOR_PRIMARY)),
              iconTheme: IconThemeData(color: Color(COLOR_PRIMARY)),
            ),
            bottomSheetTheme: BottomSheetThemeData(backgroundColor: Colors.white),
            primaryColor: Color(COLOR_PRIMARY),
            textTheme: TextTheme(
              titleLarge: TextStyle(
                color: Colors.black,
                fontSize: 17.0,
                letterSpacing: 0,
                fontWeight: FontWeight.w700,
              ),
            ),
            brightness: Brightness.light),
        darkTheme: ThemeData(
            appBarTheme: AppBarTheme(
              centerTitle: true,
              color: Colors.transparent,
              elevation: 0,
              actionsIconTheme: IconThemeData(
                color: Color(COLOR_PRIMARY),
              ),
              iconTheme: IconThemeData(
                color: Color(COLOR_PRIMARY),
              ),
            ),
            bottomSheetTheme: BottomSheetThemeData(backgroundColor: Colors.grey.shade900),
            primaryColor: Color(COLOR_PRIMARY),
            textTheme: TextTheme(
              titleLarge: TextStyle(
                color: Colors.grey[200],
                fontSize: 17.0,
                letterSpacing: 0,
                fontWeight: FontWeight.w700,
              ),
            ),
            brightness: Brightness.dark),
        debugShowCheckedModeBanner: false,
        color: Color(COLOR_PRIMARY),
        home: OnBoarding());
  }

  Future<void> checkConnectivity() async {
    var response = await Connectivity().checkConnectivity();
    setState(() {
      result = response;
    });
  }

  void retryCall() {
    debugPrint("Main App retryCall =========> called");
    initState();
  }

  @override
  void initState() {
    debugPrint("Main App initState =========> called");
    checkConnectivity();
    setupInteractedMessage(context);
    initializeFlutterFire();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    tokenStream.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (auth.FirebaseAuth.instance.currentUser != null && currentUser != null) {
      await FireStoreUtils.getCurrentUser(MyAppState.currentUser!.userID).then((value) {
        MyAppState.currentUser = value;
        if (state == AppLifecycleState.paused) {
          //user offline
          MyAppState.currentUser!.lastOnlineTimestamp = Timestamp.now();
          if (MyAppState.currentUser!.inProgressOrderID != null) {
            MyAppState.currentUser!.isActive = false;
          } else {
            MyAppState.currentUser!.isActive = MyAppState.currentUser!.isActive == true ? false : true;
          }
          FireStoreUtils.updateCurrentUser(MyAppState.currentUser!);
        } else if (state == AppLifecycleState.resumed) {
          //user online
          if (MyAppState.currentUser!.inProgressOrderID != null) {
            MyAppState.currentUser!.isActive = false;
          } else {
            MyAppState.currentUser!.isActive = MyAppState.currentUser!.isActive == false ? true : false;
          }
          FireStoreUtils.updateCurrentUser(MyAppState.currentUser!);
        }
      });
    }
  }
}

class OnBoarding extends StatefulWidget {
  @override
  State createState() {
    return OnBoardingState();
  }
}

class OnBoardingState extends State<OnBoarding> {
  Future hasFinishedOnBoarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool finishedOnBoarding = (prefs.getBool(FINISHED_ON_BOARDING) ?? false);

    if (finishedOnBoarding) {
      auth.User? firebaseUser = auth.FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        User? user = await FireStoreUtils.getCurrentUser(firebaseUser.uid);
        if (user != null && user.role == USER_ROLE_DRIVER) {
          if (user.active) {
            user.isActive = true;
            user.role = USER_ROLE_DRIVER;
            user.fcmToken = await FireStoreUtils.firebaseMessaging.getToken() ?? '';
            await FireStoreUtils.updateCurrentUser(user);
            MyAppState.currentUser = user;
            pushReplacement(context, ContainerScreen(user: user));
          } else {
            user.isActive = false;
            user.lastOnlineTimestamp = Timestamp.now();
            await FireStoreUtils.updateCurrentUser(user);
            await auth.FirebaseAuth.instance.signOut();
            MyAppState.currentUser = null;
            pushAndRemoveUntil(context, AuthScreen(), false);
          }
        } else {
          pushReplacement(context, AuthScreen());
        }
      } else {
        pushReplacement(context, AuthScreen());
      }
    } else {
      pushReplacement(context, OnBoardingScreen());
    }
  }

  @override
  void initState() {
    super.initState();
    hasFinishedOnBoarding();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CircularProgressIndicator.adaptive(
          valueColor: AlwaysStoppedAnimation(
            Color(COLOR_PRIMARY),
          ),
        ),
      ),
    );
  }
}
