import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:multi_music_handler/files_provider.dart';
import 'package:multi_music_handler/string_extension.dart';
import 'package:wakelock/wakelock.dart';
import 'column_settings_dialog.dart';

class MusicPage extends StatefulWidget {
  final ValueNotifier<double> notifier;

  const MusicPage({Key key, this.notifier}) : super(key: key);

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
    double pageIndex = (horizontalScrollController.offset / MediaQuery.of(context).size.width);
    double fractionOfPages = pageIndex / (filesProvider.filesPaths.length + 1);
    double viewportWidth = MediaQuery.of(context).size.width;
    double fractionOfViewport = fractionOfPages * viewportWidth;
    widget.notifier.value = fractionOfViewport;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    filesProvider = Provider.of<FilesProvider>(context, listen: true);

    if (filesProvider.settings.length > 0) {
      Wakelock.toggle(enable: filesProvider.settings[1].toBoolean());
    } else {
      Wakelock.toggle(enable: true);
    }

    // Se il numero di players correnti è diverso da quelli salvati
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
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
                shrinkWrap: true,
                itemCount: filesProvider.filesPaths.length + 1,
                itemBuilder: (BuildContext context, int colIndex) {
                  // L`ultima colonna è quella con il pulsante per aggiungere altri player
                  if (colIndex == filesProvider.filesPaths.length) {
                    return SizedBox (
                      width: 100,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return ColumnSettingsDialog(newCol: true);
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
                                  color: Color(int.parse(filesProvider.settings[3])),
                                ),
                              ),
                              decoration: BoxDecoration(
                                color: Color(int.parse(filesProvider.settings[2])),
                                image: DecorationImage (
                                  image: AssetImage("assets/btn-double-border.png"),
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
      states[colIndex] = filesProvider.translations[0]["playing"];
    });
  }

  // Metto in play l`audio in memoria
  void play(int colIndex) {

    if (files[colIndex] != "") {
      players[colIndex].play(files[colIndex], isLocal: true);
      players[colIndex].setVolume(volumes[colIndex] / 10);

      setState(() {
        states[colIndex] = filesProvider.translations[0]["playing"];
      });
    }
  }

  // Metto in pausa l`audio in memoria
  void pause(int colIndex) {

    if (files[colIndex] != null) {
      players[colIndex].pause();

      setState(() {
        states[colIndex] = filesProvider.translations[0]["paused"];
      });
    }
  }

  // Metto in pausa l`audio in memoria
  void stop(int colIndex) {

    if (files[colIndex] != null) {
      players[colIndex].stop();

      setState(() {
        states[colIndex] = filesProvider.translations[0]["stopped"];
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
                image: AssetImage("assets/btn-single-border.png"),
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
                      Text(
                        dirName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 15,
                            color: fontCol),
                      ),
                      IconButton(
                        icon: Icon(
                            Icons.settings_rounded,
                            color: fontCol
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return ColumnSettingsDialog(newCol: false, colIndex: colIndex);
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
                    filesProvider.translations[0]["state"] + ": " + states[colIndex],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 15,
                        color: fontCol,
                    ),
                  ),
                  Text(
                    filesProvider.translations[0]["volume"] + ": " + volumes[colIndex].toString(),
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
              (states[colIndex] == filesProvider.translations[0]["playing"]) ?
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
                      ),
                    ),
                    decoration: BoxDecoration(
                      // borderRadius: BorderRadius.circular(5),
                      color: btnCol,
                      image: DecorationImage (
                        image: AssetImage("assets/btn-double-border.png"),
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
                      ),
                    ),
                    decoration: BoxDecoration(
                      // borderRadius: BorderRadius.circular(5),
                      color: btnCol,
                      image: DecorationImage (
                        image: AssetImage("assets/btn-double-border.png"),
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
                    ),
                  ),
                  decoration: BoxDecoration(
                    // borderRadius: BorderRadius.circular(5),
                    color: btnCol,
                    image: DecorationImage (
                      image: AssetImage("assets/btn-double-border.png"),
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
                    ),
                  ),
                  decoration: BoxDecoration(
                    // borderRadius: BorderRadius.circular(5),
                    color: btnCol,
                    image: DecorationImage (
                      image: AssetImage("assets/btn-double-border.png"),
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
                    ),
                  ),
                  decoration: BoxDecoration(
                    // borderRadius: BorderRadius.circular(5),
                    color: btnCol,
                    image: DecorationImage (
                      image: AssetImage("assets/btn-double-border.png"),
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
                      filesProvider.translations[0]["random"],
                      style: TextStyle(
                        fontSize: 15,
                        color: fontCol,
                      ),
                    ),
                  ],
                ),
              ),
              decoration: BoxDecoration(
                // borderRadius: BorderRadius.circular(5),
                color: btnCol,
                image: DecorationImage (
                  image: AssetImage("assets/btn-double-border.png"),
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
          SizedBox(
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
                  // borderRadius: BorderRadius.circular(5),
                  color: btnCol,
                  image: DecorationImage (
                    image: AssetImage("assets/btn-double-border.png"),
                    fit: BoxFit.fill,
                    centerSlice: Rect.fromLTWH(2500, 2500, 2500, 2500)
                  ),
                ),
              ),
            ),
          ),
        );
      } else {
        sizedBoxes.add(SizedBox(
          width: MediaQuery
              .of(context)
              .size
              .width * 0.23,
        ));
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: sizedBoxes,
    );
  }
}
