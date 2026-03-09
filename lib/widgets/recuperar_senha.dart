import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class RecuperarSenhaDialog extends StatefulWidget {
  const RecuperarSenhaDialog({super.key});

  @override
  State<RecuperarSenhaDialog> createState() => _RecuperarSenhaDialogState();
}

class _RecuperarSenhaDialogState extends State<RecuperarSenhaDialog> {
  final _emailRecuperacaoController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailRecuperacaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 24,
              right: 24,
              top: 32,
              bottom: 70,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Redefina a sua senha',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF365665),
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  'Informe seu email para receber um codigo e recuperar seu acesso',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 32),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Email',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF838383),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 4),

                SizedBox(
                  height: 44,
                  child: TextField(
                    controller: _emailRecuperacaoController,
                    keyboardType: TextInputType.emailAddress,
                    style: GoogleFonts.poppins(color: Colors.black),
                    decoration: InputDecoration(
                      suffixIcon: const Icon(
                        Icons.email_outlined,
                        color: Colors.black,
                        size: 20,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 0,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Color(0xFF838383),
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Color(0xFF365665),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _enviarEmailRecuperacao,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8AD8FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 0,
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF365665),
                                ),
                              ),
                            )
                          : Text(
                              'Enviar link de recuperação',
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF365665),
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // IMAGEM DE DECORAÇÃO
          Positioned(
            bottom: 15,
            right: 20,
            child: Transform.rotate(
              angle: 0,
              child: Image.asset(
                'assets/images/pote_racao.png',
                height: 55,
                errorBuilder: (context, error, stackTrace) => const SizedBox(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _enviarEmailRecuperacao() async {
    final email = _emailRecuperacaoController.text.trim();

    // Validação básica do email
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, digite um email'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final resultado = await authProvider.sendPasswordResetEmail(email);

    setState(() {
      _isLoading = false;
    });

    if (resultado == null) {
      // Sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Email enviado para $email. Verifique sua caixa de entrada.',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
      // Fecha o diálogo após sucesso
      Navigator.of(context).pop();
    } else {
      // Erro
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resultado),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
}
