import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/auth_provider.dart';
import '../screens/pag_inicial_screen.dart';

class TelaPerfil extends StatefulWidget {
  const TelaPerfil({super.key});

  @override
  State<TelaPerfil> createState() => _TelaPerfilState();
}

class _TelaPerfilState extends State<TelaPerfil> {
  // Controladores para os campos
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _cargoController = TextEditingController();

  AuthProvider? _authProvider;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _authProvider = AuthProvider();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      // Obter usuário logado
      if (user != null) {
        _emailController.text = user.email ?? '';
        // Buscar dados do Firestore
        final doc = await FirebaseFirestore.instance
            .collection('funcionarios')
            .doc(user.email)
            .get();
        if (doc.exists) {
          final data = doc.data()!;
          _nomeController.text = data['nome'] ?? '';
          _cargoController.text = (data['perfil'] ?? '').toString();
        } else {
          _nomeController.text = user.displayName ?? '';
          _cargoController.text = '';
        }
      }
    } catch (e) {
      print("Erro ao carregar perfil: $e");
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _cargoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.only(left: 24, right: 24, bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 104,
                        height: 104,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD9D9D9),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF365665),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                _buildCampoPerfil(
                  label: 'Nome',
                  controller: _nomeController,
                  icone: Icons.edit_outlined,
                ),

                const SizedBox(height: 12), // Reduzido de 16 para 12

                _buildCampoPerfil(
                  label: 'Email',
                  controller: _emailController,
                  icone: Icons.lock,
                  readOnly: true,
                ),

                const SizedBox(height: 12), // Reduzido de 16 para 12

                _buildCampoPerfil(
                  label: 'Cargo',
                  controller: _cargoController,
                  icone: Icons.lock,
                  readOnly: true,
                ),

                const SizedBox(
                  height: 32,
                ),
                // Botão de Salvar Alterações
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      final novoNome = _nomeController.text.trim();

                      if (novoNome.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('O nome não pode ficar vazio.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      setState(() {
                        _isLoading = true;
                      });

                      final erro = await _authProvider?.updateNomeUsuario(
                        novoNome,
                      );

                      setState(() {
                        _isLoading = false;
                      });

                      if (!mounted) return;

                      if (erro == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Perfil atualizado com sucesso!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(erro),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8AD8FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Salvar alterações',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF0A3351),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),
                // Botão de Log out
                Center(
                  child: SizedBox(
                    width: 198,
                    height: 40,
                    child: OutlinedButton(
                      onPressed: () async {
                        // Faz o logout pelo Firebase
                        await FirebaseAuth.instance.signOut();

                        // Verifica se a tela ainda está montada antes de navegar
                        if (!mounted) return;

                        // Redireciona para a tela inicial e limpa a pilha de telas anteriores
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PagInicialScreen(),
                          ),
                          (Route<dynamic> route) => false,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color(0xFF365665),
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: Text(
                        'Log out',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFFF262B),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
  }

  Widget _buildCampoPerfil({
    required String label,
    required TextEditingController controller,
    required IconData icone,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          style: GoogleFonts.poppins(
            color: readOnly ? Colors.black54 : Colors.black,
          ),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 14,
            ),
            filled: true,
            fillColor: Colors.white,
            suffixIcon: Icon(icone, color: const Color(0xFF365665), size: 20),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: const BorderSide(
                color: Color(0xFF365665),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}