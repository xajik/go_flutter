import 'package:client/widget/editor.dart';
import 'package:client/widget/tags_note_list.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';
import 'note_list.dart';

class RowContainer extends StatelessWidget {
  final PublishSubject<int> postSelectSubject;
  RowContainer({Key key, this.postSelectSubject}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final savedPostSelectSubject = PublishSubject<int>();

    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Text(
                  "Notes",
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 18.0),
                ),
                NotesList(
                  title: "related",
                  slectedSubject: postSelectSubject,
                  updateStream: savedPostSelectSubject.stream,
                )
              ],
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.all(50),
          child: Container(
            width: 800,
            child: Editor(
              selectedItemStream: postSelectSubject.stream,
              updateSubject: savedPostSelectSubject,
            ),
            color: Colors.transparent,
          ),
          color: Colors.grey.shade200,
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Text(
                  "Related",
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 18.0),
                ),
                TagsNotesList(
                  title: "related",
                  selectedItemStream: postSelectSubject.stream,
                  slectedSubject: postSelectSubject,
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
