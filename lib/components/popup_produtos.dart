import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class PopupProdutos extends StatefulWidget {

  final dynamic produto; 

  const PopupProdutos({super.key, required this.produto});

  @override
  State<PopupProdutos> createState() => _PopupProdutosState();
}

class _PopupProdutosState extends State<PopupProdutos> {

  late TextEditingController _nomeController;
  late TextEditingController _tipoController;
  late TextEditingController _marcaController;
  late TextEditingController _precoController;
  late TextEditingController _descricaoController;

  @override
  void initState() {
    super.initState();

    _nomeController = TextEditingController(text: widget.produto.nome);
    _tipoController = TextEditingController(text: widget.produto.tipo);
    _marcaController = TextEditingController(text: widget.produto.marca);
    _precoController = TextEditingController(text: widget.produto.preco.toString());
    _descricaoController = TextEditingController(text: widget.produto.descricao);
  }

  @override
  void dispose() {

    _nomeController.dispose();
    _tipoController.dispose();
    _marcaController.dispose();
    _precoController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: Colors.white,

      child: SingleChildScrollView( 
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, 
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Editar Produto",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff365665), 
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(context), 
                  ),
                ],
              ),
              const SizedBox(height: 16),


              _construirCampoTexto("Nome do Produto", _nomeController),
              _construirCampoTexto("Tipo (ex: Cachorro)", _tipoController),
              _construirCampoTexto("Marca", _marcaController),
              _construirCampoTexto("Preço (R\$)", _precoController, isNumber: true),
              _construirCampoTexto("Descrição", _descricaoController, maxLines: 3),

              const SizedBox(height: 24),


              Row(
                children: [

                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {

                        print("Excluir o produto: ${widget.produto.nome}");
                        Navigator.pop(context); 
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        "Excluir item",
                        style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  

                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {

                        print("Salvando novo nome: ${_nomeController.text}");
                        Navigator.pop(context); 
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff8ad8ff),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        "Salvar alterações",
                        style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

 
  Widget _construirCampoTexto(String label, TextEditingController controller, {bool isNumber = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xff365665), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}