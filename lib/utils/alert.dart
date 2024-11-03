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
  }) =>
      showDialog<bool>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          backgroundColor: Colors.white,
          title: title != null
              ? Tx(
                  title,
                  color: TxColor.black,
                  weight: TxWeight.w500,
                  size: TxSize.l,
                )
              : null,
          content: content != null
              ? Tx(content, color: TxColor.black, maxLines: 64)
              : null,
          actions: List<Widget>.generate(
            actions.length,
            (index) => TextButton(
              style: ButtonStyle(
                overlayColor: WidgetStateProperty.all(
                  Colors.black.withOpacity(0.1),
                ),
              ),
              onPressed: () => actions[index].onPressed(context),
              child: Text(
                actions[index].label,
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
          ),
        ),
      );

  static Future<bool?> showConfirm({
    required BuildContext context,
    String? title,
    String? content,
    String acceptLabel = 'Aceptar',
    String cancelLabel = 'Cancelar',
  }) =>
      showDialog<bool>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          backgroundColor: Colors.white,
          title: title != null
              ? Tx(
                  title,
                  color: TxColor.black,
                  weight: TxWeight.w500,
                  size: TxSize.l,
                )
              : null,
          content: content != null
              ? Tx(content, color: TxColor.black, maxLines: 64)
              : null,
          actions: <Widget>[
            TextButton(
              style: ButtonStyle(
                overlayColor: WidgetStateProperty.all(
                  Colors.black.withOpacity(0.1),
                ),
              ),
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                cancelLabel,
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
            TextButton(
              style: ButtonStyle(
                overlayColor: WidgetStateProperty.all(
                  Colors.black.withOpacity(0.1),
                ),
              ),
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                acceptLabel,
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
          ],
        ),
      );

  static Future<void> showInfoDialog({
    required BuildContext context,
    String? title,
    String? content,
    String acceptLabel = 'Aceptar',
  }) =>
      showDialog<void>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          backgroundColor: Colors.white,
          title: title != null
              ? Tx(
                  title,
                  color: TxColor.black,
                  weight: TxWeight.w500,
                  size: TxSize.l,
                )
              : null,
          content: content != null
              ? Tx(content, color: TxColor.black, maxLines: 64)
              : null,
          actions: <Widget>[
            TextButton(
              style: ButtonStyle(
                overlayColor: WidgetStateProperty.all(
                  Colors.black.withOpacity(0.1),
                ),
              ),
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                acceptLabel,
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
          ],
        ),
      );
}
