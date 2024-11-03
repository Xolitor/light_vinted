import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'user_state.dart';
import 'home_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Erreur'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _loginUser() async {
    String userId = _loginController.text.trim();
    String password = _passwordController.text.trim();

    try {
      debugPrint('Attempting to retrieve user: $userId'); 
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
      debugPrint('User document retrieved'); 

      if (userDoc.exists) {
        String storedPassword = userDoc['password'];
        if (storedPassword == password) {
          debugPrint('Login successful'); 
          debugPrint('Welcome User ID: $userId');
          UserState.userId = userId; 
          UserState.password = password;
          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MainPage()),
          );
        } else {
          debugPrint('Incorrect password'); 
          _showErrorDialog('Mot de passe incorrect');
        }
      } else {
        debugPrint('User not found'); 
        _showErrorDialog('Utilisateur non trouvé');
      }
    } catch (e) {
      debugPrint('An error occurred: $e'); 
      _showErrorDialog('Une erreur est survenue. Réessayez.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Light Vinted')),
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,

      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _loginController,
              decoration: const InputDecoration(labelText: 'Identifiant'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Mot de passe'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loginUser,
              child: const Text('Se connecter'),
            ),
          ],
        ),
      ),
    );
  }
}

