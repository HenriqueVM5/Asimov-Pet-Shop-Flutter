import 'package:flutter/material.dart';
import 'package:pet_shop_app/screens/login_screen.dart';
import 'package:pet_shop_app/screens/tela_principal.dart';
import '../models/funcionarios_item.dart';
import '../providers/auth_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide
        AuthProvider; // Se não ele estava dando conflito com o meu auth_provider
import 'package:provider/provider.dart';

/// Tela responsável pelo cadastro de novos usuários no sistema.
///
/// Esta tela:
/// - Coleta dados do usuário
/// - Valida o formulário
/// - Cria um objeto funcionário
/// - Envia os dados para o AuthProvider
/// - Exibe feedback visual (SnackBar)
/// - Retorna para a tela de login em caso de sucesso

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  /// Chave global para controle e validação do formulário
  final _formKey = GlobalKey<FormState>();

  /// Controllers responsáveis por controlar os campos de texto
  final _nomeController = TextEditingController();
  final _sobrenomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  /// Variável responsável pelo authprovider, que vai fazer tudo em cadastro.
  final AuthProvider _authProvider = AuthProvider();

  /// Método chamado quando a tela é destruída
  /// Libera memória dos controllers para evitar memory leaks
  @override
  void dispose() {
    _nomeController.dispose();
    _sobrenomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  /// Método responsável por executar o fluxo de cadastro
  ///
  /// Fluxo:
  /// 1. Valida o formulário
  /// 2. Cria o nome completo
  /// 3. Instancia um objeto funcionário
  /// 4. Chama o AuthProvider para registrar o usuário
  /// 5. Exibe feedback visual

  Future<void> _processarCadastro() async {
    /// Valida todos os campos do formulário
    if (_formKey.currentState!.validate()) {
      final nomeCompleto =
          '${_nomeController.text.trim()} ${_sobrenomeController.text.trim()}';

      /// Concatena nome e sobrenome

      /// Criação do objeto que representa o Funcionário
      final novoFuncionario = Funcionario(
        nome: nomeCompleto,
        email: _emailController.text.trim(),
        senha: _senhaController.text,
        codFunc: '',

        /// Começa vazio pois o admin edita depois
        perfil: Perfil.leitor,

        /// Todo usuário é criado como leitor por segurança
      );

      /// Pede pro provider cadastrar
      /// Se não der certo ele envia uma mensagem de erro, se retornar null é sucesso
      String? erro = await _authProvider.cadastrarUsuario(novoFuncionario);

      if (erro == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Conta criada com sucesso! Faça seu login'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          ); // Volta pro Login
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(erro), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFFFFF), Color(0xFF8AD8FF)],
            stops: [0.65, 1.0],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 70,
              right: 10,
              child: Image.asset('assets/images/Group_2.png', width: 90),
            ),

            /// ONDA + PATINHAS DO BOTTOM DA PÁGINA
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Image.asset(
                'assets/images/Group_1.png',
                fit: BoxFit.fitWidth,
              ),
            ),

            /// CONTEÚDO DA TELA
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      const SizedBox(height: 60),

                      // LOGO DO PET SHOP
                      Center(
                        child: Image.asset(
                          'assets/images/Header.png',
                          height: 75,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // TÍTULO "Olá! Seja bem-vindo"
                      Text(
                        'Olá! Seja bem-vindo',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Color(0xFF365665),
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // ICON DE PERFIL
                      Center(
                        child: Image.asset(
                          'assets/images/Frame.png',
                          height: 45,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // LINHA: NOME E SOBRENOME
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _nomeController,
                              style: GoogleFonts.poppins(fontSize: 12),
                              decoration: _buildInputDecoration(
                                'Primeiro nome',
                                Icons.badge_outlined,
                              ),
                              validator: (value) =>
                                  value!.isEmpty ? 'Obrigatório' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _sobrenomeController,
                              style: GoogleFonts.poppins(fontSize: 12),
                              decoration: _buildInputDecoration(
                                'Ultimo nome',
                                Icons.badge_outlined,
                              ),
                              validator: (value) =>
                                  value!.isEmpty ? 'Obrigatório' : null,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // CAMPO: EMAIL
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: GoogleFonts.poppins(fontSize: 12),
                        decoration: _buildInputDecoration(
                          'Email',
                          Icons.mail_outline,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Obrigatório';
                          if (!value.contains('@')) return 'E-mail inválido';
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // CAMPO: SENHA
                      TextFormField(
                        controller: _senhaController,
                        obscureText: true,
                        style: GoogleFonts.poppins(fontSize: 12),
                        decoration: _buildInputDecoration(
                          'Senha',
                          Icons.lock_outline,
                        ),
                        validator: (value) {
                          if (value == null || value.length < 6)
                            return 'Mínimo de 6 caracteres';
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // CAMPO: CONFIRMAR SENHA
                      TextFormField(
                        controller: _confirmarSenhaController,
                        obscureText: true,
                        style: GoogleFonts.poppins(fontSize: 12),
                        decoration: _buildInputDecoration(
                          'Confirme sua senha',
                          Icons.lock_outlined,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Obrigatório';
                          if (value != _senhaController.text)
                            return 'As senhas não coincidem';
                          return null;
                        },
                      ),

                      const SizedBox(height: 8),

                      // JÁ TEM LOGIN?
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Text.rich(
                            textAlign: TextAlign.center,
                            TextSpan(
                              text: 'Já tem conta? ',
                              style: GoogleFonts.poppins(
                                color: Colors.black,
                                fontSize: 12,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Log In',
                                  style: GoogleFonts.poppins(
                                    color: Color(0xFF6097B2),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // BOTÃO AZULÃO "CADASTRAR"
                      ListenableBuilder(
                        listenable: _authProvider,
                        builder: (context, child) {
                          return _authProvider.isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF0A3351),
                                  ),
                                )
                              : ElevatedButton(
                                  onPressed: _processarCadastro,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF8AD8FF),
                                    foregroundColor: const Color(0xFF0A3351),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(34),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 9.75,
                                    ),
                                  ),
                                  child: Text(
                                    'Cadastrar',
                                    style: GoogleFonts.poppins(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                );
                        },
                      ),

                      const SizedBox(height: 20),

                      // RODAPÉ: "Ou"
                      Row(
                        children: [
                          // Fita da esquerda
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(right: 15),
                              height: 1.20,
                              color: Colors.black,
                            ),
                          ),
                          // Texto central
                          Text(
                            'Ou',
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          // Fita da direita
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(left: 15),
                              height: 1.20,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo Google
                          GestureDetector(
                            onTap: () async {
                              final authProvider = Provider.of<AuthProvider>(
                                context,
                                listen: false,
                              );

                              final String? erro = await authProvider
                                  .signInWithGoogle();

                              if (erro != null) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(SnackBar(content: Text(erro)));
                                }
                              } else {
                                if (context.mounted) {
                                  // Substituído o pushNamed pelo RemoveUntil
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const TelaPrincipal(),
                                    ),
                                    (route) => false,
                                  );
                                }
                              }
                            },

                            child: Image.asset(
                              'assets/images/google_logo.png',
                              height: 50,
                            ),
                          ),
                          const SizedBox(
                            width: 80,
                          ), // Espaço entre os dois botões
                          // Logo Facebook
                          GestureDetector(
                            onTap: () {
                              /* Lógica de login Facebook */
                            },
                            child: Image.asset(
                              'assets/images/facebook_logo.png',
                              height: 50,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // A função auxiliar para o código não ficar gigante
  InputDecoration _buildInputDecoration(String hint, IconData icone) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFF838383),
        fontSize: 10,
        fontFamily: 'Poppins',
      ),
      suffixIcon: Icon(icone, color: const Color(0xFF838383), size: 18),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: Color(0xFF838383), width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: Color(0xFF8AD8FF), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }
}
