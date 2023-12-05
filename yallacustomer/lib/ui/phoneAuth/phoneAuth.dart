import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:foodie_customer/services/helper.dart';
import 'package:foodie_customer/ui/wallet/walletScreen.dart';



//
// class PhoneAuthPage extends StatefulWidget {
//   @override
//   _PhoneAuthPageState createState() => _PhoneAuthPageState();
// }
//
// class _PhoneAuthPageState extends State<PhoneAuthPage> {
//   final TextEditingController _firstNameController = TextEditingController();
//   final TextEditingController _lastNameController = TextEditingController();
//   final TextEditingController _phoneNumberController = TextEditingController();
//   final TextEditingController otp = TextEditingController();
//
//   FirebaseAuth _auth = FirebaseAuth.instance;
//   String _verificationId = '';
//
//   void _sendCode() async {
//     String phoneNumber = "+91${_phoneNumberController.text}"; // Replace with the actual phone number
//     await _auth.verifyPhoneNumber(
//       phoneNumber: phoneNumber,
//       verificationCompleted: (PhoneAuthCredential credential) async {
//         await _auth.signInWithCredential(credential);
//         print('Verification completed automatically');
//       },
//       verificationFailed: (FirebaseAuthException e) {
//         print('Verification failed: ${e.message}');
//       },
//       codeSent: (String verificationId, int? resendToken) {
//         print('Verification code sent');
//         setState(() {
//           _verificationId = verificationId;
//         });
//       },
//       codeAutoRetrievalTimeout: (String verificationId) {
//         print('Code auto retrieval timeout');
//         setState(() {
//           _verificationId = verificationId;
//         });
//       },
//       timeout: Duration(seconds: 120),
//     );
//   }
//
//   void _signInWithCode(String code) async {
//     try {
//       PhoneAuthCredential credential = PhoneAuthProvider.credential(
//         verificationId: _verificationId,
//         smsCode: code,
//       );
//       await _auth.signInWithCredential(credential);
//       push(context, WalletScreen());
//     } catch (e) {
//       print('Error signing in with code: $e');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Firebase Phone Auth'),
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _firstNameController,
//               decoration: InputDecoration(labelText: 'First Name'),
//             ),
//             TextField(
//               controller: _lastNameController,
//               decoration: InputDecoration(labelText: 'Last Name'),
//             ),
//             TextField(
//               controller: _phoneNumberController,
//               decoration: InputDecoration(labelText: 'Phone Number'),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _sendCode,
//               child: Text('Send Code'),
//             ),
//             SizedBox(height: 20),
//             Visibility(
//               visible: _verificationId.isNotEmpty,
//               child: Column(
//                 children: [
//                   TextField(
//                     controller: otp,
//                     onChanged: (value) => _signInWithCode(value),
//                     decoration: InputDecoration(labelText: 'Enter Code'),
//                   ),
//                   SizedBox(height: 20),
//                   ElevatedButton(
//                     onPressed: () => _signInWithCode(otp.text), // Replace with actual code
//                     child: Text('Sign In with Code'),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }






// }
//
//


class PhoneAuthPage extends StatefulWidget {
  @override
  _PhoneAuthPageState createState() => _PhoneAuthPageState();
}

class _PhoneAuthPageState extends State<PhoneAuthPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController otp = TextEditingController();

  FirebaseAuth _auth = FirebaseAuth.instance;
  String _verificationId = '';

  void _sendCode() async {
    String phoneNumber = "+91${_phoneNumberController.text}"; // Replace with the actual phone number
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        print('Verification completed automatically');
        // After successful verification, you can call your sign-up function here
        await _signUp();
      },
      verificationFailed: (FirebaseAuthException e) {
        print('Verification failed: ${e.message}');
      },
      codeSent: (String verificationId, int? resendToken) {
        print('Verification code sent');
        setState(() {
          _verificationId = verificationId;
        });
        print("Verification: >>>>$_verificationId");
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        print('Code auto retrieval timeout');
        setState(() {
          _verificationId = verificationId;
        });
      },
      timeout: Duration(minutes: 2),
    );
  }

  void _signInWithCode(String code) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: code,
      );
      await _auth.signInWithCredential(credential);
      push(context, WalletScreen());
    } catch (e) {
      print('Error signing in with code: $e');
    }
  }

  Future<void> _signUp() async {
    try {
      User? user = _auth.currentUser;

      if (user != null) {
        // Get the user's UID and other details
        String uid = user.uid;
        String firstName = _firstNameController.text;
        String lastName = _lastNameController.text;
        String phoneNumber = _phoneNumberController.text;

        // Implement your sign-up logic here, e.g., store user details in Firebase Firestore
        // Firestore.instance.collection('users').doc(uid).set({
        //   'firstName': firstName,
        //   'lastName': lastName,
        //   'phoneNumber': phoneNumber,
        // });

        // Navigate to the next screen (WalletScreen in this case)
        push(context, WalletScreen());
      }
    } catch (e) {
      print('Error signing up: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firebase Phone Auth'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _firstNameController,
              decoration: InputDecoration(labelText: 'First Name'),
            ),
            TextField(
              controller: _lastNameController,
              decoration: InputDecoration(labelText: 'Last Name'),
            ),
            TextField(
              controller: _phoneNumberController,
              decoration: InputDecoration(labelText: 'Phone Number'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendCode,
              child: Text('Send Code'),
            ),
            SizedBox(height: 20),
            Visibility(
              visible: _verificationId.isNotEmpty,
              child: Column(
                children: [
                  TextField(
                    controller: otp,
                    onChanged: (value) => _signInWithCode(value),
                    decoration: InputDecoration(labelText: 'Enter Code'),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _signInWithCode(otp.text),
                    child: Text('Sign In with Code'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
