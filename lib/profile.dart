import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart'; 
import 'user_state.dart'; 
import 'ajout_vetement.dart'; 

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<void> saveUserData() => _saveUserData();

  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(UserState.userId).get();

      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _loginController.text = UserState.userId ?? '';
          _passwordController.text = data['password'] ?? '';
          _birthdayController.text = data['birthday'] ?? '';
          _addressController.text = data['address'] ?? '';
          _postalCodeController.text = data['postalCode']?.toString() ?? '';
          _cityController.text = data['city'] ?? '';
        });
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors du chargement des données.')),
      );
    }
  }

  Future<void> _saveUserData() async {
    try {
      final updatedData = <String, dynamic>{};

      if (_passwordController.text.isNotEmpty) {
        updatedData['password'] = _passwordController.text;
      }
      if (_birthdayController.text.isNotEmpty) {
        updatedData['birthday'] = _birthdayController.text;
      }
      if (_addressController.text.isNotEmpty) {
        updatedData['address'] = _addressController.text;
      }
      if (_postalCodeController.text.isNotEmpty) {
        updatedData['postalCode'] = _postalCodeController.text;
      }
      if (_cityController.text.isNotEmpty) {
        updatedData['city'] = _cityController.text;
      }

      if (updatedData.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aucune donnée à mettre à jour.')),
        );
        return;
      }

      await _firestore.collection('users').doc(UserState.userId).update(updatedData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Données sauvegardées avec succès.')),
        );
      }
    } catch (e) {
      debugPrint('Error saving user data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la sauvegarde des données.')),
        );
      }
    }
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _addClothing() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddClothingPage()),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _loginController,
              decoration: const InputDecoration(labelText: 'Login'),
              readOnly: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _birthdayController,
              decoration: const InputDecoration(labelText: 'Anniversaire'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Adresse'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _postalCodeController,
              decoration: const InputDecoration(labelText: 'Code Postal'),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _cityController,
              decoration: const InputDecoration(labelText: 'Ville'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveUserData,
              style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              minimumSize: const Size(180, 50),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              ),
              child: const Text(
              'Valider',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              minimumSize: const Size(180, 50),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              ),
              child: const Text(
              'Se déconnecter',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addClothing,
              style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              minimumSize: const Size(180, 50),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              ),
              child: const Text(
              'Ajouter un vetement',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
