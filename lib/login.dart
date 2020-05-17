

import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:throwback/auth_model.dart';
import 'router.dart';


class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScopedModelDescendant<ApiModel>(
        builder: (BuildContext context, Widget child, ApiModel apiModel) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
              padding: const EdgeInsets.all(15),
              child: const Text('Connect with Google Photos'),
              onPressed: () async {
                try {
                  await apiModel.signInWithGoogle()
                      ? _navigateToChats(context)
                      : _showSignInError(context);
                } on Exception catch (error) {
                  print(error);
                  _showSignInError(context);
                }
              },
            ),
            ]
          );
        }
      )
    );
  }

  void _showSignInError(BuildContext context) {
    final SnackBar snackBar = SnackBar(
      duration: Duration(seconds: 3),
      content: const Text('Could not sign in.\n'
          'Is the Google Services file missing?'),
    );
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void _navigateToChats(context) {
    Navigator.pushReplacementNamed(
      context, 
      Routes.chats_list,
    );
  }
}
