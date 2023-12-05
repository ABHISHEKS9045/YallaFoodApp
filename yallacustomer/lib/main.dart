import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:foodie_customer/constants.dart';
import 'package:foodie_customer/model/CurrencyModel.dart';
import 'package:foodie_customer/services/FirebaseHelper.dart';
import 'package:foodie_customer/services/helper.dart';
import 'package:foodie_customer/services/localDatabase.dart';
import 'package:foodie_customer/ui/auth/AuthScreen.dart';
import 'package:foodie_customer/ui/container/ContainerScreen.dart';
import 'package:foodie_customer/ui/onBoarding/OnBoardingScreen.dart';
import 'package:foodie_customer/ui/ordersScreen/OrdersScreen.dart';
import 'package:foodie_customer/userPrefrence.dart';
import 'package:foodie_customer/utils/DarkThemeProvider.dart';
import 'package:foodie_customer/utils/Styles.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'model/User.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    // await FirebaseAppCheck.instance.activate(
    //   webRecaptchaSiteKey: 'recaptcha-v3-site-key',
    // );
    await EasyLocalization.ensureInitialized();
    SharedPreferences sp = await SharedPreferences.getInstance();

    String savedLang = sp.getString("languageCode").toString();
    if(savedLang == "null"){
      lang = "ar";
    }
    else{
      lang = savedLang;
    }

    FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    FirebaseCrashlytics.instance.sendUnsentReports();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
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



    await UserPreference.init();
    runApp(
      MultiProvider(
        providers: [
          Provider<CartDatabase>(
            create: (_) => CartDatabase(),
          ),
        ],
        child: EasyLocalization(
          supportedLocales: [ Locale('ar'),Locale('en'),Locale('he')],
          path: 'assets/translations',
          startLocale: Locale(lang.toString()),
          fallbackLocale: Locale('en'),
          saveLocale: true,

          useOnlyLangCode: true,
          useFallbackTranslations: true,
          child: MyApp(),
        ),
      ),
    );
  }, (error, stack) => FirebaseCrashlytics.instance.recordError(error, stack));
}

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> with WidgetsBindingObserver {
  static const String TAG = "MyAppState";
  bool notificationClick = false;

  Future<void> setupInteractedMessage(BuildContext context) async {
    initialize(context);
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? initialMessage) {
      if (initialMessage != null) {
        print('$TAG get initial message ===============> ');
        print('$TAG Message also contained a notification ===============> ${initialMessage.notification!.body}');
        setState(() {
          notificationClick = true;
        });
        if (initialMessage.data["type"] == "order") {
          notificationRedirection(context);
        }
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('$TAG Got a message in the foreground ==========> ');
      print('$TAG Message data =======> ${message.data}');
      if (message.notification != null) {
        display(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('$TAG On message opened app');
      print('$TAG Message data ==========> ${message.data}');
      if (message.notification != null) {
        display(message);
        // setState(() {
        //   notificationClick = true;
        // });
        // if (message.data["type"] == "order") {
        //   notificationRedirection(context);
        // }
      }
    });

    FirebaseMessaging.instance.getToken().then((String? value) {
      //debugPrint("$TAG get firebase token =========> $value");
    });
  }

  Future<void> initialize(BuildContext context) async {
    AndroidNotificationChannel channel = const AndroidNotificationChannel(
      'Yalla', // id
      'High Importance Notifications', // title
      importance: Importance.high,
    );

    await FlutterLocalNotificationsPlugin().resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
  }

  void display(RemoteMessage message) async {
    print(message.notification!.title);
    print(message.notification!.body);
    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      const NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          "Yalla",
          "High Importance Notifications",
          importance: Importance.max,
          icon: '@mipmap/ic_launcher',
          priority: Priority.high,
          color: Color(0xFFFF683A),
          channelShowBadge: true,
          enableLights: true,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(
          presentBadge: true,
          presentSound: true,
          presentAlert: true,
          interruptionLevel: InterruptionLevel.active,
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
      print("$TAG Exception ===============> ${e.toString()}");
    }
  }

  static User? currentUser;
  static Position selectedPosotion = Position.fromMap({'latitude': 0.0, 'longitude': 0.0});
  late StreamSubscription tokenStream;

  // Set default `_initialized` and `_error` state to false
  bool _initialized = false, isColorLoad = false;
  bool _error = false;
  var result;

  //  late Stream<StripeKeyModel> futureStirpe;
  //  String? data,d;

  // Define an async function to initialize FlutterFire
  void initializeFlutterFire() async {
    try {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

      final FlutterExceptionHandler? originalOnError = FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails errorDetails) async {
        await FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
        originalOnError!(errorDetails);
        // Forward to original handler.
      };
      FirebaseFirestore.instance.collection(Setting).doc("globalSettings").get().then((dineinresult) {
        if (dineinresult.exists && dineinresult.data() != null && dineinresult.data()!.containsKey("website_color")) {
          COLOR_PRIMARY = int.parse(dineinresult.data()!["website_color"].replaceFirst("#", "0xff"));
          setState(() {
            isColorLoad = true;
          });
        }
      });
      FirebaseFirestore.instance.collection(Setting).doc("DineinForRestaurant").get().then((dineinresult) {
        if (dineinresult.exists) {
          isDineInEnable = dineinresult.data()!["isEnabledForCustomer"];
        }
      });
      await FirebaseFirestore.instance.collection(Setting).doc("Version").get().then((value) {
        //debugPrint(value.data().toString());
        appVersion = value.data()!['app_version'].toString();
      });

      tokenStream = FireStoreUtils.firebaseMessaging.onTokenRefresh.listen((event) {
        //debugPrint('token $event');
        if (currentUser != null) {
          currentUser!.fcmToken = event;
          FireStoreUtils.updateCurrentUser(currentUser!);
        }
      });

      setState(() {
        _initialized = true;
      });
    } catch (e) {
      //debugPrint(e.toString());
      // Set `_error` state to true if Firebase initialization fails
      setState(() {
        _error = true;
      });
    }
  }

  DarkThemeProvider themeChangeProvider = DarkThemeProvider();

  @override
  Widget build(BuildContext context) {
    // Show error message no internet connection
    if (result == ConnectivityResult.none) {
      return MaterialApp(
        locale: context.locale,
        supportedLocales: context.supportedLocales,
        localizationsDelegates: context.localizationDelegates,
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
                  'No internet connection.'.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 25,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Please check internet connection and restart app again.'.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'or'.tr(),
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
                      "Retry".tr(),
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
        locale: context.locale,
        supportedLocales: context.supportedLocales,
        localizationsDelegates: context.localizationDelegates,
        home: Scaffold(
          body: Container(
            color: Colors.white,
            child: Center(
                child: Column(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 25,
                ),
                SizedBox(height: 16),
                Text(
                  'Failed to initialise firebase!'.tr(),
                  style: TextStyle(color: Colors.red, fontSize: 25),
                ),
              ],
            )),
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
            valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
          ),
        ),
      );
    } else {
      return ChangeNotifierProvider(
        create: (_) {
          return themeChangeProvider;
        },
        child:
        Consumer<DarkThemeProvider>(
          builder: (context, value, child) {
            return MaterialApp(
              localizationsDelegates: context.localizationDelegates,
              locale: context.locale,
              supportedLocales: context.supportedLocales,
              debugShowCheckedModeBanner: false,
              theme: Styles.themeData(themeChangeProvider.darkTheme, context),
              home: OnBoarding(),
            );
          },
        )
      );
    }
  }

  Future<void> checkConnectivity() async {
    var response = await Connectivity().checkConnectivity();
    setState(() {
      result = response;
    });
  }

  void retryCall() {
    //debugPrint("Main App retryCall =========> called");
    initState();
  }

  @override
  void initState() {
    //debugPrint("Main App initState =========> called");
    checkConnectivity();
    initializeFlutterFire();
    setupInteractedMessage(context);
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
  void didChangeAppLifecycleState(AppLifecycleState state) {
   /* if (auth.FirebaseAuth.instance.currentUser != null && currentUser != null) {
      if (state == AppLifecycleState.paused) {
        //user offline
        tokenStream.pause();
        currentUser!.active = false;
        currentUser!.lastOnlineTimestamp = Timestamp.now();
        FireStoreUtils.updateCurrentUser(currentUser!);
      } else if (state == AppLifecycleState.resumed) {
        //user online
        tokenStream.resume();
        currentUser!.active = true;
        FireStoreUtils.updateCurrentUser(currentUser!);
      }
    }*/
  }

  Future notificationRedirection(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool finishedOnBoarding = (prefs.getBool(FINISHED_ON_BOARDING) ?? false);

    if (finishedOnBoarding) {
      auth.User? firebaseUser = auth.FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        User? user = await FireStoreUtils.getCurrentUser(firebaseUser.uid);

        if (user != null && user.role == USER_ROLE_CUSTOMER) {
          if (user.active) {
            user.active = true;
            user.role = USER_ROLE_CUSTOMER;
            user.fcmToken = await FireStoreUtils.firebaseMessaging.getToken() ?? '';
            await FireStoreUtils.updateCurrentUser(user);
            MyAppState.currentUser = user;
            pushReplacement(
              context,
              ContainerScreen(
                user: user,
                currentWidget: OrdersScreen(isAnimation: true),
                appBarTitle: 'Orders'.tr(),
                drawerSelection: DrawerSelection.Orders,
              ),
            );
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
    } else {
      pushReplacement(context, OnBoardingScreen());
    }
  }
}

class OnBoarding extends StatefulWidget {
  OnBoarding({Key? key}) : super(key: key);

  @override
  State createState() {
    return OnBoardingState();
  }
}

class OnBoardingState extends State<OnBoarding> {
  late Future<List<CurrencyModel>> futureCurrency;

  Future hasFinishedOnBoarding(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool finishedOnBoarding = (prefs.getBool(FINISHED_ON_BOARDING) ?? false);

    if (finishedOnBoarding) {
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
    } else {
      checkLoginStatus(context);
      // pushReplacement(context, ContainerScreen(user: null,));
    }
  }
  Future checkLoginStatus(BuildContext context) async {
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
  @override
  void initState() {
    super.initState();
    hasFinishedOnBoarding(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CircularProgressIndicator.adaptive(
          valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
        ),
      ),
    );
  }
}
