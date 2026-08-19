enum SkillId {
  hireCleaner('hire_cleaner'),
  cheatApartment('cheat_apartment'),
  taxiRides('taxi_rides'),
  chinaTrips('china_trips'),
  furnishPalace('furnish_palace'),
  writeBook('write_book'),
  lowerTaxes('lower_taxes'),
  breakPromise('break_promise'),
  cutSickLeave('cut_sick_leave'),
  privatizeSchools('privatize_schools'),
  privatizeHospitals('privatize_hospitals'),
  sellPreschools('sell_preschools'),
  sellPublicHousing('sell_public_housing');

  const SkillId(this.storageKey);

  final String storageKey;

  static SkillId? fromStorageKey(String key) {
    for (final id in values) {
      if (id.storageKey == key) {
        return id;
      }
    }
    return null;
  }
}
