import 'dart:io';

import 'package:barcode_image/barcode_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodie_restaurant/main.dart';
import 'package:foodie_restaurant/model/DeliveryChargeModel.dart';
import 'package:foodie_restaurant/model/VendorModel.dart';
import 'package:foodie_restaurant/model/categoryModel.dart';
import 'package:foodie_restaurant/services/FirebaseHelper.dart';
import 'package:foodie_restaurant/services/helper.dart';
import 'package:foodie_restaurant/ui/QrCodeGenerator/QrCodeGenerator.dart';
import 'package:foodie_restaurant/ui/fullScreenImageViewer/FullScreenImageViewer.dart';
import 'package:foodie_restaurant/ui/restaurant_location/restaurant_location.dart';
import 'package:image/image.dart' as ImageVar;
import 'package:image_picker/image_picker.dart';
import 'package:multiselect/multiselect.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../constants.dart';

class AddRestaurantScreen extends StatefulWidget {
  AddRestaurantScreen({Key? key}) : super(key: key);

  @override
  _AddRestaurantScreenState createState() => _AddRestaurantScreenState();
}

class _AddRestaurantScreenState extends State<AddRestaurantScreen> {
  final restaurantName = TextEditingController();
  final description = TextEditingController();
  final phonenumber = TextEditingController();
  final deliverChargeKm = TextEditingController();
  final minDeliveryCharge = TextEditingController();
  final minDeliveryChargewkm = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  List<VendorCategoryModel> categoryLst = [];
  VendorCategoryModel? selectedCategory;
  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;
  DeliveryChargeModel? deliveryChargeModel;

  @override
  void dispose() {
    restaurantName.dispose();
    description.dispose();
    phonenumber.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    FireStoreUtils.getDelivery().then((value) {
      setState(() {
        deliveryChargeModel = value;
        if (deliveryChargeModel != null && !deliveryChargeModel!.vendorCanModify) {
          deliverChargeKm.text = deliveryChargeModel!.deliveryChargesPerKm.toString();
          minDeliveryCharge.text = deliveryChargeModel!.minimumDeliveryCharges.toString();
          minDeliveryChargewkm.text = deliveryChargeModel!.minimumDeliveryChargesWithinKm.toString();
        }
      });
    });

    getVendorData();
  }

  final ImagePicker _imagePicker = ImagePicker();
  List<dynamic> _mediaFiles = [];
  List<String> selected = [];

  Map<String, dynamic> filters = {};
  var yes = "Yes";

  filter() {
    if (selected.contains('Good for Breakfast')) {
      filters['Good for Breakfast'] = 'Yes';
    } else {
      filters['Good for Breakfast'] = 'No';
    }
    if (selected.contains('Good for Lunch')) {
      filters['Good for Lunch'] = 'Yes';
    } else {
      filters['Good for Lunch'] = 'No';
    }

    if (selected.contains('Good for Dinner')) {
      filters['Good for Dinner'] = 'Yes';
    } else {
      filters['Good for Dinner'] = 'No';
    }

    if (selected.contains('Takes Reservations')) {
      filters['Takes Reservations'] = 'Yes';
    } else {
      filters['Takes Reservations'] = 'No';
    }

    if (selected.contains('Vegetarian Friendly')) {
      filters['Vegetarian Friendly'] = 'Yes';
    } else {
      filters['Vegetarian Friendly'] = 'No';
    }

    if (selected.contains('Live Music')) {
      filters['Live Music'] = 'Yes';
    } else {
      filters['Live Music'] = 'No';
    }

    if (selected.contains('Outdoor Seating')) {
      filters['Outdoor Seating'] = 'Yes';
    } else {
      filters['Outdoor Seating'] = 'No';
    }

    if (selected.contains('Free Wi-Fi')) {
      filters['Free Wi-Fi'] = 'Yes';
    } else {
      filters['Free Wi-Fi'] = 'No';
    }
  }

  VendorModel? vendorData;
  bool isLoading = true;

