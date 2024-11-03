import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_state.dart'; 

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Map<String, dynamic>> _cartItems = [];
  double _totalPrice = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchCartItems();
  }

  Future<void> _fetchCartItems() async {
  
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('cart')
          .where('userId', isEqualTo: UserState.userId) 
          .get();

      final List<Map<String, dynamic>> items = snapshot.docs.map((doc) {
        return {...doc.data(), 'id': doc.id};
      }).toList();

      setState(() {
        _cartItems = items;
        _calculateTotal();
      });
    } catch (e) {
      print('Error fetching cart items: $e');
    }
  }

  void _calculateTotal() {
    double total = 0.0;
    for (var item in _cartItems) {
      total += double.tryParse(item['price'].toString()) ?? 0.0;
    }
    setState(() {
      _totalPrice = total;
    });
  }

  Future<void> _removeItem(String id) async {
    try {
      await FirebaseFirestore.instance.collection('cart').doc(id).delete();
      setState(() {
        _cartItems.removeWhere((item) => item['id'] == id);
        _calculateTotal(); 
      });
    } catch (e) {
      debugPrint('Error removing item: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _cartItems.isEmpty
          ? const Center(child: Text('Votre panier est vide.'))
          : ListView.builder(
              itemCount: _cartItems.length,
              itemBuilder: (context, index) {
                final item = _cartItems[index];
                return ListTile(
                  leading: Image.network(
                    item['imageUrl'],
                    width: 50,
                    height: 50,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.broken_image);
                    },
                  ),
                  title: Text(item['title']),
                  subtitle: Text(
                    'Taille: ${item['size']} - Prix: \$${item['price']}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () => _removeItem(item['id']),
                  ),
                );
              },
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Total: \$${_totalPrice.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
