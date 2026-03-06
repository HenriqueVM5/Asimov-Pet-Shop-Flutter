import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pet_shop_app/screens/login_screen.dart';
import 'package:pet_shop_app/widgets/recuperar_senha.dart';
import 'package:provider/provider.dart';
import 'package:pet_shop_app/providers/auth_provider.dart' as app_auth;
import 'package:pet_shop_app/screens/cadastro_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const PetShopApp());
}

class PetShopApp extends StatelessWidget {
  const PetShopApp();

  @override
  Widget build(BuildContext context) {
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
        home: const CadastroScreen(),
      ),
    );
  }
}
