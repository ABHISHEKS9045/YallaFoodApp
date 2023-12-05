import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodie_restaurant/constants.dart';
import 'package:foodie_restaurant/model/DeliveryChargeModel.dart';
import 'package:foodie_restaurant/model/SpecialDiscountModel.dart';
import 'package:foodie_restaurant/model/WorkingHoursModel.dart';

class VendorModel {
  String author;

  String authorName;

  String authorProfilePic;

  String categoryID;

  String fcmToken;

  String categoryPhoto;

  String categoryTitle = "";

  dynamic createdAt;

  String description;
  String phonenumber;

  Map<String, dynamic> filters;

  String id;

  double latitude;

  double longitude;

  String photo;

  List<dynamic> photos;
  List<dynamic> restaurantMenuPhotos;

  String location;

  String price;

  num reviewsCount, restaurantCost;

  num reviewsSum;
  num walletAmount;

  String title;

  String openDineTime;

  String closeDineTime;

  bool hidePhotos, dineIinActive;

  bool restStatus, enabledDiveInFuture;

  GeoFireData geoFireData;
  GeoPoint coordinates;
  DeliveryChargeModel? deliveryCharge;
  List<SpecialDiscountModel>? specialDiscount;
  List<WorkingHoursModel>? workingHours;

  bool specialDiscountEnable;

  VendorModel(
      {this.author = '',
      this.hidePhotos = false,
      this.dineIinActive = false,
      this.authorName = '',
      this.authorProfilePic = '',
      this.categoryID = '',
      this.categoryPhoto = '',
      this.categoryTitle = '',
      this.createdAt,
      this.filters = const {},
      this.description = '',
      this.phonenumber = '',
      this.fcmToken = '',
      this.id = '',
      this.latitude = 0.1,
      this.longitude = 0.1,
      this.photo = '',
      this.photos = const [],
      this.workingHours = const [],
      this.restaurantMenuPhotos = const [],
      this.specialDiscount = const [],
      this.specialDiscountEnable = false,
      this.location = '',
      this.price = '',
      this.reviewsCount = 0,
      this.reviewsSum = 0,
      this.restaurantCost = 0,
      this.walletAmount = 0,
      this.closeDineTime = '',
      this.openDineTime = '',
      this.title = '',
      coordinates,
      this.restStatus = true,
      this.enabledDiveInFuture = false,
      geoFireData,
        deliveryCharge})
      : this.coordinates = coordinates ?? GeoPoint(0.0, 0.0),
        this.deliveryCharge = deliveryCharge ?? null,
        this.geoFireData = geoFireData ??
            GeoFireData(
              geohash: "",
              geoPoint: GeoPoint(0.0, 0.0),
            );

