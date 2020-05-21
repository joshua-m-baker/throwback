import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:throwback/models/new_message.dart';
import 'package:throwback/models/picture_message.dart';
import 'package:throwback/models/auth_model.dart';
import 'package:throwback/models/contact.dart';

import 'package:throwback/pages/send_dialog.dart';
import 'package:throwback/util/router.dart';

class ChatPage extends StatefulWidget {

  final Contact peer;

  ChatPage({Key key, @required this.peer}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {

  final ScrollController listScrollController = new ScrollController();

  var messagesList;

  bool newestMessage(int index){ 
    return false;
    return (index == 0);
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<ApiModel>(
      builder: (BuildContext context, Widget child, ApiModel apiModel) {
        return Scaffold(
          appBar: AppBar(title: new Text(widget.peer.name),),
          backgroundColor: Colors.white,
          body:Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  buildMessages(context),
                ],
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: createImageMessage,
            child: Icon(Icons.add_photo_alternate),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          // bottomNavigationBar: BottomAppBar(
          //   shape: CircularNotchedRectangle(),
          //   child: Row(
          //     mainAxisSize: MainAxisSize.max,
          //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //     children: <Widget>[
          //       // IconButton(
          //       //   icon: Icon(Icons.link),
          //       //   onPressed: () {
          //       //     // createNewMessage(MessageType.url, context); // TODO
          //       //   },
          //       // ), 
          //       // IconButton(
          //       //   icon: Icon(Icons.camera_alt),
          //       //   onPressed: () {} //createCameraMessage,
          //       // )
          //     ],
          //   ),
          //   color: Colors.blueGrey
          // ),
        );
      }
    );
  }

  Widget buildMessages(BuildContext context){
    //todo fetch more messages on top of scroll 
    return Flexible(
      child: StreamBuilder(
        stream: ScopedModel.of<ApiModel>(context).getChats(widget.peer.chatId), 
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.red)));
          } else if (snapshot.hasError){
            return new Text('Error: ${snapshot.error}');
          } else {
            messagesList = snapshot.data.documents;
            return ListView.builder(
              padding: EdgeInsets.fromLTRB(10, 10, 10, 65), //TODO better solution //EdgeInsets.all(10.0),
              itemBuilder: (context, index) => buildMessage(context, index, snapshot.data.documents[index]),
              itemCount: snapshot.data.documents.length,
              reverse: true,
              controller: listScrollController,
            );
          }
        }
      )
    );
  }

  Widget buildMessage(BuildContext context, index, DocumentSnapshot document){
    PictureMessage message = PictureMessage.fromDocument(document);
    // FractionallySizedBox
    return Row(
      children: <Widget>[
        Flexible(
          child: FractionallySizedBox(
            widthFactor: .70,
            child: Container(
              child: FlatButton(
                child: Material(
                  child: Hero(child: 
                    CachedNetworkImage(
                      placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                      imageUrl: message.url,
                      //width: 300.0, //mediaquery for screenwidth
                      //height: 300.0,
                      fit: BoxFit.cover,
                    ),
                    tag: message.url
                  ),

                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  clipBehavior: Clip.hardEdge,
                ),
                onPressed: () {
                  Navigator.pushNamed(
                    context, 
                    Routes.picture_chat, 
                    arguments: message
                  );
                },
                padding: EdgeInsets.all(0),
              ),
              margin: EdgeInsets.only(bottom: newestMessage(index) ? 20.0 : 10.0, right: 10.0), //todo maybe add padding to input instead

            ),
          ),
        )
      ],
      mainAxisAlignment: message.fromId == ScopedModel.of<ApiModel>(context).user.uid ? MainAxisAlignment.end : MainAxisAlignment.start,
    );
  }

  void createImageMessage() async {
    File imageFile = await ImagePicker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    NewMessage newMessage = new NewMessage(imageFile, null, widget.peer.uid, widget.peer.chatId, '', '');

    launchMessageDialog(newMessage);
  }

  // void createCameraMessage() async {
  //   File imageFile = await ImagePicker.pickImage(source: ImageSource.camera, imageQuality: 70);
  //   launchMessageDialog(imageFile);
  // }

  void launchMessageDialog(NewMessage message){
    if (message.imageFile != null) {
      showDialog(
        context: context,
        builder: (context) {
          return SendDialog(message: message);
        }
      ).then((value) {
        if (value){
          listScrollController.animateTo(0.0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
          setState(() {});
        }
      });
    }
  }
}
