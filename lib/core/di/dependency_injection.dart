import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:notebook_ai/core/services/storage_services/secure_storage_service.dart';
import 'package:notebook_ai/core/services/storage_services/shared_prefrences_service.dart';
import 'package:notebook_ai/core/services/ai/anthropic_service.dart';
import 'package:notebook_ai/core/services/storage_services/storage_service.dart';
import 'package:notebook_ai/core/utils/overlay_loading/overlay_loading_manager.dart';
import 'package:notebook_ai/core/utils/snackbar_helper.dart';
import 'package:notebook_ai/features/notes/data/datasources/notes_datasources.dart';
import 'package:shared_preferences/shared_preferences.dart';

// dart format off
class DI {
  static late final ProviderContainer container;

  // --- Core Infrastructure ---
  static final _sharedPreferences         = Provider<SharedPreferences>((ref) => throw UnimplementedError("Initialize SharedPreferences in DI.init()"));
  static final _isarProvider              = Provider<Isar>((ref) => throw UnimplementedError('isarProvider must be overridden in DI.init()'));
  static final _notesDataSourceProvider   = Provider<NotesDataSource>((ref) => NotesDataSource(ref.watch(DI._isarProvider)));
  static final _secureStorage             = Provider((ref) => SecureStorageService());
  static final _sharedPrefsService        = Provider((ref) => SharedPrefsService(ref.read(_sharedPreferences)));

  static final _storageService            = Provider((ref) => StorageService(ref.read(_secureStorage), ref.read(_sharedPrefsService)));


  static final _anthropicService          = Provider((ref) => AnthropicService());

  // --- snack bar Helper
  static final _snackBarHelper            = Provider((ref) => SnackbarHelper());

  static final _loadingService            = Provider<LoadingManager>((ref) => OverlayLoadingManager());

  /// Call this in your main.dart before runApp()
  static Future<void> init({ProviderContainer? container}) async {
    final prefs   = await SharedPreferences.getInstance();
    final isar    = await NotesDataSource.openIsar();

    DI.container  = container ?? ProviderContainer(
      overrides: [
        _sharedPreferences.overrideWithValue(prefs),
        _isarProvider.overrideWithValue(isar),
      ],
    );

    // Warm the token cache so the first API request doesn't pay the secure-storage read.
    await DI().storageService.getToken();
  }
}

extension DICoreServicesExtension on DI {
  StorageService      get storageService   => DI.container.read(DI._storageService);
  SnackbarHelper      get snackBarHelper   => DI.container.read(DI._snackBarHelper);
  LoadingManager      get loadingService   => DI.container.read(DI._loadingService);
  Isar                get isar           => DI.container.read(DI._isarProvider);
  NotesDataSource     get notesDataSource  => DI.container.read(DI._notesDataSourceProvider);
  AnthropicService    get ai               => DI.container.read(DI._anthropicService);
}

// dart format on
