import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/services.dart';
import 'package:pixel_adventure/components/checkpoint.dart';
import 'package:pixel_adventure/components/chicken.dart';
import 'package:pixel_adventure/components/collission_block.dart';
import 'package:pixel_adventure/components/custom_hitbox.dart';
import 'package:pixel_adventure/components/fruit.dart';
import 'package:pixel_adventure/components/saw.dart';
import 'package:pixel_adventure/components/utils.dart';
import 'package:pixel_adventure/pixel_adventure.dart';
import 'package:logger/logger.dart';

enum PlayerState { idle, running, jumping, falling, hit, appearing, disappearing }

// enum PlayerDirection { left, right, none }

class Player extends SpriteAnimationGroupComponent with HasGameRef<PixelAdventure>, KeyboardHandler, CollisionCallbacks {
  String character;

  // Player({position, required this.character}) : super(position: position);

  //Code for not required character set as defauld ninja
  Player({position, this.character = "Ninja Frog"}) : super(position: position);

  // PlayerDirection playerDirection = PlayerDirection.none; //Not needed in refactor
  double horizontalMovement = 0;
  double moveSpeed = 100;
  Vector2 startingPosition = Vector2.zero();
  Vector2 velocity = Vector2.zero();
  bool isOnGround = false;
  bool hasJumped = false;
  bool gotHit = false;
  bool hasReachedCheckpoint = false;
  final double _gravity = 9.8;
  // final double _jumpForce = 460;
  final double _jumpForce = 300;
  final double _terminalVelocity = 300;
  List<CollissionBlock> collissionBlocks = [];
  CustomHitbox hitbox = CustomHitbox(offsetX: 10, offsetY: 6, width: 14, height: 25,);

  double fixedDeltaTime = 1/60;
  double accumulatedTime = 0;

  // bool isFacingRight = true; //Not needed in refactor

  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  late final SpriteAnimation jumpingAnimation;
  late final SpriteAnimation fallingAnimation;
  late final SpriteAnimation hitAnimation;
  late final SpriteAnimation appearingAnimation;
  late final SpriteAnimation disappearingAnimation;
  final double stepTime = 0.05;

  @override
  //Basically the start function
  FutureOr<void> onLoad() {
    _loadAllAnimations();

    startingPosition = Vector2(position.x, position.y);

    // game.logger.d("Starting Position = $startingPosition");

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
    accumulatedTime += dt;

    while (accumulatedTime > fixedDeltaTime) {
    
     if (!gotHit && !hasReachedCheckpoint) {
     _updatePlayerState();
     _updatePlayerMovement(fixedDeltaTime);
     _checkHorizontalCollissions();
     _applyGravity(fixedDeltaTime);
    _checkVerticalCollissions();
    
    }
    
    accumulatedTime -= fixedDeltaTime;
    
    }




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


 //Collider overlap detections once over here
  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
     if (!hasReachedCheckpoint) {
          //Log the fruit hit
       if (other is Fruit) {
         // game.logger.d("Hit a ${other.fruit}");
         other.collidedWithPlayer();
       }

       if (other is Saw) {
         // other.collidedWithPlayer();
         _respawn();
       }

       if (other is Checkpoint  && !hasReachedCheckpoint) {
       
         // hasReachedCheckpoint = other.hasReachedCheckpoint;
         _reachedCheckpoint();
       }

       if (other is Chicken) {
         other.collidedWithPlayer();
       }
    }
    super.onCollisionStart(intersectionPoints, other);
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
    if (game.playSounds) {
      FlameAudio.play("jump.wav", volume: game.soundVolume);
    }
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

    hitAnimation = _spriteAnimation("Hit", 7)..loop = false;

    appearingAnimation = _specialSpriteAnimation("Appearing", 7);

    disappearingAnimation = _specialSpriteAnimation("Desappearing", 7);

    // List of all animations paired with the player enum state
    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runningAnimation,
      PlayerState.jumping: jumpingAnimation,
      PlayerState.falling: fallingAnimation,
      PlayerState.hit: hitAnimation,
      PlayerState.appearing: appearingAnimation,
      PlayerState.disappearing: disappearingAnimation,
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
  
//Scalable function for animation
  SpriteAnimation _specialSpriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
        game.images.fromCache("Main Characters/$state (96x96).png"),
        SpriteAnimationData.sequenced(
            amount: amount, stepTime: stepTime, textureSize: Vector2.all(96), loop: false,));
  }

  void _respawn() async {

    if (game.playSounds) {
      FlameAudio.play("hit.wav", volume: game.soundVolume);
    }

    gotHit = true;

    current = PlayerState.hit;

    //Wait for animation to complete
    await animationTicker?.completed;

    //Reset animation ticker
    animationTicker?.reset();


      scale.x = 1; 
      position = startingPosition - Vector2.all(32); 
      current = PlayerState.appearing;

    await animationTicker?.completed;
    animationTicker?.reset();

    velocity = Vector2.zero(); 

    position = startingPosition; 

   _updatePlayerState(); 

    gotHit = false;
  }
  
  void _reachedCheckpoint() async {
    hasReachedCheckpoint = true;
       
     if (game.playSounds) {
      FlameAudio.play("disappear.wav", volume: game.soundVolume);
    }

    if (scale.x > 0) {
      position = position - Vector2.all(32);
    }
    else if (scale.x < 0) {
      position = position + Vector2(32, -32);
    }

    current = PlayerState.disappearing;

    await animationTicker?.completed;
    animationTicker?.reset();  

    hasReachedCheckpoint = false; position = Vector2.all(-640);


    const waitToChangeDuration = Duration(seconds: 3);
    Future.delayed(
      waitToChangeDuration, (){
        //switch level
        game.loadNextLevel();
        }); 
  }

  void colliderWithEnemy() {
    _respawn();
  }
}
