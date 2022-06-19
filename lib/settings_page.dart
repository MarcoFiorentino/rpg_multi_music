import 'package:flutter/material.dart';
import 'package:flutter_color_picker_wheel/models/button_behaviour.dart';
import 'package:flutter_color_picker_wheel/presets/animation_config_presets.dart';
import 'package:flutter_color_picker_wheel/presets/color_presets.dart';
import 'package:flutter_color_picker_wheel/widgets/flutter_color_picker_wheel.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:rpg_multi_music/shared_preferences_manager.dart';
import 'package:rpg_multi_music/string_extension.dart';
import 'package:rpg_multi_music/background_dialog.dart';
import 'package:rpg_multi_music/files_provider.dart';
import 'package:rpg_multi_music/ad_helper.dart';

class SettingsPage extends StatefulWidget {

  final AppLocalizations loc;

  const SettingsPage({Key key, this.loc}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsPage> {

  FilesProvider filesProvider;

  @override
  void initState() {
    AdHelper.settingsBanner.load();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    filesProvider = Provider.of<FilesProvider>(context, listen: true);
    final AdWidget adWidget = AdWidget(ad: AdHelper.settingsBanner);

    return Scaffold(
      appBar: AppBar(
          title: Text(
              widget.loc.settings,
              style: TextStyle(color: Color(int.parse(filesProvider.settings[2]))),
          ),
          iconTheme: IconThemeData(
            color: Color(int.parse(filesProvider.settings[2])),
          ),
          backgroundColor: Color(int.parse(filesProvider.settings[1])),
      ),
      body: buildSettings(context),
      bottomNavigationBar: Container(
          height: 50,
          color: Color(int.parse(filesProvider.settings[1])),
          child: adWidget
      ),
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
                widget.loc.screen_always_on,
                style: TextStyle(
                  fontSize: 18
                ),
              ),
              Switch(
                value: filesProvider.settings[0].toBoolean(),
                onChanged: (value) {
                  setState(() {
                    filesProvider.settings[0] = value.toString();
                    SharedPreferencesManager.updateKV("Settings", true, filesProvider.settings);
                    filesProvider.getSettings();
                  });
                },
                activeColor: Color(int.parse(filesProvider.settings[1])),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.loc.base_color + ": ",
                style: TextStyle(
                    fontSize: 18
                ),
              ),
              WheelColorPicker(
                onSelect: (Color newColor) {
                  setState(() {
                    filesProvider.settings[1] = newColor.value.toString();
                    SharedPreferencesManager.updateKV("Settings", true, filesProvider.settings);
                    filesProvider.getSettings();
                  });
                },
                behaviour: ButtonBehaviour.clickToOpen,
                defaultColor: Color(int.parse(filesProvider.settings[1])),
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
                widget.loc.font_color + ": ",
                style: TextStyle(
                    fontSize: 18
                ),
              ),
              DropdownButton<String>(
                value: filesProvider.settings[2],
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
                    filesProvider.settings[2] = data;
                    SharedPreferencesManager.updateKV("Settings", true, filesProvider.settings);
                    filesProvider.getSettings();
                  });
                },
                items: [
                  DropdownMenuItem<String>(
                      value: "4280361249",
                      child: Text(
                        widget.loc.black,
                      )
                  ),
                  DropdownMenuItem<String>(
                      value: "4294638330",
                      child: Text(
                        widget.loc.white,
                      )
                  )
                ],
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.loc.background + ": ",
                style: TextStyle(
                    fontSize: 18,
                ),
              ),
              Flexible(
                flex: 2,
                child: GestureDetector(
                  child: (filesProvider.settings[3] == "none") ?
                    Container(
                      width: 100,
                      height: 75,
                      child: ColoredBox(
                        color: Color(int.parse(filesProvider.settings[4])),
                      ),
                    ) :
                    Image.asset(
                      filesProvider.settings[3],
                      height: 75,
                    ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return BackgroundDialog(loc: widget.loc);
                      },
                    );
                  },
                ),
              ),
              IconButton(
                icon: Icon(Icons.drive_file_rename_outline),
                color: Colors.grey,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return BackgroundDialog(loc: widget.loc);
                    },
                  );
                },
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.loc.show_tutorial,
                style: TextStyle(
                    fontSize: 18
                ),
              ),
              Switch(
                value: !(filesProvider.settings[5].toBoolean()),
                onChanged: (value) {
                  setState(() {
                    filesProvider.settings[5] = (!value).toString();
                    SharedPreferencesManager.updateKV("Settings", true, filesProvider.settings);
                    filesProvider.getSettings();
                  });
                },
                activeColor: Color(int.parse(filesProvider.settings[1])),
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
                  widget.loc.two_minute_tabletop_attribution,
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
                  widget.loc.attribution_link,
                  style: TextStyle(
                      fontSize: 15,
                      color: Color(int.parse(filesProvider.settings[1])),
                      decoration: TextDecoration.underline
                  ),
                ),
                onTap: () async => await canLaunchUrlString("https://2minutetabletop.com/")
                    ? await launchUrlString("https://2minutetabletop.com/")
                    : throw widget.loc.url_error,
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
                  widget.loc.signal_bug_request_feature,
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
                  widget.loc.click_here,
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(int.parse(filesProvider.settings[1])),
                    decoration: TextDecoration.underline
                  ),
                ),
                onTap: () async => await canLaunchUrlString("https://forms.gle/h7jYVnstPfm2eagy6")
                    ? await launchUrlString("https://forms.gle/h7jYVnstPfm2eagy6")
                    : throw widget.loc.url_error,
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
                  widget.loc.need_privacy,
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
                  widget.loc.privacy_text,
                  style: TextStyle(
                      fontSize: 15,
                      color: Color(int.parse(filesProvider.settings[1])),
                      decoration: TextDecoration.underline
                  ),
                ),
                onTap: () async => await canLaunchUrlString("https://www.termsfeed.com/live/87b4bdbc-4836-489c-bd47-532fe4a2adef")
                    ? await launchUrlString("https://www.termsfeed.com/live/87b4bdbc-4836-489c-bd47-532fe4a2adef")
                    : throw widget.loc.url_error,
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}