import 'package:cloud_firestore/cloud_firestore.dart';

class WithdrawHistoryModel {
  String driverID;

  num amount;

  String note, adminNote;

  String paymentStatus;

  Timestamp paidDate;

  String id;

  WithdrawHistoryModel(
      {required this.amount,
      required this.driverID,
      required this.paymentStatus,
      required this.paidDate,
      required this.id,
      required this.note,
      this.adminNote = ''});

  factory WithdrawHistoryModel.fromJson(Map<String, dynamic> parsedJson) {
    return WithdrawHistoryModel(
      amount: parsedJson['amount'] ?? 0.0,
      id: parsedJson['id'],
      paidDate: parsedJson['paidDate'] ?? '',
      paymentStatus: parsedJson['paymentStatus'] ?? 'Pending',
      driverID: parsedJson['driverID'],
      note: parsedJson['note'],
      adminNote: parsedJson['adminNote'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'amount': this.amount,
      'id': this.id,
      'paidDate': this.paidDate,
      'paymentStatus': this.paymentStatus,
      'driverID': this.driverID,
      'note': this.note,
      'adminNote': this.adminNote,
    };
    return json;
  }
}
