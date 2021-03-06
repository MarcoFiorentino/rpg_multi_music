import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:wakelock/wakelock.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:rpg_multi_music/shared_preferences_manager.dart';
import 'package:rpg_multi_music/files_provider.dart';
import 'package:rpg_multi_music/string_extension.dart';
import 'package:rpg_multi_music/arrow_painter.dart';
import 'package:rpg_multi_music/column_settings_dialog.dart';

class MusicPage extends StatefulWidget {
  final ValueNotifier<double> notifier;
  final AppLocalizations loc;

  const MusicPage({Key key, this.notifier, this.loc}) : super(key: key);

  @override
  _MusicPageState createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> {
  // Variabili condivise
  List<AudioPlayer> players = [];
  List<String> playing = [];
  List<int> volumes = [];
  List<String> files = [];
  List<String> states = [];

  final ScrollController horizontalScrollController = ScrollController();
  final ScrollController verticalScrollController = ScrollController();

  FilesProvider filesProvider;
  final colonnePerTipo = 2;

  int colIndex = 0;

  void onScroll(BuildContext context) {
    double scrolledSections = horizontalScrollController.offset / (MediaQuery.of(context).size.width / 3);
    double percentageScrolledSections = scrolledSections / (filesProvider.filesPaths.length * 3 + 1);

    double originalBackgroundHeight = filesProvider.loadedBackgroundHeight;
    double originalBackgroundWidth = filesProvider.loadedBackgroundWidth;
    if(originalBackgroundHeight != 0 && originalBackgroundWidth != 0) {
      double screenHeight = MediaQuery.of(context).size.height - 80 - AppBar().preferredSize.height;
      double newBackgroundWidth = screenHeight / originalBackgroundHeight * originalBackgroundWidth;
      double backgroundToScroll = newBackgroundWidth * percentageScrolledSections;

      if (backgroundToScroll > (newBackgroundWidth - MediaQuery.of(context).size.width)) {
        backgroundToScroll = (newBackgroundWidth - MediaQuery.of(context).size.width);
      }
      if (backgroundToScroll < 0.0) {
        backgroundToScroll = 0.0;
      }

      widget.notifier.value = backgroundToScroll;
    } else {
      widget.notifier.value = 0;
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    filesProvider = Provider.of<FilesProvider>(context, listen: true);

    if (filesProvider.settings.length > 0) {
      Wakelock.toggle(enable: filesProvider.settings[0].toBoolean());
    } else {
      Wakelock.toggle(enable: true);
    }

    // Se il numero di players correnti ?? diverso da quelli salvati
    // stoppo i player, azzero i correnti e li inizializzo di nuovo
    if (players.length != filesProvider.filesPaths.length) {
      for (var i = 0; i < players.length; i++) {
        players[i].stop();
      }

      players = [];
      playing = [];
      volumes = [];
      files = [];
      states = [];

      for (var i = 0; i < filesProvider.filesPaths.length; i++) {
        players.add(AudioPlayer());
        players[i].setReleaseMode(ReleaseMode.LOOP);
        playing.add("-----");
        volumes.add(5);
        files.add("");
        states.add("---");
      }
    }

    return Center(
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Elenco dei file nel path impostato
              Expanded(
                child: NotificationListener(
                  onNotification: (t) {
                    setState(() {
                      onScroll(context);
                    });
                    return true;
                  },
                  child: ListView.separated(
                    padding: EdgeInsets.only(left: 10),
                    scrollDirection: Axis.horizontal,
                    controller: horizontalScrollController,
                    physics: BouncingScrollPhysics(),
                    // shrinkWrap: true,
                    itemCount: filesProvider.filesPaths.length + 1,
                    itemBuilder: (BuildContext context, int colIndex) {
                      // L`ultima colonna ?? quella con il pulsante per aggiungere altri player
                      if (colIndex == filesProvider.filesPaths.length) {
                        return SizedBox (
                          width: MediaQuery.of(context).size.width / 3,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return ColumnSettingsDialog(newCol: true, loc: widget.loc);
                                    },
                                  );
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width/5,
                                  height: 40,
                                  alignment: Alignment.center,
                                  child: Padding(
                                    padding: const EdgeInsets.all(0.0),
                                    child: Icon(
                                      Icons.add_rounded,
                                      color: Color(int.parse(filesProvider.settings[2])),
                                      semanticLabel: widget.loc.new_column,
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                    color: Color(int.parse(filesProvider.settings[1])),
                                    image: DecorationImage (
                                      image: AssetImage("assets/Btn/btn-double-border.png"),
                                      fit: BoxFit.fill,
                                      centerSlice: Rect.fromLTWH(2500, 2500, 2500, 2500),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        // Tutte le altre colonne vengono costruite
                        return buildColumn(context, colIndex, filesProvider);
                      }
                    },
                    separatorBuilder: (BuildContext context, int colIndex) {
                      return VerticalDivider(
                          color: Colors.black,
                          thickness: 0.5,
                          width: 20,
                          indent: 15,
                          endIndent: 50
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          (filesProvider.settings[5].toBoolean()) ?
          SizedBox.shrink() :
          Stack(
            children: [
              Opacity(
                opacity: 0.4,
                child: Container(
                  color: Colors.black,
                ),
              ),
              Opacity(
                opacity: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Container(
                            constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width/2,
                                maxHeight: MediaQuery.of(context).size.height/3
                            ),
                            margin: EdgeInsets.only(left:10.0, top:10.0),
                            alignment: Alignment.center,
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Text(
                                widget.loc.welcome_tutorial + "\n\n" +
                                    widget.loc.settings_tutorial,
                                maxLines: 10,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Color(int.parse(filesProvider.settings[2])),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            decoration: BoxDecoration(
                              color: Color(int.parse(filesProvider.settings[1])),
                              image: DecorationImage (
                                image: AssetImage("assets/Btn/btn-single-border.png"),
                                fit: BoxFit.fill,
                                centerSlice: Rect.fromLTWH(2500, 2500, 2500, 2500),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: CustomPaint(
                            painter: ArrowPainter(
                                0, (MediaQuery.of(context).size.height/3)/2,
                                MediaQuery.of(context).size.width/2 - 35, 0,
                                filesProvider.settings[1],
                            ),
                            child: Container(
                              constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width/2,
                                  maxHeight: MediaQuery.of(context).size.height/3
                              ),
                              margin: EdgeInsets.only(left:5.0, top:5.0),
                              alignment: Alignment.center,
                            ),
                          )
                        ),
                      ],
                    ),
                    Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                            flex: 1,
                            child: CustomPaint(
                              painter: ArrowPainter(
                                  MediaQuery.of(context).size.width/2, (MediaQuery.of(context).size.height/3)/2,
                                  70, 20,
                                  filesProvider.settings[1],
                              ),
                              child: Container(
                                constraints: BoxConstraints(
                                    maxWidth: MediaQuery.of(context).size.width/2,
                                    maxHeight: MediaQuery.of(context).size.height/3
                                ),
                                margin: EdgeInsets.only(left:5.0, top:5.0),
                                alignment: Alignment.center,
                              ),
                            )
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            width: MediaQuery.of(context).size.width/2,
                            height: MediaQuery.of(context).size.height/3,
                            margin: EdgeInsets.only(right:10.0, bottom:10.0),
                            alignment: Alignment.center,
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Text(
                                widget.loc.button_tutorial,
                                maxLines: 10,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Color(int.parse(filesProvider.settings[2])),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            decoration: BoxDecoration(
                              color: Color(int.parse(filesProvider.settings[1])),
                              image: DecorationImage (
                                image: AssetImage("assets/Btn/btn-single-border.png"),
                                fit: BoxFit.fill,
                                centerSlice: Rect.fromLTWH(2500, 2500, 2500, 2500),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            filesProvider.settings[5] = true.toString();
                            SharedPreferencesManager.updateKV("Settings", true, filesProvider.settings);
                            filesProvider.getSettings();
                          },
                          child: Container(
                            height: 40,
                            constraints: BoxConstraints(
                              minWidth: MediaQuery.of(context).size.width/5,
                            ),
                            margin: EdgeInsets.only(bottom:10.0),
                            alignment: Alignment.center,
                            child: Padding(
                              padding: const EdgeInsets.all(1.0),
                              child: Text(
                                widget.loc.done_tutorial,
                                maxLines: 2,
                                style: TextStyle(
                                  color: Color(int.parse(filesProvider.settings[2])),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            decoration: BoxDecoration(
                              color: Color(int.parse(filesProvider.settings[1])),
                              image: DecorationImage (
                                image: AssetImage("assets/Btn/btn-double-border.png"),
                                fit: BoxFit.fill,
                                centerSlice: Rect.fromLTWH(2500, 2500, 2500, 2500),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Metto in play l`audio selezionato e ne visualizza il titolo
  void playSelected(BuildContext context, String path, int colIndex) async {
    setState(() {
      files[colIndex] = path;
      playing[colIndex] = basename(path).capitalize();
      if (!(players[colIndex] is AudioPlayer)) {
        players[colIndex] = AudioPlayer();
        players[colIndex].setReleaseMode(ReleaseMode.LOOP);
      }
      players[colIndex].stop();
      players[colIndex].play(files[colIndex], isLocal: true);
      players[colIndex].setVolume(volumes[colIndex] / 10);
      states[colIndex] = widget.loc.playing;
    });
  }

  // Metto in play l`audio in memoria
  void play(int colIndex) {

    if (files[colIndex] != "") {
      players[colIndex].play(files[colIndex], isLocal: true);
      players[colIndex].setVolume(volumes[colIndex] / 10);

      setState(() {
        states[colIndex] = widget.loc.playing;
      });
    }
  }

  // Metto in pausa l`audio in memoria
  void pause(int colIndex) {

    if (files[colIndex] != null) {
      players[colIndex].pause();

      setState(() {
        states[colIndex] = widget.loc.paused;
      });
    }
  }

  // Metto in pausa l`audio in memoria
  void stop(int colIndex) {

    if (files[colIndex] != null) {
      players[colIndex].stop();

      setState(() {
        states[colIndex] = widget.loc.stopped;
      });
    }
  }

  // Imposto il volume
  void setVolume(String action, int colIndex) {

    setState(() {
      if (action == "up") {
        volumes[colIndex] = volumes[colIndex] + 1;
      } else {
        volumes[colIndex] = volumes[colIndex] - 1;
      }

      if (volumes[colIndex] > 10) {
        volumes[colIndex] = 10;
      }

      if (volumes[colIndex] < 0) {
        volumes[colIndex] = 0;
      }

      players[colIndex].setVolume(volumes[colIndex] / 10);
    });
  }

  // Metto in play le musiche di una directory in ordine casuale
  void random(BuildContext context, FilesProvider provider, int colIndex) {

    String path = provider.filesPaths[colIndex][new Random().nextInt(provider.filesPaths[colIndex].length)].path;
    players[colIndex].onPlayerCompletion.listen((event) {
      random(context, provider, colIndex);
    });
    playSelected(context, path, colIndex);

  }

  // Creo una colonna di gestione per una directory
  IntrinsicWidth buildColumn(BuildContext context, int colIndex, FilesProvider provider) {

    Color btnCol = Color(int.parse(provider.dirsColors[colIndex]));
    Color fontCol = Color(int.parse(provider.fontsColors[colIndex]));
    String dirName = provider.dirsNames[colIndex];

    return IntrinsicWidth(
      stepWidth: MediaQuery.of(context).size.width/3,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(
            height: 10,
            width: 10,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: btnCol,
              image: DecorationImage (
                image: AssetImage("assets/Btn/btn-single-border.png"),
                fit: BoxFit.fill,
                centerSlice: Rect.fromLTWH(2500, 2500, 2500, 2500),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        child: Text(
                          dirName,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 15,
                              color: fontCol),
                        ),
                        padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                      ),
                      IconButton(
                        icon: Icon(
                            Icons.settings_rounded,
                            color: fontCol,
                            semanticLabel: widget.loc.settings,
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return ColumnSettingsDialog(newCol: false, colIndex: colIndex, loc: widget.loc);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  Text(
                    basenameWithoutExtension(playing[colIndex]),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: fontCol,
                    ),
                  ),
                  Text(
                    widget.loc.state + ": " + states[colIndex],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 15,
                        color: fontCol,
                    ),
                  ),
                  Text(
                    widget.loc.volume + ": " + volumes[colIndex].toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 15,
                        color: fontCol,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
            width: 10,
          ),
          // Pulsanti di gestione musica e volume musica
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              (states[colIndex] == widget.loc.playing) ?
                GestureDetector(
                  onTap: () {
                    pause(colIndex);
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width/5,
                    height: 40,
                    margin: EdgeInsets.all(1.0),
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: Icon(
                        Icons.pause_rounded,
                        color: fontCol,
                        semanticLabel: widget.loc.pause,
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: btnCol,
                      image: DecorationImage (
                        image: AssetImage("assets/Btn/btn-double-border.png"),
                        fit: BoxFit.fill,
                        centerSlice: Rect.fromLTWH(2500, 2500, 2500, 2500),
                      ),
                    ),
                  ),
                )
                  :
                GestureDetector(
                  onTap: () {
                    play(colIndex);
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width/5,
                    height: 40,
                    margin: EdgeInsets.all(1.0),
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: Icon(
                        Icons.play_arrow_rounded,
                        color: fontCol,
                        semanticLabel: widget.loc.play,
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: btnCol,
                      image: DecorationImage (
                        image: AssetImage("assets/Btn/btn-double-border.png"),
                        fit: BoxFit.fill,
                        centerSlice: Rect.fromLTWH(2500, 2500, 2500, 2500),
                      ),
                    ),
                  ),
                ),
              GestureDetector(
                onTap: () {
                  stop(colIndex);
                },
                child: Container(
                  width: MediaQuery.of(context).size.width/5,
                  height: 40,
                  margin: EdgeInsets.all(1.0),
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: Icon(
                      Icons.stop_rounded,
                      color: fontCol,
                      semanticLabel: widget.loc.stop,
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: btnCol,
                    image: DecorationImage (
                      image: AssetImage("assets/Btn/btn-double-border.png"),
                      fit: BoxFit.fill,
                      centerSlice: Rect.fromLTWH(2500, 2500, 2500, 2500),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () {
                  setVolume("down", colIndex);
                },
                child: Container(
                  width: MediaQuery.of(context).size.width/5,
                  height: 40,
                  margin: EdgeInsets.all(1.0),
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: Icon(
                      Icons.volume_down_rounded,
                      color: fontCol,
                      semanticLabel: widget.loc.volume_down,
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: btnCol,
                    image: DecorationImage (
                      image: AssetImage("assets/Btn/btn-double-border.png"),
                      fit: BoxFit.fill,
                      centerSlice: Rect.fromLTWH(2500, 2500, 2500, 2500),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setVolume("up", colIndex);
                },
                child: Container(
                  width: MediaQuery.of(context).size.width/5,
                  height: 40,
                  margin: EdgeInsets.all(1.0),
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: Icon(
                      Icons.volume_up_rounded,
                      color: fontCol,
                      semanticLabel: widget.loc.volume_up,
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: btnCol,
                    image: DecorationImage (
                      image: AssetImage("assets/Btn/btn-double-border.png"),
                      fit: BoxFit.fill,
                      centerSlice: Rect.fromLTWH(2500, 2500, 2500, 2500),
                    ),
                  ),
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              random(context, provider, colIndex);
            },
            child: Container(
              width: MediaQuery.of(context).size.width/3.5,
              height: 40,
              margin: EdgeInsets.all(1.0),
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.all(0.0),
                child: Row (
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shuffle_rounded,
                      color: fontCol,
                    ),
                    Text(
                      widget.loc.random,
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: 15,
                        color: fontCol,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              decoration: BoxDecoration(
                color: btnCol,
                image: DecorationImage (
                  image: AssetImage("assets/Btn/btn-double-border.png"),
                  fit: BoxFit.fill,
                  centerSlice: Rect.fromLTWH(2500, 2500, 2500, 2500),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 10,
            width: 10,
          ),
          Expanded(
            child: SizedBox(
              width: 200,
              child: Scrollbar(
                radius: Radius.circular(30),
                child: ListView.separated(
                  scrollDirection: Axis.vertical,
                  controller: verticalScrollController,
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  itemCount: (provider.filesPaths[colIndex].length / colonnePerTipo).round(),
                  itemBuilder: (BuildContext context, int rowIndex) {
                    return buildRow(context, colIndex, rowIndex, provider, btnCol, fontCol);
                  },
                  separatorBuilder: (BuildContext context, int rowIndex) {
                    return SizedBox(
                      height: 10,
                      width: 10,
                    );
                  },
                ),
              ),
            ),
          ),
          SizedBox(
            height: 10,
            width: 10,
          ),
        ],
      ),
    );
  }

  // Creo una riga di pulsanti per le musiche
  Row buildRow(BuildContext context, int colIndex, int rowIndex, FilesProvider provider, Color btnCol, Color fontCol) {
    List<Widget> sizedBoxes = [];

    // Aggiunge i pulsanti musica alla riga o pulsanti vuoti se servono
    for (int i = 0; i < colonnePerTipo; i++) {
      int musicIndex = (rowIndex * colonnePerTipo) + i;
      if (musicIndex < provider.filesPaths[colIndex].length) {
        sizedBoxes.add(
          Flexible(
            flex: 1,
            child: SizedBox(
              width: MediaQuery
                  .of(context)
                  .size
                  .width * 0.23,
              child: GestureDetector(
                onTap: () {
                  playSelected(context,
                    provider.filesPaths[colIndex][musicIndex].path,
                    colIndex);
                },
                child: Container(
                  width: MediaQuery.of(context).size.width/5,
                  height: 40,
                  margin: EdgeInsets.all(1.0),
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                    child: Text(
                      basenameWithoutExtension(provider.filesPaths[colIndex][musicIndex].path).capitalize(),
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: 15,
                        color: fontCol,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: btnCol,
                    image: DecorationImage (
                      image: AssetImage("assets/Btn/btn-double-border.png"),
                      fit: BoxFit.fill,
                      centerSlice: Rect.fromLTWH(2500, 2500, 2500, 2500)
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      } else {
        sizedBoxes.add(
          Flexible(
            flex: 1,
            child: SizedBox(
              width: MediaQuery
                  .of(context)
                  .size
                  .width * 0.23,
            )
          )
        );
      }
    }
print(sizedBoxes.toString());
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children:
        sizedBoxes,
    );
  }
}

class DashedLineVerticalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double dashHeight = 5, dashSpace = 3, startY = 0;
    final paint = Paint()
      ..color = Colors.grey[300]
      ..strokeWidth = 1;
    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
