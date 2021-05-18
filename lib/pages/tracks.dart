import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:music_player/pages/music_player.dart';

class Tracks extends StatefulWidget {
  @override
  _TracksState createState() => _TracksState();
}

class _TracksState extends State<Tracks> {
  final FlutterAudioQuery audioQuery = FlutterAudioQuery();
  List<SongInfo> songs = [];
  int currentIndex = 0;
  final GlobalKey<MusicPlayerState> key = GlobalKey<MusicPlayerState>();

  @override
  void initState() {
    super.initState();
    getTracks();
  }

  void getTracks() async {
    songs = await audioQuery.getSongs();
    setState(() {
      songs = songs;
    });
  }

  void changeTrack(bool isNext) {
    if (isNext) {
      if (currentIndex != songs.length - 1) currentIndex++;
    } else if (currentIndex != 0) currentIndex--;
    key.currentState.setSong(songs[currentIndex]);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo[50],
      appBar: _appBar(),
      body: Scrollbar(
        showTrackOnHover: true,
        hoverThickness: 10,
        child: ListView.separated(
          separatorBuilder: (context, index) => Divider(),
          itemCount: songs.length,
          itemBuilder: (context, index) => ListTile(
            leading: CircleAvatar(
                backgroundImage: songs[index].albumArtwork == null
                    ? AssetImage('assets/images/SHS.jpg')
                    : FileImage(File(songs[index].albumArtwork))),
            title: Text(
              songs[index].title,
              style: GoogleFonts.poppins(
                textStyle: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
            subtitle: Text(
              songs[index].artist,
              style: GoogleFonts.lato(
                textStyle: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
            onTap: () {
              currentIndex = index;
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => MusicPlayer(
                        songInfo: songs[currentIndex],
                        changeTrack: changeTrack,
                        key: key,
                      )));
            },
          ),
        ),
      ),
    );
  }

  AppBar _appBar() {
    return AppBar(
      backgroundColor: Colors.white,
      shadowColor: Colors.black,
      leading: new Tab(icon: Image.asset('assets/images/SHS.jpg')),
      title: Text(
        'SHS - A MP3 Player',
        style: GoogleFonts.play(
          textStyle: TextStyle(color: Colors.purple[700]),
        ),
      ),
    );
  }
}
