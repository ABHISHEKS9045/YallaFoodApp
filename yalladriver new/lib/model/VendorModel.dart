import 'package:cloud_firestore/cloud_firestore.dart';

class VendorModel {
  String author;

  String authorName;

  String authorProfilePic;

  String categoryID;

  String fcmToken;
  String categoryPhoto;

  String categoryTitle = "";
  num walletAmount;

  dynamic createdAt;

  String description;
  String phonenumber;

  dynamic filters;

  String id;

  double latitude;

  double longitude;

  String photo;

  List<dynamic> photos;

  String location;

  String price;

  num reviewsCount;

  num reviewsSum;

  String title;
  String opentime;

  String closetime;
  bool hidephotos;
  bool reststatus;
  GeoFireData geoFireData;

  VendorModel(
      {this.author = '',
      this.hidephotos = false,
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
      this.location = '',
      this.price = '',
      this.reviewsCount = 0,
      this.reviewsSum = 0,
      this.closetime = '',
      this.opentime = '',
      this.walletAmount = 0,
      this.title = '',
      this.reststatus = false,
      geoFireData})
      : this.geoFireData = geoFireData ??
            GeoFireData(
              geohash: "",
              geoPoint: GeoPoint(0.0, 0.0),
            );

  factory VendorModel.fromJson(Map<String, dynamic> parsedJson) {
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
        hidephotos: parsedJson['hidephotos'] ?? false,
        authorName: parsedJson['authorName'] ?? '',
        authorProfilePic: parsedJson['authorProfilePic'] ?? '',
        categoryID: parsedJson['categoryID'] ?? '',
        categoryPhoto: parsedJson['categoryPhoto'] ?? '',
        categoryTitle: parsedJson['categoryTitle'] ?? '',
        walletAmount: walVal,
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
        filters:
            // parsedJson.containsKey('filters') ?
            parsedJson['filters'] ?? [],
        // : Filters(cuisine: ''),
        id: parsedJson['id'] ?? '',
        latitude: parsedJson['latitude'] ?? 0.1,
        longitude: parsedJson['longitude'] ?? 0.1,
        photo: parsedJson['photo'] ?? '',
        photos: parsedJson['photos'] ?? [],
        location: parsedJson['location'] ?? '',
        fcmToken: parsedJson['fcmToken'] ?? '',
        price: parsedJson['price'] ?? '',
        reviewsCount: parsedJson['reviewsCount'] ?? 0,
        reviewsSum: parsedJson['reviewsSum'] ?? 0,
        title: parsedJson['title'] ?? '',
        closetime: parsedJson['closetime'] ?? '',
        opentime: parsedJson['opentime'] ?? '',
        reststatus: parsedJson['reststatus'] ?? false);
  }

  Map<String, dynamic> toJson() {
    return {
      'author': this.author,
      'hidephotos': this.hidephotos,
      'authorName': this.authorName,
      'authorProfilePic': this.authorProfilePic,
      'categoryID': this.categoryID,
      'categoryPhoto': this.categoryPhoto,
      'categoryTitle': this.categoryTitle,
      'createdAt': this.createdAt.toJson(),
      "g": this.geoFireData.toJson(),
      'description': this.description,
      'phonenumber': this.phonenumber,
      'filters': this.filters,
      'id': this.id,
      'latitude': this.latitude,
      'walletAmount': this.walletAmount,
      'longitude': this.longitude,
      'photo': this.photo,
      'photos': this.photos,
      'location': this.location,
      'fcmToken': this.fcmToken,
      'price': this.price,
      'reviewsCount': this.reviewsCount,
      'reviewsSum': this.reviewsSum,
      'title': this.title,
      'opentime': this.opentime,
      'closetime': this.closetime,
      'reststatus': this.reststatus
    };
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
