import 'package:IRG/features/Audit/presenation/view/screens/audit_screen.dart';
import 'package:IRG/features/IRG/presenation/view/screens/incident_report_page.dart';
import 'package:IRG/features/Locations/presenation/view/screens/location_screen.dart';
import 'package:flutter/material.dart';

class Layout extends StatefulWidget {
  const Layout({super.key});

  @override
  State<Layout> createState() => _LayoutState();
}
int currentIndex = 0;
class _LayoutState extends State<Layout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        elevation: 0,

        items: [
        BottomNavigationBarItem(icon: Icon(Icons.report,),label: 'Incident Report'),
        BottomNavigationBarItem(icon: Icon(Icons.edit,),label: 'Audit'),
        BottomNavigationBarItem(icon: Icon(Icons.add_location_sharp,),label: "Locations"),




      ],currentIndex: currentIndex,
      onTap: (va){
        changeIndex(va);


      },


      ),



    );
  }
  void changeIndex (int index)
  {
    setState(() {
      currentIndex = index;
    });
  }
  List<String> appBarTitle = ["Incident Report", "Audit", "Locations"];
  List<Widget> screens = [IncidentReportForm(), AuditScreen(), LocationsScreen()];
}
