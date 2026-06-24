import 'dart:convert';
import 'package:crypto/crypto.dart';

void main() {
  print(sha256.convert(utf8.encode('000000')).toString());
}
