// lib/main.dart

import 'package:flutter/material.dart';
import 'models/food.dart';
import 'models/diary_entry.dart';
import 'models/sport_activity.dart';
import 'database/database_helper.dart';
import 'screens/diary_screen.dart';
import 'screens/food_list_screen.dart';
import 'screens/food_form_screen.dart';
import 'screens/food_entry_form_screen.dart';
import 'screens/sport_list_screen.dart';
import 'screens/sport_form_screen.dart';
import 'screens/sport_entry_form_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/statistics_screen.dart';
import 'dart:io' show Platform; // Import per il controllo della piattaforma
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // Import per FFI


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('it_IT', null);

  // Inizializza sqflite per desktop (Windows, macOS, Linux)
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  final DatabaseHelper dbHelper = DatabaseHelper(); // Ottieni l'istanza singleton del DatabaseHelper
  await _addInitialSampleData(dbHelper); // Inserisci i dati di esempio e attendi che l'operazione sia completata

  runApp(MyApp(dbHelper: dbHelper)); // Passa dbHelper a MyApp
}

// Funzione di esempio per aggiungere dati iniziali se il database è vuoto
Future<void> _addInitialSampleData(DatabaseHelper dbHelper) async {
  final foods = await dbHelper.getFoods();
  final sportActivities = await dbHelper.getSportActivities();

  if (foods.isEmpty) {
    // Inserimento dei cibi comuni nel formato richiesto
    final apple = Food(name: 'Mela', unit: 'grammi', caloriesPerUnit: 0.52, glycemicIndex: 39);
    final insertedFoodIdMela = await dbHelper.insertFood(apple);
    print('Added Sample Food Mela: ${apple.name} with ID: $insertedFoodIdMela');

    final banana = Food(name: 'Banana', unit: 'grammi', caloriesPerUnit: 0.89, glycemicIndex: 51);
    final insertedFoodIdBanana = await dbHelper.insertFood(banana);
    print('Added Sample Food Banana: ${banana.name} with ID: $insertedFoodIdBanana');

    final chickenBreast = Food(name: 'Petto di Pollo', unit: 'grammi', caloriesPerUnit: 1.65, glycemicIndex: 0);
    final insertedFoodIdChickenBreast = await dbHelper.insertFood(chickenBreast);
    print('Added Sample Food Petto di Pollo: ${chickenBreast.name} with ID: $insertedFoodIdChickenBreast');

    final salmon = Food(name: 'Salmone', unit: 'grammi', caloriesPerUnit: 2.08, glycemicIndex: 0);
    final insertedFoodIdSalmon = await dbHelper.insertFood(salmon);
    print('Added Sample Food Salmone: ${salmon.name} with ID: $insertedFoodIdSalmon');

    final whiteRice = Food(name: 'Riso Bianco Cotto', unit: 'grammi', caloriesPerUnit: 1.30, glycemicIndex: 73);
    final insertedFoodIdWhiteRice = await dbHelper.insertFood(whiteRice);
    print('Added Sample Food Riso Bianco Cotto: ${whiteRice.name} with ID: $insertedFoodIdWhiteRice');

    final whiteBread = Food(name: 'Pane Bianco', unit: 'grammi', caloriesPerUnit: 2.65, glycemicIndex: 75);
    final insertedFoodIdWhiteBread = await dbHelper.insertFood(whiteBread);
    print('Added Sample Food Pane Bianco: ${whiteBread.name} with ID: $insertedFoodIdWhiteBread');

    final oliveOil = Food(name: 'Olio d\'Oliva', unit: 'grammi', caloriesPerUnit: 8.84, glycemicIndex: 0);
    final insertedFoodIdOliveOil = await dbHelper.insertFood(oliveOil);
    print('Added Sample Food Olio d\'Oliva: ${oliveOil.name} with ID: $insertedFoodIdOliveOil');

    final swordfish = Food(name: 'Pesce Spada', unit: 'grammi', caloriesPerUnit: 1.21, glycemicIndex: 0);
    final insertedFoodIdSwordfish = await dbHelper.insertFood(swordfish);
    print('Added Sample Food Pesce Spada: ${swordfish.name} with ID: $insertedFoodIdSwordfish');

    final cookedLentils = Food(name: 'Lenticchie Cotte', unit: 'grammi', caloriesPerUnit: 1.16, glycemicIndex: 32);
    final insertedFoodIdCookedLentils = await dbHelper.insertFood(cookedLentils);
    print('Added Sample Food Lenticchie Cotte: ${cookedLentils.name} with ID: $insertedFoodIdCookedLentils');

    // Nuovi alimenti aggiunti (pesce e verdure)
    final codFillet = Food(name: 'Filetto di Merluzzo', unit: 'grammi', caloriesPerUnit: 0.82, glycemicIndex: 0);
    final insertedFoodIdCodFillet = await dbHelper.insertFood(codFillet);
    print('Added Sample Food Filetto di Merluzzo: ${codFillet.name} with ID: $insertedFoodIdCodFillet');

    final plainSwordfish = Food(name: 'Pesce Spada in Bianco', unit: 'grammi', caloriesPerUnit: 1.21, glycemicIndex: 0);
    final insertedFoodIdPlainSwordfish = await dbHelper.insertFood(plainSwordfish);
    print('Added Sample Food Pesce Spada in Bianco: ${plainSwordfish.name} with ID: $insertedFoodIdPlainSwordfish');

    final bakedSwordfish = Food(name: 'Pesce Spada al Forno', unit: 'grammi', caloriesPerUnit: 1.21, glycemicIndex: 0);
    final insertedFoodIdBakedSwordfish = await dbHelper.insertFood(bakedSwordfish);
    print('Added Sample Food Pesce Spada al Forno: ${bakedSwordfish.name} with ID: $insertedFoodIdBakedSwordfish');

    final bakedSeaBass = Food(name: 'Spigola al Forno', unit: 'grammi', caloriesPerUnit: 1.05, glycemicIndex: 0);
    final insertedFoodIdBakedSeaBass = await dbHelper.insertFood(bakedSeaBass);
    print('Added Sample Food Spigola al Forno: ${bakedSeaBass.name} with ID: $insertedFoodIdBakedSeaBass');

    final roastedEggplant = Food(name: 'Melanzane Arrostite', unit: 'grammi', caloriesPerUnit: 0.25, glycemicIndex: 20);
    final insertedFoodIdRoastedEggplant = await dbHelper.insertFood(roastedEggplant);
    print('Added Sample Food Melanzane Arrostite: ${roastedEggplant.name} with ID: $insertedFoodIdRoastedEggplant');

    final roastedZucchini = Food(name: 'Zucchine Arrostite', unit: 'grammi', caloriesPerUnit: 0.17, glycemicIndex: 15);
    final insertedFoodIdRoastedZucchini = await dbHelper.insertFood(roastedZucchini);
    print('Added Sample Food Zucchine Arrostite: ${roastedZucchini.name} with ID: $insertedFoodIdRoastedZucchini');

    final plainWholeWheatPasta = Food(name: 'Pasta Integrale in Bianco', unit: 'grammi', caloriesPerUnit: 1.50, glycemicIndex: 45);
    final insertedFoodIdPlainWholeWheatPasta = await dbHelper.insertFood(plainWholeWheatPasta);
    print('Added Sample Food Pasta Integrale in Bianco: ${plainWholeWheatPasta.name} with ID: $insertedFoodIdPlainWholeWheatPasta');

    final wholeWheatPastaWithSauce = Food(name: 'Pasta Integrale al Sugo', unit: 'grammi', caloriesPerUnit: 1.60, glycemicIndex: 50);
    final insertedFoodIdWholeWheatPastaWithSauce = await dbHelper.insertFood(wholeWheatPastaWithSauce);
    print('Added Sample Food Pasta Integrale al Sugo: ${wholeWheatPastaWithSauce.name} with ID: $insertedFoodIdWholeWheatPastaWithSauce');

    // Nuovi alimenti aggiunti (frutta secca e frutta)
    final kiwi = Food(name: 'Kiwi', unit: 'grammi', caloriesPerUnit: 0.61, glycemicIndex: 49);
    final insertedFoodIdKiwi = await dbHelper.insertFood(kiwi);
    print('Added Sample Food Kiwi: ${kiwi.name} with ID: $insertedFoodIdKiwi');

    final peach = Food(name: 'Pesche', unit: 'grammi', caloriesPerUnit: 0.39, glycemicIndex: 42);
    final insertedFoodIdPeach = await dbHelper.insertFood(peach);
    print('Added Sample Food Pesche: ${peach.name} with ID: $insertedFoodIdPeach');

    final almond = Food(name: 'Mandorle', unit: 'grammi', caloriesPerUnit: 5.79, glycemicIndex: 15);
    final insertedFoodIdAlmond = await dbHelper.insertFood(almond);
    print('Added Sample Food Mandorle: ${almond.name} with ID: $insertedFoodIdAlmond');

    final walnut = Food(name: 'Noci', unit: 'grammi', caloriesPerUnit: 6.54, glycemicIndex: 15);
    final insertedFoodIdWalnut = await dbHelper.insertFood(walnut);
    print('Added Sample Food Noci: ${walnut.name} with ID: $insertedFoodIdWalnut');

    final pistachio = Food(name: 'Pistacchio', unit: 'grammi', caloriesPerUnit: 5.57, glycemicIndex: 15);
    final insertedFoodIdPistachio = await dbHelper.insertFood(pistachio);
    print('Added Sample Food Pistacchio: ${pistachio.name} with ID: $insertedFoodIdPistachio');

    final pear = Food(name: 'Pera', unit: 'grammi', caloriesPerUnit: 0.57, glycemicIndex: 38);
    final insertedFoodIdPear = await dbHelper.insertFood(pear);
    print('Added Sample Food Pera: ${pear.name} with ID: $insertedFoodIdPear');

    // Nuovi alimenti aggiunti (carni)
    final leanGroundBeef = Food(name: 'Manzo Macinato Magro', unit: 'grammi', caloriesPerUnit: 1.37, glycemicIndex: 0); // ~137 kcal/100g, IG 0
    final insertedFoodIdLeanGroundBeef = await dbHelper.insertFood(leanGroundBeef);
    print('Added Sample Food Manzo Macinato Magro: ${leanGroundBeef.name} with ID: $insertedFoodIdLeanGroundBeef');

    final beefSteak = Food(name: 'Bistecca di Manzo', unit: 'grammi', caloriesPerUnit: 2.71, glycemicIndex: 0); // ~271 kcal/100g, IG 0
    final insertedFoodIdBeefSteak = await dbHelper.insertFood(beefSteak);
    print('Added Sample Food Bistecca di Manzo: ${beefSteak.name} with ID: $insertedFoodIdBeefSteak');

    final turkeyBreast = Food(name: 'Fesa di Tacchino', unit: 'grammi', caloriesPerUnit: 1.09, glycemicIndex: 0); // ~109 kcal/100g, IG 0
    final insertedFoodIdTurkeyBreast = await dbHelper.insertFood(turkeyBreast);
    print('Added Sample Food Fesa di Tacchino: ${turkeyBreast.name} with ID: $insertedFoodIdTurkeyBreast');

    final lambChops = Food(name: 'Costolette di Agnello', unit: 'grammi', caloriesPerUnit: 2.94, glycemicIndex: 0); // ~294 kcal/100g, IG 0
    final insertedFoodIdLambChops = await dbHelper.insertFood(lambChops);
    print('Added Sample Food Costolette di Agnello: ${lambChops.name} with ID: $insertedFoodIdLambChops');

    final porkSausage = Food(name: 'Salsiccia di Maiale', unit: 'grammi', caloriesPerUnit: 3.21, glycemicIndex: 0); // ~321 kcal/100g, IG 0
    final insertedFoodIdPorkSausage = await dbHelper.insertFood(porkSausage);
    print('Added Sample Food Salsiccia di Maiale: ${porkSausage.name} with ID: $insertedFoodIdPorkSausage');

    final cookedHam = Food(name: 'Prosciutto Cotto', unit: 'grammi', caloriesPerUnit: 1.45, glycemicIndex: 0); // ~145 kcal/100g, IG 0
    final insertedFoodIdCookedHam = await dbHelper.insertFood(cookedHam);
    print('Added Sample Food Prosciutto Cotto: ${cookedHam.name} with ID: $insertedFoodIdCookedHam');

    final rabbitMeat = Food(name: 'Carne di Coniglio', unit: 'grammi', caloriesPerUnit: 1.73, glycemicIndex: 0); // ~173 kcal/100g, IG 0
    final insertedFoodIdRabbitMeat = await dbHelper.insertFood(rabbitMeat);
    print('Added Sample Food Carne di Coniglio: ${rabbitMeat.name} with ID: $insertedFoodIdRabbitMeat');

    final vealMeat = Food(name: 'Carne di Vitello', unit: 'grammi', caloriesPerUnit: 1.08, glycemicIndex: 0); // ~108 kcal/100g (taglio magro), IG 0
    final insertedFoodIdVealMeat = await dbHelper.insertFood(vealMeat);
    print('Added Sample Food Carne di Vitello: ${vealMeat.name} with ID: $insertedFoodIdVealMeat');



    final now = DateTime.now();
    final date = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final time = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    final foodEntry = DiaryEntry(
      date: date,
      time: time,
      type: 'food',
      foodId: insertedFoodIdMela,
      quantity: 150.0,
    );
    final insertedFoodEntryId = await dbHelper.insertDiaryEntry(foodEntry);
    print('Added Sample Diary Food Entry for ${apple.name}: ${foodEntry.quantity} ${apple.unit} with ID: $insertedFoodEntryId');
  }

  if (sportActivities.isEmpty) {
    // Inserimento delle attività sportive nel formato richiesto
    final running = SportActivity(name: 'Corsa', caloriesBurnedPerMinute: 10.0);
    final insertedSportActivityIdRunning = await dbHelper.insertSportActivity(running);
    print('Added Sample Sport Activity Corsa: ${running.name} with ID: $insertedSportActivityIdRunning');

    final briskWalk = SportActivity(name: 'Camminata Sostenuta', caloriesBurnedPerMinute: 6.0);
    final insertedSportActivityIdBriskWalk = await dbHelper.insertSportActivity(briskWalk);
    print('Added Sample Sport Activity Camminata Sostenuta: ${briskWalk.name} with ID: $insertedSportActivityIdBriskWalk');

    final stationaryBike = SportActivity(name: 'Cyclette Sostenuta (27-30 km/h)', caloriesBurnedPerMinute: 10.0);
    final insertedSportActivityIdStationaryBike = await dbHelper.insertSportActivity(stationaryBike);
    print('Added Sample Sport Activity Cyclette Sostenuta: ${stationaryBike.name} with ID: $insertedSportActivityIdStationaryBike');

    final beachWalk = SportActivity(name: 'Passeggiata al Mare', caloriesBurnedPerMinute: 4.5);
    final insertedSportActivityIdBeachWalk = await dbHelper.insertSportActivity(beachWalk);
    print('Added Sample Sport Activity Passeggiata al Mare: ${beachWalk.name} with ID: $insertedSportActivityIdBeachWalk');

    final mountainWalk = SportActivity(name: 'Passeggiata in Montagna', caloriesBurnedPerMinute: 8.0);
    final insertedSportActivityIdMountainWalk = await dbHelper.insertSportActivity(mountainWalk);
    print('Added Sample Sport Activity Passeggiata in Montagna: ${mountainWalk.name} with ID: $insertedSportActivityIdMountainWalk');

    final treadmillWalk = SportActivity(name: 'Tapis roulant 5 km/h', caloriesBurnedPerMinute: 4.5);
    final insertedSportActivityIdTreadmillWalk = await dbHelper.insertSportActivity(treadmillWalk);
    print('Added Sample Sport Activity Tapis roulant 5 km/h: ${treadmillWalk.name} with ID: $insertedSportActivityIdTreadmillWalk');

    final swimming = SportActivity(name: 'Nuoto (Stile Libero Moderato)', caloriesBurnedPerMinute: 8.0);
    final insertedSportActivityIdSwimming = await dbHelper.insertSportActivity(swimming);
    print('Added Sample Sport Activity Nuoto: ${swimming.name} with ID: $insertedSportActivityIdSwimming');

    final yoga = SportActivity(name: 'Yoga (Vinyasa Flow)', caloriesBurnedPerMinute: 4.0);
    final insertedSportActivityIdYoga = await dbHelper.insertSportActivity(yoga);
    print('Added Sample Sport Activity Yoga: ${yoga.name} with ID: $insertedSportActivityIdYoga');


    final now = DateTime.now();
    final date = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final time = "${(now.hour + 1).toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    final sportEntry = DiaryEntry(
      date: date,
      time: time,
      type: 'sport',
      sportActivityId: insertedSportActivityIdRunning,
      quantity: 30.0,
    );
    final insertedSportEntryId = await dbHelper.insertDiaryEntry(sportEntry);
    print('Added Sample Diary Sport Entry for ${running.name}: ${sportEntry.quantity} minutes with ID: $insertedSportEntryId');
  }
}