  factory VendorModel.fromJson(Map<String, dynamic> parsedJson) {
    num restCost = 0;
    if (parsedJson.containsKey("restaurantCost")) {
      if (parsedJson['restaurantCost'] is String && parsedJson['restaurantCost'] != '') {
        restCost = num.parse(parsedJson['restaurantCost']);
      }

      if (parsedJson['restaurantCost'] is num) {
        restCost = parsedJson['restaurantCost'];
      }
    }

    List<SpecialDiscountModel> specialDiscount = parsedJson.containsKey('specialDiscount')
        ? List<SpecialDiscountModel>.from((parsedJson['specialDiscount'] as List<dynamic>).map((e) => SpecialDiscountModel.fromJson(e))).toList()
        : [].cast<SpecialDiscountModel>();

    List<WorkingHoursModel> workingHours = parsedJson.containsKey('workingHours')
        ? List<WorkingHoursModel>.from((parsedJson['workingHours'] as List<dynamic>).map((e) => WorkingHoursModel.fromJson(e))).toList()
        : [].cast<WorkingHoursModel>();

    if (parsedJson.containsKey("tax_amount")) {
      if (parsedJson['tax_amount'] is String && parsedJson['tax_amount'] != '') {
      }
      if (parsedJson['tax_amount'] is num) {
      }
    }
    num walVal = 0;
    if (parsedJson['walletAmount'] != null) {
      if (parsedJson['walletAmount'] is int) {
        walVal = parsedJson['walletAmount'];
      } else if (parsedJson['walletAmount'] is double) {
        walVal = parsedJson['walletAmount'].toInt();
      } else if (parsedJson['walletAmount'] is String) {
        if (parsedJson['walletAmount'].isNotEmpty) {
          walVal = num.parse(parsedJson['walletAmount']);
        } else {
          walVal = 0;
        }
      }
    }
    return new VendorModel(
        author: parsedJson['author'] ?? '',
        hidePhotos: parsedJson['hidephotos'] ?? false,
        dineIinActive: parsedJson['dine_in_active'] ?? false,
        authorName: parsedJson['authorName'] ?? '',
        authorProfilePic: parsedJson['authorProfilePic'] ?? '',
        categoryID: parsedJson['categoryID'] ?? '',
        categoryPhoto: parsedJson['categoryPhoto'] ?? '',
        categoryTitle: parsedJson['categoryTitle'] ?? '',
        deliveryCharge: (parsedJson.containsKey('DeliveryCharge') && parsedJson['DeliveryCharge'] != null) ? DeliveryChargeModel.fromJson(parsedJson['DeliveryCharge']) : null,
        createdAt: parsedJson['createdAt'] != null
            ? parsedJson['createdAt'] is Map<dynamic, dynamic>
            ? CreatedAt.fromJson(parsedJson['createdAt'])
            : parsedJson['createdAt']
            : parsedJson['createdAt'] is Map<dynamic, dynamic>
            ? CreatedAt()
            : Timestamp.now(),
        geoFireData: parsedJson.containsKey('g')
            ? GeoFireData.fromJson(parsedJson['g'])
            : GeoFireData(
                geohash: "",
                geoPoint: GeoPoint(0.0, 0.0),
              ),
        description: parsedJson['description'] ?? '',
        phonenumber: parsedJson['phonenumber'] ?? '',
        walletAmount: walVal,
        filters: parsedJson['filters'] ?? {},
        id: parsedJson['id'] ?? '',
        workingHours: workingHours,
        latitude: parsedJson['latitude'] ?? 0.1,
        longitude: parsedJson['longitude'] ?? 0.1,
        photo: parsedJson['photo'] ?? '',
        photos: parsedJson['photos'] ?? [],
        restaurantMenuPhotos: parsedJson['restaurantMenuPhotos'] ?? [],
        location: parsedJson['location'] ?? '',
        fcmToken: parsedJson['fcmToken'] ?? '',
        price: parsedJson['price'] ?? '',
        reviewsCount: parsedJson['reviewsCount'] ?? 0,
        reviewsSum: parsedJson['reviewsSum'] ?? 0,
        restaurantCost: restCost,
        title: parsedJson['title'] ?? '',
        specialDiscount: specialDiscount,
        closeDineTime: parsedJson['closeDineTime'] ?? '',
        openDineTime: parsedJson['openDineTime'] ?? '',
        coordinates: parsedJson['coordinates'] ?? GeoPoint(0.0, 0.0),
        restStatus: parsedJson['reststatus'] ?? false,
        enabledDiveInFuture: parsedJson['enabledDiveInFuture'] ?? false,
        specialDiscountEnable: parsedJson['specialDiscountEnable'] ?? false);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'filters': this.filters,
      'author': this.author,
      'hidephotos': this.hidePhotos,
      'dine_in_active': this.dineIinActive,
      'authorName': this.authorName,
      'authorProfilePic': this.authorProfilePic,
      'categoryID': this.categoryID,
      'categoryPhoto': this.categoryPhoto,
      'categoryTitle': this.categoryTitle,
      'createdAt': this.createdAt.toJson(),
      "g": this.geoFireData.toJson(),
      'description': this.description,
      'phonenumber': this.phonenumber,
      'walletAmount': this.walletAmount,
      'id': this.id,
      'latitude': this.latitude,
      'longitude': this.longitude,
      'coordinates': this.coordinates,
      'photo': this.photo,
      'photos': this.photos,
      'restaurantMenuPhotos': this.restaurantMenuPhotos,
      'location': this.location,
      'fcmToken': this.fcmToken,
      'price': this.price,
      'reviewsCount': this.reviewsCount,
      'reviewsSum': this.reviewsSum,
      'restaurantCost': this.restaurantCost,
      'title': this.title,
      'openDineTime': this.openDineTime,
      'closeDineTime': this.closeDineTime,
      'reststatus': this.restStatus,
      'enabledDiveInFuture': this.enabledDiveInFuture,
      'specialDiscount': this.specialDiscount!.map((e) => e.toJson()).toList(),
      'workingHours': this.workingHours!.map((e) => e.toJson()).toList(),
      'specialDiscountEnable': this.specialDiscountEnable,
    };
    if (this.deliveryCharge != null) {
      json.addAll({'DeliveryCharge': this.deliveryCharge!.toJson()});
    }

