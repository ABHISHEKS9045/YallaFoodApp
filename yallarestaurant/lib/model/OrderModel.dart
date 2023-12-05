import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodie_restaurant/model/AddressModel.dart';
import 'package:foodie_restaurant/model/OrderProductModel.dart';
import 'package:foodie_restaurant/model/TaxModel.dart';
import 'package:foodie_restaurant/model/User.dart';
import 'package:foodie_restaurant/model/VendorModel.dart';

class OrderModel {
  String authorID;

  User? author;

  User? driver;

  String? driverID;

  List<OrderProductModel> orderProduct;
  Timestamp createdAt;

  String vendorID;

  VendorModel vendor;

  String status;

  AddressModel address;
  bool paymentShared = true;
  String orderType;

  String id;

  List<dynamic> rejectedByDrivers;

  String deliveryAddress() => '${this.address.line1} ${this.address.line2} ${this.address.city} '
      '${this.address.postalCode}';
  final bool? takeAway;

  dynamic discount;
  String? couponCode;
  String? couponId;

  // var extras = [];
  //String? extra_size;
  TaxModel? taxModel;
  String? tipValue;
  String? notes;
  String? adminCommission;
  String? adminCommissionType;
  String? deliveryCharge;
  String? paymentMethod;
  String? tax;

  OrderModel({
    address,
    this.author,
    this.driver,
    this.driverID,
    this.authorID = '',
    this.paymentMethod = "",
    this.orderType = "",
    createdAt,
    this.id = '',
    this.orderProduct = const [],
    this.status = '',
    vendor,
    this.discount = 0,
    this.couponCode = '',
    this.paymentShared = true,
    this.couponId = '',
    this.notes,
    this.tipValue,
    taxModel,
    this.adminCommission,
    this.adminCommissionType,
    this.vendorID = '',
    this.deliveryCharge,
    this.rejectedByDrivers = const [],
    this.takeAway,
    this.tax,
  })  : this.address = address ?? AddressModel(),
        this.createdAt = createdAt ?? Timestamp.now(),
        this.taxModel = taxModel ?? null,
        this.vendor = vendor ?? VendorModel();

  factory OrderModel.fromJson(Map<String, dynamic> parsedJson) {
    List<OrderProductModel> orderProduct = parsedJson.containsKey('products') ? List<OrderProductModel>.from((parsedJson['products'] as List<dynamic>).map((e) => OrderProductModel.fromJson(e))).toList() : [].cast<OrderProductModel>();

    log("product is ==========> ${jsonEncode(orderProduct)} id ${parsedJson['id']}");

    return new OrderModel(
        orderType: parsedJson['order_type'] ?? "",
        address: parsedJson.containsKey('address') ? AddressModel.fromJson(parsedJson['address']) : AddressModel(),
        author: parsedJson.containsKey('author') ? User.fromJson(parsedJson['author']) : User(),
        authorID: parsedJson['authorID'] ?? '',
        createdAt: parsedJson['createdAt'] ?? Timestamp.now(),
        id: parsedJson['id'] ?? '',
        orderProduct: orderProduct,
        status: parsedJson['status'] ?? '',
        paymentShared: parsedJson['payment_shared'] ?? true,
        discount: parsedJson['discount'] ?? 0.0,
        paymentMethod: parsedJson["payment_method"] ?? '',
        couponCode: parsedJson['couponCode'] ?? '',
        couponId: parsedJson['couponId'] ?? '',
        vendor: parsedJson.containsKey('vendor') ? VendorModel.fromJson(parsedJson['vendor']) : VendorModel(),
        vendorID: parsedJson['vendorID'] ?? '',
        driver: parsedJson.containsKey('driver') ? User.fromJson(parsedJson['driver']) : null,
        driverID: parsedJson.containsKey('driverID') ? parsedJson['driverID'] : null,
        adminCommission: parsedJson["adminCommission"] != null ? parsedJson["adminCommission"] : "",
        adminCommissionType: parsedJson["adminCommissionType"] != null ? parsedJson["adminCommissionType"] : "",
        tipValue: parsedJson["tip_amount"] != null ? parsedJson["tip_amount"] : "",
        taxModel: (parsedJson.containsKey('taxSetting') && parsedJson['taxSetting'] != null) ? TaxModel.fromJson(parsedJson['taxSetting']) : null,
        notes: (parsedJson["notes"] != null && parsedJson["notes"].toString().isNotEmpty) ? parsedJson["notes"] : "",
        takeAway: parsedJson["takeAway"] != null ? parsedJson["takeAway"] : false,
        deliveryCharge: parsedJson["deliveryCharge"],
        rejectedByDrivers: parsedJson.containsKey('rejectedByDrivers') ? parsedJson['rejectedByDrivers'] : [].cast<String>(),
        tax: parsedJson["tax"]
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': this.address.toJson(),
      'author': this.author?.toJson(),
      'order_type': orderType,

      'authorID': this.authorID,
      'createdAt': this.createdAt,
      'id': this.id,
      'payment_shared': this.paymentShared,
      'products': this.orderProduct.map((e) => e.toJson()).toList(),
      'status': this.status,
      'discount': this.discount,
      'couponCode': this.couponCode,
      'payment_method': this.paymentMethod,
      'couponId': this.couponId,
      'vendor': this.vendor.toJson(),
      'vendorID': this.vendorID,
      'notes': this.notes,
      'adminCommission': this.adminCommission,
      'adminCommissionType': this.adminCommissionType,
      "tip_amount": this.tipValue,
      if (taxModel != null) "taxSetting": this.taxModel!.toJson(),
      // "extras":this.extras,
      //"extras_price":this.extra_size,
      "takeAway": this.takeAway,
      "deliveryCharge": this.deliveryCharge,
      "tax": this.tax
    };
  }
}
