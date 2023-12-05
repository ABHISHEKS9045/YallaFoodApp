import 'package:foodie_customer/constants.dart';

class VendorCategoryModel {
  List<dynamic>? reviewAttributes;
  String? photo;
  String? description;
  String? id;
  String? title;
  num? order;





  VendorCategoryModel({this.reviewAttributes, this.photo, this.description, this.id, this.title, this.order});

  VendorCategoryModel.fromJson(Map<String, dynamic> json) {
    reviewAttributes = json['review_attributes'] ?? [];
    photo = json['photo'] ?? "";
    description = json['${lang == "en" ? "description"  : "description_$lang"}'] ?? '';
    id = json['id'] ?? "";
    title = json['${lang == "en" ? "title"  : "title_$lang"}'] ?? "";
    order = json['order'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['review_attributes'] = reviewAttributes;
    data['photo'] = photo;
    data['${lang == "en" ? "description"  : "description_$lang"}'] = description;
    data['id'] = id;
    data['${lang == "en" ? "title"  : "title_$lang"}'] = title;
    data['order'] = order;
    return data;
  }
}

class FoodByCategoryModel{

  String? name;
  String? photo;
  String? description;
  String? discountPrice;
  String? price;
  String? vendorID;

  FoodByCategoryModel({this.name,this.photo,this.description,this.discountPrice,this.price,this.vendorID,});

  FoodByCategoryModel.fromJson(Map<String, dynamic> json){
    name = json["name"] ?? '';
    photo = json["photo"] ?? '';
    vendorID = json["vendorID"] ?? '';
    description = json["description"] ?? "";
    discountPrice = json["discountPrice"] ?? "";
    price = json["price"] ?? "";
  }

  Map<String, dynamic> toJson() {

    final Map<String, dynamic> data = <String, dynamic>{};
    data["name"] = name;
    data["photo"] = photo;
    data["price"] = price;
    data["vendorID"] = vendorID;
    data["discountPrice"] = discountPrice;
    data["description"] = description;

    return data;
  }



}