    return json;
  }
}

class GeoFireData {
  String? geohash;
  GeoPoint? geoPoint;

  GeoFireData({this.geohash, this.geoPoint});

  factory GeoFireData.fromJson(Map<dynamic, dynamic> parsedJson) {
    return GeoFireData(
      geohash: parsedJson['geohash'] ?? '',
      geoPoint: parsedJson['geopoint'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'geohash': this.geohash,
      'geopoint': this.geoPoint,
    };
  }
}

class GeoPointClass {
  double latitude;

  double longitude;

  GeoPointClass({this.latitude = 0.01, this.longitude = 0.0});

  factory GeoPointClass.fromJson(Map<dynamic, dynamic> parsedJson) {
    return new GeoPointClass(
      latitude: parsedJson['latitude'] ?? 00.1,
      longitude: parsedJson['longitude'] ?? 00.1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': this.latitude,
      'longitude': this.longitude,
    };
  }
}

class CreatedAt {
  num nanoseconds;

  num seconds;

  CreatedAt({this.nanoseconds = 0.0, this.seconds = 0.0});

  factory CreatedAt.fromJson(Map<dynamic, dynamic> parsedJson) {
    return CreatedAt(
      nanoseconds: parsedJson['_nanoseconds'] ?? '',
      seconds: parsedJson['_seconds'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_nanoseconds': this.nanoseconds,
      '_seconds': this.seconds,
    };
  }
}

class Filters {
  String cuisine;

  String wifi;

  String breakfast;

  String dinner;

  String lunch;

  String seating;

  String vegan;

  String reservation;

  String music;

  String price;

  Filters({required this.cuisine, this.seating = '', this.price = '', this.breakfast = '', this.dinner = '', this.lunch = '', this.music = '', this.reservation = '', this.vegan = '', this.wifi = ''});

  factory Filters.fromJson(Map<dynamic, dynamic> parsedJson) {
    return new Filters(
        cuisine: parsedJson["Cuisine"] ?? '',
        wifi: parsedJson["Free Wi-Fi"] ?? 'No',
        breakfast: parsedJson["Good for Breakfast"] ?? 'No',
        dinner: parsedJson["Good for Dinner"] ?? 'No',
        lunch: parsedJson["Good for Lunch"] ?? 'No',
        music: parsedJson["Live Music"] ?? 'No',
        price: parsedJson["Price"] ?? '$symbol',
        reservation: parsedJson["Takes Reservations"] ?? 'No',
        vegan: parsedJson["Vegetarian Friendly"] ?? 'No',
        seating: parsedJson["Outdoor Seating"] ?? 'No');
  }

  Map<String, dynamic> toJson() {
    return {
      'Cuisine': this.cuisine,
      'Free Wi-Fi': this.wifi,
      'Good for Breakfast': this.breakfast,
      'Good for Dinner': this.dinner,
      'Good for Lunch': this.lunch,
      'Live Music': this.music,
      'Price': this.price,
      'Takes Reservations': this.reservation,
      'Vegetarian Friendly': this.vegan,
      'Outdoor Seating': this.seating
    };
  }
}
