import 'dart:async';
import 'dart:io';
import 'package:IRG/core/constants/enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../controller/bloc.dart';
import '../../controller/events.dart';
import '../../controller/state.dart';
import 'appBar.dart';
import 'buttons.dart';
import 'my_form_field.dart';



class IncidentReportForm extends StatefulWidget {
  @override
  State<IncidentReportForm> createState() => _IncidentReportFormState();
}

var incidentTypeController = TextEditingController();
var typeController = TextEditingController();
var locationController = TextEditingController();
var addressController = TextEditingController();
var reporterController = TextEditingController();
var reporterNameController = TextEditingController();
var reporterIdController = TextEditingController();
var detailsController = TextEditingController();
var detailsArabicController = TextEditingController();
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

class _IncidentReportFormState extends State<IncidentReportForm> {
  final _formKey = GlobalKey<FormState>();
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

  void _translateArabicToEnglish() {
    if (detailsArabicController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please enter Arabic text to translate"),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }


    // Trigger translation immediately
    context.read<IncidentBloc>().add(
      TranslateDetailsEvent(
        text: detailsArabicController.text,
        isFromArabic: true,
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<IncidentBloc, IncidentState>(
      listener: (context, state) {
        if (state is IncidentLoaded && state.translatedText != null) {
          if (detailsArabicController.text.isNotEmpty) {
            detailsController.text = state.translatedText!;
          }
        }

       else if(state is IncidentError)
        {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(state.message)),
          );        }
        else if (state is DocumentExported) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('File saved successfully in ${state.path}')),
          );
        }
      },
      builder: (context, state) {

        return   PopScope(
            canPop: false,
            child: SafeArea(
              child:
              Scaffold(
                appBar: AppbarWidget(
                  context: context,
                  typeController: typeController,
                  incidentTypeController: incidentTypeController,
                  locationController: locationController,
                  reporterController: reporterController,
                  reporterNameController: reporterNameController,
                  detailsController: detailsController,
                  detailsArabicController: detailsArabicController,
                  cstNamesController: cstNamesController,
                  cstIDController: cstIDController,
                  actionController: actionController,
                  closureController: closureController,
                  socMemberController: socMemberController,
                  addressController: addressController,
                  reporterIdController: reporterIdController,
                  leaMemberController: leaMemberController,
                  dateController: dateController,
                  timeController: timeController,
                  policeNuController: policeNuController,
                  guardAttackDController: guardAttackDController,
                ),
                body:  (state is IncidentLoaded) ? _buildForm(context, state) :Center(child: CircularProgressIndicator.adaptive(),),



              ),
            )


        );
      },
    );
  }

  // Your existing UI building methods, modified to use BLoC
  Widget _buildForm(BuildContext context, IncidentLoaded state) {
    String? selectedLocationType;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              //Location type
              MyFormField(
                validator: (value) => null,
                hint: "",
                showDownMenu: true,
                controller: incidentTypeController,
                title: 'Incident Type (Optional)',
                menuItems: state.lookupData.incidentTypes,
              ),
              SizedBox(height: 20),

              //Date
              MyFormField(
                validator: (value) => null,
                controller: dateController,
                title: 'Incident Date (Optional)',
                hint: "Select date",
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
                validator: (value) => null,
                controller: timeController,
                title: 'Incident Time (Optional)',
                hint: "Select time",
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
                onTap: () {
                context.read<IncidentBloc>().add(
                        UpdateLocationTypeEvent(typeController.text),
                      );
                },
                isReadonly: true,
                hint: "Choose from the list",
                showDownMenu: true,
                controller: typeController,
                title: 'Incident Location',
                menuItems: state.lookupData.locationTypes,
                onDependentValueChanged: (value) {
                  setState(() {
                    selectedLocationType = value;
                  });

                },
              ),
              SizedBox(
                height: 20,
              ),
              //Location Name
              MyFormField(
                showDownMenu: true,
                controller: locationController,
                title: 'Location name',
                menuItems: state.locationFilterItems,
                dependentValue: selectedLocationType,
              ),
              SizedBox(
                height: 20,
              ),
              //Address
              MyFormField(
                validator: (value) {
                  if(typeController.text.contains('Truck') && value!.isEmpty)
                    {
                      return "* Required";
                    }
                  else {
                    return null;
                  }
                },
                title: "Address",
                hint: "",
                controller: addressController,
              ),

              SizedBox(
                height: 20,
              ),
              MyFormField(
                title: "Reported by",
                hint: "Full Name",
                controller: reporterNameController,
              ),
              SizedBox(
                height: 20,
              ),
              //Reporter
              Row(
                children: [
                  Expanded(
                    child: MyFormField(
                      validator: (value) => null,
                      title: "Reporter Info (Optional)",
                      hint: "Name",
                      controller: reporterController,
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: MyFormField(
                      textType: TextInputType.number,

                      validator: (value) => null,
                      hint: "Staff ID",
                      controller: reporterIdController,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              //Arabic Details for Share only
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyFormField(
                    enableSpellCheck: true,
                    controller: detailsArabicController,
                    title: 'Details in Arabic (share only)',
                    hint: 'اكتب التفاصيل بالعربية',
                    validator: (value) => null,
                    onChange: (value) {
                     setState(() {

                     });
                    },
                  ),

                  SizedBox(height: 10),

                  // Translate Button
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: detailsArabicController.text.isNotEmpty && !state.isTranslating
                            ? () => _translateArabicToEnglish()
                            : null,
                        icon: state.isTranslating
                            ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                            : Icon(Icons.translate),
                        label: Text(state.isTranslating ? 'Translating...' : 'Translate to English'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      // Clear buttonjl hg
                      TextButton.icon(
                        onPressed: detailsArabicController.text.isNotEmpty
                            ? () {
                          setState(() {
                            detailsArabicController.clear();
                            detailsController.clear();
                          });
                        }
                            : null,
                        icon: Icon(Icons.clear),
                        label: Text('Clear'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                    ],
                  ),

                  if (state.isTranslating)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Please wait while translating...',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              //Details
              MyFormField(
                validator: (value) => null, // Optional field
                enableSpellCheck: true,
                controller: detailsController,
                title: ' Details',


              ),
              SizedBox(
                height: 20,
              ),
              //Customer info
              Row(
                children: [
                  Expanded(
                    child: MyFormField(
                      validator: (value) => null,
                      title: "Customer Info (Optional)",
                      hint: "Name",
                      controller: cstNamesController,
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: MyFormField(
                      textType: TextInputType.number,
                      validator: (value) => null,
                      hint: "ID",
                      controller: cstIDController,
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
                menuItems: state.lookupData.actionItems,
              ),
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
                        groupValue: state.radioSelections["equipmentDamaged"],
                        onChanged: (YesNo? value) {
                          context.read<IncidentBloc>().add(UpdateRadioSelectionEvent("equipmentDamaged", value!));

                        },
                      ),
                      Text("Yes"),
                    ],
                  ),
                  Row(
                    children: [
                      Radio<YesNo>(
                        value: YesNo.No,
                        groupValue: state.radioSelections["equipmentDamaged"],
                        onChanged: (YesNo? value) {
                          context.read<IncidentBloc>().add(UpdateRadioSelectionEvent("equipmentDamaged", value!));

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
                        groupValue: state.radioSelections["employeeInjured"],
                        onChanged: (YesNo? value) {

                          context.read<IncidentBloc>().add(UpdateRadioSelectionEvent("employeeInjured", value!));

                        },
                      ),
                      Text("Yes"),
                    ],
                  ),
                  Row(
                    children: [
                      Radio<YesNo>(
                        value: YesNo.No,
                        groupValue: state.radioSelections["employeeInjured"],
                        onChanged: (YesNo? value) {

                          context.read<IncidentBloc>().add(UpdateRadioSelectionEvent("employeeInjured", value!));

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
                          "External vendor/Customers/Visitors injured?")),
                  Spacer(),
                  Expanded(
                    flex: 1,
                    child: Row(
                      children: [
                        Radio<YesNo>(
                          value: YesNo.Yes,
                          groupValue: state.radioSelections["vendorInjured"],
                          onChanged: (YesNo? value) {
                            context.read<IncidentBloc>().add(UpdateRadioSelectionEvent("vendorInjured", value!));

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
                          groupValue: state.radioSelections["vendorInjured"],
                          onChanged: (YesNo? value) {
                            context.read<IncidentBloc>().add(UpdateRadioSelectionEvent("vendorInjured", value!));

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
                          groupValue: state.radioSelections["alarmReceived"],
                          onChanged: (YesNo? value) {
                            context.read<IncidentBloc>().add(UpdateRadioSelectionEvent("alarmReceived", value!));

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
                          groupValue: state.radioSelections["alarmReceived"],
                          onChanged: (YesNo? value) {
                            context.read<IncidentBloc>().add(UpdateRadioSelectionEvent("alarmReceived", value!));

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
                          groupValue: state.radioSelections["alarmReceived"],
                          onChanged: (YesNo? value) {
                            context.read<IncidentBloc>().add(UpdateRadioSelectionEvent("alarmReceived", value!));

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
                          groupValue: state.radioSelections["actionSoc"],
                          onChanged: (YesNo? value) {
                            context.read<IncidentBloc>().add(UpdateRadioSelectionEvent("actionSoc", value!));

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
                          groupValue: state.radioSelections["actionSoc"],
                          onChanged: (YesNo? value) {
                            context.read<IncidentBloc>().add(UpdateRadioSelectionEvent("actionSoc", value!));

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
                          groupValue: state.radioSelections["actionSoc"],
                          onChanged: (YesNo? value) {
                            context.read<IncidentBloc>().add(UpdateRadioSelectionEvent("actionSoc", value!));

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
                          groupValue: state.radioSelections["guardExistence"],
                          onChanged: (YesNo? value) {
                            context.read<IncidentBloc>().add(UpdateRadioSelectionEvent("guardExistence", value!));

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
                          groupValue: state.radioSelections["guardExistence"],
                          onChanged: (YesNo? value) {
                            context.read<IncidentBloc>().add(UpdateRadioSelectionEvent("guardExistence", value!));

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
                          groupValue: state.radioSelections["guardExistence"],
                          onChanged: (YesNo? value) {
                            context.read<IncidentBloc>().add(UpdateRadioSelectionEvent("guardExistence", value!));

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
                          groupValue: state.radioSelections["guardAttacked"],
                          onChanged: (YesNo? value) {
                            context.read<IncidentBloc>().add(UpdateRadioSelectionEvent("guardAttacked", value!));

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
                          groupValue: state.radioSelections["guardAttacked"],
                          onChanged: (YesNo? value) {
                            context.read<IncidentBloc>().add(UpdateRadioSelectionEvent("guardAttacked", value!));

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
                          groupValue: state.radioSelections["guardAttacked"],
                          onChanged: (YesNo? value) {
                            context.read<IncidentBloc>().add(UpdateRadioSelectionEvent("guardAttacked", value!));

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
                          groupValue: state.radioSelections["cctvAvailable"],
                          onChanged: (YesNo? value) {
                            context.read<IncidentBloc>().add(UpdateRadioSelectionEvent("cctvAvailable", value!));

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
                          groupValue: state.radioSelections["cctvAvailable"],
                          onChanged: (YesNo? value) {
                            context.read<IncidentBloc>().add(UpdateRadioSelectionEvent("cctvAvailable", value!));

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
                          groupValue: state.radioSelections["cctvAvailable"],
                          onChanged: (YesNo? value) {
                            context.read<IncidentBloc>().add(UpdateRadioSelectionEvent("cctvAvailable", value!));

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
                          groupValue: state.radioSelections["legalNotified"],
                          onChanged: (YesNo? value) {
                            context.read<IncidentBloc>().add(UpdateRadioSelectionEvent("legalNotified", value!));

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
                          groupValue: state.radioSelections["legalNotified"],
                          onChanged: (YesNo? value) {
                            context.read<IncidentBloc>().add(UpdateRadioSelectionEvent("legalNotified", value!));

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
                          groupValue: state.radioSelections["legalNotified"],
                          onChanged: (YesNo? value) {
                            context.read<IncidentBloc>().add(UpdateRadioSelectionEvent("legalNotified", value!));

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
                          groupValue: state.radioSelections["policeReport"],
                          onChanged: (YesNo? value) {
                            context.read<IncidentBloc>().add(UpdateRadioSelectionEvent("policeReport", value!));

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
                          groupValue: state.radioSelections["policeReport"],
                          onChanged: (YesNo? value) {
                            context.read<IncidentBloc>().add(UpdateRadioSelectionEvent("policeReport", value!));

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
                          groupValue: state.radioSelections["policeReport"],
                          onChanged: (YesNo? value) {
                            context.read<IncidentBloc>().add(UpdateRadioSelectionEvent("policeReport", value!));

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
                          groupValue:state.radioSelections["leaAction"],
                          onChanged: (YesNo? value) {
                            context.read<IncidentBloc>().add(UpdateRadioSelectionEvent("leaAction", value!));

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
                          groupValue: state.radioSelections["leaAction"],
                          onChanged: (YesNo? value) {
                            context.read<IncidentBloc>().add(UpdateRadioSelectionEvent("leaAction", value!));

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
                          groupValue: state.radioSelections["leaAction"],
                          onChanged: (YesNo? value) {
                            context.read<IncidentBloc>().add(UpdateRadioSelectionEvent("leaAction", value!));

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
                validator: (value) => null,
                title: "Police report Number (Optional)",
                hint: "",
                controller: policeNuController,
              ),
              SizedBox(
                height: 20,
              ),
              MyFormField(
                enableSpellCheck: true,

                validator: (value) => null,
                title: "Guard Attack Details (Optional)",
                hint: "",
                controller: guardAttackDController,
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
                  menuItems: state.lookupData.leaMembers),
              SizedBox(
                height: 20,
              ),
              //Soc Member
              MyFormField(
                  showDownMenu: true,
                  controller: socMemberController,
                  title: 'Soc Member',
                  menuItems: state.lookupData.socTeam),
              SizedBox(
                height: 20,
              ),
              //Closure

              MyFormField(
                  enableSpellCheck: true,

                  showDownMenu: true,
                  controller: closureController,
                  title: 'Closure',
                  menuItems: state.lookupData.closureStatus),
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
              Button(
                onPressed: () {
                if (_formKey.currentState!.validate()) {
                  if ((typeController.text.toLowerCase() == 'truck' ||
                      typeController.text.toLowerCase().contains('truck')) &&
                      addressController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            "Address is required for truck locations"),
                        duration: Duration(seconds: 3),
                      ),
                    );
                    return;
                  }
                  context
                      .read<IncidentBloc>()
                      .add(ShareReportEvent(formData: {
                    'customerName': cstNamesController.text,
                    'customerId': cstIDController.text,
                    'locationName': locationController.text,
                    'address': addressController.text,
                    'reporterName': reporterNameController.text,
                    'details': detailsArabicController.text.isNotEmpty
                        ? detailsArabicController.text
                        : detailsController.text,
                    'socAction': actionController.text,
                    'closure': closureController.text,
                    'socMember': socMemberController.text,
                    'leaMemberName': leaMemberController.text,
                    'policeReportNumber': policeNuController.text,
                    'guardAttackDetails': guardAttackDController.text
                  }));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Please fill required data"),
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              }, title: 'Share', icon:  Icons.share,),


              SizedBox(
                height: 10,
              ),
              //Export
              Button(onPressed: () {
                if(_formKey.currentState!.validate())
                {
                  context.read<IncidentBloc>().add(ExportDocumentEvent(
                    formData: {
                      "date": dateController.text,
                      "type": incidentTypeController.text,
                      "time": timeController.text,
                      "reported": reporterController.text,
                      "locationName": locationController.text,
                      "address": addressController.text,
                      "reporterName": reporterNameController.text,
                      "staffId": reporterIdController.text,
                      "customerName": cstNamesController.text,
                      "customerId": cstIDController.text,
                      "details": detailsController.text,
                      "socAction": actionController.text,
                      "damaged": state.radioSelections[
                      "equipmentDamaged"].toString().substring(6),
                      "injured": state.radioSelections["employeeInjured"].toString().substring(6),
                      "vendor": state.radioSelections["vendorInjured"].toString().substring(6),
                      "takenby": state.radioSelections["actionSoc"].toString().substring(6),
                      "alarm": state.radioSelections["alarmReceived"].toString().substring(6),
                      "guardloc": state.radioSelections["guardExistence"].toString().substring(6),
                      "guardatt": state.radioSelections["guardAttacked"].toString().substring(6),
                      "cctv": state.radioSelections["cctvAvailable"].toString().substring(6),
                      "legal": state.radioSelections["legalNotified"].toString().substring(6),
                      "lea": state.radioSelections["leaAction"].toString().substring(6),
                      "policere": state.radioSelections["policeReport"].toString().substring(6),
                      "policenu": policeNuController.text,
                      "guardattd": guardAttackDController.text,
                      "closure": closureController.text,

                    },
                    imageFile: _selectedImage,
                  ));

                }
                else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please fill required data"),
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              }, title: 'Export', icon:  Icons.import_export,),
              SizedBox(
                height: 10,
              ),
              Button(onPressed: () {
                if(_formKey.currentState!.validate())
                {
                  context.read<IncidentBloc>().add(SendReportEvent(
                    formData: {
                      'socMember': socMemberController.text,
                      'locationType': typeController.text,
                      "date": dateController.text,
                      "type": incidentTypeController.text,
                      "time": timeController.text,
                      "reported": reporterController.text,
                      "locationName": locationController.text,
                      "address": addressController.text,
                      "reporterName": reporterNameController.text,
                      "staffId": reporterIdController.text,
                      "customerName": cstNamesController.text,
                      "customerId": cstIDController.text,
                      "details": detailsController.text,
                      "socAction": actionController.text,
                      "damaged": state.radioSelections[
                      "equipmentDamaged"].toString().substring(6),
                      "injured": state.radioSelections["employeeInjured"].toString().substring(6),
                      "vendor": state.radioSelections["vendorInjured"].toString().substring(6),
                      "takenby": state.radioSelections["actionSoc"].toString().substring(6),
                      "alarm": state.radioSelections["alarmReceived"].toString().substring(6),
                      "guardloc": state.radioSelections["guardExistence"].toString().substring(6),
                      "guardatt": state.radioSelections["guardAttacked"].toString().substring(6),
                      "cctv": state.radioSelections["cctvAvailable"].toString().substring(6),
                      "legal": state.radioSelections["legalNotified"].toString().substring(6),
                      "lea": state.radioSelections["leaAction"].toString().substring(6),
                      "policere": state.radioSelections["policeReport"].toString().substring(6),
                      "policenu": policeNuController.text,
                      "guardattd": guardAttackDController.text,
                      "closure": closureController.text,

                    },
                    imageFile: _selectedImage,

                  ));

                }
                else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please fill required data"),
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              }, title: 'Export & Send Report', icon:  Icons.email,),

            ],
          ),
        ),
      ),
    );
  }

// Add other UI building methods...
}
