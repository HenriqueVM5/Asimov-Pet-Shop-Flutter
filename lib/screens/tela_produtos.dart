import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/produto_provider.dart';
import '../components/card_tabela.dart';
import '../components/popup_produtos.dart';

//codigo que finaliza a tabela de card_tabela colocando as infos de produto

class TelaProdutos extends ConsumerWidget {
  const TelaProdutos({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final produtosAsync = ref.watch(produtosProvider);

    return Padding(
      padding: const EdgeInsets.only(
        top: 35.0,
        left: 24.0,
        right: 24.0,
        bottom: 80.0,
      ),
      child: produtosAsync.when(
        data: (listaProdutos) {
          List<Widget> minhasLinhas = listaProdutos.map((produto) {
            // regra de formatçaõ do preço vindo do firebase pra moeda brasileira
            final formatadorMoeda = NumberFormat.currency(
              locale: 'pt_BR',
              symbol: 'R\$',
            );
            // Aplica a regra no seu preço
            String produtoPreco = formatadorMoeda.format(produto.preco);

            return CardTabela.construirLinha(
              valores: [
                produto.nome,
                produto.tipo,
                produto.marca,
                produtoPreco,
              ],
              onMenuTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    
                    return PopupProdutos(produto: produto); 
                  },
                );
              },
            );
          }).toList();

          return CardTabela(
            tituloBotao: 'Adicionar produto',
            acaoBotao: () {
              // Todo: abrir forms de add produto
            },
            // cabeçalho especifico
            cabecalhos: const ['Nome', 'Tipo', 'Marca', 'Preço'],
            linhas: minhasLinhas,
          );
        },
        loading: () {
          return const CardTabela(
            tituloBotao: 'Adicionar produto',
            acaoBotao: null,
            cabecalhos: ['Nome', 'Tipo', 'Marca', 'Preço'],
            linhas: [],
            isLoading: true,
          );
        },
        error: (erro, stackTrace) {
          return Center(child: Text("Erro ao carregar produtos: $erro"));
        },
      ),
    );
  }
}
