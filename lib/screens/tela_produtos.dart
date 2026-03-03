import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
//codigo que cria o produto que vai ser inserido na pagina de produtos

class TelaProdutos extends StatelessWidget {
  const TelaProdutos({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40.0, left: 24.0, right: 24.0, bottom: 80.0),
      child: Container(
        height: 450, 
        
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: const Color(0xFF2E4C5E), 
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
            

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8AD8FF),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'Alterar Produtos',
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),


            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF547A8D),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(flex: 3, child: Text('Nome', style: _estiloCabecalho())),
                  Expanded(flex: 3, child: Text('Preço', style: _estiloCabecalho())),
                  Expanded(flex: 3, child: Text('Tipo', style: _estiloCabecalho())),
                  Expanded(flex: 2, child: Text('Estoque', style: _estiloCabecalho())),
                ],
              ),
            ),
            
            const SizedBox(height: 12),


            _buildLinhaTabela(nome: 'Shampoo', preco: 'R\$ 00,00', tipo: 'Higiene', estoque: '50'),
            _buildLinhaTabela(),
            _buildLinhaTabela(),
            _buildLinhaTabela(),
            _buildLinhaTabela(),


            const Spacer(),


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
      ),
    );
  }


  TextStyle _estiloCabecalho() {
    return GoogleFonts.poppins(
      color: Colors.black,
      fontWeight: FontWeight.w800,
      fontSize: 10,
    );
  }


  TextStyle _estiloLinha() {
    return GoogleFonts.poppins(
      color: Colors.black,
      fontWeight: FontWeight.w500,
      fontSize: 9,
    );
  }

  Widget _buildLinhaTabela({String nome = '', String preco = '', String tipo = '', String estoque = ''}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(nome, style: _estiloLinha())),
          Expanded(flex: 3, child: Text(preco, style: _estiloLinha())),
          Expanded(flex: 3, child: Text(tipo, style: _estiloLinha())),
          Expanded(flex: 2, child: Text(estoque, style: _estiloLinha())),
        ],
      ),
    );
  }
}