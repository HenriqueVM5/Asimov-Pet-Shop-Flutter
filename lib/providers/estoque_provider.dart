import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_shop_app/models/estoque_item.dart';

//provider que cria uma lista global do estoque
//StreamProvider para pegar dados dirteto do firebase 24h e conseguir manter a lista atualizada
//independente de a atualizção da lista ser via desk ou via mobile

final produtosProvider = StreamProvider<List<Estoque>>((ref) {
  // Conexão coma a coleção 'Estoque' do Firebase via snapshots para atualizar a lista constantemente
  return FirebaseFirestore.instance
      .collection('estoque')
      .snapshots()
      .map((snapshot) {
    // Transforma os dados do Firebase em uma Lista de estoque atravez da funçao Estoque.fromMap criada no model Estoque
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Estoque.fromMap(data);
    }).toList();
  });
});