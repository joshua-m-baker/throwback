
import 'package:flutter/material.dart';
import 'package:throwback/chat_page.dart';
import 'package:throwback/contacts_page.dart';
import 'package:throwback/signin_page.dart';
import 'constants.dart';

class ChatArgs{
  final String myId;
  final String peerId; 

  ChatArgs(this.myId, this.peerId);
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
      return MaterialPageRoute(builder: (context) => ChatPage(myId: args.myId, peerId: args.peerId,));
  };
}
