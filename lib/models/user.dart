class User {
  int? id;
  String? email;
  String? firstName;
  String? lastName;
  String? role;
  String? password;

  User(
      {this.id,
      this.email,
      this.firstName,
      this.lastName,
      this.role,
      this.password});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    email = json['email'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    role = json['role'];
    password = json['password'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['email'] = email;
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['role'] = role;
    data['password'] = password;
    return data;
  }
}
