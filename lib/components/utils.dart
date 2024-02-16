bool checkCollission(player, block){
  final hitbox = player.hitbox;
  final playerX = player.position.x + hitbox.offsetX;
  final playerY = player.position.y + hitbox.offsetY;
  final playerWidth = hitbox.width;
  final playerHeight = hitbox.height;

  final blockX = block.x;
  final blockY = block.y;
  final blockWidth = block.width;
  final blockHeigth = block.height;

  final fixedX = player.scale.x < 0 ? playerX - (hitbox.offsetX * 2) - playerWidth : playerX;
  final fixedY = block.isPlatform ? playerY + playerHeight : playerY; 

  return ( 
    //If the very top of our player(playerY) is less than the bottom of a block (blockY(Block Tip Top) + block height)
    //Meaning it's inside it by being less than the block tip top + Block Height
    fixedY < blockY + blockHeigth && 
    //If the Player tip plus height is greater than the TOP of the block, meaning it's further down, i.e it's inside the block
    playerY + playerHeight > blockY &&
    //If the player's x is less than the block x + block height i.e now the RIGHT of the block. 
    //If the player x is less, it is inside the block
    fixedX < blockX + blockWidth &&
    //If the player x + width i.e now the Right of the player, is greater than the LEFT of the block, it is inside the block
    fixedX + playerWidth > blockX
    );

}