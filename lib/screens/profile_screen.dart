import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // Obter usuário logado
      final user = FirebaseAuth.instance.currentUser;
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
      // Em caso de erro, pode mostrar um snackbar ou log
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
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: Color(0xFF0A3351),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
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
                const SizedBox(height: 16),
                _buildCampoPerfil(
                  label: 'Email',
                  controller: _emailController,
                  icone: Icons.lock,
                  readOnly: true,
                ),
                const SizedBox(height: 16),
                _buildCampoPerfil(
                  label: 'Cargo',
                  controller: _cargoController,
                  icone: Icons.lock,
                  readOnly: true,
                ),
                const SizedBox(height: 48),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      print("Salvando alterações do perfil...");
                      // TODO: Chamar Provider para salvar no Firestore
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
        // Texto da Label (Ex: Nome, Email)
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
