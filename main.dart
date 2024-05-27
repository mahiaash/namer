import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
              seedColor: Colors
                  .deepOrange), //Generates a color scheme that goes with a certain color. Can build your own scheme or one will be given to you depending on the color you want
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair
      .random(); // Word pair comes from the english words package above.
  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }
  var history = <WordPair>[];
  var favorites = <WordPair>[];
  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
      history.add(current);
    }
    notifyListeners();
  }
  void removeFavorite(WordPair pair){
    favorites.remove(pair);
    notifyListeners();
  }
  
  void undo(WordPair pair){
    if(favorites.contains(pair)){
      Text("The " "$pair already exists");
    }
    else{
      favorites.add(pair);
    }
    
    
    notifyListeners();
  }
}
// ...

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
       // break;
      case 1:
        page = FavoritesPage(); // Placeholder is good for when you have not implemented a feature yet but need to demo it
      case 2:
      page = HistoryPage();
        //break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    return Scaffold(
      body: Row(
        children: [
          SafeArea(
            child: NavigationRail(
              extended: false,
              destinations: [
                NavigationRailDestination(
                  icon: Icon(Icons.home),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.favorite),
                  label: Text('Favorites'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.history), 
                  label: Text("History")
                  )
              ],
              selectedIndex: selectedIndex,
              onDestinationSelected: (value) {
                setState(() {
                  selectedIndex = value;
                });
              },
            ),
          ),
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: page,
            ),
          ),
        ],
      ),
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: pair.asPascalCase,
        ),
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var icon = Icons.delete;
    if(appState.favorites.isEmpty){
      return Center(
        child: Text("You Currently Have No Favorites"),
      );
    }
    return ListView(
      children: [
         Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have '
              '${appState.favorites.length} favorites:'),
         ),
      Text("Favorites"),
      for(var pair in appState.favorites)
        ListTile(
          leading: Icon(Icons.favorite),
          title: Text(pair.asCamelCase),
          trailing: IconButton(
            onPressed: (){
              appState.removeFavorite(pair);
              }, 
            icon: Icon(icon)
            ) 
          )
        
      ],
     );
          //TO Do
          // Make a delete button on favorites page --> Done
          // Create History --> Done
          // Create Undo button --> Done
  }

}
class HistoryPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var undoicon = Icons.add;
    if(appState.favorites.isEmpty){
      return Center(
        child: Text("You Have No History"),
        );
    }
    return ListView(
      children: [
        Padding(padding: const EdgeInsets.all(20)),
      Text("History"),
      for (var pair in appState.history)
      ListTile(
        title: Text(pair.asCamelCase),
        trailing: IconButton(
          onPressed: (){
            appState.undo(pair);
          }, 
          icon: Icon(undoicon)
          ),
          ),
      ],
      
    );
  }
  
}

