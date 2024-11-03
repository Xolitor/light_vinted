import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tflite_flutter/tflite_flutter.dart'; 
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'dart:convert'; 

class AddClothingPage extends StatefulWidget {
  const AddClothingPage({super.key});

  @override
  _AddClothingPageState createState() => _AddClothingPageState();
}

class _AddClothingPageState extends State<AddClothingPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  String _category = ''; 
  late Interpreter _interpreter;

  final Map<int, String> _labels = {
    0: 'Chapeau',
    1: 'Pantalon',
    2: 'Chaussure',
    3: 'T-Shirt',
  };
 
  @override
  void initState() {
    super.initState();
    _loadModel();
    _imageUrlController.addListener(() {
      if (_imageUrlController.text.isNotEmpty) {
        _predictCategoryFromImage();
      }
    });
  }

  @override
  void dispose() {
    _interpreter.close();
    super.dispose();
  }

  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/classifier.tflite');
      debugPrint('Model loaded successfully');
    } catch (e) {
      debugPrint('Failed to load model: $e');
    }
  }

  Future<Uint8List> _loadImageFromUrl(String url) async {
    try {
      if (url.startsWith('data:image')) {
        String base64String = url.split(',')[1]; 
        return base64Decode(base64String);
      } else {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          return response.bodyBytes;
        } else {
          throw Exception('Failed to load image: HTTP ${response.statusCode}');
        }
      }
    } catch (e) {
      debugPrint('Error loading image: $e');
      rethrow;
    }
  }
  List<List<List<List<double>>>> _preprocessImage(Uint8List imageData) {
    img.Image? image = img.decodeImage(imageData);
    if (image == null) throw Exception('Failed to decode image');

    img.Image resizedImage = img.copyResize(image, width: 224, height: 224);

    var input = List.generate(
      1,
      (index) => List.generate(
        224,
        (y) => List.generate(
          224,
          (x) {
            var pixel = resizedImage.getPixel(x, y);
            return [
              pixel.r / 255.0,
              pixel.g / 255.0,
              pixel.b / 255.0,
            ];
          },
        ),
      ),
    );

    return input;
  }

  Future<void> _predictCategoryFromImage() async {
    try {
      Uint8List imageData = await _loadImageFromUrl(_imageUrlController.text);
      var input = _preprocessImage(imageData);

      var output = List.filled(1 * 4, 0.0).reshape([1, 4]);
      _interpreter.run(input, output);

      int predictedIndex = 0;
      double maxProb = output[0][0];
      for (int i = 1; i < output[0].length; i++) {
        if (output[0][i] > maxProb) {
          maxProb = output[0][i];
          predictedIndex = i;
        }
      }

      setState(() {
        _category = _labels[predictedIndex] ?? 'Unknown';
      });

      debugPrint('Predicted category: $_category');
    } catch (e) {
      debugPrint('Prediction error: $e');
      setState(() {
        _category = 'Error predicting category';
      });
    }
  }

  Future<void> _saveClothingData() async {
    if (_imageUrlController.text.isEmpty ||
        _titleController.text.isEmpty ||
        _sizeController.text.isEmpty ||
        _brandController.text.isEmpty ||
        _priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs.')),
      );
      return;
    }

    try {
      await _firestore.collection('clothes').add({
        'title': _titleController.text,
        'imageUrl': _imageUrlController.text,
        'category': _category,
        'size': _sizeController.text,
        'brand': _brandController.text,
        'price': _priceController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vêtement ajouté avec succès.')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de l\'ajout du vêtement.')),
      );
    }
  }

  bool _isBase64Image(String url) {
    return url.startsWith('data:image');
  }

  Widget _buildImagePreview() {
    if (_imageUrlController.text.isEmpty) {
      return Container(
        height: 150,
        width: 150,
        color: Colors.grey[300],
        child: const Icon(Icons.image, size: 50),
      );
    }

    return Container(
      height: 150,
      width: 150,
      child: _isBase64Image(_imageUrlController.text)
          ? Image.memory(
              base64Decode(_imageUrlController.text.split(',')[1]),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                debugPrint('Error loading base64 image: $error');
                return const Icon(Icons.error, size: 50);
              },
            )
          : Image.network(
              _imageUrlController.text,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                debugPrint('Error loading network image: $error');
                return const Icon(Icons.error, size: 50);
              },
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un Vêtement'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Image URL',
                ),
              ),
              const SizedBox(height: 16),

              Center(
                child: _buildImagePreview(),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Titre'),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: TextEditingController(text: _category),
                decoration: const InputDecoration(labelText: 'Catégorie'),
                readOnly: true,
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _sizeController,
                decoration: const InputDecoration(labelText: 'Taille'),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _brandController,
                decoration: const InputDecoration(labelText: 'Marque'),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Prix'),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
                ],
              ),
              const SizedBox(height: 32),

              Center(
                child: ElevatedButton(
                  onPressed: _saveClothingData,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}