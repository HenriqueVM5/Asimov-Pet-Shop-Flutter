import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../components/fundo_padrao.dart'; 

// Tela responsável por adicionar um novo produto ao Firebase

class TelaNovoProduto extends StatefulWidget {
  const TelaNovoProduto({super.key});

  @override
  State<TelaNovoProduto> createState() => _TelaNovoProdutoState();
}

class _TelaNovoProdutoState extends State<TelaNovoProduto> {
  // Controladores para capturar o que é digitado
  late TextEditingController _codController;
  late TextEditingController _nomeController;
  late TextEditingController _tipoController;
  late TextEditingController _marcaController;
  late TextEditingController _precoController;
  late TextEditingController _descricaoController;

  bool _isSaving = false;
  bool _tentouSalvar = false; // Usada para gerar as mensagens de erro

  @override
  void initState() {
    super.initState();
    // Inicializa todos os campos vazios
    _codController = TextEditingController();
    _nomeController = TextEditingController();
    _tipoController = TextEditingController();
    _marcaController = TextEditingController();
    _precoController = TextEditingController();
    _descricaoController = TextEditingController();
  }

  @override
  void dispose() {
    _codController.dispose();
    _nomeController.dispose();
    _tipoController.dispose();
    _marcaController.dispose();
    _precoController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }


  // Salvar no firebase
  Future<void> _salvarProduto() async {
    FocusScope.of(context).unfocus();//fecha o teclado se ainda aberto
    setState(() {
      _tentouSalvar = true;
    });

    // Verificações de erro 
    if (_codController.text.trim().isEmpty ||
        _nomeController.text.trim().isEmpty ||
        _tipoController.text.trim().isEmpty ||
        _marcaController.text.trim().isEmpty ||
        _precoController.text.trim().isEmpty ||
        _descricaoController.text.trim().isEmpty) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Transforma o valor digitado em double 
      String precoTexto = _precoController.text.replaceAll(',', '.');
      double precoFormatado = double.tryParse(precoTexto) ?? 0.0;

      // Pega o e-mail de quem está a criar e a data exata da criação
      String usuarioAtual = FirebaseAuth.instance.currentUser?.email ?? 'usuario_desconhecido';
      DateTime dataAtual = DateTime.now();

      // Adiciona um novo documento à coleção 'produto'
      await FirebaseFirestore.instance.collection('produto').add({
        'cod': _codController.text.trim(),
        'nome': _nomeController.text.trim(),
        'tipo': _tipoController.text.trim(),
        'marca': _marcaController.text.trim(),
        'preco': precoFormatado,
        'descricao': _descricaoController.text.trim(),
        // Para um produto novo, a data de cadastro e edição são a do momento em que se salva
        'dataCad': Timestamp.fromDate(dataAtual),
        'dataEdit': Timestamp.fromDate(dataAtual),
        'userEdit': usuarioAtual,
      });

      if (mounted) {
        Navigator.of(context).pop(); // Volta para a tela de lista de produtos

        // Cria a mensagem de sucesso no rodapé
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Produto cadastrado com sucesso!',
                  style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            padding: const EdgeInsets.symmetric(vertical: 8),
            margin: const EdgeInsets.only(left: 28, right: 28, bottom: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 0,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar produto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }


  // Tela
  @override
  Widget build(BuildContext context) {

    return FundoPadrao(


      decoracoes: [
        // saco de ração do rodape
        Positioned(
          bottom: 40, 
          right: 50,
          child: Image.asset(
            "assets/images/racao_forms.png", 
            width: 60, 
            height: 60,
            fit: BoxFit.contain,
          ),
        ),
        //pote lado esquerdo do titulo
        Positioned(
          top: 40, 
          left: 50,
          child: Image.asset(
            "assets/images/pote_padrao.png", 
            width: 60,
            height: 60,
            fit: BoxFit.contain,
          ),
        ),
        //bolas lado esquerdo do titulo
        Positioned(
          top: 30, 
          right: 55,
          child: Image.asset(
            "assets/images/mordedor_forms.png", 
            width: 50,
            height: 50,
            fit: BoxFit.contain,
          ),
        ),
      ],
      child: SafeArea(
        child: Column(
          children: [
            // CABEÇALHO 
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 16, right: 16),

              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  // Botão de Voltar 
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  //titulo
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 90), 
                      Text(
                        "Novo Produto",
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Formulario Com Scroll 
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 24.0,
                  right: 24.0,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 40,
                ),
                child: Column(
                  children: [
                    // Linha 1: Código
                    _construirCampoTexto("Código", _codController),

                    // Linha 2: Nome do Produto
                    _construirCampoTexto("Nome do Produto", _nomeController),

                    // Linha 3: Tipo
                    _construirCampoTexto("Tipo", _tipoController),

                    // Linha 4: Marca e Preço
                    Row(
                      children: [
                        Expanded(child: _construirCampoTexto("Marca", _marcaController)),
                        const SizedBox(width: 12),
                        // Muda para teclado numérico para facilitar a digitação do preço
                        Expanded(child: _construirCampoTexto("Preço (R\$)", _precoController, isNumber: true)),
                      ],
                    ),

                    // Linha 5: Descrição
                    _construirCampoTexto("Descrição", _descricaoController, maxLines: 3),

                    const SizedBox(height: 80),

                    // BOTÃO DE SALVAR
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _salvarProduto,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff8ad8ff),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: _isSaving
                            ? const CircularProgressIndicator(color: Colors.black)
                            : Text(
                                "Salvar produto",
                                style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 40), 
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

 //widget de campo de texto
  Widget _construirCampoTexto(String label, TextEditingController controller, {bool isNumber = false, int maxLines = 1}) {
    bool temErro = _tentouSalvar && controller.text.trim().isEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextFormField(
          controller: controller,
          keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
          maxLines: maxLines,
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.black),
          decoration: InputDecoration(
            
            labelText: temErro ? "$label (Obrigatório)" : label,
            labelStyle: GoogleFonts.poppins(
              fontSize: 12, 
              color: temErro ? Colors.red : Colors.grey[600],
              fontWeight: temErro ? FontWeight.bold : FontWeight.normal,
            ),
            
            errorText: null, 
            
            filled: true,
            fillColor: Colors.white,

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: temErro ? Colors.red : Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: temErro ? Colors.red : Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: temErro ? Colors.red : const Color(0xff365665), width: 2),
            ),
            
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ),
    );
  }
}