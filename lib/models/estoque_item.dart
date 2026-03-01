import 'package:cloud_firestore/cloud_firestore.dart';

class Estoque {
  final String produtoId; // Referência ao ID do Produto no Firebase
  final String lote;
  final int qtd;
  final DateTime dataVal;
  final DateTime dataCad;
  final DateTime dataUltEdit;
  final String userEdit; // E-mail do funcionário que editou

  Estoque({
    required this.produtoId,
    required this.lote,
    required this.qtd,
    required this.dataVal,
    required this.dataCad,
    required this.dataUltEdit,
    required this.userEdit,
  });

  // Transforma as informações da classe para plain text afim de ser armazenada no firebase
  Map<String, dynamic> toMap() {
    return {
      'produtoId': produtoId,
      'lote': lote,
      'qtd': qtd,
      'dataVal': dataVal.toIso8601String(),
      'dataCad': dataCad.toIso8601String(),
      'dataUltEdit': dataUltEdit.toIso8601String(),
      'userEdit': userEdit,
    };
  }

  // Puxar as informações plain text do firebase afim de serem utilizadas como atributos da classe em questão.
  factory Estoque.fromMap(Map<String, dynamic> map) {
    return Estoque(
      produtoId: map['produtoId'] ?? '',
      lote: map['lote'] ?? '',
      qtd: map['qtd']?.toInt() ?? 0,
      dataVal: (map['dataVal'] as Timestamp).toDate(),
      dataCad: (map['dataCad'] as Timestamp).toDate(),
      dataUltEdit: (map['dataUltEdit'] as Timestamp).toDate(),
      userEdit: map['userEdit'] ?? '',
    );
  }
}
