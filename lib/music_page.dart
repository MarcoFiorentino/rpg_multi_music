import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

import 'package:music_handler/files_provider.dart';
import 'package:music_handler/string_extension.dart';

/*
Gestisco la pagina delle colonne sonore.
Queste sono divise in due macrogruppi:
- ambientale: sono le musiche di background (pioggia, vento, ecc.)
- musica: sono le musiche particolari della scena (combattimento, gruppo che suona, ecc.)
Possono essere eseguite una musica ed un effetto ambientale in contemporanea e gestite in contemporanea.
 */

class MusicPage extends StatefulWidget {
  @override
  _MusicPageState createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> {
  // TODO: gestire da settings il numero di tipi diversi di musiche da poter gestire
  List<AudioPlayer> players = [];
  List<String> playing = [];
  List<int> volumes = [];
  List<String> files = [];

  final ScrollController scrollController = ScrollController();
  final colonnePerTipo = 2;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final FilesProvider filesProvider = Provider.of<FilesProvider>(context, listen: true);

    for (var i = 0; i < filesProvider.dirNames.length; i++) {
      // print(filesProvider.dirNames[i]);
      players.add(AudioPlayer());
      players[i].setReleaseMode(ReleaseMode.LOOP);
      playing.add("---");
      volumes.add(5);
      files.add("");
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
              scrollDirection: Axis.horizontal,
              controller: scrollController,
              itemCount: filesProvider.dirNames.length,
              itemBuilder: (BuildContext context, int colIndex) {
                return buildColumn(context, colIndex, filesProvider);
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
  void playSelected(String path, int colIndex) async {

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
    });
  }

  // Metto in play l'audio in memoria
  void play(int colIndex) {

    if (files[colIndex] != "") {
      players[colIndex].play(files[colIndex], isLocal: true);
      players[colIndex].setVolume(volumes[colIndex] / 10);
    }
  }

  // Metto in pausa l'audio in memoria
  void pause(int colIndex) {

    if (files[colIndex] != null) {
      players[colIndex].pause();
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

  // Metto in play le musiche di una categoria in ordine casuale
  void random(FilesProvider provider, int colIndex) {

    String path = provider.dirNames[colIndex][new Random().nextInt(provider.dirNames[colIndex].length)].path;
    playSelected(path, colIndex);
    players[colIndex].onPlayerCompletion.listen((event) {
      random(provider, colIndex);
    });
  }

  // Creo una colonna di gestione per una cartella
  Column buildColumn(BuildContext context, int colIndex, FilesProvider provider) {

    // Color btnCol = Color(int.parse(provider.colors[colIndex]));
    Color btnCol = Colors.green;
// print(provider.directories.keys.skip(colIndex).take(1));
    return Column(
      // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Visualizza titolo e volume
        Text(
          // provider.directories.keys.skip(colIndex).take(1).first + ": ",
          "AAA",
          textAlign: TextAlign.center,
        ),
        Text(
          basenameWithoutExtension(playing[colIndex]),
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
              child: Text("-"),
              style: ElevatedButton.styleFrom(elevation: 8.0, primary: btnCol, fixedSize: Size(MediaQuery.of(context).size.width/5, 40)),
              onPressed: () {
                setVolume("down", colIndex);
              },
            ),
            SizedBox(
              width: 10,
            ),
            ElevatedButton(
              child: Text("+"),
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
            random(provider, colIndex);
          },
        ),
        SizedBox(
          height: 400,
          width: 200,
          child: ListView.separated(
            scrollDirection: Axis.vertical,
            controller: scrollController,
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            itemCount: (provider.dirNames[colIndex].length / colonnePerTipo).round(),
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
      if (musicIndex < provider.dirNames[colIndex].length) {
        sizedBoxes.add(
          SizedBox(
            width: MediaQuery
                .of(context)
                .size
                .width * 0.23,
            child: ElevatedButton(
              child: Text(basenameWithoutExtension(
                  provider.dirNames[colIndex][musicIndex].path)
                  .capitalize()),
              style: ElevatedButton.styleFrom(
                  elevation: 8.0, primary: btnCol),
              onPressed: () {
                playSelected(provider.dirNames[colIndex][musicIndex].path,
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
