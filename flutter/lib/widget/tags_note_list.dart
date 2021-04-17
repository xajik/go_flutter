import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/subjects.dart';
import 'dart:convert';
import '../model/export.dart';

class TagsNotesList extends StatefulWidget {
  final String title;
  final Stream<int> selectedItemStream;
  final PublishSubject<int> slectedSubject;

  TagsNotesList(
      {Key key,
      @required this.title,
      @required this.selectedItemStream,
      @required this.slectedSubject})
      : super(key: key);

  @override
  _TagsNotesListState createState() =>
      _TagsNotesListState(title, selectedItemStream, slectedSubject);
}

class _TagsNotesListState extends State<TagsNotesList> {
  final String title;
  final Stream<int> slectedStream;
  final PublishSubject<int> slectedSubject;
  int selectedPost = -1;

  @override
  void initState() {
    super.initState();
    slectedStream.listen((event) {
      setState(() {
        selectedPost = event;
      });
    });
  }

  Future<List<Note>> fetchNotes(int id) async {
    if (id < 0) {
      return List.empty();
    }
    try {
      var result = await http.get(
          Uri(scheme: "https", host: "localhost", path: "/api/note/$id/bytag"));
      if (result != null && result.statusCode == 200) {
        try {
          Iterable i = json.decode(result.body);
          return List.from(i.map((e) => Note.fromJson(e)));
        } catch (e) {
          return List.empty();
        }
      }
    } catch (e) {
      log(e.toString());
    }
    return List.empty();
  }

  _TagsNotesListState(this.title, this.slectedStream, this.slectedSubject);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FutureBuilder<List<Note>>(
        future: fetchNotes(selectedPost),
        builder: (context, snapshot) {
          return ListView.builder(
            itemCount: snapshot == null ? 0 : snapshot.data.length,
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
