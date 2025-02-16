import 'package:IRG/core/services/bloc_observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/services/di.dart';
import 'features/IRG/domain/repo.dart';
import 'features/IRG/presenation/controller/bloc.dart';
import 'features/IRG/presenation/controller/events.dart';
import 'features/IRG/presenation/view/screens/incident_report_form.dart';
import 'features/IRG/presenation/view/screens/splash.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await init();
Bloc.observer  = AppBlocObserver();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => IncidentBloc(
        repository:sl<IncidentRepository>(),

      )..add(LoadInitialDataEvent()),
      child: MaterialApp(
        theme: ThemeData(scaffoldBackgroundColor: Colors.grey[400],appBarTheme: AppBarTheme(color: Colors.grey[400],titleTextStyle: TextStyle(color: Colors.black,fontSize: 25))),
        debugShowCheckedModeBanner: false,

        // This widget is the ro
        home:  SplashScreen(),
      ),
    );
  }
}


