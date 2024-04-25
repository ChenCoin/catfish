import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'data/grid_data.dart';
import 'view/black_board.dart';
import 'view/count_down.dart';
import 'view/game_board.dart';
import 'view/line_board.dart';
import 'web/conf_nil.dart' if (dart.library.html) 'web/conf_web.dart';

void main() {
  webConfigure();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (ctx) => AppLocalizations.of(ctx)!.title,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff8A9CA0)),
        primaryColor: const Color(0xff8A9CA0),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GridData data = GridData();

  // 游戏状态，0为初次进入游戏，1为游戏进行中，2为游戏结束
  int gameState = 0;

  void _gameStart() {
    setState(() => data.start());
  }

  void _gameOver() {
    setState(() {
      data.end();
    });
  }

  void _onBtnTap() {
    if (gameState == 0) {
      gameState = 1;
      _gameStart();
      return;
    }
    if (gameState == 1) {
      gameState = 2;
      _gameOver();
      return;
    }
    if (gameState == 2) {
      gameState = 1;
      _gameStart();
      return;
    }
  }

  void _onScoreChanged() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    data.init(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData media = MediaQuery.of(context);
    final screenTop = media.padding.top;
    final screenBottom = media.padding.bottom;
    // 最大面板高度
    final boxHeight =
        media.size.height - screenTop - 8 - 48 - 48 - 8 - screenBottom;
    final widthOfH = (boxHeight - 20) / 16 * 10;
    // 宽度为屏幕宽度 - 40，特殊适配大屏
    final double width = min(media.size.width - 32, widthOfH);
    double height = width / 10 * 16;
    var tipText = AppLocalizations.of(context)!.tip;
    return Scaffold(
      backgroundColor: const Color(0xff8A9CA0),
      body: Align(
        alignment: Alignment.topCenter,
        child: Column(
          children: <Widget>[
            Padding(padding: EdgeInsets.only(top: 8 + screenTop)),
            SizedBox(
              width: width,
              height: 48,
              child: Visibility(
                visible: gameState == 1,
                child: titlePanel(context, width),
              ),
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                RepaintBoundary(
                  child: Stack(
                    children: [
                      BlackBoard(size: Size(width + 20, height + 20)),
                      if (gameState == 1)
                        LineBoard(size: Size(width + 20, height + 20)),
                    ],
                  ),
                ),
                if (gameState == 1)
                  SizedBox(
                    width: width,
                    height: height,
                    child: GameBoard(
                      size: Size(width, height),
                      callback: _onScoreChanged,
                      data: data,
                    ),
                  ),
                if (gameState != 1) menuPanel(context),
              ],
            ),
            SizedBox(
              width: width,
              height: 48,
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Text(tipText),
                    if (data.magicNumber != '')
                      Align(
                        alignment: Alignment.topRight,
                        child: Text(
                          data.magicNumber,
                          style: const TextStyle(color: Color(0xff809090)),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _btnLabel(BuildContext context) {
    final String gameStart = AppLocalizations.of(context)!.startGame;
    final String gameRestart = AppLocalizations.of(context)!.restartGame;
    return gameState == 0 ? gameStart : gameRestart;
  }

  String _scoreLabel(BuildContext context) {
    var scoreText = AppLocalizations.of(context)!.score;
    return '$scoreText: ${data.score}';
  }

  Widget titlePanel(BuildContext context, double width) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            _scoreLabel(context),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: TimerText(
                  secondCount: 120,
                  onTickEnd: () {
                    gameState = 2;
                    _gameOver();
                  },
                ),
              ),
              TextButton(
                onPressed: () => _onBtnTap(),
                child: Text(AppLocalizations.of(context)!.endGame),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget menuPanel(BuildContext context) {
    var highestScoreText = AppLocalizations.of(context)!.highestScore;
    var scoreNow = AppLocalizations.of(context)!.scoreNow;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (gameState == 2) ...[
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              scoreNow,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            '${data.score}',
            style: Theme.of(context).textTheme.displayLarge,
          ),
        ],
        const Padding(padding: EdgeInsets.all(24)),
        TextButton(
          onPressed: () => _onBtnTap(),
          style: ButtonStyle(
              minimumSize: MaterialStateProperty.all(const Size(200, 54))),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              _btnLabel(context),
              style: const TextStyle(
                fontSize: 24,
                color: Colors.white70,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            '$highestScoreText: ${data.highestScore}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
