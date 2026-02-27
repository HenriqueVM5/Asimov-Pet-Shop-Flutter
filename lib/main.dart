import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/login_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  // inicializa os widgets do Flutter antes do Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Firebase
  await Firebase.initializeApp();

  runApp(ProviderScope(child: PetShopApp()));
}

class PetShopApp extends StatelessWidget {
  const PetShopApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pet Shop Asimov',
      // Configuração de Tema Global do App
      theme: ThemeData(
        primarySwatch: Colors.blue, // Substituir depois que escolher a cor
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
      home: const LoginScreen(), // Define a tela inicial
    );
  }
}
