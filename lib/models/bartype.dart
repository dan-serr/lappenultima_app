class BarType {
  final int id;
  final String name;
  String? description;

  BarType({required this.id, required this.name, this.description});

  BarType.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        description = json['description'];

  Map<String, dynamic> toJson() =>
      {'id': id, 'name': name, 'description': description};
}
