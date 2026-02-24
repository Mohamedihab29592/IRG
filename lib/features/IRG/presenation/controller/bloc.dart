import 'dart:async';
import 'dart:io';
import 'package:IRG/features/IRG/presenation/controller/state.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:docx_template/docx_template.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/constants/enum.dart';
import '../../../../core/services/translate.dart';
import '../../data/Model/lookup_model.dart';
import '../../domain/repo.dart';
import 'events.dart';

class IncidentBloc extends Bloc<IncidentEvent, IncidentState> {
  final IncidentRepository repository;

  IncidentBloc({required this.repository}) : super(IncidentInitial()) {
    on<LoadInitialDataEvent>(_onLoadInitialData);
    on<UpdateIncidentTypeEvent>(_onUpdateIncidentType);
    on<UpdateLocationTypeEvent>(_onUpdateLocationType);
    on<UpdateRadioSelectionEvent>(_onUpdateRadioSelection);
    on<ExportDocumentEvent>(_onExportDocument);
    on<ShareReportEvent>(_onShareReport);
    on<SendReportEvent>(_onSendEmail);
    on<SendReportYourSelfEvent>(_onSendEmailYourSelf);
    on<TranslateDetailsEvent>(_onTranslateDetails);
    on<ClearTranslatedTextEvent>(_onClearTranslatedText);

  }

  Future<void> _onLoadInitialData(
    LoadInitialDataEvent event,
    Emitter<IncidentState> emit,
  ) async {
    emit(IncidentLoading());
    try {
      final result = await repository.getAllLookupData();
      result.fold(
        (error) {
          emit(IncidentError(error));
          print(error.toString());
        },
        (data) => emit(IncidentLoaded(
          lookupData: data,
          formData: {},
          radioSelections: _getDefaultRadioSelections(),
          locationFilterItems: [],
        )),
      );
    } catch (e) {
      emit(IncidentError('Failed to load initial data: $e'));
    }
  }

  Map<String, YesNo> _getDefaultRadioSelections() {
    return {
      'equipmentDamaged': YesNo.No,
      'employeeInjured': YesNo.No,
      'vendorInjured': YesNo.No,
      'alarmReceived': YesNo.Not_Relevant,
      'actionSoc': YesNo.Yes,
      'guardExistence': YesNo.Yes,
      'guardAttacked': YesNo.No,
      'cctvAvailable': YesNo.Yes,
      'legalNotified': YesNo.No,
      'healthNotified': YesNo.No,
      'policeReport': YesNo.No,
      'leaAction': YesNo.Yes,
    };
  }

  void _onUpdateIncidentType(
    UpdateIncidentTypeEvent event,
    Emitter<IncidentState> emit,
  ) {
    if (state is IncidentLoaded) {
      final currentState = state as IncidentLoaded;
      final newFormData = Map<String, dynamic>.from(currentState.formData)
        ..['incidentType'] = event.incidentType;
      emit(currentState.copyWith(formData: newFormData));
    }
  }

  void _onUpdateLocationType(
    UpdateLocationTypeEvent event,
    Emitter<IncidentState> emit,
  ) async {
    print('Updating location type to: ${event.locationType}');

    final result = await repository.getLocationsByType(event.locationType);

    result.fold(
      (error) {
        print('Error getting locations: $error');
        emit(IncidentError(error));
      },
      (locationList) {
        print('Got locations: ${locationList.map((l) => l.name).toList()}');
        // Update state
        if (state is IncidentLoaded) {
          final currentState = state as IncidentLoaded;
          emit(currentState.copyWith(
            locationFilterItems: locationList,
          ));
        }
      },
    );
  }

  void _onUpdateRadioSelection(
    UpdateRadioSelectionEvent event,
    Emitter<IncidentState> emit,
  ) {
    if (state is IncidentLoaded) {
      final currentState = state as IncidentLoaded;
      final newSelections =
          Map<String, YesNo>.from(currentState.radioSelections)
            ..[event.key] = event.value;
      emit(currentState.copyWith(radioSelections: newSelections));
    }
  }

