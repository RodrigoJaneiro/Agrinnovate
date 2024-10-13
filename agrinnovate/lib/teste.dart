import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class TestePage extends StatefulWidget {
  const TestePage({super.key});

  @override
  State<TestePage> createState() => _TestePageState();
}

class _TestePageState extends State<TestePage> {
  //final ref = FirebaseDatabase.instance.ref("valor");
  final ref = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
        "https://agrinnovate-d31ea-default-rtdb.europe-west1.firebasedatabase.app/",
  ).ref("Valores");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Teste'),
      ),
      body: StreamBuilder(
        stream: ref.onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {}
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return Center(child: Text('Sem dados'));
          }
          var dataSnapshot = snapshot.data!.snapshot;
          if (!dataSnapshot.exists) {
            return Center(child: Text('Sem dados'));
          }

          var data = dataSnapshot.value as Map<dynamic, dynamic>;
          double humidade = data["HumidadeAr"];
          double temperatura = data["TemperaturaAr"];
          return Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Humidade: $humidade'),
                Text('Temperatura: $temperatura'),
              ],
            ),
          );
        },
      ),
    );
  }
}
