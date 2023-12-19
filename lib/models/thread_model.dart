class ThreadModel {
  final String title;
  final String id;

  ThreadModel({required this.title, required this.id});

  factory ThreadModel.fromJson(Map<String, dynamic> json) {
    return ThreadModel(
      title: json['title'],
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'id': id,
    };
  }
}
