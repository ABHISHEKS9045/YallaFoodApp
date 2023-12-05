import 'package:foodie_restaurant/constants.dart';
import 'package:foodie_restaurant/model/variant_info.dart';

class OrderProductModel {
  dynamic extras;
  dynamic variantInfo;
  String? extrasPrice;
  String id;
  String name;
  String photo;
  String price;
  String discountPrice;
  int quantity;
  String vendorID;
  String categoryId;

  OrderProductModel(
      {this.id = '',
      this.photo = '',
      this.price = '',
      this.name = '',
      this.quantity = 0,
      this.vendorID = '',
      this.extras = const [],
      this.extrasPrice = "",
      this.variantInfo,
      this.categoryId = '',
      this.discountPrice = ''});

  factory OrderProductModel.fromJson(Map<String, dynamic> parsedJson) {
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
    return new OrderProductModel(
      id: parsedJson['id'] ?? '',
      photo: parsedJson['photo'] == '' ? placeholderImage : parsedJson['photo'],
      price: parsedJson['price'] ?? '',
      discountPrice: parsedJson['discount_price'] ?? '',
      quantity: quanVal,
      name: parsedJson['name'] ?? '',
      vendorID: parsedJson['vendorID'] ?? '',
      categoryId: parsedJson['category_id'] ?? '',
      extras: extrasVal,
      extrasPrice: parsedJson["extras_price"] != null ? parsedJson["extras_price"] : "",
      variantInfo: (parsedJson.containsKey('variant_info') && parsedJson['variant_info'] != null) ? VariantInfo.fromJson(parsedJson['variant_info']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': this.id,
      'photo': this.photo,
      'price': this.price,
      'discount_price': this.discountPrice,
      'name': this.name,
      'quantity': this.quantity,
      'vendorID': this.vendorID,
      'category_id': this.categoryId,
      "extras": this.extras,
      "extras_price": this.extrasPrice,
      'variant_info': variantInfo != null ? variantInfo!.toJson() : null,
    };
  }
}
