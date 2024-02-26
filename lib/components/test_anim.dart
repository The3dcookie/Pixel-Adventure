import 'dart:async';

import 'package:flame/components.dart';

enum TestState{run, idle}

class Test extends SpriteAnimationGroupComponent with HasGameRef{

  Test({position, size}) : super(size: size, position: position);

  late final SpriteAnimation _runAnimation;

    static const stepTime = 0.05;
  final textureSize = Vector2(1250, 1500);
  

  @override
  FutureOr<void> onLoad() {
    debugMode = true;
    _loadAllAnimations();
    return super.onLoad();
  }

    void _loadAllAnimations() {
    // _idleAnimation = _spriteAnimation("Idle", 13);
    _runAnimation = _spriteAnimation("Running", 12);

    animations = {
        // TestState.idle: _idleAnimation,
        TestState.run: _runAnimation,
    };

    current = TestState.run;


  } 

    SpriteAnimation _spriteAnimation(String state, int amount){
    return SpriteAnimation.fromFrameData(
      game.images.fromCache("Enemies/Chicken/$state.png"), 
      SpriteAnimationData.sequenced(

        amount: amount, 
        stepTime: stepTime, 
        textureSize: textureSize,
        
        ));
  }
}