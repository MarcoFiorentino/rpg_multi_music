import 'package:flutter/material.dart';
import 'package:flutter_color_picker_wheel/models/button_behaviour.dart';
import 'package:flutter_color_picker_wheel/presets/animation_config_presets.dart';
import 'package:flutter_color_picker_wheel/presets/color_presets.dart';
import 'package:flutter_color_picker_wheel/widgets/flutter_color_picker_wheel.dart';
import 'package:gdr_multi_music_handler/shared_preferences_manager.dart';
import 'package:gdr_multi_music_handler/string_extension.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart';

import 'package:gdr_multi_music_handler/files_provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsPage> {

  FilesProvider filesProvider;

  @override
  Widget build(BuildContext context) {
    filesProvider = Provider.of<FilesProvider>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
          title: Text(
              filesProvider.translations[0]["settings"],
              style: TextStyle(color: Color(int.parse(filesProvider.settings[3]))),
          ),
          iconTheme: IconThemeData(
            color: Color(int.parse(filesProvider.settings[3])),
          ),
          backgroundColor: Color(int.parse(filesProvider.settings[2])),
      ),
      body: buildSettings(context),
    );
  }

  Widget buildSettings(BuildContext context) {

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                filesProvider.translations[0]["language"] + ": ",
                style: TextStyle(
                  fontSize: 18
                ),
              ),
              DropdownButton<String>(
                value: filesProvider.settings[0],
                icon: Icon(Icons.arrow_drop_down),
                iconSize: 24,
                elevation: 16,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18
                ),
                underline: Container(
                  height: 2,
                  color: Colors.black,
                ),
                onChanged: (String data) {
                  setState(() {
                    filesProvider.settings[0] = data;
                    SharedPreferencesManager.updateKV("Settings", true, filesProvider.settings);
                    filesProvider.getSettings();
                  });
                },
                items: filesProvider.languages.map((String name, String value) {
                  return MapEntry(
                      name,
                      DropdownMenuItem<String>(
                        value: value,
                        child: Text(filesProvider.languages.entries.firstWhere((element) => element.value == value).value),
                      )
                  );
                }).values.toList(),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                filesProvider.translations[0]["screen_always_on"],
                style: TextStyle(
                  fontSize: 18
                ),
              ),
              Switch(
                value: filesProvider.settings[1].toBoolean(),
                onChanged: (value) {
                  setState(() {
                    filesProvider.settings[1] = value.toString();
                    SharedPreferencesManager.updateKV("Settings", true, filesProvider.settings);
                    filesProvider.getSettings();
                  });
                },
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              //Icon(Icons.color_lens_rounded),
              Text(
                filesProvider.translations[0]["appbar_color"] + ": ",
                style: TextStyle(
                    fontSize: 18
                ),
              ),
              WheelColorPicker(
                onSelect: (Color newColor) {
                  setState(() {
                    filesProvider.settings[2] = newColor.value.toString();
                    SharedPreferencesManager.updateKV("Settings", true, filesProvider.settings);
                    filesProvider.getSettings();
                  });
                },
                behaviour: ButtonBehaviour.clickToOpen,
                defaultColor: Color(int.parse(filesProvider.settings[2])),
                animationConfig: fanLikeAnimationConfig,
                colorList: defaultAvailableColors,
                buttonSize: 25,
                pieceHeight: 25,
                innerRadius: 30,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                filesProvider.translations[0]["font_color"] + ": ",
                style: TextStyle(
                    fontSize: 18
                ),
              ),
              DropdownButton<String>(
                value: filesProvider.settings[3],
                icon: Icon(Icons.arrow_drop_down),
                iconSize: 24,
                elevation: 16,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18
                ),
                underline: Container(
                  height: 2,
                  color: Colors.black,
                ),
                onChanged: (String data) {
                  setState(() {
                    filesProvider.settings[3] = data;
                    SharedPreferencesManager.updateKV("Settings", true, filesProvider.settings);
                    filesProvider.getSettings();
                  });
                },
                items: filesProvider.appFontColors.map((String name, String value) {
                  return MapEntry(
                    name,
                    DropdownMenuItem<String>(
                      value: value,
                      child: Text(filesProvider.translations[0][filesProvider.appFontColors.entries.firstWhere((element) => element.value == value).key]),
                    )
                  );
                }).values.toList(),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                filesProvider.translations[0]["background_img"] + ": ",
                style: TextStyle(
                    fontSize: 18
                ),
              ),
              DropdownButton<String>(
                value: filesProvider.settings[4],
                icon: Icon(Icons.arrow_drop_down),
                iconSize: 24,
                elevation: 16,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18
                ),
                underline: Container(
                  height: 2,
                  color: Colors.black,
                ),
                onChanged: (String data) {
                  setState(() {
                    filesProvider.settings[4] = data;
                    SharedPreferencesManager.updateKV("Settings", true, filesProvider.settings);
                    filesProvider.getSettings();
                  });
                },
                items: filesProvider.backgroundImages.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text((value != "none") ? basenameWithoutExtension(value.split("/")[2]).capitalize() : filesProvider.translations[0][value]),
                  );
                }).toList(),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                filesProvider.translations[0]["background_color"] + ": ",
                style: TextStyle(
                    fontSize: 18
                ),
              ),
              WheelColorPicker(
                onSelect: (Color newColor) {
                  setState(() {
                    filesProvider.settings[5] = newColor.value.toString();
                    SharedPreferencesManager.updateKV("Settings", true, filesProvider.settings);
                    filesProvider.getSettings();
                  });
                },
                behaviour: ButtonBehaviour.clickToOpen,
                defaultColor: Color(int.parse(filesProvider.settings[5])),
                animationConfig: fanLikeAnimationConfig,
                colorList: defaultAvailableColors,
                buttonSize: 25,
                pieceHeight: 25,
                innerRadius: 30,
              ),
            ],
          ),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              LimitedBox(
                maxWidth: MediaQuery.of(context).size.width,
                child: Text(
                  filesProvider.translations[0]["2-minute-tabletop-attribution"],
                  style: TextStyle(
                      fontSize: 15
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                child: Text(
                  filesProvider.translations[0]["attribution-link"],
                  style: TextStyle(
                      fontSize: 15,
                      color: Colors.blue,
                      decoration: TextDecoration.underline
                  ),
                ),
                onTap: () async => await canLaunchUrlString("https://2minutetabletop.com/")
                    ? await launchUrlString("https://2minutetabletop.com/")
                    : throw filesProvider.translations[0]["url_error"],
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              LimitedBox(
                maxWidth: MediaQuery.of(context).size.width,
                child: Text(
                  filesProvider.translations[0]["signal_bug_request_feature"],
                  style: TextStyle(
                      fontSize: 15
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                child: Text(
                  filesProvider.translations[0]["click_here"],
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.blue,
                    decoration: TextDecoration.underline
                  ),
                ),
                onTap: () async => await canLaunchUrlString("https://docs.google.com/forms/d/e/1FAIpQLSf17hcBM-AR98ZYEFxo323qyTJ-tDpf-4OQQBevsMgZ_Z-sKw/viewform")
                    ? await launchUrlString("https://docs.google.com/forms/d/e/1FAIpQLSf17hcBM-AR98ZYEFxo323qyTJ-tDpf-4OQQBevsMgZ_Z-sKw/viewform")
                    : throw filesProvider.translations[0]["url_error"],
              ),
            ],
          ),
          SizedBox(
            height: 30,
          ),
        ],
      ),
    );
  }
}