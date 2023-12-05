import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:foodie_restaurant/main.dart';
import 'package:foodie_restaurant/services/FirebaseHelper.dart';
import 'package:foodie_restaurant/services/helper.dart';
import 'package:foodie_restaurant/ui/offer/offer_model/offer_model.dart';

import '../../constants.dart';
import 'add_offer_screen.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({Key? key}) : super(key: key);

  @override
  _OffersScreenState createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  Stream<List<OfferModel>>? lstOfferData;
  FireStoreUtils fireStoreUtils = FireStoreUtils();

  @override
  void initState() {


    super.initState();
    if (MyAppState.currentUser!.vendorID.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        final snackBar = SnackBar(
          content: const Text('Please add a restaurant first').tr(),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      });
    } else {
      lstOfferData = fireStoreUtils.getOfferStream(MyAppState.currentUser!.vendorID);
    }

    //print(lstOfferData!.length.toString());
  }

  @override
  void dispose() {

    fireStoreUtils.closeOfferStream();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode(context) ? Color(DARK_VIEWBG_COLOR) : null,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FloatingActionButton(
          elevation: 10,
          onPressed: () {
            if (MyAppState.currentUser!.vendorID.isEmpty) {
              final snackBar = SnackBar(
                content: const Text('Please add a restaurant first'),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            } else {
              push(
                context,
                AddOfferScreen(
                  offerModel: null,
                ),
              );
            }
          },
          child: Image(
            image: AssetImage('assets/images/plus.png'),
            width: 55,
          ),
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
        child: Builder(builder: (context) {
          return StreamBuilder<List<OfferModel>>(
              stream: lstOfferData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return Container(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                if (!snapshot.hasData || (snapshot.data?.isEmpty ?? true)) {
                  return Container(
                    height: MediaQuery.of(context).size.height * 0.9,
                    alignment: Alignment.center,
                    child: showEmptyState('No Coupons'.tr(), 'All your coupons will show up here'.tr()),
                  );
                } else {
                  return ListView.builder(
                      itemCount: snapshot.data!.length,
                      scrollDirection: Axis.vertical,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            print(snapshot.data![index].offerId.toString() + "[][]");
                            push(
                              context,
                              AddOfferScreen(
                                offerModel: snapshot.data![index],
                              ),
                            );
                          },
                          child: Stack(
                            alignment: Alignment.bottomLeft,
                            children: [
                              Container(
                                margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
                                child: Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10), // if you need this
                                    side: BorderSide(
                                      color: Colors.grey.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Container(
                                    color: isDarkMode(context) ? Color(DARK_CARD_BG_COLOR) : Colors.white,
                                    padding: EdgeInsets.fromLTRB(7, 7, 7, 7),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: new BorderRadius.circular(10),
                                          child: CachedNetworkImage(
                                            imageUrl: snapshot.data![index].imageOffer!.isEmpty ? "" : snapshot.data![index].imageOffer!,
                                            height: 100,
                                            width: 100,
                                            fit: BoxFit.cover,
                                            errorWidget: (context, url, error) => Container(
                                              width: 100,
                                              height: 100,
                                              decoration: new BoxDecoration(
                                                borderRadius: new BorderRadius.circular(10),
                                                color: Colors.black12,
                                              ),
                                              child: Image(
                                                image: index % 2 == 0 ? AssetImage("assets/images/offer_placeholder_1.png") : AssetImage("assets/images/offer_placeholder_2.png"),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            placeholder: (context, url) => Padding(
                                              padding: const EdgeInsets.all(32.0),
                                              child: CircularProgressIndicator(),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 15,
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                height: 10,
                                              ),
                                              DottedBorder(
                                                borderType: BorderType.RRect,
                                                radius: Radius.circular(2),
                                                padding: EdgeInsets.all(2),
                                                color: Color(COUPON_DASH_COLOR),
                                                strokeWidth: 2,
                                                dashPattern: [5],
                                                child: Padding(
                                                  padding: EdgeInsets.fromLTRB(12, 0, 12, 0),
                                                  child: Container(
                                                      height: 25,
                                                      decoration: new BoxDecoration(
                                                        borderRadius: new BorderRadius.circular(2),
                                                        color: Color(COUPON_BG_COLOR),
                                                      ),
                                                      margin: EdgeInsets.only(top: 4),
                                                      child: Text(
                                                        snapshot.data![index].offerCode!,
                                                        textAlign: TextAlign.left,
                                                        style: TextStyle(fontSize: 17, fontFamily: "Poppins", fontWeight: FontWeight.bold, letterSpacing: 0.5, color: Color(COLOR_PRIMARY)),
                                                      )),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 15,
                                              ),
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Image(
                                                    image: AssetImage('assets/images/offer_icon.png'),
                                                    height: 25,
                                                    width: 25,
                                                  ),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  Expanded(
                                                      child: Text("This offer is expire on".tr() + " " + getDate(snapshot.data![index].expireOfferDate!.toDate().toString())!,
                                                          style: TextStyle(fontSize: 15, fontFamily: "Poppins", letterSpacing: 0.5, color: Color(0Xff696A75))))
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: AlignmentDirectional.bottomStart,
                                child: Container(
                                  child: Stack(
                                    alignment: Alignment.topCenter,
                                    children: [
                                      Container(width: 75, margin: EdgeInsets.only(bottom: 10), child: Image(image: AssetImage("assets/images/offer_badge.png"))),
                                      Container(
                                        margin: EdgeInsets.only(top: 3),
                                        child: Text(
                                          "${snapshot.data![index].discountTypeOffer == "Fix Price" ? "$symbol" : ""}${snapshot.data![index].discountOffer}${snapshot.data![index].discountTypeOffer == "Percentage" ? "% Off" : " Off"}",
                                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.7),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      });
                }
              });
        }),
      ),
    );
  }

  String? getDate(String date) {
    final format = DateFormat("dd MMM, yyyy");
    String formattedDate = format.format(DateTime.parse(date));
    return formattedDate;
  }
}
