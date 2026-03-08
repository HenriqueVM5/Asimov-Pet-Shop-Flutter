import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:intl/intl.dart'; 
import '../models/produto_item.dart'; 

// Este código cria o pop-up que é acionado ao clicar no botão de edição na tela de produtos
// editar os dados ou excluir o produto do Firebase.
class PopupProdutos extends StatefulWidget {
  final Produto produto; 

  const PopupProdutos({super.key, required this.produto});

  @override
  State<PopupProdutos> createState() => _PopupProdutosState();
}

class _PopupProdutosState extends State<PopupProdutos> {

  // Variaveis de controle para capturar oq foi digitado
  late TextEditingController _codController;
  late TextEditingController _nomeController;
  late TextEditingController _tipoController;
  late TextEditingController _marcaController;
  late TextEditingController _precoController;
  late TextEditingController _descricaoController;
  
  // Controladores para os campos em que é posivel apenas ler 
  late TextEditingController _userEditController;
  late TextEditingController _dataEditController;
  

  bool _isSaving = false; 
  bool _tentouSalvar = false; //usada para gerar as mensagens de erro se tentar salvar com algo em branco
  
  @override
  void initState() {
    super.initState();
    
    // Preenche os campos de texto com os valores atuais do produto vindo do banco de dados
    _codController = TextEditingController(text: widget.produto.cod);
    _nomeController = TextEditingController(text: widget.produto.nome);
    _tipoController = TextEditingController(text: widget.produto.tipo);
    _marcaController = TextEditingController(text: widget.produto.marca);
    
    
    // Pega o valor double do provider (ex: 80.9), fixa em 2 casas decimais (80.90) e troca o ponto por vírgula (80,90) 
    String precoInicial = widget.produto.preco?.toStringAsFixed(2).replaceAll('.', ',') ?? '0,00';
    _precoController = TextEditingController(text: precoInicial);
    
    _descricaoController = TextEditingController(text: widget.produto.descricao);

    // Pega o ultimo editor direto do provider q esta linkado ao firebase
    _userEditController = TextEditingController(text: widget.produto.userEdit);
    

    // Converte o DateTime padrão do Flutter para uma String 
    String dataFormatada = DateFormat("dd/MM/yyyy 'as:' HH:mm").format(widget.produto.dataEdit);
    _dataEditController = TextEditingController(text: dataFormatada);
  }


  // dispose para limpar os dados da memoria local apos fechar o pop_up
  @override
  void dispose() {
    _codController.dispose();
    _nomeController.dispose();
    _tipoController.dispose();
    _marcaController.dispose();
    _precoController.dispose();
    _descricaoController.dispose();
    
    _userEditController.dispose();
    _dataEditController.dispose();
    super.dispose();
  }



