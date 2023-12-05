import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:foodie_driver/constants.dart';
import 'package:foodie_driver/main.dart';
import 'package:foodie_driver/model/User.dart';
import 'package:foodie_driver/services/FirebaseHelper.dart';
import 'package:foodie_driver/services/helper.dart';

class SettingsScreen extends StatefulWidget {
  final User user;

  const SettingsScreen({Key? key, required this.user}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late User user;

  late bool pushNewMessages, orderUpdates, newArrivals, promotions;

  int cartCount = 0;

  @override
  void initState() {
    user = widget.user;
    pushNewMessages = user.settings.pushNewMessages;
    orderUpdates = user.settings.orderUpdates;
    newArrivals = user.settings.newArrivals;
    promotions = user.settings.promotions;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode(context) ? Color(DARK_VIEWBG_COLOR) : Colors.white,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(
            color: isDarkMode(context) ? Colors.white : Colors.black,
          ),
        ).tr(),
      ),
      body: SingleChildScrollView(
        child: Builder(
            builder: (buildContext) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0, left: 16, top: 16, bottom: 8),
                      child: Text(
                        'Push Notifications',
                        style: TextStyle(color: isDarkMode(context) ? Colors.white54 : Colors.black54, fontSize: 18),
                      ).tr(),
                    ),
                    Material(
                      elevation: 2,
                      color: isDarkMode(context) ? Color(DARK_CARD_BG_COLOR) : Colors.white,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SwitchListTile.adaptive(
                              activeColor: Color(COLOR_ACCENT),
                              title: Text(
                                'Allow Push Notifications',
                                style: TextStyle(
                                  fontSize: 17,
                                  color: isDarkMode(context) ? Colors.white : Colors.black,
                                ),
                              ).tr(),
                              value: pushNewMessages,
                              onChanged: (bool newValue) {
                                pushNewMessages = newValue;
                                setState(() {});
                              }),
                          SwitchListTile.adaptive(
                              activeColor: Color(COLOR_ACCENT),
                              title: Text(
                                'Order Updates',
                                style: TextStyle(
                                  fontSize: 17,
                                  color: isDarkMode(context) ? Colors.white : Colors.black,
                                ),
                              ).tr(),
                              value: orderUpdates,
                              onChanged: (bool newValue) {
                                orderUpdates = newValue;
                                setState(() {});
                              }),
                          // SwitchListTile.adaptive(
                          //     activeColor: Color(COLOR_ACCENT),
                          //     title: Text(
                          //       'New Arrivals',
                          //       style: TextStyle(
                          //         fontSize: 17,
                          //         color: isDarkMode(context)
                          //             ? Colors.white
                          //             : Colors.black,
                          //       ),
                          //     ).tr(),
                          //     value: newArrivals,
                          //     onChanged: (bool newValue) {
                          //       newArrivals = newValue;
                          //       setState(() {});
                          //     }),
                          SwitchListTile.adaptive(
                              activeColor: Color(COLOR_ACCENT),
                              title: Text(
                                'Promotions',
                                style: TextStyle(
                                  fontSize: 17,
                                  color: isDarkMode(context) ? Colors.white : Colors.black,
                                ),
                              ).tr(),
                              value: promotions,
                              onChanged: (bool newValue) {
                                promotions = newValue;
                                setState(() {});
                              }),
                        ],
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
                              showProgress(context, 'Saving changes...'.tr(), true);
                              user.settings.pushNewMessages = pushNewMessages;
                              user.settings.orderUpdates = orderUpdates;
                              user.settings.newArrivals = newArrivals;
                              user.settings.promotions = promotions;
                              User? updateUser = await FireStoreUtils.updateCurrentUser(user);
                              hideProgress();
                              if (updateUser != null) {
                                this.user = updateUser;
                                MyAppState.currentUser = user;
                                ScaffoldMessenger.of(buildContext).showSnackBar(SnackBar(
                                    duration: Duration(seconds: 3),
                                    content: Text(
                                      'Settings saved successfully',
                                      style: TextStyle(fontSize: 17),
                                    ).tr()));
                              }
                            },
                            child: Text(
                              'Save',
                              style: TextStyle(fontSize: 18, color: Color(COLOR_PRIMARY)),
                            ).tr(),
                            color: isDarkMode(context) ? Colors.black12 : Colors.white,
                          ),
                        ),
                      ),
                    )
                  ],
                )),
      ),
    );
  }
}
