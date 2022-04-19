import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:music_handler/files_provider.dart';
import 'package:music_handler/string_extension.dart';
import 'package:wakelock/wakelock.dart';
import 'column_settings_dialog.dart';

class MusicPage extends StatefulWidget {
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

  final ScrollController scrollController = ScrollController();
  FilesProvider filesProvider;
  final colonnePerTipo = 2;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    filesProvider = Provider.of<FilesProvider>(context, listen: true);

    if (filesProvider.settings.length > 0) {
      Wakelock.toggle(enable: filesProvider.settings[1].toBoolean());
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
            child: ListView.separated(
              padding: EdgeInsets.only(left: 10),
              scrollDirection: Axis.horizontal,
              controller: scrollController,
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
                        ElevatedButton(
                          child: Icon(Icons.add_rounded),
                          style: ElevatedButton.styleFrom(elevation: 8.0, primary: Color(int.parse("0xFF009000")), fixedSize: Size(MediaQuery.of(context).size.width/5, 40)),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return ColumnSettingsDialog(newCol: true);
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  );
                } else {
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
    String dirName = provider.dirsNames[colIndex];

    // return Column(
    return IntrinsicWidth(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dirName,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15),
              ),
              IconButton(
                icon: Icon(Icons.settings_rounded),
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
                fontWeight: FontWeight.bold
            ),
          ),
          Text(
            filesProvider.translations[0]["state"] + ": " + states[colIndex],
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 15
            ),
          ),
          Text(
            filesProvider.translations[0]["volume"] + ": " + volumes[colIndex].toString(),
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 15
            ),
          ),
          // Pulsanti di gestione musica e volume musica
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                child: Icon(Icons.stop_rounded),
                style: ElevatedButton.styleFrom(elevation: 8.0, primary: btnCol, fixedSize: Size(MediaQuery.of(context).size.width/5, 40)),
                onPressed: () {
                  stop(colIndex);
                },
              ),
              SizedBox(
                width: 10,
              ),
              ElevatedButton(
                child: Icon(Icons.pause_rounded),
                style: ElevatedButton.styleFrom(elevation: 8.0, primary: btnCol, fixedSize: Size(MediaQuery.of(context).size.width/5, 40)),
                onPressed: () {
                  pause(colIndex);
                },
              ),
              SizedBox(
                width: 10,
              ),
              ElevatedButton(
                child: Icon(Icons.play_arrow_rounded),
                style: ElevatedButton.styleFrom(elevation: 8.0, primary: btnCol, fixedSize: Size(MediaQuery.of(context).size.width/5, 40)),
                onPressed: () {
                  play(colIndex);
                },
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                child: Icon(Icons.volume_down_rounded),
                style: ElevatedButton.styleFrom(elevation: 8.0, primary: btnCol, fixedSize: Size(MediaQuery.of(context).size.width/5, 40)),
                onPressed: () {
                  setVolume("down", colIndex);
                },
              ),
              SizedBox(
                width: 10,
              ),
              ElevatedButton(
                child: Icon(Icons.volume_up_rounded),
                style: ElevatedButton.styleFrom(elevation: 8.0, primary: btnCol, fixedSize: Size(MediaQuery.of(context).size.width/5, 40)),
                onPressed: () {
                  setVolume("up", colIndex);
                },
              ),
            ],
          ),
          ElevatedButton.icon(
            label: Text(
              filesProvider.translations[0]["random"],
              style: TextStyle(
                fontSize: 15,
              ),
            ),
            icon: Icon(Icons.shuffle_rounded),
            style: ElevatedButton.styleFrom(elevation: 8.0,
                primary: btnCol,
                fixedSize: Size(MediaQuery.of(context).size.width / 2.5, 40)),
            onPressed: () {
              random(context, provider, colIndex);
            },
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
                  controller: scrollController,
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  itemCount: (provider.filesPaths[colIndex].length / colonnePerTipo).round(),
                  itemBuilder: (BuildContext context, int rowIndex) {
                    return buildRow(context, colIndex, rowIndex, provider, btnCol);
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
        ],
      ),
    );
  }

  // Creo una riga di pulsanti per le musiche
  Row buildRow(BuildContext context, int colIndex, int rowIndex, FilesProvider provider, Color btnCol) {
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
            child: ElevatedButton(
              child: Text(basenameWithoutExtension(provider.filesPaths[colIndex][musicIndex].path).capitalize()),
              style: ElevatedButton.styleFrom(elevation: 8.0, primary: btnCol),
              onPressed: () {
                playSelected(context,
                    provider.filesPaths[colIndex][musicIndex].path,
                    colIndex);
              },
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
