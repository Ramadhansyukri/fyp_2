class Menu {

  final String menuID;
  final String imageUrl;
  final String name;
  final String desc;
  final double price;

  Menu({
    required this.menuID,
    required this.imageUrl,
    required this.name,
    required this.desc,
    required this.price,
  });

  Map<String, dynamic> toJson() => {
    'menuID' : menuID,
    'imageUrl': imageUrl,
    'name': name,
    'desc': desc,
    'price': price,
  };

  static Menu fromJson(Map<String, dynamic> data) => Menu(
      menuID: data['menuID'],
      imageUrl: data['imageUrl'],
      name: data['name'],
      desc: data['desc'],
      price: data['price']
  );
}