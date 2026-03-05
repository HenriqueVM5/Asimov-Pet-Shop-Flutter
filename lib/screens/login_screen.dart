import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Chave do formulário
  final _formKey = GlobalKey<FormState>();

  bool _lembrarMe = false;

  // Controladores para capturar o que o usuário digitar
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  // Limpar memória
  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _fazerLogin() async {
    // Primeiro verifica se os campos não estão vazios
    if (_formKey.currentState!.validate()) {
      // Pega o provider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Chama a função de login criada no AuthProvider
      String? erro = await authProvider.loginUsuario(
        _emailController.text.trim(),
        _senhaController.text.trim(),
      );

      if (erro == null) {
        // Login com sucesso redireciona para a tela principal
        print("Login com e-mail feito com sucesso!");
        // TO-DO: Home
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(erro), backgroundColor: Colors.redAccent),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fundo Azul Sólido
      backgroundColor: const Color(0xFF8AD8FF),
      resizeToAvoidBottomInset: true,

      body: Stack(
        children: [
          // ONDAS
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            top: 0,
            child: Image.asset(
              'assets/images/ondas.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const SizedBox(),
            ),
          ),

          // ELEMENTOS GRÁFICOS INFERIORES
          Positioned(
            bottom: 50,
            left: -70,
            right: 0,
            child: Image.asset(
              'assets/images/elementosgraficos.png',
              height: 90,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const SizedBox(),
            ),
          ),

          // LOGO PET SHOP
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 80),
                child: Image.asset(
                  'assets/images/Header.png', // A logo preta vazada
                  height: 65,
                  errorBuilder: (context, error, stackTrace) => const Text(
                    'Habitat Pet',
                    style: TextStyle(
                      fontSize: 24,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF365665),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // CONTAINER BRANCO
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                  left: 26,
                  right: 26,
                  top: 92,
                  bottom: 20,
                ),

                // A CAIXA BRANCA
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Título "Login"
                            Text(
                              'Login',
                              style: GoogleFonts.inter(
                                color: Color(0xFF365665),
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                              ),
                            ),

                            const SizedBox(height: 30),

                            // Campo de Email
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: const TextStyle(color: Color(0xFF365665)),
                              decoration: _estiloCampo(
                                'Email',
                                Icons.email_outlined,
                              ),
                              validator: (value) =>
                                  value!.isEmpty ? 'Obrigatório' : null,
                            ),

                            const SizedBox(height: 2),

                            // Campo de Senha
                            TextFormField(
                              controller: _senhaController,
                              obscureText: true,
                              style: const TextStyle(color: Color(0xFF365665)),
                              decoration: _estiloCampo(
                                'Senha',
                                Icons.visibility_outlined,
                              ),
                              validator: (value) =>
                                  value!.isEmpty ? 'Obrigatório' : null,
                            ),

                            const SizedBox(height: 2),

                            // Checkbox "Lembrar-me" e "Esqueceu a senha?"
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: Checkbox(
                                        value: _lembrarMe,
                                        onChanged: (novoValor) {
                                          setState(() {
                                            _lembrarMe = novoValor!;
                                          });
                                        },
                                        activeColor: const Color(0xFF365665),
                                      ),
                                    ),
                                    const SizedBox(width: 1),
                                    Text(
                                      'Lembrar - me',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () => print("Recuperação de senha"),
                                  child: const Text(
                                    'Esqueceu a senha?',
                                    style: TextStyle(
                                      color: Color(0xFF6097B2),
                                      fontSize: 12,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 19),

                            // Botões "Entrar" e "Cadastrar"
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _fazerLogin,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF8AD8FF),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: Text(
                                      'Entrar',
                                      style: GoogleFonts.poppins(
                                        color: Color(0xFF365665),
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => print("Ir para Cadastro"),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      side: const BorderSide(
                                        color: Color(0xFF365665),
                                        width: 4.5,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                    ),
                                    child: Text(
                                      'Cadastrar',
                                      style: GoogleFonts.poppins(
                                        color: Color.fromARGB(255, 0, 0, 0),
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 15),

                            // RODAPÉ: "Ou"
                            Row(
                              children: [
                                // Fita da esquerda
                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 15),
                                    height: 1,
                                    color: Colors.black,
                                  ),
                                ),
                                // Texto central
                                Text(
                                  'Ou',
                                  style: GoogleFonts.poppins(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                // Fita da direita
                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.only(left: 15),
                                    height: 1,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 5),

                            // Botões Sociais (Google / Facebook)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () => print("Login Google"),
                                  child: CircleAvatar(
                                    radius: 24,
                                    backgroundColor: Colors.transparent,
                                    child: Image.asset(
                                      'assets/images/google_logo.png',
                                      height: 65,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 70),
                                GestureDetector(
                                  onTap: () => print("Login Facebook"),
                                  child: const CircleAvatar(
                                    radius: 24,
                                    backgroundColor: Colors.transparent,
                                    child: Icon(
                                      Icons.facebook,
                                      size: 48,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 0),
                          ],
                        ),
                      ),
                    ),

                    Positioned(
                      top: -65,
                      right: 10,
                      child: Transform.rotate(
                        angle: -0.05,
                        child: Image.asset(
                          'assets/images/patas_juntas.png',
                          height: 100,
                        ),
                      ),
                    ),

                    Positioned(
                      top: 15,
                      right: 260,
                      child: Transform.rotate(
                        angle: -0.05,
                        child: Image.asset(
                          'assets/images/racao.png',
                          height: 60,
                        ),
                      ),
                    ),

                    Positioned(
                      top: -220,
                      right: 50,
                      child: Transform.rotate(
                        angle: -0.05,
                        child: Image.asset(
                          'assets/images/pote_racao.png',
                          height: 68,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// O FORMULÁRIO

// ==========================================
// ESTILO DOS CAMPOS DE TEXTO
// ==========================================
InputDecoration _estiloCampo(String label, IconData icone) {
  return InputDecoration(
    hintText: label,
    hintStyle: const TextStyle(
      color: Color(0xFF6097B2),
      fontSize: 14,
      fontFamily: 'Poppins',
    ),
    suffixIcon: Icon(icone, color: const Color(0xFF365665), size: 22),
    helperText: ' ',
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(24),
      borderSide: const BorderSide(color: Color(0xFF365665), width: 1.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(24),
      borderSide: const BorderSide(color: Color(0xFF365665), width: 2.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(24),
      borderSide: const BorderSide(color: Colors.redAccent, width: 2),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(24),
      borderSide: const BorderSide(color: Colors.redAccent, width: 2.5),
    ),
  );
}
