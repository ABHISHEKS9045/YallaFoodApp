// ignore_for_file: non_constant_identifier_names

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:foodie_customer/model/CurrencyModel.dart';
import 'package:foodie_customer/model/VendorModel.dart';
import 'package:geolocator/geolocator.dart';

import 'model/TaxModel.dart';

const FINISHED_ON_BOARDING = 'finishedOnBoarding';
const COLOR_ACCENT = 0xFF8fd468;
const COLOR_PRIMARY_DARK = 0xFF683A;
var COLOR_PRIMARY = 0xffA4DC04;
const FACEBOOK_BUTTON_COLOR = 0xFF415893;
const DARK_COLOR = 0xff191A1C;
const DARK_VIEWBG_COLOR = 0xff191A1C;
const DARK_CARD_BG_COLOR = 0xff242528;
const DARK_BG_COLOR = 0xff121212;
const COUPON_BG_COLOR = 0xFFFCF8F3;
const COUPON_DASH_COLOR = 0xFFCACFDA;
const GREY_TEXT_COLOR = 0xff5E5C5C;
const DARK_GREY_TEXT_COLOR = 0xff9F9F9F;
const DarkContainerColor = 0xff26272C;
const DarkContainerBorderColor = 0xff515151;

double radiusValue = 1000.0;

const STORY = 'story';
const MENU_ITEM = 'menu_items';
const USERS = 'users';
const REPORTS = 'reports';
const Deliverycharge = 6;
const VENDOR_ATTRIBUTES = "vendor_attributes";
const REVIEW_ATTRIBUTES = "review_attributes";
const FavouriteItem = "favorite_item";
const VENDORS = 'vendors';
const PRODUCTS = 'vendor_products';
const ORDERS = 'restaurant_orders';
const ORDERS_TABLE = 'booked_table';
const SECOND_MILLIS = 1000;
const MINUTE_MILLIS = 60 * SECOND_MILLIS;
const HOUR_MILLIS = 60 * MINUTE_MILLIS;

const ORDER_STATUS_PLACED = 'Order Placed';
const ORDER_STATUS_ACCEPTED = 'Order Accepted';
const ORDER_STATUS_REJECTED = 'Order Rejected';
const ORDER_STATUS_DRIVER_PENDING = 'Driver Pending';
const ORDER_STATUS_DRIVER_REJECTED = 'Driver Rejected';
const ORDER_STATUS_SHIPPED = 'Order Shipped';
const ORDER_STATUS_IN_TRANSIT = 'In Transit';
const ORDER_STATUS_COMPLETED = 'Order Completed';
const ORDERREQUEST = 'Order';
const BOOKREQUEST = 'TableBook';

const PAYMENT_SERVER_URL = 'https://murmuring-caverns-94283.herokuapp.com/';

const USER_ROLE_DRIVER = 'driver';
const USER_ROLE_CUSTOMER = 'customer';
const USER_ROLE_VENDOR = 'vendor';
const VENDORS_CATEGORIES = 'vendor_categories';
const Order_Rating = 'foods_review';
const CONTACT_US = 'ContactUs';
const COUPON = 'coupons';
const Wallet = "wallet";

const Setting = 'settings';
const StripeSetting = 'stripeSettings';
const FavouriteRestaurant = "favorite_restaurant";

const COD = 'CODSettings';

const GlobalURL = "https://yallafood.co.il/";


const Currency = 'currencies';
String symbol = '\$';
bool isRight = false;
bool isDineInEnable = false;
int decimal = 2;
String currName = "";
CurrencyModel? currencyData;
List<VendorModel> allstoreList = [];
String appVersion = '';

bool isRazorPayEnabled = false;
bool isRazorPaySandboxEnabled = false;
String razorpayKey = "";
String razorpaySecret = "";
String? lang ;
const gApi = 'AIzaSyCzsSTpM6RkMUMlyfxZK3Od30cKoGtIDdk';

// new key
const SERVER_KEY = 'AAAAAIf8ixg:APA91bFuZXfrNtiSQdUuX7dVS7YbXSbAWLN1ZNW__UWvLfH_KPsnzIMknHGcq6Y5Vgi3_1BWXGRGi2EPZo6kpabvqLRntJRdMvY9OuxH2I6C3TAfTJn3fmEOMSZVetntPbA8UVZeyd7C';
const GOOGLE_API_KEY = "AIzaSyBK_LlbuVttvGR3GXIe1oF6qeci2ckGNNA";
// old key
// const SERVER_KEY = 'AAAA3jnI8PI:APA91bG3opTCpB8ySIczJsBKV1MhN2EC576QLpx8pYIuPsPm2iDyt9XAa-bmLJLi7nnRnvObsNmkWuLxlP4D5JnSBMdpsaD3t2xVPfRFqV_Rku7hOGkCaNsR0vVkq6_dqWEvzTjvGBSX';
// const GOOGLE_API_KEY = "AIzaSyA8lruUAVvN65M2YGTw7_3PyIV0yPfloEg";


const String invoice4uBaseUrl = "https://api.invoice4u.co.il/Services/ApiService.svc/";

const String processApiRequestV2 = "ProcessApiRequestV2";
const String verifyLogin = "VerifyLogin";
const String getClearingLogById = "GetClearingLogById";





const String Invoice4UUserApiKey =  "18939a2d-b9ad-473a-999d-58f85654197b";

String placeholderImage = 'https://Yalla.co.za/img/web_logo.png';

double getDoubleVal(dynamic input) {
  if (input == null) {
    return 0.1;
  }

  if (input is int) {
    return double.parse(input.toString());
  }

  if (input is double) {
    return input;
  }
  return 0.1;
}

double getTaxValue(TaxModel? taxModel, double amount) {
  double taxVal = 0;
  if (taxModel != null && taxModel.tax != null && taxModel.tax! > 0) {
    if (taxModel.type == "fix") {
      taxVal = taxModel.tax!.toDouble();
    } else {
      taxVal = (amount * taxModel.tax!.toDouble()) / 100;
    }
  }
  return double.parse(taxVal.toStringAsFixed(2));
}

Uri createCoordinatesUrl(double latitude, double longitude, [String? label]) {
  var uri;
  if (kIsWeb) {
    uri = Uri.https('www.google.com', '/maps/search/', {'api': '1', 'query': '$latitude,$longitude'});
  } else if (Platform.isAndroid) {
    var query = '$latitude,$longitude';
    if (label != null) query += '($label)';
    uri = Uri(scheme: 'geo', host: '0,0', queryParameters: {'q': query});
  } else if (Platform.isIOS) {
    var params = {'ll': '$latitude,$longitude'};
    if (label != null) params['q'] = label;
    uri = Uri.https('maps.apple.com', '/', params);
  } else {
    uri = Uri.https('www.google.com', '/maps/search/', {'api': '1', 'query': '$latitude,$longitude'});
  }

  return uri;
}

String getKm(Position pos1, Position pos2) {
  double distanceInMeters = Geolocator.distanceBetween(pos1.latitude, pos1.longitude, pos2.latitude, pos2.longitude);
  double kilometer = distanceInMeters / 1000;
 //debugPrint("KiloMeter$kilometer");
  return kilometer.toStringAsFixed(2).toString();
}

String getImageVAlidUrl(String url) {
  String imageUrl = placeholderImage;
  if (url.isNotEmpty) {
    imageUrl = url;
  }
  return imageUrl;
}





