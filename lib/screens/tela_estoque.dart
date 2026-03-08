import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_shop_app/components/popup_esoque.dart';
import 'package:pet_shop_app/screens/tela_nova_baixa.dart';
import 'package:pet_shop_app/screens/tela_novo_estoque.dart';
import '../providers/estoque_provider.dart';
import '../providers/produto_provider.dart';
import '../components/card_tabela.dart';
import 'package:google_fonts/google_fonts.dart';


// Verifica perfil de usuario do firebase
final perfilUsuarioProvider = StreamProvider<String>((ref) {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null || user.email == null) return Stream.value('leitor');

  return FirebaseFirestore.instance
      .collection('funcionarios')
      .doc(user.email)
      .snapshots()
      .map((snapshot) {
        if (snapshot.exists) {
          return snapshot.data()?['perfil'].toString() ?? 'leitor';
        }
        return 'leitor';
      });
});

class TelaEstoque extends ConsumerWidget {
  const TelaEstoque({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estoqueAsync = ref.watch(estoqueProvider);
    final produtosAsync = ref.watch(produtosProvider);
    final perfilAsync = ref.watch(perfilUsuarioProvider);

    bool podeEditar = perfilAsync.maybeWhen(
      data: (perfilString) {
        final perfil = perfilString.toLowerCase();
        return perfil.contains('administrador') ||
            perfil.contains('estoquista');
      },
      orElse: () => false,
    );

    return Padding(
      padding: EdgeInsets.only(
        top: podeEditar ? 0.0 : 35.0,
        left: 24.0,
        right: 24.0,
        bottom: 120.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end, 
        children: [
          
          // Botão registrar baixa
          if (podeEditar)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TelaNovaBaixa(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  "Registrar baixa",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          // Tabela de estoque 
          Expanded( 
            child: estoqueAsync.when(
              data: (listaEstoque) {
                final listaProdutos = produtosAsync.value ?? [];

                List<Widget> minhasLinhas = listaEstoque.map((estoque) {
                  String nomeDoProduto = "Carregando...";
                  
                  if (listaProdutos.isNotEmpty) {
                    try {
                      final produtoEncontrado = listaProdutos.firstWhere(
                        (p) => p.id == estoque.produtoId,
                      );
                      nomeDoProduto = produtoEncontrado.nome;
                    } catch (e) {
                      nomeDoProduto = "Não encontrado";
                    }
                  }

                  String quantidadeFormatada = " ${estoque.qtd} un";
                  String validadeFormatada = DateFormat(
                    'dd/MM/yyyy',
                  ).format(estoque.dataVal);

                  return CardTabela.construirLinha(
                    valores: [
                      nomeDoProduto,
                      estoque.lote,
                      quantidadeFormatada,
                      validadeFormatada,
                    ],
                    podeEditar: podeEditar,
                    flexes: const [6, 5, 4, 6],
                    onMenuTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return PopupEstoque(itemEstoque: estoque);
                        },
                      );
                    },
                  );
                }).toList();

                return CardTabela(
                  titulo: 'Lista de Estoque',
                  podeEditar: podeEditar,
                  acaoBotao: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TelaNovoEstoque(),
                      ),
                    );
                  },
                  cabecalhos: const ['Produto', 'Lote', 'Qtd.', 'Validade'],
                  flexColunas: const [6, 5, 4, 6],
                  linhas: minhasLinhas,
                );
              },
              loading: () {
                return const CardTabela(
                  titulo: 'Lista de Estoque',
                  podeEditar: false,
                  acaoBotao: null,
                  cabecalhos: ['Produto', 'Lote', 'Qtd.', 'Validade'],
                  flexColunas: [6, 5, 4, 6],
                  linhas: [],
                  isLoading: true,
                );
              },
              error: (erro, stackTrace) {
                return Center(child: Text("Erro ao carregar estoque: $erro"));
              },
            ),
          ),
        ],
      ),
    );
  }
}