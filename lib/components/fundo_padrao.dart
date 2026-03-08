import 'package:flutter/material.dart';

// Código que define o background em comum das telas de home/perfil/produtos/estoque e dos formularios

class FundoPadrao extends StatelessWidget {
  final Widget child;
  final List<Widget> decoracoes;
  final Widget? bottomNavigationBar;

  const FundoPadrao({
    super.key,
    required this.child,
    this.decoracoes = const [],
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,

      backgroundColor: Colors.transparent,
      extendBody: true,
      bottomNavigationBar: bottomNavigationBar,

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF8AD8FF),
              Colors.white,
            ],
            stops: [0.0, 0.75],
          ),
        ),

        child: SafeArea(
          bottom: false,
          child: Center(
            child: FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: 375, // Tamanho padrão do Figma
                height: 812, // Tamanho padrão do Figma
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Onda azul no topo
                    Positioned(
                      top: -100,
                      right: -70,
                      child: Image.asset(
                        "assets/images/Vector12.png",
                        width: 550,
                        height: 550,
                        fit: BoxFit.contain,
                      ),
                    ),

                    // Brinquedos do rodapé
                    Positioned(
                      bottom: 80,
                      left: -50,
                      right: 50,
                      child: Image.asset(
                        "assets/images/Group11.png",
                        width: 70,
                        height: 70,
                        fit: BoxFit.contain,
                      ),
                    ),
                    // Patinhas
                    Positioned(
                      bottom: 140,
                      right: 90,
                      child: Image.asset(
                        "assets/images/pata_home.png",
                        width: 120,
                      ),
                    ),

                    // Decorações
                    ...decoracoes,

                    //soluçao para o teclado
                    Positioned.fill(
                      child: Padding(
                        padding: EdgeInsets.only(
                          // levanta o conteúdo apenas quando o teclado aparece
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                        child: child,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
