import 'dart:io';
//import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

//Color primaryCol = Color(0xff8A050E);//maroon
Color primaryCol = Color(0xff1ED760); //green

// ignore: must_be_immutable
class MusicPlayer extends StatefulWidget {
//list of songs below
  SongInfo songInfo;
  Function changeTrack;
  final GlobalKey<MusicPlayerState> key;
  MusicPlayer({this.songInfo, this.changeTrack, this.key})
      : super(key: key); //like a constructor accepting value through param
  int selectedIndex = 1; //The selected song
  @override
  MusicPlayerState createState() => MusicPlayerState();
}

class MusicPlayerState extends State<MusicPlayer> {
  double minD = 0.0, maxD = 0.0, currentD = 0.0;
  String currentTime = '', endTime = '';
  bool isPlaying = false, shuffle = false, loop1 = false;

  final AudioPlayer player = AudioPlayer();
  @override
  void initState() {
    super.initState();
    setSong(widget.songInfo);
  }

  void dispose() {
    super.dispose();
    player?.dispose();
  }

  void setSong(SongInfo songInfo) async {
    //initialising audio player to play current song
    widget.songInfo = songInfo;
    await player.setUrl(widget.songInfo.uri);
    currentD = minD;
    maxD = player.duration.inMilliseconds.toDouble();
    setState(() {
      currentTime = getDuration(currentD);
      endTime = getDuration(maxD);
    });
    isPlaying = false;
    changeState();
    player.positionStream.listen((duration) {
      currentD = duration.inMilliseconds.toDouble();
      setState(() {
        currentTime = getDuration(currentD);
        if (currentD >= maxD) widget.changeTrack(true);
      });
    });
  }

  void changeState() {
    setState(() {
      isPlaying = !isPlaying;
    });
    if (isPlaying)
      player.play();
    else
      player.pause();
  }

  void changeShuffleStatus() {
    setState(() {
      shuffle = !shuffle;
    });
    if (shuffle)
      player.setShuffleModeEnabled(true);
    else
      player.setShuffleModeEnabled(false);
  }

  void changeLoopStatus() {
    setState(() {
      loop1 = !loop1;
      if (loop1)
        player.setLoopMode(LoopMode.one);
      else
        player.setLoopMode(LoopMode.off);
    });
    
  }

  String getDuration(double value) {
    Duration duration = Duration(milliseconds: value.round());

    return [duration.inMinutes, duration.inSeconds]
        .map((element) => element.remainder(60).toString().padLeft(2, '0'))
        .join(':');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.indigo[50],
      appBar: _homeAppBar(),
      body: _homeBody(),
      bottomNavigationBar: _homeBottomMenu(),
    );
  }

  SizedBox _homeBottomMenu() {
    return SizedBox(
      height: 120,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
                child: new Tab(icon:shuffle 
                ?Image.asset('assets/images/shuffle_on.png') 
                :Image.asset('assets/images/shuffle.png'),
                ),
                onTap: () {
                  changeShuffleStatus();
                }),
            Row(
              children: [
                GestureDetector(
                  child: Icon(Icons.skip_previous,color: primaryCol,),
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    widget.changeTrack(false);
                  },
                ),
                SizedBox(
                  width: 20,
                ),
                Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black26,
                              offset: Offset(0, 10),
                              blurRadius: 15)
                        ]),
                    child: GestureDetector(
                      child: Icon(
                        isPlaying
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_filled,
                        size: 60,
                      ),
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        changeState();
                      },
                    )),
                SizedBox(
                  width: 20,
                ),
                GestureDetector(
                  child: Icon(Icons.skip_next,color: primaryCol,),
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    widget.changeTrack(true);
                  },
                )
              ],
            ),
            InkWell(
                child: Icon(loop1 ? Icons.repeat_one : Icons.repeat,size: 50,),
                onTap: () {
                  changeLoopStatus();
                }),
          ],
        ),
      ),
    );
  }

  SizedBox _homeBody() {
    return SizedBox(
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 275,
                height: 510,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 250,
                      child: Text(
                        "${widget.songInfo.title}", //song title
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      "${widget.songInfo.artist}", //artists
                      style: GoogleFonts.lato(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w400),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                  ],
                ),
                decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                          spreadRadius: 0,
                          color: Colors.black54,
                          offset: Offset(0, 20),
                          blurRadius: 30),
                    ],
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(200),
                        bottomRight: Radius.circular(200)),
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        colorFilter:
                            ColorFilter.mode(primaryCol, BlendMode.multiply),
                        image: widget.songInfo.albumArtwork == null
                            ? AssetImage('assets/images/SHS.jpg')
                            : FileImage(
                                File(widget.songInfo.albumArtwork) //Album ART
                                ))),
              ),
              Positioned(
                bottom: -65,
                left: -40,
                child: SleekCircularSlider(
                  min: minD, // song start time
                  max: maxD, // song end time (duration)
                  initialValue: currentD, //default value
                  onChange: (value) {
                    currentD = value;
                    
                    player.seek(Duration(milliseconds: currentD.round()));
                  },
                  appearance: CircularSliderAppearance(
                      size: 360,
                      counterClockwise: true,
                      startAngle: 150,
                      angleRange: 120,
                      customWidths: CustomSliderWidths(
                          trackWidth: 3,progressBarWidth: 15, shadowWidth: 1),
                      customColors: CustomSliderColors(
                        trackColor: Colors.green,
                        progressBarColor: Colors.black,
                      ),
                      infoProperties: InfoProperties(
                        mainLabelStyle: TextStyle(
                          color: Colors.transparent,
                        ),
                      )),
                ),
              )
            ],
          ),
          SizedBox(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                currentTime, // CURRENT POSITION Time
                style: GoogleFonts.lato(),
              ),
            ),
            height: 50,
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 30,
              left: 60,
              right: 60,
              bottom: 10,
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              SizedBox(
                child: Text(
                  endTime, // End time
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                      textStyle: TextStyle(
                    color: Colors.black45,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                  )),
                ),
              ),
            ]),
          )
        ],
      ),
    );
  }

  AppBar _homeAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      title: Text(
        'Now Playing',
        style: GoogleFonts.lato(
          textStyle: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.chevron_left,
          color: Colors.black,
          size: 35,
        ),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      // actions: [
      //   Transform.rotate(
      //     angle: (270 / (180 / pi)),
      //     child: IconButton(
      //         icon: Icon(
      //           Icons.bar_chart,
      //           color: Colors.black,
      //           size: 35,
      //         ),
      //         onPressed: () {}),
      //   )
      // ],
    );
  }
}
