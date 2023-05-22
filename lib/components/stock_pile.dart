import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:klondike_flame_game/components/waste_pile.dart';
import 'package:klondike_flame_game/pile.dart';

import '../klondike_game.dart';
import 'card.dart';

class StockPile extends PositionComponent with TapCallbacks implements Pile {
  StockPile({super.position}) : super(size: KlondikeGame.cardSize);

  /// Which cards are currently placed onto this pile. The first card in the
  /// list is at the bottom, the last card is on top.
  final List<Card> _cards = [];

  @override
  bool canMoveCard(Card card) => false;

  @override
  bool canAcceptCard(Card card) => false;

  @override
  void removeCard(Card card) =>
      throw StateError('cannot remove cards from here');

  @override
  void returnCard(Card card) =>
      throw StateError('cannot remove cards from here');

  // acquireCard() method stores the provided card into the internal list _cards;
  // it also moves that card to the StockPile’s position and adjusts the cards
  // priority so that they are displayed in the right order. However, this method
  // does not mount the card as a child of the StockPile component – it remains
  // belonging to the top-level game.
  void acquireCard(Card card) {
    assert(!card.isFaceUp);
    card.position = position;
    card.priority = _cards.length;
    _cards.add(card);
    card.pile = this;
  }

  // When a tap occurs the top 3 cards to be turned face up and moved to the waste pile
  @override
  void onTapUp(TapUpEvent event) {
    final wastePile = parent!.firstChild<WastePile>()!;

    // Move the cards back from the waste pile into the stock pile when the user taps on an empty stock.
    if (_cards.isEmpty) {
      //  Reverse the list of cards removed from the waste pile, then it is because we want
      //  to simulate the entire waste pile being turned over at once, and not each card being
      //  flipped one by one in their places.
      wastePile.removeAllCards().reversed.forEach((card) {
        card.flip();
        acquireCard(card);
      });
    } else {
      for (var i = 0; i < 3; i++) {
        if (_cards.isNotEmpty) {
          final card = _cards.removeLast();
          card.flip();
          wastePile.acquireCard(card);
        }
      }
    }
  }

  final _borderPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 10
    ..color = const Color(0xFF3F5B5D);
  final _circlePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 100
    ..color = const Color(0x883F5B5D);

  // empty stock pile will have a card-like border, and a circle in the middle:
  @override
  void render(Canvas canvas) {
    canvas.drawRRect(KlondikeGame.cardRRect, _borderPaint);
    canvas.drawCircle(
      Offset(width / 2, height / 2),
      KlondikeGame.cardWidth * 0.3,
      _circlePaint,
    );
  }
}
