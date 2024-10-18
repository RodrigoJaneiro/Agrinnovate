import 'package:cloud_firestore/cloud_firestore.dart';

class UtilizadorMaquina {
  DocumentReference maquina;
  DocumentReference utilizador;
  Timestamp dataConfiguracao;

  UtilizadorMaquina({
    required this.maquina,
    required this.utilizador,
    required this.dataConfiguracao,
  });

  UtilizadorMaquina.fromJson(Map<String, Object?> json)
      : this(
          maquina: json['maquina']! as DocumentReference,
          utilizador: json['utilizador']! as DocumentReference,
          dataConfiguracao: json['dataConfiguracao']! as Timestamp,
        );

  UtilizadorMaquina copyWith({
    DocumentReference? maquina,
    DocumentReference? utilizador,
    Timestamp? dataConfiguracao,
  }) {
    return UtilizadorMaquina(
        maquina: maquina ?? this.maquina,
        utilizador: utilizador ?? this.utilizador,
        dataConfiguracao: dataConfiguracao ?? this.dataConfiguracao);
  }

  Map<String, Object?> toJson() {
    return {
      'maquina': maquina,
      'utilizador': utilizador,
      'dataConfiguracao': dataConfiguracao,
    };
  }
}
