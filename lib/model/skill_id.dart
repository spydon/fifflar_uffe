import 'package:fifflar_uffe/util/snake_case.dart';

enum SkillId {
  hireCleaner,
  cheatApartment,
  taxiRides,
  chinaTrips,
  furnishPalace,
  writeBook,
  lowerTaxes,
  breakPromise,
  cutSickLeave,
  privatizeSchools,
  privatizeHospitals,
  sellPreschools,
  sellPublicHousing;

  static SkillId? fromSnakeCase(String key) {
    for (final id in values) {
      if (id.snakeCaseName == key) {
        return id;
      }
    }
    return null;
  }
}
