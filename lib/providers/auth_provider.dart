import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/funcionarios_item.dart';
import 'package:google_sign_in/google_sign_in.dart' as googleAuth;

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

  Future<String?> signInWithGoogle() async {
    try {
      isLoading = true;
      notifyListeners();

      final googleAuth.GoogleSignIn googleSignIn =
          googleAuth.GoogleSignIn.instance;
      await googleSignIn.initialize();

      final googleAuth.GoogleSignInAccount googleUser = await googleSignIn
          .authenticate(scopeHint: ['email']);

      final googleAuth.GoogleSignInAuthentication googleAuthKeys =
          googleUser.authentication;

      final String? idToken = googleAuthKeys.idToken;
      if (idToken == null) {
        isLoading = false;
        notifyListeners();
        return 'Não foi possível obter idToken do Google.';
      }

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      isLoading = false;
      notifyListeners();
      return null;
    } on googleAuth.GoogleSignInException catch (e) {
      isLoading = false;
      notifyListeners();
      if (e.code == googleAuth.GoogleSignInExceptionCode.canceled) {
        return 'Login cancelado pelo usuário.';
      }
      return 'Erro no Google Sign-In: ${e.description ?? e.code}';
    } on FirebaseAuthException catch (e) {
      isLoading = false;
      notifyListeners();
      return 'Erro na autenticação: ${e.message}';
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return 'Erro inesperado: $e';
    }
  }
}
