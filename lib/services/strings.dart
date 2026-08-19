abstract class Strings {
  const Strings();

  String get pauseTitle;
  String get resume;
  String get settings;
  String get settingsTitle;
  String get skillTreeTitle;
  String get buy;
  String get owned;
  String get perSecond;
  String get requiresLabel;
  String get sourceLabel;
  String get language;
  String get about;
  String get aboutSatire;
  String get aboutAttributions;
  String get itemHireCleaner;
  String get itemCheatApartment;
  String get itemTaxiRides;
  String get itemChinaTrips;
  String get itemFurnishPalace;
  String get itemWriteBook;
  String get itemLowerTaxes;
  String get itemBreakPromise;
  String get itemCutSickLeave;
  String get itemPrivatizeSchools;
  String get itemPrivatizeHospitals;
  String get itemSellPreschools;
  String get itemSellPublicHousing;
  String get quipHireCleaner;
  String get quipCheatApartment;
  String get quipTaxiRides;
  String get quipChinaTrips;
  String get quipFurnishPalace;
  String get quipWriteBook;
  String get quipLowerTaxes;
  String get quipBreakPromise;
  String get quipCutSickLeave;
  String get quipPrivatizeSchools;
  String get quipPrivatizeHospitals;
  String get quipSellPreschools;
  String get quipSellPublicHousing;
  String get explainHireCleaner;
  String get explainCheatApartment;
  String get explainTaxiRides;
  String get explainChinaTrips;
  String get explainFurnishPalace;
  String get explainWriteBook;
  String get explainLowerTaxes;
  String get explainBreakPromise;
  String get explainCutSickLeave;
  String get explainPrivatizeSchools;
  String get explainPrivatizeHospitals;
  String get explainSellPreschools;
  String get explainSellPublicHousing;
  String get gameOverTitle;
  String get finalScore;
  String get highScoreLabel;
  String get playAgain;
  String get continuePlaying;
  String get shopHint;
  String get references;
  String voteAppeal(String date);
  String formatDate(DateTime date);
  String formatDayMonth(DateTime date);
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
  String get skillTreeTitle => 'Fifflarträdet';
  @override
  String get buy => 'Köp';
  @override
  String get owned => 'Ägda';
  @override
  String get perSecond => 'kr/s';
  @override
  String get requiresLabel => 'Kräver';
  @override
  String get sourceLabel => 'Källa';
  @override
  String get language => 'Språk';
  @override
  String get about => 'Om';
  @override
  String get aboutSatire =>
      'Spelet är satir, men händelserna i spelet bygger på '
      'verklig nyhetsrapportering.';
  @override
  String get aboutAttributions => 'Attributioner';
  @override
  String get itemHireCleaner => 'Anlita städhjälp (svart)';
  @override
  String get itemCheatApartment => 'Fiffla till dig en lägenhet';
  @override
  String get itemTaxiRides => 'Taxa på skattebetalarna';
  @override
  String get itemChinaTrips => 'Studieresor till Kina';
  @override
  String get itemFurnishPalace => 'Lyxrenovera Sagerska';
  @override
  String get itemWriteBook => 'Skriv en stridsskrift';
  @override
  String get itemLowerTaxes => 'Sänk skatten för de rika';
  @override
  String get itemBreakPromise => 'Bryt löftet';
  @override
  String get itemCutSickLeave => 'Utförsäkra de sjuka';
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
  String get quipTaxiRides => 'Taxametern tickar, notan är er!';
  @override
  String get quipChinaTrips => 'Studieresa! Typ.';
  @override
  String get quipFurnishPalace => 'En trasmatta för 60 000? Fynd!';
  @override
  String get quipWriteBook => 'Ord är gratis, åsikter är guld!';
  @override
  String get quipLowerTaxes => 'Mina vänner blir så glada!';
  @override
  String get quipBreakPromise => 'Aldrig, aldrig, aldrig... nåja.';
  @override
  String get quipCutSickLeave => 'Kalendern säger att ni är friska!';
  @override
  String get quipPrivatizeSchools => 'Marknaden fixar skolan!';
  @override
  String get quipPrivatizeHospitals => 'Vårdköer? Inte för mig!';
  @override
  String get quipSellPreschools => 'Såld! Långt under marknadspris.';
  @override
  String get quipSellPublicHousing => 'Tack för lägenheten!';
  @override
  String get explainHireCleaner =>
      'Kristersson har erkänt att han anlitade svart städhjälp under sex '
      'månader 2001, för 70 till 80 kronor i timmen.';
  @override
  String get explainCheatApartment =>
      'Som socialborgarråd fick Kristersson en attraktiv hyresrätt förbi '
      'Stockholms bostadskö, via vd:n för Einar Mattsson, samma bolag som '
      'staden tidigare sålt allmännyttiga lägenheter till.';
  @override
  String get explainTaxiRides =>
      'TV4 avslöjade 2017 att Kristersson tagit 668 taxiresor för 113 000 '
      'kronor av skattemedel på två år.';
  @override
  String get explainChinaTrips =>
      'Som socialborgarråd gjorde Kristersson tre resor till Kina på ett år '
      'för 128 000 kronor av skattebetalarnas pengar, utan tydlig koppling '
      'till uppdraget.';
  @override
  String get explainFurnishPalace =>
      'Efter regeringsskiftet 2022 möblerades statsministerns tjänstebostad '
      'Sagerska huset för runt en halv miljon kronor av skattemedel, med '
      'bland annat en specialbeställd trasmatta för 60 000 kronor och en '
      'köksmatta som med konsultarvoden gick på 27 400 kronor.';
  @override
  String get explainWriteBook =>
      'I boken Non-working generation från 1994 jämförde Kristersson den '
      'svenska modellen med apartheid, och i Generationskriget kallade han '
      '40-talisterna för Homo bidragus.';
  @override
  String get explainLowerTaxes =>
      'Moderaternas skattesänkningar, från jobbskatteavdragen till den '
      'slopade värnskatten, har gynnat höginkomsttagare mest.';
  @override
  String get explainBreakPromise =>
      'Inför valet 2018 lovade Kristersson förintelseöverlevaren Hédi Fried '
      'att aldrig samarbeta med Sverigedemokraterna. Efter valet 2022 '
      'byggde han sin regering på Tidöavtalet med SD.';
  @override
  String get explainCutSickLeave =>
      'Som socialförsäkringsminister försvarade Kristersson stupstocken i '
      'sjukförsäkringen, tidsgränsen som gjorde att runt 100 000 '
      'långtidssjuka blev utförsäkrade. De flesta blev snart sjukskrivna '
      'igen enligt Inspektionen för socialförsäkringen.';
  @override
  String get explainPrivatizeSchools =>
      'Friskolereformen och skolpengen har gjort Sverige till ett av världens '
      'få länder där skolor får drivas med vinst, med skolkoncerner som '
      'plockar ut miljoner ur skattefinansierad skola.';
  @override
  String get explainPrivatizeHospitals =>
      'S:t Görans sjukhus såldes 1999 av det borgerligt styrda landstinget '
      'till Bure, i dag Capio, och blev Sveriges första privata akutsjukhus. '
      'Revisorerna slog fast att affären bröt mot upphandlingslagen.';
  @override
  String get explainSellPreschools =>
      'Under avknoppningarna 2007 till 2008 sålde moderatledda Stockholm '
      'förskolor och hemtjänst till personal långt under marknadsvärdet. '
      'Vantörs hemtjänst gick för 69 500 kronor, och köparna gjorde '
      'miljonvinst inom ett år. Domstol fann att staden bröt mot lagen.';
  @override
  String get explainSellPublicHousing =>
      'Stockholm sålde över tusen allmännyttiga lägenheter till Einar '
      'Mattsson för 6 600 kronor per kvadratmeter, långt under marknadspris.';
  @override
  String get gameOverTitle => 'Nu är det slutfifflat, Uffe!';
  @override
  String get finalScore => 'Slutresultat';
  @override
  String get highScoreLabel => 'Rekord';
  @override
  String get playAgain => 'Fiffla igen';
  @override
  String get continuePlaying => 'Fortsätt fiffla';
  @override
  String get shopHint => 'Fiffla mer effektivt!';
  @override
  String get references => 'Referenser';
  @override
  String voteAppeal(String date) =>
      'Den $date är det val, se till att rösta på ett parti som jobbar '
      'för att det ska bli bättre för folket, inte bara för sig själv '
      'och sina vänner.';

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

  static const _fullMonths = [
    'januari',
    'februari',
    'mars',
    'april',
    'maj',
    'juni',
    'juli',
    'augusti',
    'september',
    'oktober',
    'november',
    'december',
  ];

  @override
  String formatDate(DateTime date) =>
      '${date.day} ${_months[date.month - 1]} ${date.year}';

  @override
  String formatDayMonth(DateTime date) =>
      '${date.day} ${_fullMonths[date.month - 1]}';
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
  String get skillTreeTitle => 'The Fiddle Tree';
  @override
  String get buy => 'Buy';
  @override
  String get owned => 'Owned';
  @override
  String get perSecond => 'kr/s';
  @override
  String get requiresLabel => 'Requires';
  @override
  String get sourceLabel => 'Source';
  @override
  String get language => 'Language';
  @override
  String get about => 'About';
  @override
  String get aboutSatire =>
      'The game is satire, but the events in the game are based '
      'on real news reporting.';
  @override
  String get aboutAttributions => 'Attributions';
  @override
  String get itemHireCleaner => 'Hire cleaning help (off the books)';
  @override
  String get itemCheatApartment => 'Cheat yourself an apartment';
  @override
  String get itemTaxiRides => 'Taxi on the taxpayers';
  @override
  String get itemChinaTrips => 'Study trips to China';
  @override
  String get itemFurnishPalace => 'Refurnish the palace';
  @override
  String get itemWriteBook => 'Write a polemic';
  @override
  String get itemLowerTaxes => 'Lower taxes for the rich';
  @override
  String get itemBreakPromise => 'Break the promise';
  @override
  String get itemCutSickLeave => 'Cut off the sick';
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
  String get quipTaxiRides => 'The meter is running, the bill is yours!';
  @override
  String get quipChinaTrips => 'Study trip! Sort of.';
  @override
  String get quipFurnishPalace => 'A rag rug for 60 000? A steal!';
  @override
  String get quipWriteBook => 'Words are free, opinions are gold!';
  @override
  String get quipLowerTaxes => 'My friends will be so pleased!';
  @override
  String get quipBreakPromise => 'Never, never, never... oh well.';
  @override
  String get quipCutSickLeave => 'The calendar says you are healthy!';
  @override
  String get quipPrivatizeSchools => 'The market will fix the schools!';
  @override
  String get quipPrivatizeHospitals => 'Care queues? Not for me!';
  @override
  String get quipSellPreschools => 'Sold! Well below market value.';
  @override
  String get quipSellPublicHousing => 'Thanks for the apartment!';
  @override
  String get explainHireCleaner =>
      'Kristersson has admitted that he paid for cleaning help under the '
      'table for six months in 2001, at 70 to 80 kronor an hour.';
  @override
  String get explainCheatApartment =>
      'As social services commissioner, Kristersson received an attractive '
      'rental apartment past the Stockholm housing queue, through the chief '
      'executive of Einar Mattsson, the same company the city had earlier '
      'sold public housing to.';
  @override
  String get explainTaxiRides =>
      'In 2017, TV4 revealed that Kristersson had taken 668 taxi rides for '
      '113 000 kronor of taxpayer money over two years.';
  @override
  String get explainChinaTrips =>
      'As social services commissioner, Kristersson made three trips to '
      'China in one year for 128 000 kronor of taxpayer money, without a '
      'clear connection to his duties.';
  @override
  String get explainFurnishPalace =>
      'After the 2022 change of government, the official residence Sager '
      'House was furnished for about half a million kronor of taxpayer '
      'money, including a custom rag rug for 60 000 kronor and a kitchen '
      'mat that with consultant fees came to 27 400 kronor.';
  @override
  String get explainWriteBook =>
      'In the 1994 book Non-working generation, Kristersson compared the '
      'Swedish model to apartheid, and in Generationskriget he called the '
      'generation born in the forties Homo bidragus.';
  @override
  String get explainLowerTaxes =>
      'The Moderate tax cuts, from the earned income tax credits to the '
      'abolished surtax, have benefited high earners the most.';
  @override
  String get explainBreakPromise =>
      'Before the 2018 election, Kristersson promised Holocaust survivor '
      'Hédi Fried never to cooperate with the Sweden Democrats. After the '
      '2022 election he built his government on the Tidö Agreement with '
      'that very party.';
  @override
  String get explainCutSickLeave =>
      'As social insurance minister, Kristersson defended the hard time '
      'limit in the sickness insurance that cut off around 100 000 '
      'long-term sick people. Most of them were soon on sick leave again, '
      'according to the Social Insurance Inspectorate.';
  @override
  String get explainPrivatizeSchools =>
      'The free school reform and voucher system have made Sweden one of '
      'the few countries in the world where schools can be run for profit, '
      'with school corporations extracting millions from tax-funded '
      'education.';
  @override
  String get explainPrivatizeHospitals =>
      'S:t Göran hospital was sold in 1999 by the conservative-led county '
      "council to Bure, today Capio, becoming Sweden's first private "
      'emergency hospital. The auditors found the deal broke procurement '
      'law.';
  @override
  String get explainSellPreschools =>
      'During the 2007 to 2008 spin-offs, Moderate-led Stockholm sold '
      'preschools and home care to staff far below market value. Vantör '
      'home care went for 69 500 kronor, and the buyers made millions in '
      'profit within a year. A court found the city broke the law.';
  @override
  String get explainSellPublicHousing =>
      'Stockholm sold over a thousand public housing apartments to Einar '
      'Mattsson for 6 600 kronor per square meter, far below market price.';
  @override
  String get gameOverTitle => 'The fiddling is over, Uffe!';
  @override
  String get finalScore => 'Final score';
  @override
  String get highScoreLabel => 'High score';
  @override
  String get playAgain => 'Fiddle again';
  @override
  String get continuePlaying => 'Keep fiddling';
  @override
  String get shopHint => 'Fiddle more efficiently!';
  @override
  String get references => 'References';
  @override
  String voteAppeal(String date) =>
      'On $date there is an election. Make sure to vote for a party '
      'that works to make things better for the people, not just for '
      'itself and its friends.';

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

  static const _fullMonths = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  String formatDate(DateTime date) =>
      '${_months[date.month - 1]} ${date.day}, ${date.year}';

  @override
  String formatDayMonth(DateTime date) =>
      '${_fullMonths[date.month - 1]} ${date.day}';
}
