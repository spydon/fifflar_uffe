<p align="center">
  <img src="assets/images/uffe_head.png" alt="Uffe" width="400">
</p>

<h1 align="center">Fifflar-Uffe</h1>

Fifflar-Uffe is a satirical cookie clicker about a certain Swedish prime
minister maximizing his money. Click the coins bouncing around the chamber
of the Riksdag, unlock fiffel in a skill tree where every purchase is based
on a documented scandal, and watch real news events tick by on a timeline
that runs from the year 2000 until election day on 13 September 2026. When
the election arrives, the fiddling is over.

**Play it at [fifflar-uffe.se](https://fifflar-uffe.se)**

The game is satire, but the events in it are based on real news reporting:

- [References](https://fifflar-uffe.se/references) lists every in-game
  event with a link to a news source.
- [Image credits](https://fifflar-uffe.se/attributions) lists the sources
  and licenses of the photos used in the game.

## Features

- A skill tree of documented scandals, each with an explanation and a
  source link, split into a personal branch, an ideology branch that
  multiplies your coin clicks, and a privatization branch.
- A news feed of real events that pops up as the in-game date passes them.
- Uffe himself in the corner, flapping his head South Park style and
  commenting on every purchase.
- Swedish by default with English one flag tap away.
- Progress saved locally, with a persistent high score across runs.
- An online top ten list with a counter of everyone who broke capitalism,
  hidden automatically when the backend cannot be reached.
- Responsive layouts for both desktop and phones.

## Development

The game is built with [Flame](https://flame-engine.org) using the Flame
Component System, targeting Flutter web and Android.

```sh
flutter pub get
flutter run -d chrome
```

Format, analyze, and test before pushing:

```sh
dart format .
flutter analyze
flutter test
```

Pushes to `main` build the web release and deploy it through the `web`
branch, build a signed Android app bundle that is uploaded as a draft
production release to the Play Console, and pull requests run the same
checks in CI.

### Online highscores

The highscore list lives in a Supabase project. Players are signed in
anonymously, never touch the tables directly, and the database replays every
run from sequence numbered progress reports using the same economy rules as
the game, so only trajectories the real game can produce are accepted. The
schema, functions and their pgTAP tests live in `supabase/`; migrations are
applied to the hosted project by the Supabase GitHub integration on merge to
`main`, and the project needs both new sign-ups and anonymous sign-ins
enabled under Authentication in its dashboard.

To run the backend locally (Docker required) and point the game at it:

```sh
supabase start
supabase test db
flutter run -d chrome \
  --dart-define=SUPABASE_URL=http://127.0.0.1:54521 \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=<publishable key from supabase status>
```

## Contributing

Contributions and suggestions are happily received! Open an issue with
ideas for new skills, events, or mechanics, especially if you can point to
a news source, or send a pull request directly.
