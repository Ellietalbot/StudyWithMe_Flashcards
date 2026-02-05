import 'flashcard.dart';

class Deck{

  final List<Flashcard> cards = [];

  void addCard(Flashcard card){
    cards.add(card);
  }
  
}