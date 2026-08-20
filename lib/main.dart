// ignore_for_file: do_not_use_environment

import 'package:fifflar_uffe/game/fifflar_uffe_game.dart';
import 'package:fifflar_uffe/services/supabase_highscore_client.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

const _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const _supabaseKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(
    GameWidget<FifflarUffeGame>.managed(
      gameFactory: () => FifflarUffeGame(
        highscoreClient: _supabaseUrl.isEmpty || _supabaseKey.isEmpty
            ? SupabaseHighscoreClient()
            : SupabaseHighscoreClient(
                url: _supabaseUrl,
                publishableKey: _supabaseKey,
              ),
      ),
    ),
  );
}
