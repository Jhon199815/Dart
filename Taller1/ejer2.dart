import 'dart:io';

void main() {
  print('evaluador de Contraseñas');

  stdout.write('ingresa una contraseña: ');
  String pass = stdin.readLineSync() ?? '';

  final rMayus = RegExp(r'[A-Z]');
  final rMinus = RegExp(r'[a-z]');
  final rNum = RegExp(r'[0-9]');
  final rEsp = RegExp(r'[^A-Za-z0-9]');

  bool largoOk = pass.length >= 8;
  bool mayus = rMayus.hasMatch(pass);
  bool minus = rMinus.hasMatch(pass);
  bool num = rNum.hasMatch(pass);
  bool esp = rEsp.hasMatch(pass);

  int puntos = (largoOk ? 1 : 0) + (mayus ? 1 : 0) + (minus ? 1 : 0) + (num ? 1 : 0) + (esp ? 1 : 0);

  String nivel;
  if (puntos <= 2) {
    nivel = 'debil';
  } else if (puntos == 3) {
    nivel = 'media';
  } else if (puntos == 4) {
    nivel = 'fuerte';
  } else {
    nivel = 'muy fuerte';
  }

  List<String> mejoras = [];
  if (!largoOk) mejoras.add('usa al menos 8 caracteres');
  if (!mayus) mejoras.add('agrega mayúsculas (A-Z)');
  if (!minus) mejoras.add('agrega minúsculas (a-z)');
  if (!num) mejoras.add('agrega números (0-9)');
  if (!esp) mejoras.add('agrega un carácter especial (!@#\$%&*)');

  print('\n--- resultado ---');
  print('longitud: ${pass.length}');
  print('mayusculas: ${mayus ? "si" : "no"}');
  print('minusculas: ${minus ? "si" : "no"}');
  print('mumeros:    ${num ? "si" : "no"}');
  print('especiales: ${esp ? "si" : "no"}');
  print('fortaleza: $nivel');

  if (mejoras.isEmpty) {
    print('sugerencias: bien Tu contraseña ya es muy fuerte.');
  } else {
    print('sugerencias:');
    for (var m in mejoras) {
      print('- $m');
    }
  }
}