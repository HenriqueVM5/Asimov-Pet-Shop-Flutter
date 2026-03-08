import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'fundo_padrao.dart';

//codigo que add sobre o fundo_padão as decorações em comum das telas que não estão nos forms

class FundoTelas extends StatelessWidget {
  final Widget child;
  final Widget? bottomNavigationBar;
  final String? titulo;

  const FundoTelas({
    super.key,
    required this.child,
    this.bottomNavigationBar,
    this.titulo,
  });

  @override
  Widget build(BuildContext context) {
    return FundoPadrao(
      bottomNavigationBar: bottomNavigationBar,
      decoracoes: [
        //Logo
        Positioned(
          top: 60,
          left: 0,
          right: 0,
          child: Center(
            child: Image.asset("assets/images/Header.png", height: 75),
          ),
        ),

        // Pote de ração perto da logo
        Positioned(
          top: 75,
          right: 20,
          child: Image.asset("assets/images/pote_padrao.png", width: 80),
        ),

        // Bolinhas brancas abaixo do titulo
        Positioned(
          top: 190,
          left: 30,
          child: Image.asset("assets/images/bolinhas_branco.png", width: 75),
        ),

        // Saco de ração azul
        Positioned(
          top: 200,
          right: 35,
          child: Image.asset("assets/images/racao_ae.png", width: 70),
        ),

        //Titullo da tela
        if (titulo != null)
          Positioned(
            top: 155,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                titulo!,
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),
          ),
      ],

      // Conteudo da tela vindo das telas proprias de cada aba
      // Paddin para que o conteudo seja escrito somente abaixo do titulo da tela
      child: Padding(
        padding: const EdgeInsets.only(
          top: 200.0,
        ), // conteudo da tela aoarece desse ponto para baixo
        child: child,
      ),
    );
  }
}
