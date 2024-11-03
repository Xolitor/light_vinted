import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_state.dart'; 

class DetailPage extends StatelessWidget {
  final Map<String, dynamic> clothing;

  const DetailPage({super.key, required this.clothing});

  Future<bool> _isInCart() async {

    final snapshot = await FirebaseFirestore.instance
        .collection('cart')
        .where('userId', isEqualTo: UserState.userId)  
        .where('title', isEqualTo: clothing['title'])  
        .get();

    return snapshot.docs.isNotEmpty;
  }

  Future<void> _addToCart(BuildContext context) async {

    if (await _isInCart()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le produit est déjà dans le panier !'),
          duration: Duration(seconds: 2),
        ),
      );
      return; 
    }

    try {
      await FirebaseFirestore.instance.collection('cart').add({
        'userId': UserState.userId, 
        'title': clothing['title'],
        'imageUrl': clothing['imageUrl'],
        'category': clothing['category'],
        'size': clothing['size'],
        'brand': clothing['brand'],
        'price': clothing['price'],
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Produit ajouté au panier !'),
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.pop(context);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de l\'ajout au panier.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(clothing['title']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              clothing['imageUrl'],
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.broken_image, size: 100);
              },
            ),
            const SizedBox(height: 10),
            Text(
              'Titre: ${clothing['title']}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('Category: ${clothing['category']}'),
            const SizedBox(height: 10),
            Text('Taille: ${clothing['size']}'),
            const SizedBox(height: 10),
            Text('Brand: ${clothing['brand']}'),
            const SizedBox(height: 10),
            Text('Prix: \$${clothing['price']}'),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () => _addToCart(context),
                child: const Text('Ajouter au panier'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
