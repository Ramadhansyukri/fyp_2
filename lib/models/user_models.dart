class Users {

  final String? uid;
  String name;
  final String email;
  String phone;
  final String usertype;
  final String address;
  final double balance;
  String? PIN;

  Users({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.usertype,
    required this.address,
    required this.balance,
    this.PIN,
  });

  Map<String, dynamic> toJson() => {
    'uid' : uid,
    'name': name,
    'phone': phone,
    'email': email,
    'usertype': usertype,
    'address': address,
    'balance': balance,
    'PIN': PIN
  };

  static Users fromJson(Map<String, dynamic> data) => Users(
    uid: data['uid'],
    name: data['name'],
    phone: data['phone'],
    email: data['email'],
    usertype: data['usertype'],
    address: data['address'],
    balance: data['balance'].toDouble(),
    PIN: data['PIN']
  );
}