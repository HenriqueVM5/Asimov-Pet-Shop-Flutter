import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../components/fundo_padrao.dart';
import '../models/produto_item.dart';
import '../providers/produto_provider.dart';

class TelaNovoEstoque extends ConsumerStatefulWidget {
  const TelaNovoEstoque({super.key});

  @override
  ConsumerState<TelaNovoEstoque> createState() => _TelaNovoEstoqueState();
}

class _TelaNovoEstoqueState extends ConsumerState<TelaNovoEstoque> {
  final TextEditingController _loteController = TextEditingController();
  final TextEditingController _qtdController = TextEditingController();
  final TextEditingController _dataValController = TextEditingController();

  String? _produtoSelecionadoId;
  DateTime? _dataValidadeSelecionada;
  bool _isSaving = false;
  bool _tentouSalvar = false;

  @override
  void dispose() {
    _loteController.dispose();
    _qtdController.dispose();
    _dataValController.dispose();
    super.dispose();
  }

  // Função para abrir o seletor de data (Calendário)
  Future<void> _selecionarData(BuildContext context) async {
    final DateTime? colhida = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(), // Não permite validade no passado
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xff8ad8ff),
              onPrimary: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (colhida != null) {
      setState(() {
        _dataValidadeSelecionada = colhida;
        _dataValController.text = DateFormat('dd/MM/yyyy').format(colhida);
      });
    }
  }

  Future<void> _salvarEstoque() async {
    setState(() => _tentouSalvar = true);

    if (_produtoSelecionadoId == null ||
        _loteController.text.trim().isEmpty ||
        _qtdController.text.trim().isEmpty ||
        _dataValidadeSelecionada == null) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final userEmail =
          FirebaseAuth.instance.currentUser?.email ?? 'usuario_desconhecido';
      final agora = DateTime.now();

      await FirebaseFirestore.instance.collection('estoque').add({
        'produto': _produtoSelecionadoId,
        'lote': _loteController.text.trim(),
        'qtd': int.tryParse(_qtdController.text) ?? 0,
        'dataVal': Timestamp.fromDate(_dataValidadeSelecionada!),
        'dataCad': Timestamp.fromDate(agora),
        'dataUltEdit': Timestamp.fromDate(agora),
        'userEdit': userEmail,
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
                  'Lote cadastrado com sucesso!',
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final produtosAsync = ref.watch(produtosProvider);

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
                        "Novo Estoque",
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

            const SizedBox(height: 100),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 40,
                ),
                child: Column(
                  children: [
                    // dropdown produtos
                    produtosAsync.when(
                      data: (lista) => _construirDropdown(lista),
                      loading: () => const CircularProgressIndicator(),
                      error: (_, __) => const Text("Erro ao carregar produtos"),
                    ),
                    const SizedBox(height: 16),

                    // lote
                    _construirCampoTexto("Lote", _loteController),

                    // data validade 
                    _construirCampoData(),

                    // qtd
                    _construirCampoTexto(
                      "Quantidade",
                      _qtdController,
                      isNumber: true,
                    ),

                    const SizedBox(height: 105),

                    // BOTÃO SALVAR
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _salvarEstoque,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff8ad8ff),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 0,
                        ),
                        child: _isSaving
                            ? const CircularProgressIndicator(
                                color: Colors.black,
                              )
                            : Text(
                                "Salvar estoque",
                                style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget do Dropdown 
  Widget _construirDropdown(List<Produto> produtos) {
    bool erro = _tentouSalvar && _produtoSelecionadoId == null;
    return Container(
      decoration: _boxDecorationEstilo(),
      child: DropdownButtonFormField<String>(
        value: _produtoSelecionadoId,
        dropdownColor: const Color(0xFFE3F2FD),
        items: produtos
            .map((p) => DropdownMenuItem(value: p.id, child: Text(p.nome)))
            .toList(),
        onChanged: (val) => setState(() => _produtoSelecionadoId = val),
        decoration: _inputDecorationEstilo("Selecionar Produto", erro),
      ),
    );
  }
  //widget de data
  Widget _construirCampoData() {
    bool erro = _tentouSalvar && _dataValidadeSelecionada == null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: _boxDecorationEstilo(),
        child: TextFormField(
          controller: _dataValController,
          readOnly: true,
          onTap: () => _selecionarData(context),
          decoration: _inputDecorationEstilo("Data de Validade", erro).copyWith(
            suffixIcon: const Icon(
              Icons.calendar_today,
              size: 20,
              color: Color(0xff365665),
            ),
          ),
        ),
      ),
    );
  }
  //widget de texto
  Widget _construirCampoTexto(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
  }) {
    bool erro = _tentouSalvar && controller.text.trim().isEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: _boxDecorationEstilo(),
        child: TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          decoration: _inputDecorationEstilo(label, erro),
        ),
      ),
    );
  }

  BoxDecoration _boxDecorationEstilo() {
    return BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  InputDecoration _inputDecorationEstilo(String label, bool erro) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
      filled: true,
      fillColor: Colors.white,
      errorText: erro ? "Obrigatório" : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
