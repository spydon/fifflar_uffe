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
  String get about;
  String get aboutSatire;
  String get aboutAttributions;
  String get aboutPhotoCredit;
  String get aboutPhotoSource;
  String get aboutBackgroundCredit;
  String get aboutBackgroundSource;
  String get itemHireCleaner;
  String get itemCheatApartment;
  String get itemLowerTaxes;
  String get itemPrivatizeSchools;
  String get itemPrivatizeHospitals;
  String get itemSellPreschools;
  String get itemSellPublicHousing;
  String get quipHireCleaner;
  String get quipCheatApartment;
  String get quipLowerTaxes;
  String get quipPrivatizeSchools;
  String get quipPrivatizeHospitals;
  String get quipSellPreschools;
  String get quipSellPublicHousing;
  String get gameOverTitle;
  String get finalScore;
  String get highScoreLabel;
  String get playAgain;
  String formatDate(DateTime date);
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
  String get about => 'Om';
  @override
  String get aboutSatire =>
      'Det här spelet är satir. Allt innehåll är påhittat och '
      'ska inte tolkas som påståenden om verkliga personer '
      'eller händelser.';
  @override
  String get aboutAttributions => 'Attributioner';
  @override
  String get aboutPhotoCredit =>
      'Foto på Uffe: "3N8A3989" av Stenbocki maja, '
      'CC BY 4.0 (bearbetat).';
  @override
  String get aboutPhotoSource => 'flickr.com/photos/170170135@N07/55170292775';
  @override
  String get aboutBackgroundCredit =>
      'Bakgrund: "Inside Parliament of Sweden 10" av Suyash Dwivedi, '
      'CC BY-SA 4.0 (bearbetad).';
  @override
  String get aboutBackgroundSource =>
      'commons.wikimedia.org/wiki/File:Inside_Parliament_of_Sweden_10.jpg';
  @override
  String get itemHireCleaner => 'Anlita städhjälp (svart)';
  @override
  String get itemCheatApartment => 'Fiffla till dig en lägenhet';
  @override
  String get itemLowerTaxes => 'Sänk skatten för de rika';
  @override
  String get itemPrivatizeSchools => 'Privatisera skolorna';
  @override
  String get itemPrivatizeHospitals => 'Privatisera sjukhusen';
  @override
  String get itemSellPreschools => 'Rea ut förskolorna';
  @override
  String get itemSellPublicHousing => 'Sälj allmännyttan till kompispris';
  @override
  String get quipHireCleaner => 'Kvitto? Vilket kvitto?';
  @override
  String get quipCheatApartment => 'Bostadskön är till för andra!';
  @override
  String get quipLowerTaxes => 'Mina vänner blir så glada!';
  @override
  String get quipPrivatizeSchools => 'Marknaden fixar skolan!';
  @override
  String get quipPrivatizeHospitals => 'Vårdköer? Inte för mig!';
  @override
  String get quipSellPreschools => 'Såld! Långt under marknadspris.';
  @override
  String get quipSellPublicHousing => 'Tack för lägenheten!';
  @override
  String get gameOverTitle => 'Nu är det slutfifflat!';
  @override
  String get finalScore => 'Slutresultat';
  @override
  String get highScoreLabel => 'Rekord';
  @override
  String get playAgain => 'Fiffla igen';

  static const _months = [
    'jan',
    'feb',
    'mar',
    'apr',
    'maj',
    'jun',
    'jul',
    'aug',
    'sep',
    'okt',
    'nov',
    'dec',
  ];

  @override
  String formatDate(DateTime date) =>
      '${date.day} ${_months[date.month - 1]} ${date.year}';
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
  String get about => 'About';
  @override
  String get aboutSatire =>
      'This game is satire. All content is fictional and '
      'should not be read as claims about real people '
      'or events.';
  @override
  String get aboutAttributions => 'Attributions';
  @override
  String get aboutPhotoCredit =>
      'Photo of Uffe: "3N8A3989" by Stenbocki maja, '
      'CC BY 4.0 (modified).';
  @override
  String get aboutPhotoSource => 'flickr.com/photos/170170135@N07/55170292775';
  @override
  String get aboutBackgroundCredit =>
      'Background: "Inside Parliament of Sweden 10" by Suyash Dwivedi, '
      'CC BY-SA 4.0 (modified).';
  @override
  String get aboutBackgroundSource =>
      'commons.wikimedia.org/wiki/File:Inside_Parliament_of_Sweden_10.jpg';
  @override
  String get itemHireCleaner => 'Hire cleaning help (off the books)';
  @override
  String get itemCheatApartment => 'Cheat yourself an apartment';
  @override
  String get itemLowerTaxes => 'Lower taxes for the rich';
  @override
  String get itemPrivatizeSchools => 'Privatize the schools';
  @override
  String get itemPrivatizeHospitals => 'Privatize the hospitals';
  @override
  String get itemSellPreschools => 'Fire-sale the preschools';
  @override
  String get itemSellPublicHousing => 'Sell public housing to a pal';
  @override
  String get quipHireCleaner => 'Receipt? What receipt?';
  @override
  String get quipCheatApartment => 'Housing queues are for other people!';
  @override
  String get quipLowerTaxes => 'My friends will be so pleased!';
  @override
  String get quipPrivatizeSchools => 'The market will fix the schools!';
  @override
  String get quipPrivatizeHospitals => 'Care queues? Not for me!';
  @override
  String get quipSellPreschools => 'Sold! Well below market value.';
  @override
  String get quipSellPublicHousing => 'Thanks for the apartment!';
  @override
  String get gameOverTitle => 'The fiddling is over!';
  @override
  String get finalScore => 'Final score';
  @override
  String get highScoreLabel => 'High score';
  @override
  String get playAgain => 'Fiddle again';

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  @override
  String formatDate(DateTime date) =>
      '${_months[date.month - 1]} ${date.day}, ${date.year}';
}