class MyApp extends StatelessWidget {
  final DatabaseHelper dbHelper; // Ricevi dbHelper
  const MyApp({super.key, required this.dbHelper});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => MyHomePage(dbHelper: dbHelper), // Passa dbHelper
        '/add_food': (context) => FoodFormScreen(dbHelper: dbHelper), // Passa dbHelper
        '/food_entry_form': (context) => FoodEntryFormScreen(dbHelper: dbHelper), // Passa dbHelper
        '/add_sport_activity': (context) => SportFormScreen(dbHelper: dbHelper), // Passa dbHelper
        '/sport_entry_form': (context) => SportEntryFormScreen(dbHelper: dbHelper), // Passa dbHelper
        '/statistics': (context) => StatisticsScreen(dbHelper: dbHelper), // Passa dbHelper
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  final DatabaseHelper dbHelper; // Ricevi dbHelper
  const MyHomePage({super.key, required this.dbHelper});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0; // 0 for Diary, 1 for Foods, 2 for Sport Activities, 3 for Statistics

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      DiaryScreen(dbHelper: widget.dbHelper), // Usa widget.dbHelper
      FoodListScreen(dbHelper: widget.dbHelper), // Usa widget.dbHelper
      SportListScreen(dbHelper: widget.dbHelper), // Usa widget.dbHelper
      StatisticsScreen(dbHelper: widget.dbHelper), // Usa widget.dbHelper
    ];
    // _addSampleData(); // Rimosso: i dati di esempio sono ora aggiunti in main()
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context); // Close the drawer
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            _selectedIndex == 0 ? 'Diario Alimentare e Sportivo' :
            (_selectedIndex == 1 ? 'Gestione Cibi' :
            (_selectedIndex == 2 ? 'Gestione Attività Sportive' : 'Statistiche'))
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Food & Fitness Tracker',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.book),
              title: const Text('Diario'),
              selected: _selectedIndex == 0,
              onTap: () {
                _onItemTapped(0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.food_bank),
              title: const Text('Cibi'),
              selected: _selectedIndex == 1,
              onTap: () {
                _onItemTapped(1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.sports_soccer),
              title: const Text('Attività Sportive'),
              selected: _selectedIndex == 2,
              onTap: () {
                _onItemTapped(2);
              },
            ),
            ListTile(
              leading: const Icon(Icons.show_chart),
              title: const Text('Statistiche'),
              selected: _selectedIndex == 3,
              onTap: () {
                _onItemTapped(3);
              },
            ),
          ],
        ),
      ),
      body: _screens[_selectedIndex],
    );
  }
}



