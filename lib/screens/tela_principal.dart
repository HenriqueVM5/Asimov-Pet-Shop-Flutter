import 'package:flutter/material.dart';
import 'package:pet_shop_app/screens/tela_produtos.dart';
import 'package:pet_shop_app/components/fundo_telas.dart';

//codigo que cria e configura a tab
//codigo responsavel por falar qual tela vai ser sobrescita em cima do background atravez da tab

class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  int _indiceAtual = 0;

  // Lista de qual tela deve ser sobrescrita sobre o fundo em cada aba da tabs
  final List<Widget> _telas = [
    const Center(child: Text(' ', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),//tela de home
    const Center(child: Text('Conteúdo do Perfil', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),//tela de perfil
    const TelaProdutos(),//tela de produtos
    const Center(child: Text('Conteúdo do Estoque', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),//tela de estoque
  ];

  //Lista do titulo de cada uma das telas
  final List<String?> _titulos = [
    "Olá! Seja bem-vindo", //tela home
    "Seu perfil", // tela perfil
    "Produtos", // tela produtos
    "Estoque", //tela estoque
  ];

  @override
  Widget build(BuildContext context) {
    
    // Chamada do backgrond definido em components/fundos_telas
    return FundoTelas(
      titulo: _titulos[_indiceAtual], //atualização do titulo de acordo com a aba
      
      //criação da tabs
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 40.0, right: 40.0, bottom: 00.0),//distancias a esquerda, direita e parte de baixo da tela
        child: Theme(
          data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            currentIndex: _indiceAtual,
            onTap: (index) {
              setState(() {
                _indiceAtual = index;
              });
            },
            backgroundColor: Colors.transparent,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            showSelectedLabels: false,
            showUnselectedLabels: false, 
            
            //definição do simbolos de cada tab
            items: [
              BottomNavigationBarItem(
                icon: Image.asset("assets/images/home_ns.png", height: 32),
                activeIcon: Image.asset("assets/images/home_s.png", height: 42), 
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Image.asset("assets/images/perfi_ns.png", height: 32),
                activeIcon: Image.asset("assets/images/perfil_s.png", height: 42),
                label: 'Perfil',
              ),
              BottomNavigationBarItem(
                icon: Image.asset("assets/images/produtos_ns.png", height: 32),
                activeIcon: Image.asset("assets/images/produtos_s.png", height: 42),
                label: 'Produtos',
              ),
              BottomNavigationBarItem(
                icon: Image.asset("assets/images/estoque_ns.png", height: 32),
                activeIcon: Image.asset("assets/images/estoque_s.png", height: 42),
                label: 'Estoque',
              ),
            ],
          ),
        ),
      ),
      
      // Mudança do conteudo sobre atela atravez da lista 
      child: _telas[_indiceAtual], 
    );
  }
}