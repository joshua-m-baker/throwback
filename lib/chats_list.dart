import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:throwback/auth_model.dart';
import 'router.dart';

class ChatsListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<ApiModel>(
      builder: (BuildContext context, Widget child, ApiModel apiModel) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text("Contacts"),
            actions: <Widget>[
              Builder(builder: (BuildContext context) {
                return FlatButton(
                  child: const Text('Sign out'),
                  textColor: Theme.of(context).buttonColor,
                  onPressed: () async {

                    if (apiModel.user == null) {
                      Scaffold.of(context).showSnackBar(const SnackBar(
                        content: Text('No one has signed in.'),
                      ));
                      return;
                    }
                    print("Signing out");
                    apiModel.signOut();
                    Navigator.of(context).pushReplacementNamed(Routes.root);
                  },
                );
                }
              )
            ],
          ),
          body: apiModel.isLoggedIn() ? _buildContactsList() : Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.red))),
          floatingActionButton: FloatingActionButton(
            onPressed:(){
              _newChat(context, apiModel);
            }, //_newChat,
            child: Icon(Icons.add),
          ),
        );
      }
    );
  }

  Widget _buildContactsList() {
    return ScopedModelDescendant<ApiModel>(
      builder: (BuildContext context, Widget child, ApiModel apiModel) {
        return Column(
          children: <Widget>[
            Flexible( 
              child: StreamBuilder(
                //stream: Firestore.instance.collection('users').document(widget.user.uid).collection("contacts").limit(20).snapshots(), //delete this path
                stream: apiModel.getContacts(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                        child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.red)));
                  } else if (snapshot.connectionState == ConnectionState.none) { 
                    return new Text("Connection state none");
                  } else if (snapshot.connectionState == ConnectionState.done || snapshot.connectionState == ConnectionState.active) {
                    if (!apiModel.isLoggedIn()){
                      return Center(
                        child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.red)));
                    }
                    var contactsList = snapshot.data.documents;
                    return ListView.builder(
                      padding: EdgeInsets.all(10.0),
                      itemCount: contactsList.length,
                      itemBuilder: (BuildContext context, int index){
                        return ListTile(
                          title: Text(contactsList[index]["name"]),
                          onTap: () { 
                            // Navigator.pushNamed(
                            //   context, 
                            //   Routes.chat_page,
                            //   arguments: ChatArgs(apiModel.user.uid, contactsList[index].documentID, contactsList[index]['name'])
                            // );
                          },
                        );
                      }
                    );
                  }
                  else {
                    return new Text('Error: Something went wrong');
                  } 
                }
              )
            )
          ],
        );
      }
    );
  }

  void _newChat(BuildContext context, ApiModel apiModel) async{
    TextEditingController _dialogTextController = TextEditingController();
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Search for users'),
            content: TextField(
              controller: _dialogTextController,
              decoration: InputDecoration(hintText: "Email"),
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
                  apiModel.addFriend(_dialogTextController.text.trim()).then((value) {
                    print(value);
                    Navigator.of(context).pop();
                  });
                },
              )
            ],
          );
        }
    );
  }

}