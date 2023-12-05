import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodie_driver/model/AddressModel.dart';
import 'package:foodie_driver/model/ProductModel.dart';
import 'package:foodie_driver/model/TaxModel.dart';
import 'package:foodie_driver/model/User.dart';
import 'package:foodie_driver/model/VendorModel.dart';

class OrderModel {
  String authorID, paymentMethod;

  User author;
  User? driver;
  String? driverID;
  List<ProductModel> products;

  Timestamp createdAt;

  String vendorID;

  VendorModel vendor;

  String status;
  AddressModel address;
  String orderType;

  String id;
  num? discount;
  String? couponCode;
  String? couponId, notes;
  var extras = [];
  String? extraSize;
  String? tipValue;
  String? adminCommission;
  String? adminCommissionType;
  final bool? takeAway;

  String? deliveryCharge;
  TaxModel? taxModel;
  bool paymentShared = true;
  List<dynamic> rejectedByDrivers;
  Timestamp? triggerDelevery;

  OrderModel(
      {address,
      author,
      this.driver,
      this.driverID,
      this.authorID = '',
      this.paymentMethod = '',
      createdAt,
      this.id = '',
      this.triggerDelevery,
      this.products = const [],
      this.status = '',
      this.discount = 0,
      this.couponCode = '',
      this.couponId = '',
      this.paymentShared = true,
      this.orderType = "",
      this.notes = '',
      vendor,
      this.extras = const [],
      this.extraSize,
      this.tipValue,
      this.adminCommission,
      this.takeAway = false,
      this.adminCommissionType,
      this.deliveryCharge,
      this.vendorID = '',
      taxModel,
      this.rejectedByDrivers = const []})
      : this.address = address ?? AddressModel(),
        this.author = author ?? User(),
        this.createdAt = createdAt ?? Timestamp.now(),
        this.vendor = vendor ?? VendorModel(),
        this.taxModel = taxModel ?? null;

  factory OrderModel.fromJson(Map<String, dynamic> parsedJson) {
    List<ProductModel> products = parsedJson.containsKey('products') ? List<ProductModel>.from((parsedJson['products'] as List<dynamic>).map((e) => ProductModel.fromJson(e))).toList() : [].cast<ProductModel>();

    num discountVal = 0;
    if (parsedJson['discount'] == null || parsedJson['discount'] == double.nan) {
      discountVal = 0;
    } else if (parsedJson['discount'] is String) {
      discountVal = double.parse(parsedJson['discount']);
    } else {
      discountVal = parsedJson['discount'];
    }
    return OrderModel(
        orderType: parsedJson['order_type'] ?? "",
        address: parsedJson.containsKey('address') ? AddressModel.fromJson(parsedJson['address']) : AddressModel(),
        author: parsedJson.containsKey('author') ? User.fromJson(parsedJson['author']) : User(),
        authorID: parsedJson['authorID'] ?? '',
        createdAt: parsedJson['createdAt'] ?? Timestamp.now(),
        id: parsedJson['id'] ?? '',
        products: products,
        status: parsedJson['status'] ?? '',
        paymentShared: parsedJson['payment_shared'] ?? true,
        discount: discountVal,
        couponCode: parsedJson['couponCode'] ?? '',
        couponId: parsedJson['couponId'] ?? '',
        notes: (parsedJson["notes"] != null && parsedJson["notes"].toString().isNotEmpty) ? parsedJson["notes"] : "",
        vendor: parsedJson.containsKey('vendor') ? VendorModel.fromJson(parsedJson['vendor']) : VendorModel(),
        vendorID: parsedJson['vendorID'] ?? '',
        driver: parsedJson.containsKey('driver') ? User.fromJson(parsedJson['driver']) : null,
        driverID: parsedJson.containsKey('driverID') ? parsedJson['driverID'] : null,
        triggerDelevery: parsedJson['trigger_delevery'] ?? Timestamp.now(),
        adminCommission: parsedJson["adminCommission"] != null ? parsedJson["adminCommission"] : "",
        adminCommissionType: parsedJson["adminCommissionType"] != null ? parsedJson["adminCommissionType"] : "",
        tipValue: parsedJson["tip_amount"] != null ? parsedJson["tip_amount"] : "",
        takeAway: parsedJson["takeAway"] != null ? parsedJson["takeAway"] : false,
        taxModel: (parsedJson.containsKey('taxSetting') && parsedJson['taxSetting'] != null) ? TaxModel.fromJson(parsedJson['taxSetting']) : null,
        extras: parsedJson["extras"] != null ? parsedJson["extras"] : [],
        extraSize: parsedJson["extras_price"] != null ? parsedJson["extras_price"] : "",
        deliveryCharge: parsedJson["deliveryCharge"],
        paymentMethod: parsedJson['payment_method'] ?? '',
        rejectedByDrivers: parsedJson.containsKey('rejectedByDrivers') ? parsedJson['rejectedByDrivers'] : [].cast<String>());
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'address': this.address.toJson(),
      'order_type': orderType,
      'author': this.author.toJson(),
      'authorID': this.authorID,
      'payment_method': this.paymentMethod,
      'payment_shared': this.paymentShared,
      'createdAt': this.createdAt,
      'id': this.id,
      'products': this.products.map((e) => e.toJson()).toList(),
      'status': this.status,
      'discount': this.discount,
      'couponCode': this.couponCode,
      'couponId': this.couponId,
      'notes': this.notes,
      'vendor': this.vendor.toJson(),
      'vendorID': this.vendorID,
      'adminCommission': this.adminCommission,
      'adminCommissionType': this.adminCommissionType,
      "tip_amount": this.tipValue,
      if (taxModel != null) "taxSetting": this.taxModel!.toJson(),
      "extras": this.extras,
      "extras_price": this.extraSize,
      "takeAway": this.takeAway,
      "deliveryCharge": this.deliveryCharge,
      "rejectedByDrivers": this.rejectedByDrivers,
      'trigger_delevery': this.triggerDelevery,
    };
    if (this.driver != null) {
      json.addAll({'driverID': this.driverID, 'driver': this.driver!.toJson()});
    }
    return json;
  }
}
