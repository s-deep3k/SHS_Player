import 'package:flutter/material.dart';
import 'package:music_player/pages/tracks.dart';


void main() {
  runApp(MaterialApp(
    title: "SHS Player",
    debugShowCheckedModeBanner: false,
    initialRoute: '/home',
    routes: {
      '/home': (context)=> Tracks(),
    },
  ));
}