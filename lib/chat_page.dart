import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:throwback/picture_chat.dart';

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
  bool _isSendingMessage = false;
  StorageUploadTask _uploadTask;

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

  void onSendMessage(String image_url, String title, String description) {
    if (image_url.trim() != ''){
      //textEditingController.clear();
    
     Firestore.instance
      .collection('picture_chats') //messages
      .document(chatId)
      .collection(chatId)
      .add(
          {
            'fromId': widget.myId,
            'toId': widget.peerId,
            'timestamp': DateTime.now().toUtc().millisecondsSinceEpoch,
            'url': image_url,
            'title': title,
            'description': description
          },
        );
    listScrollController.animateTo(0.0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    setState(() {
      _isSendingMessage = false;
    });
    }
  }

  bool newestMessage(int index){ 
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
              // buildInput(),
            ],
          ),
          buildLoading(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createNewMessage,
        child: Icon(Icons.add_photo_alternate),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[IconButton(icon: Icon(Icons.camera_alt),)],
        ),
        color: Colors.blueGrey
      ),
    );
  }

  Widget buildMessages(){
    return Flexible(
      child: StreamBuilder(
        stream: Firestore.instance
          .collection("picture_chats")
          .document(chatId)
          .collection(chatId)
          .orderBy('timestamp', descending: true)
          .limit(5).snapshots(), 
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

  Widget buildMessage(index, DocumentSnapshot document){
    PictureChatMessage message = PictureChatMessage(
      document['messageId'], 
      document['fromId'], 
      document['toId'], 
      document['timestamp'], 
      document['url'], 
      document['title'], 
      document['description']
    );
    return Row(
      children: <Widget>[
        Container(
          child: FlatButton(
            child: Material(
              child: Hero(child: 
                CachedNetworkImage(
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
                  imageUrl: document['url'],
                  width: 300.0, //mediaquery for screenwidth
                  height: 300.0,
                  fit: BoxFit.cover,
                ),
                tag: document['url']
              ),

              borderRadius: BorderRadius.all(Radius.circular(8.0)),
              clipBehavior: Clip.hardEdge,
            ),
            onPressed: () {
              Navigator.pushNamed(context, Routes.picture_chat, arguments: PictureChatArgs(message));
            },
            padding: EdgeInsets.all(0),
          ),
          margin: EdgeInsets.only(bottom: newestMessage(index) ? 20.0 : 10.0, right: 10.0), //todo maybe add padding to input instead

        )
      ],
      mainAxisAlignment: message.fromId == widget.myId ? MainAxisAlignment.end : MainAxisAlignment.start,
    );
  }

  

  Future createNewMessage() async {
    File imageFile = await ImagePicker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (imageFile != null) {
      _showSendDialog(imageFile);
    }
  }

  void _showSendDialog(File image) {
    TextEditingController _titleController = TextEditingController();
    TextEditingController _descriptionController = TextEditingController();
    showDialog(
      context: context,
      builder: (context){
        return AlertDialog( //TODO wrap in will pop
          actions: <Widget>[
            FlatButton(child: Text("Cancel"), onPressed: () {
              Navigator.of(context).pop();
            } ),
            Container(
              child: _isSendingMessage ? Container() : FlatButton(child: Icon(Icons.send), onPressed: () { 
              sendMessage(image, _titleController.text.trim(), _descriptionController.text.trim()); 
              }),
            ),
          ],
          title: Text('Send'),
          content: Column(
            children: <Widget>[
              Image.file(image),
              TextField(
                decoration: InputDecoration(hintText: "Title"),
                controller: _titleController,
              ),
              TextField(
                decoration: InputDecoration(hintText: "Description"),
                controller: _descriptionController,
              ),
            ],
          )
        );
      }
    );
  }

  void sendMessage(File imageFile, String title, String description) async {
    setState(() {
      _isSendingMessage = true;
      _uploadTask = uploadFile(imageFile);
    });
    StorageTaskSnapshot storageTaskSnapshot = await _uploadTask.onComplete;
    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) { // maybe move to cloud functions
      setState(() {
        onSendMessage(downloadUrl, title, description);
      });
    }, onError: (err) {
      setState(() {
        _isSendingMessage = false;
        print("Error sending message"); //todo toast
      });
    });
  }

  StorageUploadTask uploadFile(File imageFile) {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putFile(imageFile);
    return uploadTask;
    //StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    //return storageTaskSnapshot.ref.getDownloadURL();
    // storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
    //   setState(() {
    //     isLoading = false;
    //     onSendMessage(downloadUrl, '', '');
    //   });
    // }, onError: (err) {
    //   setState(() {
    //     isLoading = false;
    //   });
      //Fluttertoast.showToast(msg: 'This file is not an image');
      //print("This file is not an image");
  }
}