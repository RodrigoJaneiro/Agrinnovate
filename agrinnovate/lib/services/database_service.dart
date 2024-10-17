import 'package:agrinnovate/models/dados.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const String DADOS_COLLECTON_REF = "dados";

class DatabaseService {
  final _firestore = FirebaseFirestore.instance;

  late final CollectionReference _dadosRef;

  DatabaseService() {
    _dadosRef = _firestore.collection(DADOS_COLLECTON_REF).withConverter<Dados>(
        fromFirestore: (snapshots, _) => Dados.fromJson(
              snapshots.data()!,
            ),
        toFirestore: (dados, _) => dados.toJson());
  }

  Stream<QuerySnapshot> getDados() {
    return _dadosRef.snapshots();
  }

  Future<DocumentSnapshot> getDadosByMaquina() async{
    QuerySnapshot querySnapshot = await _dadosRef.where('maquina', isEqualTo: '7157EB2DE6B4').limit(1).get();
    return querySnapshot.docs.first;
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
