import 'package:agrinnovate/index.dart';

import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'quem_somos_model.dart';
export 'quem_somos_model.dart';

class QuemSomosWidget extends StatefulWidget {
  const QuemSomosWidget({super.key});

  @override
  State<QuemSomosWidget> createState() => _QuemSomosWidgetState();
}

class _QuemSomosWidgetState extends State<QuemSomosWidget> {
  late QuemSomosModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => QuemSomosModel());
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
        backgroundColor: Colors.white,
        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              width: double.infinity,
              height: 110,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
              ),
              child: Stack(
                children: [
                  Align(
                    alignment: const AlignmentDirectional(0, 0.6),
                    child: Text(
                      'Quem Somos?',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Outfit',
                            fontSize: 32,
                            letterSpacing: 0,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                  Align(
                    alignment: const AlignmentDirectional(0, 0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Flexible(
                          child: Align(
                            alignment: const AlignmentDirectional(-0.92, 0.65),
                            child: FlutterFlowIconButton(
                              borderColor: const Color(0x00FFFFFF),
                              borderRadius: 20,
                              borderWidth: 1,
                              buttonSize: 40,
                              fillColor: const Color(0x00FFFFFF),
                              icon: Icon(
                                Icons.arrow_back_outlined,
                                color: FlutterFlowTheme.of(context).primaryText,
                                size: 24,
                              ),
                              onPressed: () async {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const MenuWidget(),
                                  ),
                                );
                              },
                              onTap: () async {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const MenuWidget(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(15, 50, 15, 0),
                child: Text(
                  'Somos um grupo de jovens estudantes que pretendem mudar o mundo da agricultura! Com o nosso kit pretendemos apelar à sustentabilidade e ao aproveitamento da inovação tecnológica no nosso dia a dia!',
                  textAlign: TextAlign.justify,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Readex Pro',
                        fontSize: 16,
                        letterSpacing: 0,
                        fontWeight: FontWeight.normal,
                        lineHeight: 2,
                      ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0, 50, 0, 0),
              child: Text(
                'Obrigado por te juntares à Agrinnovate!',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Readex Pro',
                      color: const Color(0xFF2B8C30),
                      letterSpacing: 0,
                    ),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 40),
              child: FFButtonWidget(
                onTap: () async {
                  await launchURL(
                      'https://agrinnovate.wixstudio.io/agrinnovate');
                },
                onPressed: () async {
                  await launchURL(
                      'https://agrinnovate.wixstudio.io/agrinnovate');
                },
                text: '',
                icon: const Icon(
                  Icons.arrow_forward_rounded,
                  size: 15,
                ),
                options: FFButtonOptions(
                  height: 40,
                  padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
                  iconPadding: const EdgeInsetsDirectional.fromSTEB(40, 0, 0, 0),
                  color: const Color(0xFF2B8C30),
                  textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                        fontFamily: 'Readex Pro',
                        color: Colors.white,
                        letterSpacing: 0,
                      ),
                  elevation: 3,
                  borderSide: const BorderSide(
                    color: Colors.transparent,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(15, 0, 15, 0),
              child: Text(
                'Consulta aqui  o nosso website para mais informações e para nos contactares!',
                textAlign: TextAlign.center,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Readex Pro',
                      color: const Color(0xFF2B8C30),
                      letterSpacing: 0,
                    ),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(15, 40, 15, 5),
              child: Text(
                'Conhece a nossa equipa!',
                textAlign: TextAlign.center,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Readex Pro',
                      color: const Color(0xFF2B8C30),
                      letterSpacing: 0,
                    ),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
              child: FFButtonWidget(
                onTap: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EquipaWidget(),
                    ),
                  );
                },
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EquipaWidget(),
                    ),
                  );
                },
                text: 'Equipa',
                options: FFButtonOptions(
                  height: 40,
                  padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
                  iconPadding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                  color: const Color(0xFF2B8C30),
                  textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                        fontFamily: 'Readex Pro',
                        color: Colors.white,
                        letterSpacing: 0,
                      ),
                  elevation: 3,
                  borderSide: const BorderSide(
                    color: Colors.transparent,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/Imagem_WhatsApp_2023-10-08_s_14.42.32_39dceb35-removebg-preview-transformed_(1).png',
                width: 200,
                height: 200,
                fit: BoxFit.fitWidth,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
