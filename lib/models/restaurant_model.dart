class Restaurant {

  final String? uid;
  final String imageUrl;
  final String address;

  Restaurant({
    required this.uid,
    required this.imageUrl,
    required this.address
  });

  Map<String, dynamic> toJson() => {
    'uid' : uid,
    'imageUrl': imageUrl,
    'address': address
  };

  static Restaurant fromJson(Map<String, dynamic> data) => Restaurant(
      uid: data['uid'],
      imageUrl: data['imageUrl'],
      address: data['address']
  );
}