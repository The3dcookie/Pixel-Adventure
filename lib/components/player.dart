import 'dart:async';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:pixel_adventure/components/collission_block.dart';
import 'package:pixel_adventure/components/utils.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

enum PlayerState { idle, running }

// enum PlayerDirection { left, right, none }

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure>, KeyboardHandler {
  String character;

  // Player({position, required this.character}) : super(position: position);

  //Code for not required character set as defauld ninja
  Player({position, this.character = "Ninja Frog"}) : super(position: position);

  // PlayerDirection playerDirection = PlayerDirection.none; //Not needed in refactor
  double horizontalMovement = 0;
  double moveSpeed = 100;
  Vector2 velocity = Vector2.zero();
  bool isOnGround = false;
  final double _gravity = 9.8;
  final double _jumpForce = 460;
  final double _terminalVelocity = 300;
  List<CollissionBlock> collissionBlocks = [];

  // bool isFacingRight = true; //Not needed in refactor

  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  final double stepTime = 0.05;

  @override
  //Basically the start function
  FutureOr<void> onLoad() {
    _loadAllAnimations();

    debugMode = true;

    return super.onLoad();
  }

  @override
  //Called every frame basically update function
  void update(double dt) {
    _updatePlayerState();
    _updatePlayerMovement(dt);
    _checkHorizontalCollissions();
    _applyGravity(dt);
    _checkVerticalCollissions();

    super.update(dt);
  }

  //How to do Keyboard controls
  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalMovement = 0;

    final isLeftKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    final isRightKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight);

    horizontalMovement += isLeftKeyPressed ? -1 : 0;
    horizontalMovement += isRightKeyPressed ? 1 : 0;

    // if (isLeftKeyPressed && isRightKeyPressed) {
    //   playerDirection = PlayerDirection.none;
    // } else if (isLeftKeyPressed) {
    //   playerDirection = PlayerDirection.left;
    // } else if (isRightKeyPressed) {
    //   playerDirection = PlayerDirection.right;
    // } else {
    //   playerDirection = PlayerDirection.none;
    // }

    return super.onKeyEvent(event, keysPressed);
  }

  void _updatePlayerState() {
    PlayerState playerState = PlayerState.idle;

    if (velocity.x < 0 && scale.x > 0) {
      flipHorizontallyAroundCenter();
    } else if (velocity.x > 0 && scale.x < 0) {
      flipHorizontallyAroundCenter();
    }

    if (velocity.x > 0 || velocity.x < 0) playerState = PlayerState.running;

    current = playerState;
  }

  // Update the player movement
  void _updatePlayerMovement(double dt) {
    // double dirX = 0.0;
    // switch (playerDirection) {
    //   case PlayerDirection.left:
    //   //checks the sprite facing direction
    //     if (isFacingRight) {
    //       flipHorizontallyAroundCenter();
    //       isFacingRight = false;
    //     }
    //     //Sets the player state
    //     current = PlayerState.running;
    //     //Moves Player Left
    //     dirX -= moveSpeed;

    //     break;
    //   case PlayerDirection.right:
    //     if (!isFacingRight) {
    //       flipHorizontallyAroundCenter();
    //       isFacingRight = true;
    //     }
    //     current = PlayerState.running;
    //     dirX += moveSpeed;
    //     break;
    //   case PlayerDirection.none:
    //     current = PlayerState.idle;
    //     break;
    //   default:
    // }

    // velocity = Vector2(dirX, 0.0);
    // position += velocity * dt;

    velocity.x = horizontalMovement * moveSpeed;
    position.x += velocity.x * dt;
  }

  void _checkHorizontalCollissions() {
    for (final block in collissionBlocks) {
      //Handle collission
      //If not a platform, check horizontal collissions
      if (!block.isPlatform) {
        if (checkCollission(this, block)) {
          if (velocity.x > 0) {
            velocity.x = 0;
            position.x = block.x - width;
            break;
          }
          if (velocity.x < 0) {
            velocity.x = 0;
            position.x = block.x + block.width + width;
            break;
          }
        }
      }
    }
  }

  void _applyGravity(double dt) {
    velocity.y += _gravity;
    velocity.y = velocity.y.clamp(-_jumpForce, _terminalVelocity);
    position.y += velocity.y * dt;
  }

  void _checkVerticalCollissions() {
    for (final block in collissionBlocks) {
      if (block.isPlatform) {
        //Handle platform collission
      } else {
        if (checkCollission(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - width;
            isOnGround = true;
            break;
          }
          if (velocity.y < 0) {
            velocity.y = 0;
            position.y = block.y + block.height;
            isOnGround = true;
            break;
          }
        }
      }
    }
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
