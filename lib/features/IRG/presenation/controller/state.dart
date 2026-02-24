import '../../../../core/constants/enum.dart';
import '../../data/Model/lookup_data_model.dart';

abstract class IncidentState {}

class IncidentInitial extends IncidentState {}

class IncidentLoading extends IncidentState {}

class IncidentLoaded extends IncidentState {
  final LookupDataModel lookupData;
  final Map<String, dynamic> formData;
  final Map<String, YesNo> radioSelections;
  final List<dynamic> locationFilterItems;
  final String? translatedText;
  final String? errorMessage;
  final bool isTranslating;

  IncidentLoaded({
    required this.lookupData,
    required this.formData,
    required this.radioSelections,
    required this.locationFilterItems,
    this.translatedText,
    this.errorMessage,
    this.isTranslating = false,
  });

  IncidentLoaded copyWith({
    LookupDataModel? lookupData,
    Map<String, dynamic>? formData,
    Map<String, YesNo>? radioSelections,
    List<dynamic>? locationFilterItems,
    String? translatedText,
    String? errorMessage,
    bool? isTranslating,
    bool clearTranslatedText = false,
  }) {
    return IncidentLoaded(
      lookupData: lookupData ?? this.lookupData,
      formData: formData ?? this.formData,
      radioSelections: radioSelections ?? this.radioSelections,
      locationFilterItems: locationFilterItems ?? this.locationFilterItems,
      translatedText: clearTranslatedText ? null : (translatedText ?? this.translatedText),
      isTranslating: isTranslating ?? this.isTranslating,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class IncidentError extends IncidentState {
  final String message;
  IncidentError(this.message);
}

class DocumentExported extends IncidentState {
  final String path;
  DocumentExported(this.path);
}






