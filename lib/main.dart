import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:throwback/auth_model.dart';
import 'router.dart';

class MyApp extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Throwback',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Helvetica',
      ),
      onGenerateRoute: (RouteSettings settings) { return generateRoute(settings); },
      initialRoute: Routes.root,
      // home: Scaffold(
      //   appBar: AppBar(title: Text("Throwback"),),
      //   body: SignInPage()
        
      //   Center(
      //     child: FutureBuilder<FirebaseUser> (
      //       //future: _googleSignIn.isSignedIn(),
      //       future: _auth.currentUser(),
      //       builder: (BuildContext context, AsyncSnapshot snapshot) {
      //         if (snapshot.connectionState == ConnectionState.done){
      //           if (snapshot.data != null){
      //             print("Snapshot data");
      //             print(snapshot.data);
      //             return ContactsPage();
      //           } 
      //           return SignInPage();
      //         } else {
      //           return new CircularProgressIndicator();
      //         }
      //       },
      //     )
      //   ,)
      // ,)
    );
  }
}

void main(){
  WidgetsFlutterBinding.ensureInitialized();

  final apiModel = ApiModel();
  apiModel.signInSilently();

  runApp(
    ScopedModel<ApiModel>(
      model: apiModel,
      child: MyApp(),
    )
  );
}
