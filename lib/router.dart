
import 'package:flutter/material.dart';
import 'package:throwback/chat_page.dart';
import 'package:throwback/contacts_page.dart';
import 'package:throwback/picture_chat.dart';
import 'package:throwback/signin_page.dart';
import 'constants.dart';

class ChatArgs{
  final String myId;
  final String peerId; 
  final String peerName;

  ChatArgs(this.myId, this.peerId, this.peerName);
}

class PictureChatArgs{
  final String chatId;
  final String imageLink;

  PictureChatArgs(this.chatId, this.imageLink);
}

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name){
    case Routes.root:
      return MaterialPageRoute( builder: (context) => SignInPage());
      break;
    case Routes.chats:
      return MaterialPageRoute(builder: (context) => ContactsPage(user: settings.arguments));
      break;
    case Routes.chat_page:
      ChatArgs args = settings.arguments;
      return MaterialPageRoute(builder: (context) => ChatPage(myId: args.myId, peerId: args.peerId, peerName: args.peerName,));
      break;
    case Routes.picture_chat:
      PictureChatArgs args = settings.arguments;
      return MaterialPageRoute(builder: (context) => PictureChat(chatId: args.chatId, imageLink: args.imageLink,));
      break;
  };
}
