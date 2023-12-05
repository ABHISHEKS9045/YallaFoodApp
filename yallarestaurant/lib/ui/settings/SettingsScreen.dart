import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:foodie_restaurant/constants.dart';
import 'package:foodie_restaurant/main.dart';
import 'package:foodie_restaurant/model/User.dart';
import 'package:foodie_restaurant/model/VendorModel.dart';
import 'package:foodie_restaurant/services/FirebaseHelper.dart';
import 'package:foodie_restaurant/services/helper.dart';

class SettingsScreen extends StatefulWidget {
  //final User user;

  const SettingsScreen({
    Key? key,
    /*required this.user*/
  }) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  User? user;
  VendorModel vendor = VendorModel();
  bool pushNewMessages = false, orderUpdates = false, newArrivals = false, promotions = false, photos = false, reststatus = false;

  VendorModel? vendors;

  @override
  void initState() {
    //user = widget.user;
    FireStoreUtils.getCurrentUser(MyAppState.currentUser!.userID).then((value) {
      setState(() {
        user = value!;
        pushNewMessages = user!.settings.pushNewMessages;
        orderUpdates = user!.settings.orderUpdates;
        newArrivals = user!.settings.newArrivals;
        promotions = user!.settings.promotions;

        //print(promotions.toString()+"====UR1"+value.toJson().toString());
      });
    });
    FireStoreUtils.getVendor(MyAppState.currentUser!.vendorID).then((value) {
      setState(() {
        vendors = value;
        reststatus = vendors!.restStatus;
        photos = vendors!.hidePhotos;
      });
    });
    //reststatus = user!.settings.reststatus;
    //print(widget.user.settings.promotions.toString()+"====U");
    print(MyAppState.currentUser!.settings.promotions.toString() + "====UR");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode(context) ? Color(DARK_VIEWBG_COLOR) : Colors.white,
      appBar: AppBar(
        title: Text(
          'Settings'.tr(),
          style: TextStyle(
            color: isDarkMode(context) ? Color(0xFFFFFFFF) : Color(0Xff333333),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Builder(
          builder: (buildContext) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 16.0, left: 16, top: 16, bottom: 8),
                child: Text(
                  'Push Notifications'.tr(),
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
                          'Allow Push Notifications'.tr(),
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
                          'Order Updates'.tr(),
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
                    /*SwitchListTile.adaptive(
                        activeColor: Color(COLOR_ACCENT),
                        title: Text(
                          'New Arrivals',
                          style: TextStyle(
                            fontSize: 17,
                            color: isDarkMode(context)
                                ? Colors.white
                                : Colors.black,
                          ),
                        ).tr(),
                        value: newArrivals,
                        onChanged: (bool newValue) {
                          newArrivals = newValue;
                          setState(() {});
                        }),*/ /*SwitchListTile.adaptive(
                        activeColor: Color(COLOR_ACCENT),
                        title: Text(
                          'New Arrivals',
                          style: TextStyle(
                            fontSize: 17,
                            color: isDarkMode(context)
                                ? Colors.white
                                : Colors.black,
                          ),
                        ).tr(),
                        value: newArrivals,
                        onChanged: (bool newValue) {
                          newArrivals = newValue;
                          setState(() {});
                        }),*/
                    SwitchListTile.adaptive(
                        activeColor: Color(COLOR_ACCENT),
                        title: Text(
                          'Promotions'.tr(),
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
                    SwitchListTile.adaptive(
                        activeColor: Color(COLOR_ACCENT),
                        title: Text(
                          'Hide Photos'.tr(),
                          style: TextStyle(
                            fontSize: 17,
                            color: isDarkMode(context) ? Colors.white : Colors.black,
                          ),
                        ).tr(),
                        value: photos,
                        onChanged: (bool newValue) {
                          photos = newValue;
                          setState(() {});
                        }),
                    Container(
                        padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                        child: Text(
                          "NOTE : Hides your photos from the photo section, without disturbing photos on the menu item listing.".tr(),
                          style: TextStyle(fontSize: 15),
                        )),
                    SwitchListTile.adaptive(
                        activeColor: Color(COLOR_ACCENT),
                        title: Text(
                          'Restaurant Status',
                          style: TextStyle(
                            fontSize: 17,
                            color: isDarkMode(context) ? Colors.white : Colors.black,
                          ),
                        ).tr(),
                        value: reststatus,
                        onChanged: (bool newValue) {
                          reststatus = newValue;
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
                        user!.settings.pushNewMessages = pushNewMessages;
                        user!.settings.orderUpdates = orderUpdates;
                        user!.settings.newArrivals = newArrivals;
                        user!.settings.promotions = promotions;
                        user!.settings.photos = photos;
                        user!.settings.reststatus = reststatus;
                        vendor.id = MyAppState.currentUser!.vendorID;
                        if(MyAppState.currentUser!.vendorID.isNotEmpty){
                          await FireStoreUtils.updatestatus(vendor, reststatus);
                          await FireStoreUtils.updatePhoto(vendor, photos);
                        }

                        User? updateUser = await FireStoreUtils.updateCurrentUser(user!);
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
          ),
        ),
      ),
    );
  }
}
