import 'package:agrinnovate/extra/cabecalho_widget.dart';
import 'package:agrinnovate/fatores/grafico_fator_widget.dart';
import 'package:agrinnovate/lineChart/line_chart_widget.dart';
import 'package:agrinnovate/models/dados.dart';
import 'package:agrinnovate/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
      required this.maxY,
      required this.titulo});

  final String campo; // Campo
  final double minX;
  final double maxX;
  final double minY;
  final double maxY;
  final String titulo;

  @override
  State<GraficoFatorWidget> createState() => _GraficoFatorWidgetState();
}

class _GraficoFatorWidgetState extends State<GraficoFatorWidget> {
  late FatoresModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final DatabaseService _databaseService = DatabaseService();

  // Variável para controlar o período selecionado e o maxX
  String _periodoSelecionado = 'dia';
  late double _maxX;
  late Stream<QuerySnapshot<Object?>> _dadosFuture;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FatoresModel());
    _maxX = widget.maxX;
    _dadosFuture = _databaseService.getDadosByUtilizadorAllTime();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  // Função para atualizar o período e o maxX
  void _atualizarPeriodo(String periodo) {
    setState(() {
      _periodoSelecionado = periodo;
      switch (periodo) {
        case 'dia':
          _maxX = 10;
          break;
        case 'semana':
          _maxX = 7;
          break;
        case 'mes':
          _maxX = 30;
          break;
        default:
          _maxX = widget.maxX;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var dados = _dadosFuture;

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

          List<Dados> listaDeDadosTmp = snapshot.data!.docs.map((doc) {
            return Dados.fromSnapshot(doc);
          }).toList();

          List<Dados> listaDeDados = listaDeDadosTmp.where((d) {
            switch (_periodoSelecionado) {
              case 'dia':
                return d.dataDados == '1';
              case 'semana':
                return d.dataDados == '2';
              case 'mes':
                return d.dataDados != '-1';
              default:
                return false;
            }
          }).toList();

          List<FlSpot> dataPoints = listaDeDados.asMap().entries.map((entry) {
            int index = entry.key;
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
              index.toDouble(),
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back, color: Colors.black),
                          onPressed: () {
                            Navigator.pop(
                                context); // Volta para a página anterior
                          },
                        ),
                        Expanded(
                          child: Text(
                            widget.titulo,
                            style: FlutterFlowTheme.of(context)
                                .headlineSmall
                                .override(
                                  fontFamily: 'Outfit',
                                  fontSize: 23,
                                  letterSpacing: 0,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding:
                          const EdgeInsets.only(top: 16, bottom: 16, right: 16),
                      child: LineChartWidget(
                        dataPoints: dataPoints,
                        minX: widget.minX,
                        maxX:
                            _maxX, // Atualiza de acordo com o período selecionado
                        minY: widget.minY,
                        maxY: widget.maxY,
                      ),
                    ),
                  ),
                  // Linha com os botões dia, semana, mes
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () => _atualizarPeriodo('dia'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _periodoSelecionado == 'dia'
                                ? Colors.blue
                                : Colors.grey,
                          ),
                          child: const Text('10 Horas'),
                        ),
                        ElevatedButton(
                          onPressed: () => _atualizarPeriodo('semana'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _periodoSelecionado == 'semana'
                                ? Colors.blue
                                : Colors.grey,
                          ),
                          child: const Text('7 Dias'),
                        ),
                        ElevatedButton(
                          onPressed: () => _atualizarPeriodo('mes'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _periodoSelecionado == 'mes'
                                ? Colors.blue
                                : Colors.grey,
                          ),
                          child: const Text('30 Dias'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
