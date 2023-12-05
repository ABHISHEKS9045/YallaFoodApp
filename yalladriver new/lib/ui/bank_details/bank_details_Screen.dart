import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:foodie_driver/constants.dart';
import 'package:foodie_driver/main.dart';
import 'package:foodie_driver/model/User.dart';
import 'package:foodie_driver/services/FirebaseHelper.dart';
import 'package:foodie_driver/services/helper.dart';
import 'package:foodie_driver/ui/bank_details/enter_bank_details_screen.dart';

class BankDetailsScreen extends StatefulWidget {
  const BankDetailsScreen({Key? key}) : super(key: key);

  @override
  State<BankDetailsScreen> createState() => _BankDetailsScreenState();
}

class _BankDetailsScreenState extends State<BankDetailsScreen> {
  UserBankDetails? userBankDetails;
  bool isBankDetailsAdded = false;

  void initState() {
    userBankDetails = MyAppState.currentUser!.userBankDetails;
    isBankDetailsAdded = userBankDetails!.accountNumber.isNotEmpty;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: isDarkMode(context) ? Color(DARK_VIEWBG_COLOR) : Colors.white,
        body: isBankDetailsAdded ? showBankDetails() : addBankDetail(context));
  }

  showBankDetails() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SizedBox(
        height: 480,
        child: Card(
          color: isDarkMode(context) ? Color(DARK_CARD_BG_COLOR) : Colors.white,
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  buildDetails(
                    title: "Bank Name".tr(),
                    icon: Icons.account_balance,
                    value: userBankDetails!.bankName,
                  ),
                  buildDetails(
                    title: "Branch Name".tr(),
                    icon: Icons.account_balance,
                    value: userBankDetails!.branchName,
                  ),
                  buildDetails(
                    title: "Holder Name".tr(),
                    icon: Icons.person,
                    value: userBankDetails!.holderName,
                  ),
                  buildDetails(
                    title: "Account Number".tr(),
                    icon: Icons.credit_card,
                    value: userBankDetails!.accountNumber,
                  ),
                  buildDetails(
                    title: "Other Information".tr(),
                    icon: Icons.info_rounded,
                    value: userBankDetails!.otherDetails,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 45.0,
                    ),
                    child: buildButton(
                      context,
                      title: "EDIT BANK".tr(),
                      onPress: () => enterEditBankDetails(isNewAccount: false),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  enterEditBankDetails({bool isNewAccount = true}) async {
    var result = await Navigator.of(context).push(new MaterialPageRoute(
        builder: (context) => EnterBankDetailScreen(
              isNewAccount: isNewAccount,
            )));
    print("--->" + result.toString());
    if (result) {
      User? user = await FireStoreUtils.getCurrentUser(MyAppState.currentUser!.userID);
      setState(() {
        MyAppState.currentUser = user;
        userBankDetails = MyAppState.currentUser!.userBankDetails;
        print(MyAppState.currentUser!.userBankDetails.bankName);
        isBankDetailsAdded = true;
      });
    }
  }

  addBankDetail(context) {
    final size = MediaQuery.of(context).size;
    return Container(
      height: size.height,
      width: size.width,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 0),
              child: Image.asset(
                "assets/images/add_bank_image.png",
                height: size.height * 0.48,
                width: size.height * 0.35,
                fit: BoxFit.contain,
              ),
            ),
            Opacity(
              opacity: 0.7,
              child: Text(
                "notAddedBankAddBank".tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 45.0, bottom: 25),
              child: buildButton(
                context,
                title: "ADD BANK".tr(),
                onPress: () => enterEditBankDetails(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  buildDetails({required String title, required IconData icon, required String value}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 18,
              ),
              SizedBox(
                width: 10,
              ),
              Opacity(
                opacity: 0.7,
                child: Text(
                  title,
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 28.0, top: 4),
            child: Text(
              value,
              style: TextStyle(fontSize: 18),
            ),
          )
        ],
      ),
    );
  }

  buildButton(context, {required String title, required Function()? onPress}) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width * 0.8,
      child: MaterialButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        color: Color(0xFF00B761),
        height: 45,
        onPressed: onPress,
        child: Text(
          title,
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}
