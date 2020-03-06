import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'constants.dart';
import 'router.dart';

class ChatPage extends StatefulWidget {

  final String myId;
  final String peerId;
  final String peerName;

  ChatPage({Key key, @required this.myId, @required this.peerId, @required this.peerName}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController listScrollController = new ScrollController();
  final TextEditingController textEditingController = new TextEditingController();
  final FocusNode focusNode = new FocusNode();

  String chatId;
  var messagesList;
  bool isLoading = false;

  @override
  void initState(){
    super.initState();
    setState(() {
      isLoading = true;
    });
    if (widget.myId.hashCode <= widget.peerId.hashCode) {
      chatId = widget.myId + widget.peerId;
    } else {
      chatId = widget.peerId + widget.myId;
    }
    setState(() {
      isLoading = false;
    });
  }

  Widget buildLoading() {
    return Positioned(
      child: isLoading
          ? Container(
              child: Center(
                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.red)),
              ),
              color: Colors.white.withOpacity(0.8),
            )
          : Container(),
    );
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
              'type': type
            },
        );
    listScrollController.animateTo(0.0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    setState(() {});
    }
  }

  bool newestMessage(int index, bool fromMe){ 
    return (index == 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: new Text(widget.peerName),),
      backgroundColor: Colors.white,
      body:Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              buildMessages(),
              buildInput(),
            ],
          ),
          buildLoading(),
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
          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 1.0),
              child: new IconButton(
                icon: new Icon(Icons.image),
                onPressed: getImage,
                color: Colors.red,
              ),
            ),
            color: Colors.white,
          ),
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
    bool fromMe = document["fromId"] == widget.myId;
    int type = 0;
    if (document.data.containsKey('type')){
      print("type key found");
      type = document['type'];
    }
    if (type == 0){
      return buildTextMessage(document, fromMe, newestMessage(index, fromMe));
    }
    else{
      return buildImageMessage(document, fromMe, newestMessage(index, fromMe));
    }
  }

  Widget buildTextMessage(DocumentSnapshot document, bool rightAlign, bool isLast){
    return Row(
      children: <Widget>[
        Container(
          child: Text(document['content'], style: TextStyle(color:Colors.white)),
          padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
          width: 200.0,
          decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(8.0)),
          margin: EdgeInsets.only(bottom: isLast ?  20.0 : 10.0, right: 10.0), //todo maybe add padding to input instead
        )
      ],
      mainAxisAlignment: rightAlign ? MainAxisAlignment.end : MainAxisAlignment.start,
    );
  }

  Widget buildImageMessage(DocumentSnapshot document, bool rightAlign, bool isLast){
    return Row(
      children: <Widget>[
        Container(
          child: FlatButton(
            child: Material(
              child: CachedNetworkImage(
                placeholder: (context, url) => Container(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                  width: 200.0,
                  height: 200.0,
                  padding: EdgeInsets.all(70.0),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.all(
                      Radius.circular(8.0),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Material(
                  child: Text("Error getting image"),
                  // Image.asset(
                  //   'images/img_not_available.jpeg',
                  //   width: 200.0,
                  //   height: 200.0,
                  //   fit: BoxFit.cover,
                  // ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(8.0),
                  ),
                  clipBehavior: Clip.hardEdge,
                ),
                imageUrl: document['content'],
                width: 200.0,
                height: 200.0,
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
              clipBehavior: Clip.hardEdge,
            ),
            onPressed: () {
              print("Show photo");
              Navigator.pushNamed(context, Routes.picture_chat, arguments: PictureChatArgs(chatId, document['content']));
              // Navigator.push(
              //     context, MaterialPageRoute(builder: (context) => FullPhoto(url: document['content'])));
            },
            padding: EdgeInsets.all(0),
          ),
          margin: EdgeInsets.only(bottom: isLast ?  20.0 : 10.0, right: 10.0), //todo maybe add padding to input instead

        )
      ],
      mainAxisAlignment: rightAlign ? MainAxisAlignment.end : MainAxisAlignment.start,
    );
  }

  Future getImage() async {
    File imageFile = await ImagePicker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    if (imageFile != null) {
      setState(() {
        isLoading = true;
      });
      uploadFile(imageFile);
    }
  }

  Future uploadFile(File imageFile) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putFile(imageFile);
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      setState(() {
        isLoading = false;
        onSendMessage(downloadUrl, 1);
      });
    }, onError: (err) {
      setState(() {
        isLoading = false;
      });
      //Fluttertoast.showToast(msg: 'This file is not an image');
      print("This file is not an image");
    });
  }

}