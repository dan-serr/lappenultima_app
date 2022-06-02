class Beer {
  final int id;
  int? iDBeerCompany;
  int? iDBeerType;
  int? iBUs;
  final String name;
  String? description;

  Beer(
      {required this.id,
      this.iDBeerCompany,
      this.iDBeerType,
      this.iBUs,
      required this.name,
      this.description});

  Beer.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        iDBeerCompany = json['iDBeerCompany'],
        iDBeerType = json['iDBeerType'],
        iBUs = json['iBUs'],
        name = json['name'],
        description = json['description'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'iDBeerCompany': iDBeerCompany,
        'iDBeerType': iDBeerType,
        'iBUs': iBUs,
        'name': name,
        'description': description
      };
}
