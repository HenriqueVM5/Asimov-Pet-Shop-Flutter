import 'package:flutter/material.dart';

//codigo que define o background em comom das telas de home/perfil/produtos/estoqeue e dos fomulario de novo item

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
    return Scaffold(
      resizeToAvoidBottomInset: true, 
      backgroundColor: Colors.transparent, 
      extendBody: true, 
      bottomNavigationBar: bottomNavigationBar, 
      
      //definição das cores de fundo
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
          bottom: false, // Deixa um espaço ente o fundo criado e a tela, para que quando a tab for adicionada não esteja colada
          child: Center(
            child: FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: 375, // tamnho padrão do figma
                height: 812, // tamanho padrão do figma
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    
                    
                    // Onda azul no topo
                    Positioned(
                      top: -95, 
                      right: -70, 
                      child: Image.asset(
                        "assets/images/Vector12.png", 
                        width: 550, 
                        height: 550, 
                        fit: BoxFit.contain,
                      ),
                    ),

                    // Brinquedos do roda pé
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

                    //decorações especificas de cada tela adicionadas posteriormente
                    ...decoracoes,

                    //child para colocar o conteudo da pagina
                    child, 
                    
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