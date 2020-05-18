import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ApiModel extends Model {

  bool authenticating = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignIn _googleSignIn = new GoogleSignIn();
  
  Firestore _db = Firestore.instance;

  FirebaseUser _user; 
  FirebaseUser get user => _user;

  // StreamSubscription auth_sub;

  ApiModel(){
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account){
      if (account != null) {
        _signInFirebaseAuth(account);
      } 
      else {
        _user = null;
      }
    });

    _auth.onAuthStateChanged.listen((FirebaseUser user) { 
      _user = user;
      if (_user != null) {
        _registerFirebase(); //TODO move to cloud functions or something
      }
      notifyListeners();
    });
  }

  bool isLoggedIn() {
    return _user != null;
  }

  Future<bool> signInWithGoogle() async {
    final GoogleSignInAccount user = await _googleSignIn.signIn();

    if (user == null) {

      // User could not be signed in
      print('User could not be signed in.');
      return false;
    }

    print('User signed in.');
    return true;
  }

  Future<void> signInSilently() async {

    final GoogleSignInAccount user = await _googleSignIn.signInSilently(suppressErrors: true);

    if (_user == null) {
      // User could not be signed in
      print("Issue signing in silently");
      return;
    }
    print(_user);
    print('User signed in silently.');
  }

  Future<void> signOut() async {
    // _user = null;
    await _googleSignIn.signOut();  //   await _googleSignIn.disconnect();
    await _auth.signOut();
  }

  Future<void> _signInFirebaseAuth(GoogleSignInAccount account) async {
    // TODO logout handling
    if (await _auth.currentUser() == null){
      // final GoogleSignInAccount account = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth = await account.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
    }
  }

  void _registerFirebase(){
    if (_user != null) {
      Firestore.instance.collection('users').document(_user.uid).setData({
        'name': _user.displayName,
        'email': _user.email,
        'email_lower': _user.email.toLowerCase()
      }, merge: true);
    } else {
      print("Error registering user");
    }
  }

  Stream<QuerySnapshot> getContacts(){
    return _db.collection('users').document(_user.uid).collection("friends").limit(20).snapshots();
  }


  Future<bool> addFriend(String email) async {
    // TODO function to find person, return result, click to confirm
    return Firestore
      .instance
      .collection('users')
      .where('email_lower', isEqualTo: email.toLowerCase())
      .getDocuments()
      .then(
        (value) {
          if (value.documents.isNotEmpty){
            String friendId = value.documents[0].documentID;
            dynamic data = value.documents[0].data;
            print(friendId);
            print(data);

            // TODO maybe change
            return Firestore.instance.collection('users').document(_user.uid).collection('friends').document(friendId).setData(data).then(
              (value) => true, 
              onError: (error, stackTrace) {
                print(error);
                print(stackTrace);
                return false;
              });
          }
          else {
            return false;
          }
        }
      );
  }
}