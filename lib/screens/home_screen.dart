import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/produto_provider.dart';
import '../providers/estoque_provider.dart';
import '../models/produto_item.dart';
import '../components/popup_produtos.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Verificação do nivel de permisão
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

class TelaHome extends ConsumerWidget {
  // variavel para trocar para a aba produtos
  final VoidCallback aoMudarParaProdutos;

  const TelaHome({super.key, required this.aoMudarParaProdutos});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Usamos o SingleChildScrollView para a tela poder rolar se a lista ficar grande

    final produtosAsync = ref.watch(produtosProvider);
    final estoqueAsync = ref.watch(estoqueProvider);

    // Verifica qual o perfil do usuario atual
    final perfilAsync = ref.watch(perfilUsuarioProvider);
    bool podeEditar = perfilAsync.maybeWhen(
      data: (perfilString) {
        final perfil = perfilString.toLowerCase();
        return perfil.contains('administrador') || perfil.contains('estoquista');
      },
      orElse: () => false,
    );

    String produtosValor = '-';
    String estoqueValor = '-';

    produtosAsync.when(
      data: (produtos) {
        //conta somente produtos ativos
        final ativos = produtos.where((p) => p.ativo).length;
        produtosValor = ativos.toString();
      },
      loading: () => produtosValor = '...',
      error: (_, __) => produtosValor = 'Erro',
    );
    
    estoqueAsync.when(
      data: (estoque) {
        // Soma as quantidades (qtd) de todos os lotes juntos
        final totalItensFisicos = estoque.fold<int>(0, (soma, item) => soma + item.qtd);
        estoqueValor = totalItensFisicos.toString();
      },
      loading: () => estoqueValor = '...',
      error: (_, __) => estoqueValor = 'Erro',
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Título principal
          const SizedBox(height: 60), 
          
          // 1. CARDS DE RESUMO (PRODUTOS E ESTOQUE)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildResumoCard(
                  titulo: 'Total de Produtos',
                  valor: produtosValor,
                  descricao: 'Quantidade atual\nprodutos oferecidos',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildResumoCard(
                  titulo: 'Estoque Total',
                  valor: estoqueValor,
                  descricao: 'Quantidade atual\nde itens no estoque',
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 40), 
          
          // 2. LISTA DE REGISTROS RECENTES
          produtosAsync.when(
            data: (produtos) {
              final produtosOrdenados = List<Produto>.from(produtos)
                ..sort((a, b) => b.dataCad.compareTo(a.dataCad));

              final produtosRecentes = produtosOrdenados.take(5).toList();

              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Registros Recentes',
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...produtosRecentes
                        .map(
                          (produto) => _buildItemRegistro(
                            '${produto.nome} - ${produto.marca}',
                            () {
                              // chama a função ao mudar para produtos
                              aoMudarParaProdutos();

                              // abre o popup sobre a aba se o usuario tiver permisão para editar
                              if (podeEditar) {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return PopupProdutos(produto: produto);
                                  },
                                );
                              }
                            },
                          ),
                        )
                        .toList(),
                  ],
                ),
              );
            },
            loading: () {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Registros Recentes',
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Center(child: CircularProgressIndicator()),
                  ],
                ),
              );
            },
            error: (error, stackTrace) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Registros Recentes',
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Erro ao carregar registros',
                      style: GoogleFonts.poppins(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildResumoCard({
    required String titulo,
    required String valor,
    required String descricao,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              titulo,
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            valor,
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            descricao,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.black87,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRegistro(String texto, VoidCallback aoClicar) {
    return GestureDetector(
      onTap: aoClicar, 
      behavior: HitTestBehavior.opaque, 
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                texto,
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.black54, size: 20),
          ],
        ),
      ),
    );
  }
}