class User {
  final String id;
  String? username;
  String? email;
  String? firstName;
  String? lastName;
  String? timeZoneId;
  bool? active;
  int? version;

  User(
      {required this.id,
      this.username,
      this.email,
      this.firstName,
      this.lastName,
      this.timeZoneId,
      this.active,
      this.version});

  User.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        username = json['username'],
        email = json['email'],
        firstName = json['firstName'],
        lastName = json['lastName'],
        timeZoneId = json['timeZoneId'],
        active = json['active'],
        version = json['version'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'timeZoneId': timeZoneId,
        'active': active,
        'version': version
      };
}
