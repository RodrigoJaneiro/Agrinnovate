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

          listaDeDadosTmp.sort((a, b) {
            DateFormat format = DateFormat("dd-MM-yyyy HH:mm:ss");
            DateTime dataA = format.parse(a.dataDados);
            DateTime dataB = format.parse(b.dataDados);

            return dataA.compareTo(dataB);
          });

          List<Dados> listaDeDados = [];

          switch (_periodoSelecionado) {
            case 'dia':
              listaDeDados = listaDeDadosTmp.where((d) {
                DateFormat format = DateFormat("dd-MM-yyyy HH:mm:ss");
                DateTime dataDados = format.parse(d.dataDados);

                return dataDados.isAfter(
                    DateTime.now().subtract(const Duration(hours: 10)));
              }).toList();
              break;
            case 'semana':
            case 'mes':
              List<Dados> listaDeDadosAgrugadoPorDia = [];

              Map<String, List<Dados>> dadosPorDia = {};

              for (var dados in listaDeDadosTmp) {
                DateFormat format = DateFormat("dd-MM-yyyy HH:mm:ss");
                DateTime dataDados = format.parse(dados.dataDados);
                String dia = DateFormat("dd-MM-yyyy").format(dataDados);

                if (!dadosPorDia.containsKey(dia)) {
                  dadosPorDia[dia] = [];
                }
                dadosPorDia[dia]!.add(dados);
              }

              dadosPorDia.forEach((dia, dadosList) {
                int somaTemperatura = 0;
                int somaHumidadeAr = 0;
                int somaLuminosidade = 0;

                for (var dados in dadosList) {
                  somaTemperatura += dados.temperatura;
                  somaHumidadeAr += dados.humidadeAr;
                  somaLuminosidade += dados.luminosidade;
                }

                int mediaTemperatura =
                    (somaTemperatura / dadosList.length).round();
                int mediaHumidadeAr =
                    (somaHumidadeAr / dadosList.length).round();
                int mediaLuminosidade =
                    (somaLuminosidade / dadosList.length).round();

                listaDeDadosAgrugadoPorDia.add(Dados(
                  dataDados: dia,
                  temperatura: mediaTemperatura,
                  humidadeAr: mediaHumidadeAr,
                  luminosidade: mediaLuminosidade,
                  humidadeSolo: '',
                  maquina: listaDeDadosTmp.first.maquina,
                ));
              });

              listaDeDados = listaDeDadosAgrugadoPorDia.where((d) {
                DateFormat format = DateFormat("dd-MM-yyyy");
                DateTime dataDados = format.parse(d.dataDados);

                switch (_periodoSelecionado) {
                  case 'dia':
                    return dataDados.isAfter(
                        DateTime.now().subtract(const Duration(hours: 10)));
                  case 'semana':
                    return dataDados.isAfter(
                        DateTime.now().subtract(const Duration(days: 7)));
                  case 'mes':
                    return dataDados.isAfter(
                        DateTime.now().subtract(const Duration(days: 30)));
                  default:
                    return false;
                }
              }).toList();
              break;

            default:
              listaDeDados = listaDeDadosTmp;
          }

          List<FlSpot> dataPoints = listaDeDados.asMap().entries.map((entry) {
            int index = entry.key;
            Dados dados = entry.value;
            int valorCampo = 0;

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
              valorCampo.toDouble(),
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
                          icon:
                              const Icon(Icons.arrow_back, color: Colors.black),
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
                        maxX: _maxX,
                        minY: widget.minY,
                        maxY: widget.maxY,
                      ),
                    ),
                  ),
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
                          child: const Text('10 Hours'),
                        ),
                        ElevatedButton(
                          onPressed: () => _atualizarPeriodo('semana'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _periodoSelecionado == 'semana'
                                ? Colors.blue
                                : Colors.grey,
                          ),
                          child: const Text('7 Days'),
                        ),
                        ElevatedButton(
                          onPressed: () => _atualizarPeriodo('mes'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _periodoSelecionado == 'mes'
                                ? Colors.blue
                                : Colors.grey,
                          ),
                          child: const Text('30 Days'),
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
