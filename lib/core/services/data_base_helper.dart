import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('incident_database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Create tables for static data
    await db.execute('''
    CREATE TABLE incident_types (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL
    )
    ''');

    await db.execute('''
    CREATE TABLE location_types (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL
    )
    ''');

    await db.execute('''
    CREATE TABLE locations (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      location_type_id INTEGER,
      FOREIGN KEY (location_type_id) REFERENCES location_types (id)
    )
    ''');

    await db.execute('''
    CREATE TABLE action_items (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL
    )
    ''');

    await db.execute('''
    CREATE TABLE lea_members (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL
    )
    ''');

    await db.execute('''
    CREATE TABLE soc_team (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL
    )
    ''');

    await db.execute('''
    CREATE TABLE incident_details (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL
    )
    ''');

    await db.execute('''
    CREATE TABLE closure_status (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL
    )
    ''');

    // Insert initial data
    await _insertInitialData(db);
  }

  Future<void> _insertInitialData(Database db) async {
    // Insert incident types
    for (String type in [
      "Hassle",
      "Fire",
      "Pomp",
      "demonstration",
      "terrorism",
      "Other"
    ]) {
      await db.insert('incident_types', {'name': type});
    }

    // Insert location types
    for (String type in [
      "Building",
      "Owned",
      "Express",
      "Switch",
      "DC",
      "Warehouse",
      "Franchise",
      "Apartment",
      "Other"
    ]) {
      await db.insert('location_types', {'name': type});
    }

    // Insert locations for each type with their predefined lists
    await _insertLocationsForType(db, "Building", [
      "10th of Ramadan",
      "3rd District",
      "Horizon",
      "Mokattam",
      "Raya",
      "Smart Village",
      "Zahraa Maadi",
    ]);
    await _insertLocationsForType(db, "Owned", [
      "Alex Smouha Owned Store",
      'Alex San Stefano Owned Store',
      'Alex Syria Owned Store',
      'Alex CC Owned Store',
      'Almazah Owned Store',
      'Arkan Owned Store',
      'Assiut Owned Store',
      'Aswan Owned Store',
      'Cairo festival Owned Store',
      'C-Park Owned Store',
      'Ismaelia Owned Store',
      'Luxor Owned Store',
      'Maadi CC Owned Store',
      'Madenaty Owned Store',
      'Mahala Owned Store',
      'Mall Of Arabia Owned Store',
      'Mall of Egypt Owned Store',
      'Mansoura Mohafza Owned Store',
      'Port Said Owned Store',
      'Rehab Owned Store',
      'Seoudi - Zayed Owned Store',
      'Sodic Owned Store',
      'Sphinx Owned Store',
      'Suez Owned Store',
      'Tanta Owned Store',
      'Walk of Cairo Owned Store',
      'Zagazig 1 Owned Store',
    ]);

    await _insertLocationsForType(db, "Express", [
      "10th of Ramadan Andalus St Express Store",
      "6 Oct Motamaiez Express Store",
      "6 Oct Ordonya Express Store",
      "6th October-El hossary Express store",
      "Aabed Mall Express Store",
      "Abanoub Express Store",
      "Abbassia Express Store",
      "Abdeen Express Store",
      "AbdElhameed Badawy St Express Store",
      "Abu ElMatamir Express Store",
      "Abu Hammad Express Store",
      "Abu Hommus Express Store",
      "Abu Kebir Express Store",
      "Abu Tieg Express Store",
      "Aga Dakahlya Express Store",
      "Aghakhan Express Store",
      "Ain shams",
      "Ain shams - Moustafa Hafez St Express Store",
      "Ain Shams Naam Express Store",
      "Alex - Azareeta Express Store",
      "Alex 45 st. Express Store",
      "Alex Abu Qir Express Store",
      "Alex Agamy Hannoville Hotel Express Store",
      "Alex Ameraya Express store",
      "Alex Bahry Express Store",
      "Alex Ekbal St. Express Store",
      "Alex Gamal AbdelNaser Express Store",
      "Alex Mina Basal Express Store",
      "Alex Moharam Baik Express Store",
      "Alex Montaza Royal Mall Express Store",
      "Alex Raml Station Express Store",
      "Alex Seyouf Express Store",
      "Alex SidiGaber Express Store",
      "Alex Zizanya Express store",
      "Ameraya Koubry Express Store",
      "Ard El Lowaa Express Store",
      "Ashmoon Express store",
      "Assiut ElNasr Express Store",
      "Assiut Helaly St. Express Store",
      "Assuit Station Express Store",
      "Aswan ElTahrir St. Express Store",
      "Ayyat Express Store",
      "Badrasheen Express store",
      "Bagour Express Store",
      "Bahteem Express Store",
      "Banha ELMahatta Express Store",
      "Banha Mousa St Express Store",
      "Bani Mazar Express Store",
      "Bany Sweef Orabi St Express Store",
      "Bany Sweef Wasta Express Store",
      "BanySwef Elrawda St Express Store",
      "Barageel Express Store",
      "Basyoun Express Store",
      "Batl Ahmed AbdelAziz st Express Store",
      "Beheera Badr City Express Store",
      "Belbees Express",
      "Belbees Zaglol St Express Store",
      "Belqas Express Store",
      "Berket elsabaa Express",
      "Biala Express Store",
      "Bolak Elteraa St Express Store",
      "Borg Alarab Express",
      "Bulak Abu El Ela Express Store",
      "Bulak Eldakrour Express store",
      "Cairo University Store",
      "Damanhour - ElMahkama ELQadima Express Store",
      "Damanhour ElGamaa St Express store",
      "Damietta Abo ElWafa Sq. Express Store",
      "Dar Elsalam - Fayoum St Express Store",
      "Darasa Express Store",
      "Dayrout Express Store",
      "Dekernes Express Store",
      "Dekerness Elmahatta Express Store",
      "Delengat Express Store",
      "Desouk Elgish St Express Store",
      "Desouk express store",
      "Dokki - Mesaha Square Express Store",
      "Dokki Express Store",
      "Downtown - Mobtadayan Express Store",
      "Downtown Sabri AbuAlam Express Store",
      "Dyarb Negm Express",
      "Edfu Express Store",
      "El Amiria Express Store",
      "el bahr elazam Express store",
      "El Herafeyen Express store",
      "El Katamya 7 Stars Mall Express Store",
      "El Maadi-Elnasr st. express store",
      "EL Manzala Express Store",
      "El Moneeb Express Store",
      "El Nozha st. express store",
      "El qanater elkhayraya Express",
      "El Sadaat Express store",
      "El Salhya Express Store",
      "El waily Express store",
      "El Zawya El Hamra Express Store",
      "Eltal Elkbeer express store",
      "Elwarrak Elnozha St Express Store",
      "Elwarrak express store",
      "ElZayton Tomanbay Express Store",
      "Embaba Express Store",
      "Esna Express Store",
      "Faisal Elgamal St Express Store",
      "Faisal ElTawabek Express Store",
      "Faisal Eshreen ST. Express Store",
      "Faqous Express",
      "Faraskour Express Store",
      "Fayoum - Elhorya Express Store",
      "Fayoum Abdelnaser St Express Store",
      "Fayoum Atsa Express Store",
      "Fayoum Tamaya Express Store",
      "Gerga Express Store",
      "Hadayaak AL Ahram Express store",
      "Hadayek El Kobba Express store",
      "Hadayek Helwan Express Store",
      "Hamd Plaza Mall Express Store",
      "Haram Batran",
      "Haram Mashaal Express Store",
      "Haram Sahl Hamza Express Store",
      "Haram Talateny Express Store",
      "Haram Tersa Express Store",
      "Harm Talbia Express Store",
      "Hawamdia Express Store",
      "Heliopolis Square Express Store",
      "Helwan Hamamat Express Store",
      "Housh Eissa express store",
      "Hurgahada Elmamsha Express Store",
      "Hurghada ElDahhar Express Store",
      "Hurghada sinzo",
      "Ibshway Express Store",
      "Imbaba Wehda St Express Store",
      "Ismailia Eleshreni St Express store",
      "Ismailia Shebin St. Express Store",
      "Itay El Baroud Express Store",
      "Kafr El Dawar Express Store",
      "Kafr Elsheikh El Gamaa ST Express Store",
      "Kafr Elzayat express store",
      "Kafr Saad Express Store",
      "Kafr Sakr Express store",
      "Kafr Shoukr Express Store",
      "kasr elaany express store",
      "Kom Hamada Express Store",
      "Komombo Express Store",
      "Luxor Station Express Store",
      "Maadi Degla Express Store",
      "Maadi EL Zahraa Express Store",
      "Maadi Ring Road Express Store",
      "Maadi Sakr Korish Express Store",
      "Madinet Elsallam Express",
      "Mahalla Shoun Sq. Express Store",
      "Mahattet Misr Express Store",
      "Makattam Zelzal Express Store",
      "Malawi Express Store",
      "Manfaloot Express Store",
      "Manial Sheha Express store",
      "Mansoura Beshbeshy St Express Store",
      "ManSoura Kolyt eladab Express Store",
      "Manyet Elnasr Express store",
      "Marg Express Store",
      "Marg Station Express Store",
      "Mashtool ElSouq Express Store",
      "Masr ElQadima Express Store",
      "Matarya Express Store",
      "Matarya Terat Elgabl Express Store",
      "Meet Ghamr express store",
      "Meet Ghamr Port Said St Express Store",
      "Mega Mall 15 May Express Store",
      "Menouf Express Store",
      "Menouf Gish St Express Store",
      "Menya Kamh Sharqia Express Store",
      "Menya Nefertety Hotel Express Store",
      "Minya Palace square Express Store",
      "Mirage Express Store",
      "Moasasa Express Store",
      "Mohandeseen Gamaet Dewal Express Store",
      "Mokkattam Elhadaba Express Store",
      "Motobos Express Store",
      "Mourad St Express Store",
      "Moustafa Elnahas ST Express Store",
      "Nabarouh Express Store",
      "Nasr City - Hay Sefarat Express Store",
      "Nasr City Azhar University Express Store",
      "Nasr City Gabl Akhdar Express Store",
      "Nasr City Seven Buildings Express Store",
      "Nasr City Zahraa Express Store",
      "Nasr city-ElHay Elasher Express store",
      "Nasr City-Makram Ebied Express Store",
      "Nasr City-Nabil ElWakad Express Store",
      "Nasr City-Nady AlAhly Express Store",
      "Nasr El Din Haram Express",
      "New Damietta Express store",
      "Nozha ElGadida Express Store",
      "Obour buildings",
      "Omranya Mini Express Store",
      "Oseem Express Store",
      "Point 90 Mall Express Store",
      "Port Fouad Express store",
      "Port Said ElNasr St. Express Store",
      "Port Said Zohor Express Store",
      "Portsaid Talatiny St. Express Store",
      "PortSaid-ElBazar Express Store",
      "Qalyoub Express Store",
      "Qantara Express store",
      "Qebaa Express Store",
      "Qena Mall Express Store",
      "Qotour Express Store",
      "Qous Express Store",
      "Qousiya Assuit Express Store",
      "Qowesna Express store",
      "Quena Mahatta Express Store",
      "Ramsis Express Store",
      "Ras ElBar Express Store",
      "Ras Ghareb Express Store",
      "Rasheed Express store",
      "Remaia Express Store",
      "Rod El Farag Express store",
      "Sainte Fatima Express Store",
      "Samalout Express Store",
      "Samanoud Express Store",
      "Santa Express Store",
      "Sayeda Zainab Express Store",
      "Senores Express Store",
      "Sharm Nabq Express Store",
      "Sharm Neama Bay Express Store",
      "Sharqia ElHusainya Express Store",
      "Shebin elbahr St Express Store",
      "Shebin ELKom Stadium Express Store",
      "Shebin ElQanater Express Store",
      "Sheraton Ankara St Express Store",
      "Sheraton- Heliopolis Express",
      "Sherbeen Express Store",
      "Shobrakhit Express Store",
      "Shobrakhit Portsaid St Express Store",
      "Shoubra Elkhima - 15 May St Express Store",
      "Shoubra-Kholousy Express Store",
      "Sidi Salem Kafr Shikh Express Store",
      "Silver Star Mall Express Store",
      "Sinbalaween Express store",
      "Sohag Elteraa Express Store",
      "Sohag Station Express Store",
      "Soubra Saint Traez Express Store",
      "Sporting express store",
      "Suez ElArbieen Express Store",
      "Suez Malaha Express Store",
      "Sun city",
      "Tagamoa Elsouq St Express Store",
      "Tahta Express Store",
      "Talkha Express Store",
      "Tanta Mahatta Express Store",
      "Tanta Nahhas St. Express Store",
      "Tanta Saeed St Express Store",
      "Tema express store",
      "TomanBy Express Store",
      "Tookh Express Store",
      "Triumph Express Store",
      "Twin Plaza Mall Express Store",
      "Wady ElGadid Express Store",
      "Zagazig Elmontaza Express Store",
      "Zaher Square Express Store",
      "Zamalek Express store",
      "Zefta Express Store",
    ]);

    await _insertLocationsForType(db, "Switch", [
      "10th of Ramadan MTX",
      "3rd District MTX",
      "Alex-Lotus MTX",
      "Beni Sweif MTX",
      "Horizon MTX",
      "Mansoura MTX",
      "Mokattam MTX",
      "Tanta MTX",
      "Zahraa Maadi MTX",
    ]);

    await _insertLocationsForType(db, "DC", [
      "10th of Ramdan building DC",
      "Horizon DC",
      "Smart village DC",
      "Zahraa Building DC"
    ]);

    await _insertLocationsForType(db, "Warehouse", [
      "Abu Rawash 1"
    ]);

    await _insertLocationsForType(db, "Franchise", [
      "Damietta Kornaish Store",
      "Dumiat",
      "Mansoura",
      "Dandy Mall",
      "Hyper One Store",
      "Faisal",
      "Haram store",
      "El-Monofeya",
      "Kafr Elshekh",
      "Merghany",
      "ElDemerdash",
      "Khalifa El-Maamoon",
      "Nasr City",
      "Tayaran-Nasr City",
      "Abbas El Akad Store",
      "Geish Store",
      "Hurghada",
      "Naga3 Hamadi",
      "Qena",
      "Sohag",
      "Embaba",
      "Mosadaq",
      "Sudan",
      "Shehab",
      "Damanhour",
      "Miami",
      "Zahran Store",
      "Marsa Matrouh",
      "Masr wel Sudan",
      "Mokkatam",
      "Zeytoun",
      "Carrefour Obour",
      "Sharm",
      "Bany sweif",
      "El Fayoum",
      "El-Menya",
      "10th of Ramdan",
      "Banha",
      "Helwan",
      "Maadi Laselki",
      "Shoubra",
      "shoubra new",
      "Zamalek",
      "Zagazik 2",
      "Maadi 9",
      "Down Town Store",
      "Maadi Misr Helwan St Store",
      "Arena Mall Store"
    ]);

    await _insertLocationsForType(db, "Apartment", [
      "Assuit Apartment",
      "Ismailia Apartment",
      "Luxor Apartment",
      "Tanta Apartment"
    ]);


    // Insert action items
    for (String action in [
      "Police",
      "LEA",
      "LEGAL",
      "H&S",
      "P&FM",
      "PR",
      "PA"
    ]) {
      await db.insert('action_items', {'name': action});
    }

    // Insert LEA members
    for (String member in [
      "Akram Ali",
      "Ahmed ElDesouky",
      "Ahmed Aly",
      "Mohamed Mansy",
      "Momen Sayed",
      "Tarek El Nagar",
    ]) {
      await db.insert('lea_members', {'name': member});
    }

    // Insert SOC team members
    for (String member in [
      "Mohamed Abo Elez",
      "Ahmed Hamdy",
      "Mohamed Ihab",
      "Ahmed Hassan",
      "Karim Abo Ela",
      "Hady Khalifa",
    ]) {
      await db.insert('soc_team', {'name': member});
    }

    // Insert incident details
    for (String detail in [
      "A disgruntled customer asked to ",
      "A disgruntled customer refused to wait queue ",
      "A employee fainted on the floor ",
      "A Fire broke out in the ",
      "A Police officer asked to review CCTV records for an ongoing investigation ",
    ]) {
      await db.insert('incident_details', {'name': detail});
    }

    // Insert closure status options
    for (String status in ["In Progress", "Case closed", "Case closed after reconciliation"]) {
      await db.insert('closure_status', {'name': status});
    }

  }

  Future<void> _insertLocationsForType(Database db, String locationType, List<String> locations) async {
    // First, get the location type ID
    final typeResult = await db.query(
      'location_types',
      columns: ['id'],
      where: 'name = ?',
      whereArgs: [locationType],
    );

    if (typeResult.isNotEmpty) {
      final typeId = typeResult.first['id'] as int;
      // Insert locations with the correct type ID
      for (String location in locations) {
        await db.insert('locations', {
          'name': location,
          'location_type_id': typeId,
        });
      }
    }
  }
  // Helper methods to get data
  Future<List<Map<String, dynamic>>> getIncidentTypes() async {
    final db = await instance.database;
    return await db.query('incident_types');
  }

  Future<List<Map<String, dynamic>>> getLocationTypes() async {
    final db = await instance.database;
    return await db.query('location_types');
  }

  Future<List<Map<String, dynamic>>> getLocationsByType(String locationType) async {
    final db = await instance.database;

    // First, get the location type ID
    final typeResult = await db.query(
      'location_types',
      columns: ['id'],
      where: 'name = ?',
      whereArgs: [locationType],
    );

    if (typeResult.isEmpty) return [];

    final typeId = typeResult.first['id'] as int;

    // Get locations for this type ID
    return await db.query(
      'locations',
      where: 'location_type_id = ?',
      whereArgs: [typeId],
      orderBy: 'name ASC', // Optional: sort by name
    );
  }
  Future<List<Map<String, dynamic>>> getActionItems() async {
    final db = await instance.database;
    return await db.query('action_items');
  }

  Future<List<Map<String, dynamic>>> getLeaMembers() async {
    final db = await instance.database;
    return await db.query('lea_members');
  }

  Future<List<Map<String, dynamic>>> getSocTeam() async {
    final db = await instance.database;
    return await db.query('soc_team');
  }

  Future<List<Map<String, dynamic>>> getIncidentDetails() async {
    final db = await instance.database;
    return await db.query('incident_details');
  }

  Future<List<Map<String, dynamic>>> getClosureStatus() async {
    final db = await instance.database;
    return await db.query('closure_status');
  }

  // Close database
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}