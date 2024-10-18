import 'package:agrinnovate/auth/firebase_auth/auth_util.dart';
import 'package:agrinnovate/models/dados.dart';
import 'package:agrinnovate/models/users.dart';
import 'package:agrinnovate/models/utilizador_maquina.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

const String DADOS_COLLECTON_REF = "dados";
const String UTILIZADORMAQUINA_COLLECTON_REF = "utilizadorMaquina";
const String UTILIZADOR_COLLECTON_REF = "users";

class DatabaseService {
  final _firestore = FirebaseFirestore.instance;

  late final CollectionReference _dadosRef;
  late final CollectionReference _utilizadorMaquinaRef;
  late final CollectionReference _utilizadorRef;

  DatabaseService() {
    _dadosRef = _firestore.collection(DADOS_COLLECTON_REF).withConverter<Dados>(
        fromFirestore: (snapshots, _) => Dados.fromJson(
              snapshots.data()!,
            ),
        toFirestore: (dados, _) => dados.toJson());

    _utilizadorMaquinaRef = _firestore
        .collection(UTILIZADORMAQUINA_COLLECTON_REF)
        .withConverter<UtilizadorMaquina>(
            fromFirestore: (snapshots, _) => UtilizadorMaquina.fromJson(
                  snapshots.data()!,
                ),
            toFirestore: (utilizadorMaquina, _) => utilizadorMaquina.toJson());

    _utilizadorRef =
        _firestore.collection(UTILIZADOR_COLLECTON_REF).withConverter<User>(
            fromFirestore: (snapshots, _) => User.fromJson(
                  snapshots.data()!,
                ),
            toFirestore: (user, _) => user.toJson());
  }

  Stream<QuerySnapshot> getDados() {
    return _dadosRef.snapshots();
  }

  Future<DocumentSnapshot> getDadosByMaquina() async {
    QuerySnapshot querySnapshot = await _dadosRef
        .where('maquina', isEqualTo: '7157EB2DE6B4')
        .limit(1)
        .get();
    return querySnapshot.docs.first;
  }

  Future<DocumentSnapshot?> getUltimoDadoByUtilizador() async {
    // Busca o documento do utilizador com base no UID
    QuerySnapshot queryUser = await _utilizadorRef
        .where("uid", isEqualTo: currentUserUid)
        .limit(1)
        .get();

    if (queryUser.docs.isNotEmpty) {
      // Certifique-se de que o _utilizadorMaquinaRef esteja corretamente tipado
      // Busca o documento da coleção utilizadorMaquina com base no utilizador logado
      QuerySnapshot queryUtilizadorMaquina = await _utilizadorMaquinaRef
          .where("utilizador", isEqualTo: queryUser.docs.first.reference)
          .limit(1)
          .get();

      if (queryUtilizadorMaquina.docs.isNotEmpty) {
        // Tenta acessar os dados diretamente usando `data()`
        debugPrint(
            "idUtilizadorMaquina: ${queryUtilizadorMaquina.docs.first.id}");
        User? utilizador = queryUser.docs.first.data() as User?;
        debugPrint(
            "idUtilizadorMaquinadssddssddssdds: ${utilizador?.display_name}");

        // Acessa os dados já convertidos como instância de UtilizadorMaquina
        UtilizadorMaquina? utilizadorMaquina =
            queryUtilizadorMaquina.docs.first.data() as UtilizadorMaquina?;

        debugPrint("queryUtilizadorMaquina data: $utilizadorMaquina");
        if (utilizadorMaquina != null) {
          // DebugPrint para verificar o conteúdo do docData
          debugPrint("queryUtilizadorMaquina data: $utilizadorMaquina");

          // Extrair o maquinaId do primeiro documento encontrado
          DocumentReference maquinaRef = utilizadorMaquina.maquina;
          String maquinaId = maquinaRef.id;
          debugPrint("MaquinaId: $maquinaId");


          // Agora buscar os dados da máquina com base no maquinaId e ordenar pelos mais recentes
          QuerySnapshot queryDados = await _dadosRef
              .where("maquina", isEqualTo: maquinaId)
             
              .limit(1)
              .get();
          Dados? dados = queryDados.docs.first.data() as Dados?;
          if (queryDados.docs.isNotEmpty) {
            // Retornar o último dado encontrado
            return queryDados.docs.first;
          }
        }
      }
    }

    return null; // Retorna null se nenhum dado for encontrado
  }

  void addDados(Dados dados) async {
    _dadosRef.add(dados);
  }

  void updateDados(String dadosId, Dados dados) {
    _dadosRef.doc(dadosId).update(dados.toJson());
  }

  void deleteDados(String dadosId) {
    _dadosRef.doc(dadosId).delete();
  }
}