  Future<void> _onSendEmail(
    SendReportEvent event,
    Emitter<IncidentState> emit,
  ) async {
    final previousState = state;

    try {
      // First, export the document
      final outputFilePath = await _exportDocumentAndGetPath(
        event.formData,
        event.imageFile,
      );

      // Create a File from the path
      final documentFile = File(outputFilePath);

      // Determine recipients and CC based on locationName
      List<String> recipients = [];
      List<String> ccRecipients = [];

      final String locationTypes = event.formData['locationType'];
      final String? leaName = event.formData['leaMemberName'];
      final String? legalNotified = event.formData['legal'];
      final String? health = event.formData['health'];
      // Define LEA member email mapping
      final Map<String, String> leaMemberEmails = {
        'Akram Ali': 'akram.ali@vodafone.com.eg',
        'Ahmed ElDesouky': 'ahmed.eldesouky@vodafone.com.eg',
        'Ahmed Aly': 'Ahmed.Hussien-ElDeeb@vodafone.com.eg',
        'Mohamed Mansy': 'mohamed.mansy@vodafone.com.eg',
        'Momen Sayed': 'momen.sayed@vodafone.com.eg',
        'Tarek El Nagar': 'tarek.elnaggar@vodafone.com.eg',
      };

      if (locationTypes == 'Express' || locationTypes == 'Franchise') {
        recipients = [
          'RetailPartnershipManagementRelationTeam@vodafone.com.eg'
        ];
        ccRecipients = [
          'tarek.raslan@vodafone.com.eg',
          'mohamed.aboul-ezz@vodafone.com.eg',
          'saad.el-moselhy@vodafone.com.eg',
          'amr.elkhateeb@vodafone.com.eg',
          'amr.abdelaziz@vodafone.com.eg'
        ];
      }
      if (locationTypes == 'Truck') {
        recipients = [
          'RetailPartnershipManagementRelationTeam@vodafone.com.eg'
        ];
        ccRecipients = [
          'tarek.raslan@vodafone.com.eg',
          'mohamed.aboul-ezz@vodafone.com.eg',
          'saad.el-moselhy@vodafone.com.eg',
          'amr.elkhateeb@vodafone.com.eg',
          'amr.abdelaziz@vodafone.com.eg',
          'Tamer.Badawy@vodafone.com.eg'
        ];
      } else if (locationTypes == 'Owned') {
        recipients = [
          'tarek.raslan@vodafone.com.eg',
          'mohamed.aboul-ezz@vodafone.com.eg'
        ];
        ccRecipients = [
          'saad.el-moselhy@vodafone.com.eg',
          'amr.elkhateeb@vodafone.com.eg',
          'amr.abdelaziz@vodafone.com.eg'
        ];
      } else if (locationTypes == 'Building' ||
          locationTypes == 'Switch' ||
          locationTypes == 'Warehouse' ||
          locationTypes == 'Apartment') {
        recipients = [
          'tarek.raslan@vodafone.com.eg',
          'mohamed.aboul-ezz@vodafone.com.eg'
        ];
        ccRecipients = ['kamel.okko@vodafone.com.eg'];
      }

      if (leaName != null || leaName!.isNotEmpty) {
        final leaEmail = leaMemberEmails[leaName];
        print(leaEmail);

        if (leaEmail != null) {
          print(leaEmail);

          ccRecipients.add(leaEmail);
        }
      }

      if (legalNotified == 'Yes') {
        ccRecipients.add('Tamer.Wahba@vodafone.com.eg');
      }
      if (health == 'Yes') {
        ccRecipients.add("Health.Safety@vodafone.com.eg");
      }

      // Generate email content
      final emailContent = _generateAuditEmailContent(event.formData);
      // Send email
      await _sendViaOutlook(
        subject: 'Incident Report - ${event.formData['locationName']}',
        body: emailContent,
        recipients: recipients,
        ccRecipients: ccRecipients,
        attachment: documentFile,
      );

      // Emit success state if needed
    } catch (e) {
      emit(IncidentError('Failed to share incident report: $e'));
      print(e.toString());
      emit(previousState);
    }
  }

