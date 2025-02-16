import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/services/di.dart';
import '../../../domain/repo.dart';
import '../../controller/bloc.dart';
import '../../controller/events.dart';
import '../widgets/incident_report_page.dart';

class IncidentReportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => IncidentBloc(
        repository:sl<IncidentRepository>(),

      )..add(LoadInitialDataEvent()),
      child: IncidentReportForm(),
    );
  }
}