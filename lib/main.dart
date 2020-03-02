import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:throwback/contacts_page.dart';
import 'chat_page.dart';
import 'signin_page.dart';
import 'router.dart';
import 'constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = GoogleSignIn();

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Helvetica',
      ),
      onGenerateRoute: (RouteSettings settings) {
      switch (settings.name){
        case login:
          return MaterialPageRoute( builder: (context) => SignInPage());
          break;
        case chats:
          return MaterialPageRoute(builder: (context) => ContactsPage());
          break;
        };
      },
      home: Scaffold(
        appBar: AppBar(title: Text("Throwback"),),
        body: Center(
          child: FutureBuilder<bool> (
            future: _googleSignIn.isSignedIn(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData){
                print("Shapshot data:");
                print(snapshot.data);
                if (snapshot.data){
                  return ContactsPage();
                }
                return SignInPage();
              } else {
                return new CircularProgressIndicator();
              }
            },
          )
        ,)
      ,)
    );
  }
}

void main(){
  // Check if user is logged in with google 

  // If they are, show homepage, else go to login

  runApp(MyApp());
}
