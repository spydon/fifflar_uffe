abstract class Strings {
  const Strings();

  String get mainMenuTitle;
  String get mainMenu;
  String get mainMenuNote;
  String get startPlaying;
  String get settings;
  String get sound;
  String get language;
  String get pauseTitle;
  String get resume;
  String get restart;
  String get skillTreeTitle;
  String get buy;
  String get owned;
  String get perSecond;
  String get requiresLabel;
  String get sourceLabel;
  String get priceLabel;
  String get givesLabel;
  String get perClick;
  String get about;
  String get aboutSatire;
  String get aboutAttributions;
  String get aboutOpenSource;
  String get aboutGithub;
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
  List<String> get quipHireCleaner;
  List<String> get quipCheatApartment;
  List<String> get quipTaxiRides;
  List<String> get quipChinaTrips;
  List<String> get quipFurnishPalace;
  List<String> get quipWriteBook;
  List<String> get quipLowerTaxes;
  List<String> get quipBreakPromise;
  List<String> get quipCutSickLeave;
  List<String> get quipPrivatizeSchools;
  List<String> get quipPrivatizeHospitals;
  List<String> get quipSellPreschools;
  List<String> get quipSellPublicHousing;
  String get pokeWarning;
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
  String get brokeCapitalism;
  String get share;
  String get shareTitle;
  String get download;
  String get shareHeadline;
  String get shareTagline;
  String get highscores;
  String get periodAllTime;
  String get periodWeekly;
  String get periodDaily;
  String get highscoreNameHeader;
  String get highscoreScoreHeader;
  String get yourName;
  String get submitExplanation;
  String get nameHint;
  String get submit;
  String get openHighscores;
  String yourBest(String score, int rank);
  String get notRanked;
  String brokenCapitalismCount(int count);
  String gamesPlayed(int count);
  String get loading;
  String get highscoreLoadError;
  String get retry;
  String get submitFailed;
  String get submitTooEarly;
  String get submitAlreadyDone;
  String get submitCooldown;
  String get submitRejected;
  String get invalidName;
  String get emptyLeaderboard;
  String get shopHint;
  String affordHint(String item);
  String get references;
  String voteAppeal(String date);
  String formatDate(DateTime date);
  String formatDayMonth(DateTime date);
}

class SvStrings extends Strings {
  const SvStrings();

