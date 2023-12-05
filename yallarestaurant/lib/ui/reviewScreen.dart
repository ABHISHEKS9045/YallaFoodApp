import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:foodie_restaurant/constants.dart';
import 'package:foodie_restaurant/model/OrderProductModel.dart';
import 'package:foodie_restaurant/model/ProductModel.dart';
import 'package:foodie_restaurant/model/Ratingmodel.dart';
import 'package:foodie_restaurant/model/ReviewAttributeModel.dart';
import 'package:foodie_restaurant/model/VendorModel.dart';
import 'package:foodie_restaurant/model/categoryModel.dart';
import 'package:foodie_restaurant/services/FirebaseHelper.dart';
import 'package:foodie_restaurant/services/helper.dart';

class ReviewScreen extends StatefulWidget {
  final OrderProductModel product;
  final String? orderId;

  const ReviewScreen({Key? key, required this.product, this.orderId}) : super(key: key);

  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> with TickerProviderStateMixin {
  RatingModel? ratingModel;
  final List<dynamic> _mediaFiles = [];
  final _formKey = GlobalKey<FormState>();
  FireStoreUtils fireStoreUtils = FireStoreUtils();
  final comment = TextEditingController();
  var ratings = 0.0;
  var reviewCount, reviewSum;
  var vendorReviewCount, vendoReviewSum;

  ProductModel? productModel;
  VendorCategoryModel? vendorCategoryModel;

  List<ReviewAttributeModel> reviewAttributeList = [];

  // RatingModel? rating;
  @override
  void dispose() {
    comment.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    getCategoryAttributes();
  }

  Map<String, dynamic> reviewAttribute = {};
  Map<String, dynamic> reviewProductAttributes = {};
  VendorModel? vendorModel;

  getCategoryAttributes() async {
    await fireStoreUtils.getOrderReviewsbyID(widget.orderId.toString(), widget.product.id).then((value) {
      if (value != null) {
        setState(() {
          ratingModel = value;
          _mediaFiles.addAll(value.photos ?? []);
          ratings = value.rating ?? 0.0;
          comment.text = value.comment.toString();
          reviewAttribute = value.reviewAttributes!;
        });
      }
    });
    await fireStoreUtils.getProductByProductID(widget.product.id).then((value) {
      setState(() {
        productModel = value;

        if (ratingModel != null) {
          reviewCount = value.reviewsCount - 1;
          reviewSum = value.reviewsSum - num.parse(ratingModel!.rating.toString());

          if (value.reviewAttributes != null) {
            value.reviewAttributes!.forEach((key, value) {
              ReviewsAttribute reviewsAttributeModel = ReviewsAttribute.fromJson(value);
              reviewsAttributeModel.reviewsCount = reviewsAttributeModel.reviewsCount! - 1;
              reviewsAttributeModel.reviewsSum = reviewsAttributeModel.reviewsSum! - reviewAttribute[key];
              reviewProductAttributes.addEntries([MapEntry(key, reviewsAttributeModel.toJson())]);
            });
          }
        } else {
          reviewCount = value.reviewsCount;
          reviewSum = value.reviewsSum;
          reviewProductAttributes = value.reviewAttributes!;
        }
      });
    });

    vendorModel = await FireStoreUtils.getVendor(productModel!.vendorID);
    if (ratingModel != null) {
      vendorReviewCount = vendorModel!.reviewsCount - 1;
      vendoReviewSum = vendorModel!.reviewsSum - num.parse(ratingModel!.rating.toString());
    } else {
      vendorReviewCount = vendorModel!.reviewsCount;
      vendoReviewSum = vendorModel!.reviewsSum;
    }

    await fireStoreUtils.getVendorCategoryByCategoryId(widget.product.categoryId.toString()).then((value) {
      setState(() {
        vendorCategoryModel = value;
      });
    });
    for (var element in vendorCategoryModel!.reviewAttributes!) {
      await fireStoreUtils.getVendorReviewAttribute(element).then((value) {
        reviewAttributeList.add(value!);
      });
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode(context) ? Color(DARK_COLOR) : const Color(0XFFFDFEFE),
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back_ios,
            color: Color(COLOR_PRIMARY),
          ),
        ),
        title: Text("View Review", style: TextStyle(fontFamily: 'Poppinssb', color: isDarkMode(context) ? Colors.white : Colors.black)).tr(),
      ),
      body: SingleChildScrollView(
          child: Container(
              padding: const EdgeInsets.only(top: 20, left: 20),
              child: Form(
                key: _formKey,
                child: ratingModel != null
                    ? Column(
                        children: [
                          Card(
                              color: isDarkMode(context) ? const Color(0xff35363A) : const Color(0XFFFDFEFE),
                              elevation: 1,
                              margin: const EdgeInsets.only(right: 15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              child: SizedBox(
                                  height: 150,
                                  child: Column(children: [
                                    Container(
                                        alignment: Alignment.center,
                                        padding: const EdgeInsets.only(top: 15),
                                        child: Text(
                                          "Rate For".tr(),
                                          style: const TextStyle(color: Color(0XFF7C848E), fontFamily: 'Poppinsr', fontSize: 17),
                                        )),
                                    Container(
                                        alignment: Alignment.center,
                                        child: Text(widget.product.name,
                                            style: TextStyle(color: isDarkMode(context) ? const Color(0XFFFDFEFE) : const Color(0XFF000003), fontFamily: 'Poppinsm', fontSize: 20))),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    RatingBar.builder(
                                      ignoreGestures: true,
                                      initialRating: ratings,
                                      minRating: 1,
                                      direction: Axis.horizontal,
                                      itemCount: 5,
                                      itemPadding: const EdgeInsets.symmetric(horizontal: 6.0),
                                      itemBuilder: (context, _) => Icon(
                                        Icons.star,
                                        color: Color(COLOR_PRIMARY),
                                      ),
                                      onRatingUpdate: (double rate) {
                                        // print(ratings);
                                      },
                                    ),
                                  ]))),
                          const SizedBox(
                            height: 20,
                          ),
                          Card(
                            color: isDarkMode(context) ? const Color(0xff35363A) : const Color(0XFFFDFEFE),
                            elevation: 1,
                            margin: const EdgeInsets.only(right: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListView.builder(
                                itemCount: reviewAttributeList.length,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 5),
                                    child: Row(
                                      children: [
                                        Expanded(child: Text(reviewAttributeList[index].title.toString())),
                                        RatingBar.builder(
                                          initialRating: reviewAttribute[reviewAttributeList[index].id] is int
                                              ? double.parse(reviewAttribute[reviewAttributeList[index].id].toString())
                                              : reviewAttribute[reviewAttributeList[index].id] ?? 0.0,
                                          minRating: 1,
                                          direction: Axis.horizontal,
                                          allowHalfRating: true,
                                          itemCount: 5,
                                          itemSize: 25,
                                          ignoreGestures: true,
                                          itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
                                          itemBuilder: (context, _) => Icon(
                                            Icons.star,
                                            color: Color(COLOR_PRIMARY),
                                          ),
                                          onRatingUpdate: (double rate) {
                                            setState(() {
                                              reviewAttribute.addEntries([MapEntry(reviewAttributeList[index].id.toString(), rate)]);
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          _mediaFiles.isEmpty
                              ? Container()
                              : Padding(
                                  padding: const EdgeInsets.only(top: 35, bottom: 20),
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          height: 100,
                                          child: ListView.builder(
                                            itemCount: _mediaFiles.length,
                                            itemBuilder: (context, index) => SizedBox(width: 150, child: _imageBuilder(_mediaFiles[index])),
                                            shrinkWrap: true,
                                            scrollDirection: Axis.horizontal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                          Card(
                              color: isDarkMode(context) ? const Color(0xff35363A) : const Color(0XFFFDFEFE),
                              elevation: 1,
                              margin: const EdgeInsets.only(top: 10, right: 15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              child: Container(
                                  height: 140,
                                  padding: const EdgeInsets.only(top: 15, bottom: 15, right: 20, left: 20),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                          width: 0.5,
                                          color: const Color(0XFFD1D1E4),
                                        ),
                                        borderRadius: BorderRadius.circular(5)),
                                    constraints: const BoxConstraints(maxHeight: 100),
                                    child: SingleChildScrollView(
                                      child: Container(
                                          padding: const EdgeInsets.only(left: 10),
                                          child: TextFormField(
                                            validator: validateEmptyField,
                                            controller: comment,
                                            textInputAction: TextInputAction.next,
                                            enabled: false,
                                            decoration: InputDecoration(
                                                hintText: 'Type comment....'.tr(), hintStyle: const TextStyle(color: Color(0XFF8A8989), fontFamily: 'Poppinsr'), border: InputBorder.none),
                                            maxLines: null,
                                          )),
                                    ),
                                  ))),
                        ],
                      )
                    : Column(
                        children: [
                          Card(
                              color: isDarkMode(context) ? const Color(0xff35363A) : const Color(0XFFFDFEFE),
                              elevation: 1,
                              margin: const EdgeInsets.only(right: 15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              child: SizedBox(
                                  height: 150,
                                  child: Column(children: [
                                    Container(
                                        alignment: Alignment.center,
                                        padding: const EdgeInsets.only(top: 15),
                                        child: Text(
                                          "Rate For".tr(),
                                          style: const TextStyle(color: Color(0XFF7C848E), fontFamily: 'Poppinsr', fontSize: 17),
                                        )),
                                    Container(
                                        alignment: Alignment.center,
                                        child: Text(widget.product.name,
                                            style: TextStyle(color: isDarkMode(context) ? const Color(0XFFFDFEFE) : const Color(0XFF000003), fontFamily: 'Poppinsm', fontSize: 20))),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    RatingBar.builder(
                                      ignoreGestures: true,
                                      initialRating: 0,
                                      minRating: 1,
                                      direction: Axis.horizontal,
                                      allowHalfRating: true,
                                      itemCount: 5,
                                      itemPadding: const EdgeInsets.symmetric(horizontal: 6.0),
                                      itemBuilder: (context, _) => Icon(
                                        Icons.star,
                                        color: Color(COLOR_PRIMARY),
                                      ),
                                      onRatingUpdate: (double rate) {
                                        ratings = rate;
                                      },
                                    ),
                                  ]))),

                          // SizedBox(height: 20,),

                          Card(
                            color: isDarkMode(context) ? const Color(0xff35363A) : const Color(0XFFFDFEFE),
                            elevation: 1,
                            margin: const EdgeInsets.only(right: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListView.builder(
                                itemCount: reviewAttributeList.length,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 5),
                                    child: Row(
                                      children: [
                                        Expanded(child: Text(reviewAttributeList[index].title.toString())),
                                        RatingBar.builder(
                                          initialRating: reviewAttribute[reviewAttributeList[index].id] ?? 0.0,
                                          minRating: 1,
                                          direction: Axis.horizontal,
                                          allowHalfRating: true,
                                          itemCount: 5,
                                          itemSize: 25,
                                          itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
                                          itemBuilder: (context, _) => Icon(
                                            Icons.star,
                                            color: Color(COLOR_PRIMARY),
                                          ),
                                          onRatingUpdate: (double rate) {
                                            setState(() {
                                              reviewAttribute.addEntries([MapEntry(reviewAttributeList[index].id.toString(), rate)]);
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          _mediaFiles.isNotEmpty
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 35, bottom: 20),
                                  child: SizedBox(
                                    height: 100,
                                    child: ListView.builder(
                                      itemCount: _mediaFiles.length,
                                      itemBuilder: (context, index) => SizedBox(width: 150, child: _imageBuilder(_mediaFiles[index])),
                                      shrinkWrap: true,
                                      scrollDirection: Axis.horizontal,
                                    ),
                                  ),
                                )
                              : const Center(),
                          Card(
                              color: isDarkMode(context) ? const Color(0xff35363A) : const Color(0XFFFDFEFE),
                              elevation: 1,
                              margin: const EdgeInsets.only(top: 10, right: 15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              child: Container(
                                  height: 170,
                                  padding: const EdgeInsets.only(top: 15, bottom: 15, right: 20, left: 20),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                          width: 0.5,
                                          color: const Color(0XFFD1D1E4),
                                        ),
                                        borderRadius: BorderRadius.circular(5)),
                                    constraints: const BoxConstraints(maxHeight: 100),
                                    child: SingleChildScrollView(
                                      child: Container(
                                          padding: const EdgeInsets.only(left: 10),
                                          child: TextField(
                                            controller: comment,
                                            textInputAction: TextInputAction.send,
                                            decoration: InputDecoration(
                                                hintText: 'Type comment....'.tr(), hintStyle: const TextStyle(color: Color(0XFF8A8989), fontFamily: 'Poppinsr'), border: InputBorder.none),
                                            maxLines: null,
                                          )),
                                    ),
                                  ))),
                        ],
                      ),
              ))),
      //
    );
  }

  showAlertDialog(BuildContext context, String title, String content, bool addOkButton) {
    // set up the AlertDialog
    Widget? okButton;
    if (addOkButton) {
      okButton = TextButton(
        child: const Text('OK').tr(),
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

  _imageBuilder(dynamic image) {
    // bool isLastItem = image == null;
    return
        // GestureDetector(
        //   onTap: () {
        //       _viewOrDeleteImage(image);
        //   },
        //   child:
        Stack(children: [
      Container(
        padding: const EdgeInsets.only(right: 20),

        child: Card(
          // margin:  EdgeInsets.only(right: 10),
          shape: RoundedRectangleBorder(
            side: BorderSide.none,
            borderRadius: BorderRadius.circular(5),
          ),
          color: isDarkMode(context) ? Colors.black : Colors.white,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: image is File
                ? Image.file(
                    image,
                    fit: BoxFit.cover,
                  )
                : displayImage(image),
          ),
        ),
        // ),
      ),
    ]);
  }
}
