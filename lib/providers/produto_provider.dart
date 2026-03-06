import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_shop_app/models/produto_item.dart';

//provider que cria uma lista global de produtos
//StreamProvider para pegar dados dirteto do firebase 24h e conseguir manter a lista atualizada
//independente de a atualizção da lista ser via desk ou via mobile

final produtosProvider = StreamProvider<List<Produto>>((ref) {
  // Conexão coma a coleção 'produtos' do Firebase via snapshots para atualizar a lista constantemente
  return FirebaseFirestore.instance
      .collection('produto')
      .snapshots()
      .map((snapshot) {
    // Transforma os dados do Firebase em uma Lista de Produtos atravez da funçao Produto.fromMap criada no model produtos
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Produto.fromMap(data);
    }).toList();
  });
});