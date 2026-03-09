import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

//Codigo responsavel pela criação das tabelas de produtos e estoque

class CardTabela extends StatefulWidget {
  final String titulo;
  final VoidCallback? acaoBotao;
  final List<String> cabecalhos;
  final List<Widget> linhas;
  final bool isLoading;
  final bool podeEditar;
  final List<int> flexColunas; // variavel para controlar tamanho das colunas

  const CardTabela({
    super.key,
    required this.titulo,
    required this.acaoBotao,
    required this.cabecalhos,
    required this.linhas,
    this.isLoading = false,
    this.podeEditar = true,
    this.flexColunas = const [1, 1, 1, 1], //por padrão divide igualmente
  });

  // Criação linhas brancas
  static Widget construirLinha({
    required List<String> valores,
    required VoidCallback onMenuTap,
    bool podeEditar = true,
    List<int> flexes = const [1, 1, 1, 1], // Recebe as proporçoes das colunas
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: flexes[0],
            child: Padding(
              padding: const EdgeInsets.only(right: 6.0),
              child: Text(
                valores[0],
                style: _estiloLinha(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Expanded(
            flex: flexes[1],
            child: Padding(
              padding: const EdgeInsets.only(right: 6.0),
              child: Text(
                valores[1],
                style: _estiloLinha(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Expanded(
            flex: flexes[2],
            child: Padding(
              padding: const EdgeInsets.only(right: 6.0),
              child: Text(
                valores[2],
                style: _estiloLinha(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Expanded(
            flex: flexes[3],
            child: Padding(
              padding: const EdgeInsets.only(right: 6.0),
              child: Text(
                valores[3],
                style: _estiloLinha(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          //verificação se o usuario pode ou não editar
          if (podeEditar)
            GestureDetector(
              onTap: onMenuTap,
              child: const Icon(Icons.menu, size: 18, color: Colors.black),
            )
          else
            const Icon(Icons.pets, size: 18, color: Colors.black),
        ],
      ),
    );
  }

  //estilo do texto do conteudo das linhas brancas
  static TextStyle _estiloLinha() {
    return GoogleFonts.poppins(
      color: Colors.black,
      fontWeight: FontWeight.w600,
      fontSize: 10,
    );
  }

  @override
  State<CardTabela> createState() => _CardTabelaState();
}

class _CardTabelaState extends State<CardTabela> {
  int _paginaAtual = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 463,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xff365665),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Rormatação do cabeçalho
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xff8ad8ff),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.titulo,
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Botão "+" que abre o forms de novo produto
                if (widget.podeEditar)
                  GestureDetector(
                    onTap: widget.acaoBotao,
                    child: const SizedBox(
                      width: 18,
                      child: Icon(Icons.add, color: Colors.black, size: 22),
                    ),
                  )
                else
                  const SizedBox(width: 18),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Configuração das Colunas (Nome, Tipo, Marca, Preço)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xff6097b2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: widget.flexColunas[0],
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: Text(
                      widget.cabecalhos[0],
                      style: _estiloCabecalho(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                Expanded(
                  flex: widget.flexColunas[1],
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: Text(
                      widget.cabecalhos[1],
                      style: _estiloCabecalho(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                Expanded(
                  flex: widget.flexColunas[2],
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: Text(
                      widget.cabecalhos[2],
                      style: _estiloCabecalho(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                Expanded(
                  flex: widget.flexColunas[3],
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: Text(
                      widget.cabecalhos[3],
                      style: _estiloCabecalho(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const Icon(Icons.pets, size: 18, color: Colors.black),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Logica de paginação com os icones do rodape
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                const double alturaRodape = 30.0;
                final double espacoLivre = constraints.maxHeight - alturaRodape;
                const double alturaLinha = 58.0;

                int itensDinamicos = (espacoLivre / alturaLinha).floor();
                if (itensDinamicos < 1) itensDinamicos = 1;

                int totalPaginas = (widget.linhas.length / itensDinamicos)
                    .ceil();
                if (totalPaginas == 0) totalPaginas = 1;

                int paginaSegura = _paginaAtual;
                if (paginaSegura >= totalPaginas) {
                  paginaSegura = totalPaginas - 1;
                }

                int indexInicio = paginaSegura * itensDinamicos;
                int indexFim = min(
                  indexInicio + itensDinamicos,
                  widget.linhas.length,
                );

                List<Widget> linhasDaPagina = widget.linhas.isEmpty
                    ? []
                    : widget.linhas.sublist(indexInicio, indexFim);

                return Column(
                  children: [
                    Expanded(
                      child: widget.isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF8AD8FF),
                              ),
                            )
                          : widget.linhas.isEmpty
                          ? Center(
                              child: Text(
                                "Nenhum item encontrado",
                                style: GoogleFonts.poppins(color: Colors.white),
                              ),
                            )
                          : ListView(
                              padding: EdgeInsets.zero,
                              physics: const NeverScrollableScrollPhysics(),
                              children: linhasDaPagina,
                            ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (paginaSegura > 0) {
                              setState(() => _paginaAtual = paginaSegura - 1);
                            }
                          },
                          child: Icon(
                            Icons.chevron_left,
                            color: paginaSegura > 0
                                ? Colors.white
                                : Colors.white38,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            if (paginaSegura < totalPaginas - 1) {
                              setState(() => _paginaAtual = paginaSegura + 1);
                            }
                          },
                          child: Icon(
                            Icons.chevron_right,
                            color: paginaSegura < totalPaginas - 1
                                ? Colors.white
                                : Colors.white38,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  //Estilização dos textos do cabeçalho
  TextStyle _estiloCabecalho() {
    return GoogleFonts.poppins(
      color: Colors.black,
      fontWeight: FontWeight.w800,
      fontSize: 11,
    );
  }
}
