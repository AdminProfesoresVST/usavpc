import 'package:mobile/core/service_locator/app_config.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_config_provider.g.dart';

@Riverpod(keepAlive: true)
AppConfig appConfig(AppConfigRef ref) {
  throw UnimplementedError('appConfigProvider must be overridden in main.dart');
}
