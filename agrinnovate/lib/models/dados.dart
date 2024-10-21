import 'package:cloud_firestore/cloud_firestore.dart';

class Dados {
  double temperatura;
  double humidadeAr;
  String humidadeSolo;
  double luminosidade;
  String maquina;
  String dataDados;

  Dados({
    required this.temperatura,
    required this.humidadeAr,
    required this.humidadeSolo,
    required this.luminosidade,
    required this.maquina,
    required this.dataDados,
  });

  Dados.fromJson(Map<String, Object?> json)
      : this(
          temperatura: json['temperatura']! as double,
          humidadeAr: json['humidadeAr']! as double,
          humidadeSolo: json['humidadeSolo']! as String,
          luminosidade: json['luminosidade']! as double,
          maquina: json['maquina']! as String,
          dataDados: json['dataDados']! as String,
        );

  Dados copyWith({
    double? temperatura,
    double? humidadeAr,
    String? humidadeSolo,
    double? luminosidade,
    String? maquina,
    String? dataDados,
  }) {
    return Dados(
        temperatura: temperatura ?? this.temperatura,
        humidadeAr: humidadeAr ?? this.humidadeAr,
        humidadeSolo: humidadeSolo ?? this.humidadeSolo,
        luminosidade: luminosidade ?? this.luminosidade,
        maquina: maquina ?? this.maquina,
        dataDados: dataDados ?? this.dataDados);
  }

  factory Dados.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Dados;
    return data;
  }

  Map<String, Object?> toJson() {
    return {
      'temperatura': temperatura,
      'humidadeAr': humidadeAr,
      'humidadeSolo': humidadeSolo,
      'luminosidade': luminosidade,
      'maquina': maquina,
      'dataDados': dataDados,
    };
  }
}
