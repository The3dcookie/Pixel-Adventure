import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:pixel_adventure/components/background_tile.dart';
import 'package:pixel_adventure/components/collission_block.dart';
import 'package:pixel_adventure/components/fruit.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/components/saw.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class Levels extends World with HasGameRef<PixelAdventure>{
  final String levelName;
  final Player player;
  Levels({required this.levelName, required this.player});
  late TiledComponent level;

  List<CollissionBlock> collissionBlocks = [];

  @override
  FutureOr<void> onLoad() async {
    //Loads the level using the background made in tiled
    level = await TiledComponent.load("$levelName.tmx", Vector2.all(16));

    add(level);

    _scrollingBackground();
    _spawningObjects();
    _addCollissions();

   

    //Sets the collission blocks from the level file in the collission block List on the player file
    player.collissionBlocks = collissionBlocks;

    return super.onLoad();
  }
  
  void _scrollingBackground() {
    final backgroundLayer = level.tileMap.getLayer("Background");

    const tileSize = 64;

    final numTilesY = (game.size.y / tileSize).floor();
    final numTilesX = (game.size.x / tileSize).floor();




    
    if (backgroundLayer != null) {
      final backgroundColor = backgroundLayer.properties.getValue("BackgroundColor");//Add the C to fix

    for (double y = 0; y < game.size.y / numTilesY; y++) {
      for (double x = 0; x < numTilesX; x++) {
              
        final backgroundTile = BackgroundTile(color: backgroundColor ?? "Gray", position: Vector2(x * tileSize, y * tileSize - tileSize) );
        add(backgroundTile);
        
      }

                

            
      
    }


      

    }
  }
  
  void _spawningObjects() {
     //Gets the spawn point from the spawn point layer you made in Tiled App
    final spawnPointLayer = level.tileMap.getLayer<ObjectGroup>("SpawnPoint");

    if (spawnPointLayer != null) {
      for (final spawnPoint in spawnPointLayer.objects) {
        switch (spawnPoint.class_) {
          case "Player":
            // final player = Player(character: "Ninja Frog", position: Vector2(spawnPoints.x, spawnPoints.y));

            // print("Spawned at X: ${spawnPoints.x} Y: ${spawnPoints.y}");

            // final player = Player(character: "Ninja Frog", position: Vector2(100.333, 200.333));

            player.position = Vector2(spawnPoint.x, spawnPoint.y);
            
            // player.character = "Virtual Guy";
            add(player);

            break;

            case "Fruit": 
            final fruit = Fruit(fruit: spawnPoint.name, position: Vector2(spawnPoint.x, spawnPoint.y), size: Vector2(spawnPoint.width, spawnPoint.height));
            // game.logger.d(spawnPoint.name);
            add(fruit);
            break;

            case "Saw":
            final isVertical = spawnPoint.properties.getValue("isVertical");
            final offNeg = spawnPoint.properties.getValue("offNeg");
            final offPos = spawnPoint.properties.getValue("offPos");
            final saw = Saw(
              isVertical: isVertical,
              offNeg: offNeg,
              offPos: offPos,
              position: Vector2(spawnPoint.x, spawnPoint.y), 
              size: Vector2(spawnPoint.width, spawnPoint.height),
               
              );
            add(saw);
            break;
          default:
        }
      }
      

      //Extra players Test positions
      // add(Player(character: "Virtual Guy", position: Vector2(46.00, 63.33)));
      // add(Player(character: "Pink Man", position: Vector2(100.333, 150.333)));
      // add(Player(character: "Mask Dude", position: Vector2(200.333, 170.333)));
    }
  }
  
  void _addCollissions() {
    
    //Gets the layers for the collision
    final collissionLayer = level.tileMap.getLayer<ObjectGroup>("Collisions");

    if (collissionLayer != null) {
      for (final collision in collissionLayer.objects) {
        switch (collision.class_) {
          //Checks for platform class tag
          case "Platform":
            final platform = CollissionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
              isPlatform: true,
            );

            collissionBlocks.add(platform);

            add(platform);
            break;
          default:
          //The remaining non platform blocks
            final block = CollissionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
            );
            collissionBlocks.add(block);
            add(block);

        }
      }
    }
  }
}
