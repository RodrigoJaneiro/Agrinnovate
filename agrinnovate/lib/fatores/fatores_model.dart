import '/flutter_flow/flutter_flow_util.dart';
import 'fatores_widget.dart' show FatoresWidget;
import 'package:flutter/material.dart';

class FatoresModel extends FlutterFlowModel<FatoresWidget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    unfocusNode.dispose();
  }
}
