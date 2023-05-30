class CartItem {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String restID;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.restID,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'restID' : restID,
      'quantity': quantity,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      name: json['name'],
      price: json['price'],
        imageUrl: json['imageUrl'],
      restID: json['restID'],
      quantity: json['quantity']
    );
  }
}
/*
class Cart{
  final String menuID;
  final String restaurantID;
  late final int quantity;

  Cart({
    required this.menuID,
    required this.restaurantID,
    this.quantity = 1,
  });

  void incrementQuantity() {
    quantity = quantity + 1;

  }

  void decrementQuantity() {
    quantity = quantity - 1;
  }

  Map<String, dynamic> toJson() => {
    'menuID': menuID,
    'restaurantID': restaurantID,
    'quantity': quantity,
  };

  static Cart fromJson(Map<String, dynamic> data) => Cart(
    menuID: data['menuID'],
    restaurantID: data['restaurantID'],
    quantity: data['quantity'],
  );
}*/
