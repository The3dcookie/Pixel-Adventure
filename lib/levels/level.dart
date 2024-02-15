import 'dart:async';

import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:pixel_adventure/actors/player.dart';


class Levels extends World {
  final String levelName;
  final Player player;
  Levels({required this.levelName, required this.player});
  late TiledComponent level;

  @override
  FutureOr<void> onLoad() async {

    //Loads the level using the background made in tiled
    level = await TiledComponent.load("$levelName.tmx", Vector2.all(16));

    add(level);


    //Gets the spawn point from the spawn point layer you made in Tiled App
    final spawnPointLayer = level.tileMap.getLayer<ObjectGroup>("SpawnPoint");


    for (final spawnPoints in spawnPointLayer!.objects) {
      switch (spawnPoints.class_) {
        case "Player":
          // final player = Player(character: "Ninja Frog", position: Vector2(spawnPoints.x, spawnPoints.y));

          // print("Spawned at X: ${spawnPoints.x} Y: ${spawnPoints.y}");

          // final player = Player(character: "Ninja Frog", position: Vector2(100.333, 200.333));
          player.position =  Vector2(spawnPoints.x, spawnPoints.y);
          // player.character = "Virtual Guy";
          add(player);

          break;
        default:
      }
    }

    add(Player(character: "Virtual Guy", position: Vector2(46.00, 63.33)));
    add(Player(character: "Pink Man", position: Vector2(100.333, 150.333)));
    add(Player(character: "Mask Dude", position: Vector2(200.333, 170.333)));

    return super.onLoad();
  }
}
