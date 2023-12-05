import 'package:cloud_firestore/cloud_firestore.dart';

class WithdrawHistoryModel {
  String vendorID;

  num amount;

  String note;

  String paymentStatus;

  Timestamp paidDate;

  String id, adminNote;

  WithdrawHistoryModel({
    required this.amount,
    required this.vendorID,
    required this.paymentStatus,
    required this.paidDate,
    required this.id,
    required this.note,
    this.adminNote = "",
  });

  factory WithdrawHistoryModel.fromJson(Map<String, dynamic> parsedJson) {
    double amountVal = 0;
    if (parsedJson.containsKey('amount') && parsedJson['amount'] != null) {
      if (parsedJson['amount'] is int) {
        amountVal = parsedJson['amount'].toDouble();
      } else if (parsedJson['amount'] is String) {
        amountVal = double.parse(parsedJson['amount']);
      } else {
        amountVal = (parsedJson['amount']);
      }
    }
    return WithdrawHistoryModel(
      amount: amountVal,
      id: parsedJson['id'],
      paidDate: parsedJson['paidDate'] ?? '',
      paymentStatus: parsedJson['paymentStatus'] ?? 'Pending',
      vendorID: parsedJson['vendorID'],
      note: parsedJson['note'] ?? "",
      adminNote: parsedJson['adminNote'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'amount': this.amount,
      'id': this.id,
      'paidDate': this.paidDate,
      'paymentStatus': this.paymentStatus,
      'vendorID': this.vendorID,
      'note': this.note,
      'adminNote': this.adminNote,
    };
    return json;
  }
}
