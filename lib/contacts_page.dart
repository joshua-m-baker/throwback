import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'constants.dart';
import 'router.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class ContactsPage extends StatefulWidget {
  //final String userId = "3AV0WFSo0OfRDW5HmEdXrSVKxAZ2";
  final FirebaseUser user;

  ContactsPage({Key key, @required this.user}) : super(key: key);

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactsPage> {

  var contactsList;

  @override
  Widget build(BuildContext context){
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

  void _signOut() async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, Routes.root);
  }

  Widget buildContactsList(){
    return Column(
      children: <Widget>[
        Flexible( 
          child: StreamBuilder(
            //stream: Firestore.instance.collection('users').document(widget.user.uid).collection("contacts").limit(20).snapshots(), //delete this path
            stream: Firestore.instance.collection('users').document(widget.user.uid).collection("friends").limit(20).snapshots(),
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
                          arguments: ChatArgs(widget.user.uid, contactsList[index].documentID)
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
                          Firestore.instance.collection('users').document(widget.user.uid).collection('friends').document(friendId).setData(data).then(
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