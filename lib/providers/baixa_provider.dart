import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_shop_app/models/baixa_item.dart';

//provider que cria uma lista global das baixas
//StreamProvider para pegar dados dirteto do firebase 24h e conseguir manter a lista atualizada
//independente de a atualizção da lista ser via desk ou via mobile

final baixaProvider = StreamProvider<List<Baixa>>((ref) {
  // Conexão coma a coleção 'baixa' do Firebase via snapshots para atualizar a lista constantemente
  return FirebaseFirestore.instance
      .collection('baixas')
      .snapshots()
      .map((snapshot) {
    // Transforma os dados do Firebase em uma Lista de estoque atravez da funçao baixa.fromMap criada no model baixa
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Baixa.fromMap(data);
    }).toList();
  });
});