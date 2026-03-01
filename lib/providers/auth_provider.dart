import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/funcionarios_item.dart'; // Ajuste o caminho se a sua pasta for diferente

class AuthProvider extends ChangeNotifier {
  bool isLoading = false;

  // Função que retorna uma string (se deu errado) ou null (se deu certo)
  Future<String?> cadastrarUsuario(Funcionario funcionario) async {
    try {
      isLoading = true;
      notifyListeners(); // Avisa a tela para carregar

      // 1. Cria a conta no Firebase Auth
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: funcionario.email,
        password: funcionario.senha,
      );

      // 2. Salva o restante dos dados no Firestore
      await FirebaseFirestore.instance
          .collection('funcionarios')
          .doc(funcionario.email)
          .set(funcionario.toMap());

      isLoading = false;
      notifyListeners();

      return null; // null = sucesso
    } on FirebaseAuthException catch (e) {
      isLoading = false;
      notifyListeners();

      // Tratamento de exceptions
      if (e.code == 'email-already-in-use') {
        return 'Este e-mail já esta cadastrado.';
      } else if (e.code == 'weak-password') {
        return 'A senha é muito fraca.';
      }
      return 'Erro ao criar conta no Firebase.';
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return 'Erro inesperado: $e'; // Erro genérico
    }
  }
}
