import 'package:cloud_firestore/cloud_firestore.dart';

class Produto {
  final String? id;
  final String nome;
  final String tipo;
  final String marca;
  final DateTime dataCad;
  final DateTime dataEdit;
  final String userEdit; // E-mail do funcionário que editou
  final String descricao;
  final String? cod; // Opcional (sem asterisco no UML)
  final double? preco; 

  Produto({
    this.id,
    required this.nome,
    required this.tipo,
    required this.marca,
    required this.dataCad,
    required this.dataEdit,
    required this.userEdit,
    required this.descricao,
    this.cod,
    required this.preco, 
  });

  // Transforma as informações da classe para plain text a fim de ser armazenada no firebase
  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'tipo': tipo,
      'marca': marca,
      // Convertendo a data para texto padrão (ISO) pro Firebase entender
      'dataCad': Timestamp.fromDate(dataCad),
      'dataEdit': Timestamp.fromDate(dataEdit),
      'userEdit': userEdit,
      'descricao': descricao,
      'cod': cod,
      'preco': preco, 
    };
  }

  // Puxar as informações plain text do firebase a fim de serem utilizadas como atributos da classe
  factory Produto.fromMap(Map<String, dynamic> map, String docId) {
    return Produto(
      nome: map['nome'] ?? '',
      tipo: map['tipo'] ?? '',
      marca: map['marca'] ?? '',
      dataCad: (map['dataCad'] as Timestamp).toDate(),
      dataEdit: (map['dataEdit'] as Timestamp).toDate(),
      userEdit: map['userEdit'] ?? '',
      descricao: map['descricao'] ?? '',
      cod: map['cod'] ?? '',
      preco: (map['preco'] ?? 0.0).toDouble(), //puxa o preço do firebase e passa pra double
      id: docId,
    );
  }
}