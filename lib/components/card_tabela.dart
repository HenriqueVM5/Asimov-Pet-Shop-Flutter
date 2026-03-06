import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

//codigo que faz as tabelas padrõoes para tela de produtos e estoque

class CardTabela extends StatefulWidget {
  final String tituloBotao;
  final VoidCallback? acaoBotao;
  final List<String> cabecalhos;
  final List<Widget> linhas; 
  final bool isLoading; 

  const CardTabela({
    super.key,
    required this.tituloBotao,
    required this.acaoBotao,
    required this.cabecalhos,
    required this.linhas,
    this.isLoading = false,
  });


  // Desing linhas brancas
  static Widget construirLinha({
    required List<String> valores, 
    required VoidCallback onMenuTap,
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
          // Ícone menu (tocavel) para edição ou exclusão de um item
          GestureDetector(
            onTap: onMenuTap,
            child: const Icon(Icons.menu, size: 18, color: Colors.black),
          )
        ],
      ),
    );
  }
  //estilo texto das linas brancas
  static TextStyle _estiloLinha() {
    return GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 10);
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
          // Botão add novo item
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: widget.acaoBotao,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff8ad8ff),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                minimumSize: Size.zero, 
              ),
              child: Text(
                widget.tituloBotao,
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),


          // Cabeçalho
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xff6097b2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: Text(widget.cabecalhos[0], style: _estiloCabecalho()),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: Text(widget.cabecalhos[1], style: _estiloCabecalho()),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: Text(widget.cabecalhos[2], style: _estiloCabecalho()),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: Text(widget.cabecalhos[3], style: _estiloCabecalho()),
                  ),
                ),
                // Icone patinha
                const Icon(Icons.pets, size: 18, color: Colors.black), 
              ],
            ),
          ),
          
          const SizedBox(height: 12),

          // regras da paginação
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                const double alturaRodape = 30.0;
                final double espacoLivre = constraints.maxHeight - alturaRodape;
                
                const double alturaLinha = 65.0; 

                int itensDinamicos = (espacoLivre / alturaLinha).floor();
                if (itensDinamicos < 1) itensDinamicos = 1;

                int totalPaginas = (widget.linhas.length / itensDinamicos).ceil();
                if (totalPaginas == 0) totalPaginas = 1;

                int paginaSegura = _paginaAtual;
                if (paginaSegura >= totalPaginas) {
                  paginaSegura = totalPaginas - 1;
                }

                int indexInicio = paginaSegura * itensDinamicos;
                int indexFim = min(indexInicio + itensDinamicos, widget.linhas.length);

                List<Widget> linhasDaPagina = widget.linhas.isEmpty 
                    ? [] 
                    : widget.linhas.sublist(indexInicio, indexFim);

                return Column(
                  children: [
                    Expanded(
                      child: widget.isLoading
                          ? const Center(child: CircularProgressIndicator(color: Color(0xFF8AD8FF)))
                          : widget.linhas.isEmpty
                              ? Center(child: Text("Nenhum item encontrado", style: GoogleFonts.poppins(color: Colors.white)))
                              : ListView(
                                  padding: EdgeInsets.zero,
                                  physics: const NeverScrollableScrollPhysics(),
                                  children: linhasDaPagina,
                                ),
                    ),
                    
                    // setinhas de paginação
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (paginaSegura > 0) {
                              setState(() {
                                _paginaAtual = paginaSegura - 1;
                              });
                            }
                          },
                          child: Icon(
                            Icons.chevron_left, 
                            color: paginaSegura > 0 ? Colors.white : Colors.white38, 
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            if (paginaSegura < totalPaginas - 1) {
                              setState(() {
                                _paginaAtual = paginaSegura + 1;
                              });
                            }
                          },
                          child: Icon(
                            Icons.chevron_right, 
                            color: paginaSegura < totalPaginas - 1 ? Colors.white : Colors.white38, 
                            size: 24,
                          ),
                        ),
                      ],
                    )
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _estiloCabecalho() {
    return GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 12);
  }
}