import 'package:flutter/material.dart';

AppBar AppbarWidget({
  required BuildContext context,
  required TextEditingController typeController,
  required TextEditingController incidentTypeController,
  required TextEditingController locationController,
  required TextEditingController reporterController,
  required TextEditingController reporterNameController,
  required TextEditingController detailsController,
  required TextEditingController cstNamesController,
  required TextEditingController cstIDController,
  required TextEditingController actionController,
  required TextEditingController closureController,
  required TextEditingController socMemberController,
  required TextEditingController addressController,
  required TextEditingController reporterIdController,
  required TextEditingController leaMemberController,
  required TextEditingController dateController,
  required TextEditingController timeController,
  required TextEditingController policeNuController,
  required TextEditingController guardAttackDController,
}) {
  return AppBar(
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
            reporterNameController.clear();
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
          },
          child: Text(
            "Clear",
            style: TextStyle(color: Colors.black, fontSize: 18),
          ))
    ],
  );
}
