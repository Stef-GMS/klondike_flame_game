import 'dart:ui';

import 'package:flame/components.dart';
import 'package:klondike_flame_game/pile.dart';

import '../klondike_game.dart';
import '../suit.dart';
import 'card.dart';

// The foundation piles are the four piles in the top right corner of
// the game. This is where we will be building the ordered runs of
// cards from Ace to King.
class FoundationPile extends PositionComponent implements Pile {
  // Make a large icon of that foundation’s suit, in grey color
  FoundationPile(int intSuit, {super.position})
      : suit = Suit.fromInt(intSuit),
        super(size: KlondikeGame.cardSize);

  final Suit suit;

  final List<Card> _cards = [];

  @override
  bool canMoveCard(Card card) => _cards.isNotEmpty && card == _cards.last;

  void acquireCard(Card card) {
    assert(card.isFaceUp);
    card.position = position;
    card.priority = _cards.length;
    _cards.add(card);
    card.pile = this;
  }

  @override
  void removeCard(Card card) {
    assert(canMoveCard(card));
    _cards.removeLast();
  }

  @override
  void returnCard(Card card) {
    card.position = position;
    card.priority = _cards.indexOf(card);
  }

  @override
  bool canAcceptCard(Card card) {
    final topCardRank = _cards.isEmpty ? 0 : _cards.last.rank.value;
    return card.suit == suit &&
        card.rank.value == topCardRank + 1 &&
        card.attachedCards.isEmpty;
  }

  final _borderPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 10
    ..color = const Color(0x50ffffff);
  late final _suitPaint = Paint()
    ..color = suit.isRed ? const Color(0x3a000000) : const Color(0x64000000)
    ..blendMode = BlendMode.luminosity;

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(KlondikeGame.cardRRect, _borderPaint);
    suit.sprite.render(
      canvas,
      position: size / 2,
      anchor: Anchor.center,
      size: Vector2.all(KlondikeGame.cardWidth * 0.6),
      overridePaint: _suitPaint,
    );
  }
}
