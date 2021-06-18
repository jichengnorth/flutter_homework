import 'dart:collection';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_homework/selection.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
/**
 * Flutter Homework
 *
 * June 2021
 *
 * In this main, we could be cut it up into 3 dart.files. Since it is just for demo,
 * I combined them all in one.
 *
 * We jumped pass the login and firestore_Auth, assumme the user is already log in
 * and ready for some actions
 *
 * Action:
 *
 * 1.Choose the class that they wish to Join
 * 2.ONLY can Clicked on the displayed avaliable seats.
 * 3.Action alert dialog poped out, (Y/N)
 * 4.no-Action alert dialog disapeared
 *  Yes-Database updates, Confiramation dialog out.
 *      5.close the Confiramation -back to main
 *
 */



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _fbApp = Firebase.initializeApp();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: FutureBuilder(
      future: _fbApp,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print('You Have ERRORS! ${snapshot.error.toString()}');
          return Text("Something Went wrong");
        } else if (snapshot.hasData) {
          print('ALL GOOD');
          return MyHomePage(
            title: 'home',
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    ));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FirebaseFirestore _firebase = FirebaseFirestore.instance;
  String classNumPressed = "";

  // DatabaseReference _testref = FirebaseDatabase.instance.reference().child('test');
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.teal,
        appBar: AppBar(
          title: Text("Demo"),
          backgroundColor: Colors.blueGrey[900],
        ),
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Card(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white,
                  ),
                  onPressed: () {
                    print('class 1 is presseed');
                    classNumPressed = 'Class1';

                    print(classNumPressed);
                    getSeat();
                  },
                  child: ListTile(
                      leading: Icon(
                        Icons.photo_camera,
                        color: Colors.black,
                        size: 60,
                      ),
                      title: Text('Class 1',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 50,
                          ))),
                ),
              ),
              Card(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white,
                  ),
                  onPressed: () {
                    print('class 2 is presseed');
                    classNumPressed = 'Class2';
                    print(classNumPressed);
                    getSeat();
                  },
                  child: ListTile(
                      leading: Icon(
                        Icons.photo_camera,
                        color: Colors.red,
                        size: 60,
                      ),
                      title: Text('Class 2',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 50,
                          ))),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> getSeat() async {
    print(classNumPressed);
    List<Map<String, dynamic>> dataToSend = [
      {'ClassNum': classNumPressed}
    ];

    QuerySnapshot seats = await _firebase.collection(classNumPressed).get();
    final List allData = seats.docs.map((doc) => doc.data()).toList();
    for (Map<String, dynamic> seat in allData) {
      print("------------for loop");
      print(seat);
      dataToSend.add(seat);
    }
    print("------for loop datatosend is ");
    print(dataToSend);
    print(dataToSend.length);

    print("-------before transfer ");

    print(dataToSend[1].values.length);
    var listTest = dataToSend[1].values.toList();
    var listTest1 = dataToSend[0].values.toList();

    print(listTest[1].toString());
    print('class get is 1: ' + listTest1[0].toString());

    final List<Map<String, dynamic>> dataSend = dataToSend;
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PressScreen(datas: dataSend),
        ));
  }
}

class PressScreen extends StatelessWidget {
  final List<Map<String, dynamic>> datas;
  PressScreen({Key? key, required this.datas}) : super(key: key);
  List<Widget> textWidgetList = [];

  Color backColor = const Color(4286470082);
  String filled = "errors";
  String classNumPressed = '69';

  @override
  Widget build(BuildContext context) {
    var classNumGetlist = datas[0].values.toList();
    classNumPressed = classNumGetlist[0];

    for (int i = 1; i < datas.length; i++) {
      var list = datas[i].values.toList();
      if (list[1] == false) {
        filled = "free";
        backColor = const Color(4294967295);

        textWidgetList.add(
          SizedBox(
            width: 100.0,
            height: 100.0,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: backColor, // background
                  onPrimary: Colors.black, // foreground
                ),
                child: Center(
                    child: Text('Seat ' + list[0].toString() + '  ' + filled)),
                onPressed: () async {
                  if (await confirm(
                    context,
                    title: Text('Confirm'),
                    content:
                        Text('Would you like to confirm to join '+classNumPressed+' and Seat'+i.toString()+' ?'),
                    textOK: Text('Yes'),
                    textCancel: Text('No'),
                  )) {
                    print('pressedOK');
                    updateUser(i);
                    if (await confirm(
                      context,
                      title: Text('Confirm'),
                      content: Text('You have Succussfully booked : ' +
                          classNumPressed +
                          ' and Seat' +
                          i.toString()),
                      textOK: Text('cancel'),
                      textCancel: Text(''),
                    )) {

                    }
                    Navigator.of(context, rootNavigator: true).pop(context);
                  }
                  return print('pressedCancel');
                },
              ),
            ),
          ),
        );
      } else {
        filled = "Full";
        backColor = const Color(4294917376);

        textWidgetList.add(
          SizedBox(
            width: 100.0,
            height: 100.0,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: backColor, // background
                  onPrimary: Colors.black, // foreground
                ),
                child: Center(
                    child: Text('Seat ' + list[0].toString() + '  ' + filled)),
                onPressed: null,
              ),
            ),
          ),
        );
      }
    }

    return Scaffold(
        backgroundColor: Colors.teal,
        body: SafeArea(
            child: Center(
                child: Column(
          children: textWidgetList,
        ))));
  }

  Future<void> updateUser(int i) {
    print('fire uplod --------');



    CollectionReference db =
        FirebaseFirestore.instance.collection(classNumPressed);
    print(classNumPressed);
    print('seat' + i.toString());


    return db
        .doc('seat' + i.toString())
        .update({'filled': true})
        .then((value) => print("User Updated"))
        .catchError((error) => print("Failed to update user: $error"));
  }


}
