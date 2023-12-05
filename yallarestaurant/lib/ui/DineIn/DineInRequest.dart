import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:foodie_restaurant/constants.dart';
import 'package:foodie_restaurant/model/CurrencyModel.dart';
import 'package:foodie_restaurant/services/helper.dart';
import 'package:foodie_restaurant/services/pushnotification.dart';
import 'package:foodie_restaurant/ui/DineIn/BookTableModel.dart';
import 'package:foodie_restaurant/ui/DineIn/HistoryTableBooking.dart';
import 'package:foodie_restaurant/ui/DineIn/UpComingTableBooking.dart';

class DineInRequest extends StatefulWidget {
  const DineInRequest({Key? key}) : super(key: key);

  @override
  State<DineInRequest> createState() => _DineInRequestState();
}

class _DineInRequestState extends State<DineInRequest> {
  late Future<List<CurrencyModel>> futureCurrency;
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  List<Widget> list = [
    Tab(text: ("Upcoming".tr())),
    Tab(text: ("History".tr())),
  ];

  @override
  void initState() {
    super.initState();

    final pushNotificationService = PushNotificationService(_firebaseMessaging);
    pushNotificationService.initialise();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          backgroundColor: isDarkMode(context) ? Color(DARK_VIEWBG_COLOR) : Color(0xffFFFFFF),
          appBar: TabBar(
            labelColor: Color(COLOR_PRIMARY),
            indicatorColor: Color(COLOR_PRIMARY),
            unselectedLabelColor: Color(GREY_TEXT_COLOR),
            indicatorSize: TabBarIndicatorSize.label,
            tabs: list,
          ),
          body: TabBarView(children: [
            UpComingTableBooking(),
            HistoryTableBooking(),
          ])),
    );
  }

  Widget buildTableOrderItem(BookTableModel bookTableModel) {
    return Card(
        elevation: 3,
        margin: EdgeInsets.only(bottom: 10, top: 10),
        color: isDarkMode(context) ? Color(COLOR_DARK) : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // if you need this
          side: BorderSide(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: NetworkImage(bookTableModel.vendor.photo),
                      fit: BoxFit.cover,
                      // colorFilter: ColorFilter.mode(
                      //     Colors.black.withOpacity(0.5), BlendMode.darken),
                    ),
                  )),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${bookTableModel.vendor.title}",
                      style: TextStyle(
                        fontFamily: "Poppinsssb",
                        fontSize: 18,
                        color: Color(0xff000000),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        "Table Booking Request".tr(),
                        style: TextStyle(
                          fontFamily: "Poppinssm",
                          color: Color(GREY_TEXT_COLOR),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ]),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: Text(
                "Booking Details".tr(),
                style: TextStyle(
                  fontFamily: "Poppinsssb",
                  fontSize: 16,
                ),
              ),
            ),
            buildDetails(iconsData: Icons.person_outline, title: 'Name'.tr(), value: "${bookTableModel.author.lastName} ${bookTableModel.author.lastName}"),
            buildDetails(iconsData: Icons.phone, title: 'Phone Number'.tr(), value: "${bookTableModel.author.phoneNumber}"),
            buildDetails(iconsData: Icons.date_range, title: 'Date'.tr(), value: "${DateFormat("MMM dd, yyyy 'at' hh:mm a").format(bookTableModel.date.toDate())}"),
            buildDetails(iconsData: Icons.group, title: 'Guest'.tr(), value: "${bookTableModel.totalGuest}"),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      child: Container(
                          padding: EdgeInsets.only(top: 8, bottom: 8),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), border: Border.all(width: 0.8, color: Color(COLOR_PRIMARY))),
                          child: Center(
                            child: Text(
                              'Accept'.tr(),
                              style: TextStyle(color: isDarkMode(context) ? Color(0xffFFFFFF) : Color(COLOR_PRIMARY), fontFamily: "Poppinsm", fontSize: 15
                                  // fontWeight: FontWeight.bold,
                                  ),
                            ),
                          )),
                      onTap: () {},
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      child: Container(
                          padding: EdgeInsets.only(top: 8, bottom: 8),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), border: Border.all(width: 0.8, color: Colors.grey)),
                          child: Center(
                            child: Text(
                              'Rejected'.tr(),
                              style: TextStyle(color: Colors.grey, fontFamily: "Poppinsm", fontSize: 15
                                  // fontWeight: FontWeight.bold,
                                  ),
                            ),
                          )),
                      onTap: () {},
                    ),
                  ),
                ),
              ],
            )
          ],
        ));
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
}
