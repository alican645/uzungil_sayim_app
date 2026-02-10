import 'package:get_it/get_it.dart';
import 'package:uzungil_sayim_app/core/application/stock/stock_bloc.dart';
import 'package:uzungil_sayim_app/core/domain/repositories/i_stock_repository.dart';
import 'package:uzungil_sayim_app/core/network/api_client.dart';
import 'package:uzungil_sayim_app/infrastructure/persistence/datasources/stock_remote_data_source.dart';
import 'package:uzungil_sayim_app/infrastructure/persistence/datasources/stock_local_data_source.dart';
import 'package:uzungil_sayim_app/infrastructure/persistence/repositories/stock_repository_impl.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Core
  sl.registerLazySingleton(() => ApiClient().dio);

  // Data Sources
  sl.registerLazySingleton<IStockLocalDataSource>(() => StockLocalDataSource());
  sl.registerLazySingleton<IStockRemoteDataSource>(
    () => StockRemoteDataSourceImpl(dio: sl()),
  );

  // Repositories
  sl.registerLazySingleton<IStockRepository>(
    () => StockRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );

  // Blocs
  sl.registerFactory(() => StockBloc(repository: sl()));
}
