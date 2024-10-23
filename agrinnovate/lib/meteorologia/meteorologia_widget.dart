import 'package:agrinnovate/fatores/grafico_fator_widget.dart';
import 'package:agrinnovate/extra/cabecalho_widget.dart';
import 'package:agrinnovate/models/dados.dart';
import 'package:agrinnovate/services/database_service.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MeteorologiaWidget extends StatefulWidget {
  const MeteorologiaWidget({super.key});

  @override
  State<MeteorologiaWidget> createState() => _MeteorologiaWidgetState();
}

class _MeteorologiaWidgetState extends State<MeteorologiaWidget> {
  late FatoresModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final DatabaseService _databaseService = DatabaseService();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _model.unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(_model.unfocusNode)
          : FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBtnText,
        body: ListView(
          children: [
            CabecalhoWidget(),
            FutureBuilder(
                future: _databaseService.getMetrologia(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Erro: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data == null) {
                    return const Center(child: Text('Sem dados'));
                  }

                  var dadosSnapshot = snapshot.data!;

                  List<Map<String, dynamic>> dados = dadosSnapshot;

                  String temperatura = dados[1]['tMin'];

                  debugPrint('Temperatura: $temperatura');
                  return Text('Dados:');
                }),
            Flexible(
              child: Align(
                alignment: const AlignmentDirectional(0, 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/Imagem_WhatsApp_2023-10-08_s_14.42.32_39dceb35-removebg-preview-transformed_(1).png',
                    width: 200,
                    height: 200,
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 0),
              child: Material(
                color: Colors.transparent,
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
