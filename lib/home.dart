import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'constants.dart';
import 'router.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = GoogleSignIn();

class HomePage extends StatefulWidget {
  //final String userId = "3AV0WFSo0OfRDW5HmEdXrSVKxAZ2";
  //final FirebaseUser user;

  @override
  _HomePageState createState() => _HomePageState();
}

// https://github.com/mdanics/fluttergram/blob/master/lib/main.dart
class _HomePageState extends State<HomePage> {

  var contactsList;
  FirebaseUser firebaseUser;
  bool triedSilentLogin = false;
  bool authLoading = true;

  void silentLogin() async {
    await _login(context, false);
    setState(() {
      triedSilentLogin = true;
    });
  }

  void login() async {
    await _login(context, true);
    setState(() {
      triedSilentLogin = true;
    });
  }

  Future<Null> _login(BuildContext context, bool promptLogin) async {
    authLoading = true;
    if (_googleSignIn.currentUser == null) {
      // _googleSignIn.isSignedIn()
      await _googleSignIn.signInSilently().catchError((_){});
    }

    if (promptLogin && _googleSignIn.currentUser == null) {
      await _googleSignIn.signIn();
    }

    if (await _auth.currentUser() == null) {

      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
    }

    firebaseUser = await _auth.currentUser();
    authenticationSuccessful(firebaseUser);
    authLoading = false;
  }

  void authenticationSuccessful(FirebaseUser user){
    if (user != null) {
      Firestore.instance.collection('users').document(user.uid).setData({
        'name': 'DisplayName',
        'uid': user.uid
      }, merge: true);
    } else {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text("Error Authenticating user"),
      ));
    }
  }  
  
  Scaffold buildLoginPage() {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 240.0),
          child: authLoading ? CircularProgressIndicator() : Column(
            children: <Widget>[
              Text(
                'Throwback',
                style: TextStyle(
                    fontSize: 60.0,
                    fontFamily: "Billabong",
                    color: Colors.black),
              ),
              Padding(padding: const EdgeInsets.only(bottom: 100.0)),
              GestureDetector(
                onTap: login,
                child: Icon(Icons.computer, size: 225.0)
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context){

    if (triedSilentLogin == false) {
      silentLogin();
    }

    // if (setupNotifications == false && currentUserModel != null) {
    //   setUpNotifications();
    // }

    return (firebaseUser == null) // || currentUserModel == null)
      ? buildLoginPage()
      : buildChats();
  }

  void _signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    Navigator.pushReplacementNamed(context, Routes.root);
  }

  Widget buildChats(){
    return Scaffold(
        appBar: AppBar(
          title: Text("Contacts"),
          actions: <Widget>[
            Builder(builder: (BuildContext context) {
              return FlatButton(
                child: const Text('Sign out'),
                textColor: Theme.of(context).buttonColor,
                onPressed: () async {
                  final FirebaseUser user = await _auth.currentUser();
                  if (user == null) {
                    Scaffold.of(context).showSnackBar(const SnackBar(
                      content: Text('No one has signed in.'),
                    ));
                    return;
                  }
                  _signOut();
                  final String uid = user.uid;
                  Scaffold.of(context).showSnackBar(SnackBar(
                    content: Text(uid + ' has successfully signed out.'),
                  ));
                },
              );
              }
            )
          ],
        ),
        body: buildContactsList(),
        floatingActionButton: FloatingActionButton(
          onPressed:_newChat,
          child: Icon(Icons.add),
        ),
      );
  }

  Widget buildContactsList(){
    return Column(
      children: <Widget>[
        Flexible( 
          child: StreamBuilder(
            //stream: Firestore.instance.collection('users').document(widget.user.uid).collection("contacts").limit(20).snapshots(), //delete this path
            stream: Firestore.instance.collection('users').document(firebaseUser.uid).collection("friends").limit(20).snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return Center(
                    child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.red)));
              } else if (snapshot.hasError){
                return new Text('Error: ${snapshot.error}');
              } else {
                contactsList = snapshot.data.documents;
                return ListView.builder(
                  padding: EdgeInsets.all(10.0),
                  itemCount: contactsList.length,
                  itemBuilder: (BuildContext context, int index){
                    return ListTile(
                      title: Text(contactsList[index]["name"]),
                      onTap: () { 
                        Navigator.pushNamed(
                          context, 
                          Routes.chat_page,
                          arguments: ChatArgs(firebaseUser.uid, contactsList[index].documentID, contactsList[index]['name'])
                        );
                      },
                    );
                  }
                );
              }
            }
          )
        )
      ],
    );
  }

  void _newChat() async{
    TextEditingController _dialogTextController = TextEditingController();
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Search for users'),
            content: TextField(
              controller: _dialogTextController,
              decoration: InputDecoration(hintText: "Phone Number"),
              keyboardType: TextInputType.number
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                child: new Text('Add'),
                onPressed: () {
                  //Firestore.instance.collection('users').document(widget.user.uid).collection('friends').document()
                  Firestore
                    .instance
                    .collection('users')
                    .where('number', isEqualTo: _dialogTextController.text)
                    .getDocuments()
                    .then(
                      (value) {
                        if (value.documents.isNotEmpty){
                          // Add new friend
                          // todo move to add function
                          String friendId = value.documents[0].documentID;
                          dynamic data = value.documents[0].data;
                          print(friendId);
                          print(data);
                          Firestore.instance.collection('users').document(firebaseUser.uid).collection('friends').document(friendId).setData(data).then(
                            (_){
                              Navigator.of(context).pop();
                            }
                          );
                        }
                      }
                    );
                },
              )
            ],
          );
        }
    );
  }
}