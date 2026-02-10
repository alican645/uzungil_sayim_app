import 'package:flutter/material.dart';
import 'core/injection_container.dart' as di;
import 'presentation/navigation/app_router.dart';
import 'core/config/app_config.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'infrastructure/persistence/models/stock_count_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppConfig.init(Environment.dev);

  final appDocumentDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);
  Hive.registerAdapter(StockCountModelAdapter());
  await Hive.openBox<StockCountModel>('stock_counts');

  di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routerConfig: AppRouter.router,
    );
  }
}
