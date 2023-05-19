class Users {

  final String uid;
  final String name;
  final String email;
  final String phone;
  final String usertype;

  Users({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.usertype,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'phone': phone,
    'email': email,
    'usertype': usertype,
  };

  static Users fromJson(Map<String, dynamic> data) => Users(
    uid: data['uid'],
    name: data['name'],
    phone: data['phone'],
    email: data['email'],
    usertype: data['usertype']
  );
}