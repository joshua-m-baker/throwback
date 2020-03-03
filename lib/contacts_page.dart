import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'chat_page.dart';


class ContactsPage extends StatefulWidget {
  final String userId = "3AV0WFSo0OfRDW5HmEdXrSVKxAZ2";
  ContactsPage({Key key}) : super(key: key);

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactsPage> {

  var contactsList;

  @override
  Widget build(BuildContext context){
    return Scaffold(body: buildContactsList(),);
  }

  Widget buildContactsList(){
    return Column(
      children: <Widget>[
        Flexible( 
          child: StreamBuilder(
            stream: Firestore.instance.collection('contacts').document(widget.userId).collection(widget.userId).limit(20).snapshots(),
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
                      title: Text(contactsList[index]["displayName"]),
                      onTap: () {
                        Navigator.push(
                          context, 
                          MaterialPageRoute(
                            builder: (context) => ChatPage(myId: widget.userId, peerId: contactsList[index]['peer'],),
                          ),
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
}