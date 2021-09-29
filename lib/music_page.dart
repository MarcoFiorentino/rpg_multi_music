import 'dart:math';

import 'package:flutter/material.dart';

import 'package:audioplayers/audioplayers.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

import 'package:music_handler/string_extension.dart';
import 'package:music_handler/files_provider.dart';

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
  final musicAudioPlayer = AudioPlayer();
  final ambienceAudioPlayer = AudioPlayer();
  var musicPlaying = "---";
  var ambiencePlaying = "---";
  var musicVolume = 5;
  var ambienceVolume = 5;
  var musicFile;
  var ambienceFile;
  final ScrollController scrollController = ScrollController();
  final colonnePerTipo = 2;

  @override
  void initState() {
    super.initState();

    musicAudioPlayer.setReleaseMode(ReleaseMode.LOOP);
    ambienceAudioPlayer.setReleaseMode(ReleaseMode.LOOP);
    print('INIT');
  }

  @override
  Widget build(BuildContext context) {
    final FilesProvider filesProvider = Provider.of<FilesProvider>(context, listen: true);

    print('Build: ' + filesProvider.ambienceNames.toString());
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(""),
          // Gestione degli audio musica
          // Visualizza titolo e volume
          Text(
            "Musica: " + musicPlaying + " - Vol: " + musicVolume.toString(),
            textAlign: TextAlign.center,
          ),
          // Pulsanti di gestione musica e volume musica
          Table(children: [
            TableRow(
              children: [
                TableCell(
                  child: ElevatedButton(
                    child: Text("Play"),
                    style: ElevatedButton.styleFrom(elevation: 8.0, primary: Colors.lightGreen),
                    onPressed: () {
                      play("musica");
                    },
                  ),
                ),
                TableCell(
                  child: ElevatedButton(
                    child: Text("+"),
                    style: ElevatedButton.styleFrom(elevation: 8.0, primary: Colors.lightGreen),
                    onPressed: () {
                      setVolume("musica", "up");
                    },
                  ),
                ),
                TableCell(
                  child: ElevatedButton(
                    child: Text("-"),
                    style: ElevatedButton.styleFrom(elevation: 8.0, primary: Colors.lightGreen),
                    onPressed: () {
                      setVolume("musica", "down");
                    },
                  ),
                ),
                TableCell(
                  child: ElevatedButton(
                    child: Text("Pause"),
                    style: ElevatedButton.styleFrom(elevation: 8.0, primary: Colors.lightGreen),
                    onPressed: () {
                      pause("musica");
                    },
                  ),
                ),
              ],
            ),
          ]),
          // Gestione degli audio ambientali
          // Visualizza titolo e volume
          Text(
            "Ambientale: " + ambiencePlaying + " - Vol: " + ambienceVolume.toString(),
            textAlign: TextAlign.center,
          ),
          // Pulsanti di gestione ambientali e volume ambientali
          Table(
            children: [
              TableRow(
                children: [
                  TableCell(
                    child: ElevatedButton(
                      child: Text("Play"),
                      style: ElevatedButton.styleFrom(elevation: 8.0, primary: Colors.lightBlue),
                      onPressed: () {
                        play("ambientale");
                      },
                    ),
                  ),
                  TableCell(
                    child: ElevatedButton(
                      child: Text("+"),
                      style: ElevatedButton.styleFrom(elevation: 8.0, primary: Colors.lightBlue),
                      onPressed: () {
                        setVolume("ambientale", "up");
                      },
                    ),
                  ),
                  TableCell(
                    child: ElevatedButton(
                      child: Text("-"),
                      style: ElevatedButton.styleFrom(elevation: 8.0, primary: Colors.lightBlue),
                      onPressed: () {
                        setVolume("ambientale", "down");
                      },
                    ),
                  ),
                  TableCell(
                    child: ElevatedButton(
                      child: Text("Pause"),
                      style: ElevatedButton.styleFrom(elevation: 8.0, primary: Colors.lightBlue),
                      onPressed: () {
                        pause("ambientale");
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Elenco dei file nel path impostato
          // TODO: gestire anche scorrimento in larghezza
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: (max(filesProvider.musicNames.length, filesProvider.ambienceNames.length) / colonnePerTipo).round(),
              itemBuilder: (BuildContext context, int index) {
                return buildRow(context, index, filesProvider);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Metto in play l'audio selezionato e ne visualizza il titolo
  void playSelected(String type, String path) async {
    switch (type) {
      case "musica":
        setState(() {
          musicFile = path;
          musicAudioPlayer.play(musicFile, isLocal: true);
          musicPlaying = basename(path).capitalize();
          musicAudioPlayer.setVolume(musicVolume / 10);
        });
        break;

      case "ambientale":
        setState(() {
          ambienceFile = path;
          ambienceAudioPlayer.play(ambienceFile, isLocal: true);
          ambiencePlaying = basename(path).capitalize();
          ambienceAudioPlayer.setVolume(ambienceVolume / 10);
        });
        break;
    }
  }

  // Metto in play l'audio in memoria
  void play(String type) {
    switch (type) {
      case "musica":
        if (musicFile != null) {
          musicAudioPlayer.play(musicFile, isLocal: true);
          musicAudioPlayer.setVolume(musicVolume / 10);
        }
        break;

      case "ambientale":
        if (ambienceFile != null) {
          ambienceAudioPlayer.play(ambienceFile, isLocal: true);
          ambienceAudioPlayer.setVolume(ambienceVolume / 10);
        }
        break;
    }
  }

  // Metto in pausa l'audio in memoria
  void pause(String type) {
    switch (type) {
      case "musica":
        if (musicFile != null) {
          musicAudioPlayer.pause();
        }
        break;

      case "ambientale":
        if (ambienceFile != null) {
          ambienceAudioPlayer.pause();
        }
        break;
    }
  }

  // Imposto il volume
  void setVolume(String type, String action) {
    switch (type) {
      case "musica":
        setState(() {
          if (action == "up") {
            musicVolume = musicVolume + 1;
          } else {
            musicVolume = musicVolume - 1;
          }

          if (musicVolume > 10) {
            musicVolume = 10;
          }
          if (musicVolume < 0) {
            musicVolume = 0;
          }

          musicAudioPlayer.setVolume(musicVolume / 10);
        });
        break;

      case "ambientale":
        setState(() {
          if (action == "up") {
            ambienceVolume = ambienceVolume + 1;
          } else {
            ambienceVolume = ambienceVolume - 1;
          }

          if (ambienceVolume > 10) {
            ambienceVolume = 10;
          }
          if (ambienceVolume < 0) {
            ambienceVolume = 0;
          }

          ambienceAudioPlayer.setVolume(ambienceVolume / 10);
        });
        break;
    }
  }

  // Creo una riga di pulsanti per le musiche
  Row buildRow(BuildContext context, int index, FilesProvider provider) {
    List<Widget> sizedBoxes = [];

    // Aggiunge i pulsanti musica alla riga o pulsanti vuoti se servono
    for (int i = 0; i < colonnePerTipo; i++) {
      if (((index * colonnePerTipo) + i) < provider.musicNames.length) {
        sizedBoxes.add(
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.23,
            child: ElevatedButton(
              child: Text(basename(provider.musicNames[(index * colonnePerTipo) + i].path).capitalize()),
              style: ElevatedButton.styleFrom(elevation: 8.0, primary: Colors.lightGreen),
              onPressed: () {
                playSelected("musica", provider.musicNames[(index * colonnePerTipo) + i].path);
              },
            ),
          ),
        );
      } else {
        sizedBoxes.add(SizedBox(
          width: MediaQuery.of(context).size.width * 0.23,
        ));
      }
    }

    // Aggiunge i pulsanti ambiente alla riga o pulsanti vuoti se servono
    for (int i = 0; i < colonnePerTipo; i++) {
      if (((index * colonnePerTipo) + i) < provider.ambienceNames.length) {
        sizedBoxes.add(
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.23,
            child: ElevatedButton(
              child: Text(basename(provider.ambienceNames[(index * colonnePerTipo) + i].path).capitalize()),
              style: ElevatedButton.styleFrom(elevation: 8.0, primary: Colors.lightBlue),
              onPressed: () {
                playSelected("ambientale", provider.ambienceNames[(index * colonnePerTipo) + i].path);
              },
            ),
          ),
        );
      } else {
        sizedBoxes.add(SizedBox(
          width: MediaQuery.of(context).size.width * 0.23,
        ));
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: sizedBoxes,
    );
  }
}
