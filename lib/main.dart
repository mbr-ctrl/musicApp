import 'dart:async';
// ignore: invalid_language_version_override
// @dart=2.9

import 'package:flutter/material.dart';
import 'music.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:audioplayer/audioplayer.dart';



void main() {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(

        primarySwatch: Colors.green,
      ),
      home: const MyHomePage(title: 'MB Music'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);


  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Music> maListeDeMusic = [
    Music('janet', 'lefa', 'assets/un.jpg', 'https://drive.google.com/file/d/1I_nGBxfUOBRgVrxSfhO9GyaAxMKRei_s/view?usp=sharing'),
    Music('ecole de la vie', 'Grand corps malade', 'assets/deux.jpg', 'https://drive.google.com/file/d/1AM-4iSTyZ-etww5BPmz0J3fo2mUBCrmm/view?usp=sharing')
  ];

  late Music maMusicActuelle;
  Duration position = const Duration(seconds: 0);
  late AudioPlayer audioPlayer;
  late StreamSubscription positionSub;
  late StreamSubscription stateSubscription;
  late Duration duree = const Duration(seconds: 10);
  PlayerState statut = PlayerState.stopped;
  int index = 0;

  @override
  void initState() {
    super.initState();
    maMusicActuelle = maListeDeMusic[0];
    configurationAudioPlayer();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        title: Text(widget.title),
        centerTitle: true,
        backgroundColor: Colors.grey[900],
      ),

      backgroundColor: Colors.grey[800],
      body: Center(

        child: Column(

          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Card(
              elevation: 9.0,
              child: Container(
                width: MediaQuery.of(context).size.height/2.5,
                child: Image.asset(maMusicActuelle.imagePath),
              ),
            ),
            textAvecStyle(maMusicActuelle.titre, 2.5),
            textAvecStyle(maMusicActuelle.artiste, 1.5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                button(Icons.fast_rewind, 30.0, ActionMusic.rewind),
                button((statut == PlayerState.playing) ? Icons.pause: Icons.play_arrow, 30.0, (statut == PlayerState.playing) ? ActionMusic.pause: ActionMusic.play),
                button(Icons.fast_forward, 30.0, ActionMusic.forward)
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                textAvecStyle(fromDuration(position), 0.8),
                textAvecStyle(fromDuration(duree), 0.8)
              ],
            ),
            Slider(
                value: position.inSeconds.toDouble(),
                min: 0.0,
                max: 30.0,
                inactiveColor: Colors.white,
                activeColor: Colors.red,
                onChanged: (double d){
                  setState(() {
                    Duration nouvellePosition = Duration(seconds: d.toInt());
                    position = nouvellePosition;
                  });
                }
            )
          ],
        ),
      ),

    );
  }

  IconButton button(IconData icone, double taille, ActionMusic action){
    return IconButton(
      iconSize: taille,
      color: Colors.white,
      icon: Icon(icone),
      onPressed: (){
        switch (action){
          case ActionMusic.play:
            play();
            break;
            
          case ActionMusic.pause:
            pause();
            break;
            break;
          case ActionMusic.rewind:
            rewind();
            break;
          case ActionMusic.forward:
            forward();
            break;
        }
      },
    );
  }
  Text textAvecStyle(String data, double scale){
    return Text(
      data,
      textScaleFactor: scale,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20.0,
        fontStyle: FontStyle.italic
      ),
    );
  }

  void configurationAudioPlayer(){
    audioPlayer = AudioPlayer();
    positionSub = audioPlayer.onAudioPositionChanged.listen(
        (pos) => setState(() => position = pos)
    );
    stateSubscription = audioPlayer.onPlayerStateChanged.listen((state) {
      if(state == AudioPlayerState.PLAYING){
        setState(() {
          duree = audioPlayer.duration;
        });
      } else if(state == AudioPlayerState.STOPPED) {
        setState((){
          statut = PlayerState.stopped;
        });
      }
    }, onError: (message){
      print('error: $message');
      setState(() {
        statut = PlayerState.stopped;
        duree = const Duration(seconds: 0);
        position = const Duration(seconds: 0);
      });
    });
  }

  Future play() async {
    await audioPlayer.play(maMusicActuelle.urlSong);
    setState(() {
      statut = PlayerState.playing;
    });
  }
  Future pause() async {
    await audioPlayer.pause();
    setState(() {
      statut = PlayerState.paused;
    });
  }

  void forward(){
    if (index == maListeDeMusic.length - 1){
      index = 0;
    } else{
      index++;
    }
    maMusicActuelle = maListeDeMusic[index];
    audioPlayer.stop();
    configurationAudioPlayer();
    play();
  }

  String fromDuration(Duration duree){
    print(duree);
    return duree.toString().split('.').first;
  }

  void rewind(){
    if (position > Duration(seconds: 3)){
      audioPlayer.seek(0.0);
    } else {
      if(index == 0){
        index = maListeDeMusic.length - 1;
      } else {
        index--;
      }
      maMusicActuelle = maListeDeMusic[index];
      audioPlayer.stop();
      configurationAudioPlayer();
      play();
    }
  }
}

enum ActionMusic {
  play,
  pause,
  rewind,
  forward
}

enum PlayerState {
  playing,
  stopped,
  paused
}
