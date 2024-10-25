import 'package:agrinnovate/fatores/grafico_fator_widget.dart';
import 'package:agrinnovate/extra/cabecalho_widget.dart';
import 'package:agrinnovate/flutter_flow/flutter_flow_util.dart';
import 'package:agrinnovate/models/dados.dart';
import 'package:agrinnovate/services/database_service.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
            child: Align(
              alignment: AlignmentDirectional(-0.9, 0),
              child: Text(
                'Meteorologia',
                style: FlutterFlowTheme.of(context).displaySmall.override(
                      fontFamily: 'Outfit',
                      color: FlutterFlowTheme.of(context).primaryText,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),
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

              return ListView.builder(
                physics: const NeverScrollableScrollPhysics(), // Disable scroll inside ListView
                shrinkWrap: true, // Wrap content for ListView
                padding: const EdgeInsets.all(16),
                itemCount: dados.length,
                itemBuilder: (context, index) {
                  var dado = dados[index];
                  String tMin = (double.parse(dado['tMin']).round()).toString();
                  String tMax = (double.parse(dado['tMax']).round()).toString();
                  String precipitaProb = dado['precipitaProb'];
                  String predWindDir = dado['predWindDir'];
                  String forecastDate = dado['forecastDate'];
                  String idWeather = dado['idWeatherType'].toString().padLeft(2, '0');

                  DateFormat format = DateFormat("yyyy-MM-dd");
                  var data = format.parse(forecastDate);
                  forecastDate = DateFormat("dd-MM-yyyy").format(data);

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: double.infinity,
                        height: 100,
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).secondaryBackground,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: FlutterFlowTheme.of(context).alternate,
                            width: 2,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(15, 0, 15, 0),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 5, 0),
                                child: SvgPicture.asset(
                                  'assets/icons_ipma_weather/w_ic_d_$idWeather.svg',
                                  width: 75,
                                  height: 75,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Temp: $tMinº-$tMaxºC',
                                      style: FlutterFlowTheme.of(context).labelMedium.override(
                                            fontFamily: 'Readex Pro',
                                            letterSpacing: 0,
                                          ),
                                    ),
                                    Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsetsDirectional.fromSTEB(0, 4, 4, 0),
                                          child: Text(
                                            forecastDate,
                                            style: FlutterFlowTheme.of(context).labelMedium.override(
                                                  fontFamily: 'Readex Pro',
                                                  letterSpacing: 0,
                                                ),
                                          ),
                                        ),
                                        Text(
                                          'Vento - $predWindDir\nProb chuva. - $precipitaProb%',
                                          textAlign: TextAlign.center,
                                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                fontFamily: 'Readex Pro',
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
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
