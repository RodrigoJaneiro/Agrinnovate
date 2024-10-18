import 'dart:ffi';

class Dados {
  double temperatura;
  double humidadeAr;
  double humidadeSolo;
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
          humidadeSolo: json['humidadeSolo']! as double,
          luminosidade: json['luminosidade']! as double,
          maquina: json['maquina']! as String,
          dataDados: json['dataDados']! as String,
        );

  Dados copyWith({
    double? temperatura,
    double? humidadeAr,
    double? humidadeSolo,
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
