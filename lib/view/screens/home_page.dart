import 'dart:io';

import 'package:IRG/Model/data.dart';
import 'package:docx_template/docx_template.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../widgets/my_form_field.dart';

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

var incidentTypeController = TextEditingController();
var typeController = TextEditingController();
var locationController = TextEditingController();
var addressController = TextEditingController();
var reporterController = TextEditingController();
var reporterNameController = TextEditingController();
var reporterIdController = TextEditingController();
var detailsController = TextEditingController();
var cstNamesController = TextEditingController();
var cstIDController = TextEditingController();
var actionController = TextEditingController();
var closureController = TextEditingController();
var socMemberController = TextEditingController();
var leaMemberController = TextEditingController();
var dateController = TextEditingController();
var timeController = TextEditingController();
var policeNuController = TextEditingController();
var guardAttackDController = TextEditingController();

class _MyHomePageState extends State<MyHomePage> {
  List<String> locationFilterItems = [];
  bool isYesSelected = false; // Defaults to "No"
  IncidentData incidentData = IncidentData();
  File? _selectedImage;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);
        setState(() {
          _selectedImage = imageFile;
        });
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  // Enum to represent Yes/No options
  YesNo selectedOption = YesNo.No; // Default to "No"
  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    typeController.addListener(() {
      setState(() {
        locationFilterItems =
            IncidentData.updateLocationItems(typeController.text);
        locationController.clear();
      });
    });
    return PopScope(
      canPop: false,
      child: SafeArea(
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
            actions: [
              TextButton(
                  onPressed: () async {
                    typeController.clear();
                    incidentTypeController.clear();
                    locationController.clear();
                    reporterController.clear();
                    detailsController.clear();
                    cstNamesController.clear();
                    cstIDController.clear();
                    actionController.clear();
                    closureController.clear();
                    socMemberController.clear();
                    addressController.clear();
                    reporterIdController.clear();
                    leaMemberController.clear();
                    dateController.clear();
                    timeController.clear();
                    policeNuController.clear();
                    guardAttackDController.clear();

                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("All data has been cleared")));
                  },
                  child: Text(
                    "Clear",
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ))
            ],
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
                      //Location type
                      MyFormField(
                        validator: (value)=>null,
                        hint: "",
                        showDownMenu: true,
                        controller: incidentTypeController,
                        title: 'Incident Type (Optional)',
                        maxLines: 1,
                        menuItems: IncidentData.incidentTypeItems,
                      ),
                      SizedBox(height: 20),

                      //Date
                      MyFormField(
                        validator: (value)=>null,
                        controller: dateController,
                        title: 'Incident Date (Optional)',
                        hint: "Select date",
                        maxLines: 1,
                        isReadonly: true,
                        onTap: () async {
                          DateTime? selectedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (selectedDate != null) {
                            dateController.text =
                                "${selectedDate.toLocal()}".split(' ')[0];
                          }
                        },
                      ),
                      SizedBox(height: 20),
                      //Time
                      MyFormField(
                        validator: (value)=>null,
                        controller: timeController,
                        title: 'Incident Time (Optional)',
                        hint: "Select time",
                        maxLines: 1,
                        isReadonly: true,
                        onTap: () async {
                          TimeOfDay? selectedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (selectedTime != null) {
                            timeController.text = selectedTime.format(context);
                          }
                        },
                      ),
                      SizedBox(height: 20),
                      //Location type
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
                      //Location Name
                      MyFormField(
                          showDownMenu: true,
                          controller: locationController,
                          title: 'Location name',
                          maxLines: 1,
                          menuItems: locationFilterItems),
                      SizedBox(
                        height: 20,
                      ),
                       //Address
                      MyFormField(
                        validator: (value)=>null,
                        title: "Address (Optional)",
                        hint: "",
                        controller: addressController,
                        maxLines: 1,
                      ),

                      SizedBox(
                        height: 20,
                      ),
                      MyFormField(
                        title: "Reported by",
                        hint: "Full Name",
                        controller: reporterNameController,
                        maxLines: 1,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      //Reporter
                      Row(
                        children: [
                          Expanded(
                            child: MyFormField(
                              validator: (value)=>null,
                              title: "Reporter Info (Optional)",
                              hint: "Name",
                              controller: reporterController,
                              maxLines: 1,
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: MyFormField(
                              validator: (value)=>null,
                              hint: "Staff ID",
                              controller: reporterIdController,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      //Details
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
                      //Customer info
                      Row(
                        children: [
                          Expanded(
                            child: MyFormField(
                              validator: (value)=>null,
                              title: "Customer Info (Optional)",
                              hint: "Name",
                              controller: cstNamesController,
                              maxLines: 1,
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: MyFormField(
                              validator: (value)=>null,

                              hint: "ID",
                              controller: cstIDController,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      //Action
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
                      //Is Vodafone Equipment damaged?
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("Is Vodafone Equipment damaged?"),
                          Spacer(),
                          Row(
                            children: [
                              Radio<YesNo>(
                                value: YesNo.Yes,
                                groupValue: incidentData
                                    .selectedOptions["equipmentDamaged"],
                                onChanged: (YesNo? value) {
                                  setState(() {
                                    incidentData.selectedOptions[
                                        "equipmentDamaged"] = value!;
                                  });
                                },
                              ),
                              Text("Yes"),
                            ],
                          ),
                          Row(
                            children: [
                              Radio<YesNo>(
                                value: YesNo.No,
                                groupValue: incidentData
                                    .selectedOptions["equipmentDamaged"],
                                onChanged: (YesNo? value) {
                                  setState(() {
                                    incidentData.selectedOptions[
                                        "equipmentDamaged"] = value!;
                                  });
                                },
                              ),
                              Text("No"),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      //Is Employees / Guard Injured?
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("Is Employees / Guard Injured?"),
                          Spacer(),
                          Row(
                            children: [
                              Radio<YesNo>(
                                value: YesNo.Yes,
                                groupValue: incidentData
                                    .selectedOptions["employeeInjured"],
                                onChanged: (YesNo? value) {
                                  setState(() {
                                    incidentData.selectedOptions[
                                        "employeeInjured"] = value!;
                                  });
                                },
                              ),
                              Text("Yes"),
                            ],
                          ),
                          Row(
                            children: [
                              Radio<YesNo>(
                                value: YesNo.No,
                                groupValue: incidentData
                                    .selectedOptions["employeeInjured"],
                                onChanged: (YesNo? value) {
                                  setState(() {
                                    incidentData.selectedOptions[
                                        "employeeInjured"] = value!;
                                  });
                                },
                              ),
                              Text("No"),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      //External vendor/ Customers/ Visitors injured?
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                              flex: 2,
                              child: Text(
                                  "External vendor/ Customers/ Visitors injured?")),
                          Spacer(),
                          Expanded(
                            flex: 1,
                            child: Row(
                              children: [
                                Radio<YesNo>(
                                  value: YesNo.Yes,
                                  groupValue: incidentData
                                      .selectedOptions["vendorInjured"],
                                  onChanged: (YesNo? value) {
                                    setState(() {
                                      incidentData.selectedOptions[
                                          "vendorInjured"] = value!;
                                    });
                                  },
                                ),
                                Text("Yes"),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Row(
                              children: [
                                Radio<YesNo>(
                                  value: YesNo.No,
                                  groupValue: incidentData
                                      .selectedOptions["vendorInjured"],
                                  onChanged: (YesNo? value) {
                                    setState(() {
                                      incidentData.selectedOptions[
                                          "vendorInjured"] = value!;
                                    });
                                  },
                                ),
                                Text("No"),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      //Intrusion System Alarm Received
                      Row(
                        children: [
                          Flexible(
                            flex: 1,
                            child: Text("Intrusion System Alarm Received"),
                          ),
                          Flexible(
                            flex: 1,
                            child: Row(
                              children: [
                                Radio<YesNo>(
                                  value: YesNo.Yes,
                                  groupValue: incidentData
                                      .selectedOptions["alarmReceived"],
                                  onChanged: (YesNo? value) {
                                    setState(() {
                                      incidentData.selectedOptions[
                                          "alarmReceived"] = value!;
                                    });
                                  },
                                ),
                                Text("Yes"),
                              ],
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            child: Row(
                              children: [
                                Radio<YesNo>(
                                  value: YesNo.No,
                                  groupValue: incidentData
                                      .selectedOptions["alarmReceived"],
                                  onChanged: (YesNo? value) {
                                    setState(() {
                                      incidentData.selectedOptions[
                                          "alarmReceived"] = value!;
                                    });
                                  },
                                ),
                                Text("No"),
                              ],
                            ),
                          ),
                          Flexible(
                            flex: 2,
                            child: Row(
                              children: [
                                Radio<YesNo>(
                                  value: YesNo.Not_Relevant,
                                  groupValue: incidentData
                                      .selectedOptions["alarmReceived"],
                                  onChanged: (YesNo? value) {
                                    setState(() {
                                      incidentData.selectedOptions[
                                          "alarmReceived"] = value!;
                                    });
                                  },
                                ),
                                Text("Not relevant"),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      //Action taken by soc
                      Row(
                        children: [
                          Flexible(
                            flex: 1,
                            child: Text("Action Taken by SOC"),
                          ),
                          Flexible(
                            flex: 1,
                            child: Row(
                              children: [
                                Radio<YesNo>(
                                  value: YesNo.Yes,
                                  groupValue:
                                      incidentData.selectedOptions["actionSoc"],
                                  onChanged: (YesNo? value) {
                                    setState(() {
                                      incidentData
                                              .selectedOptions["actionSoc"] =
                                          value!;
                                    });
                                  },
                                ),
                                Text("Yes"),
                              ],
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            child: Row(
                              children: [
                                Radio<YesNo>(
                                  value: YesNo.No,
                                  groupValue:
                                      incidentData.selectedOptions["actionSoc"],
                                  onChanged: (YesNo? value) {
                                    setState(() {
                                      incidentData
                                              .selectedOptions["actionsoc"] =
                                          value!;
                                    });
                                  },
                                ),
                                Text("No"),
                              ],
                            ),
                          ),
                          Flexible(
                            flex: 2,
                            child: Row(
                              children: [
                                Radio<YesNo>(
                                  value: YesNo.Not_Relevant,
                                  groupValue:
                                      incidentData.selectedOptions["actionSoc"],
                                  onChanged: (YesNo? value) {
                                    setState(() {
                                      incidentData
                                              .selectedOptions["actionSoc"] =
                                          value!;
                                    });
                                  },
                                ),
                                Text("Not relevant"),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(
                        height: 20,
                      ),

                      //Guard existence in location
                      Row(
                        children: [
                          Flexible(
                            flex: 1,
                            child: Text("Guard existence in location"),
                          ),
                          Flexible(
                            flex: 1,
                            child: Row(
                              children: [
                                Radio<YesNo>(
                                  value: YesNo.Yes,
                                  groupValue: incidentData
                                      .selectedOptions["guardExistence"],
                                  onChanged: (YesNo? value) {
                                    setState(() {
                                      incidentData.selectedOptions[
                                          "guardExistence"] = value!;
                                    });
                                  },
                                ),
                                Text("Yes"),
                              ],
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            child: Row(
                              children: [
                                Radio<YesNo>(
                                  value: YesNo.No,
                                  groupValue: incidentData
                                      .selectedOptions["guardExistence"],
                                  onChanged: (YesNo? value) {
                                    setState(() {
                                      incidentData.selectedOptions[
                                          "guardExistence"] = value!;
                                    });
                                  },
                                ),
                                Text("No"),
                              ],
                            ),
                          ),
                          Flexible(
                            flex: 2,
                            child: Row(
                              children: [
                                Radio<YesNo>(
                                  value: YesNo.Not_Relevant,
                                  groupValue: incidentData
                                      .selectedOptions["guardExistence"],
                                  onChanged: (YesNo? value) {
                                    setState(() {
                                      incidentData.selectedOptions[
                                          "guardExistence"] = value!;
                                    });
                                  },
                                ),
                                Text("Not relevant"),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      //Guard attacked

                      Row(
                        children: [
                          Flexible(
                            flex: 1,
                            child: Text("Guard attacked"),
                          ),
                          Flexible(
                            flex: 1,
                            child: Row(
                              children: [
                                Radio<YesNo>(
                                  value: YesNo.Yes,
                                  groupValue: incidentData
                                      .selectedOptions["guardAttacked"],
                                  onChanged: (YesNo? value) {
                                    setState(() {
                                      incidentData.selectedOptions[
                                          "guardAttacked"] = value!;
                                    });
                                  },
                                ),
                                Text("Yes"),
                              ],
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            child: Row(
                              children: [
                                Radio<YesNo>(
                                  value: YesNo.No,
                                  groupValue: incidentData
                                      .selectedOptions["guardAttacked"],
                                  onChanged: (YesNo? value) {
                                    setState(() {
                                      incidentData.selectedOptions[
                                          "guardAttacked"] = value!;
                                    });
                                  },
                                ),
                                Text("No"),
                              ],
                            ),
                          ),
                          Flexible(
                            flex: 2,
                            child: Row(
                              children: [
                                Radio<YesNo>(
                                  value: YesNo.Not_Relevant,
                                  groupValue: incidentData
                                      .selectedOptions["guardAttacked"],
                                  onChanged: (YesNo? value) {
                                    setState(() {
                                      incidentData.selectedOptions[
                                          "guardAttacked"] = value!;
                                    });
                                  },
                                ),
                                Text("Not relevant"),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      //CCTv Camera
                      Row(
                        children: [
                          Flexible(
                            flex: 1,
                            child: Text("CCTV Camera available"),
                          ),
                          Flexible(
                            flex: 1,
                            child: Row(
                              children: [
                                Radio<YesNo>(
                                  value: YesNo.Yes,
                                  groupValue: incidentData
                                      .selectedOptions["cctvAvailable"],
                                  onChanged: (YesNo? value) {
                                    setState(() {
                                      incidentData.selectedOptions[
                                          "cctvAvailable"] = value!;
                                    });
                                  },
                                ),
                                Text("Yes"),
                              ],
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            child: Row(
                              children: [
                                Radio<YesNo>(
                                  value: YesNo.No,
                                  groupValue: incidentData
                                      .selectedOptions["cctvAvailable"],
                                  onChanged: (YesNo? value) {
                                    setState(() {
                                      incidentData.selectedOptions[
                                          "cctvAvailable"] = value!;
                                    });
                                  },
                                ),
                                Text("No"),
                              ],
                            ),
                          ),
                          Flexible(
                            flex: 2,
                            child: Row(
                              children: [
                                Radio<YesNo>(
                                  value: YesNo.Not_Relevant,
                                  groupValue: incidentData
                                      .selectedOptions["cctvAvailable"],
                                  onChanged: (YesNo? value) {
                                    setState(() {
                                      incidentData.selectedOptions[
                                          "cctvAvailable"] = value!;
                                    });
                                  },
                                ),
                                Text("Not relevant"),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      //Legal Notified

                      Row(
                        children: [
                          Flexible(
                            flex: 1,
                            child: Text("Legal Notified"),
                          ),
                          Flexible(
                            flex: 1,
                            child: Row(
                              children: [
                                Radio<YesNo>(
                                  value: YesNo.Yes,
                                  groupValue: incidentData
                                      .selectedOptions["legalNotified"],
                                  onChanged: (YesNo? value) {
                                    setState(() {
                                      incidentData.selectedOptions[
                                          "legalNotified"] = value!;
                                    });
                                  },
                                ),
                                Text("Yes"),
                              ],
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            child: Row(
                              children: [
                                Radio<YesNo>(
                                  value: YesNo.No,
                                  groupValue: incidentData
                                      .selectedOptions["legalNotified"],
                                  onChanged: (YesNo? value) {
                                    setState(() {
                                      incidentData.selectedOptions[
                                          "legalNotified"] = value!;
                                    });
                                  },
                                ),
                                Text("No"),
                              ],
                            ),
                          ),
                          Flexible(
                            flex: 2,
                            child: Row(
                              children: [
                                Radio<YesNo>(
                                  value: YesNo.Not_Relevant,
                                  groupValue: incidentData
                                      .selectedOptions["legalNotified"],
                                  onChanged: (YesNo? value) {
                                    setState(() {
                                      incidentData.selectedOptions[
                                          "legalNotified"] = value!;
                                    });
                                  },
                                ),
                                Text("Not relevant"),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      //Police Report issuance
                      Row(
                        children: [
                          Flexible(
                            flex: 1,
                            child: Text("Police Report issuance"),
                          ),
                          Flexible(
                            flex: 1,
                            child: Row(
                              children: [
                                Radio<YesNo>(
                                  value: YesNo.Yes,
                                  groupValue: incidentData
                                      .selectedOptions["policeReport"],
                                  onChanged: (YesNo? value) {
                                    setState(() {
                                      incidentData
                                              .selectedOptions["policeReport"] =
                                          value!;
                                    });
                                  },
                                ),
                                Text("Yes"),
                              ],
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            child: Row(
                              children: [
                                Radio<YesNo>(
                                  value: YesNo.No,
                                  groupValue: incidentData
                                      .selectedOptions["policeReport"],
                                  onChanged: (YesNo? value) {
                                    setState(() {
                                      incidentData
                                              .selectedOptions["policeReport"] =
                                          value!;
                                    });
                                  },
                                ),
                                Text("No"),
                              ],
                            ),
                          ),
                          Flexible(
                            flex: 2,
                            child: Row(
                              children: [
                                Radio<YesNo>(
                                  value: YesNo.Not_Relevant,
                                  groupValue: incidentData
                                      .selectedOptions["policeReport"],
                                  onChanged: (YesNo? value) {
                                    setState(() {
                                      incidentData
                                              .selectedOptions["policeReport"] =
                                          value!;
                                    });
                                  },
                                ),
                                Text("Not relevant"),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      //LEA Action
                      Row(
                        children: [
                          Flexible(
                            flex: 1,
                            child: Text("LEA Action"),
                          ),
                          Flexible(
                            flex: 1,
                            child: Row(
                              children: [
                                Radio<YesNo>(
                                  value: YesNo.Yes,
                                  groupValue:
                                      incidentData.selectedOptions["leaAction"],
                                  onChanged: (YesNo? value) {
                                    setState(() {
                                      incidentData
                                              .selectedOptions["leaAction"] =
                                          value!;
                                    });
                                  },
                                ),
                                Text("Yes"),
                              ],
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            child: Row(
                              children: [
                                Radio<YesNo>(
                                  value: YesNo.No,
                                  groupValue:
                                      incidentData.selectedOptions["leaAction"],
                                  onChanged: (YesNo? value) {
                                    setState(() {
                                      incidentData
                                              .selectedOptions["leaAction"] =
                                          value!;
                                    });
                                  },
                                ),
                                Text("No"),
                              ],
                            ),
                          ),
                          Flexible(
                            flex: 2,
                            child: Row(
                              children: [
                                Radio<YesNo>(
                                  value: YesNo.Not_Relevant,
                                  groupValue:
                                      incidentData.selectedOptions["leaAction"],
                                  onChanged: (YesNo? value) {
                                    setState(() {
                                      incidentData
                                              .selectedOptions["leaAction"] =
                                          value!;
                                    });
                                  },
                                ),
                                Text("Not relevant"),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),

                      MyFormField(
                        validator: (value)=>null,

                        title: "Police report Number (Optional)",
                        hint: "",
                        controller: policeNuController,
                        maxLines: 1,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      MyFormField(
                        validator: (value)=>null,

                        title: "Guard Attack Details (Optional)",
                        hint: "",
                        controller: guardAttackDController,
                        maxLines: 1,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      //Lea Name
                      MyFormField(
                          validator: (value) => null,
                          showDownMenu: true,
                          controller: leaMemberController,
                          title: ' LEA Member Name (Optional)',
                          maxLines: 1,
                          menuItems: IncidentData.leaMembers),
                      SizedBox(
                        height: 20,
                      ),
                      //Soc Member
                      MyFormField(
                          showDownMenu: true,
                          controller: socMemberController,
                          title: 'Soc Member',
                          maxLines: 1,
                          menuItems: IncidentData.socTeam),
                      SizedBox(
                        height: 20,
                      ),
                      //Closure

                      MyFormField(
                          showDownMenu: true,
                          controller: closureController,
                          title: 'Closure',
                          maxLines: 1,
                          menuItems: IncidentData.closureItems),
                      SizedBox(
                        height: 20,
                      ),
                      _selectedImage != null
                          ? Column(
                              children: [
                                const Text(
                                  "Selected Image:",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 10),
                                Stack(
                                  alignment: Alignment.topRight,
                                  children: [
                                    Image.file(
                                      _selectedImage!,
                                      height: 150,
                                      width: 150,
                                      fit: BoxFit.cover,
                                    ),
                                    IconButton(
                                      onPressed: _removeImage,
                                      icon: const Icon(
                                        Icons.close,
                                        color: Colors.red,
                                      ),
                                      tooltip: "Remove Image",
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : const Text("No Image Selected"),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _pickImage(ImageSource.camera),
                            icon: const Icon(Icons.camera),
                            label: const Text("Camera"),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton.icon(
                            onPressed: () => _pickImage(ImageSource.gallery),
                            icon: const Icon(Icons.photo_library),
                            label: const Text("Gallery"),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      //Share
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                WidgetStateProperty.all(Color(0xFFD32F2F)),
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              IncidentData().share(
                                  cstNamesController,
                                  cstIDController,
                                  locationController,
                                  reporterNameController,
                                  detailsController,
                                  actionController,
                                  closureController,
                                  socMemberController,
                                  leaMemberController,
                                policeNuController,
                                guardAttackDController

                              );
                            }else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Please fill required data"),
                                  duration: Duration(seconds: 3),
                                ),
                              );
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
                      SizedBox(
                        height: 10,
                      ),
                      //Export
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                WidgetStateProperty.all(Color(0xFFD32F2F)),
                          ),
                          onPressed: () {
                            generateWordDocument(
                              imageFile: _selectedImage,
                              date: dateController.text,
                              type: incidentTypeController.text,
                              time: timeController.text,
                              reported: reporterController.text,
                              locationName: locationController.text,
                              address: addressController.text,
                              reporterName: reporterNameController.text,
                              staffId: reporterIdController.text,
                              customerName: cstNamesController.text,
                              customerId: cstIDController.text,
                              socAction: actionController.text,
                              damaged: incidentData
                                  .selectedOptions["equipmentDamaged"]
                                  .toString()
                                  .substring(6),
                              injured: incidentData
                                  .selectedOptions["employeeInjured"]
                                  .toString()
                                  .substring(6),
                              vendor: incidentData
                                  .selectedOptions["vendorInjured"]
                                  .toString()
                                  .substring(6),
                              takenby: incidentData
                                  .selectedOptions["actionSoc"]
                                  .toString()
                                  .substring(6),
                              alarm: incidentData
                                  .selectedOptions["alarmReceived"]
                                  .toString()
                                  .substring(6),
                              guardloc: incidentData
                                  .selectedOptions["guardExistence"]
                                  .toString()
                                  .substring(6),
                              guardatt: incidentData
                                  .selectedOptions["guardAttacked"]
                                  .toString()
                                  .substring(6),
                              cctv: incidentData
                                  .selectedOptions["cctvAvailable"]
                                  .toString()
                                  .substring(6),
                              legal: incidentData
                                  .selectedOptions["legalNotified"]
                                  .toString()
                                  .substring(6),
                              lea: incidentData.selectedOptions["leaAction"]
                                  .toString()
                                  .substring(6),
                              policere: incidentData
                                  .selectedOptions["policeReport"]
                                  .toString()
                                  .substring(6),
                              policenu: policeNuController.text,
                              guardattd: guardAttackDController.text,
                              closure: closureController.text,
                              details: detailsController.text,
                            );
                          },
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.import_export,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 8.0),
                                Text(
                                  'Export',
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
                )),
          ),
        ),
      ),
    );
  }

  Widget buildYesNoRow(String label, String key) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(label)),
        Row(
          children: [
            Radio<YesNo>(
              value: YesNo.Yes,
              groupValue: IncidentData().selectedOptions[key],
              onChanged: (YesNo? value) {
                setState(() {
                  IncidentData().selectedOptions[key] = value!;
                });
              },
            ),
            Text("Yes"),
          ],
        ),
        Row(
          children: [
            Radio<YesNo>(
              value: YesNo.No,
              groupValue: IncidentData().selectedOptions[key],
              onChanged: (YesNo? value) {
                setState(() {
                  IncidentData().selectedOptions[key] = value!;
                });
              },
            ),
            Text("No"),
          ],
        ),
      ],
    );
  }

  Future<void> generateWordDocument({
    required String date,
    required String type,
    required String time,
    File? imageFile,
    required String reported,
    required String locationName,
    required String address,
    required String reporterName,
    required String staffId,
    required String customerName,
    required String customerId,
    required String socAction,
    required String damaged,
    required String injured,
    required String vendor,
    required String takenby,
    required String alarm,
    required String guardloc,
    required String guardatt,
    required String cctv,
    required String legal,
    required String lea,
    required String policere,
    required String policenu,
    required String guardattd,
    required String closure,
    required String details,
  }) async {
    try {
      // Load the template document
      final data = await rootBundle.load('assets/Incident report.docx');
      final bytes = data.buffer.asUint8List();

      // Save the template to a writable directory
      final directory = await getApplicationDocumentsDirectory();
      final fileDoc = File('${directory.path}/Document.docx');
      await fileDoc.writeAsBytes(bytes);

      // Load the document for modification
      final docx = await DocxTemplate.fromBytes(await fileDoc.readAsBytes());

      // Prepare the document content
      Content content = Content()
        ..add(TextContent('date', date))
        ..add(TextContent('type', type))
        ..add(TextContent('time', time))
        ..add(TextContent('reported', reported))
        ..add(TextContent('location name', locationName))
        ..add(TextContent('address', address))
        ..add(TextContent('reporter name', reporterName))
        ..add(TextContent('staff id', staffId))
        ..add(TextContent('customer name', customerName))
        ..add(TextContent('customer id', customerId))
        ..add(TextContent('soc action', 'Case reported to $socAction'))
        ..add(TextContent('damaged', damaged))
        ..add(TextContent('injured', injured))
        ..add(TextContent('vendor', vendor))
        ..add(TextContent('takenby', takenby))
        ..add(TextContent('alarm', alarm))
        ..add(TextContent('guardloc', guardloc))
        ..add(TextContent('guardatt', guardatt))
        ..add(TextContent('cctv', cctv))
        ..add(TextContent('legal', legal))
        ..add(TextContent('lea', lea))
        ..add(TextContent('policere', policere))
        ..add(TextContent('policenu', policenu))
        ..add(TextContent('guardattd', guardattd))
        ..add(TextContent('closure', closure))
        ..add(TextContent('details', details));

      // Check if an image file is selected and exists
      if (imageFile != null && await imageFile.exists()) {
        final imageBytes = await imageFile.readAsBytes();
        if (imageBytes.isNotEmpty) {
          print("Image bytes length: ${imageBytes.length}"); // Debug
          content.add(ImageContent(
              'image', imageBytes)); // Add the image to the content
        } else {
          print("Image file is empty.");
        }
      } else {
        print("No image selected or file doesn't exist.");
      }

      // Generate and save the modified document
      final d = await docx.generate(content);
      if (d == null) {
        throw Exception("Failed to generate document content.");
      }

      // Save the final document in the mobile's accessible Documents folder
      final externalDocumentsDir = Directory('/storage/emulated/0/Documents');

// Ensure the directory exists
      if (!externalDocumentsDir.existsSync()) {
        externalDocumentsDir.createSync(recursive: true);
      }

      final outputFile =
          File('${externalDocumentsDir.path}/Incident report.docx');
      await outputFile.writeAsBytes(d);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('File saved successfully in Documents folder'),
          duration: Duration(seconds: 3),
        ),
      );

      print('Document saved at ${outputFile.path}');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          duration: Duration(seconds: 3),
        ),
      );
      print('Error generating document: $e');
    }
  }
}
