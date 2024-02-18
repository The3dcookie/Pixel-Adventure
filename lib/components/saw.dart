import 'dart:async';

import 'package:flame/components.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class Saw extends SpriteAnimationComponent with HasGameRef<PixelAdventure>{
  final bool isVertical;
  final double offNeg;
  final double offPos;
  Saw({this.isVertical = false,this.offNeg = 0, this.offPos = 0,position, size}) : super(position: position, size: size);

  static const double sawSpeed = 0.03;

  @override
  FutureOr<void> onLoad() {
    priority = -1;
    animation = SpriteAnimation.fromFrameData(game.images.fromCache("Traps/Saw/On (38x38).png"), SpriteAnimationData.sequenced(amount: 8, stepTime: sawSpeed, textureSize: Vector2.all(38)));
    return super.onLoad();
  }
}