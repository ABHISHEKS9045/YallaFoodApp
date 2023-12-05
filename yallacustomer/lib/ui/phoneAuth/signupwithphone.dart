import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';



class SignUpPhone extends StatefulWidget {
  @override
  _SignUpPhoneState createState() => _SignUpPhoneState();
}

class _SignUpPhoneState extends State<SignUpPhone> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  FirebaseAuth _auth = FirebaseAuth.instance;
  String _verificationId = '';

  void _sendCode() async {
    String phoneNumber = "+91${_phoneNumberController.text.trim()}";
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        print('Verification completed automatically');
      },
      verificationFailed: (FirebaseAuthException e) {
        print('Verification failed: ${e.message}');
      },
      codeSent: (String verificationId, int? resendToken) {
        print('Verification code sent');
        setState(() {
          _verificationId = verificationId;
        });
        // Navigate to the OTP entry section
        _navigateToOtpEntry();
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        print('Code auto retrieval timeout');
        setState(() {
          _verificationId = verificationId;
        });
      },
      timeout: Duration(seconds: 60),
    );
  }

  void _signUpWithCode(String code) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: code,
      );
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      print('Signed up with code');
      // Extract user data and perform signup process
      String firstName = _firstNameController.text.trim();
      String lastName = _lastNameController.text.trim();
      String phoneNumber = _phoneNumberController.text.trim();
      String uid = userCredential.user!.uid;
      // Perform your signup logic here
      print('User signed up: $firstName $lastName, Phone: $phoneNumber, UID: $uid');
    } catch (e) {
      print('Error signing up with code: $e');
    }
  }

  void _navigateToOtpEntry() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OtpEntryPage(
          onOtpEntered: _signUpWithCode,
        ),
      ),
    );
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
          ],
        ),
      ),
    );
  }
}

class OtpEntryPage extends StatelessWidget {
  final Function(String) onOtpEntered;

  const OtpEntryPage({required this.onOtpEntered});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter OTP'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              onChanged: onOtpEntered,
              decoration: InputDecoration(labelText: 'Enter OTP'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => onOtpEntered('123456'), // Replace with actual code
              child: Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
