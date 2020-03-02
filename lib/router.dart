
import 'package:flutter/material.dart';
import 'package:throwback/contacts_page.dart';
import 'package:throwback/signin_page.dart';
import 'constants.dart';

class Router {
  Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name){
      case login:
        return MaterialPageRoute( builder: (context) => SignInPage());
        break;
      case chats:
        return MaterialPageRoute(builder: (context) => ContactsPage());
        break;
    }
  }
}