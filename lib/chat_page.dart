import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

// List<MessageModel> messages = [
//   MessageModel("Hello", DateTime.now()),
//   MessageModel("Hi", DateTime.now()),
//   MessageModel("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.", DateTime.now()),
//   MessageModel("Test text", DateTime.now())
// ];

class ChatPage extends StatefulWidget {

  final String myId;
  final String peerId;

  ChatPage({Key key, @required this.myId, @required this.peerId}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController listScrollController = new ScrollController();
  final TextEditingController textEditingController = new TextEditingController();
  final FocusNode focusNode = new FocusNode();

  String chatId;
  var messagesList;

  @override
  void initState(){
    super.initState();

    if (widget.myId.hashCode <= widget.peerId.hashCode) {
      chatId = widget.myId + widget.peerId;
    } else {
      chatId = widget.peerId + widget.myId;
    }
  }

  void onSendMessage(String content, int type) {
    if (content.trim() != ''){
      textEditingController.clear();
    
     Firestore.instance
     .collection('messages')
     .document(chatId)
     .collection(chatId)
     .add(
          {
            'fromId': widget.myId,
            'toId': widget.peerId,
            'timestamp': DateTime.now(),
            'content': content,
          },
      );
    listScrollController.animateTo(0.0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    setState(() {});
    }
  }

  bool newestMessageLeft(int index){ 
    return (index == 0);
  }

  bool newestMessageRight(int index){ 
    return (index == 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: new Text("TODO Change this"),),
      backgroundColor: Colors.white,
      body:Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              buildMessages(),
              buildInput(),
            ],
          )
        ],
      ),
    );
  }

  Widget buildMessages(){
    return Flexible(
      child: StreamBuilder(
        stream: Firestore.instance
          .collection("messages")
          .document(chatId)
          .collection(chatId)
          .orderBy('timestamp', descending: true)
          .limit(20).snapshots(), 
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.red)));
          } else if (snapshot.hasError){
            return new Text('Error: ${snapshot.error}');
          } else {
            messagesList = snapshot.data.documents;
            return ListView.builder(
              padding: EdgeInsets.all(10.0),
              itemBuilder: (context, index) => buildMessage(index, snapshot.data.documents[index]),
              itemCount: snapshot.data.documents.length,
              reverse: true,
              controller: listScrollController,
            );
          }
        }
      )
    );
  }

  
  Widget buildInput(){
    return Container(
      child: Row(
        children: <Widget>[
          Flexible(
              child: Container(
                child: TextField(
                  style: TextStyle(color: Colors.red, fontSize: 15.0),
                  controller: textEditingController,
                  decoration: InputDecoration.collapsed(
                    hintText: 'Type your message...',
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                  focusNode: focusNode,
                ),
              ),
            ),
          Material(
            child: new Container(
              margin: EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                icon: new Icon(Icons.send),
                color: Colors.red,
                onPressed: () => onSendMessage(textEditingController.text, 0),
              ),
            )
          )
        ],
        ),
    );
  }

  Widget buildMessage(index, DocumentSnapshot document){
    if (document["fromId"] == widget.myId){
      // right
      return Row(
        children: <Widget>[
          Container(
            child: Text(document['content'], style: TextStyle(color:Colors.white)),
            padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
            width: 200.0,
            decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(8.0)),
            margin: EdgeInsets.only(bottom: newestMessageRight(index) ?  20.0 : 10.0, right: 10.0),
          )
        ],  
        mainAxisAlignment: MainAxisAlignment.end,
      );
    } else {
      // left
      return Row(
        children: <Widget>[
          Container(
            child: Text(document['content'], style: TextStyle(color:Colors.white)),
            padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
            width: 200.0,
            decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(8.0)),
            margin: EdgeInsets.only(bottom: newestMessageLeft(index) ? 20.0 : 10.0, left: 10.0),
          )
        ],  
      );
    }
  }
}