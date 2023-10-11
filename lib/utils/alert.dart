import 'package:flutter/material.dart';
import 'package:flutter_kit/widgets/tx.dart';

class AlertAction {
  final String label;
  final Function(BuildContext) onPressed;

  AlertAction({
    required this.label,
    required this.onPressed,
  });
}

class Alert {
  static Future<bool?> showGenericDialog({
    required BuildContext context,
    String? title,
    String? content,
    required List<AlertAction> actions,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: title != null ? Tx(title, color: TxColor.black) : null,
          content: content != null
              ? Tx(
                  content,
                  color: TxColor.black,
                  maxLines: 64,
                )
              : null,
          actions: List<Widget>.generate(
            actions.length,
            (index) => TextButton(
              onPressed: () => actions[index].onPressed(context),
              child: Text(actions[index].label),
            ),
          ),
        );
      },
    );
  }

  static Future<bool?> showConfirm({
    required BuildContext context,
    String? title,
    String? content,
    String? acceptLabel,
    String? cancelLabel,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: title != null ? Tx(title, color: TxColor.black) : null,
          content: content != null
              ? Tx(
                  content,
                  color: TxColor.black,
                  maxLines: 64,
                )
              : null,
          actions: <Widget>[
            TextButton(
              child: Text(cancelLabel ?? 'Cancelar'),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
            TextButton(
              child: Text(acceptLabel ?? 'Aceptar'),
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
          ],
        );
      },
    );
  }

  static Future<void> showInfoDialog({
    required BuildContext context,
    String? title,
    String? content,
    String? acceptLabel,
  }) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: title != null ? Tx(title, color: TxColor.black) : null,
          content: content != null
              ? Tx(
                  content,
                  color: TxColor.black,
                  maxLines: 64,
                )
              : null,
          actions: <Widget>[
            TextButton(
              child: Text(acceptLabel ?? 'Aceptar'),
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
          ],
        );
      },
    );
  }
}
