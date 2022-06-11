import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:gdr_multi_music/files_provider.dart';

class PrivacyDialog extends StatefulWidget {
  const PrivacyDialog({Key key, this.loc});

  final AppLocalizations loc;

  @override
  _PrivacyDialogState createState() => _PrivacyDialogState();
}

class _PrivacyDialogState extends State<PrivacyDialog> {

  String directoryColor;
  String fontColor;
  FilesProvider filesProvider;

  @override
  void initState() {
    super.initState();
    
    filesProvider = Provider.of<FilesProvider>(context, listen: false);
    directoryColor = filesProvider.settings[1];
    fontColor = filesProvider.settings[2];
  }

  @override
  Widget build(BuildContext context) {

    return AlertDialog(
      title: Container(
        padding: EdgeInsets.all(15.0),
        alignment: Alignment.center,
        child: Text(
          widget.loc.need_privacy,
          style: TextStyle(
            fontSize: 20,
            color: Color(int.parse(fontColor)),
          ),
        ),
        decoration: BoxDecoration(
          color: Color(int.parse(directoryColor)),
          image: DecorationImage (
            image: AssetImage("assets/Btn/btn-single-border.png"),
            fit: BoxFit.fill,
            centerSlice: Rect.fromLTWH(2500, 2500, 2500, 2500),
          ),
        ),
      ),
      content: new Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Legalese",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        Row (
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                child: Text(widget.loc.done_tutorial),
                onPressed: () {
                  // Chiudo il popup
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 20),
                ),
              ),
            ]
        )
      ],
    );
  }
}
