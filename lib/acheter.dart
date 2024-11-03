import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'detail_page.dart';

class Acheter extends StatefulWidget {
  const Acheter({super.key});

  @override
  _Acheter createState() => _Acheter();
}

class _Acheter extends State<Acheter> {
  final CollectionReference _clothesCollection = FirebaseFirestore.instance.collection('clothes');

  @override
  Widget build(BuildContext context) {
    
    return StreamBuilder<QuerySnapshot>(
      stream: _clothesCollection.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong!'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No clothes available.'));
        }

        return ListView(
          children: snapshot.data!.docs.map((doc) {
            Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
            return ListTile(
              leading: Image.network(data['imageUrl'], width: 50, height: 50, fit: BoxFit.cover),
              title: Text(data['title']),
              subtitle: Text('\$${data['price'].toString()}'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DetailPage(clothing: data)),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }
}
