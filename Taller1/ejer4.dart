import 'dart:io';

void main() {
  

  stdout.write('nombre de la red (SSID): ');
  String ssid = stdin.readLineSync() ?? '';

  stdout.write('tipo de seguridad (WPA / WEP / ABIERTA): ');
  String tipo = (stdin.readLineSync() ?? '').toUpperCase();

  String pass = '';
  if (tipo != 'ABIERTA') {
    stdout.write('contraseña: ');
    pass = stdin.readLineSync() ?? '';
  }

  bool largoOk = pass.length >= 8 || tipo == 'ABIERTA';
  bool mayus = RegExp(r'[A-Z]').hasMatch(pass) || tipo == 'ABIERTA';
  bool minus = RegExp(r'[a-z]').hasMatch(pass) || tipo == 'ABIERTA';
  bool num = RegExp(r'[0-9]').hasMatch(pass) || tipo == 'ABIERTA';
  bool esp = RegExp(r'[^A-Za-z0-9]').hasMatch(pass) || tipo == 'ABIERTA';

  int puntos = 0;
  if (largoOk) puntos++;
  if (mayus) puntos++;
  if (minus) puntos++;
  if (num) puntos++;
  if (esp) puntos++;

  String nivel = '';
  if (puntos <= 2) {
    nivel = 'debil';
  } else if (puntos == 3) {
    nivel = 'media';
  } else if (puntos == 4) {
    nivel = 'fuerte';
  } else {
    nivel = 'muy fuerte';
  }

  String qr = '';
  if (tipo == 'ABIERTA') {
    qr = 'WIFI:T:nopass;S:$ssid;;';
  } else if (tipo == 'WEP') {
    qr = 'WIFI:T:WEP;S:$ssid;P:$pass;;';
  } else {
    qr = 'WIFI:T:WPA;S:$ssid;P:$pass;;';
  }


  print('seguridad: $tipo');
  if (tipo != 'ABIERTA') {
    print('fortaleza de la contraseña: $nivel');
  }
  print('string QR: $qr');

}