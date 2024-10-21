import 'package:agrinnovate/backend/backend.dart';
import 'package:agrinnovate/extra/cabecalho_widget.dart';
import 'package:agrinnovate/fatores/grafico_fator_widget.dart';
import 'package:agrinnovate/lineChart/line_chart_widget.dart';
import 'package:agrinnovate/models/dados.dart';
import 'package:agrinnovate/services/database_service.dart';
import 'package:fl_chart/fl_chart.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';

import 'fatores_model.dart';
export 'fatores_model.dart';

class GraficoFatorWidget extends StatefulWidget {
  const GraficoFatorWidget(
      {super.key,
      required this.campo,
      required this.minX,
      required this.maxX,
      required this.minY,
      required this.maxY});

  final String campo; // Campo
  final double minX;
  final double maxX;
  final double minY;
  final double maxY;

  @override
  State<GraficoFatorWidget> createState() => _GraficoFatorWidgetState();
}

class _GraficoFatorWidgetState extends State<GraficoFatorWidget> {
  late FatoresModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final DatabaseService _databaseService = DatabaseService();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FatoresModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var dados = _databaseService.getDadosByUtilizador();

    return StreamBuilder(
        stream: dados,
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

          List<Dados> listaDeDados = snapshot.data!.docs.map((doc) {
            return Dados.fromSnapshot(doc);
          }).toList();

          List<FlSpot> dataPoints = listaDeDados.asMap().entries.map((entry) {
            int index = entry.key; // Obter o índice
            Dados dados = entry.value;
            double valorCampo = 0;

            switch (widget.campo) {
              case 'temperatura':
                valorCampo = dados.temperatura;
                break;
              case 'humidadeAr':
                valorCampo = dados.humidadeAr;
                break;
              case 'luminosidade':
                valorCampo = dados.luminosidade;
                break;
              default:
            }
            return FlSpot(
              index.toDouble(), // Usar index como double
              valorCampo,
            );
          }).toList();

          return GestureDetector(
            onTap: () => _model.unfocusNode.canRequestFocus
                ? FocusScope.of(context).requestFocus(_model.unfocusNode)
                : FocusScope.of(context).unfocus(),
            child: Scaffold(
              key: scaffoldKey,
              backgroundColor: FlutterFlowTheme.of(context).primaryBtnText,
              body: Column(
                children: [
                  CabecalhoWidget(),
                  Expanded(
                    child:Padding(
                        padding: const EdgeInsets.only(top: 16,bottom: 16, right: 16),
                        child: LineChartWidget(
                          dataPoints: dataPoints,
                          minX: widget.minX,
                          maxX: widget.maxX,
                          minY: widget.minY,
                          maxY: widget.maxY,
                        ),
                      ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
