import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

//codigo que cria a table das telas de produto e estoque
class CardTabela extends StatelessWidget {
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
          
          // Botão adicionar
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: acaoBotao,
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
                tituloBotao,
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
                Expanded(flex: 3, child: Text(cabecalhos[0], style: _estiloCabecalho())),
                Expanded(flex: 3, child: Text(cabecalhos[1], style: _estiloCabecalho())),
                Expanded(flex: 3, child: Text(cabecalhos[2], style: _estiloCabecalho())),
                Expanded(flex: 2, child: Text(cabecalhos[3], style: _estiloCabecalho())),
                const SizedBox(width: 24),
              ],
            ),
          ),
          
          const SizedBox(height: 12),

          // Conteudo da tabela(Linhas brancas)
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF8AD8FF)))
                : linhas.isEmpty
                    ? Center(child: Text("Nenhum item encontrado", style: GoogleFonts.poppins(color: Colors.white)))
                    : ListView(
                        padding: EdgeInsets.zero,
                        children: linhas,
                      ),
          ),

          
          // Setinhas de rodape
          const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(Icons.chevron_left, color: Colors.white, size: 24),
              SizedBox(width: 8),
              Icon(Icons.chevron_right, color: Colors.white, size: 24),
            ],
          )
        ],
      ),
    );
  }

  TextStyle _estiloCabecalho() {
    return GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 12);
  }


  // Função que gera as linhas brancas
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
        children: [
          Expanded(flex: 3, child: Text(valores[0], style: _estiloLinha())),
          Expanded(flex: 3, child: Text(valores[1], style: _estiloLinha())),
          Expanded(flex: 3, child: Text(valores[2], style: _estiloLinha())),
          Expanded(flex: 2, child: Text(valores[3], style: _estiloLinha())),
          GestureDetector(
            onTap: onMenuTap,
            child: const Icon(Icons.menu, size: 18, color: Colors.black),
          )
        ],
      ),
    );
  }

  static TextStyle _estiloLinha() {
    return GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 9);
  }
}