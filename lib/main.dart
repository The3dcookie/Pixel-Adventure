import 'package:flame/flame.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  //Settings for setting the game to fullscreen
  await Flame.device.fullScreen();
  //Settings for setting the game to landscape
  await Flame.device.setLandscape();
  PixelAdventure game = PixelAdventure();
  runApp(GameWidget(game: kDebugMode ? PixelAdventure() : game));
  
  
  //Uncomment after game done
  // runApp(GameWidget(game: game));
}
