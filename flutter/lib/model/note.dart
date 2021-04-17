class Note {
  final int id;
  final String title;
  final String body;
  final List<String> tags;
  final String created_at;
  final String updated_at;

  Note(this.id, this.title, this.body, this.tags, this.created_at,
      this.updated_at);

  Note.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'],
        body = json['body'],
        tags = new List<String>.from(json['tags']),
        created_at = json['created_at'],
        updated_at = json['updated_at'];

  Map<String, dynamic> toJson() => {
        'title': title,
        'body': body,
        'tags': tags,
      };
}
