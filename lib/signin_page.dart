import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:throwback/contacts_page.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

SharedPreferences prefs;

class SignInPage extends StatefulWidget {
  final String title = 'Login';
  @override
  State<StatefulWidget> createState() => SignInPageState();
}

class SignInPageState extends State<SignInPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        _PhoneSignInSection(Scaffold.of(context)),
      ],
    );
  }

  // Example code for sign out.
  void _signOut() async {
    await _auth.signOut();
    await prefs.remove('id');
  }
}

class _PhoneSignInSection extends StatefulWidget {
  _PhoneSignInSection(this._scaffold);

  final ScaffoldState _scaffold;
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
      widget._scaffold.showSnackBar(const SnackBar(
        content: Text('Please check your phone for the verification code.'),
      ));
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
      Navigator.pushNamed(context, '/chats');
    } else {
      _message = 'Sign in failed'; //todo change to toast 
    }  
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