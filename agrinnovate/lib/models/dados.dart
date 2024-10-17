import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';

class Dados {
  Float temperatura;
  Float humidadeAr;
  Float humidadeSolo;
  String maquina;
  Timestamp dataDados;

  Dados({
    required this.temperatura,
    required this.humidadeAr,
    required this.humidadeSolo,
    required this.maquina,
    required this.dataDados,
  });

  Dados.fromJson(Map<String, Object?> json)
      : this(
          temperatura: json['temperatura']! as Float,
          humidadeAr: json['humidadeAr']! as Float,
          humidadeSolo: json['humidadeSolo']! as Float,
          maquina: json['maquina']! as String,
          dataDados: json['dataDados']! as Timestamp,
        );

  Dados copyWith({
    Float? temperatura,
    Float? humidadeAr,
    Float? humidadeSolo,
    String? maquina,
    Timestamp? dataDados,
  }) {
    return Dados(
        temperatura: temperatura ?? this.temperatura,
        humidadeAr: humidadeAr ?? this.humidadeAr,
        humidadeSolo: humidadeSolo ?? this.humidadeSolo,
        maquina: maquina ?? this.maquina,
        dataDados: dataDados ?? this.dataDados);
  }

  Map<String, Object?> toJson() {
    return {
      'temperatura': temperatura,
      'humidadeAr': humidadeAr,
      'humidadeSolo': humidadeSolo,
      'maquina': maquina,
      'dataDados': dataDados,
    };
  }
}
