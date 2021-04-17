import 'dart:async';
import 'dart:convert';

import 'package:client/model/note.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/subjects.dart';

class Editor extends StatefulWidget {
  final Stream<int> selectedItemStream;
  final PublishSubject<int> updateSubject;

  const Editor(
      {Key key,
      @required this.selectedItemStream,
      @required this.updateSubject})
      : super(key: key);

  @override
  _EditorState createState() => _EditorState(selectedItemStream, updateSubject);
}

class _EditorState extends State<Editor> {
  final Stream<int> selectedItemStream;
  final PublishSubject<int> updateSubject;
  String _text = "";
  int _inputViewFlex = 7;
  int _previewViewFlex = 3;
  int _selectedNoteId = -1;
  bool _showDelete = false;

  final tagsTextEditingController = TextEditingController();
  final titleTextEditingController = TextEditingController();
  final bodyTextEditingController = TextEditingController();

  _EditorState(this.selectedItemStream, this.updateSubject);

  @override
  void initState() {
    super.initState();
    selectedItemStream.listen((event) {
      _selectedNoteId = event;
      if (event >= 0) {
        _loadPost(event);
      } else {
        _emptyBoard();
      }
    });
  }

  void _emptyBoard() {
    setState(() {
      _showDelete = false;
      _selectedNoteId = -1;
      _text = "";
      tagsTextEditingController.text = "";
      titleTextEditingController.text = "";
      bodyTextEditingController.text = "";
    });
  }

  void _updateText(String text) {
    setState(() {
      _text = text;
    });
  }

  void _toogleMainViewProportion() {
    setState(() {
      if (_inputViewFlex == 7) {
        _inputViewFlex = 3;
        _previewViewFlex = 7;
      } else {
        _inputViewFlex = 7;
        _previewViewFlex = 3;
      }
    });
  }

  void _loadPost(int id) async {
    if (id < 0) {
      return null;
    }
    try {
      var result = await http
          .get(Uri(scheme: "https", host: "localhost", path: "/api/note/$id"));
      if (result != null && result.statusCode == 200) {
        try {
          final newNote = Note.fromJson(json.decode(result.body));
          setState(() {
            tagsTextEditingController.text = newNote.tags.join(", ");
            titleTextEditingController.text = newNote.title;
            bodyTextEditingController.text = newNote.body;
            _showDelete = true;
            _text = newNote.body;
          });
        } catch (e) {
          print(e.toString());
        }
      }
    } catch (e) {
      print(e.toString());
    }
    return null;
  }

  void _deletePost() async {
    try {
      var result = await http.delete((Uri(
          scheme: "https",
          host: "localhost",
          path: "/api/note/$_selectedNoteId")));
      if (result != null && result.statusCode == 200) {
        _emptyBoard();
        updateSubject.add(-1);
      }
    } catch (e) {
      print(e.toString());
    }
  }

  void _savePost() async {
    final uri = Uri(scheme: "https", host: "localhost", path: "/api/note/");
    final tags = tagsTextEditingController.text.split(',');
    final body = jsonEncode(
      <String, dynamic>{
        'title': titleTextEditingController.text,
        'body': bodyTextEditingController.text,
        'tags': tags,
      },
    );
    print("_savePost, body: $body");
    var result = await http.post(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: body,
    );
    if (result.statusCode == 200) {
      final int id = json.decode(result.body)['id'];
      updateSubject.add(id);
      setState(() {
        _selectedNoteId = id;
        _showDelete = true;
      });
    }
  }

  @override
  void dispose() {
    tagsTextEditingController.dispose();
    titleTextEditingController.dispose();
    bodyTextEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const TextStyle style = TextStyle(
      color: Colors.white,
    );

    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 24,
          centerTitle: false,
          backgroundColor: Colors.grey.shade700,
          title: TextField(
            controller: titleTextEditingController,
            decoration: InputDecoration(
              hintText: "Add title...",
              hintStyle: TextStyle(color: Colors.white, fontSize: 14.0),
            ),
            style: TextStyle(color: Colors.white, fontSize: 14.0),
          ),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  _toogleMainViewProportion();
                },
                child: Icon(
                  Icons.vertical_split,
                  size: 16.0,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: _showDelete
                  ? GestureDetector(
                      onTap: () {
                        _deletePost();
                      },
                      child: Icon(
                        Icons.delete,
                        size: 16.0,
                      ),
                    )
                  : Container(),
            )
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: _inputViewFlex,
                    child: Container(
                      width: 100,
                      height: double.infinity,
                      padding: EdgeInsets.all(10),
                      child: TextField(
                        controller: bodyTextEditingController,
                        onChanged: (value) => {_updateText(value)},
                        autofocus: true,
                        maxLines: null,
                        expands: true,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Start typing your note...',
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: _previewViewFlex,
                    child: Container(
                      width: 100,
                      height: double.infinity,
                      color: Colors.grey.shade200,
                      margin: EdgeInsets.all(10),
                      padding: EdgeInsets.all(10),
                      child: MarkdownBody(data: _text),
                    ),
                  )
                ],
              ),
            ),
            Container(
              height: 48,
              margin: EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    flex: 7,
                    child: Container(
                      child: TextField(
                        autofocus: true,
                        maxLines: null,
                        expands: true,
                        controller: tagsTextEditingController,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Coma separated tags'),
                      ),
                    ),
                  ),
                  _selectedNoteId <= 0
                      ? Expanded(
                          flex: 3,
                          child: Container(
                            alignment: Alignment.center,
                            width: 98,
                            child: ElevatedButton(
                              onPressed: _savePost,
                              child: Text('Save'),
                              style: ElevatedButton.styleFrom(
                                primary: Colors.greenAccent,
                                onPrimary: Colors.white,
                                onSurface: Colors.grey,
                              ),
                            ),
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
