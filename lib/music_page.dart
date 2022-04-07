import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:music_handler/files_provider.dart';
import 'package:music_handler/string_extension.dart';
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

    // print("2: " + AppLocalizations.of(context).toString());
    // Questo è sbagliato perchè ad ogni build aggiunge valori
    // Io uso sempre i soliti ma le liste crescono all'infinito
    for (var i = 0; i < filesProvider.filesPaths.length; i++) {
      players.add(AudioPlayer());
      players[i].setReleaseMode(ReleaseMode.LOOP);
      playing.add("---");
      volumes.add(5);
      files.add("");
      states.add("");
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(""),
          // Elenco dei file nel path impostato
          Expanded(
            child: ListView.separated(
              physics: BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              controller: scrollController,
              itemCount: filesProvider.filesPaths.length + 1,
              itemBuilder: (BuildContext context, int colIndex) {
                // L'ultima colonna è quella con il pulsante per aggiungerne altre
                if (colIndex == filesProvider.filesPaths.length) {
                  return SizedBox (
                    width: 100,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          child: Text("+"),
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
                return SizedBox(
                  width: 30,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Metto in play l'audio selezionato e ne visualizza il titolo
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
      states[colIndex] = "Playing";
      // states[colIndex] = AppLocalizations.of(context).playing;
    });
  }

  // Metto in play l'audio in memoria
  void play(int colIndex) {

    if (files[colIndex] != "") {
      players[colIndex].play(files[colIndex], isLocal: true);
      players[colIndex].setVolume(volumes[colIndex] / 10);

      setState(() {
        states[colIndex] = "Playing";
      });
    }
  }

  // Metto in pausa l'audio in memoria
  void pause(int colIndex) {

    if (files[colIndex] != null) {
      players[colIndex].pause();

      setState(() {
        states[colIndex] = "Paused";
      });
    }
  }

  // Metto in pausa l'audio in memoria
  void stop(int colIndex) {

    if (files[colIndex] != null) {
      players[colIndex].stop();

      setState(() {
        states[colIndex] = "Stopped";
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
  Column buildColumn(BuildContext context, int colIndex, FilesProvider provider) {

    Color btnCol = Color(int.parse(provider.dirsColors[colIndex]));
    String dirName = provider.dirsNames[colIndex];

    return Column(
      children: [
        // Visualizza titolo e volume
        Row(
          children: [
            Text(
              dirName,
              textAlign: TextAlign.center,
            ),
            IconButton(
              icon: Icon(Icons.more_vert),
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
        ),
        Text(
          "State: " + states[colIndex],
          textAlign: TextAlign.center,
        ),
        Text(
          "Vol: " + volumes[colIndex].toString(),
          textAlign: TextAlign.center,
        ),
        // Pulsanti di gestione musica e volume musica
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              child: Text("Stop"),
              style: ElevatedButton.styleFrom(elevation: 8.0, primary: btnCol, fixedSize: Size(MediaQuery.of(context).size.width/5, 40)),
              onPressed: () {
                stop(colIndex);
              },
            ),
            SizedBox(
              width: 10,
            ),
            ElevatedButton(
              child: Text("Pause"),
              style: ElevatedButton.styleFrom(elevation: 8.0, primary: btnCol, fixedSize: Size(MediaQuery.of(context).size.width/5, 40)),
              onPressed: () {
                pause(colIndex);
              },
            ),
            SizedBox(
              width: 10,
            ),
            ElevatedButton(
              child: Text("Play"),
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
              child: Text("Vol -"),
              style: ElevatedButton.styleFrom(elevation: 8.0, primary: btnCol, fixedSize: Size(MediaQuery.of(context).size.width/5, 40)),
              onPressed: () {
                setVolume("down", colIndex);
              },
            ),
            SizedBox(
              width: 10,
            ),
            ElevatedButton(
              child: Text("Vol +"),
              style: ElevatedButton.styleFrom(elevation: 8.0, primary: btnCol, fixedSize: Size(MediaQuery.of(context).size.width/5, 40)),
              onPressed: () {
                setVolume("up", colIndex);
              },
            ),
          ],
        ),
        Divider(
          height: 10,
          thickness: 5
        ),
        ElevatedButton(
          child: Text("Random"),
          style: ElevatedButton.styleFrom(elevation: 8.0,
              primary: btnCol,
              fixedSize: Size(MediaQuery
                  .of(context)
                  .size
                  .width / 2.5, 40)),
          onPressed: () {
            random(context, provider, colIndex);
          },
        ),
        SizedBox(
          height: 300,
          width: 200,
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
      ],
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
              child: Text(basenameWithoutExtension(
                  provider.filesPaths[colIndex][musicIndex].path)
                  .capitalize()),
              style: ElevatedButton.styleFrom(
                  elevation: 8.0, primary: btnCol),
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
