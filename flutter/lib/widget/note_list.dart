import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/subjects.dart';
import 'dart:convert';
import '../model/export.dart';

class NotesList extends StatefulWidget {
  final String title;
  final PublishSubject<int> slectedSubject;
  final Stream<int> updateStream;

  NotesList(
      {Key key,
      @required this.title,
      @required this.slectedSubject,
      @required this.updateStream})
      : super(key: key);

  @override
  _NotesListState createState() =>
      _NotesListState(title, slectedSubject, updateStream);
}

class _NotesListState extends State<NotesList> {
  final String title;
  final PublishSubject<int> slectedSubject;
  final Stream<int> updateStream;

  @override
  void initState() {
    super.initState();
    updateStream.listen((event) {
      setState(() {});
    });
  }

  Future<List<Note>> fetchNotes() async {
    try {
      var result = await http
          .get(Uri(scheme: "https", host: "localhost", path: "/api/note/"));
      if (result != null && result.statusCode == 200) {
        try {
          Iterable i = json.decode(result.body);
          return List.from(i.map((e) => Note.fromJson(e)));
        } catch (e) {
          log(e.toString());
          return List.empty();
        }
      }
    } catch (e) {
      log(e.toString());
    }
    return List.empty();
  }

  _NotesListState(this.title, this.slectedSubject, this.updateStream);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FutureBuilder<List<Note>>(
        future: fetchNotes(),
        builder: (context, snapshot) {
          return ListView.builder(
            itemCount: snapshot.data.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(
                  snapshot.data[index].title,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 14.0),
                ),
                onTap: () {
                  slectedSubject.add(snapshot.data[index].id);
                },
              );
            },
          );
        },
      ),
    );
  }
}
