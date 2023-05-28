import 'package:flutter/material.dart';
import '../../models/cart_models.dart';
import '../../models/user_models.dart';
import '../../services/database.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key,required this.user}) : super(key: key);

  final Users? user;

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CartItem> _cartItems = [];

  @override
  void initState() {
    super.initState();
    _fetchCartItems();
  }

  void _fetchCartItems() async {
    List<CartItem> cartItems = await CartService(uid: widget.user!.uid).getCartItems();
    setState(() {
      _cartItems = cartItems;
    });
  }

  void _increaseQuantity(CartItem cartItem) {
    setState(() {
      cartItem.quantity++;
    });
    _updateCartItem(cartItem);
  }

  void _decreaseQuantity(CartItem cartItem) {
    setState(() {
      if (cartItem.quantity > 0) {
        cartItem.quantity--;
        if (cartItem.quantity == 0) {
          _removeCartItem(cartItem);
        } else {
          _updateCartItem(cartItem);
        }
      }
    });
  }

  void _updateCartItem(CartItem cartItem) async {
    await CartService(uid: widget.user!.uid).updateCartItem(cartItem);
  }

  void _removeCartItem(CartItem cartItem) async {
    setState(() {
      _cartItems.remove(cartItem);
    });
    await CartService(uid: widget.user!.uid).removeCartItem(cartItem);
  }

  void _clearCart() async {
    setState(() {
      _cartItems.clear();
    });
    await CartService(uid: widget.user!.uid).clearCart();
  }

  double _calculateTotal() {
    double total = 0;
    for (var cartItem in _cartItems) {
      total += (cartItem.price * cartItem.quantity);
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                Theme.of(context).primaryColor,
                Theme.of(context).colorScheme.secondary,
              ],
            ),
          ),
        ),
        title: const Text(
          'Cart',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: _clearCart,
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: ListView.builder(
                itemCount: _cartItems.length,
                itemBuilder: (context, index) {
                  final cartItem = _cartItems[index];
                  return CartItemWidget(
                    cartItem: cartItem,
                    increaseQuantity: _increaseQuantity,
                    decreaseQuantity: _decreaseQuantity,
                  );
                },
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: RM${_calculateTotal().toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Implement checkout logic
                  },
                  child: const Text('Checkout'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CartItemWidget extends StatelessWidget {
  final CartItem cartItem;
  final Function(CartItem) increaseQuantity;
  final Function(CartItem) decreaseQuantity;

  const CartItemWidget({super.key,
    required this.cartItem,
    required this.increaseQuantity,
    required this.decreaseQuantity,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(cartItem.imageUrl),
      ),
      title: Text(cartItem.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Price: RM${cartItem.price.toStringAsFixed(2)}'),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => decreaseQuantity(cartItem),
                icon: const Icon(Icons.remove),
              ),
              Text(cartItem.quantity.toString()),
              IconButton(
                onPressed: () => increaseQuantity(cartItem),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
