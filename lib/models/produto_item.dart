class Produto {
  final String nome;
  final String tipo;
  final String marca;
  final DateTime dataCad;
  final DateTime dataEdit;
  final String userEdit; // E-mail do funcionário que editou
  final String descricao;
  final String? cod; // Opcional (sem asterisco no UML)

  Produto({
    required this.nome,
    required this.tipo,
    required this.marca,
    required this.dataCad,
    required this.dataEdit,
    required this.userEdit,
    required this.descricao,
    this.cod,
  });

  // Puxar as informações plain text do firebase afim de serem utilizadas como atributos da classe em questão.
  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'tipo': tipo,
      'marca': marca,
      // Convertendo a data para texto padrão (ISO) pro Firebase entender
      'dataCad': dataCad.toIso8601String(),
      'dataEdit': dataEdit.toIso8601String(),
      'userEdit': userEdit,
      'descricao': descricao,
      'cod': cod,
    };
  }

  // Puxar as informações plain text do firebase afim de serem utilizadas como atributos da classe em questão.
  factory Produto.fromMap(Map<String, dynamic> map) {
    return Produto(
      nome: map['nome'] ?? '',
      tipo: map['tipo'] ?? '',
      marca: map['marca'] ?? '',
      dataCad: DateTime.parse(map['dataCad']),
      dataEdit: DateTime.parse(map['dataEdit']),
      userEdit: map['userEdit'] ?? '',
      descricao: map['descricao'] ?? '',
      cod: map['cod'],
    );
  }
}
