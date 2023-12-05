import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:foodie_restaurant/constants.dart';

class User with ChangeNotifier {
  String email;

  String firstName;

  String lastName;

  String phoneNumber;

  bool active;

  UserSettings settings;

  Timestamp lastOnlineTimestamp;

  String userID;

  String profilePictureURL;

  String appIdentifier;

  String fcmToken;

  UserLocation location;

  List<dynamic> photos;

  String role;

  String vendorID;
  UserBankDetails userBankDetails;
  dynamic walletAmount;

  User(
      {this.email = '',
      this.userID = '',
      this.profilePictureURL = '',
      this.firstName = '',
      this.phoneNumber = '',
      this.lastName = '',
      this.active = true,
      this.walletAmount = 0.0,
      lastOnlineTimestamp,
      userBankDetails,
      settings,
      this.fcmToken = '',
      location,
      this.photos = const [],
      this.role = '',
      this.vendorID = ''})
      : this.lastOnlineTimestamp = lastOnlineTimestamp ?? Timestamp.now(),
        this.settings = settings ?? UserSettings(),
        this.userBankDetails = userBankDetails ?? UserBankDetails(),
        this.appIdentifier = 'Flutter Uber Restaurant Dashboard ${Platform.operatingSystem}',
        this.location = location ?? UserLocation();

  String fullName() {
    return '$firstName $lastName';
  }

  factory User.fromJson(Map<String, dynamic> parsedJson) {
    return new User(
        walletAmount: parsedJson['wallet_amount'] ?? 0.0,
        email: parsedJson['email'] ?? '',
        firstName: parsedJson['firstName'] ?? '',
        lastName: parsedJson['lastName'] ?? '',
        active: ((parsedJson.containsKey('active')) ? parsedJson['active'] : parsedJson['isActive']) ?? false,
        lastOnlineTimestamp: parsedJson['lastOnlineTimestamp'],
        phoneNumber: parsedJson['phoneNumber'] ?? '',
        userID: parsedJson['id'] ?? parsedJson['userID'] ?? '',
        profilePictureURL: parsedJson['profilePictureURL'] ?? '',
        fcmToken: parsedJson['fcmToken'] ?? '',
        location: parsedJson.containsKey('location') ? UserLocation.fromJson(parsedJson['location']) : UserLocation(),
        photos: parsedJson['photos'] ?? [].cast<dynamic>(),
        role: parsedJson['role'] ?? '',
        vendorID: parsedJson['vendorID'] ?? '',
        userBankDetails: parsedJson.containsKey('userBankDetails') ? UserBankDetails.fromJson(parsedJson['userBankDetails']) : UserBankDetails(),
        settings: parsedJson.containsKey('settings') ? UserSettings.fromJson(parsedJson['settings']) : UserSettings());
  }

  Map<String, dynamic> toJson() {
    photos.toList().removeWhere((element) => element == null);
    Map<String, dynamic> json = {
      'email': this.email,
      'wallet_amount': this.walletAmount,
      'firstName': this.firstName,
      'lastName': this.lastName,
      'phoneNumber': this.phoneNumber,
      'id': this.userID,
      'isActive': this.active,
      'active': this.active,
      'lastOnlineTimestamp': this.lastOnlineTimestamp,
      'settings': this.settings.toJson(),
      'userBankDetails': this.userBankDetails.toJson(),
      'profilePictureURL': this.profilePictureURL,
      'appIdentifier': this.appIdentifier,
      'fcmToken': this.fcmToken,
      'location': this.location.toJson(),
      'photos': this.photos,
      'role': this.role
    };
    if (role == USER_ROLE_VENDOR) {
      json.addAll({'vendorID': this.vendorID});
    }
    return json;
  }

  static fromPayload(e) {}

  Map<String, dynamic> toPayload() {
    Map<String, dynamic> json = {
      'email': this.email,
      'firstName': this.firstName,
      'lastName': this.lastName,
      'settings': this.settings.toJson(),
      'phoneNumber': this.phoneNumber,
      'id': this.userID,
      'active': this.active,
      'lastOnlineTimestamp': this.lastOnlineTimestamp.millisecondsSinceEpoch,
      'profilePictureURL': this.profilePictureURL,
      'appIdentifier': this.appIdentifier,
      'fcmToken': this.fcmToken,
      'location': this.location.toJson(),
      'role': this.role
    };
    if (this.role == 'vendor') {
      json.addAll({
        'role': this.role,
        'vendorID': this.vendorID,
      });
    }
    return json;
  }
}

class UserSettings {
  bool pushNewMessages;

  bool orderUpdates;

  bool newArrivals;

  bool promotions;

  bool photos;

  bool reststatus;

  UserSettings({this.pushNewMessages = false, this.orderUpdates = false, this.newArrivals = false, this.promotions = false, this.photos = false, this.reststatus = false});

  factory UserSettings.fromJson(Map<dynamic, dynamic> parsedJson) {
    return new UserSettings(
        pushNewMessages: parsedJson['pushNewMessages'] ?? true,
        orderUpdates: parsedJson['orderUpdates'] ?? true,
        newArrivals: parsedJson['newArrivals'] ?? true,
        promotions: parsedJson['promotions'] ?? true,
        photos: parsedJson['photos'] ?? true,
        reststatus: parsedJson['reststatus'] ?? false);
  }

  Map<String, dynamic> toJson() {
    return {
      'pushNewMessages': this.pushNewMessages,
      'orderUpdates': this.orderUpdates,
      'newArrivals': this.newArrivals,
      'promotions': this.promotions,
      'photos': this.photos,
      'reststatus': this.reststatus
    };
  }
}

class UserLocation {
  double latitude;

  double longitude;

  UserLocation({this.latitude = 0.01, this.longitude = 0.01});

  factory UserLocation.fromJson(Map<dynamic, dynamic> parsedJson) {
    double userlat = 0.1, userlog = 0.1;

    if (parsedJson.containsKey('latitude') && parsedJson['latitude'] != null && parsedJson['latitude'] != '') {
      if (parsedJson['latitude'] is double) {
        userlat = parsedJson['latitude'];
      }
      if (parsedJson['latitude'] is String) {
        userlat = double.parse(parsedJson['latitude']);
      }
    }

    if (parsedJson.containsKey('longitude') && parsedJson['longitude'] != null && parsedJson['longitude'] != '') {
      if (parsedJson['longitude'] is double) {
        userlog = parsedJson['longitude'];
      }
      if (parsedJson['longitude'] is String) {
        userlog = double.parse(parsedJson['longitude']);
      }
    }

    return new UserLocation(
      latitude: userlat,
      longitude: userlog,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': this.latitude,
      'longitude': this.longitude,
    };
  }
}

class UserBankDetails {
  String bankName;
  String branchName;
  String holderName;
  String accountNumber;
  String otherDetails;

  UserBankDetails({
    this.bankName = '',
    this.otherDetails = '',
    this.branchName = '',
    this.accountNumber = '',
    this.holderName = '',
  });

  factory UserBankDetails.fromJson(Map<String, dynamic> parsedJson) {
    return UserBankDetails(
      bankName: parsedJson['bankName'] ?? '',
      branchName: parsedJson['branchName'] ?? '',
      holderName: parsedJson['holderName'] ?? '',
      accountNumber: parsedJson['accountNumber'] ?? '',
      otherDetails: parsedJson['otherDetails'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bankName': this.bankName,
      'branchName': this.branchName,
      'holderName': this.holderName,
      'accountNumber': this.accountNumber,
      'otherDetails': this.otherDetails,
    };
  }
}
