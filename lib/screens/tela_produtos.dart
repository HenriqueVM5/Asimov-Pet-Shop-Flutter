import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; 
import '../providers/produto_provider.dart'; 
import '../components/card_tabela.dart'; 

//codigo que finaliza a tabela de card_tabela colocando as infos de produto

class TelaProdutos extends ConsumerWidget {
  const TelaProdutos({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final produtosAsync = ref.watch(produtosProvider);

    return Padding(
      padding: const EdgeInsets.only(top: 35.0, left: 24.0, right: 24.0, bottom: 80.0),
      child: produtosAsync.when(
        data: (listaProdutos) {
          
          List<Widget> minhasLinhas = listaProdutos.map((produto) {
            
           //formata a data
            String dataApresentacao = DateFormat('dd/MM/yyyy').format(produto.dataEdit);

            return CardTabela.construirLinha(
              valores: [
                produto.nome, 
                produto.tipo, 
                produto.marca, 
                dataApresentacao 
              ], 
              onMenuTap: () {
                // todo: abrir tela de detalhes com botão de excluir e editar
              },
            );
          }).toList();

          return CardTabela(
            tituloBotao: 'Adicionar produto',
            acaoBotao: () {
               // Todo: abrir forms de add produto
            },
            // cabeçalho especifico
            cabecalhos: const ['Nome', 'Tipo', 'Marca', 'Edição'],
            linhas: minhasLinhas,
          );
        },
        loading: () {
          return const CardTabela(
            tituloBotao: 'Adicionar produto',
            acaoBotao: null,
            cabecalhos: ['Nome', 'Tipo', 'Marca', 'Última edição'],
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