import 'package:meta/meta.dart';

/// A logged vaccination dose for a child. [givenOn] is the date administered;
/// [note] holds optional detail (dose number, brand, clinic).
@immutable
class Vaccination {
  const Vaccination({
    this.id,
    required this.childId,
    required this.name,
    required this.givenOn,
    this.note,
  });

  final int? id;
  final int childId;
  final String name;
  final DateTime givenOn;
  final String? note;
}

/// Common early-childhood immunisations offered as one-tap suggestions. Names
/// are kept generic (schedules vary by country), so the parent records what
/// their own clinic actually gave.
const List<String> kVaccineSuggestions = [
  '6-in-1 (DTaP/IPV/Hib/HepB)',
  'Rotavirus',
  'MenB',
  'Pneumococcal (PCV)',
  'Hib/MenC',
  'MMR',
  'Flu',
  'Hepatitis B',
  'Chickenpox (Varicella)',
  'COVID-19',
];
