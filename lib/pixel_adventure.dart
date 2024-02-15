import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:pixel_adventure/actors/player.dart';
import 'package:pixel_adventure/levels/level.dart';
import 'package:logger/logger.dart';

class PixelAdventure extends FlameGame
    with HasKeyboardHandlerComponents, DragCallbacks {
  late final CameraComponent cam;

  //Reference to the player
  Player player = Player();

  late JoystickComponent joystick;
  bool showJoystick = true;

  @override
  FutureOr<void> onLoad() async {
    var logger = Logger();
    //Loading all images into cache here
    await images.loadAllImages();

    final zaWorld = Levels(levelName: "Level-02", player: player);

    //Camera that sees the worls here
    cam = CameraComponent.withFixedResolution(
        world: zaWorld, width: 640, height: 360);

    //Code for anchoring the cam to the left
    cam.viewfinder.anchor = Anchor.topLeft;


    addAll([cam, zaWorld]);

    // await Future.delayed(const Duration(seconds: 5));
    if (showJoystick) {

      addJoystick();
   
    }


    cam.canSee(joystick);

    // print("Can see: ${cam.canSee(joystick)}");
    logger.d("Can see: ${cam.canSee(joystick)}");


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
      priority: -1,
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
    );

    add(joystick);
  }

  @override
  void update(double dt) {
    if (showJoystick) {
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
        player.playerDirection = PlayerDirection.left;
        break;
      case JoystickDirection.right:
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
        player.playerDirection = PlayerDirection.right;
        break;
      default:
        player.playerDirection = PlayerDirection.none;
        break;
    }
  }
}
