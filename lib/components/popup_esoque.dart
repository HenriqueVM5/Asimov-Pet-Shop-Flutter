import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../models/estoque_item.dart';
import '../models/produto_item.dart';
import '../providers/produto_provider.dart';

// Este código cria o pop-up que é acionado ao clicar no botão de edição na tela de produtos
// editar os dados ou excluir o produto do Firebase.
//mesmo estilo pop-up de produtos

class PopupEstoque extends ConsumerStatefulWidget {
  final Estoque itemEstoque;

  const PopupEstoque({super.key, required this.itemEstoque});

  @override
  ConsumerState<PopupEstoque> createState() => _PopupEstoqueState();
}

class _PopupEstoqueState extends ConsumerState<PopupEstoque> {
  late TextEditingController _loteController;
  late TextEditingController _qtdController;
  late TextEditingController _dataValController;

 
  late TextEditingController _userEditController;
  late TextEditingController _dataEditController;

  String? _produtoSelecionadoId;
  DateTime? _dataValidadeSelecionada;

  bool _isSaving = false;
  bool _tentouSalvar = false;

  @override
  void initState() {
    super.initState();
    _loteController = TextEditingController(text: widget.itemEstoque.lote);
    _qtdController = TextEditingController(
      text: widget.itemEstoque.qtd.toString(),
    );

    _produtoSelecionadoId = widget.itemEstoque.produtoId;
    _dataValidadeSelecionada = widget.itemEstoque.dataVal;

    String dataValFormatada = DateFormat(
      'dd/MM/yyyy',
    ).format(_dataValidadeSelecionada!);
    _dataValController = TextEditingController(text: dataValFormatada);


    _userEditController = TextEditingController(
      text: widget.itemEstoque.userEdit,
    );
    String dataEditFormatada = DateFormat(
      "dd/MM/yyyy 'as:' HH:mm",
    ).format(widget.itemEstoque.dataUltEdit);
    _dataEditController = TextEditingController(text: dataEditFormatada);
  }

  @override
  void dispose() {
    _loteController.dispose();
    _qtdController.dispose();
    _dataValController.dispose();
    _userEditController.dispose();
    _dataEditController.dispose();
    super.dispose();
  }


