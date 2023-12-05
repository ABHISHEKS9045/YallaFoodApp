class VariantInfo {
  String? variantId;
  String? variantPrice;
  String? variantSku;
  Map<String, dynamic>? variantOptions;

  VariantInfo({this.variantId, this.variantPrice, this.variantSku, this.variantOptions});

  VariantInfo.fromJson(Map<String, dynamic> json) {
    variantId = json['variant_id'];
    variantPrice = json['variant_price'];
    variantSku = json['variant_sku'];
    variantOptions = json['variant_options'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['variant_id'] = variantId;
    data['variant_price'] = variantPrice;
    data['variant_sku'] = variantSku;
    data['variant_options'] = variantOptions;
    return data;
  }
}
