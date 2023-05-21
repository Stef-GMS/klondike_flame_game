import 'package:flame/sprite.dart';
import 'package:flutter/foundation.dart';
import 'klondike_game.dart';

@immutable
class Suit {
  // Use a factory constructor here in order to enforce the singleton pattern
  // for the class: instead of creating a new object every time, we are returning
  // one of the pre-built objects that we store in the _singletons list.
  factory Suit.fromInt(int index) {
    assert(index >= 0 && index <= 3);
    return _singletons[index];
  }

  // This constructor initializes the main properties of each Suit object: the
  // numeric value, the string label, and the sprite object which we will later
  // use to draw the suit symbol on the canvas. The sprite object is initialized
  // using the klondikeSprite() function in klondike_game.dart
  Suit._(
    this.value,
    this.label,
    double x,
    double y,
    double w,
    double h,
  ) : sprite = klondikeSprite(x, y, w, h);

  final int value;
  final String label;
  final Sprite sprite;

  // Sstatic list of all Suit objects in the game. Note that we define it as late,
  // meaning that it will be only initialized the first time it is needed. This is
  // important: as we seen above, the constructor tries to retrieve an image
  // from the global cache, so it can only be invoked after the image is loaded
  // into the cache.
  //
  // The last four numbers in the constructor are the coordinates of the sprite
  // image within the spritesheet klondike_sprites.png. If you’re wondering how to
  // obtain these numbers, use a free online service spritecow.com – it’s a handy
  // tool for locating sprites within a spritesheet.
  static late final List<Suit> _singletons = [
    Suit._(0, '♥', 1176, 17, 172, 183),
    Suit._(1, '♦', 973, 14, 177, 182),
    Suit._(2, '♣', 974, 226, 184, 172),
    Suit._(3, '♠', 1178, 220, 176, 182),
  ];

  // Getters to determine the “color” of a suit. This will be needed later when
  // we need to enforce the rule that cards can only be placed into columns
  // by alternating colors.
  /// Hearts and Diamonds are red, while Clubs and Spades are black.
  bool get isRed => value <= 1;
  bool get isBlack => value >= 2;
}
