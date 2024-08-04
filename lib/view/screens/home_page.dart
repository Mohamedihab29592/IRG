import 'package:IRG/Model/data.dart';
import 'package:flutter/material.dart';

import '../widgets/my_form_field.dart';

class MyHomePage extends StatefulWidget {


  @override
  State<MyHomePage> createState() => _MyHomePageState();
}



var typeController = TextEditingController();

var locationController = TextEditingController();
var reporterController = TextEditingController();
var detailsController = TextEditingController();
var cstNamesController = TextEditingController();
var cstIDController = TextEditingController();
var actionController = TextEditingController();
var closureController = TextEditingController();
var socMemberController = TextEditingController();

class _MyHomePageState extends State<MyHomePage> {
  List<String> locationFilterItems = [];

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    typeController.addListener(() {
      setState(() {
        locationFilterItems = IncidentData.updateLocationItems(typeController.text);
        locationController.clear();

      });
    });
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  height: 40,
                  child: Image.asset(
                    "assets/vf logo.png",
                  )),
              SizedBox(
                width: 5,
              ),
              const Text('Incident report'),
            ],
          ),
          actions: [TextButton(onPressed: (){
            typeController.clear();
            locationController.clear();
            reporterController.clear();
            detailsController.clear();
            cstNamesController.clear();
            cstIDController.clear();
            actionController.clear();
            closureController.clear();
            socMemberController.clear();




          }, child: Text("Clear",style: TextStyle(color: Colors.black,fontSize: 18),))],
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
              primary: false,
              physics: BouncingScrollPhysics(),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    MyFormField(
                      isReadonly: true,
                      hint: "Choose from the list",

                      showDownMenu: true,
                      controller: typeController,
                      title: 'Incident Location',
                      maxLines: 1,
                      menuItems: IncidentData.locationTypeItems,

                    ),
                    SizedBox(
                      height: 20,
                    ),
                    MyFormField(
                        showDownMenu: true,

                        controller: locationController,
                        title: 'Location name',
                        maxLines: 1,
                        menuItems:locationFilterItems

                    ),

                    SizedBox(
                      height: 20,
                    ),
                    MyFormField(

                      controller: reporterController,
                      title: ' Reporter',
                      maxLines: 1,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    MyFormField(
                      showDownMenu: true,

                      controller: detailsController,
                      title: ' Details',
                      maxLines: 5,
                      menuItems: IncidentData.detailsItems,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(children: [
                      Expanded(
                        child: MyFormField(
                          title: "Customer Info (Optional)",
                          hint:"Name",
                          controller: cstNamesController,
                          maxLines: 1,
                          validator: (value) => null,

                        ),
                      ),
                      SizedBox(width: 10,),
                      Expanded(
                        child: MyFormField(
                          hint:"ID",
                          controller: cstIDController,
                          maxLines: 1,
                          validator: (value) => null,

                        ),
                      ),
                    ],),
                    SizedBox(
                      height: 20,
                    ),
                    MyFormField(
                        multiSelect: true,
                        hint: 'Case Reported to...',
                        showDownMenu: true,

                        controller: actionController,
                        title: ' SOC Action ',
                        maxLines: 3,
                        menuItems: IncidentData.actionItems),
                    SizedBox(
                      height: 20,
                    ),
                    MyFormField(
                        showDownMenu: true,

                        controller: closureController,
                        title: ' Closure ',
                        maxLines: 1,
                        menuItems: IncidentData.closureItems),
                    SizedBox(
                      height: 20,
                    ),
                    MyFormField(
                        showDownMenu: true,

                        controller: socMemberController,
                        title: ' Soc Member ',
                        maxLines: 1,
                        menuItems: IncidentData.socTeam),
                    SizedBox(
                      height: 20,
                    ),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(
                              Color(0xFFD32F2F)),
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            IncidentData().share(cstNamesController,cstIDController,locationController,reporterController ,detailsController, actionController, closureController,socMemberController);
                          }
                        },
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.share,
                                color: Colors.white,
                              ),
                              SizedBox(width: 8.0),
                              Text(
                                'Share',
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
          ),
        ),
      ),
    );
  }
}
