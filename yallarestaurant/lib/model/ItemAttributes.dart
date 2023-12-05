class ItemAttributes {
  List<Attributes>? attributes;
  List<Variants>? variants;

  ItemAttributes({this.attributes, this.variants});

  ItemAttributes.fromJson(Map<String, dynamic> json) {
    List<Attributes> attribute = json.containsKey('attributes') ? List<Attributes>.from((json['attributes'] as List<dynamic>).map((e) => Attributes.fromJson(e))).toList() : [];

    List<Variants> variant = json.containsKey('variants') ? List<Variants>.from((json['variants'] as List<dynamic>).map((e) => Variants.fromJson(e))).toList() : [];

    attributes = attribute;
    variants = variant;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['attributes'] = this.attributes!.map((e) => e.toJson()).toList();
    data['variants'] = this.variants!.map((e) => e.toJson()).toList();
    return data;
  }
}

class Attributes {
  String? attributesId;
  List<dynamic>? attributeOptions;

  Attributes({this.attributesId, this.attributeOptions});

  Attributes.fromJson(Map<String, dynamic> json) {
    attributesId = json['attribute_id'];
    attributeOptions = json['attribute_options'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['attribute_id'] = this.attributesId;
    data['attribute_options'] = this.attributeOptions;
    return data;
  }
}

class Variants {
  String? variantId;
  String? variantImage;
  String? variantPrice;
  String? variantQuantity;
  String? variantSku;

  Variants({this.variantId, this.variantImage, this.variantPrice, this.variantQuantity, this.variantSku});

  Variants.fromJson(Map<String, dynamic> json) {
    variantId = json['variant_id'];
    variantImage = json['variant_image'];
    variantPrice = json['variant_price'];
    variantQuantity = json['variant_quantity'];
    variantSku = json['variant_sku'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['variant_id'] = this.variantId;
    data['variant_image'] = this.variantImage;
    data['variant_price'] = this.variantPrice;
    data['variant_quantity'] = this.variantQuantity;
    data['variant_sku'] = this.variantSku;
    return data;
  }
}
