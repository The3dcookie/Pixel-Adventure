import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:pixel_adventure/components/collission_block.dart';
import 'package:pixel_adventure/components/player_hitbox.dart';
import 'package:pixel_adventure/components/utils.dart';
import 'package:pixel_adventure/pixel_adventure.dart';
import 'package:logger/logger.dart';

enum PlayerState { idle, running, jumping, falling }

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
  bool hasJumped = false;
  final double _gravity = 9.8;
  // final double _jumpForce = 460;
  final double _jumpForce = 300;
  final double _terminalVelocity = 300;
  List<CollissionBlock> collissionBlocks = [];
  PlayerHitbox hitbox = PlayerHitbox(offsetX: 10, offsetY: 6, width: 14, height: 25,);

  // bool isFacingRight = true; //Not needed in refactor

  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  late final SpriteAnimation jumpingAnimation;
  late final SpriteAnimation fallingAnimation;
  final double stepTime = 0.05;

  @override
  //Basically the start function
  FutureOr<void> onLoad() {
    _loadAllAnimations();

    //Debug Box 
    // debugMode = true;

    add(
      RectangleHitbox(
        position: Vector2(hitbox.offsetX, hitbox.offsetY),
        size: Vector2(hitbox.width, hitbox.height),
      ));

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

    // CheckGrounded();

    super.update(dt);
  }

  void CheckGrounded() {
    // logger.d("Can see: ${cam.canSee(joystick)}");
    var log = Logger();

    log.d("Bool OnGround: $isOnGround");
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

    hasJumped = keysPressed.contains(LogicalKeyboardKey.keyW) ||
        keysPressed.contains(LogicalKeyboardKey.arrowUp) ||
        keysPressed.contains(LogicalKeyboardKey.space);

    return super.onKeyEvent(event, keysPressed);
  }

  void _updatePlayerState() {
    PlayerState playerState = PlayerState.idle;

    if (velocity.x < 0 && scale.x > 0) {
      flipHorizontallyAroundCenter();
    } else if (velocity.x > 0 && scale.x < 0) {
      flipHorizontallyAroundCenter();
    }


    //Check if moving set to running
    if (velocity.x > 0 || velocity.x < 0) {
      playerState = PlayerState.running;
    }

    //Check if falling set to falling
    if (velocity.y > 0) {
      playerState = PlayerState.falling;
    }

    //Check if jumping set to jumping
    if (velocity.y < 0) {
      playerState = PlayerState.jumping;
    }

    current = playerState;
  }

  // Update the player movement
  void _updatePlayerMovement(double dt) {
    if (hasJumped && isOnGround) {
      _playerJump(dt);
    }

    // if (velocity.y > _gravity) { isOnGround = false;} cant jump on air optional

    velocity.x = horizontalMovement * moveSpeed;
    position.x += velocity.x * dt;
  }

  void _playerJump(double dt) {
    velocity.y = -_jumpForce;
    position.y += velocity.y * dt;
    isOnGround = false;
    hasJumped = false;
  }

  void _checkHorizontalCollissions() {
    for (final block in collissionBlocks) {
      //Handle collission
      //If not a platform, check horizontal collissions
      if (!block.isPlatform) {
        if (checkCollission(this, block)) {
          if (velocity.x > 0) {
            velocity.x = 0;
            position.x = block.x - hitbox.offsetX - hitbox.width;
            break;
          }
          if (velocity.x < 0) {
            velocity.x = 0;
            position.x = block.x + block.width + hitbox.width + hitbox.offsetX;
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
        if (checkCollission(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offsetY;
            isOnGround = true;
            break;
          }
        }
      } else {
        if (checkCollission(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offsetY;
            isOnGround = true;
            break;
          }
          if (velocity.y < 0) {
            velocity.y = 0;
            position.y = block.y + block.height - hitbox.offsetY;
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

    jumpingAnimation = _spriteAnimation("Jump", 1);
    
    fallingAnimation = _spriteAnimation("Fall", 1);

    // List of all animations paired with the player enum state
    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runningAnimation,
      PlayerState.jumping: jumpingAnimation,
      PlayerState.falling: fallingAnimation,
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
