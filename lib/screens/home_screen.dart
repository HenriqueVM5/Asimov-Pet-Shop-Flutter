import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/produto_provider.dart';
import '../providers/estoque_provider.dart';
import '../models/produto_item.dart';

class TelaHome extends ConsumerWidget {
  const TelaHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Usamos o SingleChildScrollView para a tela poder rolar se a lista ficar grande

    final produtosAsync = ref.watch(produtosProvider);
    final estoqueAsync = ref.watch(estoqueProvider);

    String produtosValor = '-';
    String estoqueValor = '-';

    produtosAsync.when(
      data: (produtos) => produtosValor = produtos.length.toString(),
      loading: () => produtosValor = '...',
      error: (_, __) => produtosValor = 'Erro',
    );
    estoqueAsync.when(
      data: (estoque) => estoqueValor = estoque.length.toString(),
      loading: () => estoqueValor = '...',
      error: (_, __) => estoqueValor = 'Erro',
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Título principal
          const SizedBox(height: 60), // Espaço extra entre título e cards
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
          const SizedBox(height: 40), // Espaço maior entre cards e lista
          // 2. LISTA DE REGISTROS RECENTES
          produtosAsync.when(
            data: (produtos) {
              // Ordena produtos por data de cadastro (mais recentes primeiro)
              final produtosOrdenados = List<Produto>.from(produtos)
                ..sort((a, b) => b.dataCad.compareTo(a.dataCad));

              // Pega apenas os últimos 5 produtos
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

  // Função para criar o layout repetido dos dois cards de cima
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

  // Função para criar as linhazinhas clicáveis da lista de recentes
  Widget _buildItemRegistro(String texto) {
    return Padding(
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
    );
  }
}
