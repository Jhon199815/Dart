import 'dart:io';

void main() {
  print('calculadora de Tiempo');

  stdout.write('origen: ');
  String origen = stdin.readLineSync() ?? '';

  stdout.write('destino: ');
  String destino = stdin.readLineSync() ?? '';

  stdout.write('distancia (km): ');
  double km = double.parse(stdin.readLineSync()!.replaceAll(',', '.'));

  stdout.write('medio (a pie - bicicleta - carro - transporte público): ');
  String medio = (stdin.readLineSync() ?? '').toLowerCase();

  stdout.write('trafico (hora pico - normal): ');
  String trafico = (stdin.readLineSync() ?? '').toLowerCase();

  double velocidad = 0;
  if (medio == 'a pie') {
    velocidad = 5;
  } else if (medio == 'bicicleta') {
    velocidad = 15;
  } else if (medio == 'carro') {
    velocidad = 45;
  } else if (medio == 'transporte publico') {
    velocidad = 30;
  }

  double factor = trafico == 'hora pico' ? 1.3 : 1.0;

  double horas = (km / velocidad) * factor;
  int h = horas.floor();
  int m = ((horas - h) * 60).round();

  double tarifaKm = 0;
  if (medio == 'carro') {
    tarifaKm = 0.50;
  } else if (medio == 'transporte publico') {
    tarifaKm = 0.30;
  }
  double costo = km * tarifaKm;

  print('estimacion ');
  print('de: $origen  ->  a: $destino');
  print('distancia: ${km.toStringAsFixed(2)} km');
  print('medio: $medio');
  print('trafico: $trafico');
  print('tiempo estimado: ${h}h ${m}m');
  print('costo total: \$${costo.toStringAsFixed(2)}');
}