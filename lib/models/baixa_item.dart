import 'package:cloud_firestore/cloud_firestore.dart';

class Baixa {
  final String itemEstId; // Referência ao ID do lote no Estoque
  final int qtd;
  final DateTime data;
  final String user; // E-mail do funcionário que deu a baixa
  final String motivo; 

  Baixa({
    required this.itemEstId,
    required this.qtd,
    required this.data,
    required this.user,
    required this.motivo,
  });

  // Transforma as informações da classe para plain text afim de ser armazenada no firebase
  Map<String, dynamic> toMap() {
    return {
      'itemEstId': itemEstId,
      'qtd': qtd,
      'data': Timestamp.fromDate(data),
      'user': user,
      'motivo': motivo,
    };
  }

  // Puxar as informações plain text do firebase afim de serem utilizadas como atributos da classe em questão.
  factory Baixa.fromMap(Map<String, dynamic> map) {
    return Baixa(
      itemEstId: map['itemEstId'] ?? '',
      qtd: map['qtd']?.toInt() ?? 0,
      data: (map['data'] as Timestamp).toDate(),
      user: map['user'] ?? '',
      motivo: map['motivo'] ?? '',
    );
  }
}