  Future<void> _onSendEmailYourSelf(
    SendReportYourSelfEvent event,
    Emitter<IncidentState> emit,
  ) async {
    final previousState = state;

    try {
      // First, export the document
      final outputFilePath = await _exportDocumentAndGetPath(
        event.formData,
        event.imageFile,
      );

      // Create a File from the path
      final documentFile = File(outputFilePath);

      // Determine recipients and CC based on locationName
      List<String> recipients = [];

      final String memberName = event.formData['socMember'];
      final Map<String, String>? socEmails = {
        'Mohamed Abo Elez': 'mohamed.aboul-ezz@vodafone.com.eg',
        'Ahmed Hamdy': 'ahmed.hamdyali1@vodafone.com.eg',
        'Mohamed Ihab': 'mohamed.ehabahmed2@vodafone.com.eg',
        'Mustafa Taha': 'mostafa.tahahassan1@vodafone.com.eg',
        'Karim Abo Ela': 'Karim.AbolEla@vodafone.com.eg',
        'Hady Khalifa': 'Hady.Sayed-Ibrahim@vodafone.com.eg',
      };

      final socEmail = socEmails![memberName];
      recipients.add(socEmail!);

      // Generate email content
      final emailContent = _generateAuditEmailContent(event.formData);

      // Send email
      await _sendViaOutlook(
        subject: 'Incident Report - ${event.formData['locationName']}',
        body: emailContent,
        recipients: recipients,
        ccRecipients: [],
        attachment: documentFile,
      );

      // Emit success state if needed
    } catch (e) {
      emit(IncidentError('Failed to share incident report: $e'));
      print(e.toString());
      emit(previousState);
    }
  }

  Content _prepareDocumentContent(
      Map<String, dynamic> formData, File? imageFile) {
    final socAction = formData['socAction'] ?? '';
    final menuItems = formData['menuItems'] as List<LookupModel>?;
    final isFromMenu = _isMenuSelection(socAction, menuItems);
    final socActionText = isFromMenu
        ? 'Case reported to $socAction'
        : socAction;
    Content content = Content()
      ..add(TextContent('date', formData['date']))
      ..add(TextContent('type', formData['type']))
      ..add(TextContent('time', formData['time']))
      ..add(TextContent('reported', formData['reported']))
      ..add(TextContent('location name', formData['locationName']))
      ..add(TextContent('address', formData['address']))
      ..add(TextContent('reporter name', formData['reporterName']))
      ..add(TextContent('staff id', formData['staffId']))
      ..add(TextContent('customer name', formData['customerName']))
      ..add(TextContent('customer id', formData['customerId']))
      ..add(TextContent('soc action', socActionText))
      ..add(TextContent('damaged', formData['damaged']))
      ..add(TextContent('injured', formData['injured']))
      ..add(TextContent('vendor', formData['vendor']))
      ..add(TextContent('takenby', formData['takenby']))
      ..add(TextContent('alarm', formData['alarm']))
      ..add(TextContent('guardloc', formData['guardloc']))
      ..add(TextContent('guardatt', formData['guardatt']))
      ..add(TextContent('cctv', formData['cctv']))
      ..add(TextContent('legal', formData['legal']))
      ..add(TextContent('lea', formData['lea']))
      ..add(TextContent('policere', formData['policere']))
      ..add(TextContent('policenu', formData['policenu']))
      ..add(TextContent('guardattd', formData['guardattd']))
      ..add(TextContent('closure', formData['closure']))
      ..add(TextContent('details', formData['details']));

    // Add image if available
    if (imageFile != null && imageFile.existsSync()) {
      final imageBytes = imageFile.readAsBytesSync();
      if (imageBytes.isNotEmpty) {
        content.add(ImageContent('image', imageBytes));
      }
    }

    return content;
  }

// This function extracts the document exporting logic from _onExportDocument
  Future<String> _exportDocumentAndGetPath(
      Map<String, dynamic> formData,
      File? imageFile,
      ) async {
    final data = await rootBundle.load('assets/Incident report.docx');
    final bytes = data.buffer.asUint8List();

    final directory = await getApplicationDocumentsDirectory();
    final fileDoc = File('${directory.path}/Document.docx');
    await fileDoc.writeAsBytes(bytes);

    final docx = await DocxTemplate.fromBytes(await fileDoc.readAsBytes());
    final content = _prepareDocumentContent(formData, imageFile);
    final generatedDoc = await docx.generate(content);

    if (generatedDoc == null) {
      throw Exception("Failed to generate document");
    }

    // ✅ Use Downloads folder via MediaStore (Android 10+) or fallback
    final outputPath = await _getSavePath(formData['locationName']);
    final outputFile = File(outputPath);
    await outputFile.writeAsBytes(generatedDoc);

    // ✅ Make file visible in file manager
    await _makeFileVisible(outputPath);

    return outputPath;
  }

