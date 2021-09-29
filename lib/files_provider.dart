import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_manager/flutter_file_manager.dart';
import 'package:path_provider_ex/path_provider_ex.dart';
import 'package:permission_handler/permission_handler.dart';

import 'globals.dart';

class FilesProvider with ChangeNotifier {

  Globals _globals = Globals();

  // Recupero le liste di file
  void getFilesList1() {

    // Recupero i file dalla cartella 'music'
    getFiles1("music").then((musicFiles) {

      // Recupero i file dalla cartella 'ambience'
      getFiles1("ambience").then((ambienceFiles) {
        // setState(() {
          _globals.musicNames = musicFiles;
          _globals.ambienceNames = ambienceFiles;
        // });
        print('GetFilesList music: ' + _globals.musicNames.toString());
        print('GetFilesList ambience: ' + _globals.ambienceNames.toString());
      });
    });

  }

  // Restituisce l'elenco dei file audio nella sotto cartella specificata
  // TODO: gestire da settings se usare storage locale o sd
  // TODO: gestire da settings il path da usare
  Future<List<File>> getFiles1(String type) async {

    List<File> files;

    if (await Permission.storage.request().isGranted) {
      List<StorageInfo> storageInfo = await PathProviderEx.getStorageInfo();
      var root;
      var fm;
      if (_globals.useExternalMemory) {
        root = storageInfo[1].rootDir; //storageInfo[1] for SD card, getting the root directory
        fm = FileManager(root: Directory(root + "/GDR/Musiche/" + type)); //
      } else {
        root = storageInfo[0].rootDir; //storageInfo[1] for SD card, getting the root directory
        fm = FileManager(root: Directory(root + "/Download/D&D/Musiche/" + type)); //
      }


      files = await fm.filesTree(
        //set fm.dirsTree() for directory/folder tree list
          excludedPaths: ["/storage/emulated/0/Android"],
          extensions: ["mp4", "m4a"] //optional, to filter files, remove to list all,
        //remove this if your are grabbing folder list
      );
    }
    return files;
  }

}