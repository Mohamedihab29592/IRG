import 'dart:io';
import 'package:IRG/features/IRG/presenation/controller/state.dart';
import 'package:docx_template/docx_template.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/constants/enum.dart';
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
  }

  Future<void> _onLoadInitialData(
      LoadInitialDataEvent event,
      Emitter<IncidentState> emit,
      ) async {
    emit(IncidentLoading());
    try {
      final result = await repository.getAllLookupData();
      result.fold(
            (error) {emit(IncidentError(error));
              print(error.toString());} ,
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
      final newSelections = Map<String, YesNo>.from(currentState.radioSelections)
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
          event.imageFile
      );

      // Create a File from the path
      final documentFile = File(outputFilePath);

      // Now send the email with the exported document
      final emailContent = _generateAuditEmailContent(event.formData);
      await _sendViaOutlook(
        subject: 'Incident Report - ${event.formData['locationName']}',
        body: emailContent,
        recipients: [],
        attachment: documentFile,
      );

      // Emit success state

    } catch (e) {
      emit(IncidentError('Failed to share incident report: $e'));
      print(e.toString());
      emit(previousState);

    }
  }

  Content _prepareDocumentContent(Map<String, dynamic> formData, File? imageFile) {

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
      ..add(TextContent('soc action', 'Case reported to ${formData['socAction']}'))
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

    // Save the template to a writable directory
    final directory = await getApplicationDocumentsDirectory();
    final fileDoc = File('${directory.path}/Document.docx');
    await fileDoc.writeAsBytes(bytes);

    // Load the document for modification
    final docx = await DocxTemplate.fromBytes(await fileDoc.readAsBytes());

    // Prepare content
    final content = _prepareDocumentContent(formData, imageFile);

    // Generate document
    final generatedDoc = await docx.generate(content);
    if (generatedDoc == null) {
      throw Exception("Failed to generate document");
    }

    // Save to Documents folder
    final outputDir = Directory('/storage/emulated/0/Documents');
    if (!outputDir.existsSync()) {
      outputDir.createSync(recursive: true);
    }

    final outputFile = File(
        '${outputDir.path}/Incident report - ${formData['locationName']}.docx'
    );
    await outputFile.writeAsBytes(generatedDoc);

    return outputFile.path;
  }

// Keep your existing _onExportDocument method but modify it to use the extracted function
  Future<void> _onExportDocument(
      ExportDocumentEvent event,
      Emitter<IncidentState> emit,
      ) async {
    final previousState = state;

    try {
      final previousState = state;
      if (previousState is! IncidentLoaded) return;

      final outputFilePath = await _exportDocumentAndGetPath(
          event.formData,
          event.imageFile
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

    buffer.writeln('Dears,\n\n   Please check the incident report for: ${formData['locationName']}.\n\nBest Regards\n${formData['socMember']}\nSoc team\n 01002089999');


    return buffer.toString();
  }

  Future<void> _sendViaOutlook({
    required String subject,
    required String body,
    required List<String> recipients,
    File? attachment,
  }) async {
    try {
      final Email email = Email(
        body: body,
        subject: subject,
        recipients: recipients,
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
      ) async {
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
    buffer.writeln('Reporter: ${formData['reporterName']}.\n');
    buffer.writeln('Details: ${formData['details']}.\n');

    // Add optional fields if they exist
    if (formData['customerName']?.isNotEmpty == true &&
        formData['customerId']?.isNotEmpty == true) {
      buffer.writeln('Customer Info:');
      buffer.writeln('Name: ${formData['customerName']}.');
      buffer.writeln('ID: ${formData['customerId']}.\n');
    }

    buffer.writeln('SOC Action: Case reported to ${formData['socAction']}.\n');

    // Add other optional fields
    if (formData['guardAttackDetails']?.isNotEmpty == true) {
      buffer.writeln('Guard Attack Details: ${formData['guardAttackDetails']}.\n');
    }

    if (formData['policeReportNumber']?.isNotEmpty == true) {
      buffer.writeln('Police Report Number: ${formData['policeReportNumber']}.\n');
    }

    if (formData['leaMemberName']?.isNotEmpty == true) {
      buffer.writeln('LEA Member Name: ${formData['leaMemberName']}.\n');
    }

    buffer.writeln('Closure: ${formData['closure']}.\n');
    buffer.writeln('SOC Member: ${formData['socMember']}.\n');

    return buffer.toString();
  }
}