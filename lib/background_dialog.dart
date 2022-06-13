import 'package:flutter/material.dart';
import 'package:flutter_color_picker_wheel/models/button_behaviour.dart';
import 'package:flutter_color_picker_wheel/presets/animation_config_presets.dart';
import 'package:flutter_color_picker_wheel/presets/color_presets.dart';
import 'package:flutter_color_picker_wheel/widgets/flutter_color_picker_wheel.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:gdr_multi_music/shared_preferences_manager.dart';
import 'package:gdr_multi_music/files_provider.dart';

class BackgroundDialog extends StatefulWidget {
  const BackgroundDialog({Key key, this.loc});

  final AppLocalizations loc;

  @override
  _BackgroundDialogState createState() => _BackgroundDialogState();
}

class _BackgroundDialogState extends State<BackgroundDialog> {

  FilesProvider filesProvider;
  String directoryColor;
  String fontColor;
  String selected;
  String backgroundColor;

  @override
  void initState() {
    super.initState();

    filesProvider = Provider.of<FilesProvider>(context, listen: false);
    directoryColor = filesProvider.settings[1];
    fontColor = filesProvider.settings[2];
    selected = filesProvider.settings[3];
    backgroundColor = filesProvider.settings[4];
  }

  @override
  Widget build(BuildContext context) {

    return AlertDialog(
      title: Container(
        padding: EdgeInsets.all(15.0),
        alignment: Alignment.center,
        child: Text(
          widget.loc.background,
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
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 200,
            child: GridView.count(
              // childAspectRatio: 1.1,
              shrinkWrap: true,
              primary: false,
              crossAxisSpacing: 5,
              crossAxisCount: 3,
              children: [
                GestureDetector(
                  child: Container(
                    child: Image.asset(
                      "assets/Background/Arvyre-Continent.jpg",
                    ),
                    decoration: BoxDecoration(
                      border: selected == "assets/Background/Arvyre-Continent.jpg" ?
                                              Border.all(
                                                color: Color(int.parse(filesProvider.settings[1])),
                                                width: 2.0
                                              ) : Border.all(
                                                color: Colors.transparent,
                                              ),
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      selected = "assets/Background/Arvyre-Continent.jpg";
                    });
                  },
                ),
                GestureDetector(
                  child: Container(
                    child: Image.asset(
                      "assets/Background/Desert-Oasis-Town.jpg",
                    ),
                    decoration: BoxDecoration(
                      border: selected == "assets/Background/Desert-Oasis-Town.jpg" ?
                                              Border.all(
                                                color: Color(int.parse(filesProvider.settings[1])),
                                                width: 2.0
                                              ) : Border.all(
                                                color: Colors.transparent,
                                              ),
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      selected = "assets/Background/Desert-Oasis-Town.jpg";
                    });
                  },
                ),
                GestureDetector(
                  child: Container(
                    child: Image.asset(
                      "assets/Background/Fairy-Glade-Clear.jpg",
                    ),
                    decoration: BoxDecoration(
                      border: selected == "assets/Background/Fairy-Glade-Clear.jpg" ?
                                              Border.all(
                                                color: Color(int.parse(filesProvider.settings[1])),
                                                width: 2.0
                                              ) : Border.all(
                                                color: Colors.transparent,
                                              ),
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      selected = "assets/Background/Fairy-Glade-Clear.jpg";
                    });
                  },
                ),
                GestureDetector(
                  child: Container(
                    child: Image.asset(
                      "assets/Background/Haunted-Graveyard.jpg",
                    ),
                    decoration: BoxDecoration(
                      border: selected == "assets/Background/Haunted-Graveyard.jpg" ?
                                              Border.all(
                                                color: Color(int.parse(filesProvider.settings[1])),
                                                width: 2.0
                                              ) : Border.all(
                                                color: Colors.transparent,
                                              ),
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      selected = "assets/Background/Haunted-Graveyard.jpg";
                    });
                  },
                ),
                GestureDetector(
                  child: Container(
                    child: Image.asset(
                      "assets/Background/Shipyard.jpg",
                    ),
                    decoration: BoxDecoration(
                      border: selected == "assets/Background/Shipyard.jpg" ?
                                              Border.all(
                                                color: Color(int.parse(filesProvider.settings[1])),
                                                width: 2.0
                                              ) : Border.all(
                                                color: Colors.transparent,
                                              ),
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      selected = "assets/Background/Shipyard.jpg";
                    });
                  },
                ),
                GestureDetector(
                  child: Container(
                    padding: EdgeInsets.fromLTRB(0, 12, 0, 12),
                    child: ColoredBox(
                      color: Color(int.parse(filesProvider.settings[4])),
                    ),
                    decoration: BoxDecoration(
                      border: selected == "none" ?
                      Border.all(
                          color: Color(int.parse(filesProvider.settings[1])),
                          width: 2.0
                      ) : Border.all(
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      selected = "none";
                    });
                  },
                ),
              ],
            ),
          ),
          Container(
            height: 20,
            child: (selected != "none") ?
            SizedBox.shrink() :
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.loc.background_color + ": ",
                  style: TextStyle(
                      fontSize: 18
                  ),
                ),
                WheelColorPicker(
                  onSelect: (Color newColor) {
                    setState(() {
                      backgroundColor = newColor.value.toString();
                    });
                  },
                  behaviour: ButtonBehaviour.clickToOpen,
                  defaultColor: Color(int.parse(filesProvider.settings[4])),
                  animationConfig: fanLikeAnimationConfig,
                  colorList: defaultAvailableColors,
                  buttonSize: 25,
                  pieceHeight: 25,
                  innerRadius: 30,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Row (
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                child: Text(widget.loc.abort),
                onPressed: () {
                  // Chiudo il popup
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 20),
                ),
              ),
              TextButton(
                child: Text(widget.loc.save),
                onPressed: () {
                  filesProvider.settings[3] = selected;
                  filesProvider.settings[4] = backgroundColor;
                  SharedPreferencesManager.updateKV("Settings", true, filesProvider.settings);
                  filesProvider.getSettings();
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