  @override
  String get mainMenuTitle => 'Fifflar-Uffe';
  @override
  String get mainMenu => 'Huvudmeny';
  @override
  String get mainMenuNote =>
      "Ett spel tar lite mer än en kvart och går igenom Uffe's fiffel "
      'genom tiderna. Kan du fiffla till dig nog på den tiden?';
  @override
  String get startPlaying => 'Börja fiffla';
  @override
  String get settings => 'Inställningar';
  @override
  String get sound => 'Ljud';
  @override
  String get language => 'Språk';
  @override
  String get pauseTitle => 'Pausat';
  @override
  String get resume => 'Fortsätt';
  @override
  String get restart => 'Börja om';
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
  String get priceLabel => 'Pris';
  @override
  String get givesLabel => 'Ger';
  @override
  String get perClick => 'per klick';
  @override
  String get about => 'Om';
  @override
  String get aboutSatire =>
      'Spelet är satir, men händelserna i spelet bygger på '
      'verklig nyhetsrapportering.';
  @override
  String get aboutAttributions => 'Bildkällor';
  @override
  String get aboutOpenSource =>
      'Spelet är öppen källkod och PRs/issues är varmt välkomna.';
  @override
  String get aboutGithub => 'Källkoden på GitHub';
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
  List<String> get quipHireCleaner => const [
    'Kvitto? Vilket kvitto?',
    'Kontant i ett kuvert, som man gör.',
    'Skatteverket behöver inte veta allt.',
  ];
  @override
  List<String> get quipCheatApartment => const [
    'Bostadskön är till för andra!',
    'Tjugo år i kö? Jag tog hissen.',
    'Det heter kontakter, inte fiffel.',
  ];
  @override
  List<String> get quipTaxiRides => const [
    'Taxametern tickar, notan är er!',
    'Bussen går ju inte dit jag vill.',
    'Kör runt kvarteret en gång till.',
  ];
  @override
  List<String> get quipChinaTrips => const [
    'Studieresa! Typ.',
    'Var tredje månad är man ju tvungen.',
    'Jag studerade mest lunchmenyn.',
  ];
  @override
  List<String> get quipFurnishPalace => const [
    'En trasmatta för 60 000? Fynd!',
    'Konsulten sa att gardinerna var billiga.',
    'Det är ju inte mina pengar.',
  ];
  @override
  List<String> get quipWriteBook => const [
    'Ord är gratis, åsikter är guld!',
    'Kapitel ett: Skyll på någon annan.',
    'Jag har inte läst den själv.',
  ];
  @override
  List<String> get quipLowerTaxes => const [
    'Mina vänner blir så glada!',
    'Det sipprar ner, har jag hört.',
    'Villorna i Danderyd jublar!',
  ];
  @override
  List<String> get quipBreakPromise => const [
    'Aldrig, aldrig, aldrig... nåja.',
    'Löften är bara ord i sändning.',
    'Det var den gamla Uffe som lovade.',
  ];
  @override
  List<String> get quipCutSickLeave => const [
    'Kalendern säger att ni är friska!',
    'Man blir frisk av att vara fattig.',
    'Friskare siffror, i alla fall.',
  ];
  @override
  List<String> get quipPrivatizeSchools => const [
    'Marknaden fixar skolan!',
    'Betyg är gratis om man tar dem från aktieägarna.',
    'Vinst i varje klassrum!',
  ];
  @override
  List<String> get quipPrivatizeHospitals => const [
    'Vård ska bara vara tillgängligt för de rika!',
    'Kön är kortare om man betalar.',
    'Akuten? Den finns i appen.',
  ];
  @override
  List<String> get quipSellPreschools => const [
    'Såld! Långt under marknadspris.',
    'Barnen märker ingen skillnad.',
    'Förskola idag, bostadsrätt imorgon.',
  ];
  @override
  List<String> get quipSellPublicHousing => const [
    'Tack för lägenheten!',
    'Polarna får en hyresrätt var.',
    'Hyran går upp, humöret också!',
  ];
  @override
  String get pokeWarning => "Sluuuuta, jag skickar Jimmie's kompisar på dig!";
  @override
  String get explainHireCleaner =>
      'Kristersson har erkänt att han anlitade svart städhjälp under en '
      'period 2001.';
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
      'Som socialborgarråd reste Kristersson till Kina var tredje månad '
      'under 2007, för 128 000 kronor av skattebetalarnas pengar, utan '
      'tydlig koppling till uppdraget.';
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
      'Vantörs hemtjänst gick för 69 500 kronor (köparna gjorde 9,4 '
      'miljoner i vinst på två år). Regeringsrätten fann att staden bröt '
      'mot kommunallagen.';
  @override
  String get explainSellPublicHousing =>
      'Stockholm sålde Svenska Bostäders 1 200 allmännyttiga lägenheter i '
      'Hjulsta till Einar Mattsson för 600 miljoner kronor 2008. Sjutton år '
      'senare köpte staden tillbaka dem, tillsammans med Hjulsta centrum, '
      'för 1,4 miljarder.';
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
  String get brokeCapitalism => 'Du hade sönder kapitalismen :(';
  @override
  String get share => 'Dela';
  @override
  String get shareTitle => 'Dela ditt resultat';
  @override
  String get download => 'Ladda ner';
  @override
  String get shareHeadline => 'Jag klarade fifflar-uffe.se!';
  @override
  String get shareTagline => 'Nu vet jag hur man blir en riktig fifflare.';
  @override
  String get highscores => 'Topplista';
  @override
  String get periodAllTime => 'Genom tiderna';
  @override
  String get periodWeekly => '7 dagar';
  @override
  String get periodDaily => '24 timmar';
  @override
  String get highscoreNameHeader => 'Namn';
  @override
  String get highscoreScoreHeader => 'Fifflat (totalt)';
  @override
  String get yourName => 'Ditt namn';
  @override
  String get submitExplanation =>
      'Skriv ditt namn och skicka in resultatet till topplistan';
  @override
  String get nameHint => 'Högst 10 tecken';
  @override
  String get submit => 'Skicka';
  @override
  String get openHighscores => 'Till topplistan';
  @override
  String yourBest(String score, int rank) => 'Ditt bästa: $score (plats $rank)';
  @override
  String get notRanked => 'Du finns inte med på topplistan än';
  @override
  String brokenCapitalismCount(int count) =>
      '$count ${count == 1 ? 'person' : 'personer'} '
      'har haft sönder kapitalismen';
  @override
  String gamesPlayed(int count) =>
      '$count ${count == 1 ? 'omgång' : 'omgångar'} har spelats totalt';
  @override
  String get loading => 'Laddar...';
  @override
  String get highscoreLoadError => 'Kunde inte hämta topplistan';
  @override
  String get retry => 'Försök igen';
  @override
  String get submitFailed => 'Det gick inte att skicka in resultatet';
  @override
  String get submitTooEarly => 'Omgången var för kort för att räknas';
  @override
  String get submitAlreadyDone => 'Resultatet är redan inskickat';
  @override
  String get submitCooldown => 'Vänta en stund och försök igen';
  @override
  String get submitRejected => 'Omgången kunde inte verifieras';
  @override
  String get invalidName =>
      '1 till 10 tecken: bokstäver, siffror, mellanslag och . , ! ? - _';
  @override
  String get emptyLeaderboard => 'Ingen har fifflat klart än';
  @override
  String get shopHint => 'Fiffla mer effektivt!';
  @override
  String affordHint(String item) => 'Du har råd med $item!';
  @override
  String get references => 'Referenser';
  @override
  String voteAppeal(String date) =>
      'Den $date är det val, se till att rösta på ett parti som jobbar '
      'för att det ska bli bättre för folket, inte bara för sig själva '
      'och sina vänner/kumpaner.';

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
  String get mainMenuTitle => 'Fifflar-Uffe';
  @override
  String get mainMenu => 'Main menu';
  @override
  String get mainMenuNote =>
      "A game takes a little over fifteen minutes and walks through Uffe's "
      'fiffling through the ages. Can you fiffle enough for yourself in '
      'that time?';
  @override
  String get startPlaying => 'Start fiffling';
  @override
  String get settings => 'Settings';
  @override
  String get sound => 'Sound';
  @override
  String get language => 'Language';
  @override
  String get pauseTitle => 'Paused';
  @override
  String get resume => 'Resume';
  @override
  String get restart => 'Start over';
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
  String get priceLabel => 'Price';
  @override
  String get givesLabel => 'Gives';
  @override
  String get perClick => 'per click';
  @override
  String get about => 'About';
  @override
  String get aboutSatire =>
      'The game is satire, but the events in the game are based '
      'on real news reporting.';
  @override
  String get aboutAttributions => 'Image credits';
  @override
  String get aboutOpenSource =>
      'The game is open source and PRs/issues are very welcome.';
  @override
  String get aboutGithub => 'Source code on GitHub';
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
  List<String> get quipHireCleaner => const [
    'Receipt? What receipt?',
    'Cash in an envelope, the usual way.',
    'The tax office does not need to know everything.',
  ];
  @override
  List<String> get quipCheatApartment => const [
    'Housing queues are for other people!',
    'Twenty years in line? I took the lift.',
    'It is called contacts, not fiddling.',
  ];
  @override
  List<String> get quipTaxiRides => const [
    'The meter is running, the bill is yours!',
    'The bus does not go where I want.',
    'Take another lap around the block.',
  ];
  @override
  List<String> get quipChinaTrips => const [
    'Study trip! Sort of.',
    'Every third month is simply required.',
    'I mostly studied the lunch menu.',
  ];
  @override
  List<String> get quipFurnishPalace => const [
    'A rag rug for 60 000? A steal!',
    'The consultant said the curtains were cheap.',
    'It is not my money anyway.',
  ];
  @override
  List<String> get quipWriteBook => const [
    'Words are free, opinions are gold!',
    'Chapter one: Blame somebody else.',
    'I have not read it myself.',
  ];
  @override
  List<String> get quipLowerTaxes => const [
    'My friends will be so pleased!',
    'It trickles down, I am told.',
    'The villas in Danderyd are cheering!',
  ];
  @override
  List<String> get quipBreakPromise => const [
    'Never, never, never... oh well.',
    'Promises are just words on air.',
    'That was the old Uffe promising.',
  ];
  @override
  List<String> get quipCutSickLeave => const [
    'The calendar says you are healthy!',
    'Being poor cures most things.',
    'Healthier numbers, at least.',
  ];
  @override
  List<String> get quipPrivatizeSchools => const [
    'The market will fix the schools!',
    'Grades are free when the shareholders hand them out.',
    'Profit in every classroom!',
  ];
  @override
  List<String> get quipPrivatizeHospitals => const [
    'Healthcare should only be available to the rich!',
    'The queue is shorter if you pay.',
    'The emergency room? It is in the app.',
  ];
  @override
  List<String> get quipSellPreschools => const [
    'Sold! Well below market value.',
    'The children will not notice.',
    'Preschool today, condos tomorrow.',
  ];
  @override
  List<String> get quipSellPublicHousing => const [
    'Thanks for the apartment!',
    'The boys get a flat each.',
    'Rent goes up, and so does my mood!',
  ];
  @override
  String get pokeWarning => "Stooooop, I'll send Jimmie's buddies after you!";
  @override
  String get explainHireCleaner =>
      'Kristersson has admitted that he paid for cleaning help under the '
      'table for a period in 2001.';
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
      'As social services commissioner, Kristersson traveled to China every '
      'third month during 2007, for 128 000 kronor of taxpayer money, '
      'without a clear connection to his duties.';
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
      'home care went for 69 500 kronor (the buyers made 9.4 million in '
      'profit in two years). The Supreme Administrative Court found the '
      'city broke municipal law.';
  @override
  String get explainSellPublicHousing =>
      "Stockholm sold Svenska Bostäder's 1 200 public housing apartments "
      'in Hjulsta to Einar Mattsson for 600 million kronor in 2008. '
      'Seventeen years later the city bought them back, together with the '
      'Hjulsta center, for 1.4 billion.';
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
  String get brokeCapitalism => 'You broke capitalism :(';
  @override
  String get share => 'Share';
  @override
  String get shareTitle => 'Share your result';
  @override
  String get download => 'Download';
  @override
  String get shareHeadline => 'I completed fifflar-uffe.se!';
  @override
  String get shareTagline => 'Now I know how to be a good fifflare.';
  @override
  String get highscores => 'Highscores';
  @override
  String get periodAllTime => 'All time';
  @override
  String get periodWeekly => '7 days';
  @override
  String get periodDaily => '24 hours';
  @override
  String get highscoreNameHeader => 'Name';
  @override
  String get highscoreScoreHeader => 'Fiddled (total)';
  @override
  String get yourName => 'Your name';
  @override
  String get submitExplanation =>
      'Enter your name and submit your score to the highscores';
  @override
  String get nameHint => 'At most 10 characters';
  @override
  String get submit => 'Submit';
  @override
  String get openHighscores => 'To the highscores';
  @override
  String yourBest(String score, int rank) => 'Your best: $score (place $rank)';
  @override
  String get notRanked => 'You are not on the highscores yet';
  @override
  String brokenCapitalismCount(int count) =>
      '$count ${count == 1 ? 'person has' : 'people have'} broken capitalism';
  @override
  String gamesPlayed(int count) =>
      '$count ${count == 1 ? 'game has' : 'games have'} been played in total';
  @override
  String get loading => 'Loading...';
  @override
  String get highscoreLoadError => 'Could not load the highscores';
  @override
  String get retry => 'Try again';
  @override
  String get submitFailed => 'Could not submit the score';
  @override
  String get submitTooEarly => 'The run was too short to count';
  @override
  String get submitAlreadyDone => 'This score is already submitted';
  @override
  String get submitCooldown => 'Wait a moment and try again';
  @override
  String get submitRejected => 'The run could not be verified';
  @override
  String get invalidName =>
      '1 to 10 characters: letters, digits, spaces and . , ! ? - _';
  @override
  String get emptyLeaderboard => 'Nobody has finished fiddling yet';
  @override
  String get shopHint => 'Fiddle more efficiently!';
  @override
  String affordHint(String item) => 'You can afford $item!';
  @override
  String get references => 'References';
  @override
  String voteAppeal(String date) =>
      'On $date there is an election. Make sure to vote for a party '
      'that works to make things better for the people, not just for '
      'itself and its friends/cronies.';

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