  Future<String> _getSavePath(String locationName) async {
    final sanitizedName = locationName.replaceAll(RegExp(r'[^\w\s-]'), '');
    final fileName = 'Incident report - $sanitizedName.docx';

    if (Platform.isAndroid) {
      // ✅ Android 10+ safe path
      final directory = await getExternalStorageDirectory();
      if (directory != null) {
        return '${directory.path}/$fileName';
      }
    }

    // ✅ Fallback for iOS or if external storage unavailable
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$fileName';
  }

// ✅ Make file visible in file manager on Android
  Future<void> _makeFileVisible(String filePath) async {
    if (Platform.isAndroid) {
      try {
        final result = await const MethodChannel('com.example.irg/media_scanner')
            .invokeMethod('scanFile', {'path': filePath});
        print('Media scan result: $result');
      } catch (e) {
        print('Media scanner not available: $e');
        // Not critical — file is still saved
      }
    }
  }

// Keep your existing _onExportDocument method but modify it to use the extracted function
  Future<void> _onExportDocument(
      ExportDocumentEvent event,
      Emitter<IncidentState> emit,
      ) async {
    final previousState = state;
    try {
      if (previousState is! IncidentLoaded) return;

      // ✅ Request storage permission on Android < 10
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        if (androidInfo.version.sdkInt <= 29) {
          final status = await Permission.storage.request();
          if (!status.isGranted) {
            emit(IncidentError('Storage permission denied'));
            emit(previousState);
            return;
          }
        }
      }

      final outputFilePath = await _exportDocumentAndGetPath(
        event.formData,
        event.imageFile,
      );

      emit(DocumentExported(outputFilePath));
      emit(previousState);
    } catch (e) {
      print(e.toString());
      emit(IncidentError('Failed to export document: $e'));
      emit(previousState);
    }
  }

  String _generateAuditEmailContent(Map<String, dynamic> formData) {
    final buffer = StringBuffer();

    buffer.writeln(
        'Dears,\n\n   Please check the incident report for: ${formData['locationName']}.\n\nBest Regards\n${formData['socMember']}');

    return buffer.toString();
  }

  Future<void> _sendViaOutlook({
    required String subject,
    required String body,
    required List<String> recipients,
    required List<String> ccRecipients,
    File? attachment,
  }) async {
    try {
      final Email email = Email(
        body: body,
        subject: subject,
        recipients: recipients,
        cc: ccRecipients,
        attachmentPaths: attachment != null ? [attachment.path] : [],
        isHTML: false,
      );

      await FlutterEmailSender.send(email);
    } catch (e) {
      throw Exception('Failed to send email: $e');
    }
  }

  Future<void> _onShareReport(
    ShareReportEvent event,
    Emitter<IncidentState> emit,
  ) async
  {
    try {
      final text = _generateShareText(event.formData);
      await Share.share(text);
    } catch (e) {
      emit(IncidentError('Failed to share report: $e'));
    }
  }

  String _generateShareText(Map<String, dynamic> formData) {
    final buffer = StringBuffer();

    // Add required fields
    buffer.writeln('Incident Location: ${formData['locationName']}.\n');

    if (formData['address']?.isNotEmpty == true) {
      buffer.writeln('Address: ${formData['address']}.\n');
    }
    buffer.writeln('Reporter: ${formData['reporterName']}.\n');
    buffer.writeln('Details: ${formData['details']}.\n');

    // Add optional fields if they exist
    if (formData['customerName']?.isNotEmpty == true &&
        formData['customerId']?.isNotEmpty == true) {
      buffer.writeln('Customer Info:');
      buffer.writeln('Name: ${formData['customerName']}.');
      buffer.writeln('ID: ${formData['customerId']}.\n');
    }

    final socAction = formData['socAction'] ?? '';
    if (socAction.isNotEmpty) {
      final isFromMenu = _isMenuSelection(socAction, formData['menuItems']);
      if (isFromMenu) {
        buffer.writeln('SOC Action: Case reported to $socAction.\n');
      } else {
        buffer.writeln('SOC Action: $socAction.\n');
      }
    }
    // Add other optional fields
    if (formData['guardAttackDetails']?.isNotEmpty == true) {
      buffer.writeln(
          'Guard Attack Details: ${formData['guardAttackDetails']}.\n');
    }

    if (formData['policeReportNumber']?.isNotEmpty == true) {
      buffer.writeln(
          'Police Report Number: ${formData['policeReportNumber']}.\n');
    }

    if (formData['leaMemberName']?.isNotEmpty == true) {
      buffer.writeln('LEA Member Name: ${formData['leaMemberName']}.\n');
    }

    buffer.writeln('Closure: ${formData['closure']}.\n');
    buffer.writeln('SOC Member: ${formData['socMember']}.\n');

    return buffer.toString();
  }
  bool _isMenuSelection(String value, List<LookupModel>? menuItems) {
    if (menuItems == null || menuItems.isEmpty) return false;
    final parts = value.split(',').map((e) => e.trim());
    final menuNames = menuItems.map((e) => e.name).toSet();
    return parts.every((part) => menuNames.contains(part));
  }
  Future<void> _onTranslateDetails(
      TranslateDetailsEvent event,
      Emitter<IncidentState> emit,
      ) async {
    if (state is IncidentLoaded) {
      final currentState = state as IncidentLoaded;
      emit(currentState.copyWith(isTranslating: true, errorMessage: null));

      try {
        final translation = await TranslationService.translateText(
          text: event.text,
          sourceLang: 'ar',
          targetLang: 'en',
        );

        if (translation.trim().isEmpty) {
          emit(currentState.copyWith(
            isTranslating: false,
            errorMessage: 'Translation returned empty. Please try again.',
          ));
          return;
        }

        emit(currentState.copyWith(
          translatedText: translation,
          isTranslating: false,
          errorMessage: null,
        ));
      } on TimeoutException {
        emit(currentState.copyWith(
          isTranslating: false,
          errorMessage: 'Translation timed out. Please check your connection.',
        ));
      } catch (e) {
        emit(currentState.copyWith(
          isTranslating: false,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ));
      }
    }
  }

  void _onClearTranslatedText(
      ClearTranslatedTextEvent event,
      Emitter<IncidentState> emit,
      ) {
    if (state is IncidentLoaded) {
      final currentState = state as IncidentLoaded;
      emit(currentState.copyWith(clearTranslatedText: true)); // ✅ explicitly nullify
    }
  }
}
