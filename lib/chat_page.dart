import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:throwback/models.dart/new_message.dart';
import 'package:throwback/models.dart/picture_message.dart';
import 'auth_model.dart';
import 'models.dart/contact.dart';
import 'send_dialog.dart';

import 'router.dart';
import 'new_message_dialog.dart';

class ChatPage extends StatefulWidget {

  final Contact peer;

  ChatPage({Key key, @required this.peer}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController listScrollController = new ScrollController();
  final TextEditingController textEditingController = new TextEditingController();
  final FocusNode focusNode = new FocusNode();

  var messagesList;
  bool isLoading = false;


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

  bool newestMessage(int index){ 
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
              buildLoading(),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: createImageMessage,
            child: Icon(Icons.add_photo_alternate),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: BottomAppBar(
            shape: CircularNotchedRectangle(),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.link),
                  onPressed: () {
                    // createNewMessage(MessageType.url, context); // TODO
                  },
                ), 
                IconButton(
                  icon: Icon(Icons.camera_alt),
                  onPressed: () {} //createCameraMessage,
                )
              ],
            ),
            color: Colors.blueGrey
          ),
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
              padding: EdgeInsets.all(10.0),
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
                  imageUrl: message.url,
                  width: 300.0, //mediaquery for screenwidth
                  height: 300.0,
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

        )
      ],
      mainAxisAlignment: message.fromId == ScopedModel.of<ApiModel>(context).user.uid ? MainAxisAlignment.end : MainAxisAlignment.start,
    );
  }

  void createImageMessage() async {
    File imageFile = await ImagePicker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    NewMessage newMessage = new NewMessage(imageFile, null, ScopedModel.of<ApiModel>(context).user.uid, widget.peer.uid, widget.peer.chatId, '', '');

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
          // TODO pass in mostly empty PictureMessage, imageFile, have senddialog inherit scorddescednetn 
          return SendDialog(message: message);
          //  , sendMessage: () {
          //   ScopedModel.of<ApiModel>(context).sendMessage(message);
          //  listScrollController.animateTo(0.0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
          //  setState(() {});
          // });
        }
      );
    }
  }
}
