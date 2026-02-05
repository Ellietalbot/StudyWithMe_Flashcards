import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';  
import 'flashcard.dart';
import 'deck.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flashcard App',
      home: const FlashcardHomePage(),
    );
  }
}

class FlashcardHomePage extends StatefulWidget {
  const FlashcardHomePage({super.key});

  @override
  State<FlashcardHomePage> createState() => _FlashcardHomePageState();
}

class _FlashcardHomePageState extends State<FlashcardHomePage>{
  final Deck deck = Deck();
  int currentIndex = 0;
  bool showAnswer = false;
  bool showAddCardBox = true;
  final TextEditingController questionController = TextEditingController();
  final TextEditingController answerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCards();
  }


  Future<void> _saveCards() async {
    final prefs = await SharedPreferences.getInstance();
    
    List<Map<String, String>> cardsJson = deck.cards.map((card) {
      return {
        'question': card.question,
        'answer': card.answer,
      };
    }).toList();
    String cardsString = jsonEncode(cardsJson);
    await prefs.setString('flashcards', cardsString);
    
    print('Cards saved! Total: ${deck.cards.length}');
  }


  Future<void> _loadCards() async {
    final prefs = await SharedPreferences.getInstance();
    String? cardsString = prefs.getString('flashcards');
    
    if (cardsString != null) {
      List<dynamic> cardsJson = jsonDecode(cardsString);
      
      setState(() {
        deck.cards.clear();
        for (var cardData in cardsJson) {
          deck.addCard(Flashcard(
            question: cardData['question'],
            answer: cardData['answer'],
          ));
        }
      });
    }
  }

  void handleSwipe(DragEndDetails details){
    final velocity = details.primaryVelocity;
    if(velocity != null && velocity.abs() > 500){
      if(velocity > 0){
        previousCard();
      } else{
        nextCard();
      }
    }
  }

  void addCard(){
    if (questionController.text.isNotEmpty && answerController.text.isNotEmpty){
      setState(() {
        deck.addCard(
          Flashcard(
            question: questionController.text, 
            answer: answerController.text)
        );
        questionController.clear();
        answerController.clear();
      });
      _saveCards();  
    }
  }

  void shuffleDeck(){
    if(deck.cards.isNotEmpty){ 
      setState(() {
        deck.cards.shuffle();
        currentIndex = 0;
        showAnswer = false;
      });
      _saveCards();  
    }
  }

  void deleteCard() {
    if (deck.cards.isNotEmpty) {
      setState(() {
        deck.cards.removeAt(currentIndex);
        
        if (currentIndex >= deck.cards.length && deck.cards.isNotEmpty) {
          currentIndex = deck.cards.length - 1;
        }
        
        if (deck.cards.isEmpty) {
          currentIndex = 0;
        }
        
        showAnswer = false;
      });
      _saveCards(); 
    }
  }
  
  void toggleAnswer(){
    setState(() {
      showAnswer = !showAnswer;
    });
  }

  void toggleAddCardBox(){
    setState(() {
      showAddCardBox = !showAddCardBox;
    });
  }

  void nextCard(){
    if(deck.cards.isNotEmpty){
      setState(() {
        currentIndex = (currentIndex + 1) % deck.cards.length;
        showAnswer = false;
      });
    }
  }
  
  void previousCard(){
    if(deck.cards.isNotEmpty){
      setState(() {
        currentIndex = (currentIndex - 1) % deck.cards.length;
        showAnswer = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Study with me',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white, 
        elevation: 0, 
      ),
      extendBodyBehindAppBar: true,
      
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/study cat background.png'),
            fit: BoxFit.cover,  
          ),
        ),
        
        child: SafeArea(  
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (showAddCardBox) ...[
                  TextField(
                    controller: questionController,
                    decoration: InputDecoration(
                      labelText: 'Question',
                      filled: true,  
                      fillColor: Colors.white.withValues(alpha: 0.8),  
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: answerController,
                    decoration: InputDecoration(
                      labelText: 'Answer',
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),

                  const SizedBox(height: 12),

                  ElevatedButton(
                    onPressed: addCard,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 2, 24, 42),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Add card'),
                  ),

                  const SizedBox(height: 24),
                ],

                
                if (deck.cards.isNotEmpty) ...[

                  const SizedBox(height: 16),

                  GestureDetector(
                    onTap: toggleAnswer,
                    onHorizontalDragEnd: handleSwipe,
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 83, 134, 140).withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          showAnswer? deck.cards[currentIndex].answer: deck.cards[currentIndex].question,
                          style: const TextStyle(fontSize: 24, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8,),

                  Text(
                    'Tap card to ${showAnswer ? 'hide' : 'reveal'} answer',
                    style: const TextStyle(
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 3,
                          color: Colors.black45,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: previousCard,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 2, 24, 42),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Previous'),
                      ),
                      Text(
                        '${currentIndex + 1} / ${deck.cards.length}',
                        style: const TextStyle(
                          color: const Color.fromARGB(255, 2, 24, 42),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: nextCard,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 2, 24, 42),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Next'),
                      ),
                    ],
                    
                  )
                ] else ... [
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      'No cards yet! Add your first card above',
                      style: const TextStyle(
                        fontSize: 16, 
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    )
                  )
                ],
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FloatingActionButton(
                      onPressed: toggleAddCardBox,
                      tooltip: 'Add card',
                      backgroundColor: const Color.fromARGB(255, 2, 24, 42),
                      foregroundColor: Colors.white,
                      child: Text(
                        showAddCardBox ? '-' : '+',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                    
                    if (deck.cards.isNotEmpty)
                      FloatingActionButton(
                        onPressed: shuffleDeck,
                        tooltip: 'Shuffle deck',
                        backgroundColor: const Color.fromARGB(255, 2, 24, 42),
                        foregroundColor: Colors.white,
                        child: const Icon(Icons.shuffle),
                      ),
                    
                    if (deck.cards.isNotEmpty)
                      FloatingActionButton(
                        onPressed: deleteCard,
                        tooltip: 'Delete card',
                        backgroundColor: const Color.fromARGB(255, 2, 24, 42),
                        foregroundColor: Colors.white,
                        child: const Icon(Icons.delete),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  @override
  void dispose(){
    questionController.dispose();
    answerController.dispose();
    super.dispose();
  }
}