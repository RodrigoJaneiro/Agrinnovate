import 'package:agrinnovate/auth/firebase_auth/auth_util.dart';
import 'package:agrinnovate/models/dados.dart';
import 'package:agrinnovate/models/users.dart';
import 'package:agrinnovate/models/utilizador_maquina.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
    Stream<QuerySnapshot> dados = getDadosByUtilizadorAllTime();
    QuerySnapshot querySnapshot = await dados.first;

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first;
    }

    return null;
  }

  Stream<QuerySnapshot> getDadosByUtilizadorAllTime() {
    // Busca o documento do utilizador com base no UID
    return _utilizadorRef
        .where("uid", isEqualTo: currentUserUid)
        .limit(1)
        .snapshots()
        .asyncExpand((queryUser) {
      if (queryUser.docs.isNotEmpty) {
        // Busca o documento da coleção utilizadorMaquina com base no utilizador logado
        return _utilizadorMaquinaRef
            .where("utilizador", isEqualTo: queryUser.docs.first.reference)
            .limit(1)
            .snapshots()
            .asyncExpand((queryUtilizadorMaquina) {
          if (queryUtilizadorMaquina.docs.isNotEmpty) {
            // Acessa os dados já convertidos como instância de UtilizadorMaquina
            UtilizadorMaquina? utilizadorMaquina =
                queryUtilizadorMaquina.docs.first.data() as UtilizadorMaquina?;

            if (utilizadorMaquina != null) {
              // Extrair o maquinaId do primeiro documento encontrado
              DocumentReference maquinaRef = utilizadorMaquina.maquina;
              String maquinaId = maquinaRef.id;

              // Retornar um stream de dados da máquina
              return _dadosRef
                  .where("maquina", isEqualTo: maquinaId)
                  .snapshots(); // retorna o Stream<QuerySnapshot>
            }
          }
          // Retorna um stream vazio caso não encontre dados em UtilizadorMaquina
          return null;
        });
      }
      // Retorna um stream vazio caso não encontre dados em Utilizador
      return null;
    });
  }

  Stream<QuerySnapshot> getDadosByUtilizadorLast30Days() {
    // Busca o documento do utilizador com base no UID
    return _utilizadorRef
        .where("uid", isEqualTo: currentUserUid)
        .limit(1)
        .snapshots()
        .asyncExpand((queryUser) {
      if (queryUser.docs.isNotEmpty) {
        // Busca o documento da coleção utilizadorMaquina com base no utilizador logado
        return _utilizadorMaquinaRef
            .where("utilizador", isEqualTo: queryUser.docs.first.reference)
            .limit(1)
            .snapshots()
            .asyncExpand((queryUtilizadorMaquina) {
          if (queryUtilizadorMaquina.docs.isNotEmpty) {
            // Acessa os dados já convertidos como instância de UtilizadorMaquina
            UtilizadorMaquina? utilizadorMaquina =
                queryUtilizadorMaquina.docs.first.data() as UtilizadorMaquina?;

            if (utilizadorMaquina != null) {
              // Extrair o maquinaId do primeiro documento encontrado
              DocumentReference maquinaRef = utilizadorMaquina.maquina;
              String maquinaId = maquinaRef.id;

              // Retornar um stream de dados da máquina
              return _dadosRef
                  .where("maquina", isEqualTo: maquinaId)
                  .where("dataDados",
                      isGreaterThan:
                          DateTime.now().subtract(Duration(days: 30)))
                  .snapshots(); 
            }
          }
          // Retorna um stream vazio caso não encontre dados em UtilizadorMaquina
          return null;
        });
      }
      // Retorna um stream vazio caso não encontre dados em Utilizador
      return null;
    });
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

  // Função que faz a requisição e retorna os valores de idWeatherType, tMin e tMax
  Future<List<Map<String, dynamic>>> getMetrologia() async {
    const String url =
        'https://api.ipma.pt/open-data/forecast/meteorology/cities/daily/1010500.json';

    try {
      // Fazendo a requisição GET
      final response = await http.get(Uri.parse(url));

      // Verifica se a requisição foi bem-sucedida
      if (response.statusCode == 200) {
        // Faz o parse da resposta em JSON
        final Map<String, dynamic> jsonData = json.decode(response.body);

        // Acessa a lista de previsões dentro do campo 'data'
        final List<dynamic> forecastData = jsonData['data'];

        // Cria uma lista de mapas para armazenar os valores de idWeatherType, tMin e tMax
        List<Map<String, dynamic>> weatherDetails = [];

        // Percorre cada previsão e extrai os valores necessários
        for (var forecast in forecastData) {
          weatherDetails.add({
            'idWeatherType': forecast['idWeatherType'],
            'tMin': forecast['tMin'],
            'tMax': forecast['tMax'],
          });
        }

        return weatherDetails;
      } else {
        // Caso a requisição falhe, retornar uma lista vazia
        return [];
      }
    } catch (e) {
      // Em caso de erro na requisição, retornar uma lista vazia
      return [];
    }
  }
}
