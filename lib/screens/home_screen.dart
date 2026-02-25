import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final String nomeUsuario;

  const HomeScreen({super.key, required this.nomeUsuario}) ;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      
      //aparece o nome do usuario logado por enquanto para teste
      body: Center(
        child: Text(
          'Você está logado como o usuário: \n$nomeUsuario',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}