  // Função excluir produto
  Future<void> _confirmarExclusao() async {
    //pop_up de confirmação
    showDialog(
      context: context,
      builder: (BuildContext contextDialog) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          title: Text(
            "Excluir Produto",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xff365665)),
          ),
          content: Text(
            "Tem certeza que deseja excluir o produto '${widget.produto.nome}'? Esta ação não pode ser desfeita.",
            style: GoogleFonts.poppins(fontSize: 14),
          ),
          actions: [
            // Botão Cancelar
            TextButton(
              onPressed: () => Navigator.pop(contextDialog), // Fecha apenas o aviso
              child: Text(
                "Cancelar",
                style: GoogleFonts.poppins(color: Colors.grey[700], fontWeight: FontWeight.w600),
              ),
            ),
            // Botão Excluir Definitivo
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              onPressed: () async {
                try {
                  // Apaga o documento no Firebase 
                  await FirebaseFirestore.instance
                      .collection('produto')
                      .doc(widget.produto.id)
                      .delete();

                  if (mounted) {
                    Navigator.pop(contextDialog); // Fecha a caixinha de aviso
                    Navigator.pop(context); // Fecha o Pop-up do produto
                    
                    // Msg de sucesso de exclusão
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.delete_outline, color: Colors.white, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Produto excluído com sucesso.',
                              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ],
                        ),
                        backgroundColor: Colors.red.shade600,
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
                    Navigator.pop(contextDialog); // Fecha em caso de erro
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
                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  // Função para salvar dados no firebase
  Future<void> _salvarAlteracoes() async {

    setState(() {
      _tentouSalvar = true; 
    });

    //verificaçoes de erro
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
      //tranforma o valor digitado em double para enviar para o firebase
      String precoTexto = _precoController.text.replaceAll(',', '.');
      double precoFormatado = double.tryParse(precoTexto) ?? 0.0;
      
      // Pega o e-mail de quem editou e a data exata da edição
      String usuarioAtual = FirebaseAuth.instance.currentUser?.email ?? 'usuario_desconhecido';
      DateTime dataAtual = DateTime.now();

      //atualiza o firebase
      await FirebaseFirestore.instance
          .collection('produto')
          .doc(widget.produto.id) 
          .update({
        'cod': _codController.text.trim(), 
        'nome': _nomeController.text.trim(),
        'tipo': _tipoController.text.trim(),
        'marca': _marcaController.text.trim(),
        'preco': precoFormatado,
        'descricao': _descricaoController.text.trim(),
        'dataEdit': Timestamp.fromDate(dataAtual), 
        'userEdit': usuarioAtual, 
      });


      
      if (mounted) {
        Navigator.pop(context); 
        
        // Cria a msg de sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Produto atualizado com sucesso!',
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
      //se falhar em algum momento a comunicção com o firebase
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

  //contrução do forms
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
              
              // Cabeçalho com titulo e botão de fechar pop-up
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

              
              // Linha 1: Código
              _construirCampoTexto("Código Interno", _codController),
              
              // Linha 2: Nome do Produto
              _construirCampoTexto("Nome do Produto", _nomeController),
              
              // Linha 3: Tipo
              _construirCampoTexto("Tipo (ex: Ração Cachorro)", _tipoController),
              
              // Linha 4: Marca e Preço 
              Row(
                children: [
                  Expanded(child: _construirCampoTexto("Marca", _marcaController)),
                  const SizedBox(width: 12),
                  //muda para teclado numérico
                  Expanded(child: _construirCampoTexto("Preço (R\$)", _precoController, isNumber: true)),
                ],
              ),
              
              // Linha 5: Descrição 
              _construirCampoTexto("Descrição", _descricaoController, maxLines: 3),
              const SizedBox(height: 8),

              // Linha 6 e 7: usuario e data da ultima edição
              // readOnly: true para bloquear a edição manual
              _construirCampoTexto("Última edição feita por", _userEditController, readOnly: true),
              _construirCampoTexto("Data da ultima edição", _dataEditController, readOnly: true),

              const SizedBox(height: 16),

              //Botões de salvar e de excluir
              Row(
                children: [
                  // Botão de Excluir 
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSaving ? null : _confirmarExclusao,
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
                  
                  // Botão de Salvar 
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _salvarAlteracoes, 
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff8ad8ff),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isSaving 
                          ? const SizedBox(
                              height: 16, 
                              width: 16, 
                              child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2)
                            )
                          : Text(
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



  //padronização dos campos de digitação para reduzir codigo
  Widget _construirCampoTexto(String label, TextEditingController controller, {bool isNumber = false, int maxLines = 1, bool readOnly = false}) {
    
   //mensagem de erro
    bool temErro = !readOnly && _tentouSalvar && controller.text.trim().isEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0), 
      child: TextFormField(
        controller: controller,
        readOnly: readOnly, 
        keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
        maxLines: maxLines, 
        
       //texto preto se editavel, cinza se não
        style: GoogleFonts.poppins(
          fontSize: readOnly ? 11 : 14, 
          color: readOnly ? Colors.grey[700] : Colors.black
        ),

        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
          
          //estilo msg de erro
          errorText: temErro ? 'obrigatorio' : null,
          errorStyle: GoogleFonts.poppins(fontSize: 10, color: Colors.red),
          
          // Fundo cinza para campos bloqueados, transparente para os normais
          filled: readOnly,
          fillColor: readOnly ? Colors.grey[200] : Colors.transparent,


          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: temErro ? Colors.red : (readOnly ? Colors.transparent : Colors.grey)),
          ),

          // Bordas Ficam azul se estiver tudo bem, ou vermelho se tiver erro
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: temErro ? Colors.red : const Color(0xff365665), width: 2),
          ),

          // Esconde a borda se for campo de leitura
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: temErro ? Colors.red : (readOnly ? Colors.transparent : Colors.grey)),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), 
        ),
      ),
    );
  }
}