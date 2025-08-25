import 'dart:io';
void main(List<String> args) {
  print('Ingresar el valor de la compra: ');
  String? valor_compra = stdin.readLineSync();
  double valor_pedido = double.parse(valor_compra ?? '0');
  print(valor_pedido);

print("Seleccione el servicio: ");
print("1. Comida");
print("2. Farmacia");
print("3. Supermercado");
print("Opcion");
String? opcion_entrada = stdin.readLineSync();
int tipo_servicio = int.parse(opcion_entrada ?? '0');


  String servicio = "";
  switch (tipo_servicio) {
    case 1:
      servicio = "Comida";
      break;
    case 2:
      servicio = "Farmacia";
      break;
    case 3:
      servicio = "Supermercado";
      break;
    default:
      servicio = "Servicio no disponible";
      break;
  }
print(servicio);

print("Seleccione la calificación del servicio:");
print("1. Excelente (20%)");
print("2. Bueno      (15%)");
print("3. Regular    (10%)");
stdout.write("Opción: ");
String? califEntrada = stdin.readLineSync();
int calificacion = int.parse(califEntrada ?? '0');

double porcentaje = 0.0;
switch (calificacion) {
  case 1:
    porcentaje = 0.20;
    break;
  case 2:
    porcentaje = 0.15;
    break;
  case 3:
    porcentaje = 0.10;
    break;
  default:
    porcentaje = 0.10;
    break;
}
double propina = valor_pedido * porcentaje;
double total = valor_pedido + propina;

print("El total a pagar es: \$${total.toStringAsFixed(2)}");

}