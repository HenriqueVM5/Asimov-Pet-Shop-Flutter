import 'package:flutter/material.dart';
import 'package:pet_shop_app/screens/home_screen.dart';
import 'package:pet_shop_app/screens/profile_screen.dart';
import 'package:pet_shop_app/screens/home_screen.dart';
import 'package:pet_shop_app/screens/profile_screen.dart';
import 'package:pet_shop_app/screens/tela_estoque.dart';
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
  late final List<Widget> _telas = [
    TelaHome(
      aoMudarParaProdutos: () {
        setState(() {
          _indiceAtual = 2;
        });
      },
    ), //tela de home
    const TelaPerfil(), //tela de perfil
    const TelaProdutos(), //tela de produtos
    const TelaEstoque(), //tela de estoque
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
      titulo:
          _titulos[_indiceAtual], //atualização do titulo de acordo com a aba
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(
          left: 40.0,
          right: 40.0,
          bottom: 00.0,
        ),
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
            items: List.generate(4, (index) {
              final icons = [
                ["assets/images/home_ns.png", "assets/images/home_s.png"],
                ["assets/images/perfi_ns.png", "assets/images/perfil_s.png"],
                [
                  "assets/images/produtos_ns.png",
                  "assets/images/produtos_s.png",
                ],
                ["assets/images/estoque_ns.png", "assets/images/estoque_s.png"],
              ];
              return BottomNavigationBarItem(
                icon: AnimatedScale(
                  scale: _indiceAtual == index ? 1.2 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: Image.asset(icons[index][0], height: 32),
                ),
                activeIcon: AnimatedScale(
                  scale: _indiceAtual == index ? 1.2 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: Image.asset(icons[index][1], height: 42),
                ),
                label: ['Home', 'Perfil', 'Produtos', 'Estoque'][index],
              );
            }),
          ),
        ),
      ),
      // Mudança do conteudo sobre a tela sem animação
      child: _telas[_indiceAtual],
    );
  }
}
