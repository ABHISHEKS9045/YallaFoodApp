import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants.dart';
import '../../services/FirebaseHelper.dart';

class WallletTopUpScreen extends StatefulWidget {
  const WallletTopUpScreen({super.key, required this.ammount});
  final String ammount;

  @override
  State<WallletTopUpScreen> createState() => _WallletTopUpScreenState();
}

class _WallletTopUpScreenState extends State<WallletTopUpScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  InAppWebViewController? _webViewController;
  String paymentUrl = '';
  String? loginToken;
  String? clearingLogId;
  String paymentType = "";
  String? adminCommissionValue = "", addminCommissionType = "";
  bool? isEnableAdminCommission = false;
  bool isSuccess = false;
  bool isLoading = true;
  Dio dio = Dio();  // Create a Dio instance



  @override
  void initState() {

    print("Total Amount ${widget.ammount}");
    // TODO: implement initState

    upayMakePayment(amount: widget.ammount.toString());

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

  updateWalletAmount(String amount) async {
    await FireStoreUtils.createPaymentId();
    FireStoreUtils.createPaymentId().then((value) {
      final paymentID = value;
      FireStoreUtils.topUpWalletAmount(paymentMethod: "Credit Card", amount: double.parse(amount), id: paymentID).then((value) {
        FireStoreUtils.updateWalletAmount(amount: double.parse(amount)).then((value) {
          //Add Nevigation
          Navigator.pop(context,isSuccess);
          Navigator.pop(context,isSuccess);

        });
      });
    });
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
  getPaymentStatusById() async {

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
        isSuccess = paymentResponse.data['d']['IsSuccess'];

        if (isSuccess == true){
          updateWalletAmount(widget.ammount);
        } else{
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              "Payment Successful!!".tr() + "\n",
            ),
            backgroundColor: Colors.green.shade400,
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




}
