import 'package:foodie_driver/constants.dart';
import 'package:foodie_driver/model/variant_info.dart';

class ProductModel {
  dynamic extras;
  dynamic variant_info;
  String? extras_price;
  String id;
  String name;
  String photo;
  String price;
  String discount_price;
  int quantity;
  String vendorID;
  String category_id;

  ProductModel(
      {this.id = '',
        this.photo = '',
        this.price = '',
        this.discount_price = '',
        this.name = '',
        this.quantity = 0,
        this.vendorID = '',
        this.category_id = '',
        this.extras = const [],
        this.extras_price = "",
        this.variant_info});

  factory ProductModel.fromJson(Map<String, dynamic> parsedJson) {
    dynamic extrasVal;
    if (parsedJson['extras'] == null) {
      extrasVal = List<String>.empty();
    } else {
      if (parsedJson['extras'] is String) {
        if (parsedJson['extras'] == '[]') {
          extrasVal = List<String>.empty();
        } else {
          String extraDecode = parsedJson['extras'].toString().replaceAll("[", "").replaceAll("]", "").replaceAll("\"", "");
          if (extraDecode.contains(",")) {
            extrasVal = extraDecode.split(",");
          } else {
            extrasVal = [extraDecode];
          }
        }
      }
      if (parsedJson['extras'] is List) {
        extrasVal = parsedJson['extras'].cast<String>();
      }
    }

    int quanVal = 0;
    if (parsedJson['quantity'] == null || parsedJson['quantity'] == double.nan || parsedJson['quantity'] == double.infinity) {
      quanVal = 0;
    } else {
      if (parsedJson['quantity'] is String) {
        quanVal = int.parse(parsedJson['quantity']);
      } else {
        quanVal = (parsedJson['quantity'] is double) ? (parsedJson["quantity"].isNaN ? 0 : (parsedJson['quantity'] as double).toInt()) : parsedJson['quantity'];
      }
    }
    return new ProductModel(
      id: parsedJson['id'] ?? '',
      photo: parsedJson['photo'] == '' ? placeholderImage : parsedJson['photo'],
      price: parsedJson['price'] ?? '',
      discount_price: parsedJson['discount_price'] ?? '',
      quantity: quanVal,
      name: parsedJson['name'] ?? '',
      vendorID: parsedJson['vendorID'] ?? '',
      category_id: parsedJson['category_id'] ?? '',
      extras: extrasVal,
      extras_price: parsedJson["extras_price"] != null ? parsedJson["extras_price"] : "",
      variant_info: (parsedJson.containsKey('variant_info') && parsedJson['variant_info'] != null) ? VariantInfo.fromJson(parsedJson['variant_info']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': this.id,
      'photo': this.photo,
      'price': this.price,
      'discount_price': this.discount_price,
      'name': this.name,
      'quantity': this.quantity,
      'vendorID': this.vendorID,
      'category_id': this.category_id,
      "extras": this.extras,
      "extras_price": this.extras_price,
      'variant_info': variant_info != null ? variant_info!.toJson() : null,
    };
  }
}
