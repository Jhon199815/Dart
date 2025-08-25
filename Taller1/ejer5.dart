import 'dart:io';

void main() {
 

  stdout.write('monto de la compra: ');
  double monto = double.parse(stdin.readLineSync()!.replaceAll(',', '.'));

  double descuento = 0;

  if (monto >= 0 && monto <= 50) {
    descuento = 0;
  } else if (monto >= 51 && monto <= 100) {
    descuento = 0.05;
  } else if (monto >= 101 && monto <= 200) {
    descuento = 0.10;
  } else if (monto >= 201) {
    descuento = 0.15;
  }

  double ahorro = monto * descuento;
  double subtotal = monto - ahorro;
  double iva = subtotal * 0.19;
  double total = subtotal + iva;

  print('monto original: \$${monto.toStringAsFixed(2)}');
  print('descuento aplicado: ${(descuento * 100).toStringAsFixed(0)}%');
  print('ahorro: \$${ahorro.toStringAsFixed(2)}');
  print('subtotal: \$${subtotal.toStringAsFixed(2)}');
  print('iva (19%): \$${iva.toStringAsFixed(2)}');
  print('total a pagar: \$${total.toStringAsFixed(2)}');
}