import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_shop_app/components/popup_esoque.dart';
import 'package:pet_shop_app/screens/tela_novo_estoque.dart';
import '../providers/estoque_provider.dart';
import '../providers/produto_provider.dart';
import '../components/card_tabela.dart';

//codigo que usa o card_tabela para finalizar a logica e design da tabela de estoque

// PROVEDOR DE PERMISSÕES (puxa o perfil de usuario direto do firebase)
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
      padding: const EdgeInsets.only(
        top: 35.0,
        left: 24.0,
        right: 24.0,
        bottom: 120.0,
      ),
      child: estoqueAsync.when(
        data: (listaEstoque) {
          final listaProdutos = produtosAsync.value ?? [];

          List<Widget> minhasLinhas = listaEstoque.map((estoque) {
            String nomeDoProduto = "Carregando...";
            //logica para pegar o nome do produto do estoque, pois é uma variavel de produtos
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

            //Formatação da qtd de int para string
            String quantidadeFormatada = " ${estoque.qtd} un";
            //formatação da data
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
    );
  }
}
