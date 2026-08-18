abstract class Strings {
  const Strings();

  String get pauseTitle;
  String get resume;
  String get settings;
  String get settingsTitle;
  String get shopTitle;
  String get buy;
  String get owned;
  String get perSecond;
  String get language;
  String get itemCheatApartment;
  String get itemLowerTaxes;
  String get itemPrivatizeSchools;
  String get itemPrivatizeHospitals;
}

class SvStrings extends Strings {
  const SvStrings();

  @override
  String get pauseTitle => 'Pausat';
  @override
  String get resume => 'Fortsätt';
  @override
  String get settings => 'Inställningar';
  @override
  String get settingsTitle => 'Inställningar';
  @override
  String get shopTitle => 'Butiken';
  @override
  String get buy => 'Köp';
  @override
  String get owned => 'Ägda';
  @override
  String get perSecond => 'kr/s';
  @override
  String get language => 'Språk';
  @override
  String get itemCheatApartment => 'Fiffla till dig en lägenhet';
  @override
  String get itemLowerTaxes => 'Sänk skatten för de rika';
  @override
  String get itemPrivatizeSchools => 'Privatisera skolorna';
  @override
  String get itemPrivatizeHospitals => 'Privatisera sjukhusen';
}

class EnStrings extends Strings {
  const EnStrings();

  @override
  String get pauseTitle => 'Paused';
  @override
  String get resume => 'Resume';
  @override
  String get settings => 'Settings';
  @override
  String get settingsTitle => 'Settings';
  @override
  String get shopTitle => 'The Shop';
  @override
  String get buy => 'Buy';
  @override
  String get owned => 'Owned';
  @override
  String get perSecond => 'kr/s';
  @override
  String get language => 'Language';
  @override
  String get itemCheatApartment => 'Cheat yourself an apartment';
  @override
  String get itemLowerTaxes => 'Lower taxes for the rich';
  @override
  String get itemPrivatizeSchools => 'Privatize the schools';
  @override
  String get itemPrivatizeHospitals => 'Privatize the hospitals';
}
