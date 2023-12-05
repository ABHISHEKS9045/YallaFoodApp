import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodie_restaurant/constants.dart';
import 'package:foodie_restaurant/model/ItemAttributes.dart';

import 'VendorModel.dart';

class ProductModel {
  String categoryID;
  String description;
  String id;
  String photo;
  List<dynamic> photos;
  String price;
  String name;
  String vendorID;
  int quantity;
  bool publish;
  int calories;
  int grams;
  int proteins;
  int fats;
  bool veg;
  bool nonveg;
  String? disPrice = "0";
  bool takeaway;
  List<dynamic> addOnsTitle = [];
  List<dynamic> addOnsPrice = [];
  ItemAttributes? itemAttributes;
  Map<String, dynamic> specification = {};
  num reviewsCount;
  num reviewsSum;
  Map<String, dynamic>? reviewAttributes;

  ProductModel({
    this.categoryID = '',
    this.description = '',
    this.id = '',
    this.photo = '',
    this.photos = const [],
    this.price = '',
    this.name = '',
    this.quantity = 0,
    this.vendorID = '',
    this.calories = 0,
    this.grams = 0,
    this.proteins = 0,
    this.fats = 0,
    this.publish = true,
    this.veg = false,
    this.nonveg = false,
    this.disPrice,
    this.takeaway = false,
    geoFireData,
    this.itemAttributes,
    this.addOnsPrice = const [],
    this.addOnsTitle = const [],
    this.specification = const {},
    this.reviewAttributes,
    this.reviewsCount = 0,
    this.reviewsSum = 0,
  });

  factory ProductModel.fromJson(Map<String, dynamic> parsedJson) {
    return new ProductModel(
        categoryID: parsedJson['categoryID'] ?? '',
        description: parsedJson['description'] ?? '',
        id: parsedJson['id'] ?? '',
        photo: parsedJson['photo'] == '' ? placeholderImage : parsedJson['photo'],
        photos: parsedJson['photos'] ?? [],
        price: parsedJson['price'] ?? '',
        quantity: parsedJson['quantity'] ?? 0,
        name: parsedJson['name'] ?? '',
        vendorID: parsedJson['vendorID'] ?? '',
        publish: parsedJson['publish'] ?? true,
        calories: parsedJson['calories'] ?? 0,
        grams: parsedJson['grams'] ?? 0,
        proteins: parsedJson['proteins'] ?? 0,
        fats: parsedJson['fats'] ?? 0,
        nonveg: parsedJson['nonveg'] ?? false,
        disPrice: parsedJson['disPrice'] ?? '0',
        takeaway: parsedJson['takeawayOption'] == null ? false : parsedJson['takeawayOption'],
        addOnsPrice: parsedJson['addOnsPrice'] ?? [],
        addOnsTitle: parsedJson['addOnsTitle'] ?? [],
        reviewsCount: parsedJson['reviewsCount'] ?? 0,
        reviewsSum: parsedJson['reviewsSum'] ?? 0,
        reviewAttributes: parsedJson['reviewAttributes'] ?? {},
        geoFireData: parsedJson.containsKey('g')
            ? GeoFireData.fromJson(parsedJson['g'])
            : GeoFireData(
                geohash: "",
                geoPoint: GeoPoint(0.0, 0.0),
              ),
        specification: parsedJson['product_specification'] ?? {},
        itemAttributes: (parsedJson.containsKey('item_attribute') && parsedJson['item_attribute'] != null) ? ItemAttributes.fromJson(parsedJson['item_attribute']) : null,
        veg: parsedJson['veg'] ?? false);
  }

  Map<String, dynamic> toJson() {
    photos.toList().removeWhere((element) => element == null);
    return {
      'categoryID': this.categoryID,
      'description': this.description,
      'id': this.id,
      'photo': this.photo,
      'photos': this.photos,
      'price': this.price,
      'name': this.name,
      'quantity': this.quantity,
      'vendorID': this.vendorID,
      'publish': this.publish,
      'calories': this.calories,
      'grams': this.grams,
      'proteins': this.proteins,
      'fats': this.fats,
      'veg': this.veg,
      'nonveg': this.nonveg,
      'takeawayOption': this.takeaway,
      'disPrice': this.disPrice,
      "addOnsTitle": this.addOnsTitle,
      "addOnsPrice": this.addOnsPrice,
      'product_specification': specification,
      'item_attribute': itemAttributes != null ? itemAttributes!.toJson() : null,
      'reviewAttributes': reviewAttributes,
      'reviewsCount': reviewsCount,
      'reviewsSum': reviewsSum,
    };
  }
}

class ReviewsAttribute {
  num? reviewsCount;
  num? reviewsSum;

  ReviewsAttribute({
    this.reviewsCount,
    this.reviewsSum,
  });

  ReviewsAttribute.fromJson(Map<String, dynamic> json) {
    reviewsCount = json['reviewsCount'] ?? 0;
    reviewsSum = json['reviewsSum'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['reviewsCount'] = reviewsCount;
    data['reviewsSum'] = reviewsSum;
    return data;
  }
}
