import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';


import 'package:pet_shop_app/screens/pag_inicial_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:provider/provider.dart';
import 'package:pet_shop_app/providers/auth_provider.dart' as app_auth;


void main() async {
  // Garante que o Flutter está pronto antes de chamar o Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Firebase 
  await Firebase.initializeApp();

  // Provider scope para o provider funcionae
  runApp(const ProviderScope(child: PetShopApp()));
}

class PetShopApp extends StatelessWidget {
  const PetShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiProvider para gerenciar a Autenticação
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => app_auth.AuthProvider()),
      ],
      child: MaterialApp(
        title: 'Pet Shop Asimov',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        home: const PagInicialScreen(), 
      ),
    );
  }
}