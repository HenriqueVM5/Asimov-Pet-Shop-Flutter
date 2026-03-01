import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pet_shop_app/screens/login_screen.dart';

//

class PagInicialScreen extends StatelessWidget {
  const PagInicialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
    // config do gradiente do topo da tela 
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight, 
            end: Alignment.bottomLeft, 
            colors: [
              Color(0xFF8AD8FF), // Azul claro no topo
              Color(0xFFFFFFFF), // Branco embaixo
            ],
            stops: [0.0, 0.40], 
          ),
        ),
       //safeArea e fitbox para ajustar proporcionalmente a tela a quaquer aparelho
        child: SafeArea(
          child: Center(
            child: FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: 375, // Tamanho base do Figma
                height: 812, //Altura base do Figma
                child: Stack(
                  //Clip.none para ajustar a imagem ate o final da tela
                  clipBehavior: Clip.none, 
                  children: [
                    
                    
                  //Vetor atras do cachorro e gato
                    Positioned(
                      top: 150,
                      left: -15,
                      right: -55, 
                      child: Opacity(
                        opacity: 0.8,
                        child: SvgPicture.asset(
                          "assets/Vector 1.svg", 
                          height: 500,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    
                  // Logo e nome da empresa no topo
                    Positioned(
                      top: 100,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset("assets/Vector.svg", width: 60),
                          const SizedBox(width: 8),
                          const Text(
                            "Habitat Pet",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),

                  //bola + osso + mancha do topo
                    Positioned(
                      top: 50,
                      right: 24,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Opacity(
                            opacity: 0.8,
                            child: SvgPicture.asset("assets/Vector 4.svg", width: 55, height: 55),
                          ),
                          Image.asset("assets/brinquedo-de-estimacao 2.png", width: 35, height: 35),
                        ],
                      ),
                    ),

                    
                  // Config cachorro e gato
                    //cachorro 
                    Positioned(
                      top: 167,
                      right: -35, 
                      child: Image.asset(
                        "assets/Adobe Express - file 1.png",
                        width: 250,
                      ),
                    ),
                    // Gato 
                    Positioned(
                      top: 342,
                      right: 65, 
                      child: Image.asset(
                        "assets/alexander-london-mJaD10XeD7w-unsplash-Photoroom 1.png",
                        width: 190,
                      ),
                    ),

                    
                  // Patinhas
                    Positioned(top: 260, left: 150, child: Image.asset("assets/patas 1.png", width: 31)),
                    Positioned(top: 275, left: 125, child: Image.asset("assets/patas 2.png", width: 33)),
                    Positioned(top: 300, left: 160, child: Image.asset("assets/patas 3.png", width: 30)),
                    Positioned(top: 285, left: 184, child: Image.asset("assets/patas 4.png", width: 28)),


                  //Ícones flutuantes + machas
                   //pote de ração
                   Positioned(
                      top: 340, 
                      left: 30,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Transform.translate(
                            offset: const Offset(0, 10), 
                            child: Opacity(
                              opacity: 0.8,
                              child: SvgPicture.asset("assets/Vector 6.svg", width: 42, height: 42),
                            ),
                          ),//transfor.tranlate para poder posicionar o desenho em relação a mancha
                          Image.asset("assets/racao-para-animais 2.png", width: 40, height: 40),
                        ],
                      ),
                    ),
                    
                    //bolinhas
                    Positioned(
                      top: 440, 
                      left: 80,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Transform.translate(
                            offset: const Offset(7, 0), 
                            child: Opacity(
                              opacity: 0.8,
                              child: SvgPicture.asset("assets/Vector 2.svg", width: 40, height: 40),
                            ),
                          ),//transfor.tranlate para poder posicionar o desenho em relação a mancha
                          Image.asset("assets/bola-de-cachorro 2.png", width: 45, height: 45), 
                        ],
                      ),
                    ),

                    //pacote de ração
                    Positioned(
                      top: 540, 
                      left: 60,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Transform.translate(
                            offset: const Offset(0, 11),
                            child: Opacity(
                              opacity: 0.8,
                              child: SvgPicture.asset("assets/Vector 7.svg", width: 41, height: 41), 
                            ),
                          ),//transfor.tranlate para poder posicionar o desenho em relação a mancha
                          Image.asset("assets/racao-para-animais-de-estimacao 2.png", width: 43, height: 43), 
                        ],
                      ),
                    ),

                    
                   //Botões
                    //Botão de cadastro
                    Positioned(
                      bottom: 40,
                      left: 24,
                      right: 24,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(), //substituir pelo pag de cadsatro assim q pronta
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8AD8FF).withValues(alpha: 0.8), 
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              'Cadastrar',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E3A4C), 
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 16),

                          //Botão de Login
                          OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(
                                color: Color(0xFF1E3A4C),
                                width: 2.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E3A4C),
                              ),
                            ),
                          ),
                        ],
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