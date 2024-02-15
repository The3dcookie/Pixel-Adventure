import 'package:flame/components.dart';

class CollissionBlock extends PositionComponent{

  bool isPlatform;
  CollissionBlock({position, size, this.isPlatform = false}) : super(position: position, size: size){debugMode = true;}

}