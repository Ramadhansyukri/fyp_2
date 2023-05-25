class Restaurant {

  final String? uid;
  final String imageUrl;
  final String addressLine1;
  final String addressLine2;
  final String addressLine3;

  Restaurant({
    required this.uid,
    required this.imageUrl,
    required this.addressLine1,
    required this.addressLine2,
    required this.addressLine3,
  });

  Map<String, dynamic> toJson() => {
    'imageUrl': imageUrl,
    'addressLine1': addressLine1,
    'addressLine2': addressLine2,
    'addressLine3': addressLine3,
  };

  static Restaurant fromJson(Map<String, dynamic> data) => Restaurant(
      uid: data['uid'],
      imageUrl: data['imageUrl'],
      addressLine1: data['addressLine1'],
      addressLine2: data['addressLine2'],
      addressLine3: data['addressLine3'],
  );
}