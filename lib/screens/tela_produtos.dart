import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart'; 
import '../providers/produto_provider.dart';
import '../components/card_tabela.dart';
import '../components/popup_produtos.dart';

//codigo que usa o card_tabela para finalizar a logica e design da tabela de produtos


// PROVEDOR DE PERMISSÕES (puxa o perfil de usuario direto do firebase)
final perfilUsuarioProvider = StreamProvider<String>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  
  // Se por algum motivo não houver utilizador logado, bloqueia por segurança(deixando o perfil como leitor por padrão)
  if (user == null || user.email == null) return Stream.value('leitor'); 

  // se não retorna ao vivo oq esta setado no firebase
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

class TelaProdutos extends ConsumerWidget {
  const TelaProdutos({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final produtosAsync = ref.watch(produtosProvider);
    final perfilAsync = ref.watch(perfilUsuarioProvider); // provider de perfil do firebase


    // Seta o valor da variave podeEditar a depender do perfil
    // maybeWhen para deixar bloqueado enquanto a internet não verifica o perfil
    bool podeEditar = perfilAsync.maybeWhen(
      data: (perfilString) {
        final perfil = perfilString.toLowerCase();
        // Acesso liberado somente se for administrador ou estoquista
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
        bottom: 80.0,
      ),
      child: produtosAsync.when(
        data: (listaProdutos) {
          List<Widget> minhasLinhas = listaProdutos.map((produto) {
            // Regra de formatação do preço vindo do firebase pra moeda brasileira
            final formatadorMoeda = NumberFormat.currency(
              locale: 'pt_BR',
              symbol: 'R\$',
            );
            String produtoPreco = formatadorMoeda.format(produto.preco);

            return CardTabela.construirLinha(
              valores: [
                produto.nome,
                produto.tipo,
                produto.marca,
                produtoPreco,
              ],
              podeEditar: podeEditar, 
              flexes: const [8, 6, 6, 6],//proporçoes de colunas atraves de teste
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
            titulo: 'Lista de Produtos',
            podeEditar: podeEditar, 
            acaoBotao: () {
              // Todo: abrir forms de add produto
              print("Botão de adicionar clicado!");
            },
            // cabeçalho especifico
            cabecalhos: const ['Nome', 'Tipo', 'Marca', 'Preço'],
            flexColunas : const [7, 6, 6, 6],
            linhas: minhasLinhas,
          );
        },
        loading: () {
          return const CardTabela(
            titulo: 'Lista de Produtos',
            podeEditar: false, // deixa sem permisão enquato carrega por segurança
            acaoBotao: null,
            cabecalhos: ['Nome', 'Tipo', 'Marca', 'Preço'],
            linhas: [],
            flexColunas: [7, 6, 6, 6],
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