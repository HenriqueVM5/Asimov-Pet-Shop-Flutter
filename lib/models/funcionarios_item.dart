enum Perfil { administrador, estoquista, leitor }

class Funcionario {
  final String nome;
  final String email;
  final String senha;
  final String codFunc;
  final Perfil perfil;

  Funcionario({
    required this.nome,
    required this.email,
    required this.senha,
    required this.codFunc,
    required this.perfil,
  });

  // Puxar as informações plain text do firebase afim de serem utilizadas como atributos da classe em questão.
  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'email': email,
      'codFunc': codFunc,
      'perfil': perfil.name, // transforma o enum em texto
    };
  }

  // Puxar as informações plain text do firebase afim de serem utilizadas como atributos da classe em questão.
  factory Funcionario.fromMap(Map<String, dynamic> map) {
    return Funcionario(
      nome: map['nome'] ?? '',
      email: map['email'] ?? '',
      codFunc: map['codFunc'] ?? '',
      senha: '', // O firebase armazena a senha, não precisamos dela.

      perfil: Perfil.values.firstWhere(
        (e) => e.name == map['perfil'],
        orElse: () => Perfil.leitor,
      ),
    );
  }
}
