import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/produto.dart';

class ApiService {
  static const String urlApi = 'https://6adf36788e42963c8d5d9824.mockapi.io/produtos';

  // GET 
  static Future<List<Bebida>> obterProdutos() async {
    final resposta = await http.get(Uri.parse(urlApi));
    if (resposta.statusCode == 200) {
      List listaJson = jsonDecode(resposta.body);
      return listaJson.map((item) => Bebida.fromJson(item)).toList();
    }
    throw Exception('Falha ao carregar');
  }

  // PUT 
  static Future<bool> atualizarPreco(String id, double novoPreco, String nome, String urlImagem) async {
    final resposta = await http.put(
      Uri.parse('$urlApi/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'nome': nome, 'preco': novoPreco, 'urlImagem': urlImagem}),
    );
    return resposta.statusCode == 200;
  }

  // POST 
  static Future<bool> criarProduto(String nome, double preco, String urlImagem) async {
    final resposta = await http.post(
      Uri.parse(urlApi),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'nome': nome, 'preco': preco, 'urlImagem': urlImagem}),
    );
    return resposta.statusCode == 201;
  }

  // DELETE 
  static Future<bool> deletarProduto(String id) async {
    final resposta = await http.delete(Uri.parse('$urlApi/$id'));
    return resposta.statusCode == 200;
  }
}