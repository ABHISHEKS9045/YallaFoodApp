import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../../model/CodModel.dart';
import '../../model/OrderModel.dart';
import '../../model/ProductModel.dart';
import '../../model/TaxModel.dart';
import '../../model/User.dart';
import '../../model/VendorModel.dart';
import '../../services/FirebaseHelper.dart';
import '../../services/helper.dart';
import '../../services/localDatabase.dart';
import '../checkoutScreen/CheckoutScreen.dart';
import '../placeOrderScreen/PlaceOrderScreen.dart';




class PaymentWebViewPage extends StatefulWidget {
  final double total;
  final double? discount;
  final String? couponCode;
  final String? couponId, notes;
  final List<CartProduct> products;

  final List<String>? extraAddons;
  final String? tipValue;
  final bool? takeAway;
  final String? deliveryCharge;
  final TaxModel? taxModel;
  final Map<String, dynamic>? specialDiscountMap;
  final double? subTotal;
  final double? discountVal;


  const PaymentWebViewPage({
    Key? key,
    required this.total,
    this.discount,
    this.couponCode,
    this.couponId,
    required this.products,
    this.extraAddons,
    this.tipValue,
    this.takeAway,
    this.deliveryCharge,
    this.notes,
    this.taxModel,
    this.specialDiscountMap,
    required this.subTotal,
    required this.discountVal,
  }) : super(key: key);


  @override
  _PaymentWebViewPageState createState() => _PaymentWebViewPageState();
}

class _PaymentWebViewPageState extends State<PaymentWebViewPage> {

  final fireStoreUtils = FireStoreUtils();
  late Future<bool> hasNativePay;

  //List<PaymentMethod> _cards = [];
  late Future<CodModel?> futurecod;

  Stream<DocumentSnapshot<Map<String, dynamic>>>? userQuery;

  static FirebaseFirestore fireStore = FirebaseFirestore.instance;



