import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class JumpButton extends SpriteComponent with HasGameRef<PixelAdventure>, TapCallbacks{
  JumpButton();
  final margin = 32;
  final buttonSize = 64;


  @override
  FutureOr<void> onLoad() {
    // debugMode = true;
    sprite = Sprite(game.images.fromCache("HUD/JumpButton.png"));
    size = Vector2.all(70);
    position = Vector2(560, 270);
    // position = Vector2(
    //   game.size.x - margin - buttonSize, 
    //   game.size.y -margin -buttonSize,
    // );


    priority = 10;

    if (sprite != null) {
    game.logger.d("Button Active");
      
    } else {
    game.logger.d("Button Inactive");
      
    }



    return super.onLoad();
  }

@override
  void onTapDown(TapDownEvent event) {
    game.player.hasJumped = true;
    super.onTapDown(event);
  }

@override
  void onTapUp(TapUpEvent event) {
    game.player.hasJumped = false;
    super.onTapUp(event);
  }

}