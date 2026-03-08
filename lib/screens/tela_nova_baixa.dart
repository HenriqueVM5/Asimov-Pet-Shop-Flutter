import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../components/fundo_padrao.dart';
import '../models/estoque_item.dart';
import '../models/produto_item.dart';
import '../providers/estoque_provider.dart';
import '../providers/produto_provider.dart';

//codigo que criar o formulario de registrar baixa e decrementa no estoque

class TelaNovaBaixa extends ConsumerStatefulWidget {
  const TelaNovaBaixa({super.key});

  @override
  ConsumerState<TelaNovaBaixa> createState() => _TelaNovaBaixaState();
}

class _TelaNovaBaixaState extends ConsumerState<TelaNovaBaixa> {
  final TextEditingController _qtdController = TextEditingController();
  final TextEditingController _motivoController = TextEditingController();

  String? _estoqueSelecionadoId;

  bool _isSaving = false;
  bool _tentouSalvar = false;

  @override
  void dispose() {
    _qtdController.dispose();
    _motivoController.dispose();
    super.dispose();
  }

  // Verificação de se os valores no campo qtd estão coretos
  String? _validarQuantidade(Estoque? estoqueSelecionado) {
    if (!_tentouSalvar) return null;

    //se vazio retorna campo obrigatorio
    if (_qtdController.text.trim().isEmpty) {
      return 'Obrigatório';
    }

    int qtdDigitada = int.tryParse(_qtdController.text.trim()) ?? 0;

    //se negativo deve ser maior que zero
    if (qtdDigitada <= 0) {
      return 'Deve ser maior que 0';
    }

    //se maior que a qtd disponivel no estoque
    if (estoqueSelecionado != null && qtdDigitada > estoqueSelecionado.qtd) {
      return 'Máximo disponível: ${estoqueSelecionado.qtd}';
    }

    return null; // Sem erros
  }

