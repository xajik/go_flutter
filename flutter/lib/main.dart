import 'package:client/widget/export.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final postSelectSubject = PublishSubject<int>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GoNote with Flutter',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          backgroundColor: Colors.white,
          title: Text(
            'GoNote',
            style: TextStyle(
                fontStyle: FontStyle.normal,
                color: Colors.grey.shade800,
                fontWeight: FontWeight.bold),
          ),
          actions: [
            Container(
              margin: EdgeInsets.only(right: 20.0),
              padding: EdgeInsets.only(right: 10.0),
              height: 48,
              width: 98,
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () {
                  postSelectSubject.add(-1);
                },
                child: Text('Add'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.greenAccent,
                  onPrimary: Colors.white,
                  onSurface: Colors.grey,
                ),
              ),
            ),
          ],
        ),
        body: Center(
          child: RowContainer(postSelectSubject: postSelectSubject),
        ),
      ),
    );
  }
}
