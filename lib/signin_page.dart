import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:shared_preferences/shared_preferences.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class SignInPage extends StatefulWidget {
  final String title = 'Login';
  @override
  State<StatefulWidget> createState() => SignInPageState();
}

class SignInPageState extends State<SignInPage> {

  bool loading = true;
  FirebaseUser user;

  @override
  void initState() {
    super.initState();
    alreadySignedIn();
  }

  void alreadySignedIn() async {
    user = await _auth.currentUser();

    if (user != null){
      Navigator.pushReplacementNamed(context, '/chats', arguments: user);
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return loading ? CircularProgressIndicator() : 
    
    Scaffold(
      body:Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _PhoneSignInSection(),
        ],
      )
    );
  }
}

class _PhoneSignInSection extends StatefulWidget {
  _PhoneSignInSection();

  @override
  State<StatefulWidget> createState() => _PhoneSignInSectionState();
}

class _PhoneSignInSectionState extends State<_PhoneSignInSection> {
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _smsController = TextEditingController();

  String _message = '';
  String _verificationId;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          alignment: Alignment.center,
          width: 2 * MediaQuery.of(context).size.width/3,
          child: TextFormField(
            controller: _phoneNumberController,
            decoration: const InputDecoration(
                labelText: 'Phone number (+x xxx-xxx-xxxx)'),
            validator: (String value) {
              if (value.isEmpty) {
                return 'Phone number (+x xxx-xxx-xxxx)';
              }
              return null;
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          alignment: Alignment.center,
          child: RaisedButton(
            onPressed: () async {
              _verifyPhoneNumber();
            },
            child: const Text('Go'),
          ),
        ),
      ]
    );
  }

  // Example code of how to verify phone number
  void _verifyPhoneNumber() async {
    setState(() {
      _message = '';
    });
    final PhoneVerificationCompleted verificationCompleted =
        (AuthCredential phoneAuthCredential) {
      _auth.signInWithCredential(phoneAuthCredential).then((AuthResult value) => {
        authenticationSuccessful(value.user)
      });

      setState(() {
        
      });
    };

    final PhoneVerificationFailed verificationFailed =
        (AuthException authException) {
      setState(() {
        _message =
            'Phone number verification failed. Code: ${authException.code}. Message: ${authException.message}';
      });
    };

    final PhoneCodeSent codeSent =
        (String verificationId, [int forceResendingToken]) async {
      // widget._scaffold.showSnackBar(const SnackBar(
      //   content: Text('Please check your phone for the verification code.'),
      // ));
      print('Please check your phone for the verification code.');
      _verificationId = verificationId;
    };

    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      _verificationId = verificationId;
    };

    await _auth.verifyPhoneNumber(
        phoneNumber: _phoneNumberController.text,
        timeout: const Duration(seconds: 5),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout
      );
  }

  // Example code of how to sign in with phone.
  void _signInWithPhoneNumber() async {
    final AuthCredential credential = PhoneAuthProvider.getCredential(
      verificationId: _verificationId,
      smsCode: _smsController.text,
    );
    
    final FirebaseUser user =
        (await _auth.signInWithCredential(credential)).user;
    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);
    authenticationSuccessful(user);
  }

  void authenticationSuccessful(FirebaseUser user){
    if (user != null) {
      Firestore.instance.collection('users').document(user.uid).setData({
        'number': _smsController.text,
        'name': 'DisplayName'
      }, merge: true);
      Navigator.pushReplacementNamed(context, '/chats', arguments: user);
    } else {
      _message = 'Sign in failed'; //todo change to toast 
    }  
  }

  void registerNewUser(String name, String number){

  }
}

// Verification Code
// Container(
//           padding: const EdgeInsets.symmetric(vertical: 16.0),
//           alignment: Alignment.center,
//           child: RaisedButton(
//             onPressed: () async {
//               _verifyPhoneNumber();
//             },
//             child: const Text('Verify phone number'),
//           ),
//         ),
//         TextField(
//           controller: _smsController,
//           decoration: const InputDecoration(labelText: 'Verification code'),
//         ),
//         Container(
//           padding: const EdgeInsets.symmetric(vertical: 16.0),
//           alignment: Alignment.center,
//           child: RaisedButton(
//             onPressed: () async {
//               _signInWithPhoneNumber();
//             },
//             child: const Text('Sign in with phone number'),
//           ),
//         ),
//         Container(
//           alignment: Alignment.center,
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           child: Text(
//             _message,
//             style: TextStyle(color: Colors.red),
//           ),
//         )