  // Fuynção para abrir o calendario
  Future<void> _selecionarData(BuildContext context) async {
    final DateTime? escolhida = await showDatePicker(
      context: context,
      initialDate: _dataValidadeSelecionada ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xff365665)),
          ),
          child: child!,
        );
      },
    );

    if (escolhida != null && escolhida != _dataValidadeSelecionada) {
      setState(() {
        _dataValidadeSelecionada = escolhida;
        _dataValController.text = DateFormat('dd/MM/yyyy').format(escolhida);
      });
    }
  }

  //função para excluir o estoque
  Future<void> _confirmarExclusao() async {
    showDialog(
      context: context,
      builder: (BuildContext contextDialog) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          title: Text(
            "Excluir Lote",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: const Color(0xff365665),
            ),
          ),
          content: Text(
            "Tem certeza que deseja excluir o lote '${widget.itemEstoque.lote}'?",
            style: GoogleFonts.poppins(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(contextDialog),
              child: Text(
                "Cancelar",
                style: GoogleFonts.poppins(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                elevation: 0,
              ),
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance
                      .collection('estoque')
                      .doc(widget.itemEstoque.id)
                      .delete();
                  if (mounted) {
                    Navigator.pop(contextDialog);
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.delete_outline,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Lote excluído com sucesso.',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: Colors.red.shade600,
                        behavior: SnackBarBehavior.floating,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        margin: const EdgeInsets.only(
                          left: 28,
                          right: 28,
                          bottom: 14,
                        ),
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
                    Navigator.pop(contextDialog);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erro ao excluir: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: Text(
                "Excluir",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Função para salvar estoque
  Future<void> _salvarAlteracoes() async {
    setState(() {
      _tentouSalvar = true;
    });

    if (_loteController.text.trim().isEmpty ||
        _qtdController.text.trim().isEmpty ||
        _produtoSelecionadoId == null ||
        _dataValidadeSelecionada == null) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      int qtdFormatada = int.tryParse(_qtdController.text.trim()) ?? 0;

      String usuarioAtual =
          FirebaseAuth.instance.currentUser?.email ?? 'usuario_desconhecido';
      DateTime dataAtual = DateTime.now();

      await FirebaseFirestore.instance
          .collection('estoque')
          .doc(widget.itemEstoque.id)
          .update({
            'produto': _produtoSelecionadoId,
            'lote': _loteController.text.trim(),
            'qtd': qtdFormatada,
            'dataVal': Timestamp.fromDate(_dataValidadeSelecionada!),
            'dataUltEdit': Timestamp.fromDate(dataAtual),
            'userEdit': usuarioAtual,
          });

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
                  'Lote atualizado com sucesso!',
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
            content: Text('Erro ao atualizar: $e'),
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
    final produtosAsync = ref.watch(produtosProvider);
    final listaProdutos = produtosAsync.value ?? [];
    final produtosParaDropdown = listaProdutos.where((p) {
      return p.ativo || p.id == widget.itemEstoque.produtoId;
    }).toList();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                    "Editar Estoque",
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


              _construirDropdownProduto(produtosParaDropdown),
              _construirCampoTexto("Lote", _loteController),
              

              Row(
                children: [
                  Expanded(
                    flex: 22,
                    child: _construirCampoData(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 10,
                    child: _construirCampoTexto(
                      "Qtd",
                      _qtdController,
                      isNumber: true,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              _construirCampoTexto(
                "Última edição feita por",
                _userEditController,
                readOnly: true,
              ),
              _construirCampoTexto(
                "Data da última edição",
                _dataEditController,
                readOnly: true,
              ),

              const SizedBox(height: 16),

              // Botões
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSaving ? null : _confirmarExclusao,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Excluir lote",
                        style: GoogleFonts.poppins(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _salvarAlteracoes,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff8ad8ff),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                color: Colors.black,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              "Salvar",
                              style: GoogleFonts.poppins(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  //widget do dopdrow de produtos
  Widget _construirDropdownProduto(List<Produto> listaProdutos) {
    bool temErro = _tentouSalvar && _produtoSelecionadoId == null;

    if (_produtoSelecionadoId != null &&
        !listaProdutos.any((p) => p.id == _produtoSelecionadoId)) {
      _produtoSelecionadoId = null;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: DropdownButtonFormField<String>(
        value: _produtoSelecionadoId,
        dropdownColor: const Color(0xFFE3F2FD),
        isExpanded: true, 
        decoration: InputDecoration(
          labelText: "Produto",
          labelStyle: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          errorText: temErro ? 'Selecione um produto' : null,
          errorStyle: GoogleFonts.poppins(fontSize: 10, color: Colors.red),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: temErro ? Colors.red : Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: temErro ? Colors.red : const Color(0xff365665),
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        items: listaProdutos.map((produto) {
          return DropdownMenuItem<String>(
            value: produto.id,
            child: Text(
              "${produto.cod} - ${produto.nome}",
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.black),
              overflow:
                  TextOverflow.ellipsis, 
            ),
          );
        }).toList(),
        onChanged: (String? novoValor) {
          setState(() {
            _produtoSelecionadoId = novoValor;
          });
        },
      ),
    );
  }

  //WIDGET DO CAMPO DE DATA
  Widget _construirCampoData() {
    bool temErro = _tentouSalvar && _dataValController.text.isEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: _dataValController,
        readOnly: true,
        onTap: () => _selecionarData(context),
        style: GoogleFonts.poppins(fontSize: 14, color: Colors.black),
        decoration: InputDecoration(
          labelText: "Data de Validade",
          labelStyle: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          suffixIcon: const Icon(
            Icons.calendar_today,
            color: Color(0xff365665),
            size: 20,
          ),
          errorText: temErro ? 'Obrigatório' : null,
          errorStyle: GoogleFonts.poppins(fontSize: 10, color: Colors.red),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: temErro ? Colors.red : Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: temErro ? Colors.red : const Color(0xff365665),
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  //widget dos campos de texto
  Widget _construirCampoTexto(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
    bool readOnly = false,
  }) {
    bool temErro = !readOnly && _tentouSalvar && controller.text.trim().isEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: GoogleFonts.poppins(
          fontSize: readOnly ? 11 : 14,
          color: readOnly ? Colors.grey[700] : Colors.black,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          errorText: temErro ? 'Obrigatório' : null,
          errorStyle: GoogleFonts.poppins(fontSize: 10, color: Colors.red),
          filled: readOnly,
          fillColor: readOnly ? Colors.grey[200] : Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: temErro
                  ? Colors.red
                  : (readOnly ? Colors.transparent : Colors.grey),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: temErro ? Colors.red : const Color(0xff365665),
              width: 2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: temErro
                  ? Colors.red
                  : (readOnly ? Colors.transparent : Colors.grey),
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}
