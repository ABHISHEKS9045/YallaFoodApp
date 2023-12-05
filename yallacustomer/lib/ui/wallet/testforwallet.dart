import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../services/FirebaseHelper.dart';

class WalletTest extends StatefulWidget {
  const WalletTest({super.key});

  @override
  State<WalletTest> createState() => _WalletTestState();
}

class _WalletTestState extends State<WalletTest> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Successful"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onTap: () async {
              await FireStoreUtils.createPaymentId();
              FireStoreUtils.createPaymentId().then((value) {
                final paymentID = value;
                FireStoreUtils.topUpWalletAmount(paymentMethod: "Credit Card", amount: '1', id: paymentID).then((value) {
                  FireStoreUtils.updateWalletAmount(amount: double.parse('1')).then((value) {
                    //Add Nevigation
                    Navigator.pop(context,true);
                    Navigator.pop(context,true);
                  });
                });
              });
            },
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: Color(COLOR_PRIMARY),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                  child: Text(
                    "CONTINUE",
                    style: TextStyle(color: Colors.white),
                  )),
            ),
          ),
        ],
      ),
    );
  }
}
