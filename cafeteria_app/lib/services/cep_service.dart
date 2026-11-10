import 'dart:convert';
import 'package:http/http.dart' as http;

class CepService {
  static Future<String> buscarEndereco(String cep) async {
    final cepLimpo = cep.replaceAll(RegExp(r'[^0-9]'), '');
    if (cepLimpo.length != 8) return 'CEP inválido (digite 8 números)';

    final resposta = await http.get(Uri.parse('https://viacep.com.br/ws/$cepLimpo/json/'));

    if (resposta.statusCode == 200) {
      final dados = jsonDecode(resposta.body);
      if (dados['erro'] == true || dados['erro'] == 'true') {
        return 'CEP não localizado.';
      }
      return '${dados['logradouro']}, ${dados['bairro']} - ${dados['localidade']}/${dados['uf']}';
    }
    return 'Erro ao consultar CEP';
  }
}