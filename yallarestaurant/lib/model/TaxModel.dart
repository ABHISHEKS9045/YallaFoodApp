class TaxModel {
  String? taxLabel;
  bool? taxActive;
  int? taxAmount;
  String? taxType;

  TaxModel({this.taxLabel, this.taxActive, this.taxAmount, this.taxType});

  TaxModel.fromJson(Map<String, dynamic> json) {
    int taxVal = 0;
    if (json['active'] != null && json['active']) {
      if (json.containsKey('tax') && json['tax'] != null) {
        if (json['tax'] is int) {
          taxVal = json['tax'];
        } else if (json['tax'] is String) {
          taxVal = int.parse(json['tax']);
        }
      }
      taxLabel = json['label'];
      taxActive = json['active'];
      taxAmount = taxVal;
      taxType = json['type'];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['label'] = this.taxLabel;
    data['active'] = this.taxActive;
    data['tax'] = this.taxAmount;
    data['type'] = this.taxType;
    return data;
  }
}
