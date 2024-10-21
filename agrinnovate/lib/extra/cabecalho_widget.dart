import 'package:agrinnovate/auth/firebase_auth/auth_util.dart';
import 'package:agrinnovate/flutter_flow/flutter_flow_icon_button.dart';
import 'package:agrinnovate/flutter_flow/flutter_flow_theme.dart';
import 'package:agrinnovate/menu/menu_widget.dart';
import 'package:agrinnovate/profile/profile_widget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CabecalhoWidget extends StatelessWidget {
  final List<Color> gradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff02d39a),
  ];

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        height: 110,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF3947EF), Color(0xFF11721A), Color(0xFFEE8B60)],
            stops: [0, 0.8, 1],
            begin: AlignmentDirectional(-1, -1),
            end: AlignmentDirectional(1, 1),
          ),
        ),
        child: Container(
          width: 100,
          height: 0,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0x00FFFFFF), Colors.white],
              stops: [0, 1],
              begin: AlignmentDirectional(0, -1),
              end: AlignmentDirectional(0, 1),
            ),
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).accent1,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: FlutterFlowTheme.of(context).primary,
                      width: 2,
                    ),
                  ),
                  child: Align(
                    alignment: const AlignmentDirectional(0, 0),
                    child: FlutterFlowIconButton(
                        borderColor: const Color(0x00FFFFFF),
                        borderRadius: 24,
                        borderWidth: 1,
                        buttonSize: 46,
                        fillColor: FlutterFlowTheme.of(context).primaryBtnText,
                        icon: Icon(
                          Icons.person,
                          color: FlutterFlowTheme.of(context).primaryText,
                          size: 30,
                        ),
                        onPressed: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfileWidget(),
                            ),
                          );
                        },
                        onTap: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfileWidget(),
                            ),
                          );
                        }),
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                  child: Text(
                    'Bem-vindo, ',
                    style: FlutterFlowTheme.of(context).headlineSmall.override(
                          fontFamily: 'Outfit',
                          color: FlutterFlowTheme.of(context).primary,
                          fontSize: 20,
                          letterSpacing: 0,
                        ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(2, 0, 0, 0),
                  child: AuthUserStreamWidget(
                    builder: (context) => Text(
                      currentUserDisplayName,
                      style:
                          FlutterFlowTheme.of(context).headlineSmall.override(
                                fontFamily: 'Outfit',
                                color: FlutterFlowTheme.of(context).primaryText,
                                fontSize: 20,
                                letterSpacing: 0,
                              ),
                    ),
                  ),
                ),
                Flexible(
                  child: Align(
                    alignment: const AlignmentDirectional(0.9, 0),
                    child: FlutterFlowIconButton(
                      borderColor: const Color(0x00FFFFFF),
                      borderRadius: 20,
                      borderWidth: 1,
                      buttonSize: 40,
                      fillColor: const Color(0x00FFFFFF),
                      icon: FaIcon(
                        FontAwesomeIcons.alignJustify,
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
        ),
      );
}
