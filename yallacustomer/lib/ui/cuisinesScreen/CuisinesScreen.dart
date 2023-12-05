import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:foodie_customer/AppGlobal.dart';
import 'package:foodie_customer/constants.dart';
import 'package:foodie_customer/model/ProductModel.dart';
import 'package:foodie_customer/model/VendorCategoryModel.dart';
import 'package:foodie_customer/services/FirebaseHelper.dart';
import 'package:foodie_customer/services/helper.dart';
import 'package:foodie_customer/ui/productDetailsScreen/ProductDetailsScreen.dart';
import '../../model/VendorModel.dart';

class CuisinesScreen extends StatefulWidget {
  const CuisinesScreen({Key? key, this.isPageCallFromHomeScreen = false, this.isPageCallForDineIn = false}) : super(key: key);
  @override
  _CuisinesScreenState createState() => _CuisinesScreenState();
  final bool? isPageCallFromHomeScreen;
  final bool? isPageCallForDineIn;
}

class _CuisinesScreenState extends State<CuisinesScreen> {

  String TAG = "_CuisinesScreenState";

  final fireStoreUtils = FireStoreUtils();
  late Future<List<VendorCategoryModel>> categoriesFuture;

  @override
  void initState() {
    super.initState();
    categoriesFuture = fireStoreUtils.getCuisines();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: isDarkMode(context) ? Color(DARK_VIEWBG_COLOR) : null,
        appBar: widget.isPageCallFromHomeScreen! ? AppGlobal.buildAppBar(context, "Categories".tr()) : null,
        body: FutureBuilder<List<VendorCategoryModel>>(
            future: categoriesFuture,
            initialData: [],
            builder: (context, snapshot) {
             //debugPrint("$TAG snapshot =======> ${snapshot.toString()}");
              if (snapshot.connectionState == ConnectionState.waiting)
                return Center(
                  child: CircularProgressIndicator.adaptive(
                    valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                  ),
                );

              if (snapshot.hasData || (snapshot.data?.isNotEmpty ?? false)) {
                return ListView.builder(
                    padding: EdgeInsets.all(10),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return snapshot.data != null ? buildCuisineCell(snapshot.data![index]) : showEmptyState('No Categories'.tr(), context, description: "add-categories".tr());
                    });
              }
              return CircularProgressIndicator();
            }));
  }

  Widget buildCuisineCell(VendorCategoryModel cuisineModel) {
    return Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: GestureDetector(
          onTap: () => push(
            context,
            FoodByCategory(categoryId: cuisineModel.id.toString(),),

          ),
          child: Container(
            height: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(23),
              image: DecorationImage(
                image: NetworkImage(cuisineModel.photo.toString()),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.darken),
              ),
            ),
            child: Center(
              child: Text(
                "${cuisineModel.title.toString()}",
                style: TextStyle(color: Colors.white, fontFamily: "Poppinsm", fontSize: 27),
              ),
            ),
          ),
        ));
  }



}

class FoodByCategory extends StatefulWidget {
   FoodByCategory({super.key, required this.categoryId});

  final String categoryId;

  @override
  State<FoodByCategory> createState() => _FoodByCategoryState();
}

class _FoodByCategoryState extends State<FoodByCategory> {


  final fireStoreUtils = FireStoreUtils();
  late Future<List<ProductModel>> categoriesFuture;

  @override
  void initState() {
    super.initState();
    categoriesFuture = fireStoreUtils.foodBycategory(widget.categoryId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppGlobal.buildAppBar(context, "Categories".tr()),
        body: FutureBuilder<List<ProductModel>>(
            future: categoriesFuture,
            // initialData: [],
            builder: (context, snapshot) {
              print("future: categoriesFuture =======> ${snapshot.data?.length}");
              if (snapshot.connectionState == ConnectionState.waiting)
                return Center(
                  child: CircularProgressIndicator.adaptive(
                    valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                  ),
                );

              if (snapshot.hasData ) {
                print("future: categoriesFuture snapshot.hasData : ${snapshot.hasData}");
                print("future: categoriesFuture snapshot.data : ${snapshot.data?.length}");
                return snapshot.data!.isEmpty ? Center(
                  child: Container(
                    child: Text(
                      "No Foods Found!".tr(),
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.bold
                      ),
                    ).tr(),
                  ),
                ): ListView.builder(
                    padding: EdgeInsets.all(10),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return buildVendorItemData(snapshot.data![index]);
                    })  ;}

              return CircularProgressIndicator();
            })
    );
  }
  Widget buildCuisineCell(FoodByCategoryModel foodByCategoryModel) {
    return Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: Container(
          height: 140,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(23),
            image: DecorationImage(
              image: NetworkImage(foodByCategoryModel.photo.toString()),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.darken),
            ),
          ),
          child: Center(
            child: Text(
              "${foodByCategoryModel.name.toString()}",
              style: TextStyle(color: Colors.white, fontFamily: "Poppinsm", fontSize: 27),
            ),
          ),
        ));
  }

  Widget buildVendorItemData(ProductModel foodByCategoryModel ) {
    // totItem++;
    return GestureDetector(
      onTap: () async {
        VendorModel? vendorModel = await FireStoreUtils.getVendor(foodByCategoryModel.vendorID.toString());
        if (vendorModel != null) {
          push(
            context,
            ProductDetailsScreen(
              vendorModel: vendorModel,
              productModel: foodByCategoryModel ,
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        width: MediaQuery.of(context).size.width * 0.8,
        margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        padding: const EdgeInsets.all(5),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: getImageVAlidUrl(foodByCategoryModel.photo.toString()),
                height: 100,
                width: 100,
                imageBuilder: (context, imageProvider) => Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                  ),
                ),
                placeholder: (context, url) => Center(
                    child: CircularProgressIndicator.adaptive(
                      valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                    )),
                errorWidget: (context, url, error) => ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      AppGlobal.placeHolderImage!,
                      fit: BoxFit.cover,
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                    )),
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    foodByCategoryModel.name.toString(),
                    style: const TextStyle(
                      fontFamily: "Poppinsm",
                      fontSize: 18,
                      color: Color(0xff000000),
                    ),
                    maxLines: 1,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    foodByCategoryModel.description.toString(),
                    maxLines: 1,
                    style: const TextStyle(
                      fontFamily: "Poppinsm",
                      fontSize: 16,
                      color: Color(0xff9091A4),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  foodByCategoryModel.disPrice.toString() == "" || foodByCategoryModel.disPrice.toString() == "0"
                      ? Text(
                    symbol + double.parse(foodByCategoryModel.price.toString()).toStringAsFixed(decimal),
                    style: TextStyle(fontSize: 16, fontFamily: "Poppinsm", letterSpacing: 0.5, color: Color(COLOR_PRIMARY)),
                  )
                      : Row(
                    children: [
                      Text(
                        "$symbol${double.parse(foodByCategoryModel.disPrice.toString()).toStringAsFixed(decimal)}",
                        style: TextStyle(
                          fontFamily: "Poppinsm",
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(COLOR_PRIMARY),
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        '$symbol${double.parse(foodByCategoryModel.price.toString()).toStringAsFixed(decimal)}',
                        style: const TextStyle(fontFamily: "Poppinsm", fontWeight: FontWeight.bold, color: Colors.grey, decoration: TextDecoration.lineThrough),
                      ),
                    ],
                  ),

                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}





