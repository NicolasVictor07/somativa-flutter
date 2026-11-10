import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static Future<void> salvarNome(String nome) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nome_cliente', nome);
  }


  static Future<String> lerNome() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('nome_cliente') ?? 'Cliente da Cafeteria';
  }
}