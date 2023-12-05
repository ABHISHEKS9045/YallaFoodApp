class TaxModel {
  String? taxLable;
  bool? taxActive, isLog = true;
  int? taxAmount;
  String? taxType;

  TaxModel({this.taxLable, this.taxActive, this.taxAmount, this.taxType});

  TaxModel.fromJson(Map<String, dynamic> json) {
    int taxVal = 0;
    if (json['tax_active'] != null && json['tax_active']) {
      if (json.containsKey('tax_amount') && json['tax_amount'] != null) {
        isLog = true;
        if (json['tax_amount'] is int) {
          taxVal = json['tax_amount'];
        } else if (json['tax_amount'] is String) {
          taxVal = int.parse(json['tax_amount']);
        }
      }
      taxLable = json['tax_lable'];
      taxActive = json['tax_active'];
      taxAmount = taxVal;
      taxType = json['tax_type'];
    }

    if (json.containsKey("active") && json['active'] != null && json['active']) {
      isLog = false;
      if (json.containsKey('tax') && json['tax'] != null) {
        if (json['tax'] is int) {
          taxVal = json['tax'];
        } else if (json['tax'] is String) {
          taxVal = int.parse(json['tax']);
        }
      }
      taxLable = json['lable'];
      taxActive = json['active'];
      taxAmount = taxVal;
      taxType = json['type'];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    if (this.isLog!) {
      data['tax_lable'] = this.taxLable;
      data['tax_active'] = this.taxActive;
      data['tax_amount'] = this.taxAmount;
      data['tax_type'] = this.taxType;
    } else {
      data['lable'] = this.taxLable;
      data['active'] = this.taxActive;
      data['tax'] = this.taxAmount;
      data['type'] = this.taxType;
    }
    return data;
  }
}
