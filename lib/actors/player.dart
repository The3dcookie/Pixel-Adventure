import 'dart:async';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

enum PlayerState { idle, running }

enum PlayerDirection { left, right, none }

class Player extends SpriteAnimationGroupComponent with HasGameRef<PixelAdventure>, KeyboardHandler {
  String character;

  // Player({position, required this.character}) : super(position: position);

  //Code for not required character set as defauld ninja
  Player({position, this.character = "Ninja Frog"}) : super(position: position);

  PlayerDirection playerDirection = PlayerDirection.none;
  double moveSpeed = 100;
  Vector2 velocity = Vector2.zero();
  bool isFacingRight = true;

  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  final double stepTime = 0.05;

  @override
  //Basically the start function
  FutureOr<void> onLoad() {
    _loadAllAnimations();

    return super.onLoad();
  }

  @override
  //Called every frame
  void update(double dt) {
    _updatePlayerMovement(dt);

    super.update(dt);
  }


  //How to do Keyboard controls 
  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    final isLeftKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    final isRightKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight);

    if (isLeftKeyPressed && isRightKeyPressed) {
      playerDirection = PlayerDirection.none;
    } else if (isLeftKeyPressed) {
      playerDirection = PlayerDirection.left;
    } else if (isRightKeyPressed) {
      playerDirection = PlayerDirection.right;
    } else {
      playerDirection = PlayerDirection.none;
    }

    return super.onKeyEvent(event, keysPressed);
  }

  // Update the player movement
  void _updatePlayerMovement(double dt) {
    double dirX = 0.0;
    switch (playerDirection) {
      case PlayerDirection.left:
      //checks the sprite facing direction
        if (isFacingRight) {
          flipHorizontallyAroundCenter();
          isFacingRight = false;
        }
        //Sets the player state
        current = PlayerState.running;
        //Moves Player Left
        dirX -= moveSpeed;

        break;
      case PlayerDirection.right:
        if (!isFacingRight) {
          flipHorizontallyAroundCenter();
          isFacingRight = true;
        }
        current = PlayerState.running;
        dirX += moveSpeed;
        break;
      case PlayerDirection.none:
        current = PlayerState.idle;
        break;
      default:
    }

    velocity = Vector2(dirX, 0.0);
    position += velocity * dt;
  }

  //Loading and setting the animations using the scalable function
  void _loadAllAnimations() {
    idleAnimation = _spriteAnimation("Idle", 11);

    runningAnimation = _spriteAnimation("Run", 11);

    // List of all animations paired with the player enum state
    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runningAnimation
    };

    //Set current animation
    current = PlayerState.running;
  }

//Scalable function for animation
  SpriteAnimation _spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
        game.images.fromCache("Main Characters/$character/$state (32x32).png"),
        SpriteAnimationData.sequenced(
            amount: amount, stepTime: stepTime, textureSize: Vector2.all(32)));
  }
}
