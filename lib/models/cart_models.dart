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
