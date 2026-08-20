import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:mobile/services/app_data_reset_service.dart';
import 'package:mobile/services/cache_manager.dart';
import 'package:mobile/services/follow_service.dart';
import 'package:mobile/services/local_post_store.dart';
import 'package:mobile/services/identity_vault_service.dart';
import 'package:mobile/services/user_prefs_service.dart';

class SessionLogoutService {
  SessionLogoutService._();

  static final SessionLogoutService instance = SessionLogoutService._();

  Future<void> logout({bool preserveAuthSession = true}) async {
    await LocalPostStore.instance.runWithWritesPaused(() async {
      if (!preserveAuthSession) {
        try {
          await Supabase.instance.client.auth.signOut();
        } catch (error) {
          debugPrint('[SessionLogoutService] Supabase sign-out failed: $error');
        }
      }

      await Future.wait([
        CacheManager.instance.purgeAll(),
        CacheManager.instance.clearBlocklist(),
        LocalPostStore.instance.clearAll(force: true),
        FollowService.instance.clearAll(),
        UserPrefsService.instance.clearAll(),
        IdentityVaultService.instance.clear(),
      ]);
      AppDataResetService.instance.notifyLocalDataCleared();
    });
  }
}