  // Salvar e att o estoque
  Future<void> _salvarBaixa(Estoque? estoqueSelecionado) async {
    FocusScope.of(context).unfocus(); // Fecha o teclado

    setState(() {
      _tentouSalvar = true;
    });

    // Se algum campo foi digitado errado ou vazio, impede de salvar
    if (estoqueSelecionado == null ||
        _validarQuantidade(estoqueSelecionado) != null ||
        _motivoController.text.trim().isEmpty) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      int qtdBaixa = int.parse(_qtdController.text.trim());
      String usuarioAtual =
          FirebaseAuth.instance.currentUser?.email ?? 'usuario_desconhecido';
      DateTime dataAtual = DateTime.now();

      // registra a baixa no firebase
      await FirebaseFirestore.instance.collection('baixas').add({
        'itemEstId': estoqueSelecionado.id,
        'qtd': qtdBaixa,
        'data': Timestamp.fromDate(dataAtual),
        'user': usuarioAtual,
        'motivo': _motivoController.text.trim(),
      });

      // Atualiza o estoque
      int novaQuantidade = estoqueSelecionado.qtd - qtdBaixa;

      if (novaQuantidade <= 0) {
        // se nova qtd <= a 0 exclui estoque
        await FirebaseFirestore.instance
            .collection('estoque')
            .doc(estoqueSelecionado.id)
            .delete();
      } else {
        // Se não att o qtd
        await FirebaseFirestore.instance
            .collection('estoque')
            .doc(estoqueSelecionado.id)
            .update({
              'qtd': novaQuantidade,
              'dataUltEdit': Timestamp.fromDate(dataAtual),
              'userEdit': usuarioAtual,
            });
      }

      if (mounted) {
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Baixa registrada com sucesso!',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
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
            content: Text('Erro ao registrar baixa: $e'),
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

  @override
  Widget build(BuildContext context) {
    final estoqueAsync = ref.watch(estoqueProvider);
    final produtosAsync = ref.watch(produtosProvider);

    // Resgata as listas vazias enquanto carrega para evitar erros
    final listaEstoque = estoqueAsync.value ?? [];
    final listaProdutos = produtosAsync.value ?? [];

    // procura o objeto estoque selecionado
    Estoque? estoqueSelecionado;
    if (_estoqueSelecionadoId != null) {
      try {
        estoqueSelecionado = listaEstoque.firstWhere(
          (e) => e.id == _estoqueSelecionadoId,
        );
      } catch (_) {
        _estoqueSelecionadoId = null;
      }
    }

    return FundoPadrao(
      decoracoes: [
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
            // Cabeçalho
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.black,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 90),
                      Text(
                        "Registrar Baixa",
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

            const SizedBox(height: 141),

            // Formulario
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 24.0,
                  right: 24.0,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 40,
                ),
                child: Column(
                  children: [
                    // Dropdown de lote
                    _construirDropdown(listaEstoque, listaProdutos),

                    const SizedBox(height: 16),

                    //campo motivo da baixa
                    _construirCampoTexto("Motivo da baixa", _motivoController),


                    // campo qtd que recebe o estoque celecionado
                    _construirCampoQuantidade(estoqueSelecionado),


                    const SizedBox(height: 127),

                    // Botão salvar
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isSaving
                            ? null
                            : () => _salvarBaixa(estoqueSelecionado),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff8ad8ff),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: _isSaving
                            ? const CircularProgressIndicator(
                                color: Colors.black,
                              )
                            : Text(
                                "Salvar baixa",
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

  // Cronstrução do dropdown
  Widget _construirDropdown(List<Estoque> estoques, List<Produto> produtos) {
    bool temErro = _tentouSalvar && _estoqueSelecionadoId == null;

    return Container(
      decoration: _boxDecorationEstilo(),
      child: Theme(
        data: Theme.of(context).copyWith(
          buttonTheme: ButtonTheme.of(context).copyWith(alignedDropdown: false),
        ),
        child: DropdownButtonFormField<String>(
          value: _estoqueSelecionadoId,
          isExpanded: false,
          dropdownColor: const Color(0xFFE3F2FD),
          borderRadius: BorderRadius.circular(15),

          selectedItemBuilder: (BuildContext context) {
            return estoques.map<Widget>((estoque) {
              String nomeProd = "Produto Indisponível";
              try {
                nomeProd = produtos
                    .firstWhere((p) => p.id == estoque.produtoId)
                    .nome;
              } catch (_) {}

              return Text(
                "${estoque.lote} ($nomeProd)",
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.black),
              );
            }).toList();
          },

          items: estoques.map((estoque) {
            String nomeProd = "Desconhecido";
            try {
              nomeProd = produtos
                  .firstWhere((p) => p.id == estoque.produtoId)
                  .nome;
            } catch (_) {}

            return DropdownMenuItem<String>(
              value: estoque.id,
              child: SizedBox(
                width: 220,
                child: Text(
                  "${estoque.lote} ($nomeProd)",
                  style: GoogleFonts.poppins(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            );
          }).toList(),

          onChanged: (String? novoId) {
            setState(() {
              _estoqueSelecionadoId = novoId;
            });
          },
          decoration: _inputDecorationEstilo(
            "Lote",
            temErro,
            erroMsg: 'Obrigatório',
          ),
        ),
      ),
    );
  }

  // Construção campo de texto para qtd
  Widget _construirCampoQuantidade(Estoque? estoqueSelecionado) {
    String? erroMsg = _validarQuantidade(estoqueSelecionado);
    bool temErro = erroMsg != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          Container(
            decoration: _boxDecorationEstilo(),
            child: TextFormField(
              controller: _qtdController,
              keyboardType: const TextInputType.numberWithOptions(decimal: false),
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.black),
              onChanged: (text) {
                if (_tentouSalvar) setState(() {});
              },
              decoration: _inputDecorationEstilo(
                "Quantidade Decrementada",
                temErro,
                erroMsg: erroMsg,
              ),
            ),
          ),
          //msg de qtd de items disponiveis no estoque
          Padding(
            padding: const EdgeInsets.only(top: 4.0, left: 12.0), 
            child: Text(
              "Estoque atual deste lote: ${estoqueSelecionado?.qtd ?? 0} un",
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Campo de texto genérico
  Widget _construirCampoTexto(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
  }) {
    bool erro = _tentouSalvar && controller.text.trim().isEmpty;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        decoration: _boxDecorationEstilo(),
        child: TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.black), 
          decoration: _inputDecorationEstilo(label, erro),
        ),
      ),
    );
  }

  BoxDecoration _boxDecorationEstilo() {
    return BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  //estilo das caixas
  InputDecoration _inputDecorationEstilo(
    String label,
    bool erro, {
    String? erroMsg,
  }) {
    return InputDecoration(
      labelText: erro ? "$label (${erroMsg ?? 'Obrigatório'})" : label,
      labelStyle: GoogleFonts.poppins(
        fontSize: 12,
        color: erro ? Colors.red : Colors.grey[600],
        fontWeight: erro ? FontWeight.bold : FontWeight.normal,
      ),

      errorText: null,

      filled: true,

      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: erro ? Colors.red : Colors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: erro ? Colors.red : Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: erro ? Colors.red : const Color(0xff365665),
          width: 2,
        ),
      ),

      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
