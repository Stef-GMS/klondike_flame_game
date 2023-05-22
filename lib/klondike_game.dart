import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';

import 'components/card.dart';
import 'components/foundation_pile.dart';
import 'components/tableau_pile.dart';
import 'components/stock_pile.dart';
import 'components/waste_pile.dart';

// In Flame universe, the FlameGame class is the cornerstone of most games. This class runs
// the game loop, dispatches events, owns all the components that comprise the game (the
// component tree), and usually also serves as the central repository for the game’s state.
class KlondikeGame extends FlameGame {
  static const double cardWidth = 1000.0;
  static const double cardHeight = 1400.0;
  static const double cardGap = 175.0;
  static const double cardRadius = 100.0;
  static final Vector2 cardSize = Vector2(cardWidth, cardHeight);

  static final cardRRect = RRect.fromRectAndRadius(
    const Rect.fromLTWH(0, 0, cardWidth, cardHeight),
    const Radius.circular(cardRadius),
  );

  @override
  Future<void> onLoad() async {
    // Loading the image into the global Flame.images cache here. An alternative approach is
    // to load it into the Game.images cache instead, but then it would have been more
    // difficult to access that image from other classes.
    //
    // Awaiting the image to finish loading before initializing anything else in the game. This
    // is for convenience: it means that by the time all other components are initialized,
    // they can assume the spritesheet is already loaded.
    await Flame.images.load('klondike_sprites.png');

    final stock = StockPile()
      ..size = cardSize
      ..position = Vector2(cardGap, cardGap);
    final waste = WastePile()
      ..size = cardSize
      ..position = Vector2(cardWidth + 2 * cardGap, cardGap);
    final foundations = List.generate(
      4,
      (i) => FoundationPile(
        i,
        position: Vector2((i + 3) * (cardWidth + cardGap) + cardGap, cardGap),
      ),
    );
    final piles = List.generate(
      7,
      (i) => TableauPile()
        ..size = cardSize
        ..position = Vector2(
          cardGap + i * (cardWidth + cardGap),
          cardHeight + 2 * cardGap,
        ),
    );

    final world = World()
      ..add(stock)
      ..add(waste)
      ..addAll(foundations)
      ..addAll(piles);
    add(world);

    final camera = CameraComponent(world: world)
      ..viewfinder.visibleGameSize =
          Vector2(cardWidth * 7 + cardGap * 8, 4 * cardHeight + 3 * cardGap)
      ..viewfinder.position = Vector2(cardWidth * 3.5 + cardGap * 4, 0)
      ..viewfinder.anchor = Anchor.topCenter;
    add(camera);

    // Create a full deck of 52 cards and put them onto the stock pile
    final cards = [
      for (var rank = 1; rank <= 13; rank++)
        for (var suit = 0; suit < 4; suit++) Card(rank, suit)
    ];
    cards.shuffle();
    world.addAll(cards);

    for (var i = 0; i < 7; i++) {
      for (var j = i; j < 7; j++) {
        piles[j].acquireCard(cards.removeLast());
      }
      piles[i].flipTopCard();
    }
    cards.forEach(stock.acquireCard);
  }
}

Sprite klondikeSprite(
  double x,
  double y,
  double width,
  double height,
) {
  return Sprite(
    Flame.images.fromCache('klondike_sprites.png'),
    srcPosition: Vector2(x, y),
    srcSize: Vector2(width, height),
  );
}
