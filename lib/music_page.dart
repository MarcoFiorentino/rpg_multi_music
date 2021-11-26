import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:music_handler/shared_preferences_manager.dart';
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
  final musicAudioPlayer = AudioPlayer();
  final ambienceAudioPlayer = AudioPlayer();
  final randomMusicAudioPlayer = AudioPlayer();
  final randomAmbienceAudioPlayer = AudioPlayer();
  var currentMusicAudioPlayer;
  var currentAmbienceAudioPlayer;
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
    randomMusicAudioPlayer.setReleaseMode(ReleaseMode.RELEASE);
    randomAmbienceAudioPlayer.setReleaseMode(ReleaseMode.RELEASE);
    currentMusicAudioPlayer = musicAudioPlayer;
    currentAmbienceAudioPlayer = ambienceAudioPlayer;
  }

  @override
  Widget build(BuildContext context) {
    final FilesProvider filesProvider = Provider.of<FilesProvider>(context, listen: true);
    String firstDir = filesProvider.directories[SharedPreferencesManager.firstDirectory] != null ?
      basename(filesProvider.directories[SharedPreferencesManager.firstDirectory]) :
      SharedPreferencesManager.firstDirectory;
    String secondDir = filesProvider.directories[SharedPreferencesManager.secondDirectory] != null ?
      basename(filesProvider.directories[SharedPreferencesManager.secondDirectory]) :
      SharedPreferencesManager.secondDirectory;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(""),
          // Visualizza titolo e volume
          Text(
            firstDir + ": " + musicPlaying + " - Vol: " + musicVolume.toString(),
            textAlign: TextAlign.center,
          ),
          // Pulsanti di gestione musica e volume musica
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                child: Text("Play"),
                style: ElevatedButton.styleFrom(elevation: 8.0, primary: Colors.lightGreen, fixedSize: Size(MediaQuery.of(context).size.width/5, 40)),
                onPressed: () {
                  play("musica");
                },
              ),
              ElevatedButton(
                child: Text("+"),
                style: ElevatedButton.styleFrom(elevation: 8.0, primary: Colors.lightGreen, fixedSize: Size(MediaQuery.of(context).size.width/5, 40)),
                onPressed: () {
                  setVolume("musica", "up");
                },
              ),
              ElevatedButton(
                child: Text("-"),
                style: ElevatedButton.styleFrom(elevation: 8.0, primary: Colors.lightGreen, fixedSize: Size(MediaQuery.of(context).size.width/5, 40)),
                onPressed: () {
                  setVolume("musica", "down");
                },
              ),
              ElevatedButton(
                child: Text("Pause"),
                style: ElevatedButton.styleFrom(elevation: 8.0, primary: Colors.lightGreen, fixedSize: Size(MediaQuery.of(context).size.width/5, 40)),
                onPressed: () {
                  pause("musica");
                },
              ),
            ],
          ),
          // Visualizza titolo e volume
          Text(
            secondDir + ": " + ambiencePlaying + " - Vol: " + ambienceVolume.toString(),
            textAlign: TextAlign.center,
          ),
          // Pulsanti di gestione ambientali e volume ambientali
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                  child: Text("Play"),
                  style: ElevatedButton.styleFrom(elevation: 8.0, primary: Colors.lightBlue, fixedSize: Size(MediaQuery.of(context).size.width/5, 40)),
                  onPressed: () {
                    play("ambientale");
                  },
              ),
              ElevatedButton(
                  child: Text("+"),
                  style: ElevatedButton.styleFrom(elevation: 8.0, primary: Colors.lightBlue, fixedSize: Size(MediaQuery.of(context).size.width/5, 40)),
                  onPressed: () {
                    setVolume("ambientale", "up");
                  },
              ),
              ElevatedButton(
                  child: Text("-"),
                  style: ElevatedButton.styleFrom(elevation: 8.0, primary: Colors.lightBlue, fixedSize: Size(MediaQuery.of(context).size.width/5, 40)),
                  onPressed: () {
                    setVolume("ambientale", "down");
                  },
              ),
              ElevatedButton(
                  child: Text("Pause"),
                  style: ElevatedButton.styleFrom(elevation: 8.0, primary: Colors.lightBlue, fixedSize: Size(MediaQuery.of(context).size.width/5, 40)),
                  onPressed: () {
                    pause("ambientale");
                  },
              ),
            ],
          ),
          const Divider(
            height: 20,
            thickness: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                child: Text("Random"),
                style: ElevatedButton.styleFrom(elevation: 8.0, primary: Colors.lightGreen, fixedSize: Size(MediaQuery.of(context).size.width/2.5, 40)),
                onPressed: () {
                  random("musica", filesProvider);
                },
              ),
              ElevatedButton(
                child: Text("Random"),
                style: ElevatedButton.styleFrom(elevation: 8.0, primary: Colors.lightBlue, fixedSize: Size(MediaQuery.of(context).size.width/2.5, 40)),
                onPressed: () {
                  random("ambientale", filesProvider);
                },
              ),
            ]
          ),
          // Elenco dei file nel path impostato
          // TODO: gestire anche scorrimento in larghezza
          Expanded(
            child: ListView.separated(
              controller: scrollController,
              itemCount: (max(filesProvider.firstDirNames.length, filesProvider.secondDirNames.length) / colonnePerTipo).round(),
              itemBuilder: (BuildContext context, int index) {
                return buildRow(context, index, filesProvider);
              },
              separatorBuilder: (BuildContext context, int index) {
                return SizedBox(
                  height: 10,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Metto in play l'audio selezionato e ne visualizza il titolo
  void playSelected(String type, String path, bool random) async {
    switch (type) {
      case "musica":
        setState(() {
          musicFile = path;
          musicPlaying = basename(path).capitalize();
          currentMusicAudioPlayer.stop();
          currentMusicAudioPlayer = random ? randomMusicAudioPlayer : musicAudioPlayer;
          currentMusicAudioPlayer.play(musicFile, isLocal: true);
          currentMusicAudioPlayer.setVolume(musicVolume / 10);
        });
        break;

      case "ambientale":
        setState(() {
          ambienceFile = path;
          ambiencePlaying = basename(path).capitalize();
          currentAmbienceAudioPlayer.stop();
          currentAmbienceAudioPlayer = random ? randomAmbienceAudioPlayer : ambienceAudioPlayer;
          currentAmbienceAudioPlayer.play(ambienceFile, isLocal: true);
          currentAmbienceAudioPlayer.setVolume(ambienceVolume / 10);
        });
        break;
    }
  }

  // Metto in play l'audio in memoria
  void play(String type) {
    switch (type) {
      case "musica":
        if (musicFile != null) {
          currentMusicAudioPlayer.play(musicFile, isLocal: true);
          currentMusicAudioPlayer.setVolume(musicVolume / 10);
        }
        break;

      case "ambientale":
        if (ambienceFile != null) {
          currentAmbienceAudioPlayer.play(ambienceFile, isLocal: true);
          currentAmbienceAudioPlayer.setVolume(ambienceVolume / 10);
        }
        break;
    }
  }

  // Metto in pausa l'audio in memoria
  void pause(String type) {
    switch (type) {
      case "musica":
        if (musicFile != null) {
          currentMusicAudioPlayer.pause();
        }
        break;

      case "ambientale":
        if (ambienceFile != null) {
          currentAmbienceAudioPlayer.pause();
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

          currentMusicAudioPlayer.setVolume(musicVolume / 10);
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

          currentAmbienceAudioPlayer.setVolume(ambienceVolume / 10);
        });
        break;
    }
  }

  // Metto in play le musiche di una categoria in ordine casuale
  void random(String type, FilesProvider provider) {

    switch (type) {
      case "musica":
        String path = provider.firstDirNames[new Random().nextInt(provider.firstDirNames.length)].path;
        playSelected(type, path, true);
        currentMusicAudioPlayer.onPlayerCompletion.listen((event) {
          random(type, provider);
        });
        break;

      case "ambientale":
        String path = provider.secondDirNames[new Random().nextInt(provider.secondDirNames.length)].path;
        playSelected(type, path, true);
        currentAmbienceAudioPlayer.onPlayerCompletion.listen((event) {
          random(type, provider);
        });
        break;
    }

  }

  // Creo una riga di pulsanti per le musiche
  Row buildRow(BuildContext context, int index, FilesProvider provider) {
    List<Widget> sizedBoxes = [];

    // Aggiunge i pulsanti musica alla riga o pulsanti vuoti se servono
    for (int i = 0; i < colonnePerTipo; i++) {
      if (((index * colonnePerTipo) + i) < provider.firstDirNames.length) {
        sizedBoxes.add(
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.23,
            child: ElevatedButton(
              child: Text(basenameWithoutExtension(provider.firstDirNames[(index * colonnePerTipo) + i].path).capitalize()),
              style: ElevatedButton.styleFrom(elevation: 8.0, primary: Colors.lightGreen),
              onPressed: () {
                playSelected("musica", provider.firstDirNames[(index * colonnePerTipo) + i].path, false);
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
      if (((index * colonnePerTipo) + i) < provider.secondDirNames.length) {
        sizedBoxes.add(
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.23,
            child: ElevatedButton(
              child: Text(basenameWithoutExtension(provider.secondDirNames[(index * colonnePerTipo) + i].path).capitalize()),
              style: ElevatedButton.styleFrom(elevation: 8.0, primary: Colors.lightBlue),
              onPressed: () {
                playSelected("ambientale", provider.secondDirNames[(index * colonnePerTipo) + i].path, false);
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
