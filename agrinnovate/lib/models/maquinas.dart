import 'package:cloud_firestore/cloud_firestore.dart';

class Maquina {
  String modelo;
  Timestamp dataComeco;

  Maquina({
    required this.modelo,
    required this.dataComeco,
  });

  Maquina.fromJson(Map<String, Object?> json)
      : this(
          modelo: json['modelo']! as String,
          dataComeco: json['dataComeco']! as Timestamp,
        );

  Maquina copyWith({
    String? modelo,
    Timestamp? dataComeco,
  }) {
    return Maquina(
        modelo: modelo ?? this.modelo,
        dataComeco: dataComeco ?? this.dataComeco);
  }

  Map<String, Object?> toJson() {
    return {
      'modelo': modelo,
      'dataComeco': dataComeco,
    };
  }
}
