import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pet_shop_app/screens/pag_inicial_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  // inicializa os widgets do Flutter antes do Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Firebase
  await Firebase.initializeApp();

  runApp(ProviderScope(child: PetShopApp()));
}

class PetShopApp extends StatelessWidget {
  const PetShopApp({super.key});

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
      home: const PagInicialScreen(), // Define a tela inicial
    );
  }
}