  Dio dio = Dio();  // Create a Dio instance
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> setPrefData() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString("musics_key", "");
  }




  InAppWebViewController? _webViewController;
  String paymentUrl = '';
  String? loginToken;
  String? clearingLogId;
  String paymentType = "";
  String? adminCommissionValue = "", addminCommissionType = "";
  bool? isEnableAdminCommission = false;

  bool isSuccess = false;
  bool isLoading = true;
  placeOrder(BuildContext buildContext, {String? oid}) async {
    FireStoreUtils fireStoreUtils = FireStoreUtils();
    List<CartProduct> tempProduc = [];

    if (paymentType.isEmpty) {
      ShowDialogToDismiss(title: "Empty payment type".tr(), buttonText: "ok".tr(), content: "Select payment type".tr());
      return;
    }

    for (CartProduct cartProduct in widget.products) {
      CartProduct tempCart = cartProduct;
      tempProduc.add(tempCart);
    }
    //place order
    showProgress(buildContext, 'Placing Order...'.tr(), false);
    VendorModel vendorModel = await fireStoreUtils.getVendorByVendorID(widget.products.first.vendorID).whenComplete(() => setPrefData());
    print(vendorModel.fcmToken.toString() + "{}{}{}{======TOKENADD" + vendorModel.toJson().toString());
    OrderModel orderModel = OrderModel(
      address: MyAppState.currentUser!.shippingAddress,
      author: MyAppState.currentUser,
      authorID: MyAppState.currentUser!.userID,
      createdAt: Timestamp.now(),
      products: tempProduc,
      status: ORDER_STATUS_PLACED,
      vendor: vendorModel,
      paymentMethod: paymentType,
      notes: widget.notes,
      taxModel: widget.taxModel,
      vendorID: widget.products.first.vendorID,
      discount: widget.discount,
      specialDiscount: widget.specialDiscountMap,
      couponCode: widget.couponCode,
      couponId: widget.couponId,
      adminCommission: isEnableAdminCommission! ? adminCommissionValue : "0",
      adminCommissionType: isEnableAdminCommission! ? addminCommissionType : "",
      takeAway: true,
      deviceType: "mobile app",
      tax: getTaxValue(widget.taxModel, widget.subTotal! - widget.discountVal! - widget.specialDiscountMap?["special_discount"]).toStringAsFixed(decimal),
    );

    if (oid != null && oid.isNotEmpty) {
      orderModel.id = oid;
    }

    OrderModel placedOrder = await fireStoreUtils.placeOrderWithTakeAWay(orderModel);
    print("||||{}" + orderModel.toJson().toString());
    for (int i = 0; i < tempProduc.length; i++) {
      await FireStoreUtils().getProductByID(tempProduc[i].id.split('~').first).then((value) async {
        ProductModel? productModel = value;
        if (tempProduc[i].variant_info != null) {
          for (int j = 0; j < productModel.itemAttributes!.variants!.length; j++) {
            if (productModel.itemAttributes!.variants![j].variantId == tempProduc[i].id.split('~').last) {
              if (productModel.itemAttributes!.variants![j].variantQuantity != "-1") {
                productModel.itemAttributes!.variants![j].variantQuantity = (int.parse(productModel.itemAttributes!.variants![j].variantQuantity.toString()) - tempProduc[i].quantity).toString();
              }
            }
          }
        } else {
          if (productModel.quantity != -1) {
            productModel.quantity = productModel.quantity - tempProduc[i].quantity;
          }
        }

        await FireStoreUtils.updateProduct(productModel).then((value) {});
      });
    }

    hideProgress();
    print('_CheckoutScreenState.placeOrder ${placedOrder.id}');
    showModalBottomSheet(
      isScrollControlled: true,
      isDismissible: false,
      context: buildContext,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) => PlaceOrderScreen(orderModel: placedOrder),
    );
  }
  getPaymentStatusById() async {
    print("isSuccess before payment: ${isSuccess}");
    String getPaymentStatusUrl = "$invoice4uBaseUrl$getClearingLogById";
    Map<String,dynamic>  requestBody = {
      "clearingLogId": clearingLogId,
      "token": loginToken
    };

    try{
      Response paymentResponse = await dio.post(
        getPaymentStatusUrl,
        data: requestBody,
      );

      if (paymentResponse.statusCode == 200) {
        // API call was successful

        print("paymentResponse.data: ${paymentResponse.data['d']['IsSuccess']}");
        isSuccess = paymentResponse.data['d']['IsSuccess'];

        print("isSuccess after payment: ${isSuccess}");



        if (isSuccess == true) {
          if (widget.takeAway!) {
            placeOrder(_scaffoldKey.currentContext!);
          } else {
            push(
              _scaffoldKey.currentContext!,
              CheckoutScreen(
                isPaymentDone: true,
                total: widget.total,
                discount: widget.discount!,
                paymentType: "online",
                couponCode: widget.couponCode!,
                couponId: widget.couponId!,
                paymentOption: "Credit card",
                products: widget.products,
                deliveryCharge: widget.deliveryCharge,
                tipValue: widget.tipValue,
                specialDiscountMap: widget.specialDiscountMap,
                takeAway: widget.takeAway,
                subTotal: widget.subTotal,
                discountVal: widget.discountVal,
              ),
            );
          }

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              "Payment Successful!!".tr() + "\n",
            ),
            backgroundColor: Colors.green.shade400,
            duration: Duration(seconds: 6),
          ));
        } else {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              "Payment Unsuccessful!!".tr() + "\n",
            ),
            backgroundColor: Colors.red.shade400,
            duration: Duration(seconds: 6),
          ));
        }



      } else {
        // Handle error cases
        Navigator.pop(_scaffoldKey.currentContext!);

        print('API call failed with status code: ${paymentResponse.statusCode}');
      }

      print(paymentResponse);

    } catch (error){
      // Navigator.pop(_scaffoldKey.currentContext!);

      // Handle other errors like network issues
      print('Error: ${error.toString()}');

    }

  }
  verifyLoginInvoice4u() async {

    String email = 'Ramzibenbare@gmail.com';
    String password = 'Rayan1102\$\$';

    String verifyLoginUrl = "$invoice4uBaseUrl$verifyLogin";
    Map<String,dynamic>  loginRequestBody = {
      "email": email,
      "password": password

    };

    try{
      Response loginResponse = await dio.post(
        verifyLoginUrl,
        data: loginRequestBody,
      );

      if (loginResponse.statusCode == 200) {
        // API call was successful
        loginToken =  loginResponse.data["d"].toString();
        getPaymentStatusById();

        // Navigator.pop(_scaffoldKey.currentContext!);

      } else {
        // Handle error cases
        Navigator.pop(_scaffoldKey.currentContext!);

        print('API call failed with status code: ${loginResponse.statusCode}');
      }

      print(loginResponse);

    } catch (error){
      // Navigator.pop(_scaffoldKey.currentContext!);

      // Handle other errors like network issues
      print('Error: ${error.toString()}');

    }

  }

  String customerName = "";
  String customerEmail = "";
  String customerPhone = "";

  getCustomerDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    customerName = prefs.getString("customer_name",).toString();
    customerEmail = prefs.getString("customer_email",).toString();
    customerPhone = prefs.getString("customer_phone",).toString();

    print("customerPhone$customerPhone");
  }

  Future<void> upayMakePayment({required String amount, }) async {

    await getCustomerDetails();
    // Your existing code for making the payment request
    String payUrl = "$invoice4uBaseUrl$processApiRequestV2";
    Map<String, dynamic> requestBody = {
      "request": {
        "Invoice4UUserApiKey": "18939a2d-b9ad-473a-999d-58f85654197b",
        "Type": "1",
        "CreditCardCompanyType": "1",
        "FullName": customerName,
        "Phone": '',
        "Email": customerEmail,
        // "Sum": amount,
        "Sum": amount,
        "Description": "Invoice4U Clearing",
        "PaymentsNum": "1",
        "Currency": "ILS",
        "OrderIdClientUsage": "order id if needed",
        "IsDocCreate": "true",
        "DocHeadline": "purchase item 123",
        "Comments": "Document comments",
        "IsManualDocCreationsWithParams": "false",
        "IsGeneralClient": "false",
        "IsAutoCreateCustomer": "true",
        // "ReturnUrl":"",
        // "CallBackUrl":"",
        "ReturnUrl": "https://yallafood.co.il/callbackUrl/1/2",
        "CallBackUrl": "https://yallafood.co.il/callbackUrl/1/2",
        "AddToken": "false",
        "AddTokenAndCharge": "false",
        "ChargeWithToken": "false",
        "Refund": "false",
        "IsStandingOrderClearance": "false",
        "StandingOrderDuration": "0"
      }
    };
    try {
      Response response = await dio.post(
        payUrl,
        data: requestBody,
      );


      if (response.statusCode == 200) {
        paymentUrl = response.data["d"]['ClearingRedirectUrl'].toString();
        clearingLogId = response.data["d"]['OpenInfo'][1]["Value"].toString();
        // verifyLoginInvoice4u();

        // Launch the payment URL in the in-app WebView
        if (paymentUrl.isNotEmpty) {
          _webViewController?.loadUrl(urlRequest: URLRequest(url: Uri.parse(paymentUrl)));
        }
      } else {
        // Handle error cases
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('API call failed')));
      }
    } catch (error) {
      // Handle other errors like network issues
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $error')));
    }
  }

  handleShouldOverrideUrlLoading( request) {


    print('payment on processing....1');

    print("requst >>>$request");


    final String newUrl = request.toString();
    bool paymentCompleted = false;


    final String successUrl = 'https://yallafood.co.il/callbackUrl/1/2?success=True';

    if (newUrl == successUrl) {
      verifyLoginInvoice4u();
      // Payment successful, perform necessary actions


      print('payment on processing....2');


      // Optionally, you can close the WebView here if needed
      // _webViewController?.loadUrl(urlRequest: URLRequest(url: Uri.parse('about:blank')));
    } else {
      // Continue loading other URLs
      _webViewController?.loadUrl(urlRequest: request.urlRequest);
    }
  }

  @override
  void initState() {

    print("Total Amount ${widget.total}");
    // TODO: implement initState

    upayMakePayment(amount: widget.total.toString());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Payment Page'),
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: Uri.parse(paymentUrl)),
            // onWebViewCreated: (controller) {
            //   _webViewController = controller;
            // },

            onWebViewCreated: (controller) {
              _webViewController = controller;

              // Enable WebView debugging
              if (controller.android != null) {
                AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
              }
            },
            onLoadStop: (controller, url) {
              print("onLoadStop $url");
              setState(() {
                isLoading = false; // Hide loader when loading stops
              });
            },



            onLoadStart: (controller, url) {

              print("onLoadStart$url");
              handleShouldOverrideUrlLoading(url.toString());
            },

          ),
          isLoading ? Center(child: CircularProgressIndicator(color: Color(0xffA4DC04),)) : Container()
        ],
      ),

    );
  }


}

