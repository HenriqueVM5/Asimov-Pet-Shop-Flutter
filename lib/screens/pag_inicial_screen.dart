import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pet_shop_app/screens/login_screen.dart';
import 'package:pet_shop_app/screens/tela_principal.dart';

//codigo da tela inicial
//botão de login leva a tela de login e botão de cadastro a tela de cadastro

class PagInicialScreen extends StatelessWidget {
  const PagInicialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       
      
      body: Container(
        //criação do background com gradiente assim como no figma
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight, 
            end: Alignment.bottomLeft, 
            colors: [
              Color(0xFF8AD8FF), 
              Color(0xFFFFFFFF), 
            ],
            stops: [0.0, 0.40], 
          ),
        ),
        //safeare e fittedbox para adaptar a tela de acordo com o tamnho do display
        child: SafeArea(
          child: Center(
            child: FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: 375, // Tamanho base do figma usado para fazer a proporção das imagens
                height: 812, // Altura base do figma
                child: Stack(
                  clipBehavior: Clip.none, 
                  children: [
                    
                    
                    // Config animais + vetor fundo, valores atravez de teste
                    Positioned(
                      top: 110, 
                      right: -39, 
                      child: Image.asset(
                        "assets/images/animais.png",
                        width: 430, 
                      ),
                    ),

                    
                    //config HEADER (Logo + Nome)
                    Positioned(
                      top: 60,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Image.asset(
                          "assets/images/Header.png",
                          height: 75, 
                        ),
                      ),
                    ),

                    
                    // Bola e Osso do topo
                    Positioned(
                      top: 45,
                      right: 24,
                      child: Image.asset(
                        "assets/images/bola_osso_topo.png",
                        width: 55, 
                      ),
                    ),

                    
                    // Patinhas 
                    Positioned(
                      top: 250,
                      left: 115, 
                      child: Image.asset(
                        "assets/images/patas.png", 
                        width: 90,
                      ),
                    ),


                    // Brinquedos ao lado dos animais
                    Positioned(
                      top: 315, 
                      left: 10, 
                      child: Image.asset(
                        "assets/images/elementos_graficos_ini.png", 
                        width: 120, 
                      ),
                    ),


                    //Botões
                    Positioned(
                      bottom: 30,
                      left: 24,
                      right: 24,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          
                          // Botão de cadastrar
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const TelaPrincipal(), 
                                ),// Alterar para a tela de Cadastro depois
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8AD8FF), 
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24), 
                              ),
                            ),
                            child: Text(
                              'Cadastrar',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0A3351), 
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 16),

                          // Botão de login
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
                                color: Color(0xFF0A3351), 
                                width: 2.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24), 
                              ),
                            ),
                            child: Text(
                              'Login',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0A3351), 
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