  getVendorData() async {
    categoryLst = await FireStoreUtils.getVendorCategoryById();

    if (MyAppState.currentUser!.vendorID != '') {
      await FireStoreUtils.getVendor(MyAppState.currentUser!.vendorID).then((value) async {
        vendorData = value;

        print(vendorData!.toJson());
        VendorCategoryModel vendorCategoryModel = VendorCategoryModel(id: vendorData!.categoryID, title: vendorData!.categoryTitle);

        await FireStoreUtils.getVendorCategoryById().then((value) {
          categoryLst.clear();
          categoryLst.addAll(value);

          for (int a = 0; a < value.length; a++) {
            if (value[a].id == vendorCategoryModel.id) {
              selectedCategory = value[a];
            }
          }
          if (selectedCategory != null) {
            for (VendorCategoryModel vendorCategoryModel in categoryLst) {
              if (vendorCategoryModel.id == selectedCategory!.id) {
                selectedCategory = vendorCategoryModel;
              }
            }
          }
        });

        if (deliveryChargeModel != null && deliveryChargeModel!.vendorCanModify && vendorData!.deliveryCharge != null) {
          deliverChargeKm.text = vendorData!.deliveryCharge!.deliveryChargesPerKm.toString();
          minDeliveryCharge.text = vendorData!.deliveryCharge!.minimumDeliveryCharges.toString();
          minDeliveryChargewkm.text = vendorData!.deliveryCharge!.minimumDeliveryChargesWithinKm.toString();
        }

        restaurantName.text = vendorData!.title;
        description.text = vendorData!.description;
        phonenumber.text = vendorData!.phonenumber;

        print("---->${vendorData!.filters}");
        vendorData!.filters.forEach((key, value) {
          if (value.contains("Yes")) {
            selected.add(key);
          }
        });

        isLoading = false;
        setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode(context) ? Color(COLOR_DARK) : null,
      body: SingleChildScrollView(
        child: Padding(
            padding: EdgeInsets.only(left: 20, right: 20, top: 20),
            child: Form(
                key: _formKey,
                autovalidateMode: _autoValidateMode,
                child: MyAppState.currentUser!.vendorID == ''
                    ? Column(
                        children: [
                          Container(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Restaurant Name".tr(),
                                style: TextStyle(fontSize: 17, fontFamily: "Poppinsl", color: isDarkMode(context) ? Colors.white : Color(0Xff696A75)),
                              )),
                          Container(
                            padding: const EdgeInsetsDirectional.only(start: 2, end: 20, bottom: 10),
                            child: TextFormField(
                                controller: restaurantName,
                                textAlignVertical: TextAlignVertical.center,
                                textInputAction: TextInputAction.next,
                                validator: validateEmptyField,
                                // onSaved: (text) => line1 = text,
                                style: TextStyle(fontSize: 18.0),
                                keyboardType: TextInputType.streetAddress,
                                cursorColor: Color(COLOR_PRIMARY),
                                // initialValue: MyAppState.currentUser!.shippingAddress.line1,
                                decoration: InputDecoration(
                                  // contentPadding: EdgeInsets.symmetric(horizontal: 24),
                                  hintText: 'Restaurant Name'.tr(),
                                  hintStyle: TextStyle(color: isDarkMode(context) ? Colors.white : Color(0Xff333333), fontSize: 17, fontFamily: "Poppinsm"),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Color(COLOR_PRIMARY)),
                                  ),

                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Color(0XFFCCD6E2)),
                                    // borderRadius: BorderRadius.circular(8.0),
                                  ),
                                )),
                          ),
                          Container(
                              padding: EdgeInsets.only(top: 10, bottom: 10),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Categories".tr(),
                                style: TextStyle(fontSize: 17, fontFamily: "Poppinsl", color: isDarkMode(context) ? Colors.white : Color(0Xff696A75)),
                              )),
                          Container(
                            height: 60,
                            child: DropdownButtonFormField<VendorCategoryModel>(
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey, width: 1),
                                    borderRadius: BorderRadius.circular(5),
                                  ),

                                  // filled: true,
                                  //fillColor: Colors.blueAccent,
                                ),
                                //dropdownColor: Colors.blueAccent,
                                value: selectedCategory,
                                onChanged: (value) {
                                  setState(() {
                                    selectedCategory = value;
                                  });
                                },
                                hint: Text('Select Product Category'.tr()),
                                items: categoryLst.map((VendorCategoryModel item) {
                                  return DropdownMenuItem<VendorCategoryModel>(
                                    child: Text(item.title.toString()),
                                    value: item,
                                  );
                                }).toList()),
                          ),
                          Container(
                              padding: EdgeInsets.only(top: 10),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Services".tr(),
                                style: TextStyle(fontSize: 17, fontFamily: "Poppinsl", color: isDarkMode(context) ? Colors.white : Color(0Xff696A75)),
                              )),
                          DropDownMultiSelect(
                            onChanged: (List<String> x) {
                              setState(() {
                                selected = x;
                              });
                            },
                            options: ['Good for Breakfast', 'Good for Lunch', 'Good for Dinner', 'Takes Reservations', 'Vegetarian Friendly', 'Live Music', 'Outdoor Seating', 'Free Wi-Fi'],
                            selectedValues: selected,
                            // childBuilder: selected.first,
                            whenEmpty: 'Select Something'.tr(),
                          ),
                          Container(
                              padding: EdgeInsets.only(top: 10),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Description".tr(),
                                style: TextStyle(fontSize: 17, fontFamily: "Poppinsl", color: isDarkMode(context) ? Colors.white : Color(0Xff696A75)),
                              )),
                          Container(
                            padding: const EdgeInsetsDirectional.only(end: 20, bottom: 10),
                            child: TextFormField(
                                controller: description,
                                textAlignVertical: TextAlignVertical.center,
                                textInputAction: TextInputAction.next,
                                validator: validateEmptyField,
                                // onSaved: (text) => line1 = text,
                                style: TextStyle(fontSize: 18.0),
                                keyboardType: TextInputType.streetAddress,
                                cursorColor: Color(COLOR_PRIMARY),
                                // initialValue: MyAppState.currentUser!.shippingAddress.line1,
                                decoration: InputDecoration(
                                  // contentPadding: EdgeInsets.symmetric(horizontal: 24),
                                  hintText: 'Description'.tr(),
                                  hintStyle: TextStyle(color: isDarkMode(context) ? Colors.white : Color(0Xff333333), fontSize: 17, fontFamily: "Poppinsm"),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Color(COLOR_PRIMARY)),
                                  ),

                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Color(0XFFB1BCCA)),
                                    // borderRadius: BorderRadius.circular(8.0),
                                  ),
                                )),
                          ),
                          Container(
                              padding: EdgeInsets.only(top: 5),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Phone Number".tr(),
                                style: TextStyle(fontSize: 17, fontFamily: "Poppinsl", color: isDarkMode(context) ? Colors.white : Color(0Xff696A75)),
                              )),
                          Container(
                            padding: const EdgeInsetsDirectional.only(end: 20, bottom: 10),
                            child: TextFormField(
                                controller: phonenumber,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.allow(RegExp(r'\d')),
                                ],
                                textAlignVertical: TextAlignVertical.center,
                                textInputAction: TextInputAction.next,
                                validator: validateEmptyField,
                                // onSaved: (text) => line1 = text,
                                style: TextStyle(fontSize: 18.0),
                                keyboardType: TextInputType.number,
                                cursorColor: Color(COLOR_PRIMARY),
                                // initialValue: MyAppState.currentUser!.shippingAddress.line1,
                                decoration: InputDecoration(
                                  // contentPadding: EdgeInsets.symmetric(horizontal: 24),
                                  hintText: 'Phone Number'.tr(),
                                  hintStyle: TextStyle(color: isDarkMode(context) ? Colors.white : Color(0Xff333333), fontSize: 17, fontFamily: "Poppinsm"),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Color(COLOR_PRIMARY)),
                                  ),

                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Color(0XFFB1BCCA)),
                                    // borderRadius: BorderRadius.circular(8.0),
                                  ),
                                )),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          SwitchListTile.adaptive(
                            dense: true,
                            activeColor: Color(COLOR_ACCENT),
                            title: Text(
                              'Delivery Settings'.tr(),
                              style: TextStyle(fontSize: 16, color: isDarkMode(context) ? Colors.white : Colors.black, fontFamily: "Poppinsm"),
                            ),
                            value: deliveryChargeModel != null ? deliveryChargeModel!.vendorCanModify : false,
                            onChanged: (value) {},
                          ),
                          Container(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Delivery Charge Per km".tr(),
                                style: TextStyle(fontSize: 15, fontFamily: "Poppinsl", color: isDarkMode(context) ? Colors.white : Color(0Xff696A75)),
                              )),
                          Container(
                            padding: const EdgeInsetsDirectional.only(end: 20, bottom: 10),
                            child: TextFormField(
                                controller: deliverChargeKm,
                                textAlignVertical: TextAlignVertical.center,
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  print("value os $value");
                                  if (value == null || value.isEmpty) {
                                    return "Invalid value".tr();
                                  }
                                  return null;
                                },
                                enabled: deliveryChargeModel != null ? deliveryChargeModel!.vendorCanModify : false,
                                onSaved: (text) => deliverChargeKm.text = text!,
                                style: TextStyle(fontSize: 18.0),
                                keyboardType: TextInputType.number,
                                cursorColor: Color(COLOR_PRIMARY),
                                // initialValue: vendor.phonenumber,
                                decoration: InputDecoration(
                                  // contentPadding: EdgeInsets.symmetric(horizontal: 24),
                                  hintText: 'Delivery Charge Per km'.tr(),
                                  hintStyle: TextStyle(color: isDarkMode(context) ? Colors.white : Color(0Xff333333), fontSize: 17, fontFamily: "Poppinsm"),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Color(COLOR_PRIMARY)),
                                  ),

                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Color(0XFFB1BCCA)),
                                    // borderRadius: BorderRadius.circular(8.0),
                                  ),
                                )),
                          ),
                          Container(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Min Delivery Charge".tr(),
                                style: TextStyle(fontSize: 15, fontFamily: "Poppinsl", color: isDarkMode(context) ? Colors.white : Color(0Xff696A75)),
                              )),
                          Container(
                            padding: const EdgeInsetsDirectional.only(end: 20, bottom: 10),
                            child: TextFormField(
                                enabled: deliveryChargeModel != null ? deliveryChargeModel!.vendorCanModify : false,
                                controller: minDeliveryCharge,
                                textAlignVertical: TextAlignVertical.center,
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Invalid value".tr();
                                  }
                                  return null;
                                },
                                onSaved: (text) => minDeliveryCharge.text = text!,
                                style: TextStyle(fontSize: 18.0),
                                keyboardType: TextInputType.number,
                                cursorColor: Color(COLOR_PRIMARY),
                                // initialValue: vendor.phonenumber,
                                decoration: InputDecoration(
                                  // contentPadding: EdgeInsets.symmetric(horizontal: 24),
                                  hintText: 'Min Delivery Charge'.tr(),
                                  hintStyle: TextStyle(color: isDarkMode(context) ? Colors.white : Color(0Xff333333), fontSize: 17, fontFamily: "Poppinsm"),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Color(COLOR_PRIMARY)),
                                  ),

                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Color(0XFFB1BCCA)),
                                    // borderRadius: BorderRadius.circular(8.0),
                                  ),
                                )),
                          ),
                          Container(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Min Delivery Charge within km".tr(),
                                style: TextStyle(fontSize: 15, fontFamily: "Poppinsl", color: isDarkMode(context) ? Colors.white : Color(0Xff696A75)),
                              )),
                          Container(
                            padding: const EdgeInsetsDirectional.only(end: 20, bottom: 10),
                            child: TextFormField(
                                controller: minDeliveryChargewkm,
                                enabled: deliveryChargeModel != null ? deliveryChargeModel!.vendorCanModify : false,
                                textAlignVertical: TextAlignVertical.center,
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Invalid value".tr();
                                  }
                                  return null;
                                },
                                onSaved: (text) => minDeliveryChargewkm.text = text!,
                                style: TextStyle(fontSize: 18.0),
                                keyboardType: TextInputType.number,
                                cursorColor: Color(COLOR_PRIMARY),
                                // initialValue: vendor.phonenumber,
                                decoration: InputDecoration(
                                  // contentPadding: EdgeInsets.symmetric(horizontal: 24),
                                  hintText: 'Min Delivery Charge within km'.tr(),
                                  hintStyle: TextStyle(color: isDarkMode(context) ? Colors.white : Color(0Xff333333), fontSize: 17, fontFamily: "Poppinsm"),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Color(COLOR_PRIMARY)),
                                  ),

                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Color(0XFFB1BCCA)),
                                    // borderRadius: BorderRadius.circular(8.0),
                                  ),
                                )),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          _mediaFiles.isEmpty == true
                              ? InkWell(
                                  onTap: () {
                                    _pickImage();
                                  },
                                  child: Image(
                                    image: AssetImage("assets/images/add_img.png"),
                                    width: MediaQuery.of(context).size.width * 1,
                                    height: MediaQuery.of(context).size.height * 0.2,
                                  ))
                              : _imageBuilder(_mediaFiles.first)
                        ],
                      )
                    : isLoading == true
                        ? Container(
                            alignment: Alignment.center,
                            child: CircularProgressIndicator.adaptive(
                              valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                            ),
                          )
                        : buildrow())),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.only(top: 12, bottom: 12), backgroundColor: Color(COLOR_PRIMARY),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  side: BorderSide(
                    color: Color(COLOR_PRIMARY),
                  ),
                ),
              ),
              onPressed: () {
                validate();
              },
              child: Text(
                'CONTINUE'.tr(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode(context) ? Colors.black : Colors.white,
                ),
              ),
            ),
            Visibility(
              visible: MyAppState.currentUser!.vendorID != '',
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.only(top: 12, bottom: 12), backgroundColor: Color(COLOR_PRIMARY),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(
                        color: Color(COLOR_PRIMARY),
                      ),
                    ),
                  ),
                  onPressed: () async {
                    final image = ImageVar.Image(600, 600);
                    ImageVar.fill(image, ImageVar.getColor(255, 255, 255));
                    drawBarcode(image, Barcode.qrCode(), '{"vendorid":"${MyAppState.currentUser!.vendorID}","vendorname":"${vendorData!.title}"}', font: ImageVar.arial_24);
                    // Save the image
                    Directory appDocDir = await getApplicationDocumentsDirectory();
                    String appDocPath = appDocDir.path;
                    print("path $appDocPath");
                    File file = File('$appDocPath/barcode${MyAppState.currentUser!.vendorID}.png');
                    if (!await file.exists()) {
                      await file.create();
                    } else {
                      await file.delete();
                      await file.create();
                    }
                    file.writeAsBytesSync(ImageVar.encodePng(image));
                    push(context, QrCodeGenerator(vendorModel: vendorData!));
                  },
                  child: Text(
                    'Generate QR Code'.tr(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode(context) ? Colors.black : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  buildrow() {
    return Column(children: [
      Container(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            "Restaurant Name".tr(),
            style: TextStyle(fontSize: 17, fontFamily: "Poppinsl", color: isDarkMode(context) ? Colors.white : Color(0Xff696A75)),
          )),

      Container(
        padding: const EdgeInsetsDirectional.only(start: 2, end: 20, bottom: 10),
        child: TextFormField(
            controller: restaurantName,
            textAlignVertical: TextAlignVertical.center,
            textInputAction: TextInputAction.next,
            validator: validateEmptyField,
            // initialValue: vendor.title,
            onSaved: (text) => restaurantName.text = text!,
            style: TextStyle(fontSize: 18.0),
            keyboardType: TextInputType.streetAddress,
            cursorColor: Color(COLOR_PRIMARY),
            // initialValue: MyAppState.currentUser!.shippingAddress.line1,
            decoration: InputDecoration(
              // contentPadding: EdgeInsets.symmetric(horizontal: 24),
              hintText: 'Restaurant Name'.tr(),
              hintStyle: TextStyle(color: isDarkMode(context) ? Colors.white : Color(0Xff696A75), fontSize: 17, fontFamily: "Poppinsm"),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(COLOR_PRIMARY)),
              ),

              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0XFFCCD6E2)),
                // borderRadius: BorderRadius.circular(8.0),
              ),
            )),
      ),
      Container(
          padding: EdgeInsets.only(top: 10, bottom: 10),
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            "Categories".tr(),
            style: TextStyle(fontSize: 17, fontFamily: "Poppinsl", color: isDarkMode(context) ? Colors.white : Color(0Xff696A75)),
          )),

      Container(
        height: 60,
        child: DropdownButtonFormField<VendorCategoryModel>(
            decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(10, 2, 10, 2),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 1),
                borderRadius: BorderRadius.circular(5),
              ),

              // filled: true,
              //fillColor: Colors.blueAccent,
            ),
            //dropdownColor: Colors.blueAccent,
            value: selectedCategory,
            onChanged: (value) {
              setState(() {
                selectedCategory = value;
              });
            },
            hint: Text('Select Product Category'.tr()),
            items: categoryLst.map((VendorCategoryModel item) {
              return DropdownMenuItem<VendorCategoryModel>(
                child: Text(item.title.toString()),
                value: item,
              );
            }).toList()),
      ),

      // DropdownButtonHideUnderline(
      //     child: DropdownButtonFormField(
      //   //  validator: (value) => value == null ? 'field required' : null,
      //   icon: Icon(Icons.keyboard_arrow_down),

      //   hint: _dropdownval == null
      //       ? Text('Select Product Category',
      //           style: TextStyle(
      //               color: Color(0Xff333333),
      //               fontSize: 17,
      //               fontFamily: "Poppinsm"))
      //       : Text(_dropdownval.toString(),
      //           style: TextStyle(
      //               color:
      //                   isDarkMode(context) ? Colors.white : Color(0Xff333333),
      //               fontSize: 17,
      //               fontFamily: "Poppinsm")),
      //   items: <String>[
      //     'Burgers',
      //     'Sushi',
      //     'Ramen',
      //     'Bar Food',
      //     'Breakfast',
      //     'Italian',
      //     'Japanese',
      //     'New Mexican',
      //     'Sandwiches',
      //     'Mediterranean'
      //   ].map((String value) {
      //     return DropdownMenuItem<String>(
      //       value: value,
      //       child: Text(value),
      //     );
      //   }).toList(),
      //   isExpanded: true,

      //   iconSize: 30.0,
      //   onChanged: (value) {
      //     // vendor.categoryTitle?

      //     // setState(() {
      //     value != null ? _dropdownval = value : null;

      //     catselect();
      //     // });
      //   },
      // )),

      Container(
          padding: EdgeInsets.only(top: 10),
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            "Services".tr(),
            style: TextStyle(fontSize: 17, fontFamily: "Poppinsl", color: isDarkMode(context) ? Colors.white : Color(0Xff696A75)),
          )),

      DropDownMultiSelect(
        onChanged: (List<String> x) {
          x = selected;

          //  vendor.filters.keys.toList()= x;
        },
        options: ['Good for Breakfast', 'Good for Lunch', 'Good for Dinner', 'Takes Reservations', 'Vegetarian Friendly', 'Live Music', 'Outdoor Seating', 'Free Wi-Fi'],
        selectedValues: selected,

        // childBuilder: selected.first,
        whenEmpty: 'Select Something'.tr(),
      ),

      Container(
          padding: EdgeInsets.only(top: 10),
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            "Description".tr(),
            style: TextStyle(fontSize: 17, fontFamily: "Poppinsl", color: isDarkMode(context) ? Colors.white : Color(0Xff696A75)),
          )),

      Container(
        padding: const EdgeInsetsDirectional.only(end: 20, bottom: 10),
        child: TextFormField(
            controller: description,
            textAlignVertical: TextAlignVertical.center,
            textInputAction: TextInputAction.next,
            validator: validateEmptyField,
            onSaved: (text) => description.text = text!,
            style: TextStyle(fontSize: 18.0),
            keyboardType: TextInputType.streetAddress,
            cursorColor: Color(COLOR_PRIMARY),
            // initialValue: vendor.description,
            decoration: InputDecoration(
              // contentPadding: EdgeInsets.symmetric(horizontal: 24),
              hintText: 'Description'.tr(),
              hintStyle: TextStyle(color: isDarkMode(context) ? Colors.white : Color(0Xff333333), fontSize: 17, fontFamily: "Poppinsm"),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(COLOR_PRIMARY)),
              ),

              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0XFFB1BCCA)),
                // borderRadius: BorderRadius.circular(8.0),
              ),
            )),
      ),
      Container(
          padding: EdgeInsets.only(top: 10),
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            "Phone Number".tr(),
            style: TextStyle(fontSize: 17, fontFamily: "Poppinsl", color: isDarkMode(context) ? Colors.white : Color(0Xff696A75)),
          )),

      Container(
        padding: const EdgeInsetsDirectional.only(end: 20, bottom: 10),
        child: TextFormField(
            controller: phonenumber,
            textAlignVertical: TextAlignVertical.center,
            textInputAction: TextInputAction.next,
            validator: validateMobile,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'\d')),
            ],
            onSaved: (text) => phonenumber.text = text!,
            style: TextStyle(fontSize: 18.0),
            keyboardType: TextInputType.streetAddress,
            cursorColor: Color(COLOR_PRIMARY),
            // initialValue: vendor.phonenumber,
            decoration: InputDecoration(
              // contentPadding: EdgeInsets.symmetric(horizontal: 24),
              hintText: 'Phone Number'.tr(),
              hintStyle: TextStyle(color: isDarkMode(context) ? Colors.white : Color(0Xff333333), fontSize: 17, fontFamily: "Poppinsm"),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(COLOR_PRIMARY)),
              ),

              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0XFFB1BCCA)),
                // borderRadius: BorderRadius.circular(8.0),
              ),
            )),
      ),
      SizedBox(
        height: 10,
      ),
      SwitchListTile.adaptive(
        contentPadding: EdgeInsets.all(0),
        activeColor: Color(COLOR_ACCENT),
        title: Text(
          'Delivery Settings'.tr(),
          style: TextStyle(fontSize: 17, color: isDarkMode(context) ? Colors.white : Color(0Xff696A75), fontFamily: "Poppinsl"),
        ),
        value: deliveryChargeModel!.vendorCanModify,
        onChanged: null,
      ),
      Container(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            "Delivery Charge Per km".tr(),
            style: TextStyle(fontSize: 15, fontFamily: "Poppinsl", color: isDarkMode(context) ? Colors.white : Color(0Xff696A75)),
          )),
      Container(
        padding: const EdgeInsetsDirectional.only(end: 20, bottom: 10),
        child: TextFormField(
            controller: deliverChargeKm,
            textAlignVertical: TextAlignVertical.center,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Invalid value".tr();
              }
              return null;
            },
            enabled: deliveryChargeModel!.vendorCanModify,
            onSaved: (text) => deliverChargeKm.text = text!,
            style: TextStyle(fontSize: 18.0),
            keyboardType: TextInputType.number,
            cursorColor: Color(COLOR_PRIMARY),
            // initialValue: vendor.phonenumber,
            decoration: InputDecoration(
              // contentPadding: EdgeInsets.symmetric(horizontal: 24),
              hintText: 'Delivery Charge Per km'.tr(),
              hintStyle: TextStyle(color: isDarkMode(context) ? Colors.white : Color(0Xff333333), fontSize: 17, fontFamily: "Poppinsm"),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(COLOR_PRIMARY)),
              ),

              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0XFFB1BCCA)),
                // borderRadius: BorderRadius.circular(8.0),
              ),
            )),
      ),
      Container(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            "Min Delivery Charge".tr(),
            style: TextStyle(fontSize: 15, fontFamily: "Poppinsl", color: isDarkMode(context) ? Colors.white : Color(0Xff696A75)),
          )),
      Container(
        padding: const EdgeInsetsDirectional.only(end: 20, bottom: 10),
        child: TextFormField(
            enabled: deliveryChargeModel!.vendorCanModify,
            controller: minDeliveryCharge,
            textAlignVertical: TextAlignVertical.center,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Invalid value".tr();
              }
              return null;
            },
            onSaved: (text) => minDeliveryCharge.text = text!,
            style: TextStyle(fontSize: 18.0),
            keyboardType: TextInputType.number,
            cursorColor: Color(COLOR_PRIMARY),
            // initialValue: vendor.phonenumber,
            decoration: InputDecoration(
              // contentPadding: EdgeInsets.symmetric(horizontal: 24),
              hintText: 'Min Delivery Charge'.tr(),
              hintStyle: TextStyle(color: isDarkMode(context) ? Colors.white : Color(0Xff333333), fontSize: 17, fontFamily: "Poppinsm"),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(COLOR_PRIMARY)),
              ),

              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0XFFB1BCCA)),
                // borderRadius: BorderRadius.circular(8.0),
              ),
            )),
      ),
      Container(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            "Min Delivery Charge within km".tr(),
            style: TextStyle(fontSize: 15, fontFamily: "Poppinsl", color: isDarkMode(context) ? Colors.white : Color(0Xff696A75)),
          )),
      Container(
        padding: const EdgeInsetsDirectional.only(end: 20, bottom: 10),
        child: TextFormField(
            controller: minDeliveryChargewkm,
            enabled: deliveryChargeModel!.vendorCanModify,
            textAlignVertical: TextAlignVertical.center,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Invalid value".tr();
              }
              return null;
            },
            onSaved: (text) => minDeliveryChargewkm.text = text!,
            style: TextStyle(fontSize: 18.0),
            keyboardType: TextInputType.number,
            cursorColor: Color(COLOR_PRIMARY),
            // initialValue: vendor.phonenumber,
            decoration: InputDecoration(
              // contentPadding: EdgeInsets.symmetric(horizontal: 24),
              hintText: 'Min Delivery Charge within km'.tr(),
              hintStyle: TextStyle(color: isDarkMode(context) ? Colors.white : Color(0Xff333333), fontSize: 17, fontFamily: "Poppinsm"),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(COLOR_PRIMARY)),
              ),

              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0XFFB1BCCA)),
                // borderRadius: BorderRadius.circular(8.0),
              ),
            )),
      ),
      SizedBox(
        height: 10,
      ),
      // _mediaFiles.isEmpty == true ?
      // InkWell(onTap: (){
      //   _pickImage();
      // },
      //   child:
      //   Image(image: AssetImage("assets/images/add_img.png"),
      //   width:MediaQuery.of(context).size.width*1,
      //   height: MediaQuery.of(context).size.height*0.2 ,))
      //   :
      _mediaFiles.isEmpty == true
          ? InkWell(
              onTap: () {
                changeimg();
              },
              child: Image(
                image: NetworkImage(vendorData!.photo),
                width: 150,
              ))
          : _imageBuilder(_mediaFiles.first)
    ]);
  }

  changeimg() {
    final action = CupertinoActionSheet(
      message: Text(
        'Change Picture'.tr(),
        style: TextStyle(fontSize: 15.0),
      ),
      actions: [
        CupertinoActionSheetAction(
          child: Text('Choose image from gallery'.tr()),
          isDefaultAction: false,
          onPressed: () async {
            Navigator.pop(context);
            XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
            if (image != null) {
              // _mediaFiles.removeLast();
              setState(() {
                _mediaFiles.add(File(image.path));
              });

              // _mediaFiles.add(null);

            }
          },
        ),
        CupertinoActionSheetAction(
          child: Text('Take a picture'.tr()),
          isDestructiveAction: false,
          onPressed: () async {
            Navigator.pop(context);
            XFile? image = await _imagePicker.pickImage(source: ImageSource.camera);
            if (image != null) {
              // _mediaFiles.removeLast();
              _mediaFiles.add(File(image.path));
              // _mediaFiles.add(null);

            }
          },
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text('Cancel'.tr()),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
    showCupertinoModalPopup(context: context, builder: (context) => action);
  }

  showAlertDialog(BuildContext context) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("OK".tr()),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Restaurant Field".tr()),
      content: Text("Please Select Image to Continue.".tr()),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  validate() async {
    if (MyAppState.currentUser!.vendorID != '') {
      if (_formKey.currentState?.validate() ?? false) {
        filter();
        if (_mediaFiles.isNotEmpty) {
          await showProgress(context, 'Updating Photo...'.tr(), false);

          var uniqueID = Uuid().v4();
          Reference upload = FirebaseStorage.instance.ref().child('flutter/uberEats/productImages/$uniqueID'
              '.png');
          UploadTask uploadTask = upload.putFile(_mediaFiles.first);
          uploadTask.whenComplete(() {}).catchError((onError) {
            print((onError as PlatformException).message);
          });
          var storageRef = (await uploadTask.whenComplete(() {})).ref;
          String downloadUrl = await storageRef.getDownloadURL();
          downloadUrl.toString();
          await hideProgress();
          DeliveryChargeModel deliveryChargeModel = DeliveryChargeModel(
              vendorCanModify: true,
              deliveryChargesPerKm: num.parse(deliverChargeKm.text),
              minimumDeliveryCharges: num.parse(minDeliveryCharge.text),
              minimumDeliveryChargesWithinKm: num.parse(minDeliveryChargewkm.text));
          push(
            context,
            RestaurantLocationScreen(
                restname: restaurantName.text,
                catid: selectedCategory!.id,
                filter: filters,
                cat: selectedCategory!.title,
                desc: description.text,
                phonenumber: phonenumber.text,
                pic: downloadUrl,
                vendor: vendorData,
                deliveryChargeModel: deliveryChargeModel),
          );
        } else {
          DeliveryChargeModel deliveryChargeModel = DeliveryChargeModel(
              vendorCanModify: true,
              deliveryChargesPerKm: num.parse(deliverChargeKm.text),
              minimumDeliveryCharges: num.parse(minDeliveryCharge.text),
              minimumDeliveryChargesWithinKm: num.parse(minDeliveryChargewkm.text));
          push(
            context,
            RestaurantLocationScreen(
                restname: restaurantName.text,
                catid: selectedCategory!.id,
                filter: filters,
                cat: selectedCategory!.title,
                desc: description.text,
                phonenumber: phonenumber.text,
                pic: vendorData!.photo,
                vendor: vendorData,
                deliveryChargeModel: deliveryChargeModel),
          );
        }
      }
    } else if (_formKey.currentState?.validate() ?? false) {
      if (_mediaFiles.isEmpty) {
        showimgAlertDialog(context, 'Please add Image'.tr(), 'Add Image to continue'.tr(), true);
      } else if (phonenumber.text.isEmpty) {
        showimgAlertDialog(context, 'Please enter valid number'.tr(), 'Add phone no. to continue'.tr(), true);
      } else {
        filter();
        _formKey.currentState!.save();
        DeliveryChargeModel deliveryChargeModel = DeliveryChargeModel(
            vendorCanModify: true,
            deliveryChargesPerKm: num.parse(deliverChargeKm.text),
            minimumDeliveryCharges: num.parse(minDeliveryCharge.text),
            minimumDeliveryChargesWithinKm: num.parse(minDeliveryChargewkm.text));
        print("---->$filters");

        push(
          context,
          RestaurantLocationScreen(
            restname: restaurantName.text,
            catid: selectedCategory!.id,
            filter: filters,
            cat: selectedCategory!.title.toString(),
            desc: description.text,
            phonenumber: phonenumber.text,
            pic: _mediaFiles.first,
            vendor: vendorData,
            deliveryChargeModel: deliveryChargeModel,
          ),
        );
      }
    } else {
      setState(() {
        _autoValidateMode = AutovalidateMode.onUserInteraction;
      });
    }
  }

  _pickImage() {
    final action = CupertinoActionSheet(
      message: Text(
        'Add Picture'.tr(),
        style: TextStyle(fontSize: 15.0),
      ),
      actions: <Widget>[
        CupertinoActionSheetAction(
          child: Text('Choose image from gallery'.tr()),
          isDefaultAction: false,
          onPressed: () async {
            Navigator.pop(context);
            XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
            if (image != null) {
              // _mediaFiles.removeLast();
              _mediaFiles.add(File(image.path));
              // _mediaFiles.add(null);
              setState(() {});
            }
          },
        ),
        CupertinoActionSheetAction(
          child: Text('Take a picture'.tr()),
          isDestructiveAction: false,
          onPressed: () async {
            Navigator.pop(context);
            XFile? image = await _imagePicker.pickImage(source: ImageSource.camera);
            if (image != null) {
              // _mediaFiles.removeLast();
              _mediaFiles.add(File(image.path));
              // _mediaFiles.add(null);
              setState(() {});
            }
          },
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text('Cancel'.tr()),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
    showCupertinoModalPopup(context: context, builder: (context) => action);
  }

  _imageBuilder(dynamic image) {
    // bool isLastItem = image == null;
    return GestureDetector(
      onTap: () {
        _viewOrDeleteImage(image);
      },
      child: Container(
        width: 100,
        child: Card(
          shape: RoundedRectangleBorder(
            side: BorderSide.none,
            borderRadius: BorderRadius.circular(12),
          ),
          color: isDarkMode(context) ? Colors.black : Colors.white,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: image is File
                ? Image.file(
                    image,
                    fit: BoxFit.cover,
                  )
                : displayImage(image),
          ),
        ),
      ),
    );
  }

  _viewOrDeleteImage(dynamic image) {
    final action = CupertinoActionSheet(
      actions: <Widget>[
        CupertinoActionSheetAction(
          onPressed: () async {
            Navigator.pop(context);
            // _mediaFiles.removeLast();
            if (image is File) {
              _mediaFiles.removeWhere((value) => value is File && value.path == image.path);
            } else {
              _mediaFiles.removeWhere((value) => value is String && value == image);
            }
            // _mediaFiles.add(null);
            setState(() {});
          },
          child: Text('Remove picture'.tr()),
          isDestructiveAction: true,
        ),
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
            push(context, image is File ? FullScreenImageViewer(imageFile: image) : FullScreenImageViewer(imageUrl: image));
          },
          isDefaultAction: true,
          child: Text('View picture'.tr()),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text('Cancel'.tr()),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
    showCupertinoModalPopup(context: context, builder: (context) => action);
  }

  bool isPhoneNoValid(String? phoneNo) {
    if (phoneNo == null) return false;
    final regExp = RegExp(r'(^(?:[+0]9)?\d{10,12}$)');
    return regExp.hasMatch(phoneNo);
  }

  showimgAlertDialog(BuildContext context, String title, String content, bool addOkButton) {
    Widget? okButton;
    if (addOkButton) {
      okButton = TextButton(
        child: Text('OK'.tr()),
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

  showAlertDialog1(BuildContext context) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("OK".tr()),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("My title".tr()),
      content: Text("This is my message.".tr()),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
