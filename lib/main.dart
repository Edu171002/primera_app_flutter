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
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random(); //WordPair es una clase de la biblioteca 'english_words' predefinida en flutter
  var favorites = <WordPair>[]; //Propiedad tipo lista que almacena objetos de tipo WordPair

  void getNext(){
    current = WordPair.random();
    notifyListeners();
  }

  void toggleFavorite(){
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 1;
  var extended = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SafeArea(
            child: NavigationRail(
              extended: extended,  //probar a extender esto en otro momento
              destinations: [
                NavigationRailDestination(icon: Icon(Icons.align_horizontal_left), label: Text('Toggle'),),
                NavigationRailDestination(icon: Icon(Icons.home), label: Text('Home'),),
                NavigationRailDestination(icon: Icon(Icons.favorite), label: Text('Favorites'),),
              ],
              selectedIndex: selectedIndex, //Indica el número de elemento del riel que se marcará como seleccionado
              onDestinationSelected: (value) {
                if(value==0) {
                  setState(() {
                    extended = !extended;
                  });
                } else {
                  setState(() {
                    selectedIndex = value;
                  });
                }
              },
            )
          ),
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: GeneratorPage(),
            ),
          ),
        ],
      )
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(child: Text('No favorites yet.'),);
    } else {
      return ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text('You have '
                '${appState.favorites.length} favorites:'),
          ),
          for (var pair in appState.favorites)
            ListTile(
              leading: Icon(Icons.favorite),
              title: Text(pair.asLowerCase),
            ),
        ],
      );
    }
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    //Icono de corazón del botón de like
    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;  //Corasón con relleno
    } else {
      icon = Icons.favorite_border; //Corasón solo contorno
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('A random idea:'),
          BigCard(pair: pair),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon( //Botón de like con un constructor que incluye un icono
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),

              SizedBox(width: 10),  //Para añadir espacio simplemente

              ElevatedButton( //Botón de siguiente
                onPressed: () { //Al pulsar carga otro valor aleatorio
                  appState.getNext();
                },
                child: Text('Next'),
              )
            ],
          ),
        ], //Children
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
    final tema = Theme.of(context);  //En dart, final es un tipo de variable al que no se le puede cambiar el valor tras su creación
    final estilo = tema.textTheme.displayMedium!.copyWith(color: Colors.white); //displayMedium es una propiedad con estilo grande, la ! sirve para forzar a Dart a trabajar con algo que podría ser nulo. copyWith() aplica el color blanco al texto

    return Card (
      color: tema.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(pair.asLowerCase, style: estilo),
      ),
    );
  }
}