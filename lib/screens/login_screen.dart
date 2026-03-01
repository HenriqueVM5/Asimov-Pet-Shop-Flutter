import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_shop_app/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // captura do texto nos campos email e senha
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isLoading = false;

  // Função que executa o Login
  Future<void> _fazerLogin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      // Tenta autenticar no Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      // Se logou, busca o NOME no Firestore
      if (userCredential.user != null) {
        // Busca na coleção 'funcionarios' o documento onde o ID é o email
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('funcionarios')
            .doc(email)
            .get();

        String nomeDoUsuario = "Usuário Desconhecido";

        // Se existe nome de usuario salva ele na var nomeDoUsuario
        if (userDoc.exists) {
          nomeDoUsuario = userDoc.get('nome');
        }

        // Navega para a HomeScreen passando o nome
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(nomeUsuario: 'leo',),
            ),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      // Exibe msg de erra caso email ou senha estejam incoretos
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('E-mail ou senha incoretos')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Campo de email
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'E-mail'),
            ),
            const SizedBox(height: 16),
            // Campo de senha
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Senha'),
            ),
            const SizedBox(height: 24),
            // Botão de Logar
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _fazerLogin,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('LOGAR', style: TextStyle(fontSize: 16)),
                  ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}