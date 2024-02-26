import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:pixel_adventure/components/jump_button.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/components/level.dart';
import 'package:logger/logger.dart';

class PixelAdventure extends FlameGame 
         with 
         
         HasKeyboardHandlerComponents, 
         DragCallbacks, 
         HasCollisionDetection, 
         TapCallbacks 
         
  {
  late CameraComponent cam;
  final Logger logger = Logger();

  //Reference to the player
  Player player = Player();

  late JoystickComponent joystick = JoystickComponent(
      // size: 32,
      priority: 20,
      knob: SpriteComponent(
        size: Vector2.all(50),
        sprite: Sprite(
          images.fromCache("HUD/Knob.png"),
        ),
      ),
      background: SpriteComponent(
        size: Vector2.all(70),
        sprite: Sprite(
          images.fromCache("HUD/Joystick.png"),
        ),
      ),
      margin: const EdgeInsets.only(left: 5, bottom: 20),
      // anchor: Anchor.center
    ).. priority = 10;

    late SpriteComponent button = JumpButton();

  bool showControls = true;

  bool playSounds = true;

  double soundVolume = 1.0;
    
  List<String> levelNames = ["Level-01", "Level-02", "Level-03"];
  
  int currentLevelIndex = 0;

  @override
  FutureOr<void> onLoad() async {
    // priority = -2;

    // debugMode = true;

    //Loading all images into cache here
    await images.loadAllImages();

    _loadLevel();


    
    return super.onLoad();
  }

  //Sets the background color to match
  @override
  Color backgroundColor() => const Color(0xFF211F30);

  //Black background Test
  // Color backgroundColor() => const Color.fromARGB(255, 0, 0, 0);

  void addJoystick() {
    joystick = JoystickComponent(
      // size: 32,
      
      priority: 10,
      knob: SpriteComponent(
        size: Vector2.all(50),
        sprite: Sprite(
          images.fromCache("HUD/Knob.png"),
        ),
      ),
      background: SpriteComponent(
        size: Vector2.all(70),
        sprite: Sprite(
          images.fromCache("HUD/Joystick.png"),
        ),
      ),
      margin: const EdgeInsets.only(left: 32, bottom: 32),
      // anchor: Anchor.center
    ).. priority = 10;

          cam.viewport.add(joystick);

  }

  @override
  void update(double dt) {
    if (showControls) {
      updateJoystick();
    }
    super.update(dt);
  }

  //Updates the player direction based on the joystick position
  void updateJoystick() {
    switch (joystick.direction) {
      case JoystickDirection.left:
      case JoystickDirection.upLeft:
      case JoystickDirection.downLeft:
        player.horizontalMovement = -1;
        break;
      case JoystickDirection.right:
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
        player.horizontalMovement = 1;
        break;

      // case JoystickDirection.up:
      // player.hasJumped = true;
      default:
        player.horizontalMovement = 0;
        break;
    }
  }
  
  void loadNextLevel(){
    //Deleted the level
    removeWhere((component) => component is Levels);

    if (currentLevelIndex < levelNames.length - 1) {
      currentLevelIndex++;
      _loadLevel();
    }
    else{
      //No more Levels
      currentLevelIndex = 0;
      _loadLevel();
    }
  }

  void _loadLevel() {
    //A second of delay so that the previous level deletes properly
    Future.delayed(const Duration(seconds: 1), () {

    Levels zaWorld = Levels(levelName: levelNames[currentLevelIndex], player: player);

    //Camera that sees the worls here
    cam = CameraComponent.withFixedResolution(world: zaWorld, width: 640, height: 360);

    //Code for anchoring the cam to the left
    cam.viewfinder.anchor = Anchor.topLeft;

    addAll([cam, zaWorld, ]);

          if (showControls) {
      // addJoystick();
      cam.viewport.add(joystick);
      cam.viewport.add(button..priority = 10);


      // logger.d("Can see: ${cam.canSee(joystick)}");
      logger.d("Logger Works");
    }




    });


  }
}
