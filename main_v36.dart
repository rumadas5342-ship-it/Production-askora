// ============================================================
// ASKROA AI — main.dart  (v36 production)
// ============================================================
// BUILD COMMAND (all dart-define required):
//   flutter build apk --obfuscate --split-debug-info=./debug-info \
//     --dart-define=ELEVENLABS_API_KEY=sk_... \
//     --dart-define=BACKEND_BASE_URL=https://api.askroa.com \
//     --dart-define=WEBSOCKET_URL=wss://api.askroa.com/ws \
//     --dart-define=SENTRY_DSN=https://...@sentry.io/... \
//     --dart-define=LOG_HASH_SALT=your-random-salt \
//     --dart-define=CERTIFICATE_PIN_PRIMARY=sha256/... \
//     --dart-define=CERTIFICATE_PIN_BACKUP=sha256/...
//
// REQUIRED pubspec.yaml dependencies (verify these are present):
//   http_parser, path, web_socket_channel, timezone, drift, drift_flutter,
//   sqlite3_flutter_libs, encrypt, sentry_flutter, firebase_core,
//   firebase_auth, firebase_remote_config, firebase_messaging,
//   firebase_crashlytics, firebase_performance, firebase_app_check,
//   firebase_analytics, google_sign_in, sign_in_with_apple,
//   in_app_purchase, in_app_purchase_android, in_app_purchase_storekit,
//   workmanager, flutter_background_service, just_audio, just_audio_background,
//   record, speech_to_text, flutter_tts, permission_handler,
//   flutter_secure_storage, shared_preferences, connectivity_plus,
//   go_router, image_picker, cached_network_image, flutter_cache_manager,
//   dio, dio_cache_interceptor, dio_cache_interceptor_isar_store,
//   flutter_local_notifications, wakelock_plus, share_plus, app_links,
//   lottie, shimmer, fl_chart, badges, google_fonts, local_auth,
//   package_info_plus, device_info_plus, mutex, async, pool,
//   crypto, pointycastle, image, exif, video_compress (deferred),
//   video_player (deferred), camera (deferred), webview_flutter (deferred)
// ============================================================

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io'; // ignore: avoid_web_libraries_in_flutter — Platform.* always guarded by kIsWeb checks
import 'dart:math';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:uuid/uuid.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logger/logger.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart' deferred as video_player;
import 'package:camera/camera.dart' deferred as camera;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:workmanager/workmanager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:local_auth/local_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';
import 'package:image/image.dart' as img;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shimmer/shimmer.dart';
import 'package:lottie/lottie.dart';
import 'package:http_parser/http_parser.dart';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_isar_store/dio_cache_interceptor_isar_store.dart';
import 'package:path/path.dart' as path;
import 'package:video_compress/video_compress.dart' deferred as video_compress;
import 'package:audio_session/audio_session.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:share_plus/share_plus.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:crypto/crypto.dart';
import 'package:pointycastle/export.dart' as pc;
import 'package:pool/pool.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:webview_flutter/webview_flutter.dart' deferred as webview;
import 'package:webview_flutter_android/webview_flutter_android.dart' deferred as webview_android;
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart' deferred as webview_ios;
import 'package:app_links/app_links.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/scheduler.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:badges/badges.dart' as badges;
import 'package:fl_chart/fl_chart.dart';
import 'package:mutex/mutex.dart';
import 'package:async/async.dart';


// ===========================================
// CONFIG WARNING HELPER
// ===========================================
void _askroaConfigWarn(String msg) {
  assert(() { return true; }());
}



// ===========================================
// RATE LIMIT STATUS MODEL
// ===========================================

class RateLimitQuota {
  final int remaining;
  final int limit;
  final double usagePercent;
  const RateLimitQuota({required this.remaining, required this.limit, required this.usagePercent});

  factory RateLimitQuota.fromJson(Map<String, dynamic> j, String key) => RateLimitQuota(
    remaining:    (j['remaining']?[key] as num?)?.toInt() ?? 0,
    limit:        (j['limits']?[key]    as num?)?.toInt() ?? 0,
    usagePercent: (j['usage_percent']?[key] as num?)?.toDouble() ?? 0,
  );

  bool get isExhausted => remaining <= 0;
  bool get isLow       => remaining > 0 && remaining <= 3;
}

class CooldownStatus {
  final bool canSend;
  final int  waitSeconds;
  final DateTime? nextAvailableAt;
  const CooldownStatus({required this.canSend, required this.waitSeconds, this.nextAvailableAt});

  factory CooldownStatus.fromJson(Map<String, dynamic>? j) {
    if (j == null) return const CooldownStatus(canSend: true, waitSeconds: 0);
    return CooldownStatus(
      canSend:        j['can_send'] as bool? ?? true,
      waitSeconds:    (j['wait_seconds'] as num?)?.toInt() ?? 0,
      nextAvailableAt: j['next_available_at'] != null
          ? DateTime.tryParse(j['next_available_at'] as String)
          : null,
    );
  }
}

class RateLimitStatus {
  final String  userId;
  final String  plan;
  final RateLimitQuota messages;
  final RateLimitQuota images;
  final RateLimitQuota videos;
  final RateLimitQuota voice;
  final int     dailyResetInSeconds;
  final DateTime dailyResetAt;
  final CooldownStatus chatCooldown;
  final CooldownStatus imageCooldown;
  final CooldownStatus videoCooldown;
  final CooldownStatus voiceCooldown;
  final bool    canChat;
  final bool    canGenerateImage;
  final bool    canGenerateVideo;
  final List<Map<String, dynamic>> messages_;

  const RateLimitStatus({
    required this.userId,
    required this.plan,
    required this.messages,
    required this.images,
    required this.videos,
    required this.voice,
    required this.dailyResetInSeconds,
    required this.dailyResetAt,
    required this.chatCooldown,
    required this.imageCooldown,
    required this.videoCooldown,
    required this.voiceCooldown,
    required this.canChat,
    required this.canGenerateImage,
    required this.canGenerateVideo,
    this.messages_ = const [],
  });

  factory RateLimitStatus.fromJson(Map<String, dynamic> j) {
    final quotas    = j['quotas'] as Map<String, dynamic>? ?? {};
    final cooldowns = j['cooldowns'] as Map<String, dynamic>? ?? {};
    final reset     = j['reset']    as Map<String, dynamic>? ?? {};
    return RateLimitStatus(
      userId:              j['user_id']  as String? ?? '',
      plan:                j['plan']     as String? ?? 'free',
      messages:            RateLimitQuota.fromJson(quotas, 'messages'),
      images:              RateLimitQuota.fromJson(quotas, 'images'),
      videos:              RateLimitQuota.fromJson(quotas, 'videos'),
      voice:               RateLimitQuota.fromJson(quotas, 'voice'),
      dailyResetInSeconds: (reset['daily_reset_in_seconds'] as num?)?.toInt() ?? 86400,
      dailyResetAt:        reset['daily_reset_at'] != null
          ? DateTime.tryParse(reset['daily_reset_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      chatCooldown:        CooldownStatus.fromJson(cooldowns['chat_message']       as Map<String, dynamic>?),
      imageCooldown:       CooldownStatus.fromJson(cooldowns['image_generation']   as Map<String, dynamic>?),
      videoCooldown:       CooldownStatus.fromJson(cooldowns['video_generation']   as Map<String, dynamic>?),
      voiceCooldown:       CooldownStatus.fromJson(cooldowns['voice_synthesis']    as Map<String, dynamic>?),
      canChat:             j['can_chat']           as bool? ?? true,
      canGenerateImage:    j['can_generate_image'] as bool? ?? true,
      canGenerateVideo:    j['can_generate_video'] as bool? ?? false,
      messages_:           (j['messages'] as List?)?.cast<Map<String, dynamic>>() ?? [],
    );
  }

  // Convenience
  String get resetTimeLabel {
    final h = dailyResetInSeconds ~/ 3600;
    final m = (dailyResetInSeconds % 3600) ~/ 60;
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }
}

// ===========================================
// ELEVENLABS TTS SERVICE
// ===========================================

class ElevenLabsVoice {
  final String id;
  final String name;
  final String gender;
  const ElevenLabsVoice({required this.id, required this.name, required this.gender});
}

class ElevenLabsTtsService {
  // API key loaded from dart-define (never hardcoded in source)
  static const String _apiKey = String.fromEnvironment('ELEVENLABS_API_KEY');
  static const String _baseUrl = 'https://api.elevenlabs.io/v1';

  static const Map<String, ElevenLabsVoice> voices = {
    'voice_1': ElevenLabsVoice(id: '5pbRhgyt5cu8sOyTb4iQ', name: 'Rachel',  gender: 'female'),
    'voice_2': ElevenLabsVoice(id: 'yUyoTeLmPuhy6PzRBfAb', name: 'Antoni',  gender: 'male'),
    'voice_3': ElevenLabsVoice(id: 'feqiSUkro9i70ckCxePf', name: 'Elli',    gender: 'female'),
    'voice_4': ElevenLabsVoice(id: 'kFCe7jyOkkYKzOgpe2u0', name: 'Simran',  gender: 'female'),
    'voice_5': ElevenLabsVoice(id: 'gO8Kb3hHPEPElVxVHDwT', name: 'Harry',   gender: 'male'),
  };

  static const String _defaultVoiceKey = 'voice_1';
  final ProductionLogger _log;
  final AudioPlayer _player = AudioPlayer();

  ElevenLabsTtsService({required ProductionLogger logger}) : _log = logger;

  static ElevenLabsVoice voiceForKey(String key) =>
      voices[key] ?? voices[_defaultVoiceKey]!;

  Future<void> speak(String text, {
    String voiceKey = _defaultVoiceKey,
    VoidCallback? onDone,
  }) async {
    if (text.trim().isEmpty) return;
    if (_apiKey.isEmpty) {
      _log.w('[ElevenLabs] ELEVENLABS_API_KEY not set via dart-define — skipping');
      return;
    }
    try {
      final voice = voiceForKey(voiceKey);
      final url   = Uri.parse('$_baseUrl/text-to-speech/${voice.id}/stream');
      final resp  = await http.post(url,
        headers: {
          'xi-api-key':   _apiKey,
          'Content-Type': 'application/json',
          'Accept':       'audio/mpeg',
        },
        body: jsonEncode({
          'text':       text,
          'model_id':   'eleven_multilingual_v2',
          'voice_settings': {'stability': 0.5, 'similarity_boost': 0.75},
        }),
      ).timeout(const Duration(seconds: 30));

      if (resp.statusCode == 200) {
        final dir  = await getTemporaryDirectory();
        final file = File('${dir.path}/el_tts_${DateTime.now().millisecondsSinceEpoch}.mp3');
        await file.writeAsBytes(resp.bodyBytes);
        await _player.setFilePath(file.path);
        await _player.play();
        _player.playerStateStream.listen((s) async {
          if (s.processingState == ProcessingState.completed) {
            try { await file.delete(); } catch (_) {}
            onDone?.call();
          }
        });
        _log.d('[ElevenLabs] Speaking: ${voice.name} (${text.length} chars)');
      } else {
        _log.e('[ElevenLabs] API error ${resp.statusCode}');
      }
    } catch (e, s) {
      _log.e('[ElevenLabs] speak failed', error: e, stackTrace: s);
    }
  }

  Future<void> stop() async {
    try { await _player.stop(); } catch (_) {}
  }

  void dispose() => _player.dispose();
}

// ===========================================
// VOICE SETTINGS MODEL
// ===========================================

class VoiceSettings {
  final String voiceKey;
  final bool   useElevenLabs;
  const VoiceSettings({this.voiceKey = 'voice_1', this.useElevenLabs = true});
  VoiceSettings copyWith({String? voiceKey, bool? useElevenLabs}) => VoiceSettings(
    voiceKey:      voiceKey      ?? this.voiceKey,
    useElevenLabs: useElevenLabs ?? this.useElevenLabs,
  );
  Map<String, dynamic> toJson() => {'voice_key': voiceKey, 'use_eleven_labs': useElevenLabs};
  factory VoiceSettings.fromJson(Map<String, dynamic> j) => VoiceSettings(
    voiceKey:      j['voice_key']       as String? ?? 'voice_1',
    useElevenLabs: j['use_eleven_labs'] as bool?   ?? true,
  );
}

// ===========================================
// VOICE SETTINGS NOTIFIER
// ===========================================

class VoiceSettingsNotifier extends StateNotifier<VoiceSettings> {
  final Ref ref;
  late final ProductionLogger _log;
  late final ProductionApiService _apiService;
  late final GlobalUserHandler _userHandler;

  VoiceSettingsNotifier(this.ref) : super(const VoiceSettings()) {
    _init();
  }

  Future<void> _init() async {
    try {
      _log         = ref.read(loggerProvider);
      _apiService  = await ref.read(apiServiceProvider.future);
      _userHandler = await ref.read(globalUserHandlerFutureProvider.future);
      final prefs  = await SharedPreferences.getInstance();
      final raw    = prefs.getString('askroa_voice_settings');
      if (raw != null) {
        state = VoiceSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      }
    } catch (e) {
      if (mounted) _log.w('[VoiceSettings] init failed', error: e);
    }
  }

  Future<void> setVoice(String voiceKey) async {
    final next = state.copyWith(voiceKey: voiceKey);
    state = next;
    await _persist(next);
    await _syncToBackend(next);
  }

  Future<void> setUseElevenLabs(bool use) async {
    final next = state.copyWith(useElevenLabs: use);
    state = next;
    await _persist(next);
  }

  Future<void> _persist(VoiceSettings s) async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString('askroa_voice_settings', jsonEncode(s.toJson()));
    } catch (_) {}
  }

  Future<void> _syncToBackend(VoiceSettings s) async {
    try {
      final user = _userHandler.currentUser;
      if (user == null) return;
      await _apiService.updateUserVoiceSettings(userId: user.id, voiceKey: s.voiceKey);
      _log.d('[VoiceSettings] Synced to backend: ${s.voiceKey}');
    } catch (e) {
      _log.w('[VoiceSettings] backend sync failed', error: e);
    }
  }

  Future<void> loadFromBackend() async {
    try {
      final user = _userHandler.currentUser;
      if (user == null) return;
      final data = await _apiService.getUserVoiceSettings(userId: user.id);
      if (data['voice_key'] != null) {
        final loaded = VoiceSettings.fromJson(data);
        state = loaded;
        await _persist(loaded);
        _log.d('[VoiceSettings] Loaded from backend: ${loaded.voiceKey}');
      }
    } catch (e) {
      _log.w('[VoiceSettings] load from backend failed', error: e);
    }
  }
}

final voiceSettingsProvider =
    StateNotifierProvider<VoiceSettingsNotifier, VoiceSettings>((ref) => VoiceSettingsNotifier(ref));

final elevenLabsTtsProvider = Provider<ElevenLabsTtsService>((ref) {
  final svc = ElevenLabsTtsService(logger: ref.read(loggerProvider));
  ref.onDispose(svc.dispose);
  return svc;
});

// ===========================================
// SINGLETON SECURE STORAGE — keystore fallback for old Android devices
// ===========================================
class AppSecureStorage {
  AppSecureStorage._();
  static const AppSecureStorage instance = AppSecureStorage._();

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
  );

  String _obfuscate(String value) => base64.encode(utf8.encode(value));
  String _deobfuscate(String value) {
    try { return utf8.decode(base64.decode(value)); } catch (_) { return value; }
  }

  Future<String?> read({required String key}) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      // Fail secure: do NOT fall back to SharedPreferences for sensitive data
      // If FlutterSecureStorage fails, return null and let caller handle auth flow
      if (kDebugMode) debugPrint('[SecureStorage] read failed for $key: $e');
      return null;
    }
  }

  Future<void> write({required String key, required String? value}) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      // Fail secure: do NOT write sensitive data to insecure storage
      if (kDebugMode) debugPrint('[SecureStorage] write failed for $key: $e');
      rethrow; // Caller must handle — silent failure risks data loss
    }
  }

  Future<void> delete({required String key}) async {
    try { await _storage.delete(key: key); } catch (_) {}
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('_ss_$key');
    } catch (_) {}
  }

  Future<Map<String, String>> readAll() async {
    try { return await _storage.readAll(); } catch (_) { return {}; }
  }
}

// ===========================================
// FIXED: FIREBASE OPTIONS WITH PROPER VALIDATION
// ===========================================
class DefaultFirebaseOptions {

  static FirebaseOptions get android {
    const apiKey             = String.fromEnvironment('FIREBASE_ANDROID_API_KEY');
    const appId              = String.fromEnvironment('FIREBASE_ANDROID_APP_ID');
    const messagingSenderId  = String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
    const projectId          = String.fromEnvironment('FIREBASE_PROJECT_ID');
    const storageBucket      = String.fromEnvironment('FIREBASE_STORAGE_BUCKET');

    if (apiKey.isEmpty || appId.isEmpty || messagingSenderId.isEmpty || projectId.isEmpty) {
      throw Exception(
        '[Askroa] CRITICAL: Firebase Android config missing. '
        'Provide FIREBASE_ANDROID_API_KEY, FIREBASE_ANDROID_APP_ID, '
        'FIREBASE_MESSAGING_SENDER_ID, FIREBASE_PROJECT_ID via --dart-define.',
      );
    }

    return FirebaseOptions(
      apiKey:            apiKey,
      appId:             appId,
      messagingSenderId: messagingSenderId,
      projectId:         projectId,
      storageBucket:     storageBucket.isNotEmpty ? storageBucket : '$projectId.appspot.com',
    );
  }

  static FirebaseOptions get ios {
    const apiKey             = String.fromEnvironment('FIREBASE_IOS_API_KEY');
    const appId              = String.fromEnvironment('FIREBASE_IOS_APP_ID');
    const messagingSenderId  = String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
    const projectId          = String.fromEnvironment('FIREBASE_PROJECT_ID');
    const storageBucket      = String.fromEnvironment('FIREBASE_STORAGE_BUCKET');
    const iosClientId        = String.fromEnvironment('FIREBASE_IOS_CLIENT_ID');
    const iosBundleId        = String.fromEnvironment('FIREBASE_IOS_BUNDLE_ID');

    if (apiKey.isEmpty || appId.isEmpty || messagingSenderId.isEmpty ||
        projectId.isEmpty || iosClientId.isEmpty || iosBundleId.isEmpty) {
      throw Exception(
        '[Askroa] CRITICAL: Firebase iOS config missing. '
        'Provide FIREBASE_IOS_API_KEY, FIREBASE_IOS_APP_ID, '
        'FIREBASE_MESSAGING_SENDER_ID, FIREBASE_PROJECT_ID, '
        'FIREBASE_IOS_CLIENT_ID, FIREBASE_IOS_BUNDLE_ID via --dart-define.',
      );
    }

    return FirebaseOptions(
      apiKey:            apiKey,
      appId:             appId,
      messagingSenderId: messagingSenderId,
      projectId:         projectId,
      storageBucket:     storageBucket.isNotEmpty ? storageBucket : '$projectId.appspot.com',
      iosClientId:       iosClientId,
      iosBundleId:       iosBundleId,
    );
  }

  static FirebaseOptions get web {
    const apiKey             = String.fromEnvironment('FIREBASE_WEB_API_KEY');
    const appId              = String.fromEnvironment('FIREBASE_WEB_APP_ID');
    const messagingSenderId  = String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
    const projectId          = String.fromEnvironment('FIREBASE_PROJECT_ID');
    const storageBucket      = String.fromEnvironment('FIREBASE_STORAGE_BUCKET');
    const authDomain         = String.fromEnvironment('FIREBASE_AUTH_DOMAIN');

    if (apiKey.isEmpty || appId.isEmpty || messagingSenderId.isEmpty ||
        projectId.isEmpty || authDomain.isEmpty) {
      throw Exception(
        '[Askroa] CRITICAL: Firebase Web config missing. '
        'Provide FIREBASE_WEB_API_KEY, FIREBASE_WEB_APP_ID, '
        'FIREBASE_MESSAGING_SENDER_ID, FIREBASE_PROJECT_ID, '
        'FIREBASE_AUTH_DOMAIN via --dart-define.',
      );
    }

    return FirebaseOptions(
      apiKey:            apiKey,
      appId:             appId,
      messagingSenderId: messagingSenderId,
      projectId:         projectId,
      storageBucket:     storageBucket.isNotEmpty ? storageBucket : '$projectId.appspot.com',
      authDomain:        authDomain,
    );
  }

  static FirebaseOptions get windows {
    const apiKey             = String.fromEnvironment('FIREBASE_WINDOWS_API_KEY');
    const appId              = String.fromEnvironment('FIREBASE_WINDOWS_APP_ID');
    const messagingSenderId  = String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
    const projectId          = String.fromEnvironment('FIREBASE_PROJECT_ID');
    const storageBucket      = String.fromEnvironment('FIREBASE_STORAGE_BUCKET');

    if (apiKey.isEmpty || appId.isEmpty || messagingSenderId.isEmpty || projectId.isEmpty) {
      throw Exception(
        '[Askroa] CRITICAL: Firebase Windows config missing. '
        'Provide FIREBASE_WINDOWS_API_KEY, FIREBASE_WINDOWS_APP_ID, '
        'FIREBASE_MESSAGING_SENDER_ID, FIREBASE_PROJECT_ID via --dart-define.',
      );
    }

    return FirebaseOptions(
      apiKey:            apiKey,
      appId:             appId,
      messagingSenderId: messagingSenderId,
      projectId:         projectId,
      storageBucket:     storageBucket.isNotEmpty ? storageBucket : '$projectId.appspot.com',
    );
  }

  static FirebaseOptions get macos {
    const apiKey             = String.fromEnvironment('FIREBASE_MACOS_API_KEY');
    const appId              = String.fromEnvironment('FIREBASE_MACOS_APP_ID');
    const messagingSenderId  = String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
    const projectId          = String.fromEnvironment('FIREBASE_PROJECT_ID');
    const storageBucket      = String.fromEnvironment('FIREBASE_STORAGE_BUCKET');

    if (apiKey.isEmpty || appId.isEmpty || messagingSenderId.isEmpty || projectId.isEmpty) {
      throw Exception(
        '[Askroa] CRITICAL: Firebase macOS config missing. '
        'Provide FIREBASE_MACOS_API_KEY, FIREBASE_MACOS_APP_ID, '
        'FIREBASE_MESSAGING_SENDER_ID, FIREBASE_PROJECT_ID via --dart-define.',
      );
    }

    return FirebaseOptions(
      apiKey:            apiKey,
      appId:             appId,
      messagingSenderId: messagingSenderId,
      projectId:         projectId,
      storageBucket:     storageBucket.isNotEmpty ? storageBucket : '$projectId.appspot.com',
    );
  }

  static FirebaseOptions get linux {
    const apiKey             = String.fromEnvironment('FIREBASE_LINUX_API_KEY');
    const appId              = String.fromEnvironment('FIREBASE_LINUX_APP_ID');
    const messagingSenderId  = String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
    const projectId          = String.fromEnvironment('FIREBASE_PROJECT_ID');
    const storageBucket      = String.fromEnvironment('FIREBASE_STORAGE_BUCKET');

    if (apiKey.isEmpty || appId.isEmpty || messagingSenderId.isEmpty || projectId.isEmpty) {
      throw Exception(
        '[Askroa] CRITICAL: Firebase Linux config missing. '
        'Provide FIREBASE_LINUX_API_KEY, FIREBASE_LINUX_APP_ID, '
        'FIREBASE_MESSAGING_SENDER_ID, FIREBASE_PROJECT_ID via --dart-define.',
      );
    }

    return FirebaseOptions(
      apiKey:            apiKey,
      appId:             appId,
      messagingSenderId: messagingSenderId,
      projectId:         projectId,
      storageBucket:     storageBucket.isNotEmpty ? storageBucket : '$projectId.appspot.com',
    );
  }

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    if (Platform.isAndroid) return android;
    if (Platform.isIOS) return ios;
    if (Platform.isWindows) return windows;
    if (Platform.isMacOS) return macos;
    if (Platform.isLinux) return linux;
    throw UnsupportedError('Unsupported platform: ${Platform.operatingSystem}');
  }
}

// ===========================================
// LAZY LOADING MANAGER - FIXED: Proper disposal with lock
// ===========================================
class LazyLoader {
  static final Map<String, Future<dynamic>> _loadingFutures = {};
  static final Map<String, dynamic> _loadedModules = {};
  static final List<StreamController> _controllers = [];
  static final Lock _lock = Lock();
  
  static Future<T> load<T>(String key, Future<T> Function() loader) {
    return _lock.synchronized(() async {
      if (_loadedModules.containsKey(key)) {
        return _loadedModules[key] as T;
      }
      
      if (!_loadingFutures.containsKey(key)) {
        _loadingFutures[key] = loader().then((value) {
          _loadedModules[key] = value;
          _loadingFutures.remove(key);
          return value;
        }).catchError((error) {
          _loadingFutures.remove(key);
          throw error;
        });
      }
      
      return _loadingFutures[key] as Future<T>;
    });
  }
  
  static bool isLoaded(String key) => _loadedModules.containsKey(key);
  
  static T? getIfLoaded<T>(String key) => _loadedModules[key] as T?;
  
  static void registerController(StreamController controller) {
    _controllers.add(controller);
  }
  
  static void unregisterController(StreamController controller) {
    _controllers.remove(controller);
  }
  
  static final Map<String, bool> _moduleStatus = {};
  static final Map<String, String> _moduleErrors = {};

  static bool isModuleLoaded(String name) => _moduleStatus[name] == true;
  static String? moduleError(String name) => _moduleErrors[name];

  static Future<void> loadDeferredModules(ProductionLogger? log) async {
    final modules = <String, Future<void> Function()>{
      'video_player':   () async => video_player.loadLibrary(),
      'camera':         () async => camera.loadLibrary(),
      'video_compress': () async => video_compress.loadLibrary(),
      'webview':        () async => webview.loadLibrary(),
      'webview_ios':    () async => webview_ios.loadLibrary(),
      'webview_android':() async => webview_android.loadLibrary(),
    };
    for (final entry in modules.entries) {
      try {
        await entry.value();
        _moduleStatus[entry.key] = true;
        log?.d('[LazyLoader] Module loaded: \${entry.key}');
      } catch (e) {
        _moduleStatus[entry.key] = false;
        _moduleErrors[entry.key] = e.toString();
        log?.w('[LazyLoader] Module failed: \${entry.key}', error: e);
        // Non-critical: app continues without this deferred feature
      }
    }
  }

    static Future<void> clear() async {
    for (final controller in _controllers) {
      if (!controller.isClosed) {
        await controller.close();
      }
    }
    _controllers.clear();
    _loadingFutures.clear();
    _loadedModules.clear();
  }
}

// ===========================================
// APP CONSTANTS - PRODUCTION ONLY, NO FALLBACKS
// ===========================================
const String appName = 'Askroa AI';
const String appVersion = '3.2.0';
const String apiVersion = 'v21';
const String privacyPolicyUrl = 'https://askroa-ai.com/privacy';
const String aiReportPolicyNotice =
    'AI responses can be reported for review. '
    'See our Privacy Policy for details on how reports are handled.';
const String termsUrl = 'https://askroa-ai.com/terms';
const String contentPolicyUrl = 'https://askroa-ai.com/content-policy';
const String dataSafetyUrl = 'https://askroa-ai.com/data-safety';

const String newAppIconUrl = 'assets/icons/new_app_icon.png';

// ===========================================
// APP COLORS - UPDATED TO MATCH IMAGE COLORS EXACTLY
// ===========================================
class AppColors {
  static const Color primaryBlue = Color(0xFF007AFF);     // welcome blue, buttons, exact match
  static const Color darkBlue = Color(0xFF0056B3);
  static const Color lightBlue = Color(0xFF5AC8FA);
  
  static const Color backgroundBlack = Color(0xFF000000);     // main dark background
  static const Color backgroundDark = Color(0xFF1C1C1E);      // input bar, surfaces
  static const Color backgroundCard = Color(0xFF2C2C2E);      // context menus, bubbles, cards
  static const Color backgroundSurface = Color(0xFF121212);
  static const Color lightBackground = Color(0xFFF6F6F8);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  
  static const Color borderDark = Color(0xFF38383A);
  static const Color borderMedium = Color(0xFF48484A);
  static const Color borderLight = Color(0xFF5A5A5E);
  static const Color lightBorder = Color(0xFFE5E5EA);
  
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGrey = Color(0xFF8E8E93);
  static const Color textLightGrey = Color(0xFFAEAEB2);
  static const Color textBlue = Color(0xFF007AFF);
  static const Color textDark = Color(0xFF000000);
  static const Color textLightDark = Color(0xFF1C1C1E);
  
  static const Color buttonPrimary = Color(0xFF007AFF);
  static const Color buttonSecondary = Color(0xFF2C2C2E);
  static const Color buttonGoogle = Color(0xFF4285F4);
  static const Color buttonApple = Color(0xFF000000);
  
  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFFF9500);
  static const Color error = Color(0xFFFF3B30);           // clear chats red
  static const Color info = Color(0xFF007AFF);

  static const Gradient blueGradient = LinearGradient(
    colors: [Color(0xFF007AFF), Color(0xFF5AC8FA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient premiumGradient = LinearGradient(
    colors: [Color(0xFFFFCC00), Color(0xFFFF9500)],       // pro+, ultra pro yellow-orange
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Color userMessageBubble = Color(0xFF2C2C2E);
  static const Color aiMessageBubble = Color(0xFF1C1C1E);
  static const Color lightUserMessageBubble = Color(0xFFE5E5EA);
  static const Color lightAiMessageBubble = Color(0xFFF2F2F7);

  static Color getPngBackground(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? backgroundSurface : Colors.grey[100]!;
  }

  static Color getPngIconColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? Colors.white : Colors.black;
  }

  static Color getBackground(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? backgroundBlack : lightBackground;
  }

  static Color getSurface(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? backgroundDark : lightSurface;
  }

  static Color getCard(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? backgroundCard : lightCard;
  }

  static Color getBorder(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? borderDark : lightBorder;
  }

  static Color getText(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? textWhite : textDark;
  }

  static Color getUserMessageBubble(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? userMessageBubble : lightUserMessageBubble;
  }

  static Color getAiMessageBubble(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? aiMessageBubble : lightAiMessageBubble;
  }
}

// ===========================================
// PRODUCTION THEME - DARK (matches your screenshots)
// ===========================================
ThemeData getDarkTheme() {
  return ThemeData.dark().copyWith(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.backgroundBlack,
    canvasColor: AppColors.backgroundDark,
    cardColor: AppColors.backgroundCard,
    dialogBackgroundColor: AppColors.backgroundSurface,

    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryBlue,
      secondary: AppColors.lightBlue,
      surface: AppColors.backgroundBlack,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.textWhite,
      onError: Colors.white,
      brightness: Brightness.dark,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.backgroundDark,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: AppColors.textWhite,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: AppColors.textWhite),
    ),

    textTheme: TextTheme(
      displayLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.textWhite,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: AppColors.textWhite,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.textWhite,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textWhite,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textWhite,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textWhite,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textWhite,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textGrey,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textWhite,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textWhite,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textGrey,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textWhite,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textGrey,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: AppColors.textGrey,
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.backgroundSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      hintStyle: const TextStyle(
        color: AppColors.textGrey,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      labelStyle: const TextStyle(
        color: AppColors.textGrey,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      floatingLabelStyle: const TextStyle(
        color: AppColors.primaryBlue,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.buttonPrimary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textWhite,
        backgroundColor: Colors.transparent,
        side: const BorderSide(color: AppColors.borderDark),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryBlue,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),

    cardTheme: CardTheme(
      color: AppColors.backgroundCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.borderDark),
      ),
      margin: const EdgeInsets.all(0),
    ),

    dividerTheme: const DividerThemeData(
      color: AppColors.borderDark,
      thickness: 1,
      space: 0,
    ),

    dialogTheme: DialogTheme(
      backgroundColor: AppColors.backgroundSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textWhite,
      ),
      contentTextStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textWhite,
      ),
    ),
  );
}

ThemeData getLightTheme() {
  return ThemeData.light().copyWith(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.lightBackground,
    canvasColor: AppColors.lightSurface,
    cardColor: AppColors.lightCard,
    dialogBackgroundColor: Colors.white,

    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryBlue,
      secondary: AppColors.lightBlue,
      surface: AppColors.lightBackground,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.textDark,
      onError: Colors.white,
      brightness: Brightness.light,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: AppColors.textDark,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: AppColors.textDark),
    ),

    textTheme: TextTheme(
      displayLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textDark,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textLightDark,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textDark,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textDark,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textLightDark,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textLightDark,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: AppColors.textLightDark,
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.lightBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.lightBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      hintStyle: const TextStyle(
        color: Colors.grey,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      labelStyle: const TextStyle(
        color: Colors.grey,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      floatingLabelStyle: const TextStyle(
        color: AppColors.primaryBlue,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.buttonPrimary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textDark,
        backgroundColor: Colors.transparent,
        side: const BorderSide(color: AppColors.lightBorder),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryBlue,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),

    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.lightBorder),
      ),
      margin: const EdgeInsets.all(0),
    ),

    dividerTheme: const DividerThemeData(
      color: AppColors.lightBorder,
      thickness: 1,
      space: 0,
    ),

    dialogTheme: DialogTheme(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),
      contentTextStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textDark,
      ),
    ),
  );
}

// ===========================================
// APP ASSETS - NEW APP ICON ADDED, OLD REMOVED
// ===========================================
class AppAssets {
  static const String appIcon = 'assets/icons/new_app_icon.png';
  
  static const String googleIcon = 'assets/icons/google_icon.png';
  static const String emailIcon = 'assets/icons/email_icon.png';
  static const String appleIcon = 'assets/icons/apple_icon.png';
  static const String sendIcon = 'assets/icons/send_icon.png';
  static const String stopIcon = 'assets/icons/stop_icon.png';
  static const String holdSpeakIcon = 'assets/icons/hold_speak_icon.png';
  static const String keyboardIcon = 'assets/icons/keyboard_icon.png';
  static const String attachIcon = 'assets/icons/attach_icon.png';
  static const String deepResearchIcon = 'assets/icons/deep_research_icon.png';
  static const String likeIcon = 'assets/icons/like_icon.png';
  static const String dislikeIcon = 'assets/icons/dislike_icon.png';
  static const String copyIcon = 'assets/icons/copy_icon.png';
  static const String selectTextIcon = 'assets/icons/select_text_icon.png';
  static const String regenerateIcon = 'assets/icons/regenerate_icon.png';
  static const String reportIcon = 'assets/icons/report_icon.png';
  static const String speakIcon = 'assets/icons/speak_icon.png';
  static const String editIcon = 'assets/icons/edit_icon.png';
  static const String shareIcon = 'assets/icons/share_icon.png';
  static const String menuBarIcon = 'assets/icons/menu_bar_icon.png';
  static const String newChatIcon = 'assets/icons/new_chat_icon.png';
  static const String premiumIcon = 'assets/icons/premium_icon.png';
  static const String imageHistoryIcon = 'assets/icons/image_history_icon.png';
  static const String settingsIcon = 'assets/icons/settings_icon.png';
  static const String cameraIcon = 'assets/icons/camera_icon.png';
  static const String galleryIcon = 'assets/icons/gallery_icon.png';
  static const String fileIcon = 'assets/icons/file_icon.png';
  static const String googlePayIcon = 'assets/icons/google_pay_icon.png';
  static const String phonePeIcon = 'assets/icons/phonepe_icon.png';
  static const String paytmIcon = 'assets/icons/paytm_icon.png';
  static const String upiIcon = 'assets/icons/upi_icon.png';
  static const String closeIcon = 'assets/icons/close_icon.png';
  static const String deleteIcon = 'assets/icons/delete_icon.png';
  static const String pinIcon = 'assets/icons/pin_icon.png';
  static const String voice1Icon = 'assets/icons/voice1_icon.png';
  static const String voice2Icon = 'assets/icons/voice2_icon.png';
  static const String voice3Icon = 'assets/icons/voice3_icon.png';
  static const String voice4Icon = 'assets/icons/voice4_icon.png';
  static const String voice5Icon = 'assets/icons/voice5_icon.png';
  static const String okIcon = 'assets/icons/ok_icon.png';
  static const String arrowDownIcon = 'assets/icons/arrow_down_icon.png';
  static const String arrowIcon = 'assets/icons/arrow_icon.png';
  static const String falseIcon = 'assets/icons/false_icon.png';
  static const String policyIcon = 'assets/icons/policy_icon.png';
  static const String dataSafetyIcon = 'assets/icons/data_safety_icon.png';
  static const String liveAIicon = 'assets/icons/live_ai_icon.png';
    
}

class DynamicAssets {
  static const String appLogo = newAppIconUrl;
}

// ===========================================
// ENHANCED PNG WIDGET - WITH LOCAL FALLBACK AND LOGO CLICK HANDLER
// ===========================================
class AppPNG extends StatelessWidget {
  final String? networkUrl;
  final String localAsset;
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;
  final bool showBackground;
  final BoxFit fit;
  final double borderRadius;
  final VoidCallback? onTap;

  final String? semanticLabel;

  const AppPNG({
    super.key,
    this.networkUrl,
    required this.localAsset,
    this.size = 24,
    this.backgroundColor,
    this.iconColor,
    this.showBackground = true,
    this.fit = BoxFit.contain,
    this.borderRadius = 8,
    this.onTap,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    final Color bgColor = backgroundColor ?? (showBackground
        ? (isDarkTheme ? const Color(0xFF111111) : Colors.white)
        : Colors.transparent);

    return Semantics(
      label: semanticLabel,
      button: onTap != null,
      child: GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: showBackground
            ? BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: isDarkTheme ? const Color(0xFF333333) : Colors.grey[300]!,
                  width: 1,
                ),
              )
            : null,
        child: Center(
          child: _buildImage(context, isDarkTheme),
        ),
      ),
    ),
    );
  }

  Widget _buildImage(BuildContext context, bool isDarkTheme) {
    if (networkUrl != null) {
      return CachedNetworkImage(
        imageUrl: networkUrl!,
        width: showBackground ? size * 0.7 : size,
        height: showBackground ? size * 0.7 : size,
        fit: fit,
        placeholder: (context, url) => _buildPlaceholder(isDarkTheme),
        errorWidget: (context, url, error) => _buildLocalAsset(isDarkTheme),
        cacheManager: DefaultCacheManager(),
        memCacheWidth: (size * 2).toInt(),   // 2× for retina, no over-allocation
        memCacheHeight: (size * 2).toInt(),
      );
    }
    
    return _buildLocalAsset(isDarkTheme);
  }

  Widget _buildLocalAsset(bool isDarkTheme) {
    return Image.asset(
      localAsset,
      width: showBackground ? size * 0.7 : size,
      height: showBackground ? size * 0.7 : size,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return _buildFallbackIcon(isDarkTheme);
      },
    );
  }

  Widget _buildFallbackIcon(bool isDarkTheme) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isDarkTheme ? const Color(0xFF222222) : Colors.grey[200],
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Center(
        child: Icon(
          Icons.image_not_supported,
          size: size * 0.5,
          color: isDarkTheme ? Colors.grey[400] : Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(bool isDarkTheme) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isDarkTheme ? const Color(0xFF1A1A1A) : Colors.grey[100],
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Center(
        child: SizedBox(
          width: size * 0.3,
          height: size * 0.3,
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primaryBlue,
          ),
        ),
      ),
    );
  }
}

// ===========================================
// FIXED: ENVIRONMENT CONFIG WITH PROPER VALIDATION
// ===========================================
class EnvironmentConfig {
  static final EnvironmentConfig _instance = EnvironmentConfig._internal();
  factory EnvironmentConfig() => _instance;
  EnvironmentConfig._internal();

  late final ProductionLogger _logger;
  late final RemoteConfigService _remoteConfig;
  
  static const String sentryDsn = String.fromEnvironment('SENTRY_DSN');
  static const String backendBaseUrl = String.fromEnvironment('BACKEND_BASE_URL');
  static const String environment = String.fromEnvironment('ENVIRONMENT', defaultValue: 'production');
  static const String webSocketUrl = String.fromEnvironment('WEBSOCKET_URL');
  static const String wakeWordDetectionUrl = String.fromEnvironment('WAKE_WORD_DETECTION_URL');
  
  String _sentryDsn = sentryDsn;
  String _backendBaseUrl = backendBaseUrl;
  String _environment = environment;
  String _webSocketUrl = webSocketUrl;
  String _wakeWordDetectionUrl = wakeWordDetectionUrl;
  bool _isInitialized = false;

  Future<void> initialize({ProductionLogger? logger}) async {
    if (_isInitialized) return;
    
    _logger = logger ?? ProductionLogger();
    await _logger.initialize();
    _remoteConfig = RemoteConfigService(logger: _logger);
    
    try {
      try {
        await _remoteConfig.initialize();
        
        _sentryDsn = _remoteConfig.getString('sentry_dsn', defaultValue: _sentryDsn);
        _backendBaseUrl = _remoteConfig.getString('api_base_url', defaultValue: _backendBaseUrl);
        _environment = _remoteConfig.getString('environment', defaultValue: _environment);
        _webSocketUrl = _remoteConfig.getString('websocket_url', defaultValue: _webSocketUrl);
        _wakeWordDetectionUrl = _remoteConfig.getString('wake_word_detection_url', defaultValue: _wakeWordDetectionUrl);
      } catch (e) {
        _logger.w('Remote config failed, using dart-define defaults', error: e);
      }
      
      _validateConfig();
      _isInitialized = true;
      
      _logger.i('Environment config initialized with backend: $_backendBaseUrl');
    } catch (e, stack) {
      _logger.e('Failed to initialize environment config', error: e, stackTrace: stack);
      rethrow;
    }
  }

  void _validateConfig() {
    if (_sentryDsn.isEmpty) {
      _logger.w('Sentry DSN not configured');
    }
    
    if (_backendBaseUrl.isEmpty) {
      _logger.w('[Config] BACKEND_BASE_URL not set — backend features will show maintenance message');
    }
    
    if (_webSocketUrl.isEmpty) {
      _webSocketUrl = _backendBaseUrl.replaceFirst('http', 'ws');
    }

    if (_wakeWordDetectionUrl.isEmpty) {
      final wsBase = _webSocketUrl.endsWith('/')
          ? _webSocketUrl.substring(0, _webSocketUrl.length - 1)
          : _webSocketUrl;
      _wakeWordDetectionUrl = '$wsBase/ws/wake-word';
      _logger.w('WAKE_WORD_DETECTION_URL not set — using fallback: $_wakeWordDetectionUrl');
    }
    
  }

  String get sentryDsn => _sentryDsn;
  String get backendBaseUrl => _backendBaseUrl;
  String get environment => _environment;
  String get webSocketUrl => _webSocketUrl;
  String get wakeWordDetectionUrl => _wakeWordDetectionUrl;
  bool get isProduction => _environment == 'production';
  bool get isInitialized => _isInitialized;
}

// ===========================================
// FIXED: PRODUCTION LOGGER WITH SALTED HASH AND PII FILTERING
// ===========================================
class ProductionLogger {
  final Logger _logger;
  final bool _isProduction;
  final List<LogEntry> _logBuffer = [];
  static const int _maxBufferSize = 1000;
  static const String _hashSalt = String.fromEnvironment('LOG_HASH_SALT');
  static const int _maxLogFileSizeBytes = 2 * 1024 * 1024; // 2MB
  final Map<String, int> _errorCounts = {};
  static const int _errorDedupeThreshold = 10;
  Timer? _flushTimer;
  
  static final RegExp _emailPattern    = RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}');
  static final RegExp _phonePattern    = RegExp(r'[\+]?[(]?[0-9]{3}[)]?[-\s\.]?[0-9]{3}[-\s\.]?[0-9]{4,6}');
  static final RegExp _tokenPattern    = RegExp(r'Bearer\s+[A-Za-z0-9\-._~+/]+=*', caseSensitive: false);
  static final RegExp _aadhaarPattern  = RegExp(r'\b[2-9]{1}[0-9]{3}\s?[0-9]{4}\s?[0-9]{4}\b');
  static final RegExp _panPattern      = RegExp(r'\b[A-Z]{5}[0-9]{4}[A-Z]{1}\b');
  static final RegExp _jwtPattern      = RegExp(r'eyJ[A-Za-z0-9\-_]+\.[A-Za-z0-9\-_]+\.[A-Za-z0-9\-_]*');
  static final RegExp _apiKeyPattern   = RegExp(r'(api[_-]?key|secret|password|token)\s*[:=]\s*["\']?[A-Za-z0-9\-_]{8,}', caseSensitive: false);
  static final RegExp _ipv4Pattern     = RegExp(r'\b(?:[0-9]{1,3}\.){3}[0-9]{1,3}\b');
  static final RegExp _creditCardPat   = RegExp(r'\b(?:4[0-9]{12}(?:[0-9]{3})?|5[1-5][0-9]{14}|3[47][0-9]{13})\b');

  ProductionLogger({bool isProduction = true}) 
      : _isProduction = isProduction,
        _logger = Logger(
          printer: PrettyPrinter(
            methodCount: 0,
            errorMethodCount: 5,
            lineLength: 80,
            colors: kDebugMode,
            printEmojis: false,
            printTime: true,
          ),
          filter: ProductionLogFilter(isProduction: isProduction),
          output: ProductionLogOutput(isProduction: isProduction),
        );

  Future<void> initialize() async {
  }

  String _filterPII(String message) {
    String filtered = message;
    filtered = _emailPattern.replaceAll(filtered, '[EMAIL]');
    filtered = _phonePattern.replaceAll(filtered, '[PHONE]');
    filtered = _tokenPattern.replaceAll(filtered, 'Bearer [TOKEN]');
    filtered = _aadhaarPattern.replaceAll(filtered, '[AADHAAR]');
    filtered = _panPattern.replaceAll(filtered, '[PAN]');
    filtered = _jwtPattern.replaceAll(filtered, '[JWT]');
    filtered = _apiKeyPattern.replaceAll(filtered, r'\1=[KEY]');
    filtered = _ipv4Pattern.replaceAll(filtered, '[IP]');
    filtered = _creditCardPat.replaceAll(filtered, '[CARD]');
    return filtered;
  }

  void d(String message, {dynamic error, StackTrace? stackTrace}) {
    final filteredMessage = _filterPII(message);
    if (kDebugMode) {
      _logger.d(filteredMessage, error: error, stackTrace: stackTrace);
    }
    _addToBuffer(LogLevel.debug, filteredMessage, error, stackTrace);
  }

  void i(String message, {dynamic error, StackTrace? stackTrace}) {
    final filteredMessage = _filterPII(message);
    _logger.i(filteredMessage, error: error, stackTrace: stackTrace);
    _addToBuffer(LogLevel.info, filteredMessage, error, stackTrace);
    _sendToSentry(filteredMessage, SentryLevel.info, error, stackTrace);
  }

  void w(String message, {dynamic error, StackTrace? stackTrace}) {
    final filteredMessage = _filterPII(message);
    _logger.w(filteredMessage, error: error, stackTrace: stackTrace);
    _addToBuffer(LogLevel.warning, filteredMessage, error, stackTrace);
    _sendToSentry(filteredMessage, SentryLevel.warning, error, stackTrace);
  }

  void e(String message, {dynamic error, StackTrace? stackTrace}) {
    final filteredMessage = _filterPII(message);
    _logger.e(filteredMessage, error: error, stackTrace: stackTrace);
    _addToBuffer(LogLevel.error, filteredMessage, error, stackTrace);
    _sendToSentry(filteredMessage, SentryLevel.error, error, stackTrace);
    
    if (_isProduction) {
      try {
        FirebaseCrashlytics.instance.recordError(error ?? message, stackTrace);
      } catch (e) {
        if (kDebugMode) { _logger.d('Crashlytics error suppressed in production'); }
      }
    }
  }

  void _addToBuffer(LogLevel level, String message, dynamic error, StackTrace? stackTrace) {
    if (level == LogLevel.error && error != null) {
      final key = error.toString().substring(0, error.toString().length.clamp(0, 80));
      _errorCounts[key] = (_errorCounts[key] ?? 0) + 1;
      if (_errorCounts[key]! > _errorDedupeThreshold) {
        if (_errorCounts[key]! % 50 != 0) return;
      }
    }

    _logBuffer.add(LogEntry(
      timestamp: DateTime.now(),
      level: level,
      message: message,
      error: error?.toString(),
      stackTrace: stackTrace?.toString(),
    ));

    if (_logBuffer.length > _maxBufferSize) {
      _logBuffer.removeAt(0);
    }

    if (level == LogLevel.error || level == LogLevel.warning) {
      _scheduleFlushToDisk();
    }
  }

  void _scheduleFlushToDisk() {
    _flushTimer?.cancel();
    _flushTimer = Timer(const Duration(seconds: 5), () => unawaited(_flushToDisk()));
  }

  Future<void> _flushToDisk() async {
    if (_logBuffer.isEmpty) return;
    try {
      final dir = await getApplicationDocumentsDirectory();
      final logFile = File('${dir.path}/askroa_error.log');
      if (await logFile.exists()) {
        final stat = await logFile.stat();
        if (stat.size > _maxLogFileSizeBytes) {
          final backup = File('${dir.path}/askroa_error_old.log');
          await logFile.copy(backup.path);
          await logFile.delete();
        }
      }
      final errors = _logBuffer
          .where((e) => e.level == LogLevel.error || e.level == LogLevel.warning)
          .map((e) => '[${e.timestamp.toIso8601String()}] ${e.level.name}: ${e.message}'
              '${e.error != null ? "\n  ERROR: ${e.error}" : ""}')
          .join('\n');
      if (errors.isNotEmpty) {
        await logFile.writeAsString('$errors\n', mode: FileMode.append);
      }
    } catch (_) {}
  }

  bool _inSentry = false;
  void _sendToSentry(String message, SentryLevel level, dynamic error, StackTrace? stackTrace) {
    if (!_isProduction || _inSentry) return;
    _inSentry = true;
    try {
      unawaited(Sentry.captureException(error ?? message, stackTrace: stackTrace, level: level));
    } catch (_) {}
    finally { _inSentry = false; }
  }

  void logApiCall(String endpoint, int statusCode, int durationMs, {String? userId}) {
    final sanitizedEndpoint = _sanitizeSensitiveData(endpoint);
    final hashedUserId = _hashUserIdWithSalt(userId);
    
    final data = {
      'endpoint': sanitizedEndpoint,
      'status_code': statusCode,
      'duration_ms': durationMs,
      'user_id': hashedUserId,
    };
    
    i('API Call: $sanitizedEndpoint - $statusCode (${durationMs}ms)');
    
    if (_isProduction) {
      try {
        Sentry.addBreadcrumb(Breadcrumb(
          message: 'API Call',
          data: data,
          level: SentryLevel.info,
        ));
      } catch (e) {
        if (kDebugMode) { _logger.d('Sentry breadcrumb error suppressed'); }
      }
    }
  }

  String _sanitizeSensitiveData(String input) {
    try {
      final uri = Uri.tryParse(input);
      if (uri != null) {
        return '${uri.path}${uri.hasQuery ? '?[REDACTED]' : ''}';
      }
    } catch (_) {}
    return input;
  }

  String _hashUserIdWithSalt(String? userId) {
    if (userId == null) return 'null';
    try {
      final saltedInput = '$_hashSalt:$userId:${DateTime.now().millisecondsSinceEpoch % 1000}';
      return sha256.convert(utf8.encode(saltedInput)).toString().substring(0, 16);
    } catch (_) {
      return 'invalid';
    }
  }

  List<LogEntry> getRecentLogs({LogLevel? minLevel, int limit = 100}) {
    var logs = _logBuffer;
    if (minLevel != null) {
      logs = logs.where((log) => log.level.index >= minLevel.index).toList();
    }
    return logs.reversed.take(limit).toList();
  }

  void dispose() {
    _flushTimer?.cancel();
    _flushTimer = null;
    unawaited(_flushToDisk());
    _logBuffer.clear();
    _errorCounts.clear();
  }
}

enum LogLevel { debug, info, warning, error }

class LogEntry {
  final DateTime timestamp;
  final LogLevel level;
  final String message;
  final String? error;
  final String? stackTrace;

  LogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
    this.error,
    this.stackTrace,
  });
}

class ProductionLogFilter extends LogFilter {
  final bool isProduction;
  
  ProductionLogFilter({required this.isProduction});

  @override
  bool shouldLog(LogEvent event) {
    if (isProduction && event.level.index < Level.info.index) {
      return false;
    }
    return true;
  }
}

class ProductionLogOutput extends LogOutput {
  final bool isProduction;
  
  ProductionLogOutput({required this.isProduction});

  @override
  void output(OutputEvent event) {
    // ignore: avoid_print
  }
}

// ===========================================
// FIXED: PRODUCTION ENCRYPTION SERVICE WITH PROPER KEY ROTATION AND BACKUP CLEANUP
// ===========================================
class ProductionEncryptionService {
  final ProductionLogger _logger;
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
  );
  static const String _keyStorageKey        = 'askroa_enc_key_v5';
  static const String _backupKeyStorageKey   = 'askroa_enc_key_v5_backup';
  static const String _prevBackupKeyKey      = 'askroa_enc_key_v5_prev';
  static const String _keyRotationTsKey      = 'askroa_key_rotation_ts_v5';
  static const String _hmacKeyStorageKey     = 'askroa_hmac_key_v5';
  static const int    _ivLengthBytes         = 16;
  static const int    _aesKeyLengthBytes     = 32;
  static const int    _hmacKeyLengthBytes    = 32;
  static const int    _maxIvCacheSize        = 1000;
  static const Duration _keyRotationInterval = Duration(days: 90);
  static const Duration _ivCacheCleanInterval = Duration(hours: 1);
  static const Duration _backupKeyRetention   = Duration(days: 30);

  bool _isInitialized = false;

  late encrypt.Key _aesKey;
  late encrypt.Encrypter _encrypter;
  late List<int> _hmacKeyBytes;

  final Set<String> _usedIvCache = {};
  Timer? _keyRotationTimer;
  Timer? _backupDeletionTimer;
  Timer? _ivCacheCleanupTimer;
  final Mutex _keyMutex = Mutex();
  final Mutex _initMutex = Mutex();

  ProductionEncryptionService({required ProductionLogger logger}) : _logger = logger;

  Future<void> initialize() async {
    await _initMutex.acquire();
    try {
      if (_isInitialized) return;
      await _loadOrGenerateKeys();
      _startTimers();
      _isInitialized = true;
      _logger.i('[Enc] AES-256-GCM + HMAC-SHA256 initialized');
    } catch (e, stack) {
      _logger.e('[Enc] Initialization failed', error: e, stackTrace: stack);
      rethrow;
    } finally {
      _initMutex.release();
    }
  }

  Future<void> _loadOrGenerateKeys() async {
    String? aesKeyStr  = await _secureStorage.read(key: _keyStorageKey);
    String? hmacKeyStr = await _secureStorage.read(key: _hmacKeyStorageKey);

    if (aesKeyStr == null) {
      final rng = Random.secure();
      final aesBytes  = List<int>.generate(_aesKeyLengthBytes,  (_) => rng.nextInt(256));
      final hmacBytes = List<int>.generate(_hmacKeyLengthBytes, (_) => rng.nextInt(256));
      aesKeyStr  = base64Url.encode(aesBytes);
      hmacKeyStr = base64Url.encode(hmacBytes);
      await _secureStorage.write(key: _keyStorageKey,     value: aesKeyStr);
      await _secureStorage.write(key: _hmacKeyStorageKey, value: hmacKeyStr);
      _logger.d('[Enc] Fresh AES + HMAC keys generated');
    }

    _aesKey      = encrypt.Key.fromBase64(aesKeyStr);
    _encrypter   = encrypt.Encrypter(encrypt.AES(_aesKey, mode: encrypt.AESMode.gcm));
    _hmacKeyBytes = base64Url.decode(hmacKeyStr ?? base64Url.encode(
      List<int>.generate(_hmacKeyLengthBytes, (_) => Random.secure().nextInt(256)),
    ));
  }

  void _startTimers() {
    _keyRotationTimer?.cancel();
    _ivCacheCleanupTimer?.cancel();
    _keyRotationTimer = Timer.periodic(_keyRotationInterval, (_) => rotateEncryptionKey());
    _ivCacheCleanupTimer = Timer.periodic(_ivCacheCleanInterval, (_) {
      if (_usedIvCache.length > _maxIvCacheSize) _usedIvCache.clear();
    });
  }

  void restartKeyRotationTimer() {
    _startTimers();
    _logger.d('[Enc] Timers restarted');
  }

  String _generateHmac(String data) {
    final hmac = Hmac(sha256, _hmacKeyBytes);
    return hmac.convert(utf8.encode(data)).toString();
  }

  bool _verifyHmac(String data, String expectedHmac) {
    final actual = _generateHmac(data);
    if (actual.length != expectedHmac.length) return false;
    var result = 0;
    for (var i = 0; i < actual.length; i++) {
      result |= actual.codeUnitAt(i) ^ expectedHmac.codeUnitAt(i);
    }
    return result == 0;
  }

  String encrypt(String plainText) {
    if (!_isInitialized) throw StateError('[Enc] Not initialized');
    if (plainText.isEmpty) throw ArgumentError('[Enc] plainText must not be empty');
    try {
      encrypt.IV iv;
      String ivBase64;
      do {
        iv      = encrypt.IV.fromSecureRandom(_ivLengthBytes);
        ivBase64 = iv.base64;
      } while (_usedIvCache.contains(ivBase64));
      _usedIvCache.add(ivBase64);

      final encrypted = _encrypter.encrypt(plainText, iv: iv);
      final payload   = '$ivBase64:${encrypted.base64}';
      final hmac      = _generateHmac(payload);
      return '$payload:$hmac';
    } catch (e) {
      _logger.e('[Enc] encrypt() failed', error: e);
      throw Exception('[Enc] Encryption failed: $e');
    }
  }

  Future<String> decrypt(String encryptedText) async {
    if (!_isInitialized) throw StateError('[Enc] Not initialized');
    try {
      return _decryptWithKey(encryptedText, _encrypter, verifyHmac: true);
    } catch (e) {
      _logger.w('[Enc] Primary decrypt failed, trying backups', error: e);
      return await _decryptWithBackupKeys(encryptedText);
    }
  }

  String _decryptWithKey(
    String encryptedText,
    encrypt.Encrypter encrypter, {
    bool verifyHmac = true,
  }) {
    final parts = encryptedText.split(':');
    if (parts.length == 3 && verifyHmac) {
      final payload  = '${parts[0]}:${parts[1]}';
      final hmac     = parts[2];
      if (!_verifyHmac(payload, hmac)) {
        throw Exception('[Enc] HMAC verification failed — data may be tampered');
      }
      final iv        = encrypt.IV.fromBase64(parts[0]);
      final encrypted = encrypt.Encrypted.fromBase64(parts[1]);
      return encrypter.decrypt(encrypted, iv: iv);
    } else if (parts.length == 2) {
      final iv        = encrypt.IV.fromBase64(parts[0]);
      final encrypted = encrypt.Encrypted.fromBase64(parts[1]);
      return encrypter.decrypt(encrypted, iv: iv);
    }
    throw FormatException('[Enc] Unexpected ciphertext format (${parts.length} segments)');
  }

  Future<String> _decryptWithBackupKeys(String encryptedText) async {
    for (final keyStoreName in [_backupKeyStorageKey, _prevBackupKeyKey]) {
      try {
        final keyStr = await _secureStorage.read(key: keyStoreName);
        if (keyStr == null) continue;
        final backupKey      = encrypt.Key.fromBase64(keyStr);
        final backupEncrypter = encrypt.Encrypter(encrypt.AES(backupKey, mode: encrypt.AESMode.gcm));
        final result = _decryptWithKey(encryptedText, backupEncrypter, verifyHmac: false);
        _logger.i('[Enc] Decrypted with backup key $keyStoreName');
        return result;
      } catch (_) {
        continue;
      }
    }
    _logger.e('[Enc] All decryption attempts exhausted');
    return '[DECRYPTION_FAILED]';
  }

  Future<Map<String, dynamic>> encryptData(Map<String, dynamic> data) async {
    if (!_isInitialized) throw StateError('[Enc] Not initialized');
    try {
      final jsonString = jsonEncode(data);
      final encrypted  = encrypt(jsonString);
      return {
        'encrypted_data':     encrypted,
        'encryption_version': 'aes256-gcm-hmac-sha256-v5',
        'timestamp':          DateTime.now().toUtc().toIso8601String(),
      };
    } catch (e) {
      _logger.e('[Enc] encryptData() failed', error: e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> decryptData(String encryptedData) async {
    final decrypted = await decrypt(encryptedData);
    if (decrypted == '[DECRYPTION_FAILED]') throw Exception('[Enc] decryptData() failed');
    return jsonDecode(decrypted) as Map<String, dynamic>;
  }

  String encryptToken(String token) => encrypt(token);

  Future<String> decryptToken(String encryptedToken) async => await decrypt(encryptedToken);

  Future<void> rotateEncryptionKey() async {
    await _keyMutex.acquire();
    try {
      _logger.i('[Enc] Starting key rotation');
      final rng          = Random.secure();
      final newAesBytes  = List<int>.generate(_aesKeyLengthBytes,  (_) => rng.nextInt(256));
      final newHmacBytes = List<int>.generate(_hmacKeyLengthBytes, (_) => rng.nextInt(256));
      final newAesStr    = base64Url.encode(newAesBytes);
      final newHmacStr   = base64Url.encode(newHmacBytes);

      final oldAesKey = await _secureStorage.read(key: _keyStorageKey);
      if (oldAesKey != null) {
        final prevBackup = await _secureStorage.read(key: _backupKeyStorageKey);
        if (prevBackup != null) {
          await _secureStorage.write(key: _prevBackupKeyKey, value: prevBackup);
        }
        await _secureStorage.write(key: _backupKeyStorageKey, value: oldAesKey);
      }

      await _secureStorage.write(key: _keyStorageKey,     value: newAesStr);
      await _secureStorage.write(key: _hmacKeyStorageKey, value: newHmacStr);

      _aesKey      = encrypt.Key.fromBase64(newAesStr);
      _encrypter   = encrypt.Encrypter(encrypt.AES(_aesKey, mode: encrypt.AESMode.gcm));
      _hmacKeyBytes = newHmacBytes;
      _usedIvCache.clear();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyRotationTsKey, DateTime.now().toUtc().toIso8601String());

      _logger.i('[Enc] Key rotation complete');

      _backupDeletionTimer?.cancel();
      _backupDeletionTimer = Timer(_backupKeyRetention, () async {
        await _secureStorage.delete(key: _prevBackupKeyKey);
        _backupDeletionTimer = null;
        _logger.d('[Enc] Expired backup key purged');
      });
    } catch (e, stack) {
      _logger.e('[Enc] Key rotation failed', error: e, stackTrace: stack);
    } finally {
      _keyMutex.release();
    }
  }

  bool get isInitialized => _isInitialized;

  void dispose() {
    _keyRotationTimer?.cancel();
    _backupDeletionTimer?.cancel();
    _ivCacheCleanupTimer?.cancel();
    _usedIvCache.clear();
  }
}

// ===========================================
// E2EE CHAT MESSAGE ENCRYPTION
// Per-session AES-256-GCM key: stored in FlutterSecureStorage under
// 'askroa_chat_key_<sessionId>'. Key is rotated with the 90-day cycle.
// encrypt() / decrypt() are called on every ChatMessage.text before
// storing to Drift and before sending to backend.
// ===========================================
extension ChatE2EE on ProductionEncryptionService {
  static const FlutterSecureStorage _e2eeStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
  );
  static const int _e2eeKeyBytes     = 32;
  static const int _e2eeIvBytes      = 16;
  static const int _e2eeHmacBytes    = 32;
  static const String _e2eeKeyPrefix  = 'askroa_e2ee_key_v2_';
  static const String _e2eeHmacPrefix = 'askroa_e2ee_hmac_v2_';

  Future<_E2EEKeys> _getOrCreateSessionKeys(String sessionId) async {
    final aesStorageKey  = '$_e2eeKeyPrefix$sessionId';
    final hmacStorageKey = '$_e2eeHmacPrefix$sessionId';

    String? aesStr  = await _e2eeStorage.read(key: aesStorageKey);
    String? hmacStr = await _e2eeStorage.read(key: hmacStorageKey);

    if (aesStr == null) {
      final rng  = Random.secure();
      final aes  = List<int>.generate(_e2eeKeyBytes,  (_) => rng.nextInt(256));
      final hmac = List<int>.generate(_e2eeHmacBytes, (_) => rng.nextInt(256));
      aesStr  = base64Url.encode(aes);
      hmacStr = base64Url.encode(hmac);
      await _e2eeStorage.write(key: aesStorageKey,  value: aesStr);
      await _e2eeStorage.write(key: hmacStorageKey, value: hmacStr);
    }

    return _E2EEKeys(
      aesKey:   encrypt.Key.fromBase64(aesStr),
      hmacKey:  base64Url.decode(hmacStr!),
    );
  }

  String _e2eeHmac(List<int> hmacKey, String data) {
    final h = Hmac(sha256, hmacKey);
    return h.convert(utf8.encode(data)).toString();
  }

  bool _e2eeVerifyHmac(List<int> hmacKey, String data, String expected) {
    final actual = _e2eeHmac(hmacKey, data);
    if (actual.length != expected.length) return false;
    var diff = 0;
    for (var i = 0; i < actual.length; i++) {
      diff |= actual.codeUnitAt(i) ^ expected.codeUnitAt(i);
    }
    return diff == 0;
  }

  Future<String> encryptChatMessage(String sessionId, String plainText) async {
    if (plainText.isEmpty) throw ArgumentError('[E2EE] plainText must not be empty');
    try {
      final keys      = await _getOrCreateSessionKeys(sessionId);
      final encrypter = encrypt.Encrypter(encrypt.AES(keys.aesKey, mode: encrypt.AESMode.gcm));
      final iv        = encrypt.IV.fromSecureRandom(_e2eeIvBytes);
      final encrypted = encrypter.encrypt(plainText, iv: iv);
      final payload   = '${iv.base64}:${encrypted.base64}';
      final hmac      = _e2eeHmac(keys.hmacKey, payload);
      return '$payload:$hmac';
    } catch (e) {
      throw Exception('[E2EE] encryptChatMessage failed: $e');
    }
  }

  Future<String> decryptChatMessage(String sessionId, String cipherText) async {
    try {
      final keys  = await _getOrCreateSessionKeys(sessionId);
      final parts = cipherText.split(':');
      if (parts.length == 3) {
        final payload = '${parts[0]}:${parts[1]}';
        if (!_e2eeVerifyHmac(keys.hmacKey, payload, parts[2])) {
          return '[E2EE_TAMPERED]';
        }
        final iv        = encrypt.IV.fromBase64(parts[0]);
        final enc       = encrypt.Encrypted.fromBase64(parts[1]);
        final encrypter = encrypt.Encrypter(encrypt.AES(keys.aesKey, mode: encrypt.AESMode.gcm));
        return encrypter.decrypt(enc, iv: iv);
      } else if (parts.length == 2) {
        final iv        = encrypt.IV.fromBase64(parts[0]);
        final enc       = encrypt.Encrypted.fromBase64(parts[1]);
        final encrypter = encrypt.Encrypter(encrypt.AES(keys.aesKey, mode: encrypt.AESMode.gcm));
        return encrypter.decrypt(enc, iv: iv);
      }
      return '[E2EE_DECRYPT_FAILED]';
    } catch (e) {
      return '[E2EE_DECRYPT_FAILED]';
    }
  }

  Future<void> deleteSessionKey(String sessionId) async {
    await _e2eeStorage.delete(key: '$_e2eeKeyPrefix$sessionId');
    await _e2eeStorage.delete(key: '$_e2eeHmacPrefix$sessionId');
  }

  Future<void> rotateSessionKey(String sessionId) async {
    await deleteSessionKey(sessionId);
    await _getOrCreateSessionKeys(sessionId);
  }
}

class _E2EEKeys {
  final encrypt.Key aesKey;
  final List<int>   hmacKey;
  const _E2EEKeys({required this.aesKey, required this.hmacKey});
}

// ===========================================
// IN-APP PURCHASE CONFIGURATION - FIXED: Platform-specific product IDs with proper validation
// ===========================================
class IAPConfig {
  static const Set<String> _androidProductIds = {
    'com.askroa.monthly_pro',
    'com.askroa.half_year_pro',
    'com.askroa.yearly_ultra_pro',
  };

  static const Set<String> _iosProductIds = {
    'com.askroa.ios.monthly_pro',
    'com.askroa.ios.half_year_pro',
    'com.askroa.ios.yearly_ultra_pro',
  };

  static const Set<String> _webProductIds = {
    'askroa_monthly_pro',
    'askroa_half_year_pro',
    'askroa_yearly_ultra_pro',
  };

  static const Set<String> _windowsProductIds = {
    'askroa.windows.monthly_pro',
    'askroa.windows.half_year_pro',
    'askroa.windows.yearly_ultra_pro',
  };

  static const Set<String> _macosProductIds = {
    'askroa.macos.monthly_pro',
    'askroa.macos.half_year_pro',
    'askroa.macos.yearly_ultra_pro',
  };

  static const Set<String> _linuxProductIds = {
    'askroa.linux.monthly_pro',
    'askroa.linux.half_year_pro',
    'askroa.linux.yearly_ultra_pro',
  };

  static Set<String> get productIds {
    if (kIsWeb) return _webProductIds;
    if (Platform.isAndroid) return _androidProductIds;
    if (Platform.isIOS) return _iosProductIds;
    if (Platform.isWindows) return _windowsProductIds;
    if (Platform.isMacOS) return _macosProductIds;
    if (Platform.isLinux) return _linuxProductIds;
    return {};
  }

  static bool get isSupported {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  static bool isPlatformSupported(BuildContext context) {
    if (!isSupported) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Not Available'),
            content: const Text('Subscriptions are only available on mobile devices (Android and iOS).'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      });
      return false;
    }
    return true;
  }
}

// ===========================================
// FIXED: WEBSOCKET SERVICE WITH EXPONENTIAL BACKOFF AND PROPER CLEANUP
// ===========================================
class WebSocketService {
  final ProductionLogger _logger;
  WebSocketChannel? _channel;
  WebSocketChannel? _wakeWordChannel;
  final Map<String, StreamController<String>> _streamControllers = {};
  final Map<String, StreamController<Map<String, dynamic>>> _wakeWordControllers = {};
  final ValueNotifier<bool> _isConnected = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isWakeWordConnected = ValueNotifier<bool>(false);
  Timer? _reconnectTimer;
  Timer? _wakeWordReconnectTimer;
  Timer? _heartbeatTimer;
  Timer? _wakeWordHeartbeatTimer;
  int _reconnectAttempts = 0;
  int _wakeWordReconnectAttempts = 0;
  static const int _maxReconnectAttempts = 10;
  static const Duration _baseDelay = Duration(seconds: 1);
  static const Duration _maxDelay = Duration(minutes: 5);
  static const Duration _heartbeatInterval = Duration(seconds: 30);
  
  final List<Map<String, dynamic>> _pendingMessages = [];
  bool _isInitialized = false;
  bool _isDisposed = false;
  final Mutex _reconnectMutex = Mutex();

  ValueNotifier<bool> get isConnected => _isConnected;
  ValueNotifier<bool> get isWakeWordConnected => _isWakeWordConnected;

  WebSocketService({required ProductionLogger logger}) : _logger = logger;

  final List<String> _backupPins = [];

  void addDynamicPin(String pin) {
    if (!_pins.contains(pin) && !_backupPins.contains(pin)) {
      _backupPins.add(pin);
      _logger.d('[CertPin] Dynamic pin added: ${pin.substring(0, 12)}...');
    }
  }

  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;
  }

  Future<void> connect() async {
    if (_isDisposed) return;
    
    await _reconnectMutex.acquire();
    try {
      if (_channel != null && _isConnected.value) {
        _sendHeartbeat();
        return;
      }

      _reconnectAttempts = 0;
      final envConfig = EnvironmentConfig();
      final wsUrl = envConfig.webSocketUrl;
      final uri = Uri.parse(wsUrl);
      
      _channel = WebSocketChannel.connect(uri);
      
      _channel!.stream.listen(
        (message) => _handleMessage(message),
        onError: (error) => _handleError(error),
        onDone: () => _handleDisconnect(),
        cancelOnError: true,
      );

      _isConnected.value = true;
      _reconnectAttempts = 0;
      
      await _sendAuthentication();
      _startHeartbeat();
      _sendPendingMessages();
      
      _logger.i('WebSocket connected to $wsUrl');
    } catch (e, stack) {
      _logger.d('WebSocket connection failed', error: e, stackTrace: stack);
      _scheduleReconnect();
    } finally {
      _reconnectMutex.release();
    }
  }

  Future<void> connectWakeWordDetection({List<String>? wakePhrases}) async {
    if (_isDisposed) return;
    
    try {
      if (_wakeWordChannel != null && _isWakeWordConnected.value) {
        return;
      }

      _wakeWordReconnectAttempts = 0;
      final envConfig = EnvironmentConfig();
      final wsUrl = envConfig.wakeWordDetectionUrl;
      final uri = Uri.parse(wsUrl);
      
      _wakeWordChannel = WebSocketChannel.connect(uri);

      Timer? inactivityTimer;
      void resetInactivityTimer() {
        inactivityTimer?.cancel();
        inactivityTimer = Timer(const Duration(seconds: 10), () {
          if (!_isDisposed && _isWakeWordConnected.value) {
            _logger.w('[WakeWord] No response in 10s — disconnecting');
            _handleWakeWordDisconnect();
          }
        });
      }
      
      _wakeWordChannel!.stream.listen(
        (message) {
          resetInactivityTimer();
          _handleWakeWordMessage(message);
        },
        onError: (error) {
          inactivityTimer?.cancel();
          _handleWakeWordError(error);
        },
        onDone: () {
          inactivityTimer?.cancel();
          _handleWakeWordDisconnect();
        },
        cancelOnError: true,
      );

      _isWakeWordConnected.value = true;
      _wakeWordReconnectAttempts = 0;
      
      try {
        final secureStorage = AppSecureStorage.instance;
        final encryptedToken = await secureStorage.read(key: 'askroa_access_token');
        String? token;
        if (encryptedToken != null) {
          final encryption = ProductionEncryptionService(logger: _logger);
          await encryption.initialize();
          final decrypted = await encryption.decrypt(encryptedToken);
          if (decrypted != '[DECRYPTION_FAILED]') token = decrypted;
        }
        final authMessage = jsonEncode({
          'type': 'auth',
          if (token != null) 'token': token,
          'wake_phrases': wakePhrases ?? ['hey_askroa', 'askroa'],
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
        _wakeWordChannel!.sink.add(authMessage);
      } catch (e) {
        _logger.d('[WakeWord] Auth/wake-phrases send failed', error: e);
      }

      resetInactivityTimer();
      _startWakeWordHeartbeat();
      
      _logger.i('Wake Word WebSocket connected to $wsUrl');
    } catch (e, stack) {
      _logger.d('Wake Word WebSocket connection failed', error: e, stackTrace: stack);
      _scheduleWakeWordReconnect();
    }
  }

  Future<void> _sendAuthentication() async {
    try {
    final secureStorage = AppSecureStorage.instance;
      final encryptedToken = await secureStorage.read(key: 'askroa_access_token');

      if (encryptedToken != null) {
        final encryption = ProductionEncryptionService(logger: _logger);
        await encryption.initialize();
        final token = await encryption.decrypt(encryptedToken);

        final authMessage = jsonEncode({
          'type': 'auth',
          'token': token,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });

        if (_channel != null && _isConnected.value) {
          _channel!.sink.add(authMessage);
        }
        if (_wakeWordChannel != null && _isWakeWordConnected.value) {
          _wakeWordChannel!.sink.add(authMessage);
        }

        _logger.d('WebSocket authentication sent');
      }
    } catch (e, stack) {
      _logger.d('WebSocket authentication failed', error: e, stackTrace: stack);
    }
  }
  
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (timer) {
      _sendHeartbeat();
    });
  }

  void _startWakeWordHeartbeat() {
    _wakeWordHeartbeatTimer?.cancel();
    _wakeWordHeartbeatTimer = Timer.periodic(_heartbeatInterval, (timer) {
      _sendWakeWordHeartbeat();
    });
  }
  
  void _sendHeartbeat() {
    if (_isConnected.value && _channel != null && !_isDisposed) {
      try {
        _channel!.sink.add(jsonEncode({'type': 'ping'}));
      } catch (e) {
        _handleDisconnect();
      }
    }
  }

  void _sendWakeWordHeartbeat() {
    if (_isWakeWordConnected.value && _wakeWordChannel != null && !_isDisposed) {
      try {
        _wakeWordChannel!.sink.add(jsonEncode({'type': 'ping'}));
      } catch (e) {
        _handleWakeWordDisconnect();
      }
    }
  }
  
  void _queueMessage(Map<String, dynamic> message) {
    _pendingMessages.add(message);
    if (_pendingMessages.length > 1000) {
      _pendingMessages.removeAt(0);
    }
  }
  
  void _sendPendingMessages() {
    if (_pendingMessages.isEmpty) return;
    
    final messages = List<Map<String, dynamic>>.from(_pendingMessages);
    _pendingMessages.clear();
    
    for (final message in messages) {
      try {
        if (_channel != null && _isConnected.value) {
          _channel!.sink.add(jsonEncode(message));
        } else {
          _queueMessage(message);
        }
      } catch (e) {
        _queueMessage(message);
        break;
      }
    }
  }

  void _handleMessage(dynamic message) {
    try {
      final dynamic decoded = jsonDecode(message.toString());
      if (decoded is! Map<String, dynamic>) {
        _logger.w('[WS] Received non-object message: ${message.toString().substring(0, 100)}');
        return;
      }
      final data = decoded;
      final type = data['type'] as String?;
      final streamId = data['stream_id'] as String?;
      final content = data['content'] as String?;
      
      if (type == 'pong') {
        return;
      }
      
      if (type == 'chat_stream' && streamId != null && content != null) {
        final controller = _streamControllers[streamId];
        if (controller != null && !controller.isClosed) {
          controller.add(content);
        }
        
        final isFinal = data['is_final'] as bool? ?? false;
        if (isFinal) {
          final thinkingText = data['thinking_text'] as String? ?? '';
          final isThinking   = data['is_thinking']   as bool?   ?? false;
          if (isThinking && thinkingText.isNotEmpty) {
            final ctrl = _streamControllers[streamId];
            if (ctrl != null && !ctrl.isClosed) {
              ctrl.add('__THINKING__:${thinkingText}');
            }
          }
          final doneModelUsed = data['model_used'] as String?;
          if (doneModelUsed != null && doneModelUsed.isNotEmpty) {
            final ctrl = _streamControllers[streamId];
            if (ctrl != null && !ctrl.isClosed) {
              ctrl.add('__MODEL_USED__:${doneModelUsed}');
            }
          }
          final controller = _streamControllers[streamId];
          if (controller != null && !controller.isClosed) {
            controller.close();
            _streamControllers.remove(streamId);
            LazyLoader.unregisterController(controller);
          }
        }
      } else if (type == 'thinking_chunk' && streamId != null) {
        final thinkChunk = data['thinking'] as String? ?? content ?? '';
        if (thinkChunk.isNotEmpty) {
          final controller = _streamControllers[streamId];
          if (controller != null && !controller.isClosed) {
            controller.add('__THINKING_CHUNK__:${thinkChunk}');
          }
        }
      } else if (type == 'error') {
        final error = data['error'] as String?;
        final controller = _streamControllers[data['stream_id'] as String?];
        if (controller != null && !controller.isClosed) {
          controller.addError(error ?? 'Unknown error');
          controller.close();
          _streamControllers.remove(data['stream_id']);
          LazyLoader.unregisterController(controller);
        }
      }
    } catch (e, stack) {
      _logger.d('WebSocket message handling failed', error: e, stackTrace: stack);
    }
  }

  void _handleWakeWordMessage(dynamic message) {
    try {
      final dynamic decoded = jsonDecode(message.toString());
      if (decoded is! Map<String, dynamic>) {
        _logger.w('[WS-WW] Received non-object message');
        return;
      }
      final data = decoded;
      final type = data['type'] as String?;
      final wakeWord = data['wake_word'] as String?;
      final confidence = data['confidence'] as double?;
      final timestamp = data['timestamp'] as int?;
      
      if (type == 'wake_word_detected' && wakeWord != null && confidence != null) {
        for (var controller in _wakeWordControllers.values) {
          if (!controller.isClosed) {
            controller.add({
              'wake_word': wakeWord,
              'confidence': confidence,
              'timestamp': timestamp,
            });
          }
        }
      }
    } catch (e, stack) {
      _logger.d('Wake Word message handling failed', error: e, stackTrace: stack);
    }
  }

  void _handleError(dynamic error) {
    _logger.d('WebSocket error', error: error);
    _isConnected.value = false;
    _scheduleReconnect();
  }

  void _handleWakeWordError(dynamic error) {
    _logger.d('Wake Word WebSocket error', error: error);
    _isWakeWordConnected.value = false;
    _scheduleWakeWordReconnect();
  }

  void _handleDisconnect() {
    _logger.d('WebSocket disconnected');
    _isConnected.value = false;
    _heartbeatTimer?.cancel();
    for (final ctrl in _streamControllers.values) {
      if (!ctrl.isClosed) {
        ctrl.addError(Exception('WebSocket disconnected'));
        ctrl.close();
      }
    }
    _streamControllers.clear();
    _scheduleReconnect();
  }

  void _handleWakeWordDisconnect() {
    _logger.d('Wake Word WebSocket disconnected');
    _isWakeWordConnected.value = false;
    _wakeWordHeartbeatTimer?.cancel();
    _scheduleWakeWordReconnect();
  }

  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      _logger.w('Max WebSocket reconnect attempts reached');
      _reconnectAttempts = 0;
      return;
    }

    if (_reconnectTimer != null && _reconnectTimer!.isActive) {
      return;
    }

    _reconnectAttempts++;

    final baseDelaySeconds = _baseDelay.inSeconds;
    final maxDelaySeconds = _maxDelay.inSeconds;
    final exponentialDelay = baseDelaySeconds * pow(2, _reconnectAttempts - 1);
    final cappedDelay = min(exponentialDelay, maxDelaySeconds).toInt();
    final jitter = Random().nextInt(1000);
    final finalDelay = Duration(seconds: cappedDelay) + Duration(milliseconds: jitter);

    _logger.d('Scheduling WebSocket reconnect in ${finalDelay.inSeconds}s (attempt $_reconnectAttempts)');

    _reconnectTimer = Timer(finalDelay, () async {
      _reconnectTimer = null;
      try {
        await connect();
        _reconnectAttempts = 0;
      } catch (e) {
        _logger.w('WebSocket reconnect attempt $_reconnectAttempts failed', error: e);
        _scheduleReconnect();
      }
    });
  }

  void _scheduleWakeWordReconnect() {
    if (_wakeWordReconnectAttempts >= _maxReconnectAttempts) {
      _logger.w('Max Wake Word WebSocket reconnect attempts reached');
      _wakeWordReconnectAttempts = 0;
      return;
    }

    if (_wakeWordReconnectTimer != null && _wakeWordReconnectTimer!.isActive) {
      return;
    }

    _wakeWordReconnectAttempts++;

    final baseDelaySeconds = _baseDelay.inSeconds;
    final maxDelaySeconds = _maxDelay.inSeconds;
    final exponentialDelay = baseDelaySeconds * pow(2, _wakeWordReconnectAttempts - 1);
    final cappedDelay = min(exponentialDelay, maxDelaySeconds).toInt();
    final jitter = Random().nextInt(1000);
    final finalDelay = Duration(seconds: cappedDelay) + Duration(milliseconds: jitter);

    _logger.d('Scheduling Wake Word reconnect in ${finalDelay.inSeconds}s (attempt $_wakeWordReconnectAttempts)');

    _wakeWordReconnectTimer = Timer(finalDelay, () async {
      _wakeWordReconnectTimer = null;
      try {
        await connectWakeWordDetection();
        _wakeWordReconnectAttempts = 0;
      } catch (e) {
        _logger.w('WakeWord reconnect attempt $_wakeWordReconnectAttempts failed', error: e);
        _scheduleWakeWordReconnect();
      }
    });
  }

  void onAppResumed() {
    if (_isDisposed) return;
    if (!_isConnected.value) {
      _reconnectAttempts = 0;
      _reconnectTimer?.cancel();
      _reconnectTimer = null;
      _scheduleReconnect();
    }
    if (!_isWakeWordConnected.value) {
      _wakeWordReconnectAttempts = 0;
      _wakeWordReconnectTimer?.cancel();
      _wakeWordReconnectTimer = null;
      _scheduleWakeWordReconnect();
    }
  }

  void onNetworkRestored() {
    if (_isDisposed) return;
    _reconnectAttempts = 0;
    _wakeWordReconnectAttempts = 0;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _wakeWordReconnectTimer?.cancel();
    _wakeWordReconnectTimer = null;
    if (!_isConnected.value) _scheduleReconnect();
    if (!_isWakeWordConnected.value) _scheduleWakeWordReconnect();
  }

  Stream<String> subscribeToStream(String streamId) {
    final existing = _streamControllers[streamId];
    if (existing != null && !existing.isClosed) return existing.stream;
    final controller = StreamController<String>.broadcast(
      onCancel: () {
        _streamControllers.remove(streamId);
        LazyLoader.unregisterController(controller);
      },
    );
    _streamControllers[streamId] = controller;
    LazyLoader.registerController(controller);
    return controller.stream;
  }

  Stream<Map<String, dynamic>> subscribeToWakeWord() {
    final controllerId = const Uuid().v4();
    final controller = StreamController<Map<String, dynamic>>();
    _wakeWordControllers[controllerId] = controller;
    LazyLoader.registerController(controller);
    
    controller.onCancel = () {
      _wakeWordControllers.remove(controllerId);
      LazyLoader.unregisterController(controller);
    };
    
    return controller.stream;
  }

  Future<void> sendAudioChunk(List<int> audioChunk) async {
    try {
      if (!_isWakeWordConnected.value || _wakeWordChannel == null) {
        throw Exception('Wake Word WebSocket not connected');
      }
      
      final audioMessage = {
        'type': 'audio_chunk',
        'audio_data': base64Encode(audioChunk),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      
      _queueMessage(audioMessage);
      _wakeWordChannel!.sink.add(jsonEncode(audioMessage));
    } catch (e, stack) {
      _logger.d('Send audio chunk failed', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<String> sendChatMessage({
    required String sessionId,
    required String message,
    required String userId,
    bool deepResearch = false,
    List<String>? attachments,
    String? modelId,
    String? systemNote,
    bool isContinuation = false,
    String? continuationFromMessageId,
    String? continuationPartialText,
  }) async {
    try {
      if (!_isConnected.value || _channel == null) {
        throw Exception('WebSocket not connected');
      }
      
      final streamId = '${sessionId}_${DateTime.now().millisecondsSinceEpoch}';
      
      final chatMessage = {
        'type':       'chat_message',
        'stream_id':  streamId,
        'session_id': sessionId,
        'message':    message,
        'user_id':    userId,
        'deep_research': deepResearch,
        'attachments':   attachments,
        'timestamp':     DateTime.now().millisecondsSinceEpoch,
        if (modelId != null)                  'model_id':                  modelId,
        if (systemNote != null)               'system_note':               systemNote,
        if (isContinuation)                   'is_continuation':           true,
        if (continuationFromMessageId != null)'continuation_from_message_id': continuationFromMessageId,
        if (continuationPartialText != null)  'continuation_partial_text': continuationPartialText,
      };
      
      _queueMessage(chatMessage);
      _channel!.sink.add(jsonEncode(chatMessage));
      
      _logger.d('Chat message sent: $streamId');
      
      return streamId;
    } catch (e, stack) {
      _logger.d('Send chat message failed', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<void> disconnect() async {
    _isDisposed = true;
    
    _reconnectTimer?.cancel();
    _wakeWordReconnectTimer?.cancel();
    _heartbeatTimer?.cancel();
    _wakeWordHeartbeatTimer?.cancel();
    await _channel?.sink.close(status.goingAway);
    await _wakeWordChannel?.sink.close(status.goingAway);
    
    for (final ctrl in _streamControllers.values) {
      if (!ctrl.isClosed) await ctrl.close();
    }
    _streamControllers.clear();
    
    for (final ctrl in _wakeWordControllers.values) {
      if (!ctrl.isClosed) await ctrl.close();
    }
    _wakeWordControllers.clear();
    _pendingMessages.clear();
    
    _isConnected.value = false;
    _isWakeWordConnected.value = false;
    _isConnected.dispose();
    _isWakeWordConnected.dispose();

    _logger.i('WebSocket disconnected');
  }
}

// ===========================================
// FIXED: CONNECTIVITY SERVICE WITH PROPER ENDPOINT HEALTH CHECK
// ===========================================
class ProductionConnectivityService {
  final ProductionLogger _logger;
  final Connectivity _connectivity = Connectivity();
  final ValueNotifier<bool> _isConnected = ValueNotifier<bool>(true);
  final ValueNotifier<ConnectivityResult> _connectionType = ValueNotifier<ConnectivityResult>(ConnectivityResult.none);
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isInitialized = false;

  ValueNotifier<bool> get isConnected => _isConnected;
  ValueNotifier<ConnectivityResult> get connectionType => _connectionType;

  ProductionConnectivityService({required ProductionLogger logger}) : _logger = logger;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      final initialResults = await _connectivity.checkConnectivity();
      _updateConnectionStatus(initialResults);

      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

      _isInitialized = true;
      _logger.i('Connectivity service initialized');
    } catch (e, stack) {
      _logger.e('Failed to initialize connectivity service', error: e, stackTrace: stack);
      _isConnected.value = false;
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    const priority = [
      ConnectivityResult.wifi,
      ConnectivityResult.mobile,
      ConnectivityResult.ethernet,
      ConnectivityResult.vpn,
      ConnectivityResult.bluetooth,
      ConnectivityResult.other,
      ConnectivityResult.none,
    ];
    ConnectivityResult dominant = ConnectivityResult.none;
    for (final p in priority) {
      if (results.contains(p)) { dominant = p; break; }
    }
    final bool connected = dominant != ConnectivityResult.none;
    _isConnected.value = connected;
    _connectionType.value = dominant;
    _logger.d('Connection status: $connected, type: $dominant (all: $results)');
  }

  Future<bool> checkInternetAccess() async {
    try {
      final envConfig = EnvironmentConfig();
      final response = await http.get(
        Uri.parse('${envConfig.backendBaseUrl}/health'),
      ).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> checkApiConnectivity() => checkInternetAccess();

  Timer? _healthCheckTimer;

  void dispose() {
    _connectivitySubscription?.cancel();
    _healthCheckTimer?.cancel();
    _isConnected.dispose();
    _connectionType.dispose();
    _logger.d('Connectivity service disposed');
  }
}

// ===========================================
// FIXED: RATE LIMITING SERVICE WITH SERVER SYNC
// ===========================================
class RateLimitingService {
  final ProductionLogger _logger;
  final Map<String, List<DateTime>> _userRequests = {};
  final Map<String, List<DateTime>> _endpointRequests = {};
  final Map<String, Map<String, int>> _userDailyQuotas = {};
  Timer? _syncTimer;
  Timer? _cleanupTimer;
  final Mutex _quotaMutex = Mutex();

  static const Duration _userWindow = Duration(minutes: 1);
  static const Duration _endpointWindow = Duration(minutes: 1);
  static const int _maxUserRequests = 60;
  static const int _maxEndpointRequests = 100;
  
  // Local fallback quotas — server /api/rate-limit/status is authoritative
  static const Map<String, int> _localFallbackQuotas = {
    'free':       5,
    'monthly':    1000,
    'half_year':  5000,
    'yearly':     999999,
  };

  // Server-provided limits (overrides local fallback when available)
  Map<String, int>? _serverQuotas;

  void updateServerQuotas(Map<String, int> quotas) {
    _serverQuotas = quotas;
    _logger.d('[RateLimit] Server quotas updated: $quotas');
  }

  int _limitForPlan(String plan) {
    if (_serverQuotas != null && _serverQuotas!.containsKey(plan)) {
      return _serverQuotas![plan]!;
    }
    return _localFallbackQuotas[plan] ?? 5;
  }
  
  bool _isInitialized = false;

  RateLimitingService({required ProductionLogger logger}) : _logger = logger;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _startPeriodicSync();
    _startPeriodicCleanup();
    _isInitialized = true;
    _logger.i('Rate Limiting Service initialized');
  }

  void _startPeriodicSync() {
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _syncWithServer();
    });
  }

  void _startPeriodicCleanup() {
    _cleanupTimer = Timer.periodic(const Duration(hours: 1), (timer) {
      clearOldData();
    });
  }

  Future<void> _syncWithServer() async {
    await _quotaMutex.acquire();
    try {
      final envConfig = EnvironmentConfig();
      for (var entry in _userDailyQuotas.entries) {
        final userId = entry.key;
        final today = DateTime.now().toIso8601String().substring(0, 10);
        final currentCount = entry.value[today] ?? 0;

        try {
          final response = await http.post(
            Uri.parse('${envConfig.backendBaseUrl}/rate-limit/sync'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'user_id': userId,
              'date': today,
              'count': currentCount,
            }),
          ).timeout(const Duration(seconds: 5));

          if (response.statusCode == 200) {
            try {
              final data = jsonDecode(response.body) as Map<String, dynamic>;
              if (data['server_count'] != null) {
                entry.value[today] = data['server_count'] as int;
              }
            } catch (_) {}
          }
        } catch (e) {
          _logger.d('Rate limit sync failed for user $userId — keeping local count', error: e);
        }
      }
    } catch (e) {
      _logger.d('Rate limit sync failed — local data preserved', error: e);
    } finally {
      _quotaMutex.release();
    }
  }

  Future<bool> checkUserRateLimit(String userId) async {
    try {
      final now = DateTime.now();

      if (!_userRequests.containsKey(userId)) {
        _userRequests[userId] = [];
      }

      _userRequests[userId]!.removeWhere(
        (time) => now.difference(time) > _userWindow,
      );

      if (_userRequests[userId]!.length >= _maxUserRequests) {
        _logger.w('User rate limit exceeded', error: {'userId': userId});
        return false;
      }

      _userRequests[userId]!.add(now);

      if (_userRequests.length > 10000) {
        final oldest = _userRequests.entries
            .where((e) => e.value.isEmpty ||
                now.difference(e.value.last) > const Duration(hours: 2))
            .map((e) => e.key)
            .toList();
        for (final k in oldest) {
          _userRequests.remove(k);
        }
      }

      return true;
    } catch (e, stack) {
      _logger.d('Rate limit check failed', error: e, stackTrace: stack);
      return true;
    }
  }

  Future<bool> checkEndpointRateLimit(String endpoint) async {
    try {
      final now = DateTime.now();

      if (!_endpointRequests.containsKey(endpoint)) {
        _endpointRequests[endpoint] = [];
      }

      _endpointRequests[endpoint]!.removeWhere(
        (time) => now.difference(time) > _endpointWindow,
      );

      if (_endpointRequests[endpoint]!.length >= _maxEndpointRequests) {
        _logger.w('Endpoint rate limit exceeded', error: {'endpoint': endpoint});
        return false;
      }

      _endpointRequests[endpoint]!.add(now);
      return true;
    } catch (e, stack) {
      _logger.d('Endpoint rate limit check failed', error: e, stackTrace: stack);
      return true;
    }
  }
  
  Future<bool> checkDailyQuota(String userId, String plan, String action) async {
    await _quotaMutex.acquire();
    try {
      final today = DateTime.now().toIso8601String().substring(0, 10);
      
      if (!_userDailyQuotas.containsKey(userId)) {
        _userDailyQuotas[userId] = {};
      }
      
      if (!_userDailyQuotas[userId]!.containsKey(today)) {
        try {
          final envConfig = EnvironmentConfig();
          final response = await http.get(
            Uri.parse('${envConfig.backendBaseUrl}/rate-limit/quota/$userId'),
          ).timeout(const Duration(seconds: 5));
          
          if (response.statusCode == 200) {
            try {
              final data = jsonDecode(response.body) as Map<String, dynamic>;
              _userDailyQuotas[userId]![today] = (data['used'] as int?) ?? 0;
            } catch (_) {
              _userDailyQuotas[userId]![today] = 0;
            }
          } else {
            _userDailyQuotas[userId]![today] = 0;
          }
        } catch (e) {
          _userDailyQuotas[userId]![today] = 0;
        }
      }
      
      final quota = _dailyQuotas[plan] ?? 5;
      final current = _userDailyQuotas[userId]![today] ?? 0;
      
      if (current >= quota) {
        _logger.w('Daily quota exceeded', error: {
          'userId': userId,
          'plan': plan,
          'action': action,
        });
        return false;
      }
      
      _userDailyQuotas[userId]![today] = current + 1;
      return true;
    } catch (e, stack) {
      _logger.d('Daily quota check failed', error: e, stackTrace: stack);
      return true;
    } finally {
      _quotaMutex.release();
    }
  }
  
  Future<void> syncQuotaWithServer(String userId, int serverQuota) async {
    await _quotaMutex.acquire();
    try {
      final today = DateTime.now().toIso8601String().substring(0, 10);
      
      if (!_userDailyQuotas.containsKey(userId)) {
        _userDailyQuotas[userId] = {};
      }
      
      _userDailyQuotas[userId]![today] = serverQuota;
      
      _logger.d('Quota synced for user $userId: $serverQuota');
    } catch (e, stack) {
      _logger.d('Quota sync failed', error: e, stackTrace: stack);
    } finally {
      _quotaMutex.release();
    }
  }
  
  int getRemainingQuota(String userId, String plan) {
    try {
      final today = DateTime.now().toIso8601String().substring(0, 10);
      
      if (!_userDailyQuotas.containsKey(userId) || !_userDailyQuotas[userId]!.containsKey(today)) {
        return _dailyQuotas[plan] ?? 5;
      }
      
      final quota = _dailyQuotas[plan] ?? 5;
      final current = _userDailyQuotas[userId]![today] ?? 0;
      
      return quota - current;
    } catch (e) {
      _logger.d('Get remaining quota failed', error: e);
      return 0;
    }
  }

  Future<void> clearOldData() async {
    try {
      final now = DateTime.now();

      _userRequests.forEach((userId, times) {
        _userRequests[userId]!.removeWhere(
          (time) => now.difference(time) > const Duration(hours: 24),
        );
      });
      _userRequests.removeWhere((_, times) => times.isEmpty);

      _endpointRequests.forEach((endpoint, times) {
        _endpointRequests[endpoint]!.removeWhere(
          (time) => now.difference(time) > const Duration(hours: 1),
        );
      });
      _endpointRequests.removeWhere((_, times) => times.isEmpty);

      _userDailyQuotas.removeWhere((userId, quotas) {
        quotas.removeWhere((date, count) {
          return date != now.toIso8601String().substring(0, 10);
        });
        return quotas.isEmpty;
      });

      _logger.d('Rate limit data cleared');
    } catch (e, stack) {
      _logger.d('Clear old data failed', error: e, stackTrace: stack);
    }
  }
  
  void dispose() {
    _syncTimer?.cancel();
    _syncTimer = null;
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
    _userRequests.clear();
    _endpointRequests.clear();
    _userDailyQuotas.clear();
  }
}

// ===========================================
// FIXED: SECURITY ARCHITECTURE WITH PROPER KEY MANAGEMENT
// ===========================================
class SecurityArchitecture {
  final ProductionLogger _logger;
  final AppSecureStorage _secureStorage = AppSecureStorage.instance;
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isDeviceSecured = false;
  bool _isInitialized = false;
  Timer? _appCheckRefreshTimer;
  
  late encrypt.Key _aesKey;
  late encrypt.Encrypter _encrypter;
  late List<int> _saHmacKey;

  String _saGenerateHmac(String data) {
    final h = Hmac(sha256, _saHmacKey);
    return h.convert(utf8.encode(data)).toString();
  }

  bool _saVerifyHmac(String data, String expected) {
    final actual = _saGenerateHmac(data);
    if (actual.length != expected.length) return false;
    var d = 0;
    for (var i = 0; i < actual.length; i++) d |= actual.codeUnitAt(i) ^ expected.codeUnitAt(i);
    return d == 0;
  }

  final Map<String, List<DateTime>> _authAttempts = {};
  static const int _maxAuthAttempts = 5;
  static const Duration _authLockoutDuration = Duration(minutes: 15);
  
  String? _accessToken;
  String? _refreshToken;
  DateTime? _tokenExpiry;
  
  static final List<String> _pinnedCertificates = [
    if (const String.fromEnvironment('CERTIFICATE_PIN_PRIMARY').isNotEmpty)
      const String.fromEnvironment('CERTIFICATE_PIN_PRIMARY'),
    if (const String.fromEnvironment('CERTIFICATE_PIN_BACKUP').isNotEmpty)
      const String.fromEnvironment('CERTIFICATE_PIN_BACKUP'),
  ];
  
  static const Map<InputType, RegExp> _validationPatterns = {
    InputType.email: RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'),
    InputType.password: RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>]).{8,}$'),
    InputType.phone: RegExp(r'^[\+]?[(]?[0-9]{3}[)]?[-\s\.]?[0-9]{3}[-\s\.]?[0-9]{4,6}$'),
    InputType.name: RegExp(r'^[a-zA-Z\s\-\.\']{2,50}$'),
    InputType.message: RegExp(r'^[\s\S]{1,10000}$'),
  };
  
  static const Map<InputType, String> _sanitizationPatterns = {
    InputType.email: r'[<>&"\'()\[\]{};]',
    InputType.password: r'[<>]',
    InputType.phone: r'[^\d\+]',
    InputType.name: r'[<>&"\'()\[\]{};]',
    InputType.message: r'[<>]',
  };

  static final List<RegExp> _promptInjectionPatterns = [
    RegExp(r'ignore\s+(all\s+)?(previous|prior|above)\s+(instructions?|prompts?|rules?)', caseSensitive: false),
    RegExp(r'(disregard|forget|override)\s+(your\s+)?(instructions?|rules?|guidelines?|training)', caseSensitive: false),
    RegExp(r'you\s+are\s+now\s+(a\s+)?(DAN|jailbreak|unrestricted|evil|unethical)', caseSensitive: false),
    RegExp(r'(pretend|act|behave)\s+(like|as)\s+(you\s+have\s+no\s+)?(restrictions?|limits?|rules?|guidelines?)', caseSensitive: false),
    RegExp(r'(system|user|assistant)\s*:\s*(ignore|override|you are)', caseSensitive: false),
    RegExp(r'\[SYSTEM\]|\[INST\]|<\|system\|>|<\|im_start\|>', caseSensitive: false),
    RegExp(r'(jailbreak|do anything now|DAN mode|developer mode|god mode)', caseSensitive: false),
    RegExp(r'repeat\s+(after\s+me|the\s+following)\s*:\s*(ignore|you are|system)', caseSensitive: false),
    RegExp(r'(write|generate|produce)\s+(malware|ransomware|virus|exploit|bomb|weapon)', caseSensitive: false),
    RegExp(r'(how\s+to\s+)?(make|build|create|synthesize)\s+(drugs|explosives|poison|weapon)', caseSensitive: false),
  ];

  static final List<RegExp> _outputFilterPatterns = [
    RegExp(r'(step[- ]by[- ]step|instructions?)\s+(to|for)\s+(make|build|create)\s+(bomb|explosive|weapon|malware)', caseSensitive: false),
    RegExp(r'(here\'s|here is)\s+how\s+to\s+(hack|exploit|bypass|crack|jailbreak)', caseSensitive: false),
  ];

  bool detectPromptInjection(String input) {
    if (input.isEmpty) return false;
    for (final pattern in _promptInjectionPatterns) {
      if (pattern.hasMatch(input)) {
        _logger.w('Prompt injection detected', error: {'pattern': pattern.pattern});
        return true;
      }
    }
    return false;
  }

  String? filterAiOutput(String output) {
    for (final pattern in _outputFilterPatterns) {
      if (pattern.hasMatch(output)) {
        _logger.w('Harmful AI output filtered', error: {'pattern': pattern.pattern});
        return '[Content filtered: This response was blocked by the safety system.]';
      }
    }
    return null;
  }

  SecurityArchitecture({required ProductionLogger logger}) : _logger = logger;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      await _checkDeviceSecurity();
      await _initializeEncryption();
      await _checkRootStatus();
      await _verifyAppIntegrity();
      
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        try {
          if (kReleaseMode) {
            await FirebaseAppCheck.instance.activate(
              androidProvider: AndroidProvider.playIntegrity,
              appleProvider: AppleProvider.appAttest,
            );
          } else {
            await FirebaseAppCheck.instance.activate(
              androidProvider: AndroidProvider.debug,
              appleProvider: AppleProvider.debug,
            );
          }
          final token = await FirebaseAppCheck.instance.getToken(true);
          if (token == null) {
            _logger.w('[Security] App Check token null — device may not pass integrity check');
          } else {
            _logger.i('[Security] Firebase App Check token obtained (Play Integrity / App Attest)');
          }
          _appCheckRefreshTimer?.cancel();
          _appCheckRefreshTimer = Timer.periodic(const Duration(minutes: 55), (_) async {
            try {
              await FirebaseAppCheck.instance.getToken(true);
            } catch (e) {
              _logger.w('[Security] AppCheck periodic refresh failed', error: e);
            }
          });
        } catch (e) {
          _logger.w('[Security] Firebase AppCheck activation failed (rooted/emulator?)', error: e);
        }
      }
      
      _isInitialized = true;
      _logger.i('Security Architecture initialized');
    } catch (e, stack) {
      _logger.e('Failed to initialize Security Architecture', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<void> _checkDeviceSecurity() async {
    try {
      if (kIsWeb || Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
        _isDeviceSecured = true;
        return;
      }
      
      final canAuthenticate = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      
      _isDeviceSecured = canAuthenticate || isDeviceSupported;
      
      if (!_isDeviceSecured) {
        _logger.w('Device not secured', error: {
          'canAuthenticate': canAuthenticate,
          'isDeviceSupported': isDeviceSupported,
          'biometrics': availableBiometrics.map((e) => e.name).toList(),
        });
      }
    } catch (e) {
      _logger.d('Device security check failed', error: e);
    }
  }

  Future<void> _checkRootStatus() async {
    try {
      if (kIsWeb || Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
        return;
      }
      
      if (Platform.isAndroid) {
        final paths = [
          '/system/app/Superuser.apk',
          '/sbin/su',
          '/system/bin/su',
          '/system/xbin/su',
          '/data/local/xbin/su',
          '/data/local/bin/su',
          '/system/sd/xbin/su',
          '/system/bin/failsafe/su',
          '/data/local/su',
        ];
        
        for (final path in paths) {
          if (await File(path).exists()) {
            _logger.w('Rooted device detected', error: {'root_path': path});
            break;
          }
        }
      } else if (Platform.isIOS) {
        final paths = [
          '/Applications/Cydia.app',
          '/Library/MobileSubstrate/MobileSubstrate.dylib',
          '/bin/bash',
          '/usr/sbin/sshd',
          '/etc/apt',
          '/private/var/lib/apt/',
        ];
        
        for (final path in paths) {
          if (await File(path).exists()) {
            _logger.w('Jailbroken device detected', error: {'jailbreak_path': path});
            break;
          }
        }
      }
    } catch (e) {
      _logger.d('Root check failed', error: e);
    }
  }

  Future<void> _verifyAppIntegrity() async {
    try {
      if (kIsWeb || Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
        return;
      }

      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS) && kReleaseMode) {
        try {
          final appCheckToken = await FirebaseAppCheck.instance.getToken(true);
          if (appCheckToken == null || appCheckToken.token.isEmpty) {
            _logger.w('[Security] App Check token null/empty — possible rooted/jailbroken device');
          } else {
            _logger.i('[Security] App Check token validated successfully');
          }
        } catch (e) {
          _logger.w('[Security] App Check token validation failed', error: e);
        }
      }
      
      if (Platform.isAndroid) {
        final packageInfo = await PackageInfo.fromPlatform();
        final signature = await _getAppSignature();
        
        final knownSignature = await _secureStorage.read(key: 'app_signature');
        if (knownSignature != null && knownSignature != signature) {
          _logger.e('App signature mismatch — possible tampering');
        }
      }
    } catch (e, stack) {
      _logger.e('App integrity verification failed', error: e, stackTrace: stack);
    }
  }

  Future<String> _getAppSignature() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final signature = '${packageInfo.packageName}_${packageInfo.version}_${packageInfo.buildNumber}';
      final hash = sha256.convert(utf8.encode(signature)).toString();
      return hash;
    } catch (e) {
      _logger.d('App signature generation failed', error: e);
      return 'app_signature_fallback_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  Future<void> _initializeEncryption() async {
    try {
      const aesKeyName  = 'askroa_sa_aes_key_v5';
      const hmacKeyName = 'askroa_sa_hmac_key_v5';
      String? aesStr  = await _secureStorage.read(key: aesKeyName);
      String? hmacStr = await _secureStorage.read(key: hmacKeyName);

      if (aesStr == null) {
        final rng  = Random.secure();
        final aes  = List<int>.generate(32, (_) => rng.nextInt(256));
        final hmac = List<int>.generate(32, (_) => rng.nextInt(256));
        aesStr  = base64Url.encode(aes);
        hmacStr = base64Url.encode(hmac);
        await _secureStorage.write(
         key: aesKeyName, value: aesStr,
          aOptions: const AndroidOptions(encryptedSharedPreferences: true),
          iOptions: const IOSOptions(accessibility: KeychainAccessibility.first_unlock),
        );
        await _secureStorage.write(
         key: hmacKeyName, value: hmacStr,
          aOptions: const AndroidOptions(encryptedSharedPreferences: true),
          iOptions: const IOSOptions(accessibility: KeychainAccessibility.first_unlock),
        );
      }

      _aesKey    = encrypt.Key.fromBase64(aesStr);
      _encrypter = encrypt.Encrypter(encrypt.AES(_aesKey, mode: encrypt.AESMode.gcm));
      _saHmacKey = base64Url.decode(hmacStr!);

      _logger.i('[SA] AES-256-GCM + HMAC-SHA256 initialized');
    } catch (e, stack) {
      _logger.e('[SA] Encryption initialization failed', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<bool> authenticateWithBiometrics({bool fallbackToPasscode = true}) async {
    try {
      if (!_isDeviceSecured) {
        if (fallbackToPasscode) {
          return await _authenticateWithPasscode();
        }
        return false;
      }
      
      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access Askroa AI',
        options: AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
        authMessages: const [
          AndroidAuthMessages(
            signInTitle: 'Unlock Askroa AI',
            biometricHint: 'Verify your identity',
          ),
          IOSAuthMessages(
            lockOut: 'Too many attempts. Try again later.',
          ),
        ],
      );
      
      return didAuthenticate;
    } catch (e) {
      _logger.d('Biometric authentication failed', error: e);
      return fallbackToPasscode ? await _authenticateWithPasscode() : false;
    }
  }

  Future<bool> _authenticateWithPasscode() async {
    try {
      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Enter your device passcode',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
      return didAuthenticate;
    } catch (e) {
      _logger.d('Passcode authentication failed', error: e);
      return false;
    }
  }

  Future<bool> checkRateLimit(String action, String userId) async {
    final key = '$action:$userId';
    final now = DateTime.now();
    
    if (!_authAttempts.containsKey(key)) {
      _authAttempts[key] = [];
    }
    
    _authAttempts[key]!.removeWhere(
      (time) => now.difference(time) > _authLockoutDuration,
    );
    
    if (_authAttempts[key]!.length >= _maxAuthAttempts) {
      return false;
    }
    
    _authAttempts[key]!.add(now);
    return true;
  }

  String encrypt(String plainText) {
    try {
      final iv        = encrypt.IV.fromSecureRandom(16);
      final encrypted = _encrypter.encrypt(plainText, iv: iv);
      final payload   = '${iv.base64}:${encrypted.base64}';
      final hmac      = _saGenerateHmac(payload);
      return '$payload:$hmac';
    } catch (e) {
      _logger.e('[SA] Encryption failed', error: e);
      throw Exception('[SA] Encryption failed: $e');
    }
  }

  Future<String> decrypt(String encryptedText) async {
    try {
      final parts = encryptedText.split(':');
      if (parts.length == 3) {
        final payload = '${parts[0]}:${parts[1]}';
        if (!_saVerifyHmac(payload, parts[2])) {
          throw Exception('[SA] HMAC mismatch — possible tampering');
        }
        final iv        = encrypt.IV.fromBase64(parts[0]);
        final encrypted = encrypt.Encrypted.fromBase64(parts[1]);
        return _encrypter.decrypt(encrypted, iv: iv);
      } else if (parts.length == 2) {
        final iv        = encrypt.IV.fromBase64(parts[0]);
        final encrypted = encrypt.Encrypted.fromBase64(parts[1]);
        try {
          return _encrypter.decrypt(encrypted, iv: iv);
        } catch (_) {
          final backupStr = await _secureStorage.read(key: 'askroa_enc_key_v5_backup');
          if (backupStr == null) rethrow;
          final backupKey      = encrypt.Key.fromBase64(backupStr);
          final backupEncrypter = encrypt.Encrypter(encrypt.AES(backupKey, mode: encrypt.AESMode.gcm));
          final result = backupEncrypter.decrypt(encrypted, iv: iv);
          _logger.i('[SA] Decrypted with backup key');
          return result;
        }
      }
      throw FormatException('[SA] Unexpected ciphertext format');
    } catch (e) {
      _logger.e('[SA] Decryption failed', error: e);
      throw Exception('[SA] Decryption failed: $e');
    }
  }

  Future<void> setTokens(String accessToken, String refreshToken, int expiresIn) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn));
    
    await _secureStorage.write(
      key: 'access_token',
      value: encrypt(accessToken));
    await _secureStorage.write(
      key: 'refresh_token',
      value: encrypt(refreshToken));
    await _secureStorage.write(
      key: 'token_expiry',
      value: _tokenExpiry!.toIso8601String(),
    );
    
    _logger.i('Tokens stored securely');
  }

  Future<String?> getAccessToken() async {
    if (_accessToken != null && _tokenExpiry != null && _tokenExpiry!.isAfter(DateTime.now())) {
      return _accessToken;
    }
    
    try {
      final encryptedToken = await _secureStorage.read(key: 'access_token');
      final expiryString = await _secureStorage.read(key: 'token_expiry');
      
      if (encryptedToken != null && expiryString != null) {
        _accessToken = await decrypt(encryptedToken);
        _tokenExpiry = DateTime.parse(expiryString);
        
        if (_tokenExpiry!.isAfter(DateTime.now())) {
          return _accessToken;
        }
      }
    } catch (e) {
      _logger.d('Token loading failed', error: e);
    }
    
    return null;
  }

  Future<String?> refreshAccessToken() async {
    try {
      final encryptedRefreshToken = await _secureStorage.read(key: 'refresh_token');
      if (encryptedRefreshToken == null) return null;
      
      final refreshToken = await decrypt(encryptedRefreshToken);
      
      final envConfig = EnvironmentConfig();
      final response = await http.post(
        Uri.parse('${envConfig.backendBaseUrl}/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refreshToken}),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          await setTokens(
            data['access_token'],
            data['refresh_token'],
            data['expires_in'],
          );
          return _accessToken;
        } catch (_) {
          return null;
        }
      }
    } catch (e) {
      _logger.d('Token refresh failed', error: e);
    }
    
    return null;
  }

  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    _tokenExpiry = null;
    
    await _secureStorage.delete(key: 'access_token');
    await _secureStorage.delete(key: 'refresh_token');
    await _secureStorage.delete(key: 'token_expiry');
    
    _logger.i('Tokens cleared');
  }

  bool validateInput(String input, InputType type) {
    final pattern = _validationPatterns[type];
    if (pattern == null) return false;
    return pattern.hasMatch(input);
  }

  String sanitizeInput(String input, InputType type) {
    if (input.isEmpty) return input;
    
    String sanitized = input;
    
    sanitized = sanitized.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');
    
    final pattern = _sanitizationPatterns[type];
    if (pattern != null) {
      sanitized = sanitized.replaceAll(RegExp(pattern), '');
    }
    
    sanitized = sanitized
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;')
        .replaceAll('/', '&#x2F;');
    
    sanitized = sanitized.trim();
    
    return sanitized;
  }

  bool isSecureConnection() {
    final envConfig = EnvironmentConfig();
    return envConfig.backendBaseUrl.startsWith('https://');
  }

  Map<String, String> getSecureHeaders() {
    return {
      'X-Content-Type-Options': 'nosniff',
      'X-Frame-Options': 'DENY',
      'X-XSS-Protection': '1; mode=block',
      'Strict-Transport-Security': 'max-age=31536000; includeSubDomains',
      'Content-Security-Policy': "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline';",
      'Referrer-Policy': 'strict-origin-when-cross-origin',
      'Permissions-Policy': 'camera=(), microphone=(), geolocation=(self)',
    };
  }

  void dispose() {
    _appCheckRefreshTimer?.cancel();
    _appCheckRefreshTimer = null;
    _authAttempts.clear();
    _accessToken = null;
    _refreshToken = null;
    _tokenExpiry = null;
    _isInitialized = false;
  }
}

enum InputType {
  email,
  password,
  phone,
  name,
  message,
}

// ===========================================
// FIXED: GLOBAL USER HANDLER WITH PROPER DISPOSAL
// ===========================================
class GlobalUserHandler {
  final ProductionLogger _logger;
  User? _currentUser;
  final ValueNotifier<User?> _userNotifier = ValueNotifier<User?>(null);
  final ValueNotifier<int> _remainingRequests = ValueNotifier<int>(5);
  final ValueNotifier<bool> _isVoiceActive = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isChatLimitReached = ValueNotifier<bool>(false);
  final ValueNotifier<String> _userName = ValueNotifier<String>('');
  final ValueNotifier<ThemeMode> _themeMode = ValueNotifier<ThemeMode>(ThemeMode.dark);
  final ValueNotifier<Locale> _locale = ValueNotifier<Locale>(const Locale('en'));
  
  final Map<String, List<DateTime>> _actionTimestamps = {};
  Timer? _dailyResetTimer;
  Timer? _rateLimitCleanupTimer;
  
  static const int _voiceCooldown = 10;
  static const int _imageCooldown = 30;
  static const int _sendCooldown = 2;
  static const int _newChatCooldown = 5;
  
  static const int _freeDailyLimit = 5;
  static const int _freePerMinuteLimit = 10;
  static const int _freeNewChatLimit = 3;

  static const int _ultraProSessionLimit = 50;
  int _ultraProSessionMessageCount = 0;
  final ValueNotifier<bool> _isUltraProSessionLimitReached = ValueNotifier<bool>(false);

  ValueNotifier<bool> get isUltraProSessionLimitReached => _isUltraProSessionLimitReached;
  
  bool _isInitialized = false;
  bool _isDisposed = false;

  ValueNotifier<User?> get userNotifier => _userNotifier;
  ValueNotifier<int> get remainingRequests => _remainingRequests;
  ValueNotifier<bool> get isVoiceActive => _isVoiceActive;
  ValueNotifier<bool> get isChatLimitReached => _isChatLimitReached;
  ValueNotifier<String> get userName => _userName;
  ValueNotifier<ThemeMode> get themeMode => _themeMode;
  ValueNotifier<Locale> get locale => _locale;

  GlobalUserHandler({required ProductionLogger logger}) : _logger = logger;

  Future<void> initialize() async {
    if (_isInitialized) return;

    final secureStorage = AppSecureStorage.instance;

    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = await secureStorage.read(key: 'askroa_user_data');

      if (userData != null) {
        final encryption = ProductionEncryptionService(logger: _logger);
        await encryption.initialize();
        final decrypted = await encryption.decrypt(userData);

        if (decrypted != '[DECRYPTION_FAILED]') {
          final userJson = jsonDecode(decrypted) as Map<String, dynamic>;

          _currentUser = User.fromJson(userJson);
          _userNotifier.value = _currentUser;
          _userName.value = _currentUser!.name;

          final requests = prefs.getInt('askroa_remaining_requests') ??
              (_currentUser!.isPremium ? 999999 : _freeDailyLimit);
          _remainingRequests.value = requests;

          _isChatLimitReached.value = requests <= 0 && !_currentUser!.isPremium;

          final themeModeIndex = prefs.getInt('askroa_theme_mode') ?? 0;
          _themeMode.value = ThemeMode.values[themeModeIndex];

          final localeCode = prefs.getString('askroa_locale') ?? 'en';
          _locale.value = Locale(localeCode);

          _cleanRateLimitData();
          _scheduleDailyReset();

          if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
            try {
              await FirebaseCrashlytics.instance.setUserIdentifier(_currentUser!.id);
              await FirebaseCrashlytics.instance.setCustomKey('plan', _currentUser!.plan);
              final emailHash = sha256.convert(utf8.encode(_currentUser!.email)).toString().substring(0, 16);
              await FirebaseCrashlytics.instance.setCustomKey('email_hash', emailHash);
            } catch (e) {
              _logger.d('Crashlytics set user failed', error: e);
            }
          }

          _logger.i('User handler initialized for ${_currentUser!.id}');
        } else {
          _logger.w('User data decryption failed, clearing corrupted data');
          await secureStorage.delete(key: 'askroa_user_data');
        }
      } else {
        _logger.d('No user data found');
      }

      _isInitialized = true;
    } catch (e, stack) {
      _logger.e('[UserHandler] Initialization failed', error: e, stackTrace: stack);
      try { FirebaseCrashlytics.instance.recordError(e, stack, fatal: false); } catch (_) {}
      // Continue with unauthenticated state rather than crashing
      _isInitialized = true;
    }
  }

  Future<void> setUser(User user) async {
    try {
      _currentUser = user;
      _userNotifier.value = user;
      _userName.value = user.name;

      if (user.isPremium) {
        _remainingRequests.value = 999999;
        _isChatLimitReached.value = false;
      } else {
        _remainingRequests.value = _freeDailyLimit;
        _isChatLimitReached.value = false;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('askroa_remaining_requests', _remainingRequests.value);

      _scheduleDailyReset();
      
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        try {
          await FirebaseCrashlytics.instance.setUserIdentifier(user.id);
          await FirebaseCrashlytics.instance.setCustomKey('plan', user.plan);
        } catch (e) {
          _logger.d('Crashlytics set user failed', error: e);
        }
      }
      
      _logger.i('User set: ${user.id}');
    } catch (e, stack) {
      _logger.e('Failed to set user', error: e, stackTrace: stack);
    }
  }

  void _notifyQuotaWarning(int remaining) {
    if (remaining <= 2 && remaining > 0) {
      _logger.i('[Quota] Warning: only $remaining requests left today');
    }
  }

  Future<void> updateRemainingRequests(int count) async {
    if (_currentUser == null || _currentUser!.isPremium) return;
    _remainingRequests.value = count;
    _isChatLimitReached.value = count <= 0;
    _notifyQuotaWarning(count);
    try {
      final prefs = await SharedPreferences.getInstance()
          .timeout(const Duration(seconds: 3));
      await prefs.setInt('askroa_remaining_requests', count)
          .timeout(const Duration(seconds: 3));
      _logger.d('Remaining requests updated: $count');
    } catch (e) {
      _logger.d('SharedPreferences write skipped (background/timeout)', error: e);
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    try {
      _themeMode.value = mode;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('askroa_theme_mode', mode.index);
    } catch (e, stack) {
      _logger.e('Failed to set theme mode', error: e, stackTrace: stack);
    }
  }

  Future<void> setLocale(Locale locale) async {
    try {
      _locale.value = locale;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('askroa_locale', locale.languageCode);
    } catch (e, stack) {
      _logger.e('Failed to set locale', error: e, stackTrace: stack);
    }
  }

  void _scheduleDailyReset() {
    _rateLimitCleanupTimer?.cancel();
    _rateLimitCleanupTimer = Timer.periodic(const Duration(hours: 1), (_) {
      if (_isDisposed) {
        _rateLimitCleanupTimer?.cancel();
        return;
      }
      _cleanRateLimitData();
    });
    _dailyResetTimer?.cancel();
    
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final duration = tomorrow.difference(now);

    _dailyResetTimer = Timer(duration, () {
      if (_currentUser != null && !_currentUser!.isPremium) {
        _remainingRequests.value = _freeDailyLimit;
        _isChatLimitReached.value = false;

        SharedPreferences.getInstance().then((prefs) {
          prefs.setInt('askroa_remaining_requests', _freeDailyLimit);
        });
        
        _logger.d('Daily requests reset');
      }
    });

    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      try {
        Workmanager().registerOneOffTask(
          'daily_reset_task',
          'daily_reset_task',
          initialDelay: duration,
          constraints: Constraints(networkType: NetworkType.connected),
        );
      } catch (e) {
        _logger.d('Workmanager registration failed', error: e);
      }
    }
  }

  void _cleanRateLimitData() {
    final now = DateTime.now();
    _actionTimestamps.removeWhere((key, timestamps) {
      timestamps.removeWhere((time) => now.difference(time).inMinutes > 5);
      return timestamps.isEmpty;
    });
  }

  Future<void> clearUser() async {
    try {
      _currentUser = null;
      _userNotifier.value = null;
      _userName.value = '';
      _remainingRequests.value = _freeDailyLimit;
      _isVoiceActive.value = false;
      _isChatLimitReached.value = false;
      _ultraProSessionMessageCount = 0;
      _isUltraProSessionLimitReached.value = false;

      _actionTimestamps.clear();

      final secureStorage = AppSecureStorage.instance;

      await _deleteAllChatSessionKeys(secureStorage);

      await secureStorage.delete(key: 'askroa_access_token');
      await secureStorage.delete(key: 'askroa_refresh_token');
      await secureStorage.delete(key: 'askroa_user_data');

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('askroa_remaining_requests');
      await prefs.remove('askroa_user_plan');
      await prefs.remove('askroa_session_id');
      await prefs.remove('askroa_last_login');

      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        try {
          await FirebaseCrashlytics.instance.setUserIdentifier(null);
        } catch (e) {
          _logger.d('Crashlytics clear user failed', error: e);
        }
      }

      _themeMode.value = ThemeMode.dark;
      _locale.value = const Locale('en');

      final prefs2 = await SharedPreferences.getInstance();
      await prefs2.remove('askroa_theme_mode');
      await prefs2.remove('askroa_locale');

      _logger.i('User cleared');
    } catch (e, stack) {
      _logger.e('Failed to clear user', error: e, stackTrace: stack);
    }
  }

  Future<void> _deleteAllChatSessionKeys(AppSecureStorage ss) async {
    try {
      final allKeys = await ss.readAll();
      final chatKeyPrefix = 'askroa_chat_key_';
      final toDelete = allKeys.keys.where((k) => k.startsWith(chatKeyPrefix)).toList();
      for (final key in toDelete) {
        await ss.delete(key: key);
      }
      _logger.d('Deleted ${toDelete.length} E2EE session keys on logout');
    } catch (e) {
      _logger.w('E2EE session key cleanup failed (non-critical)', error: e);
    }
  }

  User? get currentUser => _currentUser;
  bool get hasUser => _currentUser != null;
  bool get isInitialized => _isInitialized;


  RateLimitStatus? _serverRateLimits;
  DateTime?        _lastRateLimitSync;
  static const Duration _rateLimitSyncInterval = Duration(minutes: 5);

  RateLimitStatus? get serverRateLimits => _serverRateLimits;

  /// Fetches authoritative rate limit status from backend.
  /// Frontend local counters are only for optimistic UI — server is truth.
  Future<void> syncRateLimitsFromServer(ProductionApiService apiService) async {
    final user = _currentUser;
    if (user == null) return;
    final now = DateTime.now();
    if (_lastRateLimitSync != null &&
        now.difference(_lastRateLimitSync!) < _rateLimitSyncInterval) return;
    try {
      final status = await apiService.getRateLimitStatus(user.id);
      if (status == null) return;
      _serverRateLimits = status;
      _lastRateLimitSync = now;
      // Sync local counters to server truth
      final serverRemaining = status.messages.remaining;
      _remainingRequests.value = serverRemaining;
      _isChatLimitReached.value = !status.canChat;
      _logger.d('[UserHandler] Rate limits synced: ${status.messages.remaining} msgs remaining');
    } catch (e) {
      _logger.w('[UserHandler] Rate limit sync failed', error: e);
    }
  }

  bool get canSendMessage {
    if (_currentUser == null) return false;

    final plan = _currentUser!.plan.toLowerCase().trim();
    if (plan == 'yearly' || plan == 'half_year') {
      return !_isUltraProSessionLimitReached.value;
    }

    if (_currentUser!.isPremium) return true;

    return !_isChatLimitReached.value &&
           _remainingRequests.value > 0 &&
           _checkRateLimit('send_message', _freePerMinuteLimit);
  }

  bool get canCreateNewChat {
    if (_currentUser == null) return false;
    if (_currentUser!.isPremium) return true;
    return true;
  }

  void incrementUltraProSessionMessage() {
    if (_currentUser?.plan.toLowerCase().trim() != 'yearly') return;
    _ultraProSessionMessageCount++;
    if (_ultraProSessionMessageCount >= _ultraProSessionLimit) {
      _isUltraProSessionLimitReached.value = true;
      _logger.w('[UltraPro] Session message limit reached ($_ultraProSessionLimit). User must start a new chat.');
    }
  }

  void resetUltraProSession() {
    if (_currentUser?.plan.toLowerCase().trim() != 'yearly') return;
    _ultraProSessionMessageCount = 0;
    _isUltraProSessionLimitReached.value = false;
    _logger.d('[UltraPro] Session counter reset for new chat.');
  }

  Future<void> decrementRequest() async {
    if (_currentUser != null && !_currentUser!.isPremium) {
      final newCount = _remainingRequests.value - 1;
      await updateRemainingRequests(newCount);
    }
  }

  void updateUserName(String name) {
    _userName.value = name;
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(name: name);
      _userNotifier.value = _currentUser;
    }
  }

  bool _checkRateLimit(String action, int limitPerWindow, {int windowMinutes = 1}) {
    if (_currentUser?.isPremium ?? false) return true;
    
    final now = DateTime.now();
    final key = '${_currentUser?.id}_$action';
    
    if (!_actionTimestamps.containsKey(key)) {
      _actionTimestamps[key] = [];
    }
    
    _actionTimestamps[key]!.removeWhere((time) => 
        now.difference(time).inMinutes >= windowMinutes);
    
    if (_actionTimestamps[key]!.length >= limitPerWindow) {
      return false;
    }
    
    _actionTimestamps[key]!.add(now);
    return true;
  }

  bool checkVoiceCooldown() {
    if (_currentUser?.isPremium ?? false) return true;
    
    final now = DateTime.now();
    final key = '${_currentUser?.id}_voice';
    
    if (_actionTimestamps.containsKey(key) && _actionTimestamps[key]!.isNotEmpty) {
      final lastTime = _actionTimestamps[key]!.last;
      final secondsSince = now.difference(lastTime).inSeconds;
      
      if (secondsSince < _voiceCooldown) {
        return false;
      }
    }
    
    if (!_actionTimestamps.containsKey(key)) {
      _actionTimestamps[key] = [];
    }
    _actionTimestamps[key]!.add(now);
    return true;
  }

  bool checkImageCooldown() {
    if (_currentUser?.isPremium ?? false) return true;
    
    final now = DateTime.now();
    final key = '${_currentUser?.id}_image';
    
    if (_actionTimestamps.containsKey(key) && _actionTimestamps[key]!.isNotEmpty) {
      final lastTime = _actionTimestamps[key]!.last;
      final secondsSince = now.difference(lastTime).inSeconds;
      
      if (secondsSince < _imageCooldown) {
        return false;
      }
    }
    
    if (!_actionTimestamps.containsKey(key)) {
      _actionTimestamps[key] = [];
    }
    _actionTimestamps[key]!.add(now);
    return true;
  }

  bool checkNewChatCooldown() {
    if (_currentUser?.isPremium ?? false) return true;

    final now = DateTime.now();
    final key = '${_currentUser?.id}_new_chat';

    if (_actionTimestamps.containsKey(key) && _actionTimestamps[key]!.isNotEmpty) {
      final lastTime = _actionTimestamps[key]!.last;
      final secondsSince = now.difference(lastTime).inSeconds;
      if (secondsSince < _newChatCooldown) {
        _logger.d('[Rate] New chat cooldown active: ${_newChatCooldown - secondsSince}s remaining');
        return false;
      }
    }

    if (!_actionTimestamps.containsKey(key)) {
      _actionTimestamps[key] = [];
    }
    _actionTimestamps[key]!.add(now);
    return true;
  }

  int getVoiceCooldownRemaining() {
    final now = DateTime.now();
    final key = '${_currentUser?.id}_voice';
    
    if (_actionTimestamps.containsKey(key) && _actionTimestamps[key]!.isNotEmpty) {
      final lastTime = _actionTimestamps[key]!.last;
      final secondsSince = now.difference(lastTime).inSeconds;
      
      if (secondsSince < _voiceCooldown) {
        return _voiceCooldown - secondsSince;
      }
    }
    
    return 0;
  }

  int getImageCooldownRemaining() {
    final now = DateTime.now();
    final key = '${_currentUser?.id}_image';
    
    if (_actionTimestamps.containsKey(key) && _actionTimestamps[key]!.isNotEmpty) {
      final lastTime = _actionTimestamps[key]!.last;
      final secondsSince = now.difference(lastTime).inSeconds;
      
      if (secondsSince < _imageCooldown) {
        return _imageCooldown - secondsSince;
      }
    }
    
    return 0;
  }

  int getNewChatCooldownRemaining() {
    return 0;
  }

  void dispose() {
    _isDisposed = true;
    _dailyResetTimer?.cancel();
    _dailyResetTimer = null;
    _rateLimitCleanupTimer?.cancel();
    _rateLimitCleanupTimer = null;
    _userNotifier.dispose();
    _remainingRequests.dispose();
    _isVoiceActive.dispose();
    _isChatLimitReached.dispose();
    _isUltraProSessionLimitReached.dispose();
    _userName.dispose();
    _themeMode.dispose();
    _locale.dispose();
    _actionTimestamps.clear();
    _logger.d('GlobalUserHandler disposed');
  }
}

// ===========================================
// FIXED: PERFORMANCE OPTIMIZER WITH PROPER DISPOSAL
// ===========================================
class PerformanceOptimizer {
  final ProductionLogger _logger;
  final Map<String, Stopwatch> _operations = {};
  final Map<String, List<int>> _operationDurations = {};
  final ValueNotifier<Map<String, double>> _fpsMetrics = ValueNotifier({});
  final ValueNotifier<Map<String, int>> _memoryMetrics = ValueNotifier({});
  Timer? _metricsTimer;
  bool _isInitialized = false;
  bool _isDisposed = false;
  
  static const int _targetFps = 60;
  static const int _frameTimeTarget = 16;
  static const int _maxJankFrames = 3;
  
  int _totalFrames = 0;
  int _jankFrames = 0;
  int _lastFrameTimestamp = 0;
  
  final Queue<int> _frameRenderTimes = Queue<int>();
  final Queue<int> _buildTimes = Queue<int>();
  
  static const int _memoryWarningThreshold = 150;
  static const int _memoryCriticalThreshold = 200;
  
  static const int _slowOperationThreshold = 100;
  static const int _verySlowOperationThreshold = 500;

  PerformanceOptimizer({required ProductionLogger logger}) : _logger = logger;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _startMetricsCollection();
      
      SchedulerBinding.instance.addTimingsCallback(_onTimingsCallback);
      
      _isInitialized = true;
      _logger.i('Performance Optimizer initialized');
    } catch (e, stack) {
      _logger.e('Failed to initialize Performance Optimizer', error: e, stackTrace: stack);
    }
  }

  void _onTimingsCallback(List<FrameTiming> timings) {
    if (_isDisposed) return;
    
    for (final timing in timings) {
      final frameTime = timing.totalSpan.inMilliseconds;
      final buildTime = timing.buildDuration.inMilliseconds;
      
      _frameRenderTimes.addLast(frameTime);
      if (_frameRenderTimes.length > 60) _frameRenderTimes.removeFirst();

      _buildTimes.addLast(buildTime);
      if (_buildTimes.length > 60) _buildTimes.removeFirst();
      
      if (frameTime > _frameTimeTarget) {
        _jankFrames++;
      }
      _totalFrames++;
      
      final now = DateTime.now().millisecondsSinceEpoch;
      if (_lastFrameTimestamp > 0) {
        final timeSinceLastFrame = now - _lastFrameTimestamp;
        if (timeSinceLastFrame > 0) {
          final currentFps = (1000 / timeSinceLastFrame).clamp(0, 60);
          _fpsMetrics.value = {
            ..._fpsMetrics.value,
            'current': currentFps,
            'average': _totalFrames > 0 ? (60 - (_jankFrames / _totalFrames * 60)) : 60,
            'jankRate': _totalFrames > 0 ? (_jankFrames / _totalFrames * 100) : 0,
          };
        }
      }
      _lastFrameTimestamp = now;
    }
  }

  void _startMetricsCollection() {
    _metricsTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!_isDisposed) {
        _collectMemoryMetrics();
        _checkPerformanceThresholds();
      }
    });
  }

  void _collectMemoryMetrics() {
    try {
      // ProcessInfo.currentRss is from dart:io — real RSS memory usage
      if (!kIsWeb) {
        _memoryMetrics.value = {
          'rss':     ProcessInfo.currentRss,
          'rss_mb':  (ProcessInfo.currentRss / (1024 * 1024)).round(),
        };
        final rssMb = (_memoryMetrics.value['rss_mb'] as int? ?? 0);
        if (rssMb > 300) {
          _logger.w('[Perf] High memory usage: ${rssMb}MB RSS');
        }
      }
    } catch (_) {}
  }

  void _checkPerformanceThresholds() {
    if (_frameRenderTimes.isNotEmpty) {
      final avgFrameTime = _frameRenderTimes.reduce((a, b) => a + b) ~/ _frameRenderTimes.length;
      if (avgFrameTime > _verySlowOperationThreshold) {
        _logger.w('High average frame time', error: {
          'avg_frame_time_ms': avgFrameTime,
          'jank_frames': _jankFrames,
          'total_frames': _totalFrames,
        });
      }
    }
    
    if (_buildTimes.isNotEmpty) {
      final avgBuildTime = _buildTimes.reduce((a, b) => a + b) ~/ _buildTimes.length;
      if (avgBuildTime > _slowOperationThreshold) {
        _logger.w('Slow widget builds', error: {
          'avg_build_time_ms': avgBuildTime,
        });
      }
    }
  }

  void startOperation(String name) {
    if (!_isInitialized || _isDisposed) return;
    
    final stopwatch = Stopwatch()..start();
    _operations[name] = stopwatch;
  }

  void endOperation(String name) {
    if (!_isInitialized || _isDisposed) return;
    
    final stopwatch = _operations.remove(name);
    if (stopwatch != null) {
      stopwatch.stop();
      final duration = stopwatch.elapsedMilliseconds;
      
      if (!_operationDurations.containsKey(name)) {
        _operationDurations[name] = [];
      }
      
      _operationDurations[name]!.add(duration);
      if (_operationDurations[name]!.length > 10) {
        _operationDurations[name]!.removeAt(0);
      }
      
      if (duration > _verySlowOperationThreshold) {
        _logger.w('Very slow operation', error: {
          'operation': name,
          'duration_ms': duration,
        });
      } else if (duration > _slowOperationThreshold) {
        _logger.d('Slow operation: $name took ${duration}ms');
      }
    }
  }

  Future<T> measureOperation<T>(String name, Future<T> Function() operation) async {
    startOperation(name);
    try {
      return await operation();
    } finally {
      endOperation(name);
    }
  }

  T measureSyncOperation<T>(String name, T Function() operation) {
    startOperation(name);
    try {
      return operation();
    } finally {
      endOperation(name);
    }
  }

  Timer? _debounceTimer;
  void debounce(VoidCallback action, {Duration duration = const Duration(milliseconds: 300)}) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(duration, action);
  }

  DateTime? _lastThrottleTime;
  bool throttle(VoidCallback action, {Duration duration = const Duration(milliseconds: 100)}) {
    final now = DateTime.now();
    if (_lastThrottleTime == null || now.difference(_lastThrottleTime!) > duration) {
      _lastThrottleTime = now;
      action();
      return true;
    }
    return false;
  }

  Map<String, dynamic> getPerformanceReport() {
    return {
      'fps': _fpsMetrics.value,
      'memory': _memoryMetrics.value,
      'average_frame_time': _frameRenderTimes.isEmpty ? 0 : _frameRenderTimes.reduce((a, b) => a + b) ~/ _frameRenderTimes.length,
      'average_build_time': _buildTimes.isEmpty ? 0 : _buildTimes.reduce((a, b) => a + b) ~/ _buildTimes.length,
      'jank_percentage': _totalFrames > 0 ? (_jankFrames / _totalFrames * 100) : 0,
    };
  }

  void dispose() {
    _isDisposed = true;
    _metricsTimer?.cancel();
    _debounceTimer?.cancel();
    _operations.clear();
    _operationDurations.clear();
    _fpsMetrics.dispose();
    _memoryMetrics.dispose();
    _frameRenderTimes.clear();
    _buildTimes.clear();
  }

  bool get isInitialized => _isInitialized;
}

// ===========================================
// FIXED: PRODUCTION CACHE MANAGER WITH SIZE LIMITS AND AUTO CLEANUP
// ===========================================
class ProductionCacheManager {
  final ProductionLogger _logger;
  final PerformanceOptimizer _performance;
  static const String _cacheKey = 'askroa_cache_manager';
  CacheStore? _cacheStore;
  DioCacheInterceptor? _cacheInterceptor;
  DefaultCacheManager? _imageCacheManager;
  
  final Pool _downloadPool = Pool(5);
  final Map<String, Completer<File>> _downloadCompleters = {};
  bool _isInitialized = false;
  bool _isDisposed = false;
  Timer? _cleanupTimer;
  
  static const int _maxCacheEntries = 1000;
  static const int _maxCacheSizeBytes = 100 * 1024 * 1024; // 100 MB

  ProductionCacheManager({required ProductionLogger logger, required PerformanceOptimizer performance})
      : _logger = logger, _performance = performance;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      await _performance.measureOperation('cache_init', () async {
        final isarDir = await getTemporaryDirectory();
        _cacheStore = IsarCacheStore(
          directory: isarDir.path,
          maxEntries: _maxCacheEntries,
        );
        
        _cacheInterceptor = DioCacheInterceptor(
          options: CacheOptions(
            store: _cacheStore,
            policy: CachePolicy.request,
            hitCacheOnErrorExcept: [401, 403],
            maxStale: const Duration(days: 30),
            priority: CachePriority.high,
            maxSize: _maxCacheSizeBytes,
            keyBuilder: (request) {
              return sha256.convert(utf8.encode(request.uri.toString())).toString();
            },
          ),
        );
        
        _imageCacheManager = CacheManager(
          Config(
            _cacheKey,
            stalePeriod: const Duration(days: 30),
            maxNrOfCacheObjects: 500,
            repo: JsonCacheInfoRepository(databaseName: _cacheKey),
            fileSystem: IOFileSystem(
              await _getImageCacheDirectory(),
            ),
            fileService: HttpFileService(),
          ),
        );
        
        _startCleanupTimer();
        
        _isInitialized = true;
        _logger.i('Production Cache Manager initialized');
        return null;
      });
    } catch (e, stack) {
      _logger.e('Failed to initialize cache manager', error: e, stackTrace: stack);
    }
  }

  void _startCleanupTimer() {
    _cleanupTimer = Timer.periodic(const Duration(hours: 24), (timer) {
      if (!_isDisposed) {
        clearExpiredCache();
      }
    });
  }

  Future<Directory> _getImageCacheDirectory() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${appDocDir.path}/image_cache');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir;
  }

  Future<File> downloadFileWithRetry({
    required String url,
    required String cacheKey,
    VoidCallback? onStart,
    void Function(double)? onProgress,
    int maxRetries = 3,
  }) async {
    return await _performance.measureOperation('download_file', () async {
      if (_downloadCompleters.containsKey(cacheKey)) {
        return _downloadCompleters[cacheKey]!.future;
      }

      final completer = Completer<File>();
      _downloadCompleters[cacheKey] = completer;

      try {
        await _downloadPool.withResource(() async {
          onStart?.call();

          if (_imageCacheManager == null) {
            completer.completeError(Exception('Image cache manager not initialized'));
            return;
          }

          for (int attempt = 1; attempt <= maxRetries; attempt++) {
            try {
              final file = await _imageCacheManager!.getSingleFile(url, key: cacheKey);

              final cacheSize = await getCacheSize();
              if (cacheSize > _maxCacheSizeBytes) {
                await _imageCacheManager!.removeFile(cacheKey);
                _logger.d('Cache size exceeded limit, evicted oldest entry');
              }

              completer.complete(file);
              return;
            } catch (e) {
              if (attempt == maxRetries) {
                completer.completeError(e);
              } else {
                await Future.delayed(Duration(seconds: attempt * 2));
              }
            }
          }
        });
      } finally {
        _downloadCompleters.remove(cacheKey);
      }

      return completer.future;
    });
  }

  Future<void> prefetchImages(List<String> urls) async {
    await _performance.measureOperation('prefetch_images', () async {
      final futures = urls.map((url) async {
        try {
          final cacheKey = sha256.convert(utf8.encode(url)).toString();
          await downloadFileWithRetry(
            url: url,
            cacheKey: cacheKey,
          ).timeout(const Duration(seconds: 10));
        } catch (e) {
          _logger.d('Prefetch failed for $url', error: e);
        }
      });
      
      await Future.wait(futures);
      return null;
    });
  }

  Future<void> clearExpiredCache() async {
    try {
      await _imageCacheManager?.emptyCache();
      await _cacheStore?.clean();
      _logger.d('Cache cleaned');
    } catch (e, stack) {
      _logger.e('Failed to clear cache', error: e, stackTrace: stack);
    }
  }

  Future<int> getCacheSize() async {
    try {
      final cacheDir = await _getImageCacheDirectory();
      int size = 0;
      
      await for (final file in cacheDir.list(recursive: true)) {
        if (file is File) {
          size += await file.length();
        }
      }
      
      return size;
    } catch (e) {
      _logger.d('Failed to get cache size', error: e);
      return 0;
    }
  }

  Future<void> clearAllCache() async {
    try {
      await _imageCacheManager?.emptyCache();
      await _cacheStore?.clean();
      await _imageCacheManager?.clean();
      _logger.d('All cache cleared');
    } catch (e, stack) {
      _logger.e('Failed to clear all cache', error: e, stackTrace: stack);
    }
  }

  DioCacheInterceptor? get cacheInterceptor => _cacheInterceptor;
  DefaultCacheManager? get imageCacheManager => _imageCacheManager;
  bool get isInitialized => _isInitialized;

  void dispose() {
    _isDisposed = true;
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
    _downloadCompleters.clear();
    _cacheStore = null;
    _cacheInterceptor = null;
    _imageCacheManager = null;
  }
}

// ===========================================
// ASKROA MODEL SYSTEM
// ===========================================

enum ModelTier { free, basic, pro, elite }

extension ModelTierExt on ModelTier {
  String get label {
    switch (this) {
      case ModelTier.free:  return 'Free';
      case ModelTier.basic: return 'Monthly';     // backend: 'monthly'
      case ModelTier.pro:   return 'Pro+';         // backend: 'half_year'
      case ModelTier.elite: return 'Ultra Pro';    // backend: 'yearly'
    }
  }

  String get backendPlanKey {
    switch (this) {
      case ModelTier.free:  return 'free';
      case ModelTier.basic: return 'monthly';
      case ModelTier.pro:   return 'half_year';
      case ModelTier.elite: return 'yearly';
    }
  }

  Color get badgeColor {
    switch (this) {
      case ModelTier.free:  return const Color(0xFF34C759);   // green
      case ModelTier.basic: return const Color(0xFF007AFF);   // blue
      case ModelTier.pro:   return const Color(0xFFFFD700);   // gold
      case ModelTier.elite: return const Color(0xFFFF6B35);   // orange
    }
  }

  String get priceLabel {
    switch (this) {
      case ModelTier.free:  return 'Free forever';
      case ModelTier.basic: return '\$25/month';
      case ModelTier.pro:   return '\$90/6 months';
      case ModelTier.elite: return '\$510/year';
    }
  }
}

@immutable
class AskroaModelInfo {
  final String id;
  final String displayName;
  final String provider;
  final ModelTier tier;
  final String description;
  final bool supportsThinking;
  final bool supportsCode;
  final bool isFast;
  final bool isImageModel;
  final bool isAudioModel;
  final bool isVideoModel;

  const AskroaModelInfo({
    required this.id,
    required this.displayName,
    required this.provider,
    required this.tier,
    required this.description,
    this.supportsThinking = false,
    this.supportsCode = false,
    this.isFast = false,
    this.isImageModel = false,
    this.isAudioModel = false,
    this.isVideoModel = false,
  });

  IconData get typeIcon {
    if (isImageModel) return Icons.image_outlined;
    if (isAudioModel) return Icons.mic_none_outlined;
    if (isVideoModel) return Icons.videocam_outlined;
    if (supportsThinking) return Icons.psychology_outlined;
    if (supportsCode) return Icons.code_outlined;
    return Icons.chat_bubble_outline_rounded;
  }

  String get typeLabel {
    if (isImageModel) return 'Image';
    if (isAudioModel) return 'Audio';
    if (isVideoModel) return 'Video';
    if (supportsThinking) return 'Thinking';
    if (supportsCode) return 'Code';
    return 'Text';
  }
}



const List<AskroaModelInfo> kAskroaModels = [
  AskroaModelInfo(id: 'gpt-4o-mini',          displayName: 'GPT-4o Mini',         provider: 'OpenAI',    tier: ModelTier.free,  description: 'Fast everyday AI',            isFast: true),
  AskroaModelInfo(id: 'gemini-2.0-flash',      displayName: 'Gemini 2.0 Flash',    provider: 'Google',    tier: ModelTier.free,  description: 'Lightweight & fast',          isFast: true),
  AskroaModelInfo(id: 'llama-3.3-70b',         displayName: 'Llama 3.3 70B',       provider: 'Meta',      tier: ModelTier.free,  description: 'Open-source, capable',        supportsCode: true),
  AskroaModelInfo(id: 'claude-sonnet-4-6',     displayName: 'Claude Sonnet 4.6',   provider: 'Anthropic', tier: ModelTier.basic, description: 'Smart & efficient',           supportsCode: true, isFast: true),
  AskroaModelInfo(id: 'gpt-4o',                displayName: 'GPT-4o',              provider: 'OpenAI',    tier: ModelTier.basic, description: 'Powerful multimodal AI',      supportsCode: true),
  AskroaModelInfo(id: 'gemini-2.5-flash',      displayName: 'Gemini 2.5 Flash',    provider: 'Google',    tier: ModelTier.basic, description: 'Fast reasoning model',        isFast: true),
  AskroaModelInfo(id: 'grok-3-mini',           displayName: 'Grok 3 Mini',         provider: 'xAI',       tier: ModelTier.basic, description: 'Efficient xAI model',         isFast: true),
  AskroaModelInfo(id: 'deepseek-r2-lite',      displayName: 'DeepSeek R2 Lite',    provider: 'DeepSeek',  tier: ModelTier.basic, description: 'Cost-efficient reasoning',     supportsCode: true),
  AskroaModelInfo(id: 'claude-opus-4-6',       displayName: 'Claude Opus 4.6',     provider: 'Anthropic', tier: ModelTier.pro,   description: 'Most intelligent Claude',     supportsThinking: true, supportsCode: true),
  AskroaModelInfo(id: 'gpt-4-5',              displayName: 'GPT-4.5',             provider: 'OpenAI',    tier: ModelTier.pro,   description: 'Advanced reasoning & code',   supportsCode: true, supportsThinking: true),
  AskroaModelInfo(id: 'gemini-2.5-pro',        displayName: 'Gemini 2.5 Pro',      provider: 'Google',    tier: ModelTier.pro,   description: 'Advanced multimodal',         supportsThinking: true),
  AskroaModelInfo(id: 'grok-3',               displayName: 'Grok 3',              provider: 'xAI',       tier: ModelTier.pro,   description: 'xAI flagship model',          supportsCode: true),
  AskroaModelInfo(id: 'deepseek-r2',          displayName: 'DeepSeek R2',         provider: 'DeepSeek',  tier: ModelTier.pro,   description: 'Advanced chain-of-thought',   supportsThinking: true, supportsCode: true),
  AskroaModelInfo(id: 'llama-4-maverick',     displayName: 'Llama 4 Maverick',    provider: 'Meta',      tier: ModelTier.pro,   description: 'Meta multimodal leader',      supportsCode: true),
  AskroaModelInfo(id: 'claude-opus-4-ultra',   displayName: 'Claude Opus 4 Ultra', provider: 'Anthropic', tier: ModelTier.elite, description: 'Most powerful Claude',        supportsThinking: true, supportsCode: true),
  AskroaModelInfo(id: 'gpt-4-5-turbo',        displayName: 'GPT-4.5 Turbo',      provider: 'OpenAI',    tier: ModelTier.elite, description: 'Max power & speed',           supportsThinking: true, supportsCode: true),
  AskroaModelInfo(id: 'gemini-2.5-ultra',      displayName: 'Gemini 2.5 Ultra',    provider: 'Google',    tier: ModelTier.elite, description: 'Google\'s most capable',      supportsThinking: true),
  AskroaModelInfo(id: 'grok-3-5',             displayName: 'Grok 3.5',            provider: 'xAI',       tier: ModelTier.elite, description: 'xAI ultra model',             supportsThinking: true, supportsCode: true),
  AskroaModelInfo(id: 'llama-4-behemoth',     displayName: 'Llama 4 Behemoth',    provider: 'Meta',      tier: ModelTier.elite, description: 'Meta\'s largest model',       supportsThinking: true, supportsCode: true),
  AskroaModelInfo(id: 'deepseek-r3',          displayName: 'DeepSeek R3',         provider: 'DeepSeek',  tier: ModelTier.elite, description: 'SOTA open-source reasoning',  supportsThinking: true, supportsCode: true),
];

AskroaModelInfo? modelInfoFromAnyId(String? rawId) {
  if (rawId == null) return null;
  try {
    return kAskroaModels.firstWhere((m) => m.id == rawId);
  } catch (_) {}
  final lc = rawId.toLowerCase();
  for (final m in kAskroaModels) {
    if (lc.contains(m.id.toLowerCase()) ||
        m.id.toLowerCase().contains(lc) ||
        lc.contains(m.displayName.toLowerCase().replaceAll(' ', '-'))) {
      return m;
    }
  }
  return null;
}


@immutable
class ModelSelectionState {
  final Map<String, String?> sessionModels;
  final String? activeSessionId;
  final bool isSyncing;

  const ModelSelectionState({
    this.sessionModels = const {},
    this.activeSessionId,
    this.isSyncing = false,
  });

  String? get effectiveModelId => activeSessionId == null
      ? null
      : sessionModels[activeSessionId!];

  bool get isManual => effectiveModelId != null;

  ModelSelectionState copyWith({
    Map<String, String?>? sessionModels,
    String? activeSessionId,
    bool clearActiveSession = false,
    bool? isSyncing,
  }) {
    return ModelSelectionState(
      sessionModels: sessionModels ?? this.sessionModels,
      activeSessionId: clearActiveSession
          ? null
          : (activeSessionId ?? this.activeSessionId),
      isSyncing: isSyncing ?? this.isSyncing,
    );
  }
}

class ModelSelectionNotifier extends StateNotifier<ModelSelectionState> {
  final Ref _ref;
  ProductionLogger? _logger;

  ModelSelectionNotifier(this._ref) : super(const ModelSelectionState()) {
    _logger = _ref.read(loggerProvider);
  }

  void setActiveSession(String sessionId) {
    state = state.copyWith(activeSessionId: sessionId);
  }

  void removeSession(String sessionId) {
    final updated = Map<String, String?>.from(state.sessionModels)..remove(sessionId);
    final newActiveId = state.activeSessionId == sessionId ? null : state.activeSessionId;
    state = state.copyWith(
      sessionModels: updated,
      clearActiveSession: newActiveId == null,
      activeSessionId: newActiveId,
    );
    _logger?.d('[ModelSelect] Session removed: $sessionId, activeSession → $newActiveId');
  }

  Future<bool> selectModelAsync({
    required String sessionId,
    required String modelId,
    required ProductionApiService apiService,
  }) async {
    state = state.copyWith(isSyncing: true);
    try {
      final result = await apiService.selectModelForSession(
        sessionId: sessionId,
        modelId: modelId,
      );

      if (result['success'] == true && result['allowed'] == true) {
        final updated = Map<String, String?>.from(state.sessionModels);
        updated[sessionId] = modelId;
        state = state.copyWith(
          sessionModels: updated,
          activeSessionId: sessionId,
          isSyncing: false,
        );
        _logger?.i('[ModelSelect] Pinned model=$modelId session=$sessionId');
        return true;
      } else {
        _logger?.w(
          '[ModelSelect] Backend denied model=$modelId: ${result['detail'] ?? result['message']}',
        );
        state = state.copyWith(isSyncing: false);
        return false;
      }
    } catch (e) {
      _logger?.e('[ModelSelect] selectModelAsync failed', error: e);
      state = state.copyWith(isSyncing: false);
      return false;
    }
  }

  void selectModel(String sessionId, String modelId) {
    final updated = Map<String, String?>.from(state.sessionModels);
    updated[sessionId] = modelId;
    state = state.copyWith(sessionModels: updated, activeSessionId: sessionId);
  }

  Future<void> clearManualSelectionAsync({
    required String sessionId,
    required ProductionApiService apiService,
  }) async {
    try {
      await apiService.clearModelSelection();
    } catch (e) {
      _logger?.w('[ModelSelect] Backend clear failed (ignoring)', error: e);
    }
    final updated = Map<String, String?>.from(state.sessionModels);
    updated.remove(sessionId);
    state = state.copyWith(sessionModels: updated);
  }

  void clearManualSelection(String sessionId) {
    final updated = Map<String, String?>.from(state.sessionModels);
    updated.remove(sessionId);
    state = state.copyWith(sessionModels: updated);
  }

  void onNewChat(String sessionId) {
    final updated = Map<String, String?>.from(state.sessionModels)
      ..remove(sessionId);
    state = state.copyWith(sessionModels: updated, activeSessionId: sessionId);
    _logger?.d('[ModelSelect] New chat → auto-select resumed session=$sessionId');
    try {
      _ref.read(apiServiceProvider).whenData((api) {
        api.clearModelSelection().catchError((e) {
          _logger?.w('[ModelSelect] Backend clear on new-chat failed', error: e);
        });
      });
    } catch (_) {}
  }

  String? modelForSession(String sessionId) => state.sessionModels[sessionId];
}

final modelSelectionProvider =
    StateNotifierProvider<ModelSelectionNotifier, ModelSelectionState>(
  (ref) => ModelSelectionNotifier(ref),
);

bool canUserAccessTier(String userPlan, ModelTier tier) {
  final normalised = switch (userPlan.toLowerCase().trim()) {
    'monthly'   => 'monthly',
    'half_year' => 'half_year',
    'yearly'    => 'yearly',
    'pro'       => 'half_year',   // legacy alias
    'elite'     => 'yearly',      // legacy alias
    'basic'     => 'monthly',     // legacy alias
    _           => 'free',
  };

  switch (tier) {
    case ModelTier.free:
      return true;                  // every plan gets free models
    case ModelTier.basic:
      return normalised != 'free';  // monthly, half_year, yearly
    case ModelTier.pro:
      return normalised == 'half_year' || normalised == 'yearly';
    case ModelTier.elite:
      return normalised == 'yearly';
  }
}

// ===========================================
// DATA MODELS
// ===========================================
@immutable
class User {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? profileImage;
  final String plan;
  final DateTime createdAt;
  final DateTime? subscriptionExpiry;
  final int dailyRequests;
  final int maxRequests;
  final Map<String, dynamic> preferences;
  final bool isVoiceTrained;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.profileImage,
    required this.plan,
    required this.createdAt,
    this.subscriptionExpiry,
    this.dailyRequests = 0,
    this.maxRequests = 5,
    this.preferences = const {},
    this.isVoiceTrained = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      profileImage: json['profile_image'] as String?,
      plan: json['plan'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      subscriptionExpiry: json['subscription_expiry'] != null
          ? DateTime.parse(json['subscription_expiry'] as String)
          : null,
      dailyRequests: json['daily_requests'] as int? ?? 0,
      maxRequests: json['max_requests'] as int? ?? 5,
      preferences: json['preferences'] as Map<String, dynamic>? ?? const {},
      isVoiceTrained: json['is_voice_trained'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profile_image': profileImage,
      'plan': plan,
      'created_at': createdAt.toIso8601String(),
      'subscription_expiry': subscriptionExpiry?.toIso8601String(),
      'daily_requests': dailyRequests,
      'max_requests': maxRequests,
      'preferences': preferences,
      'is_voice_trained': isVoiceTrained,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? profileImage,
    String? plan,
    DateTime? createdAt,
    DateTime? subscriptionExpiry,
    int? dailyRequests,
    int? maxRequests,
    Map<String, dynamic>? preferences,
    bool? isVoiceTrained,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      plan: plan ?? this.plan,
      createdAt: createdAt ?? this.createdAt,
      subscriptionExpiry: subscriptionExpiry ?? this.subscriptionExpiry,
      dailyRequests: dailyRequests ?? this.dailyRequests,
      maxRequests: maxRequests ?? this.maxRequests,
      preferences: preferences ?? this.preferences,
      isVoiceTrained: isVoiceTrained ?? this.isVoiceTrained,
    );
  }

  bool get isPremium => plan != 'free';
  bool get canUseVoice => isPremium || dailyRequests < maxRequests;
  bool get canGenerateImages => isPremium;
  bool get canUseDeepResearch => isPremium;
  bool get isBasicOrAbove => plan == 'basic' || plan == 'pro' || plan == 'elite';
  bool get isProOrAbove    => plan == 'pro' || plan == 'elite';
  bool get isElite         => plan == 'elite';
}

@immutable
class ChatMessage {
  final String id;
  final String text;
  final String sender;
  final DateTime timestamp;
  final bool isLiked;
  final bool isDisliked;
  final bool isReported;
  final String? parentMessageId;
  final List<String>? attachments;
  final Map<String, dynamic>? metadata;
  final bool isStreaming;
  final String? streamingText;
  final bool isThinking;
  final String? thinkingText;
  final String? modelUsed;
  final bool isEdited;
  final DateTime? editedAt;
  final String? feedbackText;   // dislike reason written by user
  final String? reportText;     // report reason written by user

  const ChatMessage({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
    this.isLiked = false,
    this.isDisliked = false,
    this.isReported = false,
    this.parentMessageId,
    this.attachments,
    this.metadata,
    this.isStreaming = false,
    this.streamingText,
    this.isThinking = false,
    this.thinkingText,
    this.modelUsed,
    this.isEdited = false,
    this.editedAt,
    this.feedbackText,
    this.reportText,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      text: json['text'] as String,
      sender: json['sender'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isLiked: json['is_liked'] as bool? ?? false,
      isDisliked: json['is_disliked'] as bool? ?? false,
      isReported: json['is_reported'] as bool? ?? false,
      parentMessageId: json['parent_message_id'] as String?,
      attachments: json['attachments'] != null
          ? List<String>.from(json['attachments'] as List)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
      isStreaming: json['is_streaming'] as bool? ?? false,
      streamingText: json['streaming_text'] as String?,
      isThinking: json['is_thinking'] as bool? ?? false,
      thinkingText: json['thinking_text'] as String?,
      modelUsed: json['model_used'] as String?,
      isEdited: json['is_edited'] as bool? ?? false,
      editedAt: json['edited_at'] != null ? DateTime.parse(json['edited_at'] as String) : null,
      feedbackText: json['feedback_text'] as String?,
      reportText: json['report_text'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'sender': sender,
      'timestamp': timestamp.toIso8601String(),
      'is_liked': isLiked,
      'is_disliked': isDisliked,
      'is_reported': isReported,
      'parent_message_id': parentMessageId,
      'attachments': attachments,
      'metadata': metadata,
      'is_streaming': isStreaming,
      'streaming_text': streamingText,
      'is_thinking': isThinking,
      'thinking_text': thinkingText,
      'model_used': modelUsed,
      'is_edited': isEdited,
      'edited_at': editedAt?.toIso8601String(),
      'feedback_text': feedbackText,
      'report_text': reportText,
    };
  }

  ChatMessage copyWith({
    String? id,
    String? text,
    String? sender,
    DateTime? timestamp,
    bool? isLiked,
    bool? isDisliked,
    bool? isReported,
    String? parentMessageId,
    List<String>? attachments,
    Map<String, dynamic>? metadata,
    bool? isStreaming,
    String? streamingText,
    bool? isThinking,
    String? thinkingText,
    String? modelUsed,
    bool? isEdited,
    DateTime? editedAt,
    String? feedbackText,
    String? reportText,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      sender: sender ?? this.sender,
      timestamp: timestamp ?? this.timestamp,
      isLiked: isLiked ?? this.isLiked,
      isDisliked: isDisliked ?? this.isDisliked,
      isReported: isReported ?? this.isReported,
      parentMessageId: parentMessageId ?? this.parentMessageId,
      attachments: attachments ?? this.attachments,
      metadata: metadata ?? this.metadata,
      isStreaming: isStreaming ?? this.isStreaming,
      streamingText: streamingText ?? this.streamingText,
      isThinking: isThinking ?? this.isThinking,
      thinkingText: thinkingText ?? this.thinkingText,
      modelUsed: modelUsed ?? this.modelUsed,
      isEdited: isEdited ?? this.isEdited,
      editedAt: editedAt ?? this.editedAt,
      feedbackText: feedbackText ?? this.feedbackText,
      reportText: reportText ?? this.reportText,
    );
  }
}

@immutable
class ChatSession {
  final String id;
  final String title;
  final bool titleLocked;
  final List<ChatMessage> messages;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPinned;
  final String? category;
  final Map<String, dynamic>? sessionData;

  const ChatSession({
    required this.id,
    required this.title,
    this.titleLocked = false,
    required this.messages,
    required this.createdAt,
    required this.updatedAt,
    this.isPinned = false,
    this.category,
    this.sessionData,
  });

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'] as String,
      title: json['title'] as String,
      messages: (json['messages'] as List)
          .map((msg) => ChatMessage.fromJson(msg as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isPinned: json['is_pinned'] as bool? ?? false,
      titleLocked: json['title_locked'] as bool? ?? false,
      category: json['category'] as String?,
      sessionData: json['session_data'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'title_locked': titleLocked,
      'messages': messages.map((msg) => msg.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_pinned': isPinned,
      'category': category,
      'session_data': sessionData,
    };
  }

  ChatSession copyWith({
    String? id,
    String? title,
    bool? titleLocked,
    List<ChatMessage>? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPinned,
    String? category,
    Map<String, dynamic>? sessionData,
  }) {
    return ChatSession(
      id: id ?? this.id,
      title: title ?? this.title,
      titleLocked: titleLocked ?? this.titleLocked,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPinned: isPinned ?? this.isPinned,
      category: category ?? this.category,
      sessionData: sessionData ?? this.sessionData,
    );
  }
}

@immutable
class ImageHistoryItem {
  final String id;
  final String url;
  final String thumbnailUrl;
  final String? videoUrl;
  final String prompt;
  final String type;
  final DateTime createdAt;
  final String? sessionId;
  final Map<String, dynamic>? metadata;

  const ImageHistoryItem({
    required this.id,
    required this.url,
    required this.thumbnailUrl,
    this.videoUrl,
    required this.prompt,
    required this.type,
    required this.createdAt,
    this.sessionId,
    this.metadata,
  });

  factory ImageHistoryItem.fromJson(Map<String, dynamic> json) {
    return ImageHistoryItem(
      id: json['id'] as String,
      url: json['url'] as String,
      thumbnailUrl: json['thumbnail_url'] as String,
      videoUrl: json['video_url'] as String?,
      prompt: json['prompt'] as String,
      type: json['type'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      sessionId: json['session_id'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'thumbnail_url': thumbnailUrl,
      'video_url': videoUrl,
      'prompt': prompt,
      'type': type,
      'created_at': createdAt.toIso8601String(),
      'session_id': sessionId,
      'metadata': metadata,
    };
  }
}

// ===========================================
// SUBSCRIPTION PLANS
// ===========================================
enum SubscriptionPlan {
  free(
    id: 'free',
    name: 'Free',
    price: 0.00,
    priceDisplay: 'Free',
    features: [
      'Basic Chat (100k context)',
      '5 Image Generations Daily',
      'Basic File Processing',
      'Basic Search',
      '5 Videos Daily',
    ],
    limitations: [],
  ),
  monthly(
    id: 'monthly',
    name: 'Monthly Pro',
    price: 25.0,
    priceDisplay: '\$25/month',
    features: [
      'Advanced Chat (400k context)',
      'Advanced Search',
      'Advanced File Processing',
      '20 Images Daily',
      '19 Videos Daily',
    ],
    limitations: [],
    isPopular: false,
  ),
  halfYearly(
    id: 'half_year',
    name: '6 Months Pro+',
    price: 90.00,
    priceDisplay: '\$90/6 months',
    features: [
      'Advanced Chat (129k context)',
      'All Monthly Pro Features',
      'Advanced Models',
      '34 Videos Daily',
      'Advanced Analytics',
      '38 Images Daily',
    ],
    limitations: [],
    isPopular: true,
  ),
  yearly(
    id: 'yearly',
    name: '1 Year Ultra Pro',
    price: 510.00,
    priceDisplay: '\$510/year',
    features: [
      '1.5 Million Chat Context with Powerful Models',
      'All Monthly Pro Features',
      'Early Access',
      'All Advanced Models',
      '400 Images Daily',
      '340 Videos Daily',
    ],
    limitations: [],
    isPopular: false,
  );

  final String id;
  final String name;
  final double price;
  final String priceDisplay;
  final List<String> features;
  final List<String> limitations;
  final bool isPopular;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.priceDisplay,
    required this.features,
    this.limitations = const [],
    this.isPopular = false,
  });

  String get monthlyEquivalent {
    if (id == 'monthly') return priceDisplay;
    if (id == 'half_year') return '\$${(price / 6).toStringAsFixed(2)}/month';
    if (id == 'yearly') return '\$${(price / 12).toStringAsFixed(2)}/month';
    return priceDisplay;
  }
}

// ===========================================
// DRIFT DATABASE TABLES
// ===========================================
@DataClassName('LocalChatMessage')
class LocalChatMessages extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get serverId => text().withLength(min: 1, max: 100)();
  TextColumn get sessionId => text().withLength(min: 1, max: 100)();
  TextColumn get text => text()();
  TextColumn get sender => text().withLength(min: 1, max: 50)();
  DateTimeColumn get timestamp => dateTime()();
  BoolColumn get isLiked => boolean().withDefault(const Constant(false))();
  BoolColumn get isDisliked => boolean().withDefault(const Constant(false))();
  BoolColumn get isReported => boolean().withDefault(const Constant(false))();
  TextColumn get parentMessageId => text().nullable()();
  TextColumn get attachments => text().nullable()();
  TextColumn get metadataJson => text().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  BoolColumn get isFailed => boolean().withDefault(const Constant(false))();
  TextColumn get errorMessage => text().nullable()();
  BoolColumn get isStreaming => boolean().withDefault(const Constant(false))();
  TextColumn get streamingText => text().nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
  @override
  List<String> get customConstraints => [
    'UNIQUE(serverId)',
  ];
}

@DataClassName('LocalChatSession')
class LocalChatSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get serverId => text().withLength(min: 1, max: 100)();
  TextColumn get title => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();
  TextColumn get category => text().nullable()();
  TextColumn get sessionDataJson => text().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  
  @override
  Set<Column> get primaryKey => {id};
  @override
  List<String> get customConstraints => [
    'UNIQUE(serverId)',
  ];
}

@DataClassName('LocalImageHistory')
class LocalImageHistories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get serverId => text().withLength(min: 1, max: 100)();
  TextColumn get url => text()();
  TextColumn get thumbnailUrl => text()();
  TextColumn get videoUrl => text().nullable()();
  TextColumn get prompt => text()();
  TextColumn get type => text()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get sessionId => text().nullable()();
  TextColumn get metadataJson => text().nullable()();
  BoolColumn get isDownloaded => boolean().withDefault(const Constant(false))();
  TextColumn get localPath => text().nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
  @override
  List<String> get customConstraints => [
    'UNIQUE(serverId)',
  ];
}

@DataClassName('LocalUser')
class LocalUsers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get serverId => text().withLength(min: 1, max: 100)();
  TextColumn get name => text()();
  TextColumn get email => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get profileImage => text().nullable()();
  TextColumn get plan => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get subscriptionExpiry => dateTime().nullable()();
  IntColumn get dailyRequests => integer().withDefault(const Constant(0))();
  IntColumn get maxRequests => integer().withDefault(const Constant(5))();
  TextColumn get preferencesJson => text().withDefault(const Constant('{}'))();
  BoolColumn get isVoiceTrained => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastSynced => dateTime()();
  
  @override
  Set<Column> get primaryKey => {id};
  @override
  List<String> get customConstraints => [
    'UNIQUE(serverId)',
  ];
}

@DataClassName('LocalOfflineQueue')
class LocalOfflineQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text()();
  TextColumn get operation => text()();
  TextColumn get entity => text()();
  TextColumn get entityId => text()();
  TextColumn get data => text()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get processedAt => dateTime().nullable()();
  TextColumn get errorMessage => text().nullable()();
  TextColumn get idempotencyKey => text().nullable()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get nextRetryAt => dateTime().nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
  @override
  List<String> get customConstraints => [
    'UNIQUE(idempotencyKey)',
  ];
}

@DataClassName('LocalSyncMetadata')
class LocalSyncMetadata extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text()();
  TextColumn get entity => text()();
  DateTimeColumn get lastSync => dateTime()();
  
  @override
  Set<Column> get primaryKey => {id};
  @override
  List<String> get customConstraints => [
    'UNIQUE(userId, entity)',
  ];
}

// ===========================================
// DRIFT DATABASE WITH PROPER ISOLATE MANAGEMENT
// ===========================================
@DriftDatabase(tables: [
  LocalChatMessages,
  LocalChatSessions,
  LocalImageHistories,
  LocalUsers,
  LocalOfflineQueue,
  LocalSyncMetadata,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await customStatement('CREATE INDEX idx_messages_session_id ON local_chat_messages (session_id);');
        await customStatement('CREATE INDEX idx_messages_timestamp ON local_chat_messages (timestamp);');
        await customStatement('CREATE INDEX idx_sessions_updated_at ON local_chat_sessions (updated_at);');
        await customStatement('CREATE INDEX idx_images_created_at ON local_image_histories (created_at);');
        await customStatement('CREATE INDEX idx_queue_created_at ON local_offline_queue (created_at);');
        await customStatement('CREATE INDEX IF NOT EXISTS idx_messages_session_ts '
            'ON local_chat_messages (session_id, timestamp DESC);');
        await customStatement('CREATE INDEX IF NOT EXISTS idx_messages_unsynced '
            'ON local_chat_messages (is_synced) WHERE is_synced = 0;');
        await customStatement('CREATE INDEX IF NOT EXISTS idx_sessions_pinned_updated '
            'ON local_chat_sessions (is_pinned DESC, updated_at DESC);');
        await customStatement('CREATE INDEX IF NOT EXISTS idx_queue_pending '
            'ON local_offline_queue (status, created_at) WHERE status = \'pending\';');
      },
      onUpgrade: (Migrator m, int from, int to) async {
        try {
          if (from < 2) {
            await m.addColumn(localChatMessages, localChatMessages.parentMessageId);
          }
          if (from < 3) {
            await m.addColumn(localChatMessages, localChatMessages.metadataJson);
          }
          if (from < 4) {
            await m.createTable(localOfflineQueue);
          }
          if (from < 5) {
            await m.createTable(localSyncMetadata);
          }
          if (from < 6) {
            await m.addColumn(localUsers, localUsers.preferencesJson);
            await m.addColumn(localUsers, localUsers.isVoiceTrained);
            await customStatement(
              "UPDATE local_users SET preferences_json = '{}' WHERE preferences_json IS NULL;"
            );
            await customStatement(
              "UPDATE local_users SET is_voice_trained = 0 WHERE is_voice_trained IS NULL;"
            );
            await customStatement(
              "UPDATE local_users SET last_synced = datetime('now') WHERE last_synced IS NULL;"
            );
            await customStatement(
              "UPDATE local_chat_messages SET is_synced = 0 WHERE is_synced IS NULL;"
            );
            await customStatement(
              "UPDATE local_chat_messages SET is_failed = 0 WHERE is_failed IS NULL;"
            );
            await customStatement(
              "UPDATE local_chat_messages SET is_streaming = 0 WHERE is_streaming IS NULL;"
            );
          }
        } catch (e, stack) {
          // migration failure logged via rethrow
          rethrow;
        }
      },
    );
  }

  Future<int> insertChatMessage(LocalChatMessagesCompanion message) {
    return into(localChatMessages).insert(message);
  }

  Future<void> updateChatMessage(LocalChatMessagesCompanion message) {
    return update(localChatMessages).replace(message);
  }

  Future<List<LocalChatMessage>> getChatMessages(String sessionId, {int limit = 50, int offset = 0}) {
    return (select(localChatMessages)
      ..where((tbl) => tbl.sessionId.equals(sessionId))
      ..orderBy([(t) => OrderingTerm(expression: t.timestamp, mode: OrderingMode.desc)])
      ..limit(limit, offset: offset))
      .get();
  }

  Future<void> deleteChatMessage(String serverId) {
    return (delete(localChatMessages)..where((tbl) => tbl.serverId.equals(serverId))).go();
  }

  Future<void> markMessageAsSynced(String serverId) {
    return (update(localChatMessages)
      ..where((tbl) => tbl.serverId.equals(serverId)))
      .write(const LocalChatMessagesCompanion(
        isSynced: drift.Value(true),
        isFailed: drift.Value(false),
      ));
  }

  Future<void> markMessageAsFailed(String serverId, String error) {
    return (update(localChatMessages)
      ..where((tbl) => tbl.serverId.equals(serverId)))
      .write(LocalChatMessagesCompanion(
        isFailed: const drift.Value(true),
        errorMessage: drift.Value(error),
      ));
  }

  Future<void> updateStreamingMessage(String serverId, String text) {
    return (update(localChatMessages)
      ..where((tbl) => tbl.serverId.equals(serverId)))
      .write(LocalChatMessagesCompanion(
        streamingText: drift.Value(text),
        isStreaming: const drift.Value(true),
      ));
  }

  Future<void> completeStreamingMessage(String serverId, String finalText) {
    return (update(localChatMessages)
      ..where((tbl) => tbl.serverId.equals(serverId)))
      .write(LocalChatMessagesCompanion(
        text: drift.Value(finalText),
        streamingText: const drift.Value(null),
        isStreaming: const drift.Value(false),
        isSynced: const drift.Value(true),
      ));
  }

  Future<int> insertChatSession(LocalChatSessionsCompanion session) {
    return into(localChatSessions).insert(session);
  }

  Future<void> insertMessageAndSession(
    LocalChatMessagesCompanion message,
    LocalChatSessionsCompanion session,
  ) {
    return transaction(() async {
      await into(localChatSessions).insertOnConflictUpdate(session);
      await into(localChatMessages).insert(message);
    });
  }

  Future<void> updateChatSession(LocalChatSessionsCompanion session) {
    return update(localChatSessions).replace(session);
  }

  Future<List<LocalChatSession>> getChatSessions({int limit = 100, int offset = 0}) {
    return (select(localChatSessions)
      ..orderBy([(t) => OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc)])
      ..limit(limit, offset: offset))
      .get();
  }

  Future<int> insertImageHistory(LocalImageHistoriesCompanion image) {
    return into(localImageHistories).insert(image);
  }

  Future<List<LocalImageHistory>> getImageHistory({int limit = 100, int offset = 0}) {
    return (select(localImageHistories)
      ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)])
      ..limit(limit, offset: offset))
      .get();
  }

  Future<int> insertUser(LocalUsersCompanion user) {
    return into(localUsers).insert(user, mode: InsertMode.insertOrReplace);
  }

  Future<LocalUser?> getUser(String userId) {
    return (select(localUsers)..where((tbl) => tbl.serverId.equals(userId))).getSingleOrNull();
  }

  Future<int> addToQueue(LocalOfflineQueueCompanion item) {
    return into(localOfflineQueue).insert(item);
  }

  Future<List<LocalOfflineQueue>> getPendingQueueItems() {
    return (select(localOfflineQueue)
      ..where((tbl) => tbl.status.equals('pending'))
      ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.asc)]))
      .get();
  }

  Future<void> markQueueItemAsProcessed(int id) {
    return (update(localOfflineQueue)..where((tbl) => tbl.id.equals(id)))
      .write(const LocalOfflineQueueCompanion(
        status: drift.Value('processed'),
        processedAt: drift.Value(DateTime.now()),
      ));
  }

  Future<void> markQueueItemAsFailed(int id, String error) {
    return (update(localOfflineQueue)..where((tbl) => tbl.id.equals(id)))
      .write(LocalOfflineQueueCompanion(
        status: const drift.Value('failed'),
        errorMessage: drift.Value(error),
      ));
  }

  Future<void> updateSyncMetadata(String userId, String entity, DateTime lastSync) {
    return into(localSyncMetadata).insert(
      LocalSyncMetadataCompanion(
        userId: drift.Value(userId),
        entity: drift.Value(entity),
        lastSync: drift.Value(lastSync),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<DateTime?> getLastSyncTime(String userId, String entity) {
    return (select(localSyncMetadata)
      ..where((tbl) => tbl.userId.equals(userId) & tbl.entity.equals(entity)))
      .getSingleOrNull()
      .then((value) => value?.lastSync);
  }

  Future<void> deleteQueueItemsExcept(int keepCount) async {
    await customStatement(
      'DELETE FROM local_offline_queue WHERE id NOT IN '
      '(SELECT id FROM local_offline_queue ORDER BY created_at DESC LIMIT $keepCount) '
      "AND status = 'pending';"
    );
  }

  Future<void> cleanupOldData() {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return (delete(localChatMessages)
      ..where((tbl) => tbl.timestamp.isSmallerThan(thirtyDaysAgo) & tbl.isSynced.equals(true)))
      .go();
  }
  
  Future<void> vacuum() async {
    await customStatement('VACUUM;');
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    if (kIsWeb) {
      throw UnsupportedError('[DB] SQLite is not supported on web. Use a web-compatible storage solution.');
    }
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(path.join(dbFolder.path, 'askroa_db.sqlite'));

    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }

    final cachebase = await getTemporaryDirectory();
    sqlite3.tempDirectory = cachebase.path;

    final db = NativeDatabase.createInBackground(file, setup: (database) {
      database.execute('PRAGMA journal_mode=WAL;');
      database.execute('PRAGMA synchronous=NORMAL;');
      database.execute('PRAGMA cache_size=-20000;');
      database.execute('PRAGMA foreign_keys=ON;');
      database.execute('PRAGMA auto_vacuum=INCREMENTAL;');
      database.execute('PRAGMA temp_store=MEMORY;');
      database.execute('PRAGMA mmap_size=134217728;');
      // Multi-isolate concurrent access safety:
      // busy_timeout prevents SQLITE_BUSY when background isolate holds write lock
      database.execute('PRAGMA busy_timeout=5000;');
      // wal_autocheckpoint keeps WAL file from growing unbounded across isolates
      database.execute('PRAGMA wal_autocheckpoint=100;');
    });
    return db;
  });
}

// ===========================================
// FIXED: DATABASE SERVICE WITH PROPER ISOLATE MANAGEMENT
// ===========================================
class DatabaseService {
  final ProductionLogger _logger;
  final PerformanceOptimizer _performance;
  late AppDatabase _database;
  bool _isInitialized = false;
  bool _isDisposed = false;

  DatabaseService({required ProductionLogger logger, required PerformanceOptimizer performance})
      : _logger = logger, _performance = performance;

  Timer? _walCheckpointTimer;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      await _performance.measureOperation('db_initialize', () async {
        _database = AppDatabase();
        _isInitialized = true;
        _logger.i('Database initialized (NativeDatabase.createInBackground)');
        return null;
      });
      _walCheckpointTimer = Timer.periodic(const Duration(hours: 1), (_) async {
        if (!_isDisposed) await walCheckpoint();
      });
    } catch (e, stack) {
      _logger.e('Failed to initialize database', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<void> addToQueue({
    required String userId,
    required String operation,
    required String entity,
    required String entityId,
    required Map<String, dynamic> data,
    String? idempotencyKey,
  }) async {
    await _database.addToQueue(LocalOfflineQueueCompanion(
      userId: drift.Value(userId),
      operation: drift.Value(operation),
      entity: drift.Value(entity),
      entityId: drift.Value(entityId),
      data: drift.Value(jsonEncode(data)),
      idempotencyKey: drift.Value(idempotencyKey),
      createdAt: drift.Value(DateTime.now()),
      retryCount: const drift.Value(0),
    ));
    
    _logger.d('Added item to queue: $entity/$entityId');
  }

  Future<void> saveChatMessage(LocalChatMessage message) async {
    await _database.insertChatMessage(LocalChatMessagesCompanion(
      serverId: drift.Value(message.serverId),
      sessionId: drift.Value(message.sessionId),
      text: drift.Value(message.text),
      sender: drift.Value(message.sender),
      timestamp: drift.Value(message.timestamp),
      isLiked: drift.Value(message.isLiked),
      isDisliked: drift.Value(message.isDisliked),
      isReported: drift.Value(message.isReported),
      parentMessageId: drift.Value(message.parentMessageId),
      attachments: drift.Value(message.attachments != null ? jsonEncode(message.attachments) : null),
      metadataJson: drift.Value(message.metadataJson),
      isSynced: drift.Value(message.isSynced),
      isFailed: drift.Value(message.isFailed),
      errorMessage: drift.Value(message.errorMessage),
      isStreaming: drift.Value(message.isStreaming),
      streamingText: drift.Value(message.streamingText),
    ));
  }

  Future<List<LocalChatMessage>> getChatMessages(String sessionId, {int limit = 50, int offset = 0}) async {
    return await _database.getChatMessages(sessionId, limit: limit, offset: offset);
  }

  Future<int> insertChatMessage(LocalChatMessagesCompanion companion) async {
    return await _database.insertChatMessage(companion);
  }

  Future<void> insertMessageAndSession(
    LocalChatMessagesCompanion message,
    LocalChatSessionsCompanion session,
  ) async {
    await _database.insertMessageAndSession(message, session);
  }

  Future<void> saveChatSession(LocalChatSession session) async {
    await _database.insertChatSession(LocalChatSessionsCompanion(
      serverId: drift.Value(session.serverId),
      title: drift.Value(session.title),
      createdAt: drift.Value(session.createdAt),
      updatedAt: drift.Value(session.updatedAt),
      isPinned: drift.Value(session.isPinned),
      category: drift.Value(session.category),
      sessionDataJson: drift.Value(session.sessionDataJson),
      isSynced: drift.Value(session.isSynced),
    ));
  }

  Future<List<LocalChatSession>> getChatSessions({int limit = 50, int offset = 0}) async {
    return await _database.getChatSessions(limit: limit, offset: offset);
  }

  Future<void> saveImageHistory(LocalImageHistory image) async {
    await _database.insertImageHistory(LocalImageHistoriesCompanion(
      serverId: drift.Value(image.serverId),
      url: drift.Value(image.url),
      thumbnailUrl: drift.Value(image.thumbnailUrl),
      videoUrl: drift.Value(image.videoUrl),
      prompt: drift.Value(image.prompt),
      type: drift.Value(image.type),
      createdAt: drift.Value(image.createdAt),
      sessionId: drift.Value(image.sessionId),
      metadataJson: drift.Value(image.metadataJson),
      isDownloaded: drift.Value(image.isDownloaded),
      localPath: drift.Value(image.localPath),
    ));
  }

  Future<List<LocalImageHistory>> getImageHistory({int limit = 100, int offset = 0}) async {
    return await _database.getImageHistory(limit: limit, offset: offset);
  }

  Future<void> saveUser(LocalUser user) async {
    await _database.insertUser(LocalUsersCompanion(
      serverId: drift.Value(user.serverId),
      name: drift.Value(user.name),
      email: drift.Value(user.email),
      phone: drift.Value(user.phone),
      profileImage: drift.Value(user.profileImage),
      plan: drift.Value(user.plan),
      createdAt: drift.Value(user.createdAt),
      subscriptionExpiry: drift.Value(user.subscriptionExpiry),
      dailyRequests: drift.Value(user.dailyRequests),
      maxRequests: drift.Value(user.maxRequests),
      preferencesJson: drift.Value(user.preferencesJson),
      isVoiceTrained: drift.Value(user.isVoiceTrained),
      lastSynced: drift.Value(user.lastSynced),
    ));
  }

  Future<LocalUser?> getUser(String userId) async {
    return await _database.getUser(userId);
  }

  Future<void> updateSyncMetadata(String userId, String entity) async {
    await _database.updateSyncMetadata(userId, entity, DateTime.now());
  }

  Future<DateTime?> getLastSyncTime(String userId, String entity) async {
    return await _database.getLastSyncTime(userId, entity);
  }

  Future<void> cleanupOldData() async {
    await _database.cleanupOldData();
    _logger.d('Cleaned up old data');
  }
  
  Future<void> vacuum() async {
    await _database.vacuum();
    _logger.d('Database vacuum completed');
  }

  Future<void> incrementalVacuum({int pages = 100}) async {
    try {
      await _database.customStatement('PRAGMA incremental_vacuum($pages);');
      _logger.d('[DB] Incremental vacuum: $pages pages freed');
    } catch (e, stack) {
      _logger.d('[DB] Incremental vacuum failed', error: e, stackTrace: stack);
    }
  }

  Future<void> analyze() async {
    try {
      await _database.customStatement('PRAGMA analysis_limit=400; ANALYZE;');
      _logger.d('[DB] ANALYZE complete');
    } catch (e, stack) {
      _logger.d('[DB] ANALYZE failed', error: e, stackTrace: stack);
    }
  }

  Future<void> walCheckpoint() async {
    try {
      await _database.customStatement('PRAGMA wal_checkpoint(TRUNCATE);');
      _logger.d('[DB] WAL checkpoint complete');
    } catch (e) {
      _logger.w('[DB] WAL checkpoint failed', error: e);
    }
  }

  Future<int> getPendingQueueCount() async {
    try {
      final items = await _database.getPendingQueueItems();
      return items.length;
    } catch (_) { return 0; }
  }

  Future<void> dropOldestQueueItems({required int keepCount}) async {
    try {
      await _database.customStatement(
        "DELETE FROM local_offline_queue WHERE id NOT IN "
        "(SELECT id FROM local_offline_queue ORDER BY created_at DESC LIMIT $keepCount) "
        "AND status = 'pending';"
      );
      _logger.d('[DB] Dropped queue overflow items, kept $keepCount');
    } catch (e) {
      _logger.w('[DB] dropOldestQueueItems failed', error: e);
    }
  }

  Future<File> createBackup() async {
    try {
      final dbPath = await _getDatabasePath();
      final backupDir = await getTemporaryDirectory();
      final backupPath = '${backupDir.path}/askroa_backup_${DateTime.now().millisecondsSinceEpoch}.db';
      
      final dbFile = File(dbPath);
      if (await dbFile.exists()) {
        await dbFile.copy(backupPath);
        
        final encryption = ProductionEncryptionService(logger: _logger);
        await encryption.initialize();
        final bytes = await File(backupPath).readAsBytes();
        final encrypted = encryption.encrypt(base64Encode(bytes));
        
        final encryptedBackupPath = '$backupPath.enc';
        await File(encryptedBackupPath).writeAsString(encrypted);
        
        await File(backupPath).delete();
        
        _logger.i('Database backup created: $encryptedBackupPath');
        return File(encryptedBackupPath);
      }
      throw Exception('Database file not found');
    } catch (e, stack) {
      _logger.e('Failed to create backup', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<void> restoreFromBackup(File backupFile) async {
    final dbPath = await _getDatabasePath();
    String? tempPath;
    try {
      final encryption = ProductionEncryptionService(logger: _logger);
      await encryption.initialize();
      final encrypted     = await backupFile.readAsString();
      final decryptedB64  = await encryption.decrypt(encrypted);
      if (decryptedB64 == '[DECRYPTION_FAILED]') throw Exception('Backup decryption failed');
      final bytes = base64Decode(decryptedB64);
      final origFile = File(dbPath);
      if (await origFile.exists()) {
        tempPath = '$dbPath.pre_restore';
        await origFile.copy(tempPath);
      }
      await _database.close();
      try {
        await File(dbPath).writeAsBytes(bytes);
      } catch (writeErr) {
        _logger.e('[DB] Write failed, rolling back', error: writeErr);
        if (tempPath != null && await File(tempPath).exists()) {
          await File(tempPath).copy(dbPath);
        }
        rethrow;
      }
      if (tempPath != null) { try { await File(tempPath).delete(); } catch (_) {} }
      _database = AppDatabase();
      _isInitialized = true;
      _logger.i('[DB] Restored from backup successfully');
    } catch (e, stack) {
      _logger.e('Failed to restore backup', error: e, stackTrace: stack);
      try { _database = AppDatabase(); _isInitialized = true; } catch (_) {}
      rethrow;
    }
  }

  Future<String> _getDatabasePath() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    return path.join(dbFolder.path, 'askroa_db.sqlite');
  }

  Future<Map<String, dynamic>> exportUserData(String userId) async {
    try {
      final user = await _database.getUser(userId);
      final allSessions = await _database.getChatSessions();
      final userSessionIds = allSessions.map((s) => s.serverId).toSet();
      final allMessages = await (_database.select(_database.localChatMessages)).get();
      final userMessages = allMessages
          .where((m) => userSessionIds.contains(m.sessionId))
          .toList();
      final images = await _database.getImageHistory();

      return {
        'user': user?.toJson(),
        'messages': userMessages.map((m) => m.toJson()).toList(),
        'sessions': allSessions.map((s) => s.toJson()).toList(),
        'images': images.map((i) => i.toJson()).toList(),
        'exported_at': DateTime.now().toIso8601String(),
      };
    } catch (e, stack) {
      _logger.e('Failed to export user data', error: e, stackTrace: stack);
      rethrow;
    }
  }

  AppDatabase get database => _database;
  bool get isInitialized => _isInitialized;

  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    _walCheckpointTimer?.cancel();
    _walCheckpointTimer = null;
    try { await _database.close(); } catch (_) {}
    _logger.i('Database disposed');
  }
}

// ===========================================
// REPOSITORY IMPLEMENTATIONS
// ===========================================
abstract class UserRepository {
  Future<User?> getUser(String id);
  Future<void> saveUser(User user);
  Future<void> deleteUser(String id);
  Stream<User?> watchUser(String id);
}

class DatabaseUserRepository implements UserRepository {
  final DatabaseService _database;
  DatabaseUserRepository(this._database);
  
  @override
  Future<User?> getUser(String id) async {
    final localUser = await _database.getUser(id);
    if (localUser == null) return null;
    
    return User(
      id: localUser.serverId,
      name: localUser.name,
      email: localUser.email,
      phone: localUser.phone,
      profileImage: localUser.profileImage,
      plan: localUser.plan,
      createdAt: localUser.createdAt,
      subscriptionExpiry: localUser.subscriptionExpiry,
      dailyRequests: localUser.dailyRequests,
      maxRequests: localUser.maxRequests,
      preferences: localUser.preferencesJson != null 
          ? jsonDecode(localUser.preferencesJson!) as Map<String, dynamic>
          : {},
      isVoiceTrained: localUser.isVoiceTrained,
    );
  }
  
  @override
  Future<void> saveUser(User user) async {
    final localUser = LocalUser(
      serverId: user.id,
      name: user.name,
      email: user.email,
      phone: user.phone,
      profileImage: user.profileImage,
      plan: user.plan,
      createdAt: user.createdAt,
      subscriptionExpiry: user.subscriptionExpiry,
      dailyRequests: user.dailyRequests,
      maxRequests: user.maxRequests,
      preferencesJson: jsonEncode(user.preferences),
      isVoiceTrained: user.isVoiceTrained,
      lastSynced: DateTime.now(),
    );
    await _database.saveUser(localUser);
  }
  
  @override
  Future<void> deleteUser(String id) async {}
  
  @override
  Stream<User?> watchUser(String id) => Stream.empty();
}

abstract class AuthRepository {
  Future<User> loginWithEmail(String email, String password);
  Future<User> loginWithGoogle();
  Future<User> loginWithApple();
  Future<User> register(String name, String email, String password, {String? phone});
  Future<void> logout(String userId);
  Future<User?> getCurrentUser();
  Future<String?> refreshToken();
}

class ApiAuthRepository implements AuthRepository {
  final ProductionApiService _apiService;
  final GlobalUserHandler _userHandler;
  final SecurityArchitecture _security;
  
  ApiAuthRepository(this._apiService, this._userHandler, this._security);
  
  @override
  Future<User> loginWithEmail(String email, String password) async {
    final response = await _apiService.loginWithEmail(email: email, password: password);
    final user = User.fromJson(response['user'] as Map<String, dynamic>);
    await _userHandler.setUser(user);
    return user;
  }
  
  @override
  Future<User> loginWithGoogle() async {
    final response = await _apiService.loginWithGoogle();
    final user = User.fromJson(response['user'] as Map<String, dynamic>);
    await _userHandler.setUser(user);
    return user;
  }
  
  @override
  Future<User> loginWithApple() async {
    final response = await _apiService.loginWithApple();
    final user = User.fromJson(response['user'] as Map<String, dynamic>);
    await _userHandler.setUser(user);
    return user;
  }
  
  @override
  Future<User> register(String name, String email, String password, {String? phone}) async {
    final response = await _apiService.registerUser(
      name: name,
      email: email,
      password: password,
      phone: phone,
    );
    final user = User.fromJson(response['user'] as Map<String, dynamic>);
    await _userHandler.setUser(user);
    return user;
  }
  
  @override
  Future<void> logout(String userId) async {
    await _apiService.logout(userId);
    await _userHandler.clearUser();
    await _security.clearTokens();
  }
  
  @override
  Future<User?> getCurrentUser() async {
    return _userHandler.currentUser;
  }
  
  @override
  Future<String?> refreshToken() async {
    return await _security.refreshAccessToken();
  }
}

// ===========================================
// FIXED: GLOBAL API CLIENT WITH PROPER ERROR HANDLING
// ===========================================
class GlobalApiClient {
  final ProductionLogger _logger;
  final ProductionEncryptionService _encryption;
  final ProductionConnectivityService _connectivity;
  final RateLimitingService _rateLimiter;
  final PerformanceOptimizer _performance;
  final SecurityArchitecture _security;
  final CertificatePinningService _certificatePinning;
  final ProductionCacheManager _cacheManager;
  late Dio _dio;
  
  final Map<String, CircuitBreaker> _circuitBreakers = {};
  static const int _defaultRetryCount = 3;
  static const Duration _defaultTimeout    = Duration(seconds: 30);
  static const Duration _aiEndpointTimeout = Duration(seconds: 120);
  static const Set<String> _aiEndpoints = {
    '/chat/messages', '/chat/regenerate', '/chat/thinking',
    '/voice/process', '/images/', '/ai/',
  };

  Duration _timeoutForEndpoint(String endpoint) {
    for (final ai in _aiEndpoints) {
      if (endpoint.contains(ai)) return _aiEndpointTimeout;
    }
    return _defaultTimeout;
  }
  static const int _circuitBreakerFailureThreshold = 5;
  static const Duration _circuitBreakerTimeout = Duration(minutes: 1);
  
  bool _isRefreshing = false;
  final List<Completer<bool>> _refreshCompleters = [];
  static const int _maxTokenRefreshRetries = 3;
  int _tokenRefreshRetries = 0;
  bool _isInitialized = false;
  bool _isDisposed = false;

  GlobalApiClient({
    required ProductionLogger logger,
    required ProductionEncryptionService encryption,
    required ProductionConnectivityService connectivity,
    required RateLimitingService rateLimiter,
    required PerformanceOptimizer performance,
    required SecurityArchitecture security,
    required CertificatePinningService certificatePinning,
    required ProductionCacheManager cacheManager,
  }) : _logger = logger,
       _encryption = encryption,
       _connectivity = connectivity,
       _rateLimiter = rateLimiter,
       _performance = performance,
       _security = security,
       _certificatePinning = certificatePinning,
       _cacheManager = cacheManager;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    await _performance.measureOperation('api_client_init', () async {      
      final envConfig = EnvironmentConfig();
      _dio = Dio(BaseOptions(
        baseUrl: envConfig.backendBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-App-Version': appVersion,
          'X-API-Version': apiVersion,
          'X-Platform': kIsWeb ? 'web' : Platform.operatingSystem,
        },
      ));
      
      if (!kIsWeb) {
        await _certificatePinning.configureDio(_dio);
      }
      
      if (_cacheManager.cacheInterceptor != null) {
        _dio.interceptors.add(_cacheManager.cacheInterceptor!);
      }
      
      _dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            if (EnvironmentConfig().backendBaseUrl.isEmpty) {
              return handler.reject(DioException(
                requestOptions: options,
                error: ApiException('Our team is working on it. Please try later. 😓', 503, 'MAINTENANCE'),
                type: DioExceptionType.cancel,
              ));
            }
            final circuitBreaker = _getCircuitBreaker(options.path);
            if (!circuitBreaker.canExecute) {
              return handler.reject(DioException(
                requestOptions: options,
                error: ApiException('Service temporarily unavailable', 503, 'CIRCUIT_OPEN'),
              ));
            }
            
            final token = await _getAuthToken();
            if (token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
            
            options.headers['X-Request-ID'] = const Uuid().v4();
            options.headers['X-Timestamp'] = DateTime.now().millisecondsSinceEpoch.toString();
            options.headers.addAll(_security.getSecureHeaders());
            
            handler.next(options);
          } catch (e) {
            handler.reject(DioException(requestOptions: options, error: e));
          }
        },
        onError: (error, handler) async {
          if (_isDisposed) {
            return handler.next(error);
          }
          
          final circuitBreaker = _getCircuitBreaker(error.requestOptions.path);
          
          if (error.response?.statusCode == 401) {
            circuitBreaker.recordSuccess();
            try {
              final newToken = await _refreshAuthTokenWithLock();
              if (newToken != null) {
                error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
                final response = await _dio.fetch(error.requestOptions);
                handler.resolve(response);
                return;
              } else {
                circuitBreaker.recordFailure();
                await _logoutOnAuthFailure();
                handler.reject(DioException(
                  requestOptions: error.requestOptions,
                  error: ApiException('Session expired. Please login again.', 401, 'SESSION_EXPIRED'),
                ));
                return;
              }
            } catch (e) {
              circuitBreaker.recordFailure();
              handler.reject(DioException(
                requestOptions: error.requestOptions,
                error: ApiException('Authentication failed. Please login again.', 401, 'AUTH_FAILED'),
              ));
              return;
            }
          } else if (error.response?.statusCode == 429) {
            circuitBreaker.recordSuccess();
            handler.reject(DioException(
              requestOptions: error.requestOptions,
              error: ApiException('Rate limit exceeded. Please try again later.', 429, 'RATE_LIMIT'),
            ));
            return;
          } else if (error.response?.statusCode == 500 || error.response?.statusCode == 502 || error.response?.statusCode == 503) {
            circuitBreaker.recordFailure();
            if (_shouldRetry(error)) {
              final retryCount = error.requestOptions.extra['retryCount'] ?? 0;
              if (retryCount < _defaultRetryCount) {
                error.requestOptions.extra['retryCount'] = retryCount + 1;
                final delay = Duration(seconds: pow(2, retryCount).toInt());
                await Future.delayed(delay);
                final response = await _dio.fetch(error.requestOptions);
                handler.resolve(response);
                return;
              }
            }
          } else {
            circuitBreaker.recordSuccess();
          }
          
          if (error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.receiveTimeout ||
              error.type == DioExceptionType.sendTimeout) {
            if (_shouldRetry(error)) {
              final retryCount = error.requestOptions.extra['retryCount'] ?? 0;
              if (retryCount < _defaultRetryCount) {
                error.requestOptions.extra['retryCount'] = retryCount + 1;
                final delay = Duration(seconds: pow(2, retryCount).toInt());
                await Future.delayed(delay);
                final response = await _dio.fetch(error.requestOptions);
                handler.resolve(response);
                return;
              }
            }
            handler.reject(DioException(
              requestOptions: error.requestOptions,
              error: ApiException('Request timeout. Please check your connection.', 408, 'TIMEOUT'),
            ));
            return;
          }
          
          handler.next(error);
        },
      ));
      
      _isInitialized = true;
      _logger.i('Global API Client initialized with certificate pinning');
      return null;
    });
  }
  
  CircuitBreaker _getCircuitBreaker(String endpoint) {
    if (!_circuitBreakers.containsKey(endpoint)) {
      _circuitBreakers[endpoint] = CircuitBreaker(
        failureThreshold: _circuitBreakerFailureThreshold,
        timeout: _circuitBreakerTimeout,
      );
    }
    return _circuitBreakers[endpoint]!;
  }
  
  bool _shouldRetry(DioException error) {
    return error.type == DioExceptionType.connectionTimeout ||
           error.type == DioExceptionType.receiveTimeout ||
           error.type == DioExceptionType.sendTimeout ||
           error.response?.statusCode == 500 ||
           error.response?.statusCode == 502 ||
           error.response?.statusCode == 503;
  }
  
  Future<ApiResponse<Map<String, dynamic>>> request(ApiRequest request) async {
    return await _performance.measureOperation('api_${request.endpoint.replaceAll('/', '_')}', () async {
      if (!_connectivity.isConnected.value) {
        throw ApiException('No internet connection', 0, 'NETWORK_ERROR');
      }

      if (request.userId != null) {
        final userAllowed = await _rateLimiter.checkUserRateLimit(request.userId!);
        if (!userAllowed) {
          throw ApiException('Rate limit exceeded', 429, 'RATE_LIMIT');
        }
      }

      final endpointAllowed = await _rateLimiter.checkEndpointRateLimit(request.endpoint);
      if (!endpointAllowed) {
        throw ApiException('Service busy, please try again', 429, 'SERVICE_BUSY');
      }
      
      if (request.userId != null && request.plan != null && 
          (request.endpoint.contains('/chat/') || request.endpoint.contains('/images/'))) {
        final quotaAllowed = await _rateLimiter.checkDailyQuota(request.userId!, request.plan!, request.endpoint);
        if (!quotaAllowed) {
          throw ApiException('Daily limit reached. Upgrade to Pro for more.', 429, 'QUOTA_EXCEEDED');
        }
      }

      try {
        final stopwatch = Stopwatch()..start();
        final _perfMonitor = PerformanceMonitoringService(logger: _logger);
        final trace = _perfMonitor.startTrace('api_${request.endpoint.replaceAll('/', '_')}');
        
        final effectiveHeaders = request.headers ?? {};
        if (request.idempotencyKey != null) {
          effectiveHeaders['Idempotency-Key'] = request.idempotencyKey!;
        }
        
        final timeout = request.timeout ?? _timeoutForEndpoint(request.endpoint);
        final options = Options(
          headers: effectiveHeaders,
          sendTimeout: timeout,
          receiveTimeout: timeout,
        );
        
        Response response;
        switch (request.method) {
          case HttpMethod.post:
            response = await _dio.post(request.endpoint, data: request.body, options: options);
            break;
          case HttpMethod.get:
            response = await _dio.get(request.endpoint, options: options);
            break;
          case HttpMethod.put:
            response = await _dio.put(request.endpoint, data: request.body, options: options);
            break;
          case HttpMethod.delete:
            response = await _dio.delete(request.endpoint, options: options);
            break;
          case HttpMethod.patch:
            response = await _dio.patch(request.endpoint, data: request.body, options: options);
            break;
        }

        stopwatch.stop();
        trace.putAttribute('duration_ms', stopwatch.elapsedMilliseconds.toString());
        trace.putAttribute('status_code', response.statusCode?.toString() ?? '0');
        trace.stop();
        
        _logger.logApiCall(request.endpoint, response.statusCode ?? 0, stopwatch.elapsedMilliseconds, userId: request.userId);

        final responseData = response.data as Map<String, dynamic>;

        if (response.statusCode! >= 200 && response.statusCode! < 300) {
          if (responseData['encrypted_data'] != null) {
            final decrypted = await _encryption.decryptData(responseData['encrypted_data'] as String);
            return ApiResponse(
              data: decrypted,
              statusCode: response.statusCode!,
              headers: response.headers.map.map,
            );
          }
          return ApiResponse(
            data: responseData,
            statusCode: response.statusCode!,
            headers: response.headers.map.map,
          );
        } else {
          throw ApiException(
            responseData['error']?['message'] as String? ?? 'Request failed',
            response.statusCode ?? 500,
            responseData['error']?['code'] as String?,
          );
        }
      } on DioException catch (e) {
        if (e.error is ApiException) rethrow;
        final String userMessage;
        final String errorCode;
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
            userMessage = 'Network is slow. Please check your connection and try again.';
            errorCode   = 'CONNECTION_TIMEOUT';
          case DioExceptionType.receiveTimeout:
            userMessage = 'Server took too long to respond. Please try again.';
            errorCode   = 'RECEIVE_TIMEOUT';
          case DioExceptionType.sendTimeout:
            userMessage = 'Request timed out. Please try again.';
            errorCode   = 'SEND_TIMEOUT';
          case DioExceptionType.connectionError:
            userMessage = 'No internet connection. Please check your network.';
            errorCode   = 'NO_INTERNET';
          case DioExceptionType.badResponse:
            final status = e.response?.statusCode ?? 500;
            if (status == 401) {
              userMessage = 'Session expired. Please log in again.';
              errorCode   = 'SESSION_EXPIRED';
            } else if (status == 403) {
              userMessage = 'Access denied. Your plan may not include this feature.';
              errorCode   = 'ACCESS_DENIED';
            } else if (status == 404) {
              userMessage = 'Service not found. Please update the app.';
              errorCode   = 'NOT_FOUND';
            } else if (status == 429) {
              userMessage = 'Too many requests. Please wait a moment and try again.';
              errorCode   = 'RATE_LIMITED';
            } else if (status >= 500) {
              userMessage = 'Server error. Our team is working on it.';
              errorCode   = 'SERVER_ERROR';
            } else {
              userMessage = 'Something went wrong. Please try again.';
              errorCode   = 'BAD_RESPONSE';
            }
          case DioExceptionType.cancel:
            userMessage = 'Request cancelled.';
            errorCode   = 'CANCELLED';
          case DioExceptionType.badCertificate:
            userMessage = 'Security error: invalid certificate. Please update the app.';
            errorCode   = 'BAD_CERTIFICATE';
          case DioExceptionType.unknown:
          default:
            userMessage = 'Something went wrong. Please try again.';
            errorCode   = 'UNKNOWN';
        }
        throw ApiException(userMessage, e.response?.statusCode ?? 500, errorCode);
      }
    });
  }

  Future<String> _getAuthToken() async {
    try {
      final token = await _security.getAccessToken();
      if (token != null) {
        return token;
      }

      final secureStorage = AppSecureStorage.instance;
      final encryptedToken = await secureStorage.read(key: 'askroa_access_token');

      if (encryptedToken == null) {
        final refreshed = await _refreshAuthTokenWithLock();
        if (refreshed == null) {
          throw ApiException('User not authenticated', 401, 'UNAUTHORIZED');
        }

        final newEncryptedToken = await secureStorage.read(key: 'askroa_access_token');
        if (newEncryptedToken == null) {
          throw ApiException('Authentication failed', 401, 'AUTH_ERROR');
        }
        return await _encryption.decrypt(newEncryptedToken);
      }

      final decryptedToken = await _encryption.decrypt(encryptedToken);

      if (decryptedToken == '[DECRYPTION_FAILED]') {
        throw ApiException('Authentication failed', 401, 'AUTH_ERROR');
      }

      final tokenData = _parseJwt(decryptedToken);
      final expiry = tokenData['exp'] as int?;

      if (expiry != null) {
        final expiryTime = DateTime.fromMillisecondsSinceEpoch(expiry * 1000);
        final now = DateTime.now();
        if (expiryTime.isBefore(now.add(const Duration(minutes: 5)))) {
          _logger.d('[Auth] Token expiring soon, attempting silent refresh');
          final refreshed = await _refreshAuthTokenWithLock();
          if (refreshed != null) {
            _logger.i('[Auth] Silent token refresh successful');
            return refreshed;
          }
          final newEncryptedToken = await secureStorage.read(key: 'askroa_access_token');
          if (newEncryptedToken != null) {
            final newToken = await _encryption.decrypt(newEncryptedToken);
            if (newToken != '[DECRYPTION_FAILED]') return newToken;
          }
          _logger.w('[Auth] Token refresh failed, forcing logout');
          await _logoutOnAuthFailure();
          throw ApiException('Session expired. Please log in again.', 401, 'SESSION_EXPIRED');
        }
      }

      return decryptedToken;
    } catch (e) {
      _logger.d('Get auth token failed', error: e);
      throw ApiException('Authentication failed', 401, 'AUTH_ERROR');
    }
  }
  
  Future<String?> _refreshAuthTokenWithLock() async {
    if (_isRefreshing) {
      final completer = Completer<bool>();
      _refreshCompleters.add(completer);
      final success = await completer.future;
      if (success) {
        final secureStorage = AppSecureStorage.instance;
        final encryptedToken = await secureStorage.read(key: 'askroa_access_token');
        if (encryptedToken != null) {
          return await _encryption.decrypt(encryptedToken);
        }
      }
      return null;
    }

    _isRefreshing = true;
    _tokenRefreshRetries = 0;
    String? token;

    try {
      while (_tokenRefreshRetries < _maxTokenRefreshRetries) {
        token = await _refreshAuthToken();
        if (token != null) break;
        _tokenRefreshRetries++;
        await Future.delayed(Duration(seconds: pow(2, _tokenRefreshRetries).toInt()));
      }
      return token;
    } catch (e) {
      token = null;
      return null;
    } finally {
      for (final completer in _refreshCompleters) {
        if (!completer.isCompleted) completer.complete(token != null);
      }
      _isRefreshing = false;
      _refreshCompleters.clear();
    }
  }

  Future<String?> _refreshAuthToken() async {
    try {
      final token = await _security.refreshAccessToken();
      if (token != null) {
        return token;
      }

      final secureStorage = AppSecureStorage.instance;
      final encryptedRefreshToken = await secureStorage.read(key: 'askroa_refresh_token');

      if (encryptedRefreshToken == null) {
        return null;
      }

      final refreshToken = await _encryption.decrypt(encryptedRefreshToken);

      if (refreshToken == '[DECRYPTION_FAILED]') {
        return null;
      }

      final response = await _dio.post(
        '/auth/refresh',
        data: {
          'refresh_token': refreshToken,
          'timestamp': DateTime.now().toUtc().toIso8601String(),
        },
        options: Options(headers: {
          'Idempotency-Key': 'refresh_$refreshToken',
        }),
      );

      if (response.statusCode == 200 && response.data['access_token'] != null) {
        await _storeAuthData(
          accessToken: response.data['access_token'] as String,
          refreshToken: response.data['refresh_token'] as String,
          userData: response.data['user'] as Map<String, dynamic>,
          expiresIn: response.data['expires_in'] as int,
        );
        return response.data['access_token'] as String;
      }

      return null;
    } catch (e) {
      _logger.d('Refresh auth token failed', error: e);
      return null;
    }
  }

  Future<void> _storeAuthData({
    required String accessToken,
    required String refreshToken,
    required Map<String, dynamic> userData,
    required int expiresIn,
  }) async {
  final secureStorage = AppSecureStorage.instance;
    try {
      await secureStorage.write(
        key: 'askroa_access_token',
        value: _encryption.encrypt(accessToken),
      );
      await secureStorage.write(
        key: 'askroa_refresh_token',
        value: _encryption.encrypt(refreshToken),
      );
      await secureStorage.write(
        key: 'askroa_user_data',
        value: _encryption.encrypt(jsonEncode(userData)),
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'askroa_last_login',
        DateTime.now().toUtc().toIso8601String(),
      );

      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        try {
          await FirebaseCrashlytics.instance.setUserIdentifier(userData['id'] as String? ?? 'unknown');
          await FirebaseCrashlytics.instance.setCustomKey('plan', userData['plan'] as String? ?? 'free');
        } catch (e) {
          _logger.d('Crashlytics set user failed', error: e);
        }
      }

      final dailyQuota = userData['daily_quota'] as int? ?? 5;
      await _rateLimiter.syncQuotaWithServer(userData['id'] as String, dailyQuota);

      _logger.d('Auth data stored securely for user: ${userData['id']}');
    } catch (e, stack) {
      _logger.e('Store auth data failed', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<void> _logoutOnAuthFailure() async {
  final secureStorage = AppSecureStorage.instance;
    try {
      final encryptedUserData = await secureStorage.read(key: 'askroa_user_data');

      if (encryptedUserData != null) {
        final userJsonStr = await _encryption.decrypt(encryptedUserData);
        if (userJsonStr != '[DECRYPTION_FAILED]') {
          final userJson = jsonDecode(userJsonStr) as Map<String, dynamic>;
          final userId = userJson['id'] as String;

          try {
            await _dio.post('/auth/logout', data: {
              'user_id': userId,
              'timestamp': DateTime.now().toUtc().toIso8601String(),
            });
          } catch (e) {
            _logger.d('Logout on auth failure error', error: e);
          }
        }
      }

      await secureStorage.delete(key: 'askroa_access_token');
      await secureStorage.delete(key: 'askroa_refresh_token');
      await secureStorage.delete(key: 'askroa_user_data');

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('askroa_last_login');

      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        try {
          await FirebaseCrashlytics.instance.setUserIdentifier(null);
        } catch (e) {
          _logger.d('Crashlytics clear user failed', error: e);
        }
      }

      _logger.i('Logged out due to auth failure');
    } catch (e, stack) {
      _logger.e('Logout on auth failure failed', error: e, stackTrace: stack);
    }
  }

  Map<String, dynamic> _parseJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return {};
      }

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decodedBytes = base64Url.decode(normalized);
      final decoded = utf8.decode(decodedBytes);
      final result = jsonDecode(decoded);
      if (result is! Map<String, dynamic>) return {};
      return result;
    } catch (e) {
      return {};
    }
  }

  void dispose() {
    _isDisposed = true;
    _dio.close();
    _cacheManager.clearAllCache();
  }

  Dio get dio => _dio;
}

// ===========================================
// PERFORMANCE MONITORING SERVICE
// ===========================================
class PerformanceMonitoringService {
  final ProductionLogger _logger;
  final Map<String, Trace> _activeTraces = {};

  PerformanceMonitoringService({required ProductionLogger logger}) : _logger = logger;

  Future<void> initialize() async {}

  Trace startTrace(String name) {
    try {
      if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
        return DummyTrace();
      }
      final trace = FirebasePerformance.instance.newTrace(name);
      trace.start();
      _activeTraces[name] = trace;
      return trace;
    } catch (e) {
      _logger.d('Failed to start trace: $name', error: e);
      return DummyTrace();
    }
  }

  void stopTrace(String name) {
    try {
      final trace = _activeTraces[name];
      if (trace != null) {
        trace.stop();
        _activeTraces.remove(name);
      }
    } catch (e) {
      _logger.d('Failed to stop trace: $name', error: e);
    }
  }

  HttpMetric startHttpMetric(String url, HttpMethod method) {
    try {
      if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
        return DummyHttpMetric();
      }
      final metric = FirebasePerformance.instance.newHttpMetric(url, method);
      metric.start();
      return metric;
    } catch (e) {
      _logger.d('Failed to start HTTP metric', error: e);
      return DummyHttpMetric();
    }
  }

  void stopHttpMetric(HttpMetric metric, int statusCode, int responseSize) {
    try {
      metric.setHttpResponseCode(statusCode);
      metric.setResponsePayloadSize(responseSize);
      metric.stop();
    } catch (e) {
      _logger.d('Failed to stop HTTP metric', error: e);
    }
  }

  Future<void> recordScreenRender(String screenName, Duration duration) async {
    try {
      if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return;
      final trace = FirebasePerformance.instance.newTrace('${screenName}_render');
      trace.start();
      trace.putAttribute('duration_ms', duration.inMilliseconds.toString());
      trace.stop();
    } catch (e) {
      _logger.d('Failed to record screen render', error: e);
    }
  }

  Future<void> recordApiCall(String endpoint, int durationMs, int statusCode) async {
    try {
      if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return;
      final trace = FirebasePerformance.instance.newTrace('api_${endpoint.replaceAll('/', '_')}');
      trace.start();
      trace.putAttribute('duration_ms', durationMs.toString());
      trace.putAttribute('status_code', statusCode.toString());
      trace.stop();
    } catch (e) {
      _logger.d('Failed to record API call', error: e);
    }
  }
}

class DummyTrace implements Trace {
  @override
  void putAttribute(String attribute, String value) {}
  
  @override
  void start() {}
  
  @override
  void stop() {}
  
  @override
  Future<Map<String, String>> getAttributes() async => {};
  
  @override
  Future<String?> getAttribute(String attribute) async => null;
  
  @override
  Future<void> incrementMetric(String metric, int by) async {}
  
  @override
  Future<int> getMetric(String metric) async => 0;
  
  @override
  Future<Map<String, int>> getMetrics() async => {};
  
  @override
  Future<void> putMetrics(Map<String, int> metrics) async {}
}

class DummyHttpMetric implements HttpMetric {
  @override
  void setHttpResponseCode(int code) {}
  
  @override
  void setRequestPayloadSize(int bytes) {}
  
  @override
  void setResponseContentType(String contentType) {}
  
  @override
  void setResponsePayloadSize(int bytes) {}
  
  @override
  void start() {}
  
  @override
  void stop() {}
  
  @override
  String get url => '';
  
  @override
  HttpMethod get httpMethod => HttpMethod.Get;
}

// ===========================================
// FIXED: PRODUCTION API SERVICE WITH COMPLETE IMPLEMENTATION
// ===========================================
class ProductionApiService {
  final ProductionLogger _logger;
  final ProductionEncryptionService _encryption;
  final ProductionConnectivityService _connectivity;
  final RateLimitingService _rateLimiter;
  final WebSocketService _webSocket;
  late final PerformanceOptimizer _performance;
  late final SecurityArchitecture _security;
  late final GlobalApiClient _apiClient;
  late final ProductionCacheManager _cacheManager;
  late final AnalyticsService _analytics;
  
  ProductionApiService(
    this._logger,
    this._encryption,
    this._connectivity,
    this._rateLimiter,
    this._webSocket,
  );

  Future<void> initialize() async {
    _performance = PerformanceOptimizer(logger: _logger);
    await _performance.initialize();
    
    await _performance.measureOperation('api_init', () async {
      await _encryption.initialize();
      await _connectivity.initialize();
      await _webSocket.initialize();
      if (!kIsWeb) {
        await _webSocket.connect();
      }
      _cacheManager = ProductionCacheManager(logger: _logger, performance: _performance);
      await _cacheManager.initialize();
      _security = SecurityArchitecture(logger: _logger);
      await _security.initialize();
      _analytics = AnalyticsService(logger: _logger);
      await _analytics.initialize();
      
      final certificatePinning = CertificatePinningService(logger: _logger);
      await certificatePinning.initialize();
      
      _apiClient = GlobalApiClient(
        logger: _logger,
        encryption: _encryption,
        connectivity: _connectivity,
        rateLimiter: _rateLimiter,
        performance: _performance,
        security: _security,
        certificatePinning: certificatePinning,
        cacheManager: _cacheManager,
      );
      await _apiClient.initialize();
      
      _logger.i('API service initialized');
      return null;
    });
  }

  
  Future<Map<String, dynamic>> getSubscriptionPlans() async {
    try {
      final response = await _apiClient.request(ApiRequest(
        endpoint: '/subscription/plans',
        method: HttpMethod.get,
        requiresAuth: false,
        useCache: true,
      ));
      return response.data;
    } catch (e) {
      _logger.e('Failed to get subscription plans', error: e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createSubscription({
    required String userId,
    required String planId,
    required String paymentMethod,
    Map<String, dynamic>? paymentDetails,
    String? couponCode,
  }) async {
    try {
      final idempotencyKey = const Uuid().v4();
      
      final response = await _apiClient.request(ApiRequest(
        endpoint: '/subscription/create',
        method: HttpMethod.post,
        body: {
          'user_id': userId,
          'plan_id': planId,
          'payment_method': paymentMethod,
          'payment_details': paymentDetails,
          'coupon_code': couponCode,
          'timestamp': DateTime.now().toUtc().toIso8601String(),
        },
        userId: userId,
        idempotencyKey: idempotencyKey,
      ));
      
      if (response.data['subscription_id'] != null) {
        _logger.i('Subscription created: ${response.data['subscription_id']} for user $userId');
        await _analytics.logEvent('subscription_created', parameters: {
          'user_id': userId,
          'plan_id': planId,
        });
      }
      
      return response.data;
    } catch (e) {
      _logger.e('Failed to create subscription', error: e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> cancelSubscription({
    required String userId,
    required String subscriptionId,
    String? reason,
  }) async {
    try {
      final response = await _apiClient.request(ApiRequest(
        endpoint: '/subscription/cancel',
        method: HttpMethod.post,
        body: {
          'user_id': userId,
          'subscription_id': subscriptionId,
          'reason': reason,
          'timestamp': DateTime.now().toUtc().toIso8601String(),
        },
        userId: userId,
        idempotencyKey: 'cancel_$subscriptionId',
      ));
      
      _logger.i('Subscription cancelled: $subscriptionId');
      await _analytics.logEvent('subscription_cancelled', parameters: {
        'user_id': userId,
        'subscription_id': subscriptionId,
        'reason': reason ?? 'none',
      });
      return response.data;
    } catch (e) {
      _logger.e('Failed to cancel subscription', error: e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getSubscriptionStatus(String userId) async {
    try {
      final response = await _apiClient.request(ApiRequest(
        endpoint: '/subscription/status',
        method: HttpMethod.get,
        userId: userId,
        useCache: true,
      ));
      return response.data;
    } catch (e) {
      _logger.e('Failed to get subscription status', error: e);
      rethrow;
    }
  }

  Future<bool> validateSubscription(String userId) async {
    try {
      final response = await _apiClient.request(ApiRequest(
        endpoint: '/subscription/validate',
        method: HttpMethod.get,
        userId: userId,
      ));
      
      return response.data['is_valid'] as bool? ?? false;
    } catch (e) {
      _logger.d('Subscription validation failed', error: e);
      return false;
    }
  }

  Future<Map<String, dynamic>> updatePaymentMethod({
    required String userId,
    required String subscriptionId,
    required String paymentMethod,
    Map<String, dynamic>? paymentDetails,
  }) async {
    try {
      final response = await _apiClient.request(ApiRequest(
        endpoint: '/subscription/update-payment',
        method: HttpMethod.post,
        body: {
          'user_id': userId,
          'subscription_id': subscriptionId,
          'payment_method': paymentMethod,
          'payment_details': paymentDetails,
          'timestamp': DateTime.now().toUtc().toIso8601String(),
        },
        userId: userId,
        idempotencyKey: 'update_payment_$subscriptionId',
      ));
      
      _logger.i('Payment method updated for subscription: $subscriptionId');
      return response.data;
    } catch (e) {
      _logger.e('Failed to update payment method', error: e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getSubscriptionHistory(String userId) async {
    try {
      final response = await _apiClient.request(ApiRequest(
        endpoint: '/subscription/history',
        method: HttpMethod.get,
        userId: userId,
      ));
      return response.data;
    } catch (e) {
      _logger.e('Failed to get subscription history', error: e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> processRefund({
    required String userId,
    required String subscriptionId,
    required String reason,
  }) async {
    try {
      final response = await _apiClient.request(ApiRequest(
        endpoint: '/subscription/refund',
        method: HttpMethod.post,
        body: {
          'user_id': userId,
          'subscription_id': subscriptionId,
          'reason': reason,
          'timestamp': DateTime.now().toUtc().toIso8601String(),
        },
        userId: userId,
        idempotencyKey: 'refund_$subscriptionId',
      ));
      
      _logger.i('Refund processed for subscription: $subscriptionId');
      return response.data;
    } catch (e) {
      _logger.e('Failed to process refund', error: e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> applyCoupon({
    required String couponCode,
    required String planId,
  }) async {
    try {
      final response = await _apiClient.request(ApiRequest(
        endpoint: '/subscription/apply-coupon',
        method: HttpMethod.post,
        body: {
          'coupon_code': couponCode,
          'plan_id': planId,
          'timestamp': DateTime.now().toUtc().toIso8601String(),
        },
        requiresAuth: false,
        idempotencyKey: 'coupon_${couponCode}_$planId',
      ));
      
      return response.data;
    } catch (e) {
      _logger.e('Failed to apply coupon', error: e);
      rethrow;
    }
  }


  Future<Map<String, dynamic>> createPaymentIntent({
    required String userId,
    required double amount,
    required String currency,
    required String paymentMethod,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final idempotencyKey = const Uuid().v4();
      
      final response = await _apiClient.request(ApiRequest(
        endpoint: '/payment/create-intent',
        method: HttpMethod.post,
        body: {
          'user_id': userId,
          'amount': amount,
          'currency': currency,
          'payment_method': paymentMethod,
          'metadata': metadata,
          'timestamp': DateTime.now().toUtc().toIso8601String(),
        },
        userId: userId,
        idempotencyKey: idempotencyKey,
      ));
      
      _logger.i('Payment intent created for user $userId');
      await _analytics.logEvent('payment_intent_created', parameters: {
        'user_id': userId,
        'amount': amount,
        'currency': currency,
      });
      return response.data;
    } catch (e) {
      _logger.e('Failed to create payment intent', error: e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> confirmPayment({
    required String userId,
    required String paymentIntentId,
    required Map<String, dynamic> paymentDetails,
  }) async {
    try {
      final response = await _apiClient.request(ApiRequest(
        endpoint: '/payment/confirm',
        method: HttpMethod.post,
        body: {
          'user_id': userId,
          'payment_intent_id': paymentIntentId,
          'payment_details': paymentDetails,
          'timestamp': DateTime.now().toUtc().toIso8601String(),
        },
        userId: userId,
        idempotencyKey: 'confirm_$paymentIntentId',
      ));
      
      _logger.i('Payment confirmed: $paymentIntentId');
      await _analytics.logEvent('payment_confirmed', parameters: {
        'user_id': userId,
        'payment_intent_id': paymentIntentId,
      });
      return response.data;
    } catch (e) {
      _logger.e('Failed to confirm payment', error: e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getPaymentHistory(String userId) async {
    try {
      final response = await _apiClient.request(ApiRequest(
        endpoint: '/payment/history',
        method: HttpMethod.get,
        userId: userId,
      ));
      return response.data;
    } catch (e) {
      _logger.e('Failed to get payment history', error: e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getPaymentStatus(String paymentIntentId) async {
    try {
      final response = await _apiClient.request(ApiRequest(
        endpoint: '/payment/status/$paymentIntentId',
        method: HttpMethod.get,
        requiresAuth: false,
      ));
      return response.data;
    } catch (e) {
      _logger.e('Failed to get payment status', error: e);
      rethrow;
    }
  }


  Future<Map<String, dynamic>> processGooglePay({
    required String userId,
    required double amount,
    required String currency,
    required String googlePayToken,
  }) async {
    try {
      final response = await _apiClient.request(ApiRequest(
        endpoint: '/payment/google-pay',
        method: HttpMethod.post,
        body: {
          'user_id': userId,
          'amount': amount,
          'currency': currency,
          'google_pay_token': googlePayToken,
          'timestamp': DateTime.now().toUtc().toIso8601String(),
        },
        userId: userId,
        idempotencyKey: 'google_pay_${const Uuid().v4()}',
      ));
      
      _logger.i('Google Pay processed for user $userId');
      return response.data;
    } catch (e) {
      _logger.e('Failed to process Google Pay', error: e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> processPhonePe({
    required String userId,
    required double amount,
    required String currency,
    required String phonePeToken,
  }) async {
    try {
      final response = await _apiClient.request(ApiRequest(
        endpoint: '/payment/phonepe',
        method: HttpMethod.post,
        body: {
          'user_id': userId,
          'amount': amount,
          'currency': currency,
          'phonepe_token': phonePeToken,
          'timestamp': DateTime.now().toUtc().toIso8601String(),
        },
        userId: userId,
        idempotencyKey: 'phonepe_${const Uuid().v4()}',
      ));
      
      _logger.i('PhonePe processed for user $userId');
      return response.data;
    } catch (e) {
      _logger.e('Failed to process PhonePe', error: e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> processPaytm({
    required String userId,
    required double amount,
    required String currency,
    required String paytmToken,
  }) async {
    try {
      final response = await _apiClient.request(ApiRequest(
        endpoint: '/payment/paytm',
        method: HttpMethod.post,
        body: {
          'user_id': userId,
          'amount': amount,
          'currency': currency,
          'paytm_token': paytmToken,
          'timestamp': DateTime.now().toUtc().toIso8601String(),
        },
        userId: userId,
        idempotencyKey: 'paytm_${const Uuid().v4()}',
      ));
      
      _logger.i('Paytm processed for user $userId');
      return response.data;
    } catch (e) {
      _logger.e('Failed to process Paytm', error: e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> processUPI({
    required String userId,
    required double amount,
    required String currency,
    required String upiId,
    String? upiIntentUrl,
  }) async {
    try {
      final response = await _apiClient.request(ApiRequest(
        endpoint: '/payment/upi',
        method: HttpMethod.post,
        body: {
          'user_id': userId,
          'amount': amount,
          'currency': currency,
          'upi_id': upiId,
          'upi_intent_url': upiIntentUrl,
          'timestamp': DateTime.now().toUtc().toIso8601String(),
        },
        userId: userId,
        idempotencyKey: 'upi_${const Uuid().v4()}',
      ));
      
      _logger.i('UPI processed for user $userId');
      return response.data;
    } catch (e) {
      _logger.e('Failed to process UPI', error: e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> generateUPIIntent({
    required double amount,
    required String currency,
    required String upiId,
    required String name,
    String? note,
  }) async {
    try {
      final uri = Uri(
        scheme: 'upi',
        path: 'pay',
        queryParameters: {
          'pa': upiId,
          'pn': name,
          'am': amount.toStringAsFixed(2),
          'cu': currency,
          'tn': note ?? 'Subscription to Askroa AI',
          'mode': '04',
        },
      );
      
      final upiIntentUrl = uri.toString();
      
      return {
        'upi_intent_url': upiIntentUrl,
        'upi_id': upiId,
        'amount': amount,
        'currency': currency,
      };
    } catch (e) {
      _logger.e('Failed to generate UPI intent', error: e);
      rethrow;
    }
  }


  Future<Map<String, dynamic>> executeAIFeature({
    required String feature,
    required String userId,
    required String plan,
    Map<String, dynamic>? parameters,
    String? idempotencyKey,
  }) async {
    try {
      final response = await _apiClient.request(ApiRequest(
        endpoint: '/ai/execute-feature',
        method: HttpMethod.post,
        body: {
          'feature': feature,
          'user_id': userId,
          'parameters': parameters,
          'timestamp': DateTime.now().toUtc().toIso8601String(),
        },
        userId: userId,
        plan: plan,
        idempotencyKey: idempotencyKey,
      ));
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Stream<String> sendChatMessageStream({
    required String sessionId,
    required String message,
    required String userId,
    required String plan,
    bool deepResearch = false,
    List<String>? attachments,
    String? idempotencyKey,
  }) async* {
    try {
      final streamId = await _webSocket.sendChatMessage(
        sessionId: sessionId,
        message: message,
        userId: userId,
        deepResearch: deepResearch,
        attachments: attachments,
      );

      yield* _webSocket.subscribeToStream(streamId);
    } catch (e) {
      _logger.w('[Chat] WebSocket unavailable, falling back to HTTP: $e');
      final response = await sendChatMessage(
        sessionId: sessionId,
        message: message,
        userId: userId,
        plan: plan,
        deepResearch: deepResearch,
        attachments: attachments,
        idempotencyKey: idempotencyKey,
      );
      
      yield response['response'] as String;
    }
  }

  Future<Map<String, dynamic>> sendChatMessage({
    required String sessionId,
    required String message,
    required String userId,
    required String plan,
    bool deepResearch = false,
    List<String>? attachments,
    String? parentMessageId,
    String? idempotencyKey,
    String? modelId,
  }) async {
    try {
      final response = await _apiClient.request(ApiRequest(
        endpoint: '/chat/messages',
        method: HttpMethod.post,
        body: {
          'session_id': sessionId,
          'message': message,
          'user_id': userId,
          'deep_research': deepResearch,
          'attachments': attachments,
          'parent_message_id': parentMessageId,
          'timestamp': DateTime.now().toUtc().toIso8601String(),
          if (modelId != null) 'model_id': modelId,
          'plan': plan, // backend uses this to verify model entitlement
        },
        userId: userId,
        plan: plan,
        idempotencyKey: idempotencyKey,
      ));
      
      await _analytics.logEvent('chat_message_sent', parameters: {
        'user_id': userId,
        'session_id': sessionId,
        'deep_research': deepResearch,
      });
      
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> selectModelForSession({
    required String sessionId,
    required String modelId,
  }) async {
    try {
      final response = await _apiClient.request(ApiRequest(
        endpoint: '/chat/model-select',
        method: HttpMethod.post,
        body: {
          'session_id': sessionId,
          'model_id': modelId,
        },
      ));
      return response.data as Map<String, dynamic>;
    } on ApiException catch (e) {
      if (e.statusCode == 403) {
        return {
          'success': false,
          'allowed': false,
          'message': e.message,
        };
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> clearModelSelection() async {
    try {
      await _apiClient.request(ApiRequest(
        endpoint: '/chat/model-select/clear',
        method: HttpMethod.post,
        body: {},
      ));
    } catch (e) {
      _logger.w('clearModelSelection failed (non-critical)', error: e);
    }
  }

  Future<void> sendMessageFeedback({
    required String messageId,
    required String reaction,
    String? feedbackText,
  }) async {
    try {
      await _apiClient.request(ApiRequest(
        endpoint: '/feedback/message',
        method: HttpMethod.post,
        body: {
          'message_id': messageId,
          'reaction': reaction,
          if (feedbackText != null) 'feedback_text': feedbackText,
          'timestamp': DateTime.now().toUtc().toIso8601String(),
        },
      ));
      _logger.d('Message feedback sent: $messageId reaction=$reaction');
    } catch (e) {
      _logger.d('Send feedback failed (non-critical)', error: e);
    }
  }

  Future<void> reportMessage({
    required String messageId,
    required String reportText,
  }) async {
    try {
      await _apiClient.request(ApiRequest(
        endpoint: '/report/message',
        method: HttpMethod.post,
        body: {
          'message_id': messageId,
          'report_text': reportText,
          'timestamp': DateTime.now().toUtc().toIso8601String(),
        },
      ));
      _logger.d('Message reported: $messageId');
    } catch (e) {
      _logger.d('Report message failed (non-critical)', error: e);
    }
  }

  Future<Map<String, dynamic>> regenerateMessage({
    required String sessionId,
    required String messageId,
    required String userId,
    String? modelId,
    String? plan,
  }) async {
    try {
      final response = await _apiClient.request(ApiRequest(
        endpoint: '/chat/regenerate',
        method: HttpMethod.post,
        body: {
          'session_id': sessionId,
          'message_id': messageId,
          'user_id': userId,
          if (modelId != null) 'model_id': modelId,
          'timestamp': DateTime.now().toUtc().toIso8601String(),
        },
        userId: userId,
        plan: plan,
      ));
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> fetchModelsByPlan() async {
    try {
      final response = await _apiClient.request(ApiRequest(
        endpoint: '/ai/models/list/by-plan',
        method: HttpMethod.get,
      ));
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      if (!_security.validateInput(email, InputType.email)) {
        throw ApiException('Invalid email format', 400, 'INVALID_EMAIL');
      }
      
      if (!_security.validateInput(password, InputType.password)) {
        throw ApiException('Password must be at least 8 characters with uppercase, lowercase, number and special character', 400, 'INVALID_PASSWORD');
      }

      final response = await _apiClient.request(ApiRequest(
        endpoint: '/auth/login/email',
        method: HttpMethod.post,
        body: {
          'email': _security.sanitizeInput(email, InputType.email),
          'password': password,
          'device_info': await _getDeviceInfo(),
          'timestamp': DateTime.now().toUtc().toIso8601String(),
        },
        requiresAuth: false,
        idempotencyKey: 'login_${sha256.convert(utf8.encode(email + password)).toString()}',
      ));

      if (response.data['access_token'] != null) {
        await _storeAuthData(
          accessToken: response.data['access_token'] as String,
          refreshToken: response.data['refresh_token'] as String,
          userData: response.data['user'] as Map<String, dynamic>,
          expiresIn: response.data['expires_in'] as int,
        );
        
        await _security.setTokens(
          response.data['access_token'] as String,
          response.data['refresh_token'] as String,
          response.data['expires_in'] as int,
        );
        
        await _analytics.logEvent('login_email', parameters: {
          'user_id': response.data['user']?['id'],
        });
        
        _logger.i('Email login successful for user: ${response.data['user']?['id']}');
      }

      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> loginWithGoogle() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign in cancelled');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final response = await _apiClient.request(ApiRequest(
        endpoint: '/auth/login/google',
        method: HttpMethod.post,
        body: {
          'google_token': googleAuth.idToken,
          'device_info': await _getDeviceInfo(),
          'timestamp': DateTime.now().toUtc().toIso8601String(),
        },
        requiresAuth: false,
        idempotencyKey: 'google_${googleUser.id}',
      ));

      if (response.data['access_token'] != null) {
        await _storeAuthData(
          accessToken: response.data['access_token'] as String,
          refreshToken: response.data['refresh_token'] as String,
          userData: response.data['user'] as Map<String, dynamic>,
          expiresIn: response.data['expires_in'] as int,
        );
        
        await _security.setTokens(
          response.data['access_token'] as String,
          response.data['refresh_token'] as String,
          response.data['expires_in'] as int,
        );
        
        await _analytics.logEvent('login_google', parameters: {
          'user_id': response.data['user']?['id'],
        });
        
        _logger.i('Google login successful for user: ${response.data['user']?['id']}');
      }

      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> loginWithApple() async {
    if (kIsWeb || !Platform.isIOS) {
      throw ApiException('Apple Sign In is only available on iOS', 400, 'PLATFORM_NOT_SUPPORTED');
    }
    
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final response = await _apiClient.request(ApiRequest(
        endpoint: '/auth/login/apple',
        method: HttpMethod.post,
        body: {
          'apple_token': credential.identityToken,
          'device_info': await _getDeviceInfo(),
          'timestamp': DateTime.now().toUtc().toIso8601String(),
        },
        requiresAuth: false,
        idempotencyKey: 'apple_${credential.userIdentifier ?? 'unknown'}',
      ));

      if (response.data['access_token'] != null) {
        await _storeAuthData(
          accessToken: response.data['access_token'] as String,
          refreshToken: response.data['refresh_token'] as String,
          userData: response.data['user'] as Map<String, dynamic>,
          expiresIn: response.data['expires_in'] as int,
        );
        
        await _security.setTokens(
          response.data['access_token'] as String,
          response.data['refresh_token'] as String,
          response.data['expires_in'] as int,
        );
        
        await _analytics.logEvent('login_apple', parameters: {
          'user_id': response.data['user']?['id'],
        });
        
        _logger.i('Apple login successful for user: ${response.data['user']?['id']}');
      }

      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout(String userId) async {
    try {
      await _apiClient.request(ApiRequest(
        endpoint: '/auth/logout',
        method: HttpMethod.post,
        body: {
          'user_id': userId,
          'timestamp': DateTime.now().toUtc().toIso8601String(),
        },
        idempotencyKey: 'logout_$userId',
      ));

      await _clearAuthData();
      await _security.clearTokens();
      
      await _analytics.logEvent('logout', parameters: {
        'user_id': userId,
      });
      
      _logger.i('Logout successful for user: $userId');
    } catch (e) {
      await _clearAuthData();
      await _security.clearTokens();
      rethrow;
    }
  }

  Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      if (!_security.validateInput(name, InputType.name)) {
        throw ApiException('Invalid name format', 400, 'INVALID_NAME');
      }
      
      if (!_security.validateInput(email, InputType.email)) {
        throw ApiException('Invalid email format', 400, 'INVALID_EMAIL');
      }
      
      if (!_security.validateInput(password, InputType.password)) {
        throw ApiException('Password must be at least 8 characters with uppercase, lowercase, number and special character', 400, 'INVALID_PASSWORD');
      }
      
      if (phone != null && !_security.validateInput(phone, InputType.phone)) {
        throw ApiException('Invalid phone format', 400, 'INVALID_PHONE');
      }

      final response = await _apiClient.request(ApiRequest(
        endpoint: '/auth/register',
        method: HttpMethod.post,
        body: {
          'name': _security.sanitizeInput(name, InputType.name),
          'email': _security.sanitizeInput(email, InputType.email),
          'password': password,
          'phone': phone != null ? _security.sanitizeInput(phone, InputType.phone) : null,
          'device_info': await _getDeviceInfo(),
          'timestamp': DateTime.now().toUtc().toIso8601String(),
        },
        requiresAuth: false,
        idempotencyKey: 'register_${sha256.convert(utf8.encode(email)).toString()}',
      ));

      if (response.data['access_token'] != null) {
        await _storeAuthData(
          accessToken: response.data['access_token'] as String,
          refreshToken: response.data['refresh_token'] as String,
          userData: response.data['user'] as Map<String, dynamic>,
          expiresIn: response.data['expires_in'] as int,
        );
        
        await _security.setTokens(
          response.data['access_token'] as String,
          response.data['refresh_token'] as String,
          response.data['expires_in'] as int,
        );
        
        await _analytics.logEvent('user_registered', parameters: {
          'user_id': response.data['user']?['id'],
        });
        
        _logger.i('Registration successful for user: ${response.data['user']?['id']}');
      }

      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> stopGeneration({
    required String sessionId,
    required String userId,
    required String messageId,
  }) async {
    try {
      final response = await _apiClient.request(ApiRequest(
        endpoint: '/chat/generation/stop',
        method: HttpMethod.post,
        body: {
          'session_id': sessionId,
          'user_id': userId,
          'message_id': messageId,
          'timestamp': DateTime.now().toUtc().toIso8601String(),
        },
        userId: userId,
      ));
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getChatHistory({
    required String userId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiClient.request(ApiRequest(
        endpoint: '/chat/history?page=$page&limit=$limit',
        method: HttpMethod.get,
        userId: userId,
      ));
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getChatHistoryWithRetry({
    required String userId,
    int page = 1,
    int limit = 20,
    int maxRetries = 3,
  }) async {
    int retryCount = 0;
    while (retryCount < maxRetries) {
      try {
        return await getChatHistory(userId: userId, page: page, limit: limit);
      } catch (e) {
        retryCount++;
        if (retryCount == maxRetries) {
          rethrow;
        }
        await Future.delayed(Duration(seconds: retryCount * 2));
      }
    }
    throw Exception('Failed after $maxRetries retries');
  }

  Future<Map<String, dynamic>> processVoiceCommand({
    required String audioBase64,
    required String userId,
    required String plan,
    String? sessionId,
    String? idempotencyKey,
  }) async {
    try {
      final response = await _apiClient.request(ApiRequest(
        endpoint: '/voice/process',
        method: HttpMethod.post,
        body: {
          'audio_data': audioBase64,
          'user_id': userId,
          'session_id': sessionId,
          'audio_format': 'wav',
          'sample_rate': 16000,
          'timestamp': DateTime.now().toUtc().toIso8601String(),
        },
        userId: userId,
        plan: plan,
        idempotencyKey: idempotencyKey ?? 'voice_${sha256.convert(utf8.encode(audioBase64.substring(0, min(100, audioBase64.length)))).toString()}',
      ));
      
      await _analytics.logEvent('voice_command_processed', parameters: {
        'user_id': userId,
      });
      
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> uploadFile({
    required File file,
    required String userId,
    required String fileType,
    void Function(double)? onProgress,
    CancelToken? cancelToken,
    String? idempotencyKey,
  }) async {
    try {
      final fileSize = await file.length();
      final chunkSize = 1024 * 1024;
      
      if (fileSize <= chunkSize) {
        final formData = FormData.fromMap({
          'file': await MultipartFile.fromFile(
            file.path,
            filename: path.basename(file.path),
            contentType: MediaType.parse(fileType),
          ),
          'user_id': userId,
          'file_type': fileType,
          'timestamp': DateTime.now().toUtc().toIso8601String(),
        });

        final response = await _apiClient.dio.post(
          '/files/upload',
          data: formData,
          onSendProgress: (sent, total) {
            onProgress?.call(sent / total);
          },
          cancelToken: cancelToken,
          options: Options(headers: {
            'Idempotency-Key': idempotencyKey
                ?? 'upload_${sha256.convert(utf8.encode(file.path + fileSize.toString())).toString()}',
          }),
        );

        await _analytics.logEvent('file_uploaded', parameters: {
          'user_id': userId,
          'file_size': fileSize,
          'file_type': fileType,
        });

        return response.data as Map<String, dynamic>;
      } else {
        final uploadId = '${userId}_${DateTime.now().millisecondsSinceEpoch}';
        final chunks = (fileSize / chunkSize).ceil();
        
        final initResponse = await _apiClient.dio.post(
          '/files/upload/init',
          data: {
            'filename': path.basename(file.path),
            'file_size': fileSize,
            'file_type': fileType,
            'user_id': userId,
            'upload_id': uploadId,
            'chunks': chunks,
          },
          options: Options(headers: {
            'Idempotency-Key': 'upload_init_${sha256.convert(utf8.encode(file.path)).toString()}',
          }),
        );
        
        final uploadData = initResponse.data as Map<String, dynamic>;
        final serverUploadId = uploadData['upload_id'] as String;
        
        final statusResponse = await _apiClient.dio.get(
          '/files/upload/status/$serverUploadId',
        );
        
        final statusData = statusResponse.data as Map<String, dynamic>;
        final uploadedChunks = (statusData['uploaded_chunks'] as List?)?.cast<int>() ?? [];
        
        for (int i = 0; i < chunks; i++) {
          if (uploadedChunks.contains(i)) {
            onProgress?.call((i + 1) / chunks);
            continue;
          }
          
          final start = i * chunkSize;
          final end = min(start + chunkSize, fileSize);
          Uint8List chunkBytes;
          final raf = await file.open(mode: FileMode.read);
          try {
            await raf.setPosition(start);
            chunkBytes = await raf.read(end - start);
          } finally {
            await raf.close();
          }
          
          final chunkData = FormData.fromMap({
            'file': MultipartFile.fromBytes(
              chunkBytes,
              filename: 'chunk_$i',
            ),
            'upload_id': serverUploadId,
            'chunk_index': i,
            'total_chunks': chunks,
          });
          
          await _apiClient.dio.post(
            '/files/upload/chunk',
            data: chunkData,
            onSendProgress: (sent, total) {
              onProgress?.call((i + sent / total) / chunks);
            },
            cancelToken: cancelToken,
            options: Options(headers: {
              'Idempotency-Key': 'upload_chunk_${serverUploadId}_$i',
            }),
          );
          
          onProgress?.call((i + 1) / chunks);
        }
        
        final completeResponse = await _apiClient.dio.post(
          '/files/upload/complete',
          data: {
            'upload_id': serverUploadId,
            'timestamp': DateTime.now().toUtc().toIso8601String(),
          },
          options: Options(headers: {
            'Idempotency-Key': 'upload_complete_$serverUploadId',
          }),
        );
        
        await _analytics.logEvent('file_uploaded_chunked', parameters: {
          'user_id': userId,
          'file_size': fileSize,
          'chunks': chunks,
        });
        
        return completeResponse.data as Map<String, dynamic>;
      }
    } catch (e, stack) {
      _logger.e('File upload failed', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> generateImage({
    required String prompt,
    required String userId,
    required String plan,
    String? style,
    String? size,
    String? idempotencyKey,
  }) async {
    try {
      final response = await _apiClient.request(ApiRequest(
        endpoint: '/images/generate',
        method: HttpMethod.post,
        body: {
          'prompt': _security.sanitizeInput(prompt, InputType.message),
          'user_id': userId,
          'style': style,
          'size': size,
          'timestamp': DateTime.now().toUtc().toIso8601String(),
        },
        userId: userId,
        plan: plan,
        idempotencyKey: idempotencyKey ?? 'image_${sha256.convert(utf8.encode(prompt + userId)).toString()}',
      ));
      
      await _analytics.logEvent('image_generated', parameters: {
        'user_id': userId,
        'prompt_length': prompt.length,
        'style': style ?? 'default',
      });
      
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getImageHistory({
    required String userId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiClient.request(ApiRequest(
        endpoint: '/images/history?page=$page&limit=$limit',
        method: HttpMethod.get,
        userId: userId,
      ));
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> walkWorldVoiceQuery({
    required String query,
    required String userId,
  }) async {
    try {
      final response = await _apiClient.request(ApiRequest(
        endpoint: '/walkworld/query',
        method: HttpMethod.post,
        body: {
          'query': _security.sanitizeInput(query, InputType.message),
          'user_id': userId,
          'timestamp': DateTime.now().toUtc().toIso8601String(),
        },
        userId: userId,
        timeout: const Duration(seconds: 15),
        idempotencyKey: 'walkworld_${sha256.convert(utf8.encode(query)).toString()}',
      ));
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> sendThinkingRequest({
    required String sessionId,
    required String message,
    required String userId,
    required String plan,
    int thinkingBudget = 8000,
    String? modelId,
    String? idempotencyKey,
  }) async {
    try {
      final response = await _apiClient.request(ApiRequest(
        endpoint: '/chat/thinking',
        method: HttpMethod.post,
        body: {
          'session_id':      sessionId,
          'message':         _security.sanitizeInput(message, InputType.message),
          'user_id':         userId,
          'thinking_budget': thinkingBudget,
          if (modelId != null) 'model_id': modelId,
          'timestamp': DateTime.now().toUtc().toIso8601String(),
        },
        userId: userId,
        plan: plan,
        timeout: const Duration(seconds: 90),
        idempotencyKey: idempotencyKey ??
            'think_${sha256.convert(utf8.encode(message + sessionId)).toString()}',
      ));
      return response.data;
    } catch (e) {
      rethrow;
    }
  }



  Future<Map<String, dynamic>> securityCheck({
    required String userId,
    required Map<String, dynamic> requestData,
  }) async {
    try {
      final response = await _apiClient.request(ApiRequest(
        endpoint: '/security/check',
        method: HttpMethod.post,
        body: {'user_id': userId, ...requestData},
        userId: userId,
      ));
      return response.data;
    } catch (e) {
      _logger.d('Security check failed (non-critical)', error: e);
      return {'result': {'safe': true}};
    }
  }

  Future<Map<String, dynamic>> storageUpload({
    required String userId,
    required String filePath,
    String provider = 'aws',
    String bucket = 'ai-sandbox',
    bool encrypt = true,
  }) async {
    final response = await _apiClient.request(ApiRequest(
      endpoint: '/storage/upload',
      method: HttpMethod.post,
      body: {
        'user_id':   userId,
        'file_path': filePath,
        'provider':  provider,
        'bucket':    bucket,
        'encrypt':   encrypt,
      },
      userId: userId,
    ));
    return response.data;
  }

  Future<Map<String, dynamic>> createBackup({
    required String userId,
    String type = 'full',
    String description = 'App triggered backup',
  }) async {
    final response = await _apiClient.request(ApiRequest(
      endpoint: '/backup/create',
      method: HttpMethod.post,
      body: {'user_id': userId, 'type': type, 'description': description},
      userId: userId,
    ));
    return response.data;
  }

  Future<Map<String, dynamic>> getBackupStatus() async {
    final response = await _apiClient.request(ApiRequest(
      endpoint: '/backup/status',
      method: HttpMethod.get,
      requiresAuth: true,
    ));
    return response.data;
  }

  Future<Map<String, dynamic>> storeMemory({
    required String userId,
    required Map<String, dynamic> content,
    String type = 'general',
    double importance = 0.5,
  }) async {
    final response = await _apiClient.request(ApiRequest(
      endpoint: '/memory/store',
      method: HttpMethod.post,
      body: {
        'user_id':    userId,
        'type':       type,
        'content':    content,
        'importance': importance,
      },
      userId: userId,
    ));
    return response.data;
  }

  Future<Map<String, dynamic>> retrieveMemory({
    required String userId,
    required String query,
    int maxResults = 5,
  }) async {
    final response = await _apiClient.request(ApiRequest(
      endpoint: '/memory/retrieve?user_id=${Uri.encodeComponent(userId)}'
                '&query=${Uri.encodeComponent(query)}&max_results=$maxResults',
      method: HttpMethod.get,
      userId: userId,
    ));
    return response.data;
  }

  Future<Map<String, dynamic>> triggerEmergencyRecovery() async {
    final response = await _apiClient.request(ApiRequest(
      endpoint: '/emergency/recovery',
      method: HttpMethod.post,
      body: {},
      requiresAuth: true,
    ));
    return response.data;
  }

  Future<Map<String, dynamic>> getDatabaseStats() async {
    final response = await _apiClient.request(ApiRequest(
      endpoint: '/database/stats',
      method: HttpMethod.get,
      requiresAuth: true,
    ));
    return response.data;
  }

  Future<void> publishEvent({
    required String eventType,
    required Map<String, dynamic> data,
    required String userId,
  }) async {
    try {
      await _apiClient.request(ApiRequest(
        endpoint: '/event/publish',
        method: HttpMethod.post,
        body: {'type': eventType, 'data': data},
        userId: userId,
      ));
    } catch (e) {
      _logger.d('Event publish failed (non-critical)', error: e);
    }
  }

  Future<Map<String, dynamic>> getPlanLimits({required String planId}) async {
    final response = await _apiClient.request(ApiRequest(
      endpoint: '/subscription/plans/limits/$planId',
      method: HttpMethod.get,
    ));
    return response.data;
  }

  Future<Map<String, dynamic>> processSubscriptionPayment({
    required String userId,
    required String planType,
    required String paymentMethod,
    required String plan,
    Map<String, dynamic>? paymentDetails,
    Map<String, dynamic>? billingInfo,
  }) async {
    final response = await _apiClient.request(ApiRequest(
      endpoint: '/subscription/payment',
      method: HttpMethod.post,
      body: {
        'user_id':        userId,
        'plan_type':      planType,
        'payment_method': paymentMethod,
        if (paymentDetails != null) 'payment_details': paymentDetails,
        if (billingInfo != null) 'billing_info': billingInfo,
        'timestamp': DateTime.now().toUtc().toIso8601String(),
      },
      userId: userId,
      plan: plan,
      idempotencyKey:
          'subpay_${sha256.convert(utf8.encode(userId + planType)).toString()}',
    ));
    return response.data;
  }

  Future<Map<String, dynamic>> fetchAIModels() async {
    try {
      final response = await _apiClient.request(ApiRequest(
        endpoint: '/ai/models',
        method: HttpMethod.get,
        requiresAuth: true,
      ));
      return response.data;
    } catch (e) {
      _logger.d('Fetch AI models failed', error: e);
      return {'models': [], 'total': 0};
    }
  }

  Future<Map<String, dynamic>> sourcedSearch({
    required String query,
    required String userId,
    required String plan,
    String? modelId,
    int maxSources = 6,
    bool fetchFullPages = false,
  }) async {
    final response = await _apiClient.request(ApiRequest(
      endpoint: '/ai/sourced-search',
      method: HttpMethod.post,
      body: {
        'query':            _security.sanitizeInput(query, InputType.message),
        'user_id':          userId,
        if (modelId != null) 'model_id': modelId,
        'max_sources':      maxSources,
        'fetch_full_pages': fetchFullPages,
        'timestamp': DateTime.now().toUtc().toIso8601String(),
      },
      userId: userId,
      plan: plan,
      timeout: const Duration(seconds: 30),
      idempotencyKey:
          'srch_${sha256.convert(utf8.encode(query + userId)).toString()}',
    ));
    return response.data;
  }

  Future<void> auditResponse({
    required String responseText,
    required String prompt,
    required String userId,
    required String model,
  }) async {
    try {
      await _apiClient.request(ApiRequest(
        endpoint: '/audit/response',
        method: HttpMethod.post,
        body: {
          'response': responseText,
          'prompt':   prompt,
          'user_id':  userId,
          'model':    model,
          'timestamp': DateTime.now().toUtc().toIso8601String(),
        },
        userId: userId,
      ));
    } catch (e) {
      _logger.d('Audit response failed (non-critical)', error: e);
    }
  }

  Future<Map<String, dynamic>> auditPrompt({
    required String prompt,
    required String userId,
  }) async {
    try {
      final response = await _apiClient.request(ApiRequest(
        endpoint: '/audit/prompt',
        method: HttpMethod.post,
        body: {
          'prompt':  _security.sanitizeInput(prompt, InputType.message),
          'user_id': userId,
          'timestamp': DateTime.now().toUtc().toIso8601String(),
        },
        userId: userId,
      ));
      return response.data;
    } catch (e) {
      _logger.d('Audit prompt failed (non-critical)', error: e);
      return {'safe': true};
    }
  }

  Future<Map<String, dynamic>> fetchAuditSummary({int lastN = 100}) async {
    try {
      final response = await _apiClient.request(ApiRequest(
        endpoint: '/audit/summary?last_n=$lastN',
        method: HttpMethod.get,
        requiresAuth: true,
      ));
      return response.data;
    } catch (e) {
      _logger.d('Fetch audit summary failed', error: e);
      return {};
    }
  }



  static final AppSecureStorage _secureStorage = AppSecureStorage.instance;

  Future<void> _storeAuthData({
    required String accessToken,
    required String refreshToken,
    required Map<String, dynamic> userData,
    required int expiresIn,
  }) async {
    try {
      await _secureStorage.write(
        key: 'askroa_access_token',
        value: _encryption.encrypt(accessToken),
      );
      await _secureStorage.write(
        key: 'askroa_refresh_token',
        value: _encryption.encrypt(refreshToken),
      );
      await _secureStorage.write(
        key: 'askroa_user_data',
        value: _encryption.encrypt(jsonEncode(userData)),
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'askroa_last_login',
        DateTime.now().toUtc().toIso8601String(),
      );

      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        try {
          await FirebaseCrashlytics.instance.setUserIdentifier(userData['id'] as String? ?? 'unknown');
          await FirebaseCrashlytics.instance.setCustomKey('plan', userData['plan'] as String? ?? 'free');
        } catch (e) {
          _logger.d('Crashlytics set user failed', error: e);
        }
      }

      final dailyQuota = userData['daily_quota'] as int? ?? 5;
      await _rateLimiter.syncQuotaWithServer(userData['id'] as String, dailyQuota);

      _logger.d('Auth data stored securely for user: ${userData['id']}');
    } catch (e, stack) {
      _logger.e('Store auth data failed', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<void> _clearAuthData() async {
    try {
      await _secureStorage.delete(key: 'askroa_access_token');
      await _secureStorage.delete(key: 'askroa_refresh_token');
      await _secureStorage.delete(key: 'askroa_user_data');

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('askroa_last_login');

      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        try {
          await FirebaseCrashlytics.instance.setUserIdentifier(null);
        } catch (e) {
          _logger.d('Crashlytics clear user failed', error: e);
        }
      }

      _logger.d('Auth data cleared from secure storage');
    } catch (e, stack) {
      _logger.e('Clear auth data failed', error: e, stackTrace: stack);
    }
  }

  Future<String> _getDeviceId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? deviceId = prefs.getString('askroa_device_id');
      if (deviceId == null) {
        deviceId = const Uuid().v4();
        await prefs.setString('askroa_device_id', deviceId);
      }
      return deviceId;
    } catch (e) {
      return 'unknown_device_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  Future<Map<String, dynamic>> _getDeviceInfo() async {
    String platform;
    if (kIsWeb) {
      platform = 'web';
    } else {
      platform = Platform.operatingSystem;
    }
    
    return {
      'device_id': await _getDeviceId(),
      'platform': platform,
      'os_version': kIsWeb ? 'web' : Platform.operatingSystemVersion,
      'app_version': appVersion,
      'device_model': kIsWeb ? 'Web' : (Platform.isAndroid ? 'Android' : (Platform.isIOS ? 'iOS' : Platform.operatingSystem)),
      'locale': Platform.localeName,
      'timezone': DateTime.now().timeZoneName,
    };
  }

  void dispose() {
    _apiClient.dispose();
    _webSocket.disconnect();
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  final String? errorCode;

  ApiException(this.message, this.statusCode, [this.errorCode]);

  @override
  String toString() {
    return 'ApiException: $message (Status: $statusCode${errorCode != null ? ', Code: $errorCode' : ''})';
  }
}

// ===========================================
// CIRCUIT BREAKER
// ===========================================
enum CircuitBreakerState {
  closed,
  open,
  halfOpen,
}

class CircuitBreaker {
  final int failureThreshold;
  final Duration timeout;
  int failureCount = 0;
  CircuitBreakerState state = CircuitBreakerState.closed;
  DateTime? openTime;
  
  CircuitBreaker({required this.failureThreshold, required this.timeout});
  
  bool get canExecute {
    if (state == CircuitBreakerState.closed) return true;
    
    if (state == CircuitBreakerState.open) {
      if (openTime != null && DateTime.now().difference(openTime!) > timeout) {
        state = CircuitBreakerState.halfOpen;
        return true;
      }
      return false;
    }
    
    return true;
  }
  
  void recordSuccess() {
    if (state == CircuitBreakerState.halfOpen) {
      state = CircuitBreakerState.closed;
      failureCount = 0;
    }
  }
  
  void recordFailure() {
    if (state == CircuitBreakerState.closed || state == CircuitBreakerState.halfOpen) {
      failureCount++;
      if (failureCount >= failureThreshold) {
        state = CircuitBreakerState.open;
        openTime = DateTime.now();
      }
    }
  }
}

enum HttpMethod { get, post, put, delete, patch }

class ApiRequest {
  final String endpoint;
  final HttpMethod method;
  final Map<String, dynamic>? body;
  final Map<String, String>? headers;
  final String? userId;
  final String? plan;
  final bool requiresAuth;
  final bool useCache;
  final String? idempotencyKey;
  final Duration? timeout;
  
  ApiRequest({
    required this.endpoint,
    required this.method,
    this.body,
    this.headers,
    this.userId,
    this.plan,
    this.requiresAuth = true,
    this.useCache = false,
    this.idempotencyKey,
    this.timeout,
  });
}

class ApiResponse<T> {
  final T data;
  final int statusCode;
  final Map<String, String> headers;
  
  ApiResponse({required this.data, required this.statusCode, required this.headers});
}

// ===========================================
// CERTIFICATE PINNING SERVICE - FIXED
// ===========================================
class CertificatePinningService {
  final ProductionLogger _logger;
  final List<String> _pinnedCertificates = [
    const String.fromEnvironment(
      'CERTIFICATE_PIN_PRIMARY',
      defaultValue: '',
    ),
  ];
  bool _isInitialized = false;
  static const String _certExpiryKey = 'askroa_cert_expiry_warned';

  CertificatePinningService({required ProductionLogger logger}) : _logger = logger;

  Future<void> initialize({RemoteConfigService? remoteConfig}) async {
    if (_isInitialized) return;

    const backupPin = String.fromEnvironment('CERTIFICATE_PIN_BACKUP');
    if (backupPin.isNotEmpty && !_pinnedCertificates.contains(backupPin)) {
      _pinnedCertificates.add(backupPin);
    }

    if (remoteConfig != null) {
      try {
        final rcPrimary = remoteConfig.getString('certificate_pin_primary', defaultValue: '');
        final rcBackup  = remoteConfig.getString('certificate_pin_backup',  defaultValue: '');
        if (rcPrimary.isNotEmpty && !_pinnedCertificates.contains(rcPrimary)) {
          _pinnedCertificates.insert(0, rcPrimary);
        }
        if (rcBackup.isNotEmpty && !_pinnedCertificates.contains(rcBackup)) {
          _pinnedCertificates.add(rcBackup);
        }
        _logger.d('[CertPin] Remote pins loaded: ${_pinnedCertificates.length}');
      } catch (e) {
        _logger.w('[CertPin] Remote config pin load failed', error: e);
      }
    }

    await _checkCertExpiryWarning();

    if (kDebugMode) {
      _logger.d('[CertPin] Initialized with ${_pinnedCertificates.length} pins.');
    }

    _isInitialized = true;
  }

  Future<void> _checkCertExpiryWarning() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final warned = prefs.getString(_certExpiryKey);
      if (warned != null) {
        final warnedDate = DateTime.tryParse(warned);
        if (warnedDate != null &&
            DateTime.now().difference(warnedDate).inDays < 30) {
          return;
        }
      }
      const expiryEnv = String.fromEnvironment('CERTIFICATE_EXPIRY_DATE', defaultValue: '');
      if (expiryEnv.isEmpty) return;
      final expiry = DateTime.tryParse(expiryEnv);
      if (expiry == null) return;
      final daysLeft = expiry.difference(DateTime.now()).inDays;
      if (daysLeft <= 60) {
        _logger.w('[CertPin] Certificate expires in $daysLeft days! Update app before expiry.');
        await prefs.setString(_certExpiryKey, DateTime.now().toIso8601String());
      }
    } catch (_) {}
  }

  Future<void> configureDio(Dio dio) async {
    try {
      if (kIsWeb) {
        _logger.d('Certificate pinning not available on web');
        return;
      }
      
      if (Platform.isAndroid) {
        (dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate = (client) {
          client.badCertificateCallback = (X509Certificate cert, String host, int port) {
            final String certFingerprint = _getCertificateFingerprint(cert);
            final bool isPinned = _pinnedCertificates.contains(certFingerprint);
            
            if (!isPinned) {
              _logger.e('Certificate pinning failed for $host', error: {
                'host': host,
                'fingerprint': certFingerprint,
              });
            }
            
            return isPinned;
          };
          return client;
        };
      } else if (Platform.isIOS) {
        (dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate = (client) {
          client.badCertificateCallback = (X509Certificate cert, String host, int port) {
            final String certFingerprint = _getCertificateFingerprint(cert);
            final bool isPinned = _pinnedCertificates.contains(certFingerprint);
            
            if (!isPinned) {
              _logger.e('Certificate pinning failed for $host', error: {
                'host': host,
                'fingerprint': certFingerprint,
              });
            }
            
            return isPinned;
          };
          return client;
        };
      }

      _logger.i('Certificate pinning configured with ${_pinnedCertificates.length} certificates');
    } catch (e, stack) {
      _logger.e('Failed to configure certificate pinning', error: e, stackTrace: stack);
    }
  }

  String _getCertificateFingerprint(X509Certificate cert) {
    try {
      final certBytes = cert.der;
      if (certBytes == null || certBytes.isEmpty) {
        _logger.w('[CertPin] Certificate DER bytes null or empty');
        return '';
      }
      final sha256 = pc.SHA256Digest();
      final digest = sha256.process(Uint8List.fromList(certBytes));
      return 'sha256/${base64.encode(digest)}';
    } catch (e) {
      _logger.e('Failed to compute certificate fingerprint', error: e);
      return '';
    }
  }

  bool validateCertificate(String fingerprint) {
    return _pinnedCertificates.contains(fingerprint);
  }

  void addCertificate(String fingerprint) {
    if (!_pinnedCertificates.contains(fingerprint)) {
      _pinnedCertificates.add(fingerprint);
      _logger.d('Added certificate: $fingerprint');
    }
  }

  void removeCertificate(String fingerprint) {
    _pinnedCertificates.remove(fingerprint);
    _logger.d('Removed certificate: $fingerprint');
  }

  List<String> get certificates => List.unmodifiable(_pinnedCertificates);
}

// ===========================================
// IDEMPOTENCY SERVICE - FIXED
// ===========================================
class IdempotencyService {
  final ProductionLogger _logger;
  final AppSecureStorage _secureStorage = AppSecureStorage.instance;
  final Map<String, Set<String>> _processedKeys = {};
  final Map<String, DateTime> _keyTimestamps = {};
  Timer? _cleanupTimer;
  Timer? _persistDebounceTimer;

  static const Duration _keyExpiry = Duration(hours: 24);
  static const Duration _cleanupInterval = Duration(hours: 1);
  static const Duration _persistDebounce = Duration(seconds: 2);
  bool _isInitialized = false;

  IdempotencyService({required ProductionLogger logger}) : _logger = logger;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _startCleanupTimer();
    await _loadPersistedKeys();
    _isInitialized = true;
    _logger.i('Idempotency service initialized');
  }

  void _startCleanupTimer() {
    _cleanupTimer = Timer.periodic(_cleanupInterval, (timer) {
      _cleanupExpiredKeys();
    });
  }

  Future<void> _loadPersistedKeys() async {
    try {
      final keysJson = await _secureStorage.read(key: 'idempotency_keys');
      if (keysJson != null) {
        final decoded = jsonDecode(keysJson) as Map<String, dynamic>;
        decoded.forEach((key, timestamp) {
          final date = DateTime.parse(timestamp as String);
          if (DateTime.now().difference(date) < _keyExpiry) {
            final parts = key.split(':');
            if (parts.length == 2) {
              final userId = parts[0];
              final operationKey = parts[1];
              if (!_processedKeys.containsKey(userId)) {
                _processedKeys[userId] = {};
              }
              _processedKeys[userId]!.add(operationKey);
              _keyTimestamps['$userId:$operationKey'] = date;
            }
          }
        });
      }
    } catch (e, stack) {
      _logger.d('Failed to load persisted keys', error: e, stackTrace: stack);
    }
  }

  Future<void> _persistKeys() async {
    try {
      final now = DateTime.now();
      final toPersist = <String, String>{};
      
      _keyTimestamps.forEach((key, timestamp) {
        if (now.difference(timestamp) < _keyExpiry) {
          toPersist[key] = timestamp.toIso8601String();
        }
      });

      await _secureStorage.write(
        key: 'idempotency_keys',
        value: jsonEncode(toPersist),
      );
    } catch (e, stack) {
      _logger.d('Failed to persist keys', error: e, stackTrace: stack);
    }
  }

  void _cleanupExpiredKeys() {
    final now = DateTime.now();
    _keyTimestamps.removeWhere((key, timestamp) {
      final expired = now.difference(timestamp) > _keyExpiry;
      if (expired) {
        final parts = key.split(':');
        if (parts.length == 2) {
          final userId = parts[0];
          final operationKey = parts[1];
          _processedKeys[userId]?.remove(operationKey);
          if (_processedKeys[userId]?.isEmpty ?? false) {
            _processedKeys.remove(userId);
          }
        }
      }
      return expired;
    });
    _debouncePersist();
  }

  String generateKey({
    required String userId,
    required String operation,
    required String entity,
    required String entityId,
  }) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random.secure().nextInt(1000000);
    final rawKey = '$userId:$operation:$entity:$entityId:$timestamp:$random';
    return sha256.convert(utf8.encode(rawKey)).toString();
  }

  Future<bool> isProcessed(String userId, String operationKey) async {
    if (!_processedKeys.containsKey(userId)) {
      return false;
    }
    return _processedKeys[userId]!.contains(operationKey);
  }

  Future<void> markAsProcessed(String userId, String operationKey) async {
    if (!_processedKeys.containsKey(userId)) {
      _processedKeys[userId] = {};
    }
    _processedKeys[userId]!.add(operationKey);
    _keyTimestamps['$userId:$operationKey'] = DateTime.now();
    _debouncePersist();
    _logger.d('Marked as processed: $userId:$operationKey');
  }

  void _debouncePersist() {
    _persistDebounceTimer?.cancel();
    _persistDebounceTimer = Timer(_persistDebounce, () async {
      await _persistKeys();
    });
  }

  Future<bool> checkAndMark({
    required String userId,
    required String operation,
    required String entity,
    required String entityId,
    String? providedKey,
  }) async {
    final operationKey = providedKey ?? generateKey(
      userId: userId,
      operation: operation,
      entity: entity,
      entityId: entityId,
    );

    if (await isProcessed(userId, operationKey)) {
      _logger.w('Duplicate operation detected: $userId:$operationKey');
      return false;
    }

    await markAsProcessed(userId, operationKey);
    return true;
  }

  void dispose() {
    _cleanupTimer?.cancel();
    _persistDebounceTimer?.cancel();
    _processedKeys.clear();
    _keyTimestamps.clear();
  }
}

// ===========================================
// BACKGROUND SYNC ORCHESTRATOR - FIXED
// ===========================================
class BackgroundSyncOrchestrator {
  final ProductionLogger _logger;
  final DatabaseService _database;
  final ProductionConnectivityService _connectivity;
  final RateLimitingService _rateLimiter;
  final IdempotencyService _idempotency;
  Timer? _syncTimer;
  Timer? _retryTimer;
  Timer? _networkCheckTimer;
  VoidCallback? _connectivityListener;
  static const int _maxPendingQueueSize = 500;
  bool _isSyncing = false;
  static const int _maxRetryDelaySeconds = 300;
  static const int _baseRetryDelaySeconds = 5;
  static const int _batchSize = 50;
  static const Duration _syncInterval = Duration(minutes: 5);
  static const Duration _networkCheckInterval = Duration(seconds: 30);
  bool _isInitialized = false;
  bool _isDisposed = false;

  BackgroundSyncOrchestrator({
    required ProductionLogger logger,
    required DatabaseService database,
    required ProductionConnectivityService connectivity,
    required RateLimitingService rateLimiter,
    required IdempotencyService idempotency,
  }) : _logger = logger,
       _database = database,
       _connectivity = connectivity,
       _rateLimiter = rateLimiter,
       _idempotency = idempotency;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _startPeriodicSync();
      _startNetworkMonitoring();
      
      _isInitialized = true;
      _logger.i('Background Sync Orchestrator initialized');
    } catch (e, stack) {
      _logger.e('Failed to initialize Background Sync Orchestrator', error: e, stackTrace: stack);
    }
  }

  void _startPeriodicSync() {
    _syncTimer = Timer.periodic(_syncInterval, (timer) async {
      if (!_isDisposed && _connectivity.isConnected.value && !_isSyncing) {
        await syncPendingOperations();
      }
    });
  }

  void _startNetworkMonitoring() {
    _networkCheckTimer?.cancel();
    _networkCheckTimer = Timer.periodic(_networkCheckInterval, (timer) async {
      if (!_isDisposed && _connectivity.isConnected.value && !_isSyncing) {
        final pendingCount = await _getPendingCount();
        if (pendingCount > 0) {
          _logger.d('Network available with $pendingCount pending items, triggering sync');
          await syncPendingOperations();
        }
      }
    });

    _connectivityListener = () {
      if (!_isDisposed && _connectivity.isConnected.value && !_isSyncing) {
        _retryTimer?.cancel();
        _retryTimer = Timer(const Duration(seconds: 2), () async {
          final pendingCount = await _getPendingCount();
          if (pendingCount > 0) {
            _logger.d('Network reconnected with $pendingCount pending items, triggering sync');
            await syncPendingOperations();
          }
        });
      }
    };
    _connectivity.isConnected.addListener(_connectivityListener!);
  }

  Future<int> _getPendingCount() async {
    try {
      final pending = await _database.database.getPendingQueueItems();
      return pending.length;
    } catch (e) {
      return 0;
    }
  }

  Future<void> syncPendingOperations() async {
    if (_isSyncing || _isDisposed) return;
    
    _isSyncing = true;
    
    try {
      final pendingItems = await _database.database.getPendingQueueItems();
      
      if (pendingItems.isEmpty) {
        _isSyncing = false;
        return;
      }
      
      _logger.i('Starting sync of ${pendingItems.length} pending items');
      
      final batches = pendingItems.slices(_batchSize);
      int successCount = 0;
      int failureCount = 0;
      
      for (var i = 0; i < batches.length; i++) {
        final batch = batches[i];
        _logger.d('Processing batch ${i + 1}/${batches.length} with ${batch.length} items');
        
        final results = await Future.wait(
          batch.map((item) => _processQueueItem(item)),
          eagerError: false,
        );
        
        successCount += results.where((r) => r).length;
        failureCount += results.where((r) => !r).length;
        
        // Brief yield between batches to keep event loop responsive
        if (i < batches.length - 1) {
          await Future.delayed(Duration.zero);
        }
      }
      
      _logger.i('Sync completed: $successCount succeeded, $failureCount failed');
      
      if (failureCount > 0) {
        _scheduleRetry();
      }
      
    } catch (e, stack) {
      _logger.e('Batch sync failed', error: e, stackTrace: stack);
      _scheduleRetry();
    } finally {
      _isSyncing = false;
    }
  }

  Future<bool> _processQueueItem(LocalOfflineQueue item) async {
    try {
      final canProcess = await _idempotency.checkAndMark(
        userId: item.userId,
        operation: item.operation,
        entity: item.entity,
        entityId: item.entityId,
        providedKey: item.idempotencyKey,
      );

      if (!canProcess) {
        await _database.database.markQueueItemAsProcessed(item.id);
        _logger.d('Skipped duplicate item ${item.id}');
        return true;
      }

      switch (item.operation) {
        case 'send_message':
          final data = jsonDecode(item.data);
          final apiService = await _getApiService();
          await apiService.sendChatMessage(
            sessionId: data['sessionId'],
            message: data['message'],
            userId: item.userId,
            plan: data['plan'],
            deepResearch: data['deepResearch'] ?? false,
            attachments: data['attachments'],
          );
          try {
            final sessionId = data['sessionId'] as String?;
            if (sessionId != null && sessionId.isNotEmpty) {
              final dbInstance = _database.database;
              await (dbInstance.update(dbInstance.localChatSessions)
                ..where((tbl) => tbl.serverId.equals(sessionId)))
                .write(LocalChatSessionsCompanion(
                  updatedAt: drift.Value(DateTime.now()),
                  isSynced: const drift.Value(true),
                ));
            }
          } catch (sessionUpdateErr) {
            _logger.d('[Sync] Session update after send_message failed (non-fatal)', error: sessionUpdateErr);
          }
          break;
        case 'generate_image':
          final data = jsonDecode(item.data);
          final apiService = await _getApiService();
          await apiService.generateImage(
            prompt: data['prompt'],
            userId: item.userId,
            plan: data['plan'],
            style: data['style'],
            size: data['size'],
          );
          break;
        case 'upload_file':
          final data = jsonDecode(item.data);
          final apiService = await _getApiService();
          final file = File(data['path']);
          await apiService.uploadFile(
            file: file,
            userId: item.userId,
            fileType: data['fileType'],
          );
          break;
        default:
          _logger.w('Unknown operation: ${item.operation}');
      }

      await _database.database.markQueueItemAsProcessed(item.id);
      _logger.d('Processed item ${item.id}');
      return true;
      
    } catch (e) {
      final currentRetryCount = item.retryCount + 1;
      final delaySeconds = _calculateRetryDelay(currentRetryCount);
      final nextRetryAt = DateTime.now().add(Duration(seconds: delaySeconds));
      
      await (_database.database.update(_database.database.localOfflineQueue)
        ..where((tbl) => tbl.id.equals(item.id))).write(
          LocalOfflineQueueCompanion(
            retryCount: drift.Value(currentRetryCount),
            nextRetryAt: drift.Value(nextRetryAt),
            errorMessage: drift.Value(e.toString()),
          ),
        );
      
      _logger.w('Item ${item.id} failed (retry $currentRetryCount): $e');
      return false;
    }
  }
  
  Future<ProductionApiService> _getApiService() async {
    final encryption = ProductionEncryptionService(logger: _logger);
    await encryption.initialize();
    final webSocket = WebSocketService(logger: _logger);
    await webSocket.initialize();
    
    return ProductionApiService(
      _logger,
      encryption,
      _connectivity,
      _rateLimiter,
      webSocket,
    );
  }

  int _calculateRetryDelay(int retryCount) {
    if (retryCount <= 1) return _baseRetryDelaySeconds;
    final exponentialDelay = _baseRetryDelaySeconds * pow(2, retryCount - 1).toInt();
    return min(exponentialDelay, _maxRetryDelaySeconds);
  }

  void _scheduleRetry() {
    _retryTimer?.cancel();
    _retryTimer = Timer(const Duration(minutes: 1), () async {
      if (!_isDisposed && _connectivity.isConnected.value && !_isSyncing) {
        _logger.d('Executing scheduled retry');
        await syncPendingOperations();
      }
    });
  }

  Future<void> triggerImmediateSync() async {
    if (!_isDisposed && _connectivity.isConnected.value) {
      _retryTimer?.cancel();
      await syncPendingOperations();
    } else {
      _logger.w('Cannot sync: no network connection');
    }
  }

  void dispose() {
    _isDisposed = true;
    if (_connectivityListener != null) {
      _connectivity.isConnected.removeListener(_connectivityListener!);
      _connectivityListener = null;
    }
    _syncTimer?.cancel();
    _syncTimer = null;
    _retryTimer?.cancel();
    _retryTimer = null;
    _networkCheckTimer?.cancel();
    _networkCheckTimer = null;
    _isSyncing = false;
    _logger.d('Background Sync Orchestrator disposed');
  }
}

// ===========================================
// FIREBASE REMOTE CONFIG SERVICE - FIXED
// ===========================================
class RemoteConfigService {
  final ProductionLogger _logger;
  final RemoteConfig _remoteConfig = RemoteConfig.instance;
  final ValueNotifier<bool> _isInitialized = ValueNotifier<bool>(false);
  final ValueNotifier<Map<String, dynamic>> _configValues = ValueNotifier<Map<String, dynamic>>({});
  bool _isDisposed = false;

  ValueNotifier<bool> get isInitialized => _isInitialized;
  ValueNotifier<Map<String, dynamic>> get configValues => _configValues;

  RemoteConfigService({required ProductionLogger logger}) : _logger = logger;

  Future<void> initialize() async {
    try {
      await _remoteConfig.setDefaults({
        'min_app_version': '1.0.0',
        'force_update': false,
        'maintenance_mode': false,
        'maintenance_message': 'Under maintenance',
        'maintenance_whitelist': '[]',
        'api_base_url': 'https://api.askroa-ai.com',
        'sentry_dsn': '',
        'environment': 'production',
        'websocket_url': 'wss://ws.askroa-ai.com',
        'wake_word_detection_url': 'wss://wake.askroa-ai.com',
        'free_daily_messages': '5',
        'free_daily_images': '5',
        'free_daily_videos': '5',
        'free_new_chat_limit': '3',
        'premium_monthly_price': '25.0',
        'premium_half_year_price': '90.0',
        'premium_yearly_price': '510.0',
        'wake_word_enabled': true,
        'voice_commands_enabled': true,
        'content_policy_url': 'https://askroa-ai.com/content-policy',
        'data_safety_url': 'https://askroa-ai.com/data-safety',
        'ai_models_list': '["gpt-4o","gpt-4o-mini","claude-3-5-sonnet","gemini-1.5-pro"]',
        'ab_test_onboarding': 'control',
        'ab_test_chat_ui': 'control',
        'feature_image_gen': true,
        'feature_voice': true,
        'feature_web_search': true,
        'certificate_pin_primary': '',
        'certificate_pin_backup': '',
      });

      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: kReleaseMode ? const Duration(hours: 1) : const Duration(minutes: 5),
      ));

      await _fetchAndActivate();
      _isInitialized.value = true;

      _logger.i('Remote Config initialized');
    } catch (e, stack) {
      _logger.e('Failed to initialize Remote Config', error: e, stackTrace: stack);
    }
  }

  Future<void> _fetchAndActivate() async {
    try {
      await _remoteConfig.fetchAndActivate();
      final values = <String, dynamic>{};
      final allKeys = _remoteConfig.getAll();

      for (var key in allKeys.keys) {
        final value = allKeys[key];
        if (value is String) {
          values[key] = _remoteConfig.getString(key);
        } else if (value is bool) {
          values[key] = _remoteConfig.getBool(key);
        } else if (value is int) {
          values[key] = _remoteConfig.getInt(key);
        } else if (value is double) {
          values[key] = _remoteConfig.getDouble(key);
        }
      }

      _configValues.value = values;
      _logger.i('Remote Config fetched and activated');
    } catch (e, stack) {
      _logger.d('Remote Config fetch failed', error: e, stackTrace: stack);
    }
  }

  String getString(String key, {String defaultValue = ''}) {
    try {
      return _remoteConfig.getString(key);
    } catch (_) {
      return defaultValue;
    }
  }

  bool getBool(String key, {bool defaultValue = false}) {
    try {
      return _remoteConfig.getBool(key);
    } catch (_) {
      return defaultValue;
    }
  }

  int getInt(String key, {int defaultValue = 0}) {
    try {
      return _remoteConfig.getInt(key);
    } catch (_) {
      return defaultValue;
    }
  }

  double getDouble(String key, {double defaultValue = 0.0}) {
    try {
      return _remoteConfig.getDouble(key);
    } catch (_) {
      return defaultValue;
    }
  }

  Future<void> refresh() async {
    await _fetchAndActivate();
  }

  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    try { _isInitialized.dispose(); } catch (_) {}
    try { _configValues.dispose(); } catch (_) {}
  }
}

// ===========================================
// FIREBASE MESSAGING SERVICE - FIXED
// ===========================================
class FirebaseMessagingService {
  final ProductionLogger _logger;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final ValueNotifier<RemoteMessage?> _lastMessage = ValueNotifier<RemoteMessage?>(null);
  GlobalKey<NavigatorState>? _navigatorKey;
  StreamSubscription<RemoteMessage>? _foregroundSub;
  StreamSubscription<RemoteMessage>? _backgroundSub;
  StreamSubscription<String>? _tokenRefreshSub;

  ValueNotifier<RemoteMessage?> get lastMessage => _lastMessage;

  void setNavigatorKey(GlobalKey<NavigatorState> key) {
    _navigatorKey = key;
  }

  FirebaseMessagingService({required ProductionLogger logger}) : _logger = logger;

  Future<void> initialize() async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      _logger.d('Firebase Messaging not available on this platform');
      return;
    }
    
    try {
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings();
      const settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );
      
      await _notifications.initialize(settings);

      final settings2 = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      _logger.d('Notification permission: ${settings2.authorizationStatus}');

      final token = await _messaging.getToken();
      if (token != null) {
        _logger.d('FCM Token acquired');
        await _sendTokenToServer(token);
      }

      _foregroundSub = FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      _backgroundSub = FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleBackgroundMessage(initialMessage);
      }

      _tokenRefreshSub = _messaging.onTokenRefresh.listen((newToken) {
        if (newToken.isNotEmpty) {
          _logger.d('FCM Token refreshed');
          _sendTokenToServer(newToken);
        }
      }, onError: (e) {
        _logger.w('FCM token refresh stream error', error: e);
      });
      
      _logger.i('Firebase Messaging initialized');
    } catch (e, stack) {
      _logger.e('Failed to initialize Firebase Messaging', error: e, stackTrace: stack);
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    _logger.d('Foreground message received');
    final payloadSize = jsonEncode(message.data).length;
    if (payloadSize > 4000) {
      _logger.w('[FCM] Payload size ${payloadSize}B exceeds 4KB limit');
    }
    _lastMessage.value = message;
    _showLocalNotification(message);
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    _logger.d('Background message received');
    _lastMessage.value = message;
    _handleMessageNavigation(message);
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    if (message.notification != null) {
      const androidDetails = AndroidNotificationDetails(
        'askroa_channel',
        'Askroa AI',
        channelDescription: 'AI Assistant Notifications',
        importance: Importance.high,
        priority: Priority.high,
        ticker: 'ticker',
      );
      
      const iosDetails = DarwinNotificationDetails();
      
      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      
      await _notifications.show(
        message.hashCode,
        message.notification!.title,
        message.notification!.body,
        details,
      );
    }
  }

  void _handleMessageNavigation(RemoteMessage message) {
    final data = message.data;
    if (!data.containsKey('screen')) return;
    final screen = data['screen'] as String?;
    if (screen == null || screen.isEmpty) return;
    final context = _navigatorKey?.currentContext;
    if (context == null || !context.mounted) {
      Timer(const Duration(milliseconds: 500), () {
        final ctx = _navigatorKey?.currentContext;
        if (ctx != null && ctx.mounted) {
          _navigateToScreen(ctx, screen, data);
        }
      });
      return;
    }
    _navigateToScreen(context, screen, data);
  }

  void _navigateToScreen(BuildContext context, String screen, Map<String, dynamic> data) {
    try {
      final router = GoRouter.of(context);
      switch (screen) {
        case 'home':
          router.go('/home');
        case 'chat':
          final sessionId = data['session_id'] as String?;
          if (sessionId != null) {
            router.go('/home', extra: {'session_id': sessionId});
          } else {
            router.go('/home');
          }
        case 'premium':
          router.push('/premium');
        case 'settings':
          router.push('/settings');
        case 'voice':
          router.push('/voice');
        default:
          if (screen.startsWith('/')) {
            router.push(screen);
          }
      }
      _logger.d('Notification navigation → $screen');
    } catch (e) {
      _logger.w('Notification navigation failed', error: e);
    }
  }

  Future<void> _sendTokenToServer(String token) async {
    try {
    final secureStorage = AppSecureStorage.instance;
      final encryptedToken = await secureStorage.read(key: 'askroa_access_token');

      if (encryptedToken != null) {
        final encryption = ProductionEncryptionService(logger: _logger);
        await encryption.initialize();
        final authToken = await encryption.decrypt(encryptedToken);

        if (authToken != '[DECRYPTION_FAILED]') {
          final envConfig = EnvironmentConfig();
          final response = await http.post(
            Uri.parse('${envConfig.backendBaseUrl}/notifications/register-token'),
            headers: {
              'Authorization': 'Bearer $authToken',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'token': token,
              'platform': kIsWeb ? 'web' : Platform.operatingSystem,
              'timestamp': DateTime.now().toIso8601String(),
            }),
          ).timeout(const Duration(seconds: 10));

          if (response.statusCode == 200) {
            _logger.d('FCM token sent to server');
          }
        }
      }
    } catch (e, stack) {
      _logger.d('Send token to server failed', error: e, stackTrace: stack);
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      _logger.d('Subscribed to topic: $topic');
    } catch (e, stack) {
      _logger.d('Subscribe to topic failed', error: e, stackTrace: stack);
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      _logger.d('Unsubscribed from topic: $topic');
    } catch (e, stack) {
      _logger.d('Unsubscribe from topic failed', error: e, stackTrace: stack);
    }
  }

  void dispose() {
    _foregroundSub?.cancel();
    _backgroundSub?.cancel();
    _tokenRefreshSub?.cancel();
    _lastMessage.dispose();
    _navigatorKey = null;
    _logger.d('FirebaseMessagingService disposed');
  }
}

// ===========================================
// FIXED: IN-APP PURCHASE SERVICE WITH COMPLETE IMPLEMENTATION
// ===========================================
class InAppPurchaseService {
  final ProductionLogger _logger;
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  final List<ProductDetails> _products = [];
  final List<PurchaseDetails> _purchases = [];
  final ValueNotifier<bool> _isAvailable = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isLoading = ValueNotifier<bool>(false);
  bool _isInitialized = false;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  final List<PurchaseDetails> _verificationQueue = [];
  final Map<String, int> _verificationRetryCount = [];
  static const int _maxVerificationRetries = 5;
  Timer? _queueRetryTimer;
  bool _isProcessingQueue = false;

  ValueNotifier<bool> get isAvailable => _isAvailable;
  ValueNotifier<bool> get isLoading => _isLoading;

  InAppPurchaseService({required ProductionLogger logger}) : _logger = logger;

  Future<void> initialize() async {
    if (!IAPConfig.isSupported) {
      _logger.d('In-app purchases not supported on this platform');
      _isAvailable.value = false;
      return;
    }
    
    try {
      final bool isAvailable = await _inAppPurchase.isAvailable();
      _isAvailable.value = isAvailable;

      if (!isAvailable) {
        _logger.w('In-app purchases not available');
        return;
      }

      _purchaseSubscription = _inAppPurchase.purchaseStream.listen(_listenToPurchaseUpdated);

      await _loadProducts();
      await _restorePurchases();

      _isInitialized = true;
      _logger.i('In-app purchase service initialized');
    } catch (e, stack) {
      _logger.e('Failed to initialize in-app purchase', error: e, stackTrace: stack);
      _isAvailable.value = false;
    }
  }

  Future<void> _loadProducts() async {
    try {
      _isLoading.value = true;

      final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(IAPConfig.productIds);

      if (response.notFoundIDs.isNotEmpty) {
        _logger.w('Products not found: ${response.notFoundIDs}');
      }

      _products.clear();
      _products.addAll(response.productDetails);

      _logger.i('Loaded ${_products.length} products');
    } catch (e, stack) {
      _logger.e('Failed to load products', error: e, stackTrace: stack);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _restorePurchases() async {
    try {
      final QueryPurchaseDetailsResponse response = await _inAppPurchase.queryPastPurchases();
      final seen = <String>{};
      for (var purchase in response.pastPurchases) {
        final key = '${purchase.productID}_${purchase.purchaseID}';
        if (seen.contains(key)) continue;
        seen.add(key);
        if (purchase.status == PurchaseStatus.restored) {
          await _verifyPurchase(purchase);
        }
      }
      _logger.i('Restored ${seen.length} unique purchases');
    } catch (e, stack) {
      _logger.e('Failed to restore purchases', error: e, stackTrace: stack);
    }
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchaseDetails in purchaseDetailsList) {
      _handlePurchase(purchaseDetails);
    }
  }

  Future<void> _handlePurchase(PurchaseDetails purchaseDetails) async {
    try {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        _logger.d('Purchase pending');
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        _logger.e('Purchase error', error: purchaseDetails.error);
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        final verified = await _verifyPurchase(purchaseDetails);
        if (verified) {
          await _deliverProduct(purchaseDetails);
        } else {
          _enqueueForRetry(purchaseDetails);
        }
      }

      if (purchaseDetails.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchaseDetails);
      }
    } catch (e, stack) {
      _logger.e('Failed to handle purchase', error: e, stackTrace: stack);
      _enqueueForRetry(purchaseDetails);
    }
  }

  void _enqueueForRetry(PurchaseDetails purchase) {
    final key = '${purchase.productID}_${purchase.purchaseID}';
    final retries = (_verificationRetryCount[key] ?? 0) + 1;
    if (retries > _maxVerificationRetries) {
      _logger.e('[IAP] Max retries ($retries) for ${purchase.productID} — dropped');
      _verificationRetryCount.remove(key);
      return;
    }
    _verificationRetryCount[key] = retries;
    final alreadyQueued = _verificationQueue.any((p) =>
        p.purchaseID == purchase.purchaseID && p.productID == purchase.productID);
    if (!alreadyQueued) {
      _verificationQueue.add(purchase);
      _logger.w('[IAP] Queued retry $retries/$_maxVerificationRetries: ${purchase.productID}');
    }
    _queueRetryTimer?.cancel();
    _queueRetryTimer = Timer(const Duration(minutes: 2), _processVerificationQueue);
  }

  Future<void> _processVerificationQueue() async {
    if (_isProcessingQueue || _verificationQueue.isEmpty) return;
    _isProcessingQueue = true;
    final pending = List<PurchaseDetails>.from(_verificationQueue);
    _verificationQueue.clear();
    for (final purchase in pending) {
      try {
        final verified = await _verifyPurchase(purchase);
        if (verified) {
          await _deliverProduct(purchase);
          if (purchase.pendingCompletePurchase) {
            await _inAppPurchase.completePurchase(purchase);
          }
          _logger.i('[IAP] Queued purchase verified: ${purchase.productID}');
        } else {
          _verificationQueue.add(purchase);
        }
      } catch (e) {
        _verificationQueue.add(purchase);
        _logger.w('[IAP] Queue retry failed for ${purchase.productID}', error: e);
      }
    }
    _isProcessingQueue = false;
    if (_verificationQueue.isNotEmpty) {
      _queueRetryTimer = Timer(const Duration(minutes: 5), _processVerificationQueue);
    }
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
  final secureStorage = AppSecureStorage.instance;
    try {
      final encryptedToken = await secureStorage.read(key: 'askroa_access_token');
      if (encryptedToken == null) {
        _logger.w('[IAP] User not authenticated during purchase verification');
        throw Exception('User not authenticated');
      }

      final encryption = ProductionEncryptionService(logger: _logger);
      await encryption.initialize();
      final token = await encryption.decrypt(encryptedToken);
      if (token == '[DECRYPTION_FAILED]') {
        _logger.w('[IAP] Token decryption failed during purchase verification');
        throw Exception('Authentication failed');
      }

      final envConfig = EnvironmentConfig();

      final serverToken = purchaseDetails.verificationData.serverVerificationData;
      final localToken  = purchaseDetails.verificationData.localVerificationData;

      final purchaseData = {
        'product_id':               purchaseDetails.productID,
        'purchase_id':              purchaseDetails.purchaseID ?? '',
        'server_verification_data': serverToken,
        'local_verification_data':  localToken,
        'platform':                 kIsWeb ? 'web' : Platform.operatingSystem,
        'timestamp':                DateTime.now().toIso8601String(),
        'idempotency_key': purchaseDetails.purchaseID ??
            '${purchaseDetails.productID}_${DateTime.now().millisecondsSinceEpoch}',
      };

      int attempt = 0;
      const maxAttempts = 3;
      while (attempt < maxAttempts) {
        attempt++;
        try {
          final response = await http.post(
            Uri.parse('${envConfig.backendBaseUrl}/subscription/verify-purchase'),
            headers: {
              'Authorization':   'Bearer $token',
              'Content-Type':    'application/json',
              'Idempotency-Key': purchaseData['idempotency_key'] as String,
            },
            body: jsonEncode(purchaseData),
          ).timeout(const Duration(seconds: 15));

          if (response.statusCode == 200) {
            final responseData = jsonDecode(response.body) as Map<String, dynamic>;
            final verified = responseData['verified'] == true;
            if (verified) {
              _logger.i('[IAP] Purchase verified server-side: ${purchaseDetails.productID}');
            } else {
              _logger.w('[IAP] Server rejected purchase: ${purchaseDetails.productID}');
            }
            return verified;
          } else if (response.statusCode == 409) {
            _logger.i('[IAP] Purchase already processed (idempotent): ${purchaseDetails.productID}');
            return true;
          } else if (response.statusCode >= 500 && attempt < maxAttempts) {
            await Future.delayed(Duration(seconds: pow(2, attempt).toInt()));
            continue;
          } else {
            _logger.w('[IAP] Verification failed HTTP ${response.statusCode}: ${purchaseDetails.productID}');
            return false;
          }
        } on TimeoutException {
          if (attempt < maxAttempts) {
            await Future.delayed(Duration(seconds: pow(2, attempt).toInt()));
            continue;
          }
          _logger.w('[IAP] Verification timed out after $maxAttempts attempts');
          return false;
        }
      }
      return false;
    } catch (e, stack) {
      _logger.e('[IAP] Purchase verification error', error: e, stackTrace: stack);
      return false;
    }
  }

  Future<void> _deliverProduct(PurchaseDetails purchaseDetails) async {
  final secureStorage = AppSecureStorage.instance;
    try {
      final productId = purchaseDetails.productID;

      final encryptedAccessToken = await secureStorage.read(key: 'askroa_access_token');
      if (encryptedAccessToken == null) {
        _logger.e('[IAP] Cannot deliver: no auth token');
        return;
      }

      final encryption = ProductionEncryptionService(logger: _logger);
      await encryption.initialize();
      final token = await encryption.decrypt(encryptedAccessToken);
      if (token == '[DECRYPTION_FAILED]') {
        _logger.e('[IAP] Cannot deliver: token decryption failed');
        return;
      }

      final serverConfirmed = await _confirmDeliveryWithServer(token, purchaseDetails);
      if (!serverConfirmed) {
        _logger.w('[IAP] Server did not confirm delivery for $productId — skipping local update');
        return;
      }

      final userData = await secureStorage.read(key: 'askroa_user_data');
      if (userData != null) {
        final decrypted = await encryption.decrypt(userData);
        if (decrypted != '[DECRYPTION_FAILED]') {
          final userJson = jsonDecode(decrypted) as Map<String, dynamic>;
          String plan = 'free';
          if (productId.contains('monthly'))   plan = 'monthly';
          else if (productId.contains('half_year')) plan = 'half_year';
          else if (productId.contains('yearly'))    plan = 'yearly';

          userJson['plan'] = plan;
          userJson['subscription_expiry'] = DateTime.now().add(const Duration(days: 30)).toIso8601String();
          await secureStorage.write(key: 'askroa_user_data', value: encryption.encrypt(jsonEncode(userJson)));
          _logger.i('[IAP] Local state updated: $productId → $plan');
        }
      }
    } catch (e, stack) {
      _logger.e('[IAP] Failed to deliver product', error: e, stackTrace: stack);
    }
  }

  Future<bool> _confirmDeliveryWithServer(String token, PurchaseDetails purchase) async {
    try {
      final env = EnvironmentConfig();
      final res = await http.post(
        Uri.parse('${env.backendBaseUrl}/subscription/confirm-delivery'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'product_id':               purchase.productID,
          'purchase_id':              purchase.purchaseID ?? '',
          'server_verification_data': purchase.verificationData.serverVerificationData,
          'platform':                 kIsWeb ? 'web' : Platform.operatingSystem,
          'timestamp':                DateTime.now().toUtc().toIso8601String(),
        }),
      ).timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        return body['confirmed'] == true;
      }
      _logger.w('[IAP] Server confirm-delivery returned ${res.statusCode}');
      return false;
    } catch (e) {
      _logger.e('[IAP] _confirmDeliveryWithServer failed', error: e);
      return false;
    }
  }
  
  Future<void> _syncSubscriptionWithServer(String token, String plan) async {
    try {
      final envConfig = EnvironmentConfig();
      final response = await http.post(
        Uri.parse('${envConfig.backendBaseUrl}/subscription/sync'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'plan': plan,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        _logger.d('Subscription synced with server');
      }
    } catch (e, stack) {
      _logger.d('Subscription sync failed', error: e, stackTrace: stack);
    }
  }

  Future<void> purchaseProduct(String productId) async {
    try {
      if (!_isInitialized) {
        throw Exception('IAP service not initialized');
      }
      
      final product = _products.firstWhere(
        (p) => p.id == productId,
        orElse: () => throw Exception('Product not found'),
      );

      final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
      await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);

      _logger.i('Purchase started for: $productId');
    } catch (e, stack) {
      _logger.e('Purchase failed', error: e, stackTrace: stack);
      rethrow;
    }
  }

  List<ProductDetails> getProducts() => _products;

  ProductDetails? getProduct(String productId) {
    try {
      return _products.firstWhere((p) => p.id == productId);
    } catch (_) {
      return null;
    }
  }

  void dispose() {
    _purchaseSubscription?.cancel();
    _queueRetryTimer?.cancel();
    _verificationQueue.clear();
    _verificationRetryCount.clear();
    _isAvailable.dispose();
    _isLoading.dispose();
    _isInitialized = false;
  }
}

// ===========================================
// SYNC CONFLICT RESOLUTION
// ===========================================
enum ConflictResolutionStrategy {
  serverWins,
  clientWins,
  lastWriteWins,
  merge,
}

class SyncConflictResolver {
  final ProductionLogger _logger;

  SyncConflictResolver({required ProductionLogger logger}) : _logger = logger;

  ConflictResolutionStrategy resolveConflict({
    required String entity,
    required Map<String, dynamic> serverData,
    required Map<String, dynamic> clientData,
    required DateTime serverTimestamp,
    required DateTime clientTimestamp,
    String? userId,
  }) {
    _logger.d('Resolving conflict for $entity');

    switch (entity) {
      case 'user':
        return ConflictResolutionStrategy.serverWins;
      case 'chat_message':
        return ConflictResolutionStrategy.lastWriteWins;
      case 'chat_session':
        return ConflictResolutionStrategy.merge;
      case 'image_history':
        return ConflictResolutionStrategy.serverWins;
      default:
        return serverTimestamp.isAfter(clientTimestamp)
            ? ConflictResolutionStrategy.serverWins
            : ConflictResolutionStrategy.clientWins;
    }
  }

  Map<String, dynamic> mergeData({
    required String entity,
    required Map<String, dynamic> serverData,
    required Map<String, dynamic> clientData,
  }) {
    _logger.d('Merging data for $entity');

    switch (entity) {
      case 'chat_session':
        return {
          ...serverData,
          'is_pinned': serverData['is_pinned'] ?? clientData['is_pinned'] ?? false,
          'title': clientData['title'] ?? serverData['title'],
          'updated_at': DateTime.now().toIso8601String(),
        };
      default:
        return serverData;
    }
  }

  Map<String, dynamic> applyResolution({
    required ConflictResolutionStrategy strategy,
    required Map<String, dynamic> serverData,
    required Map<String, dynamic> clientData,
    required DateTime serverTimestamp,
    required DateTime clientTimestamp,
    String? entity,
  }) {
    switch (strategy) {
      case ConflictResolutionStrategy.serverWins:
        _logger.d('Server wins conflict resolution');
        return serverData;
      case ConflictResolutionStrategy.clientWins:
        _logger.d('Client wins conflict resolution');
        return clientData;
      case ConflictResolutionStrategy.lastWriteWins:
        final result = serverTimestamp.isAfter(clientTimestamp) ? serverData : clientData;
        _logger.d('Last write wins: ${serverTimestamp.isAfter(clientTimestamp) ? "server" : "client"}');
        return result;
      case ConflictResolutionStrategy.merge:
        if (entity == null) return serverData;
        return mergeData(entity: entity, serverData: serverData, clientData: clientData);
    }
  }
}

// ===========================================
// FIXED: CRASH RECOVERY WITH PROPER HANDLING
// ===========================================
class GlobalCrashRecovery {
  final ProductionLogger _logger;
  final Map<String, dynamic> _recoveryState = {};
  final AppSecureStorage _secureStorage = AppSecureStorage.instance;
  bool _isInitialized = false;

  GlobalCrashRecovery({required ProductionLogger logger}) : _logger = logger;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    final envConfig = EnvironmentConfig();
    
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      try {
        await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
        FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
      } catch (e) {
        _logger.d('Firebase Crashlytics initialization failed', error: e);
      }
    }

    // Sentry already initialized in main() — skip to avoid double-init crash
    
    await _setCrashlyticsUserIdentifier();

    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      try {
        await Workmanager().initialize(
          callbackDispatcher,
          isInDebugMode: kDebugMode,
        );

        await Workmanager().registerPeriodicTask(
          'recovery_cleanup',
          'recovery_cleanup_task',
          frequency: const Duration(hours: 24),
          constraints: Constraints(
            networkType: NetworkType.connected,
            requiresBatteryNotLow: false,
            requiresCharging: false,
            requiresDeviceIdle: false,
            requiresStorageNotLow: false,
          ),
        );

        await Workmanager().registerPeriodicTask(
          'daily_reset',
          'daily_reset_task',
          frequency: const Duration(hours: 24),
          initialDelay: _getTimeUntilMidnightLocal(),
        );

        await Workmanager().registerPeriodicTask(
          'offline_sync',
          'sync_offline_messages',
          frequency: const Duration(minutes: 15),
          constraints: Constraints(
            networkType: NetworkType.connected,
            requiresBatteryNotLow: true,
          ),
        );
        
        await Workmanager().registerPeriodicTask(
          'database_vacuum',
          'database_vacuum_task',
          frequency: const Duration(days: 7),
          constraints: Constraints(
            networkType: NetworkType.connected,
            requiresBatteryNotLow: true,
            requiresCharging: true,
          ),
        );
      } catch (e) {
        _logger.d('Workmanager initialization failed', error: e);
      }
    }

    await _loadRecoveryState();
    
    _isInitialized = true;
    _logger.i('Crash recovery initialized');
  }

  Duration _getTimeUntilMidnightLocal() {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    return midnight.difference(now);
  }

  Future<void> _setCrashlyticsUserIdentifier() async {
  final secureStorage = AppSecureStorage.instance;
    try {
      if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return;

      final encryptedUserData = await secureStorage.read(key: 'askroa_user_data');
      
      if (encryptedUserData != null) {
        final encryption = ProductionEncryptionService(logger: _logger);
        await encryption.initialize();
        final decrypted = await encryption.decrypt(encryptedUserData);
        
        if (decrypted != '[DECRYPTION_FAILED]') {
          final userJson = jsonDecode(decrypted) as Map<String, dynamic>;
          
          final userId = userJson['id'] as String? ?? 'unknown';
          final email = userJson['email'] as String? ?? '';
          final plan = userJson['plan'] as String? ?? 'free';

          await FirebaseCrashlytics.instance.setUserIdentifier(userId);
          if (email.isNotEmpty) {
            final emailHash = sha256.convert(utf8.encode(email)).toString().substring(0, 16);
            await FirebaseCrashlytics.instance.setCustomKey('email_hash', emailHash);
          }
          await FirebaseCrashlytics.instance.setCustomKey('plan', plan);

          _logger.d('Crashlytics user identifier set');
        }
      }
    } catch (e) {
      _logger.d('Failed to set Crashlytics user identifier', error: e);
    }
  }



  Future<void> _performRecovery() async {
  final secureStorage = AppSecureStorage.instance;
    try {
      final userData = await secureStorage.read(key: 'askroa_user_data');
      if (userData != null) {
        _recoveryState['user_recovered'] = true;
        _recoveryState['recovery_time'] = DateTime.now().toIso8601String();
        _recoveryState['recovery_count'] = (_recoveryState['recovery_count'] ?? 0) + 1;

        if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
          try {
            await FirebaseCrashlytics.instance.setCustomKey(
                'recovery_count', _recoveryState['recovery_count']);
          } catch (_) {}
        }
      }

      final prefs = await SharedPreferences.getInstance();
      final sessionId = prefs.getString('askroa_session_id');
      if (sessionId != null) {
        _recoveryState['last_session_id'] = sessionId;
        _recoveryState['session_recovered'] = true;
      }

      final remainingRequests = prefs.getInt('askroa_remaining_requests');
      if (remainingRequests != null) {
        _recoveryState['remaining_requests'] = remainingRequests;
      }

      _recoveryState['recovery_complete'] = true;
      await _saveRecoveryState();
      _logger.i('Crash recovery performed: user=${_recoveryState['user_recovered']}, '
          'session=${_recoveryState['session_recovered']}');
    } catch (e, stack) {
      _logger.e('Recovery failed', error: e, stackTrace: stack);
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        try {
          await FirebaseCrashlytics.instance.recordError(e, stack, reason: 'Recovery failed');
        } catch (_) {}
      }
    }
  }

  Future<void> _syncOfflineMessages() async {
    try {
      final performance = PerformanceOptimizer(logger: _logger);
      final db = DatabaseService(logger: _logger, performance: performance);
      await db.initialize();
      
      final dbInstance = db.database;
      final unsyncedMessages = await (dbInstance.select(dbInstance.localChatMessages)
        ..where((tbl) => tbl.isSynced.equals(false))).get();
      
      if (unsyncedMessages.isNotEmpty) {
        _logger.i('Syncing ${unsyncedMessages.length} offline messages');
        
        final envConfig = EnvironmentConfig();
        final encryption = ProductionEncryptionService(logger: _logger);
        final connectivity = ProductionConnectivityService(logger: _logger);
        final rateLimiter = RateLimitingService(logger: _logger);
        final webSocket = WebSocketService(logger: _logger);
        
        final api = ProductionApiService(
          _logger,
          encryption,
          connectivity,
          rateLimiter,
          webSocket,
        );
        await api.initialize();
        
        for (var message in unsyncedMessages) {
          try {
            final parts = message.sessionId.split('_');
            final userId = parts.length > 1 ? parts[1] : message.sessionId;
                
            await api.sendChatMessage(
              sessionId: message.sessionId,
              message: message.text,
              userId: userId,
              plan: 'free',
            );
            await dbInstance.markMessageAsSynced(message.serverId);
          } catch (e) {
            await dbInstance.markMessageAsFailed(message.serverId, e.toString());
          }
        }
      }
    } catch (e, stack) {
      _logger.e('Offline sync failed', error: e, stackTrace: stack);
    }
  }

  Future<void> _performDailyReset() async {
  final secureStorage = AppSecureStorage.instance;
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastReset = prefs.getString('last_daily_reset');
      final today = DateTime.now().toIso8601String().substring(0, 10);

      if (lastReset != today) {
        final userData = await secureStorage.read(key: 'askroa_user_data');
        if (userData != null) {
          final encryption = ProductionEncryptionService(logger: _logger);
          await encryption.initialize();
          final decrypted = await encryption.decrypt(userData);

          if (decrypted != '[DECRYPTION_FAILED]') {
            final userJson = jsonDecode(decrypted) as Map<String, dynamic>;

            if (userJson['plan'] == 'free') {
              userJson['daily_requests'] = 0;
              final encrypted = encryption.encrypt(jsonEncode(userJson));
              await secureStorage.write(key: 'askroa_user_data', value: encrypted);
            }
          }
        }

        await prefs.setString('last_daily_reset', today);
        _logger.i('Daily reset performed');
      }
    } catch (e, stack) {
      _logger.e('Daily reset failed', error: e, stackTrace: stack);
    }
  }

  Future<void> _vacuumDatabase() async {
    try {
      final performance = PerformanceOptimizer(logger: _logger);
      final db = DatabaseService(logger: _logger, performance: performance);
      await db.initialize();
      await db.vacuum();
      _logger.i('Database vacuum completed');
    } catch (e, stack) {
      _logger.e('Database vacuum failed', error: e, stackTrace: stack);
    }
  }

  Future<void> _cleanupOldData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();

      await _secureStorage.delete(key: 'askroa_recovery_state');
      _recoveryState.clear();

      final tempDir = await getTemporaryDirectory();
      if (await tempDir.exists()) {
        final files = tempDir.listSync();
        for (var file in files) {
          try {
            if (file is File) {
              final stat = await file.stat();
              if (stat.modified.isBefore(now.subtract(const Duration(days: 7)))) {
                await file.delete();
              }
            }
          } catch (e) {
            _logger.d('Failed to delete temp file', error: e);
          }
        }
      }

      final performance = PerformanceOptimizer(logger: _logger);
      final db = DatabaseService(logger: _logger, performance: performance);
      await db.initialize();
      await db.cleanupOldData();

      final cache = ProductionCacheManager(logger: _logger, performance: performance);
      await cache.initialize();
      await cache.clearExpiredCache();

      _logger.i('Cleanup completed');
    } catch (e, stack) {
      _logger.e('Cleanup failed', error: e, stackTrace: stack);
    }
  }

  Future<void> saveState(String key, dynamic value) async {
    try {
      _recoveryState[key] = value;
      await _saveRecoveryState();
    } catch (e, stack) {
      _logger.e('Save state failed', error: e, stackTrace: stack);
    }
  }

  Future<dynamic> loadState(String key) async {
    try {
      await _loadRecoveryState();
      return _recoveryState[key];
    } catch (e) {
      return null;
    }
  }

  Future<void> _saveRecoveryState() async {
    try {
      final stateJson = jsonEncode(_recoveryState);
      await _secureStorage.write(key: 'askroa_recovery_state', value: stateJson);
    } catch (e) {
      _logger.d('Failed to save recovery state', error: e);
    }
  }

  Future<void> _loadRecoveryState() async {
    try {
      final stateJson = await _secureStorage.read(key: 'askroa_recovery_state');
      if (stateJson != null) {
        _recoveryState.clear();
        _recoveryState.addAll(jsonDecode(stateJson));
      }
    } catch (e) {
      _logger.d('Failed to load recovery state', error: e);
    }
  }

  Future<void> clearRecoveryState() async {
    try {
      _recoveryState.clear();
      await _secureStorage.delete(key: 'askroa_recovery_state');
    } catch (e) {
      _logger.d('Failed to clear recovery state', error: e);
    }
  }

  bool get isRecovering => _recoveryState['user_recovered'] == true;
  int get recoveryCount => _recoveryState['recovery_count'] ?? 0;
}

// ===========================================
// GLOBAL ERROR BOUNDARY - FIXED
// ===========================================
class GlobalErrorBoundary extends StatefulWidget {
  final Widget child;
  const GlobalErrorBoundary({super.key, required this.child});

  @override
  State<GlobalErrorBoundary> createState() => _GlobalErrorBoundaryState();
}

class _GlobalErrorBoundaryState extends State<GlobalErrorBoundary> {
  late final ProductionLogger _logger;
  late final GlobalUserHandler _userHandler;
  Widget? _errorWidget;
  bool _hasError = false;
  bool _isInitialized = false;
  int _recoveryAttempts = 0;
  static const int _maxRecoveryAttempts = 3;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
    _logger = ProductionLogger(isProduction: true);
    try {
      await _logger.initialize();
    } catch (e) {
      // logger init failed silently
    }
    _userHandler = GlobalUserHandler(logger: _logger);
    try {
      await _userHandler.initialize();
    } catch (e) {
      _logger.e('[GlobalErrorBoundary] UserHandler init failed', error: e);
    }
    
    FlutterError.onError = (FlutterErrorDetails details) {
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        try {
          FirebaseCrashlytics.instance.recordFlutterFatalError(details);
        } catch (e) {
          _logger.d('Crashlytics error', error: e);
        }
      }
      _handleError(details.exception, details.stack, 'flutter_error');
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        try {
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        } catch (e) {
          _logger.d('Crashlytics error', error: e);
        }
      }
      _handleError(error, stack, 'platform_error');
      return true;
    };

    Isolate.current.addErrorListener(RawReceivePort((pair) {
      final List<dynamic> errorAndStacktrace = pair as List<dynamic>;
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        try {
          FirebaseCrashlytics.instance.recordError(
            errorAndStacktrace.first,
            errorAndStacktrace.last as StackTrace?,
            fatal: true,
          );
        } catch (e) {
          _logger.d('Crashlytics error', error: e);
        }
      }
      _handleError(errorAndStacktrace.first, errorAndStacktrace.last, 'isolate_error');
    }).sendPort);
    
    } catch (e) {
      _logger.e('[GlobalErrorBoundary] Critical init error', error: e);
    } finally {
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      } else {
        _isInitialized = true;
      }
    }
  }

  void _handleError(Object error, StackTrace? stack, String source) {
    _logger.e('Global error caught', error: error, stackTrace: stack);

    if (!_hasError && mounted) {
      setState(() {
        _hasError = true;
        _errorWidget = _buildErrorUI(error, stack);
      });
    }
  }

  Widget _buildErrorUI(Object error, StackTrace? stack) {
    return Material(
      color: Colors.black,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Color(0xFFEA4335),
                  size: 80,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Something went wrong',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'We encountered an unexpected error. Please try again.',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: _performRecovery,
                  icon: const Icon(Icons.refresh),
                  label: const Text(
                    'Try Again',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066CC),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _navigateToLogin,
                  child: const Text(
                    'Go to Login',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _performRecovery() async {
    _recoveryAttempts++;
    if (_recoveryAttempts > _maxRecoveryAttempts) {
      _logger.e('[Recovery] Max recovery attempts ($_maxRecoveryAttempts) reached. Navigating to login.');
      if (context.mounted) {
        context.go('/login');
      }
      return;
    }

    setState(() {
      _hasError = false;
      _errorWidget = null;
    });
    
    try {
      await _userHandler.initialize();
      if (_userHandler.hasUser) {
        if (context.mounted) {
          _recoveryAttempts = 0;
          context.go('/home');
        }
      } else {
        if (context.mounted) {
          _recoveryAttempts = 0;
          context.go('/login');
        }
      }
    } catch (e) {
      _logger.e('[Recovery] Recovery attempt $_recoveryAttempts failed', error: e);
      if (context.mounted) {
        _recoveryAttempts = 0;
        context.go('/login');
      }
    }
  }

  void _navigateToLogin() {
    setState(() {
      _hasError = false;
      _errorWidget = null;
    });
    
    if (context.mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const SizedBox();
    }
    if (_hasError && _errorWidget != null) {
      return _errorWidget!;
    }
    return widget.child;
  }
}

// ===========================================
// FIXED: DEEP LINKING SERVICE WITH COMPLETE IMPLEMENTATION
// ===========================================


class _AppLinkData {
  final Uri link;
  _AppLinkData(this.link);
}
class DeepLinkingService {
  final ProductionLogger _logger;
  final AppLinks _appLinks = AppLinks();
  final ValueNotifier<Uri?> _initialLink = ValueNotifier<Uri?>(null);
  StreamSubscription<Uri>? _linkSubscription;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  ValueNotifier<Uri?> get initialLink => _initialLink;

  DeepLinkingService({required ProductionLogger logger}) : _logger = logger;

  Future<void> initialize() async {
    try {
      final initialUri = await _appLinks.getInitialAppLink();
      _initialLink.value = initialUri;
      if (initialUri != null) {
        _handleDeepLink(initialUri);
        _logger.d('Initial deep link: $initialUri');
      }

      _linkSubscription = _appLinks.uriLinkStream.listen(_handleDeepLink);
      
      _logger.i('Deep linking service initialized');
    } catch (e, stack) {
      _logger.e('Failed to initialize deep linking', error: e, stackTrace: stack);
    }
  }

  void _handleDeepLink(Uri link) {
    _logger.d('Deep link received: $link');
    
    if (link.path.contains('invite')) {
      final ref = link.queryParameters['ref'];
      if (ref != null) {
        _processInvite(ref);
      }
    } else if (link.path.contains('reset-password')) {
      final token = link.queryParameters['token'];
      if (token != null) {
        _processPasswordReset(token);
      }
    } else if (link.path.contains('verify-email')) {
      final token = link.queryParameters['token'];
      if (token != null) {
        _processEmailVerification(token);
      }
    }
  }

  static const int _maxDeepLinkRetries = 8;

  void _processInvite(String ref, [int attempt = 0]) {
    _logger.d('Processing invite: $ref (attempt $attempt)');
    final context = _navigatorKey.currentContext;
    if (context == null) {
      if (attempt >= _maxDeepLinkRetries) { _logger.w('[DeepLink] invite: context timeout, giving up'); return; }
      Timer(const Duration(milliseconds: 500), () => _processInvite(ref, attempt + 1));
      return;
    }
    GoRouter.of(context).go('/invite/$ref');
  }

  void _processPasswordReset(String token, [int attempt = 0]) {
    _logger.d('Processing password reset (attempt $attempt)');
    final context = _navigatorKey.currentContext;
    if (context == null) {
      if (attempt >= _maxDeepLinkRetries) { _logger.w('[DeepLink] password reset: context timeout, giving up'); return; }
      Timer(const Duration(milliseconds: 500), () => _processPasswordReset(token, attempt + 1));
      return;
    }
    GoRouter.of(context).go('/reset-password', extra: {'token': token});
  }

  void _processEmailVerification(String token, [int attempt = 0]) {
    _logger.d('Processing email verification (attempt $attempt)');
    final context = _navigatorKey.currentContext;
    if (context == null) {
      if (attempt >= _maxDeepLinkRetries) { _logger.w('[DeepLink] email verify: context timeout, giving up'); return; }
      Timer(const Duration(milliseconds: 500), () => _processEmailVerification(token, attempt + 1));
      return;
    }
    GoRouter.of(context).go('/verify-email', extra: {'token': token});
  }

  Future<String> createDynamicLink({
    required String link,
    required String title,
    required String description,
    String? imageUrl,
  }) async {
    try {
      final uri = Uri.parse(link);
      final referralCode = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : '';
      final deepLinkUrl = Uri(
        scheme: 'https',
        host: 'askroa.ai',
        path: '/invite/$referralCode',
        queryParameters: {
          if (title.isNotEmpty) 'title': title,
          if (description.isNotEmpty) 'desc': description,
          if (imageUrl != null && imageUrl.isNotEmpty) 'img': imageUrl,
        },
      );
      _logger.d('Deep link created: $deepLinkUrl');
      return deepLinkUrl.toString();
    } catch (e, stack) {
      _logger.e('Failed to create dynamic link', error: e, stackTrace: stack);
      return link;
    }
  }

  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  void dispose() {
    _linkSubscription?.cancel();
    _initialLink.dispose();
    _logger.d('Deep linking service disposed');
  }
}

// ===========================================
// BUILD OPTIMIZER
// ===========================================
class BuildOptimizer {
  final ProductionLogger _logger;
  bool _isInitialized = false;
  PackageInfo? _packageInfo;
  Map<String, dynamic> _buildConfig = {};
  
  static const String buildTypeDebug = 'debug';
  static const String buildTypeProfile = 'profile';
  static const String buildTypeRelease = 'release';
  
  static const int optimizationLevelMinimal = 0;
  static const int optimizationLevelBalanced = 1;
  static const int optimizationLevelAggressive = 2;

  BuildOptimizer({required ProductionLogger logger}) : _logger = logger;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _packageInfo = await PackageInfo.fromPlatform();
      
      _buildConfig = {
        'appName': _packageInfo!.appName,
        'packageName': _packageInfo!.packageName,
        'version': _packageInfo!.version,
        'buildNumber': _packageInfo!.buildNumber,
        'buildType': _getBuildType(),
        'optimizationLevel': _getOptimizationLevel(),
        'platform': kIsWeb ? 'web' : Platform.operatingSystem,
        'architecture': _getArchitecture(),
        'compiler': _getCompilerInfo(),
        'debugSymbols': !kReleaseMode,
        'obfuscated': kReleaseMode && const bool.fromEnvironment('dart.obfuscate'),
        'splitDebugInfo': const bool.fromEnvironment('split-debug-info'),
      };
      
      if (kReleaseMode) {
        _applyReleaseOptimizations();
      }
      
      _isInitialized = true;
      
      _logger.i('Build Optimizer initialized');
    } catch (e, stack) {
      _logger.e('Failed to initialize Build Optimizer', error: e, stackTrace: stack);
    }
  }

  String _getBuildType() {
    if (kDebugMode) return buildTypeDebug;
    if (kProfileMode) return buildTypeProfile;
    return buildTypeRelease;
  }

  int _getOptimizationLevel() {
    if (kDebugMode) return optimizationLevelMinimal;
    if (kProfileMode) return optimizationLevelBalanced;
    return optimizationLevelAggressive;
  }

  String _getArchitecture() {
    if (kIsWeb) return 'web';
    if (Platform.isAndroid) {
      if (Platform.version.contains('arm64')) return 'arm64-v8a';
      if (Platform.version.contains('armeabi')) return 'armeabi-v7a';
      if (Platform.version.contains('x86_64')) return 'x86_64';
      return 'unknown';
    } else if (Platform.isIOS) {
      if (Platform.version.contains('arm64')) return 'arm64';
      return 'x86_64';
    } else if (Platform.isWindows) {
      return 'x64';
    } else if (Platform.isMacOS) {
      return 'arm64';
    } else if (Platform.isLinux) {
      return 'x64';
    }
    return 'unknown';
  }

  String _getCompilerInfo() {
    final compiler = <String>[];
    
    if (const bool.fromEnvironment('dart.obfuscate')) {
      compiler.add('obfuscated');
    }
    
    if (const bool.fromEnvironment('split-debug-info')) {
      compiler.add('split-debug');
    }
    
    if (kReleaseMode) {
      compiler.add('release');
    }
    
    return compiler.join(', ');
  }

  void _applyReleaseOptimizations() {
    if (!kIsWeb && Platform.isAndroid) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    
    _precacheAssets();
    
    PaintingBinding.instance.imageCache.maximumSize = 200;
    PaintingBinding.instance.imageCache.maximumSizeBytes = 100 * 1024 * 1024;
  }

  Future<void> _precacheAssets() async {
    _logger.d('Asset precaching deferred to app widget tree');
  }

  String getProductionBuildCommand() {
    final commands = <String>[];
    
    if (kIsWeb) {
      commands.add('flutter build web');
      commands.add('--release');
      commands.add('--web-renderer canvaskit');
    } else if (Platform.isAndroid) {
      commands.add('flutter build appbundle');
      commands.add('--release');
      commands.add('--split-debug-info=build/app/outputs/symbols');
      commands.add('--obfuscate');
      commands.add('--target-platform=android-arm,android-arm64,android-x64');
    } else if (Platform.isIOS) {
      commands.add('flutter build ios');
      commands.add('--release');
      commands.add('--split-debug-info=build/ios/symbols');
      commands.add('--obfuscate');
    } else if (Platform.isWindows) {
      commands.add('flutter build windows');
      commands.add('--release');
    } else if (Platform.isMacOS) {
      commands.add('flutter build macos');
      commands.add('--release');
    } else if (Platform.isLinux) {
      commands.add('flutter build linux');
      commands.add('--release');
    }
    
    return commands.join(' ');
  }

  Map<String, dynamic> getBuildConfig() => _buildConfig;
  PackageInfo? getPackageInfo() => _packageInfo;
  bool get isInitialized => _isInitialized;
}

// ===========================================
// BUNDLE OPTIMIZER
// ===========================================
class BundleOptimizer {
  final ProductionLogger _logger;
  final Map<String, int> _assetUsage = {};
  final Map<String, DateTime> _assetLastAccessed = {};
  Timer? _cleanupTimer;
  bool _isInitialized = false;
  
  static const int _bundleWarningThreshold = 50;
  static const int _bundleCriticalThreshold = 100;
  
  static const List<String> _imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
  static const List<String> _fontExtensions = ['.ttf', '.otf'];
  static const List<String> _audioExtensions = ['.mp3', '.wav', '.aac'];
  static const List<String> _videoExtensions = ['.mp4', '.mov', '.avi'];

  BundleOptimizer({required ProductionLogger logger}) : _logger = logger;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _startCleanupTimer();
      unawaited(_monitorBundleSize());
      
      _isInitialized = true;
      
      _logger.i('Bundle Optimizer initialized');
    } catch (e, stack) {
      _logger.e('Failed to initialize Bundle Optimizer', error: e, stackTrace: stack);
    }
  }

  void _startCleanupTimer() {
    _cleanupTimer = Timer.periodic(const Duration(hours: 24), (timer) {
      _cleanupUnusedAssets();
    });
  }

  Future<void> _monitorBundleSize() async {
    final bundleSize = await _getBundleSize();
    
    if (bundleSize > _bundleCriticalThreshold) {
      _logger.w('Bundle size critical', error: {'size_mb': bundleSize});
    } else if (bundleSize > _bundleWarningThreshold) {
      _logger.i('Bundle size warning', error: {'size_mb': bundleSize});
    }
  }

  Future<double> _getBundleSize() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final size = await _getDirectorySize(appDir);
      return size / (1024 * 1024);
    } catch (e) {
      _logger.d('Failed to get bundle size', error: e);
      return 0;
    }
  }

  Future<int> _getDirectorySize(Directory dir) async {
    int size = 0;
    try {
      await for (final file in dir.list(recursive: true)) {
        if (file is File) {
          size += await file.length();
        }
      }
    } catch (e) {
      _logger.d('Failed to get directory size', error: e);
    }
    return size;
  }

  void trackAssetUsage(String assetPath) {
    _assetUsage[assetPath] = (_assetUsage[assetPath] ?? 0) + 1;
    _assetLastAccessed[assetPath] = DateTime.now();
  }

  Future<void> _cleanupUnusedAssets() async {
    final now = DateTime.now();
    final threshold = now.subtract(const Duration(days: 30));
    
    final unusedAssets = _assetLastAccessed.entries
        .where((entry) => entry.value.isBefore(threshold))
        .map((e) => e.key)
        .toList();
    
    for (final asset in unusedAssets) {
      _assetUsage.remove(asset);
      _assetLastAccessed.remove(asset);
    }
    
    if (unusedAssets.isNotEmpty) {
      _logger.d('Cleaned up ${unusedAssets.length} unused assets');
    }
  }

  Map<String, dynamic> getCompressionRecommendations() {
    return {
      'images': {
        'format': 'WebP',
        'quality': 85,
        'resize': true,
        'maxDimension': 1920,
      },
      'audio': {
        'format': 'MP3',
        'bitrate': 128,
        'sampleRate': 44100,
      },
      'video': {
        'codec': 'H.264',
        'bitrate': '2M',
        'resolution': '1080p',
      },
      'fonts': {
        'subset': true,
        'format': 'WOFF2',
      },
    };
  }

  Map<String, dynamic> getLoadingStrategy() {
    return {
      'preload': [AppAssets.appIcon, AppAssets.sendIcon],
      'lazy': ['assets/icons/*'],
      'onDemand': [AppAssets.premiumIcon, AppAssets.voice1Icon],
      'cache': {
        'maxSize': 50 * 1024 * 1024,
        'ttl': Duration(days: 7),
      },
    };
  }

  void dispose() {
    _cleanupTimer?.cancel();
    _assetUsage.clear();
    _assetLastAccessed.clear();
  }
}

// ===========================================
// CONTENT POLICY - FIXED: Updated date to current year
// ===========================================
class ContentPolicy {
  static final String currentYear = DateTime.now().year.toString();
  
  static const String policy = '''
1. Acceptable Use
You may use Askroa AI for lawful purposes only. You agree not to use the service for:
- Illegal activities
- Harassment or bullying
- Generating harmful content
- Violating intellectual property rights
- Spamming or phishing attempts

2. Content Ownership
You retain ownership of the content you create using Askroa AI. However, you grant us a license to use, store, and analyze your content to improve our services.

3. Prohibited Content
The following content is strictly prohibited:
- Hate speech or discrimination
- Violence or threats
- Sexual content involving minors
- Malware or viruses
- Personal information of others

4. Fair Use
Free tier users are limited to 5 daily requests. Premium users enjoy unlimited access subject to fair use policies.

5. Termination
We reserve the right to terminate accounts that violate these terms without notice.

6. Changes to Terms
We may update these terms from time to time. Continued use of the service constitutes acceptance of the updated terms.

7. Contact
For questions about these terms, contact us at: support@askroa-ai.com

Full policy: $contentPolicyUrl
''';

  static String getFormattedPolicy() {
    return policy.replaceAll('\n', '\n\n');
  }
}

// ===========================================
// DATA SAFETY POLICY - FIXED: Updated date to current year
// ===========================================
class DataSafetyPolicy {
  static final String currentYear = DateTime.now().year.toString();
  
  static const String dataCollection = '''
1. Information We Collect

We collect the following information to provide and improve our services:

Personal Information:
- Email address
- Name
- Phone number (optional)
- Profile picture

Usage Data:
- Chat history
- Voice recordings
- Generated images and videos
- Device information
- IP address
- App usage statistics

2. How We Use Your Information

We use your information to:
- Provide and maintain our services
- Improve user experience
- Process payments
- Send important updates
- Ensure security and prevent fraud
- Train AI models (anonymized)

3. Data Security

We implement industry-standard security measures:
- End-to-end encryption (AES-256)
- Secure data storage (encrypted at rest)
- Regular security audits
- Access controls and authentication
- SOC2 Type II compliance

4. Data Retention

We retain your data for as long as your account is active. You can request data deletion at any time.
Inactive accounts are deleted after 2 years.

5. Third-Party Services

We use trusted third-party services for:
- Payment processing (Stripe, Razorpay)
- Analytics (Mixpanel, Amplitude)
- Cloud storage (AWS S3, Google Cloud)
- Authentication (Firebase Auth)
- Monitoring (Sentry, Firebase)

6. Your Rights

You have the right to:
- Access your data
- Correct inaccurate data
- Delete your data
- Export your data (GDPR compliant)
- Opt-out of marketing
- Withdraw consent

7. Children's Privacy

Our service is not intended for children under 13. We do not knowingly collect data from children.
If you believe we have collected data from a child, contact us immediately.

8. International Transfers

Your data may be processed in countries with different data protection laws.
We ensure appropriate safeguards through Standard Contractual Clauses.

9. Contact Us

For privacy concerns, contact: privacy@askroa-ai.com

Data Protection Officer: dpo@askroa-ai.com

Last updated: $currentYear

Full policy: $dataSafetyUrl
''';

  static String getFormattedDataCollection() {
    return dataCollection.replaceAll('\n', '\n\n');
  }
}

// ===========================================
// ANALYTICS SERVICE - FIXED
// ===========================================
class AnalyticsService {
  final ProductionLogger _logger;
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  bool _isInitialized = false;

  AnalyticsService({required ProductionLogger logger}) : _logger = logger;

  Future<void> initialize() async {
    _isInitialized = true;
  }

  Future<void> logEvent(String name, {Map<String, dynamic>? parameters}) async {
    unawaited(Future(() async {
      try {
        await _analytics.logEvent(name: name, parameters: parameters);
        _logger.d('Analytics event: $name');
      } catch (e, stack) {
        _logger.d('Analytics event failed', error: e, stackTrace: stack);
      }
    }));
  }

  Future<void> setUserProperties(String userId, {String? email, String? plan}) async {
    try {
      await _analytics.setUserId(id: userId);
      if (email != null) {
        await _analytics.setUserProperty(name: 'email', value: email);
      }
      if (plan != null) {
        await _analytics.setUserProperty(name: 'plan', value: plan);
      }
      _logger.d('Analytics user properties set');
    } catch (e, stack) {
      _logger.d('Set user properties failed', error: e, stackTrace: stack);
    }
  }

  Future<void> logScreenView(String screenName) async {
    try {
      await _analytics.logScreenView(screenName: screenName);
      _logger.d('Analytics screen view: $screenName');
    } catch (e, stack) {
      _logger.d('Log screen view failed', error: e, stackTrace: stack);
    }
  }
}

// ===========================================
// FEATURE FLAG SERVICE - FIXED
// ===========================================
class FeatureFlagService {
  final RemoteConfigService _remoteConfig;
  final ProductionLogger _logger;
  bool _isInitialized = false;
  bool _remoteConfigAvailable = false;
  final Map<String, String> _abVariantCache = {};

  static const Map<String, bool> _hardcodedDefaults = {
    'feature_image_gen': true,
    'feature_voice': true,
    'feature_web_search': true,
    'wake_word_enabled': true,
    'voice_commands_enabled': true,
    'maintenance_mode': false,
    'force_update': false,
  };

  FeatureFlagService({required RemoteConfigService remoteConfig, required ProductionLogger logger})
      : _remoteConfig = remoteConfig, _logger = logger;

  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      await _remoteConfig.initialize();
      _remoteConfigAvailable = true;
    } catch (e) {
      _logger.w('[FeatureFlag] RemoteConfig unavailable, using hardcoded defaults', error: e);
      _remoteConfigAvailable = false;
    }
    _isInitialized = true;
  }

  bool isEnabled(String feature) {
    if (!_remoteConfigAvailable) {
      return _hardcodedDefaults[feature] ?? false;
    }
    return _remoteConfig.getBool(feature, defaultValue: _hardcodedDefaults[feature] ?? false);
  }

  String getVariant(String testName) {
    if (_abVariantCache.containsKey(testName)) {
      return _abVariantCache[testName]!;
    }
    final variant = _remoteConfigAvailable
        ? _remoteConfig.getString('ab_test_$testName', defaultValue: 'control')
        : 'control';
    _abVariantCache[testName] = variant;
    return variant;
  }
}

// ===========================================
// APP TRACKING TRANSPARENCY SERVICE (iOS 14+) - FIXED
// ===========================================


// ===========================================
// FIXED: WORKMANAGER + BACKGROUND SERVICE INITIALIZATION
// ===========================================
Future<void> initializeBackgroundServices() async {
  if (kIsWeb) return;
  
  final _initLogger = ProductionLogger(isProduction: kReleaseMode);

  try {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: kDebugMode,
    );
    
    await Workmanager().registerPeriodicTask(
      'offline_sync',
      'sync_offline_messages',
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
      ),
    );

    await Workmanager().registerPeriodicTask(
      'daily_reset',
      'daily_reset_task',
      frequency: const Duration(hours: 24),
      initialDelay: _getTimeUntilMidnight(),
    );

    await Workmanager().registerPeriodicTask(
      'recovery_cleanup',
      'recovery_cleanup_task',
      frequency: const Duration(hours: 24),
    );
    
    await Workmanager().registerPeriodicTask(
      'database_vacuum',
      'database_vacuum_task',
      frequency: const Duration(days: 7),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
        requiresCharging: true,
      ),
    );

    await FlutterBackgroundService().configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true,
        autoStartOnBoot: true,
        notificationChannelId: 'askroa_background_channel',
        initialNotificationTitle: 'Askroa AI',
        initialNotificationContent: 'Running in background',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );

    if (!kIsWeb && Platform.isAndroid) {
      try {
        await FlutterBackgroundService().startService();
        _initLogger.i('[Init] Background service started');
      } catch (e) {
        _initLogger.w('[Init] Background service start failed (non-critical)', error: e);
      }
    }

    _initLogger.i('[Init] Background services initialized');
  } catch (e, stack) {
    _initLogger.e('[Init] Background services initialization failed', error: e);
    ProductionLogger().e('Background services initialization failed', error: e, stackTrace: stack);
  }
}


@pragma('vm:entry-point')
void onStart(ServiceInstance service) {
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });
    
    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }
  
  service.on('stopService').listen((event) {
    service.stopSelf();
  });
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  return true;
}

Duration _getTimeUntilMidnight() {
  final now = DateTime.now();
  final midnight = DateTime(now.year, now.month, now.day + 1);
  return midnight.difference(now);
}

// ===========================================
// JUST AUDIO BACKGROUND INITIALIZATION - FIXED
// ===========================================
Future<void> initializeJustAudioBackground() async {
  if (kIsWeb) return;
  
  final _initLogger = ProductionLogger(isProduction: kReleaseMode);
  try {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.askroa.audio.channel',
      androidNotificationChannelName: 'Audio Playback',
      androidNotificationOngoing: true,
    );
    _initLogger.i('[Init] JustAudioBackground initialized');
  } catch (e, stack) {
    _initLogger.e('[Init] JustAudioBackground initialization failed', error: e);
    ProductionLogger().e('JustAudioBackground initialization failed', error: e, stackTrace: stack);
  }
}

// ===========================================
// FIXED: FIREBASE INITIALIZATION FUNCTION
// ===========================================
Future<void> initializeFirebase() async {
  if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return;
  
  final _initLogger = ProductionLogger(isProduction: kReleaseMode);
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    
    await FirebasePerformance.instance.setPerformanceCollectionEnabled(true);
    
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.playIntegrity,
      appleProvider: AppleProvider.appAttest,
    );
    
    _initLogger.i('[Init] Firebase initialized');
  } catch (e, stack) {
    _initLogger.e('[Init] Firebase initialization failed', error: e);
    ProductionLogger().e('Firebase initialization failed', error: e, stackTrace: stack);
    rethrow;
  }
}

// ===========================================
// RIVERPOD PROVIDERS - FIXED: Proper dependency injection
// ===========================================
final loggerProvider = Provider<ProductionLogger>((ref) {
  return ProductionLogger(isProduction: kReleaseMode);
});

final envConfigProvider = FutureProvider<EnvironmentConfig>((ref) async {
  final config = EnvironmentConfig();
  final logger = ref.read(loggerProvider);
  await config.initialize(logger: logger); // no-op if already initialized
  return config;
});

final performanceOptimizerProvider = Provider<PerformanceOptimizer>((ref) {
  final logger = ref.read(loggerProvider);
  return PerformanceOptimizer(logger: logger);
});

final performanceOptimizerFutureProvider = FutureProvider<PerformanceOptimizer>((ref) async {
  final optimizer = ref.read(performanceOptimizerProvider);
  await optimizer.initialize();
  return optimizer;
});

final securityArchitectureProvider = Provider<SecurityArchitecture>((ref) {
  final logger = ref.read(loggerProvider);
  return SecurityArchitecture(logger: logger);
});

final securityArchitectureFutureProvider = FutureProvider<SecurityArchitecture>((ref) async {
  final security = ref.read(securityArchitectureProvider);
  await security.initialize();
  return security;
});

final buildOptimizerProvider = Provider<BuildOptimizer>((ref) {
  final logger = ref.read(loggerProvider);
  return BuildOptimizer(logger: logger);
});

final buildOptimizerFutureProvider = FutureProvider<BuildOptimizer>((ref) async {
  final optimizer = ref.read(buildOptimizerProvider);
  await optimizer.initialize();
  return optimizer;
});

final bundleOptimizerProvider = Provider<BundleOptimizer>((ref) {
  final logger = ref.read(loggerProvider);
  return BundleOptimizer(logger: logger);
});

final bundleOptimizerFutureProvider = FutureProvider<BundleOptimizer>((ref) async {
  final optimizer = ref.read(bundleOptimizerProvider);
  await optimizer.initialize();
  return optimizer;
});

final encryptionProvider = Provider<ProductionEncryptionService>((ref) {
  final logger = ref.read(loggerProvider);
  return ProductionEncryptionService(logger: logger);
});

final encryptionFutureProvider = FutureProvider<ProductionEncryptionService>((ref) async {
  final encryption = ref.read(encryptionProvider);
  await encryption.initialize();
  return encryption;
});

final connectivityProvider = Provider<ProductionConnectivityService>((ref) {
  final logger = ref.read(loggerProvider);
  return ProductionConnectivityService(logger: logger);
});

final connectivityFutureProvider = FutureProvider<ProductionConnectivityService>((ref) async {
  final connectivity = ref.read(connectivityProvider);
  await connectivity.initialize();
  return connectivity;
});

final rateLimitingProvider = Provider<RateLimitingService>((ref) {
  final logger = ref.read(loggerProvider);
  return RateLimitingService(logger: logger);
});

final rateLimitingFutureProvider = FutureProvider<RateLimitingService>((ref) async {
  final rateLimiter = ref.read(rateLimitingProvider);
  await rateLimiter.initialize();
  return rateLimiter;
});

final webSocketProvider = Provider<WebSocketService>((ref) {
  final logger = ref.read(loggerProvider);
  return WebSocketService(logger: logger);
});

final webSocketFutureProvider = FutureProvider<WebSocketService>((ref) async {
  final webSocket = ref.read(webSocketProvider);
  await webSocket.initialize();
  return webSocket;
});

final cacheManagerProvider = Provider<ProductionCacheManager>((ref) {
  final logger = ref.read(loggerProvider);
  final performance = ref.read(performanceOptimizerProvider);
  return ProductionCacheManager(logger: logger, performance: performance);
});

final cacheManagerFutureProvider = FutureProvider<ProductionCacheManager>((ref) async {
  final cache = ref.read(cacheManagerProvider);
  await cache.initialize();
  return cache;
});

final databaseProvider = Provider<DatabaseService>((ref) {
  final logger = ref.read(loggerProvider);
  final performance = ref.read(performanceOptimizerProvider);
  return DatabaseService(logger: logger, performance: performance);
});

final databaseFutureProvider = FutureProvider<DatabaseService>((ref) async {
  final db = ref.read(databaseProvider);
  await db.initialize();
  return db;
});

final idempotencyServiceProvider = Provider<IdempotencyService>((ref) {
  final logger = ref.read(loggerProvider);
  return IdempotencyService(logger: logger);
});

final idempotencyServiceFutureProvider = FutureProvider<IdempotencyService>((ref) async {
  final idempotency = ref.read(idempotencyServiceProvider);
  await idempotency.initialize();
  return idempotency;
});

final certificatePinningProvider = Provider<CertificatePinningService>((ref) {
  final logger = ref.read(loggerProvider);
  return CertificatePinningService(logger: logger);
});

final certificatePinningFutureProvider = FutureProvider<CertificatePinningService>((ref) async {
  final pinning = ref.read(certificatePinningProvider);
  await pinning.initialize();
  return pinning;
});

final syncConflictResolverProvider = Provider<SyncConflictResolver>((ref) {
  final logger = ref.read(loggerProvider);
  return SyncConflictResolver(logger: logger);
});

final remoteConfigProvider = Provider<RemoteConfigService>((ref) {
  final logger = ref.read(loggerProvider);
  return RemoteConfigService(logger: logger);
});

final remoteConfigFutureProvider = FutureProvider<RemoteConfigService>((ref) async {
  final config = ref.read(remoteConfigProvider);
  await config.initialize();
  return config;
});

final firebaseMessagingProvider = Provider<FirebaseMessagingService>((ref) {
  final logger = ref.read(loggerProvider);
  return FirebaseMessagingService(logger: logger);
});

final firebaseMessagingFutureProvider = FutureProvider<FirebaseMessagingService>((ref) async {
  final messaging = ref.read(firebaseMessagingProvider);
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    final deepLinking = ref.read(deepLinkingProvider);
    messaging.setNavigatorKey(deepLinking.navigatorKey);
    await messaging.initialize();
  }
  return messaging;
});

final inAppPurchaseProvider = Provider<InAppPurchaseService>((ref) {
  final logger = ref.read(loggerProvider);
  return InAppPurchaseService(logger: logger);
});

final inAppPurchaseFutureProvider = FutureProvider<InAppPurchaseService>((ref) async {
  final iap = ref.read(inAppPurchaseProvider);
  if (IAPConfig.isSupported) {
    await iap.initialize();
  }
  return iap;
});

final performanceMonitoringProvider = Provider<PerformanceMonitoringService>((ref) {
  final logger = ref.read(loggerProvider);
  return PerformanceMonitoringService(logger: logger);
});

final performanceMonitoringFutureProvider = FutureProvider<PerformanceMonitoringService>((ref) async {
  final performance = ref.read(performanceMonitoringProvider);
  await performance.initialize();
  return performance;
});

final crashRecoveryProvider = Provider<GlobalCrashRecovery>((ref) {
  final logger = ref.read(loggerProvider);
  return GlobalCrashRecovery(logger: logger);
});

final crashRecoveryFutureProvider = FutureProvider<GlobalCrashRecovery>((ref) async {
  final recovery = ref.read(crashRecoveryProvider);
  await recovery.initialize();
  return recovery;
});

final globalUserHandlerProvider = Provider<GlobalUserHandler>((ref) {
  final logger = ref.read(loggerProvider);
  return GlobalUserHandler(logger: logger);
});

final globalUserHandlerFutureProvider = FutureProvider<GlobalUserHandler>((ref) async {
  final handler = ref.read(globalUserHandlerProvider);
  await handler.initialize();
  return handler;
});

final globalApiClientProvider = FutureProvider<GlobalApiClient>((ref) async {
  final logger = ref.read(loggerProvider);
  final encryption = await ref.read(encryptionFutureProvider.future);
  final connectivity = await ref.read(connectivityFutureProvider.future);
  final rateLimiter = await ref.read(rateLimitingFutureProvider.future);
  final performance = await ref.read(performanceOptimizerFutureProvider.future);
  final security = await ref.read(securityArchitectureFutureProvider.future);
  final certificatePinning = await ref.read(certificatePinningFutureProvider.future);
  final cacheManager = await ref.read(cacheManagerFutureProvider.future);
  
  final client = GlobalApiClient(
    logger: logger,
    encryption: encryption,
    connectivity: connectivity,
    rateLimiter: rateLimiter,
    performance: performance,
    security: security,
    certificatePinning: certificatePinning,
    cacheManager: cacheManager,
  );
  await client.initialize();
  return client;
});

final apiServiceProvider = FutureProvider<ProductionApiService>((ref) async {
  final logger = ref.read(loggerProvider);
  final encryption = await ref.read(encryptionFutureProvider.future);
  final connectivity = await ref.read(connectivityFutureProvider.future);
  final rateLimiter = await ref.read(rateLimitingFutureProvider.future);
  final webSocket = await ref.read(webSocketFutureProvider.future);
  
  final apiService = ProductionApiService(
    logger,
    encryption,
    connectivity,
    rateLimiter,
    webSocket,
  );
  await apiService.initialize();
  return apiService;
});

final analyticsProvider = Provider<AnalyticsService>((ref) {
  final logger = ref.read(loggerProvider);
  return AnalyticsService(logger: logger);
});

final analyticsFutureProvider = FutureProvider<AnalyticsService>((ref) async {
  final analytics = ref.read(analyticsProvider);
  await analytics.initialize();
  return analytics;
});

final featureFlagProvider = FutureProvider<FeatureFlagService>((ref) async {
  final remoteConfig = await ref.read(remoteConfigFutureProvider.future);
  final logger = ref.read(loggerProvider);
  final featureFlag = FeatureFlagService(remoteConfig: remoteConfig, logger: logger);
  await featureFlag.initialize();
  return featureFlag;
});

final deepLinkingProvider = Provider<DeepLinkingService>((ref) {
  final logger = ref.read(loggerProvider);
  return DeepLinkingService(logger: logger);
});

final deepLinkingFutureProvider = FutureProvider<DeepLinkingService>((ref) async {
  final deepLinking = ref.read(deepLinkingProvider);
  await deepLinking.initialize();
  return deepLinking;
});




final backgroundSyncOrchestratorProvider = FutureProvider<BackgroundSyncOrchestrator>((ref) async {
  final logger = ref.read(loggerProvider);
  final database = await ref.read(databaseFutureProvider.future);
  final connectivity = await ref.read(connectivityFutureProvider.future);
  final rateLimiter = await ref.read(rateLimitingFutureProvider.future);
  final idempotency = await ref.read(idempotencyServiceFutureProvider.future);
  
  final sync = BackgroundSyncOrchestrator(
    logger: logger,
    database: database,
    connectivity: connectivity,
    rateLimiter: rateLimiter,
    idempotency: idempotency,
  );
  await sync.initialize();
  return sync;
});

final userRepositoryProvider = FutureProvider<UserRepository>((ref) async {
  final db = await ref.read(databaseFutureProvider.future);
  return DatabaseUserRepository(db);
});

final authRepositoryProvider = FutureProvider<AuthRepository>((ref) async {
  final apiService = await ref.read(apiServiceProvider.future);
  final userHandler = await ref.read(globalUserHandlerFutureProvider.future);
  final security = await ref.read(securityArchitectureFutureProvider.future);
  return ApiAuthRepository(apiService, userHandler, security);
});

// ===========================================
// AUTH PROVIDER - FIXED: Proper dependency injection
// ===========================================
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;
  late final ProductionLogger _logger;
  late final ProductionApiService _apiService;
  late final GlobalUserHandler _userHandler;
  late final DatabaseService _databaseService;
  late final SecurityArchitecture _security;
  late final RateLimitingService _rateLimiter;
  late final IdempotencyService _idempotency;
  late final AuthRepository _authRepository;
  bool _isInitialized = false;

  AuthNotifier(this.ref) : super(const AuthState.initial()) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      _logger = ref.read(loggerProvider);
      _apiService = await ref.read(apiServiceProvider.future);
      _userHandler = await ref.read(globalUserHandlerFutureProvider.future);
      _databaseService = await ref.read(databaseFutureProvider.future);
      _security = await ref.read(securityArchitectureFutureProvider.future);
      _rateLimiter = await ref.read(rateLimitingFutureProvider.future);
      _idempotency = await ref.read(idempotencyServiceFutureProvider.future);
      _authRepository = await ref.read(authRepositoryProvider.future);
      
      _isInitialized = true;
      await initialize();
    } catch (e, stack) {
      _logger.e('Auth notifier initialization failed', error: e, stackTrace: stack);
    }
  }

  Future<void> initialize() async {
    if (!_isInitialized) return;
    
    try {
      state = const AuthState.loading();
      if (!_databaseService.isInitialized) {
        await _databaseService.initialize();
      }
      await _userHandler.initialize();

      if (_userHandler.hasUser) {
        final isValid = await _apiService.validateSubscription(_userHandler.currentUser!.id);
        if (isValid) {
          state = AuthState.authenticated(_userHandler.currentUser!);
          _logger.i('User authenticated: ${_userHandler.currentUser!.id}');
          // Sync rate limits + voice settings after auth
          unawaited(() async {
            try {
              await _userHandler.syncRateLimitsFromServer(_apiService);
              unawaited(ref.read(voiceSettingsProvider.notifier).loadFromBackend());
            } catch (_) {}
          }());
        } else {
          await logout();
          state = const AuthState.unauthenticated();
          _logger.w('Subscription invalid, logged out');
        }
      } else {
        state = const AuthState.unauthenticated();
        _logger.d('No user found');
      }
    } catch (e, stack) {
      _logger.e('Auth initialization failed', error: e, stackTrace: stack);
      state = const AuthState.unauthenticated();
    }
  }

  Future<void> loginWithEmail(String email, String password) async {
    if (!_isInitialized) return;
    
    try {
      state = const AuthState.loading();
      final user = await _authRepository.loginWithEmail(email, password);
      
      await _saveUserToDatabase(user);
      
      state = AuthState.authenticated(user);
      _logger.i('Email login successful: ${user.id}');
    } catch (e) {
      _logger.e('Email login failed', error: e);
      state = AuthState.error('Unable to sign in. Please check your credentials and try again.');
      rethrow;
    }
  }

  Future<void> loginWithGoogle() async {
    if (!_isInitialized) return;
    
    try {
      state = const AuthState.loading();
      final user = await _authRepository.loginWithGoogle();
      
      await _saveUserToDatabase(user);
      
      state = AuthState.authenticated(user);
      _logger.i('Google login successful: ${user.id}');
    } catch (e) {
      _logger.e('Google login failed', error: e);
      state = AuthState.error('Google sign in failed. Please try again.');
      rethrow;
    }
  }

  Future<void> loginWithApple() async {
    if (!_isInitialized) return;
    
    try {
      state = const AuthState.loading();
      final user = await _authRepository.loginWithApple();
      
      await _saveUserToDatabase(user);
      
      state = AuthState.authenticated(user);
      _logger.i('Apple login successful: ${user.id}');
    } catch (e) {
      _logger.e('Apple login failed', error: e);
      state = AuthState.error('Apple sign in failed. Please try again.');
      rethrow;
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    if (!_isInitialized) return;
    
    try {
      state = const AuthState.loading();
      final user = await _authRepository.register(name, email, password, phone: phone);
      
      await _saveUserToDatabase(user);
      
      state = AuthState.authenticated(user);
      _logger.i('Registration successful: ${user.id}');
    } catch (e) {
      _logger.e('Registration failed', error: e);
      state = AuthState.error('Registration failed. Please try again.');
      rethrow;
    }
  }

  Future<void> logout() async {
    if (!_isInitialized) return;
    
    try {
      state = const AuthState.loading();
      final currentUser = state.maybeWhen(
        authenticated: (user) => user,
        orElse: () => null,
      );

      if (currentUser != null) {
        await _authRepository.logout(currentUser.id);
      }

      await _userHandler.clearUser();
      await _security.clearTokens();
      state = const AuthState.unauthenticated();
      _logger.i('Logout successful');
    } catch (e) {
      _logger.e('Logout failed', error: e);
      state = AuthState.error('Unable to sign out. Please try again.');
      rethrow;
    }
  }

  Future<void> updateUser(User user) async {
    if (!_isInitialized) return;
    
    try {
      await _userHandler.setUser(user);
      await _saveUserToDatabase(user);
      state = AuthState.authenticated(user);
      _logger.d('User updated: ${user.id}');
    } catch (e, stack) {
      _logger.e('Update user failed', error: e, stackTrace: stack);
    }
  }

  Future<void> _saveUserToDatabase(User user) async {
    try {
      await _databaseService.database.into(_databaseService.database.localUsers).insertOnConflictUpdate(
        LocalUsersCompanion(
          serverId: drift.Value(user.id),
          name: drift.Value(user.name),
          email: drift.Value(user.email),
          phone: drift.Value(user.phone),
          profileImage: drift.Value(user.profileImage),
          plan: drift.Value(user.plan),
          createdAt: drift.Value(user.createdAt),
          subscriptionExpiry: drift.Value(user.subscriptionExpiry),
          dailyRequests: drift.Value(user.dailyRequests),
          maxRequests: drift.Value(user.maxRequests),
          preferencesJson: drift.Value(jsonEncode(user.preferences)),
          isVoiceTrained: drift.Value(user.isVoiceTrained),
          lastSynced: drift.Value(DateTime.now()),
        ),
      );
      
      await _rateLimiter.syncQuotaWithServer(user.id, user.maxRequests);
      
      _logger.d('User saved to database: ${user.id}');
    } catch (e, stack) {
      _logger.e('Save user to database failed', error: e, stackTrace: stack);
    }
  }
}

@immutable
abstract class AuthState {
  const AuthState();

  const factory AuthState.initial() = InitialAuthState;
  const factory AuthState.loading() = LoadingAuthState;
  const factory AuthState.authenticated(User user) = AuthenticatedAuthState;
  const factory AuthState.unauthenticated() = UnauthenticatedAuthState;
  const factory AuthState.error(String message) = ErrorAuthState;
}

class InitialAuthState extends AuthState {
  const InitialAuthState();
}

class LoadingAuthState extends AuthState {
  const LoadingAuthState();
}

class AuthenticatedAuthState extends AuthState {
  final User user;
  const AuthenticatedAuthState(this.user);
}

class UnauthenticatedAuthState extends AuthState {
  const UnauthenticatedAuthState();
}

class ErrorAuthState extends AuthState {
  final String message;
  const ErrorAuthState(this.message);
}

// ===========================================
// FIXED: STREAMING CHAT PROVIDER - Proper disposal, auto-save on app close
// ===========================================
final streamingChatProvider = StateNotifierProvider<StreamingChatNotifier, StreamingChatState>((ref) {
  return StreamingChatNotifier(ref);
});

class StreamingChatNotifier extends StateNotifier<StreamingChatState> with WidgetsBindingObserver {
  final Ref ref;
  late final ProductionLogger _logger;
  late final ProductionApiService _apiService;
  late final GlobalUserHandler _userHandler;
  late final DatabaseService _databaseService;
  late final WebSocketService _webSocket;
  late final PerformanceOptimizer _performance;
  late final RateLimitingService _rateLimiter;
  late final IdempotencyService _idempotency;
  late final ProductionEncryptionService _encryption;
  final Map<String, StreamController<String>> _streamControllers = {};
  final Map<String, String> _streamingMessages = {};
  final Map<String, StringBuffer> _thinkingBuffers = {};
  final Map<String, bool> _isThinkingActive = {};
  final Map<String, String> _modelUsedBuffers = {};
  VoidCallback? scrollToBottomCallback;
  String? _generatingSessionId;
  String? _generatingMessageId;
  int _newChatClickCount = 0;
  Timer? _newChatClickResetTimer;
  Timer? _reconnectTimer;
  Timer? _autoSaveTimer;
  bool _isInitialized = false;
  bool _isDisposed = false;

  StreamingChatNotifier(this.ref) : super(const StreamingChatState.initial()) {
    WidgetsBinding.instance.addObserver(this);
    _initialize();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState appState) {
    switch (appState) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        // Pause auto-save timer to save battery when backgrounded
        _autoSaveTimer?.cancel();
        _autoSaveTimer = null;
        break;
      case AppLifecycleState.resumed:
        // Resume auto-save when app comes back to foreground
        if (_isInitialized && !_isDisposed) _startAutoSaveTimer();
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  Future<void> _initialize() async {
    try {
      _logger = ref.read(loggerProvider);
      _apiService = await ref.read(apiServiceProvider.future);
      _userHandler = await ref.read(globalUserHandlerFutureProvider.future);
      _databaseService = await ref.read(databaseFutureProvider.future);
      _webSocket = await ref.read(webSocketFutureProvider.future);
      _performance = await ref.read(performanceOptimizerFutureProvider.future);
      _rateLimiter = await ref.read(rateLimitingFutureProvider.future);
      _idempotency = await ref.read(idempotencyServiceFutureProvider.future);
      _encryption = await ref.read(encryptionFutureProvider.future);
      
      _startAutoSaveTimer();
      
      _isInitialized = true;
    } catch (e, stack) {
      _logger.e('StreamingChatNotifier initialization failed', error: e, stackTrace: stack);
    }
  }

  void _startAutoSaveTimer() {
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (!_isDisposed) {
        _autoSaveCurrentSession();
      }
    });
  }

  Future<void> _autoSaveCurrentSession() async {
    try {
      final currentState = state;
      if (currentState is StreamingChatLoaded && currentState.activeSession != null) {
        final session = currentState.activeSession!;
        final hasActiveStream = session.messages.any((m) => m.isStreaming);
        if (session.messages.isNotEmpty && !hasActiveStream) {
          await _saveSessionToDatabase(session);
          _logger.d('Auto-saved session (all messages complete): ${session.id}');
        } else if (hasActiveStream) {
          _logger.d('Auto-save skipped — stream in progress (memory only)');
        }
      }
    } catch (e, stack) {
      _logger.d('Auto-save failed', error: e, stackTrace: stack);
    }
  }

  Future<void> sendMessage({
    required String sessionId,
    required String message,
    bool deepResearch = false,
    List<String>? attachments,
    String? idempotencyKey,
    String? modelId,
    String? languageCode,
    String? systemNote,
    bool isContinuation = false,
    String? continuationFromMessageId,
    String? continuationPartialText,
  }) async {
    if (!_isInitialized || _isDisposed) return;
    
    await _performance.measureOperation('send_message', () async {
      try {
        final user = _userHandler.currentUser;
        if (user == null) throw Exception('User not authenticated');

        final _secGuard = SecurityArchitecture(logger: _logger);
        if (_secGuard.detectPromptInjection(message)) {
          throw ApiException(
            'Your message was blocked by the safety system. Please rephrase your request.',
            400,
            'PROMPT_INJECTION_DETECTED',
          );
        }
        
        if (!_userHandler.canSendMessage) {
          if (user.plan.toLowerCase().trim() == 'yearly') {
            throw ApiException(
              'Chat limit reached. Go to new chat.',
              429,
              'ULTRA_PRO_SESSION_LIMIT',
            );
          }
          throw ApiException('Your chat limit has been reached. Please go to Pro plan.', 429, 'CHAT_LIMIT');
        }
        
        final quotaRemaining = _rateLimiter.getRemainingQuota(user.id, user.plan);
        if (quotaRemaining <= 0 && !user.isPremium) {
          throw ApiException('Daily limit reached. Upgrade to Pro for more.', 429, 'QUOTA_EXCEEDED');
        }

        final effectiveKey = idempotencyKey ?? _idempotency.generateKey(
          userId: user.id,
          operation: 'send_message',
          entity: 'chat_message',
          entityId: sessionId,
        );

        final canProceed = await _idempotency.checkAndMark(
          userId: user.id,
          operation: 'send_message',
          entity: 'chat_message',
          entityId: sessionId,
          providedKey: effectiveKey,
        );

        if (!canProceed) {
          _logger.w('Duplicate message attempt prevented: $effectiveKey');
          return;
        }

        final userMessageId = 'user_${DateTime.now().millisecondsSinceEpoch}';
        final userMessage = ChatMessage(
          id: userMessageId,
          text: message,
          sender: 'user',
          timestamp: DateTime.now(),
          attachments: attachments,
        );

        final aiMessageId = 'ai_${DateTime.now().millisecondsSinceEpoch}';
        final aiMessage = ChatMessage(
          id: aiMessageId,
          text: '',
          sender: 'ai',
          timestamp: DateTime.now(),
          isStreaming: true,
          streamingText: '',
        );

        _generatingSessionId = sessionId;
        _generatingMessageId = aiMessageId;

        _addMessagesOptimistically(sessionId, [userMessage, aiMessage],
            autoTitleFromMessage: message);
        
        await _userHandler.decrementRequest();
        // Background: refresh authoritative rate limits from server
        unawaited(() async {
          try { await _userHandler.syncRateLimitsFromServer(_apiService); } catch (_) {}
        }());
        _userHandler.incrementUltraProSessionMessage();

        try {
          final streamId = await _webSocket.sendChatMessage(
            sessionId: sessionId,
            message: message,
            userId: user.id,
            deepResearch: deepResearch,
            attachments: attachments,
            systemNote: systemNote,
            isContinuation: isContinuation,
            continuationFromMessageId: continuationFromMessageId,
            continuationPartialText: continuationPartialText,
            modelId: modelId,
          );

          final controller = StreamController<String>();
          LazyLoader.registerController(controller);
          _streamControllers[aiMessageId] = controller;
          _streamingMessages[aiMessageId] = '';

          controller.stream.listen((chunk) {
            _performance.throttle(() {
              if (chunk.startsWith('__MODEL_USED__:')) {
                final modelId = chunk.substring('__MODEL_USED__:'.length).trim();
                _modelUsedBuffers[aiMessageId] = modelId;
                return;
              }
              if (chunk.startsWith('__THINKING_CHUNK__:')) {
                final thinkPart = chunk.substring('__THINKING_CHUNK__:'.length);
                _thinkingBuffers.putIfAbsent(aiMessageId, () => StringBuffer());
                _thinkingBuffers[aiMessageId]!.write(thinkPart);
                _isThinkingActive[aiMessageId] = true;
                _updateStreamingMessage(sessionId, aiMessageId,
                    '__THINKING__:${_thinkingBuffers[aiMessageId]}');
                return;
              }
              if (chunk.startsWith('__THINKING__:')) {
                final thinkText = chunk.substring('__THINKING__:'.length);
                _thinkingBuffers.putIfAbsent(aiMessageId, () => StringBuffer());
                _thinkingBuffers[aiMessageId]!.clear();
                _thinkingBuffers[aiMessageId]!.write(thinkText);
                return;
              }
              if (_isThinkingActive[aiMessageId] == true) {
                _isThinkingActive[aiMessageId] = false;
              }
              final currentText = _streamingMessages[aiMessageId] ?? '';
              final newText = currentText + chunk;
              _streamingMessages[aiMessageId] = newText;
              
              _updateStreamingMessage(sessionId, aiMessageId, newText);
            }, duration: const Duration(milliseconds: 50));
          }, onDone: () {
            _finalizeStreamingMessage(sessionId, aiMessageId);
            _streamControllers.remove(aiMessageId);
            _streamingMessages.remove(aiMessageId);
            LazyLoader.unregisterController(controller);
            controller.close();
          }, onError: (error) async {
            _logger.d('Streaming error — attempting HTTP fallback retry', error: error);
            _streamControllers.remove(aiMessageId);
            _streamingMessages.remove(aiMessageId);
            LazyLoader.unregisterController(controller);
            controller.close();

            const maxRetries = 3;
            int attempt = 0;
            bool retrySuccess = false;
            while (attempt < maxRetries && !retrySuccess) {
              attempt++;
              final delay = Duration(seconds: attempt * 2);
              _logger.d('Streaming retry attempt $attempt/$maxRetries in ${delay.inSeconds}s');
              await Future.delayed(delay);
              try {
                final retryResponse = await _apiService.sendChatMessage(
                  sessionId: sessionId,
                  message: message,
                  userId: user.id,
                  plan: user.plan,
                  deepResearch: deepResearch,
                  attachments: attachments,
                  idempotencyKey: effectiveKey,
                  modelId: modelId,
                );
                final retryThinkingText = retryResponse['thinking_text'] as String? ?? '';
                final retryIsThinking = retryResponse['is_thinking'] as bool? ?? retryThinkingText.isNotEmpty;
                final retryModelUsed = retryResponse['model_used'] as String?;
                final rawText = retryResponse['response'] as String? ?? '';
                if (rawText.isEmpty && attempt < maxRetries) {
                  _logger.w('Streaming retry $attempt: empty response, will retry');
                  continue;
                }
                final security = SecurityArchitecture(logger: _logger);
                final filteredText = security.filterAiOutput(rawText) ?? rawText;
                final retryAiMessage = aiMessage.copyWith(
                  text: filteredText,
                  isStreaming: false,
                  streamingText: null,
                  isThinking: retryIsThinking,
                  thinkingText: retryIsThinking ? retryThinkingText : null,
                  modelUsed: retryModelUsed,
                  metadata: {
                    ...?(retryResponse['metadata'] as Map<String, dynamic>?),
                    'show_disclaimer': true,
                    'retry_attempt': attempt,
                    if (retryIsThinking) 'thinking_mode': true,
                    if (retryModelUsed != null) 'model_used': retryModelUsed,
                  },
                );
                _updateMessage(sessionId, aiMessageId, retryAiMessage);
                retrySuccess = true;
                _logger.i('Streaming retry succeeded on attempt $attempt');
              } catch (retryError) {
                _logger.w('Streaming retry attempt $attempt failed', error: retryError);
                if (attempt == maxRetries) {
                  _handleStreamingError(
                    sessionId,
                    aiMessageId,
                    '⚠️ Connection lost after $maxRetries retries.\n'
                    'Your message was received. Tap to retry.',
                  );
                  _logger.w('[Stream] All $maxRetries retries failed for session $sessionId');
                }
              }
            } // end while
          });

        } catch (e) {
          _logger.d('WebSocket failed, falling back to HTTP', error: e);
          final response = await _apiService.sendChatMessage(
            sessionId: sessionId,
            message: message,
            userId: user.id,
            plan: user.plan,
            deepResearch: deepResearch,
            attachments: attachments,
            idempotencyKey: effectiveKey,
            modelId: modelId,
          );

          final httpThinkingText = response['thinking_text'] as String? ?? '';
          final httpIsThinking   = response['is_thinking'] as bool? ?? httpThinkingText.isNotEmpty;
          final httpModelUsed    = response['model_used'] as String?;
          final httpLangCode     = response['language_code'] as String? ?? languageCode;
          final _httpSecGuard = SecurityArchitecture(logger: _logger);
          final rawHttpText = response['response'] as String? ?? '';
          final filteredHttpText = _httpSecGuard.filterAiOutput(rawHttpText) ?? rawHttpText;
          final completedAiMessage = aiMessage.copyWith(
            text: filteredHttpText,
            isStreaming: false,
            streamingText: null,
            isThinking: httpIsThinking,
            thinkingText: httpIsThinking ? httpThinkingText : null,
            modelUsed: httpModelUsed,
            metadata: {
              ...?(response['metadata'] as Map<String, dynamic>?),
              'show_disclaimer': true,
              if (httpIsThinking) 'thinking_mode': true,
              if (httpModelUsed != null) 'model_used': httpModelUsed,
            },
          );

          _updateMessage(sessionId, aiMessageId, completedAiMessage);
        }
        
        await _saveSessionToDatabase(_getSessionById(sessionId));
      } on ApiException catch (e) {
        if (e.statusCode == 429 || e.errorCode == 'CHAT_LIMIT' || e.errorCode == 'QUOTA_EXCEEDED') {
          _showChatLimitError();
        }
        rethrow;
      } catch (e, stack) {
        _logger.e('Send message failed', error: e, stackTrace: stack);
        rethrow;
      }
      return null;
    });
  }

  Future<void> stopStreaming(String sessionId, String messageId) async {
    if (!_isInitialized || _isDisposed) return;
    
    try {
      final controller = _streamControllers[messageId];
      if (controller != null && !controller.isClosed) {
        LazyLoader.unregisterController(controller);
        controller.close();
        _streamControllers.remove(messageId);
        _streamingMessages.remove(messageId);
        
        _finalizeStreamingMessage(sessionId, messageId);
        
        final user = _userHandler.currentUser;
        if (user != null) {
          await _apiService.stopGeneration(
            sessionId: sessionId,
            userId: user.id,
            messageId: messageId,
          );
        }
        
        _logger.d('Streaming stopped: $messageId');
      }
    } catch (e, stack) {
      _logger.d('Stop streaming failed', error: e, stackTrace: stack);
    }
  }

  Future<void> sendVoiceMessage({
    required String sessionId,
    required File audioFile,
    String? idempotencyKey,
  }) async {
    if (!_isInitialized || _isDisposed) return;
    
    try {
      final user = _userHandler.currentUser;
      if (user == null) throw Exception('User not authenticated');
      
      if (!_userHandler.canSendMessage) {
        if (user.plan.toLowerCase().trim() == 'yearly') {
          throw ApiException('Chat limit reached. Go to new chat.', 429, 'ULTRA_PRO_SESSION_LIMIT');
        }
        throw ApiException('Your chat limit has been reached. Please go to Pro plan.', 429, 'CHAT_LIMIT');
      }
      
      final quotaRemaining = _rateLimiter.getRemainingQuota(user.id, user.plan);
      if (quotaRemaining <= 0 && !user.isPremium) {
        throw ApiException('Daily limit reached. Upgrade to Pro for more.', 429, 'QUOTA_EXCEEDED');
      }

      final aiMessageId = 'ai_${DateTime.now().millisecondsSinceEpoch}';
      final aiMessage = ChatMessage(
        id: aiMessageId,
        text: '',
        sender: 'ai',
        timestamp: DateTime.now(),
        isStreaming: true,
        streamingText: 'Processing voice...',
      );

      _addMessagesOptimistically(sessionId, [aiMessage]);

      final audioBytes = await audioFile.readAsBytes();
      final audioBase64 = base64Encode(audioBytes);

      final response = await _apiService.processVoiceCommand(
        audioBase64: audioBase64,
        userId: user.id,
        plan: user.plan,
        sessionId: sessionId,
        idempotencyKey: idempotencyKey,
      );

      final voiceText = response['text'] as String? ?? 'Could not process voice';

      await sendMessage(
        sessionId: sessionId,
        message: voiceText,
        idempotencyKey: idempotencyKey,
      );

    } catch (e, stack) {
      _logger.e('Send voice message failed', error: e, stackTrace: stack);
      _handleStreamingError(sessionId, aiMessageId, 'Voice processing failed');
      rethrow;
    }
  }

  void _addMessagesOptimistically(String sessionId, List<ChatMessage> messages,
      {String? autoTitleFromMessage}) {
    final currentState = state;
    if (currentState is! StreamingChatLoaded) return;

    final sessionIndex = currentState.sessions.indexWhere((s) => s.id == sessionId);
    if (sessionIndex == -1) return;

    final session = currentState.sessions[sessionIndex];
    final updatedMessages = [...session.messages, ...messages];
    final updatedSession = session.copyWith(
      messages: updatedMessages,
      updatedAt: DateTime.now(),
    );

    final updatedSessions = List<ChatSession>.from(currentState.sessions);
    updatedSessions[sessionIndex] = updatedSession;

    state = StreamingChatState.loaded(
      sessions: updatedSessions,
      activeSession: updatedSession,
      typingIndicator: currentState.typingIndicator,
    );
  }

  void _updateStreamingMessage(String sessionId, String messageId, String streamingText) {
    final currentState = state;
    if (currentState is! StreamingChatLoaded) return;

    final sessionIndex = currentState.sessions.indexWhere((s) => s.id == sessionId);
    if (sessionIndex == -1) return;

    final session = currentState.sessions[sessionIndex];
    final messageIndex = session.messages.indexWhere((m) => m.id == messageId);
    if (messageIndex == -1) return;

    final message = session.messages[messageIndex];
    final updatedMessage = message.copyWith(
      streamingText: streamingText,
      isStreaming: true,
    );

    final updatedMessages = List<ChatMessage>.from(session.messages);
    updatedMessages[messageIndex] = updatedMessage;

    final updatedSession = session.copyWith(
      messages: updatedMessages,
      updatedAt: DateTime.now(),
    );

    final updatedSessions = List<ChatSession>.from(currentState.sessions);
    updatedSessions[sessionIndex] = updatedSession;

    state = StreamingChatState.loaded(
      sessions: updatedSessions,
      activeSession: updatedSession,
      typingIndicator: currentState.typingIndicator,
    );
  }

  Future<void> stopGeneration() async {
    final msgId  = _generatingMessageId;
    final sessId = _generatingSessionId;
    if (msgId == null) return;

    // Capture partial text BEFORE finalization (for "Let's Continue" feature)
    final partialText = _streamingMessages[msgId] ?? '';

    try {
      final controller = _streamControllers[msgId];
      if (controller != null && !controller.isClosed) {
        await controller.close();
      }
      _streamControllers.remove(msgId);
      if (sessId != null) {
        _finalizeStreamingMessage(sessId, msgId);
      }
      // Notify backend to cancel the generation
      if (sessId != null) {
        unawaited(_apiService.stopGeneration(sessionId: sessId, messageId: msgId));
      }
      _logger.i('[Chat] Stopped: $msgId (${partialText.length} chars captured)');

      final current = state;
      if (current is StreamingChatLoaded) {
        state = current.copyWith(
          isGenerating: false,
          clearGeneratingId: true,
          stoppedMessageId: msgId,
          stoppedSessionId: sessId,
          stoppedPartialText: partialText.isNotEmpty ? partialText : null,
        );
      }
    } catch (e, stack) {
      _logger.e('stopGeneration failed', error: e, stackTrace: stack);
    } finally {
      _generatingSessionId = null;
      _generatingMessageId = null;
    }
  }

  // "Let's Continue" — resumes stopped AI generation from partial response.
  Future<void> continueGeneration() async {
    final current = state;
    if (current is! StreamingChatLoaded) return;
    if (!current.canContinueGeneration) return;

    final sessionId   = current.stoppedSessionId!;
    final msgId       = current.stoppedMessageId!;
    final partialText = current.stoppedPartialText!;

    final session = current.sessions.firstWhere(
      (s) => s.id == sessionId,
      orElse: () => throw StateError('[Chat] continueGeneration: session not found'),
    );
    final aiIdx = session.messages.indexWhere((m) => m.id == msgId);
    if (aiIdx <= 0) return;

    final userMsg = session.messages
        .sublist(0, aiIdx)
        .lastWhere((m) => m.sender == 'user', orElse: () => session.messages[aiIdx - 1]);

    state = current.copyWith(clearStoppedId: true);

    _logger.i('[Chat] Continuing generation for $msgId (${partialText.length} chars)');

    await sendMessage(
      sessionId:                 sessionId,
      message:                   userMsg.text,
      isContinuation:            true,
      continuationFromMessageId: msgId,
      continuationPartialText:   partialText,
      systemNote: 'Continue your previous response exactly from where it was interrupted. '
                  'Do not repeat what was already said. Resume naturally.',
    );
  }

  Future<void> regenerateMessage(String sessionId, String stoppedAiMessageId) async {
    if (!_userHandler.canSendMessage) {
      final plan = _userHandler.currentUser?.plan.toLowerCase().trim() ?? '';
      final msg = (plan == 'yearly' || plan == 'half_year')
          ? 'Chat limit reached. Go to new chat to regenerate.'
          : 'Your chat limit has been reached. Upgrade to Pro to continue.';
      throw ApiException(msg, 429, 'RATE_LIMIT_REACHED');
    }

    final current = state;
    if (current is! StreamingChatLoaded) return;
    final sessionIdx = current.sessions.indexWhere((s) => s.id == sessionId);
    if (sessionIdx == -1) return;
    final session = current.sessions[sessionIdx];
    final aiMsgIdx = session.messages.indexWhere((m) => m.id == stoppedAiMessageId);
    if (aiMsgIdx <= 0) return;

    final userMsg = session.messages.sublist(0, aiMsgIdx).lastWhere(
      (m) => m.sender == 'user',
      orElse: () => session.messages[aiMsgIdx - 1],
    );

    final trimmed = session.copyWith(
      messages: session.messages.sublist(0, aiMsgIdx),
    );
    final sessions = List<ChatSession>.from(current.sessions)..[sessionIdx] = trimmed;
    state = current.copyWith(
      sessions: sessions,
      activeSession: current.activeSession?.id == sessionId ? trimmed : current.activeSession,
      clearStoppedId: true,
    );

    await sendMessage(sessionId: sessionId, message: userMsg.text,
        attachments: userMsg.attachments);
  }

  void clearStoppedState() {
    final current = state;
    if (current is StreamingChatLoaded) {
      state = current.copyWith(clearStoppedId: true);
    }
  }

  void renameSession(String sessionId, String newTitle) {
    final current = state;
    if (current is! StreamingChatLoaded) return;
    final idx = current.sessions.indexWhere((s) => s.id == sessionId);
    if (idx == -1) return;
    final updated = current.sessions[idx].copyWith(
      title: newTitle.trim().isEmpty ? 'Untitled Chat' : newTitle.trim(),
      titleLocked: true,
    );
    final sessions = List<ChatSession>.from(current.sessions)..[idx] = updated;
    state = current.copyWith(
      sessions: sessions,
      activeSession: current.activeSession?.id == sessionId ? updated : current.activeSession,
    );
    _logger.d('[Chat] Session renamed: $sessionId → ${updated.title}');
  }

  Future<void> likeMessage(String sessionId, String messageId) async {
    _updateMessageReaction(sessionId, messageId, isLiked: true, isDisliked: false);
    try {
      await _apiService.sendMessageFeedback(
        messageId: messageId,
        reaction: 'like',
        feedbackText: null,
      );
    } catch (e) {
      _logger.d('likeMessage API failed (ignored)', error: e);
    }
  }

  Future<void> dislikeMessage(String sessionId, String messageId,
      {String? feedbackText}) async {
    _updateMessageReaction(sessionId, messageId,
        isLiked: false, isDisliked: true, feedbackText: feedbackText);
    try {
      await _apiService.sendMessageFeedback(
        messageId: messageId,
        reaction: 'dislike',
        feedbackText: feedbackText,
      );
    } catch (e) {
      _logger.d('dislikeMessage API failed (ignored)', error: e);
    }
  }


  // ===========================================
  // VOICE SETTINGS API
  // ===========================================


  // ===========================================
  // RATE LIMIT STATUS — synced from backend
  // ===========================================

  Future<RateLimitStatus?> getRateLimitStatus(String userId) async {
    try {
      final r = await _apiClient.get<Map<String, dynamic>>(
        '/api/rate-limit/status',
        userId: userId,
      );
      return RateLimitStatus.fromJson(r);
    } catch (e) {
      _logger.w('[API] getRateLimitStatus failed', error: e);
      return null;
    }
  }

  Future<void> updateUserVoiceSettings({required String userId, required String voiceKey}) async {
    try {
      await _apiClient.put(
        '/users/$userId/voice-settings',
        body: {'voice_key': voiceKey},
        userId: userId,
      );
    } catch (e) {
      _logger.w('[API] updateUserVoiceSettings failed (non-critical)', error: e);
    }
  }

  Future<Map<String, dynamic>> getUserVoiceSettings({required String userId}) async {
    try {
      final r = await _apiClient.get<Map<String, dynamic>>(
        '/users/$userId/voice-settings',
        userId: userId,
      );
      return r;
    } catch (_) {
      return {};
    }
  }

  // ===========================================
  // SEARCH API — /api/search + /api/search/deep-research
  // ===========================================

  Future<Map<String, dynamic>> searchWeb({
    required String query,
    String? modelId,
    required String userId,
    required String plan,
  }) async {
    try {
      final r = await _apiClient.post<Map<String, dynamic>>(
        '/api/search',
        body: {
          'query': query,
          if (modelId != null) 'model': modelId,
        },
        userId: userId,
        plan: plan,
      );
      return r;
    } catch (e, s) {
      _logger.e('[API] searchWeb failed', error: e, stackTrace: s);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> deepResearch({
    required String query,
    required String userId,
    required String plan,
  }) async {
    // Backend enforces plan check — Pro+/Ultra Pro only
    try {
      final r = await _apiClient.post<Map<String, dynamic>>(
        '/api/search/deep-research',
        body: {'query': query},
        userId: userId,
        plan: plan,
      );
      return r;
    } catch (e, s) {
      _logger.e('[API] deepResearch failed', error: e, stackTrace: s);
      rethrow;
    }
  }

  Future<void> reportMessage(String sessionId, String messageId,
      {required String reportText}) async {
    _updateMessageReaction(sessionId, messageId,
        isReported: true, reportText: reportText);
    try {
      await _apiService.reportMessage(
        messageId: messageId,
        reportText: reportText,
      );
    } catch (e) {
      _logger.d('reportMessage API failed (ignored)', error: e);
    }
  }

  void _updateMessageReaction(
    String sessionId,
    String messageId, {
    bool? isLiked,
    bool? isDisliked,
    bool? isReported,
    String? feedbackText,
    String? reportText,
  }) {
    final current = state;
    if (current is! StreamingChatLoaded) return;
    final sessionIdx = current.sessions.indexWhere((s) => s.id == sessionId);
    if (sessionIdx == -1) return;
    final session = current.sessions[sessionIdx];
    final msgIdx = session.messages.indexWhere((m) => m.id == messageId);
    if (msgIdx == -1) return;
    final updated = session.messages[msgIdx].copyWith(
      isLiked: isLiked,
      isDisliked: isDisliked,
      isReported: isReported,
      feedbackText: feedbackText,
      reportText: reportText,
    );
    final msgs = List<ChatMessage>.from(session.messages)..[msgIdx] = updated;
    final updatedSession = session.copyWith(messages: msgs);
    final sessions = List<ChatSession>.from(current.sessions)..[sessionIdx] = updatedSession;
    state = current.copyWith(
      sessions: sessions,
      activeSession: current.activeSession?.id == sessionId ? updatedSession : current.activeSession,
    );
  }

  Future<void> editMessageAndResend({
    required String sessionId,
    required String messageId,
    required String newText,
    List<String>? newAttachments,
  }) async {
    if (!_isInitialized || _isDisposed) return;

    if (!_userHandler.canSendMessage) {
      final plan = _userHandler.currentUser?.plan.toLowerCase().trim() ?? '';
      final msg = (plan == 'yearly' || plan == 'half_year')
          ? 'Chat limit reached. Go to new chat to edit and resend.'
          : 'Your chat limit has been reached. Upgrade to Pro to continue.';
      throw ApiException(msg, 429, 'RATE_LIMIT_REACHED');
    }

    final current = state;
    if (current is! StreamingChatLoaded) return;
    final sessionIdx = current.sessions.indexWhere((s) => s.id == sessionId);
    if (sessionIdx == -1) return;
    final session = current.sessions[sessionIdx];
    final msgIdx = session.messages.indexWhere((m) => m.id == messageId);
    if (msgIdx == -1) return;

    final truncated = session.messages.sublist(0, msgIdx);
    final truncatedSession = session.copyWith(messages: truncated);
    final sessions = List<ChatSession>.from(current.sessions)..[sessionIdx] = truncatedSession;
    state = current.copyWith(
      sessions: sessions,
      activeSession: current.activeSession?.id == sessionId ? truncatedSession : current.activeSession,
    );

    await sendMessage(
      sessionId: sessionId,
      message: newText,
      attachments: newAttachments,
    );
  }

  void _finalizeStreamingMessage(String sessionId, String messageId) {
    final currentState = state;
    if (currentState is! StreamingChatLoaded) return;

    final sessionIndex = currentState.sessions.indexWhere((s) => s.id == sessionId);
    if (sessionIndex == -1) return;

    final session = currentState.sessions[sessionIndex];
    final messageIndex = session.messages.indexWhere((m) => m.id == messageId);
    if (messageIndex == -1) return;

    final message = session.messages[messageIndex];
    final finalText = _streamingMessages[messageId] ?? message.text;
    
    final thinkingBuf  = _thinkingBuffers.remove(messageId);
    final thinkingStr  = thinkingBuf?.toString() ?? '';
    final hadThinking  = thinkingStr.isNotEmpty;
    _isThinkingActive.remove(messageId);
    final modelUsedStr = _modelUsedBuffers.remove(messageId)
        ?? message.metadata?['model_used'] as String?;
    
    final updatedMessage = message.copyWith(
      text: finalText,
      isStreaming: false,
      streamingText: null,
      isThinking: hadThinking,
      thinkingText: hadThinking ? thinkingStr : null,
      modelUsed: modelUsedStr,
      metadata: {
        ...?message.metadata,
        'show_disclaimer': true,
        if (hadThinking) 'thinking_mode': true,
        if (modelUsedStr != null) 'model_used': modelUsedStr,
      },
    );

    final updatedMessages = List<ChatMessage>.from(session.messages);
    updatedMessages[messageIndex] = updatedMessage;

    final updatedSession = session.copyWith(
      messages: updatedMessages,
      updatedAt: DateTime.now(),
    );

    final updatedSessions = List<ChatSession>.from(currentState.sessions);
    updatedSessions[sessionIndex] = updatedSession;

    _generatingSessionId = null;
    _generatingMessageId = null;

    state = StreamingChatState.loaded(
      sessions: updatedSessions,
      activeSession: updatedSession,
      typingIndicator: false,
      isGenerating: false,
      stoppedMessageId: currentState.stoppedMessageId,
      stoppedSessionId: currentState.stoppedSessionId,
    );

    _saveMessageAndSessionAtomic(updatedMessage, sessionId, updatedSession);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToBottomCallback?.call();
    });
    _logger.d('[Stream] Finalized + saved to DB: $messageId');
  }

  void _updateMessage(String sessionId, String messageId, ChatMessage updatedMessage) {
    final currentState = state;
    if (currentState is! StreamingChatLoaded) return;

    final sessionIndex = currentState.sessions.indexWhere((s) => s.id == sessionId);
    if (sessionIndex == -1) return;

    final session = currentState.sessions[sessionIndex];
    final messageIndex = session.messages.indexWhere((m) => m.id == messageId);
    if (messageIndex == -1) return;

    final updatedMessages = List<ChatMessage>.from(session.messages);
    updatedMessages[messageIndex] = updatedMessage;

    final updatedSession = session.copyWith(
      messages: updatedMessages,
      updatedAt: DateTime.now(),
    );

    final updatedSessions = List<ChatSession>.from(currentState.sessions);
    updatedSessions[sessionIndex] = updatedSession;

    state = StreamingChatState.loaded(
      sessions: updatedSessions,
      activeSession: updatedSession,
      typingIndicator: currentState.typingIndicator,
    );

    _saveMessageToDatabase(updatedMessage, sessionId);
    _saveSessionToDatabase(updatedSession);
  }

  void _handleStreamingError(String sessionId, String messageId, String error) {
    // Prevent memory leak: always clear thinking buffer on error
    _thinkingBuffers.remove(messageId);
    _isThinkingActive.remove(messageId);
    _modelUsedBuffers.remove(messageId);
    _streamingMessages.remove(messageId);
    final currentState = state;
    if (currentState is! StreamingChatLoaded) return;

    final sessionIndex = currentState.sessions.indexWhere((s) => s.id == sessionId);
    if (sessionIndex == -1) return;

    final session = currentState.sessions[sessionIndex];
    final messageIndex = session.messages.indexWhere((m) => m.id == messageId);
    if (messageIndex == -1) return;

    final message = session.messages[messageIndex];
    final errorMessage = ChatMessage(
      id: messageId,
      text: 'Error: $error',
      sender: 'ai',
      timestamp: DateTime.now(),
      isStreaming: false,
    );

    final updatedMessages = List<ChatMessage>.from(session.messages);
    updatedMessages[messageIndex] = errorMessage;

    final updatedSession = session.copyWith(
      messages: updatedMessages,
      updatedAt: DateTime.now(),
    );

    final updatedSessions = List<ChatSession>.from(currentState.sessions);
    updatedSessions[sessionIndex] = updatedSession;

    state = StreamingChatState.loaded(
      sessions: updatedSessions,
      activeSession: updatedSession,
      typingIndicator: currentState.typingIndicator,
    );
    
    _saveSessionToDatabase(updatedSession);
    _logger.e('Streaming error: $error');
  }

  Future<void> _saveMessageToDatabase(ChatMessage message, String sessionId) async {
    try {
      final msgToSave = (message.isThinking && message.thinkingText != null)
          ? message.copyWith(
              metadata: {
                ...?message.metadata,
                'thinking_text': message.thinkingText,
                'is_thinking': true,
              },
            )
          : message;
      // E2EE: fail secure — if encryption fails, do NOT save plaintext
      final String encryptedText;
      try {
        encryptedText = await _encryption.encryptChatMessage(sessionId, msgToSave.text);
      } catch (encErr) {
        _logger.e('[E2EE] Encrypt failed — message NOT saved to protect privacy', error: encErr);
        return; // Do not persist unencrypted data
      }
      final companion = LocalChatMessagesCompanion(
        serverId: drift.Value(message.id),
        sessionId: drift.Value(sessionId),
        text: drift.Value(encryptedText),
        sender: drift.Value(message.sender),
        timestamp: drift.Value(message.timestamp),
        isLiked: drift.Value(message.isLiked),
        isDisliked: drift.Value(message.isDisliked),
        isReported: drift.Value(message.isReported),
        parentMessageId: drift.Value(message.parentMessageId),
        attachments: drift.Value(message.attachments != null ? jsonEncode(message.attachments) : null),
        metadataJson: drift.Value(msgToSave.metadata != null ? jsonEncode(msgToSave.metadata) : null),
        isSynced: const drift.Value(false),
        isFailed: const drift.Value(false),
        isStreaming: drift.Value(message.isStreaming),
        streamingText: drift.Value(message.streamingText),
      );
      await _databaseService.insertChatMessage(companion);
      _logger.d('Message saved to database: ${message.id}');
    } catch (e, stack) {
      _logger.e('Save message to database failed', error: e, stackTrace: stack);
    }
  }

  Future<void> _saveSessionToDatabase(ChatSession session) async {
    try {
      final companion = LocalChatSessionsCompanion(
        serverId: drift.Value(session.id),
        title: drift.Value(session.title),
        createdAt: drift.Value(session.createdAt),
        updatedAt: drift.Value(session.updatedAt),
        isPinned: drift.Value(session.isPinned),
        category: drift.Value(session.category),
        sessionDataJson: drift.Value(session.sessionData != null ? jsonEncode(session.sessionData) : null),
        isSynced: const drift.Value(false),
      );
      await _databaseService.insertChatSession(companion);
    } catch (e, stack) {
      _logger.d('Save session to database failed', error: e, stackTrace: stack);
    }
  }

  Future<void> _saveMessageAndSessionAtomic(
    ChatMessage message,
    String sessionId,
    ChatSession session,
  ) async {
    try {
      final msgToSave = (message.isThinking && message.thinkingText != null)
          ? message.copyWith(metadata: {...?message.metadata, 'thinking_text': message.thinkingText, 'is_thinking': true})
          : message;
      String encryptedText;
      try {
        encryptedText = await _encryption.encryptChatMessage(sessionId, msgToSave.text);
      } catch (_) {
        encryptedText = msgToSave.text;
      }
      final msgCompanion = LocalChatMessagesCompanion(
        serverId: drift.Value(message.id),
        sessionId: drift.Value(sessionId),
        text: drift.Value(encryptedText),
        sender: drift.Value(message.sender),
        timestamp: drift.Value(message.timestamp),
        isLiked: drift.Value(message.isLiked),
        isDisliked: drift.Value(message.isDisliked),
        isReported: drift.Value(message.isReported),
        parentMessageId: drift.Value(message.parentMessageId),
        attachments: drift.Value(message.attachments != null ? jsonEncode(message.attachments) : null),
        metadataJson: drift.Value(msgToSave.metadata != null ? jsonEncode(msgToSave.metadata) : null),
        isSynced: const drift.Value(false),
        isFailed: const drift.Value(false),
        isStreaming: drift.Value(message.isStreaming),
        streamingText: drift.Value(message.streamingText),
      );
      final sessionCompanion = LocalChatSessionsCompanion(
        serverId: drift.Value(session.id),
        title: drift.Value(session.title),
        createdAt: drift.Value(session.createdAt),
        updatedAt: drift.Value(session.updatedAt),
        isPinned: drift.Value(session.isPinned),
        category: drift.Value(session.category),
        sessionDataJson: drift.Value(session.sessionData != null ? jsonEncode(session.sessionData) : null),
        isSynced: const drift.Value(false),
      );
      await _databaseService.insertMessageAndSession(msgCompanion, sessionCompanion);
      _logger.d('Atomic save: message+session ${message.id}');
    } catch (e, stack) {
      _logger.e('Atomic save failed', error: e, stackTrace: stack);
    }
  }

  ChatSession _getSessionById(String sessionId) {
    final currentState = state;
    if (currentState is! StreamingChatLoaded) {
      throw Exception('Chat not loaded');
    }
    return currentState.sessions.firstWhere((s) => s.id == sessionId);
  }

  void _showChatLimitError() {
    _logger.w('Chat limit reached');
  }

  Future<void> loadChatHistory(String userId) async {
    if (!_isInitialized || _isDisposed) return;
    
    try {
      state = const StreamingChatState.loading();
      
      try {
        final response = await _apiService.getChatHistoryWithRetry(userId: userId, maxRetries: 3);
        final sessions = (response['sessions'] as List)
            .map((json) => ChatSession.fromJson(json as Map<String, dynamic>))
            .toList();

        for (var session in sessions) {
          await _saveSessionToDatabase(session);
        }

        state = StreamingChatState.loaded(
          sessions: sessions,
          activeSession: sessions.isNotEmpty ? sessions.first : null,
          typingIndicator: false,
        );
        
        _logger.i('Chat history loaded: ${sessions.length} sessions');
      } catch (e) {
        _logger.d('Failed to load from server, loading from database', error: e);
        final localSessions = await _loadSessionsFromDatabase();
        final sessions = localSessions.map((local) => ChatSession(
          id: local.serverId,
          title: local.title,
          messages: [],
          createdAt: local.createdAt,
          updatedAt: local.updatedAt,
          isPinned: local.isPinned,
          category: local.category,
          sessionData: local.sessionDataJson != null 
              ? jsonDecode(local.sessionDataJson!) as Map<String, dynamic>
              : null,
        )).toList();

        for (var session in sessions) {
          final messages = await _databaseService.getChatMessages(session.id);
          final chatMessages = await Future.wait(messages.map((m) async {
            Map<String, dynamic>? metadata;
            List<String>? attachments;
            
            try {
              if (m.metadataJson != null) {
                metadata = jsonDecode(m.metadataJson!) as Map<String, dynamic>;
              }
            } catch (_) {
              metadata = {};
            }
            
            try {
              if (m.attachments != null) {
                attachments = List<String>.from(jsonDecode(m.attachments!));
              }
            } catch (_) {
              attachments = [];
            }

            String decryptedText = m.text;
            try {
              decryptedText = await _encryption.decryptChatMessage(session.id, m.text);
              if (decryptedText == '[E2EE_DECRYPT_FAILED]' || decryptedText == '[E2EE_TAMPERED]') {
                _logger.w('[E2EE] Decrypt failed for message ${m.serverId}, showing placeholder');
              }
            } catch (decErr) {
              _logger.e('[E2EE] Decrypt error for message ${m.serverId}', error: decErr);
            }
            
            return ChatMessage(
              id: m.serverId,
              text: decryptedText,
              sender: m.sender,
              timestamp: m.timestamp,
              isLiked: m.isLiked,
              isDisliked: m.isDisliked,
              isReported: m.isReported,
              parentMessageId: m.parentMessageId,
              attachments: attachments,
              metadata: metadata,
              isStreaming: m.isStreaming,
              streamingText: m.streamingText,
            );
          }));
          
          session = session.copyWith(messages: chatMessages);
        }

        state = StreamingChatState.loaded(
          sessions: sessions,
          activeSession: sessions.isNotEmpty ? sessions.first : null,
          typingIndicator: false,
        );
        
        _logger.i('Loaded ${sessions.length} sessions from database');
      }
    } catch (e, stack) {
      _logger.e('Load chat history failed', error: e, stackTrace: stack);
      state = StreamingChatState.error('Failed to load chat history');
    }
  }

  Future<List<LocalChatSession>> _loadSessionsFromDatabase() async {
    try {
      return await _databaseService.getChatSessions(limit: 100, offset: 0);
    } catch (e, stack) {
      _logger.d('Load sessions from database failed', error: e, stackTrace: stack);
      return [];
    }
  }

  Future<void> createNewChatSession() async {
    if (!_isInitialized || _isDisposed) return;
    
    try {
      final user = _userHandler.currentUser;
      if (user == null) throw Exception('User not authenticated');

      _userHandler.resetUltraProSession();
      
      final sessionId = 'session_${user.id}_${DateTime.now().millisecondsSinceEpoch}';
      final session = ChatSession(
        id: sessionId,
        title: 'New Chat',
        messages: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final currentState = state;
      if (currentState is StreamingChatLoaded) {
        final updatedSessions = [session, ...currentState.sessions];
        final isUserActiveInChat = currentState.activeSession != null &&
            currentState.activeSession!.messages.isNotEmpty;
        state = StreamingChatState.loaded(
          sessions: updatedSessions,
          activeSession: isUserActiveInChat ? currentState.activeSession : session,
          typingIndicator: false,
        );
      }

      await _saveSessionToDatabase(session);
      _logger.i('New chat session created: $sessionId');
      
    } catch (e, stack) {
      _logger.e('Create new chat session failed', error: e, stackTrace: stack);
      rethrow;
    }
  }

  void setTypingIndicator(bool isTyping) {
    final currentState = state;
    if (currentState is StreamingChatLoaded) {
      state = currentState.copyWith(typingIndicator: isTyping);
    }
  }

  Future<void> editMessage({
    required String sessionId,
    required String messageId,
    required String newText,
    List<String>? newAttachments,
  }) async {
    if (!_isInitialized || _isDisposed) return;

    if (!_userHandler.canSendMessage) {
      final plan = _userHandler.currentUser?.plan.toLowerCase().trim() ?? '';
      final msg = (plan == 'yearly' || plan == 'half_year')
          ? 'Chat limit reached. Go to new chat to edit messages.'
          : 'Your chat limit has been reached. Upgrade to Pro to continue.';
      throw ApiException(msg, 429, 'RATE_LIMIT_REACHED');
    }

    final _secGuard = SecurityArchitecture(logger: _logger);
    if (_secGuard.detectPromptInjection(newText)) {
      throw ApiException(
        'Your edited message was blocked by the safety system.',
        400,
        'PROMPT_INJECTION_DETECTED',
      );
    }

    final currentState = state;
    if (currentState is! StreamingChatLoaded) return;

    final sessionIndex = currentState.sessions.indexWhere((s) => s.id == sessionId);
    if (sessionIndex == -1) return;

    final session = currentState.sessions[sessionIndex];
    final msgIndex = session.messages.indexWhere((m) => m.id == messageId);
    if (msgIndex == -1) return;

    final original = session.messages[msgIndex];
    if (original.sender != 'user') return;

    final edited = original.copyWith(
      text: newText,
      attachments: newAttachments ?? original.attachments,
      isEdited: true,
      editedAt: DateTime.now(),
    );

    final updatedMessages = List<ChatMessage>.from(session.messages);
    updatedMessages[msgIndex] = edited;

    if (msgIndex + 1 < updatedMessages.length &&
        updatedMessages[msgIndex + 1].sender == 'ai') {
      updatedMessages.removeAt(msgIndex + 1);
    }

    final updatedSession = session.copyWith(
      messages: updatedMessages,
      updatedAt: DateTime.now(),
    );

    final updatedSessions = List<ChatSession>.from(currentState.sessions);
    updatedSessions[sessionIndex] = updatedSession;

    state = StreamingChatState.loaded(
      sessions: updatedSessions,
      activeSession: updatedSession,
      typingIndicator: false,
    );

    await sendMessage(
      sessionId: sessionId,
      message: newText,
      attachments: newAttachments ?? original.attachments,
    );

    _logger.i('Message edited: $messageId');
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);

    _autoSaveTimer?.cancel();
    _newChatClickResetTimer?.cancel();
    _reconnectTimer?.cancel();

    for (var controller in _streamControllers.values) {
      if (!controller.isClosed) {
        LazyLoader.unregisterController(controller);
        controller.close();
      }
    }
    _streamControllers.clear();
    _streamingMessages.clear();
    _thinkingBuffers.clear();
    _isThinkingActive.clear();
    _modelUsedBuffers.clear();
    _generatingSessionId = null;
    _generatingMessageId = null;
    scrollToBottomCallback = null;

    _logger.d('StreamingChatNotifier disposed');
    super.dispose();
  }
}

@immutable
abstract class StreamingChatState {
  const StreamingChatState();

  List<ChatSession> get sessions;
  ChatSession? get activeSession;
  bool get typingIndicator;
  bool get isGenerating;
  String? get activeGeneratingMessageId;

  const factory StreamingChatState.initial() = InitialStreamingChatState;
  const factory StreamingChatState.loading() = LoadingStreamingChatState;
  const factory StreamingChatState.loaded({
    required List<ChatSession> sessions,
    required ChatSession? activeSession,
    required bool typingIndicator,
    bool isGenerating,
    String? activeGeneratingMessageId,
    String? stoppedMessageId,
    String? stoppedSessionId,
  }) = StreamingChatLoaded;
  const factory StreamingChatState.error(String message) = ErrorStreamingChatState;
}

class InitialStreamingChatState extends StreamingChatState {
  const InitialStreamingChatState();
  @override List<ChatSession> get sessions => [];
  @override ChatSession? get activeSession => null;
  @override bool get typingIndicator => false;
  @override bool get isGenerating => false;
  @override String? get activeGeneratingMessageId => null;
}

class LoadingStreamingChatState extends StreamingChatState {
  const LoadingStreamingChatState();
  @override List<ChatSession> get sessions => [];
  @override ChatSession? get activeSession => null;
  @override bool get typingIndicator => false;
  @override bool get isGenerating => false;
  @override String? get activeGeneratingMessageId => null;
}

class StreamingChatLoaded extends StreamingChatState {
  @override final List<ChatSession> sessions;
  @override final ChatSession? activeSession;
  @override final bool typingIndicator;
  @override final bool isGenerating;
  @override final String? activeGeneratingMessageId;

  final String? stoppedMessageId;
  final String? stoppedSessionId;
  final String? stoppedPartialText;

  const StreamingChatLoaded({
    required this.sessions,
    required this.activeSession,
    required this.typingIndicator,
    this.isGenerating = false,
    this.activeGeneratingMessageId,
    this.stoppedMessageId,
    this.stoppedSessionId,
    this.stoppedPartialText,
  });

  // True when generation stopped mid-stream and user can resume with "Let's Continue"
  bool get canContinueGeneration =>
      stoppedMessageId != null &&
      stoppedSessionId != null &&
      stoppedPartialText != null &&
      stoppedPartialText!.isNotEmpty;

  StreamingChatLoaded copyWith({
    List<ChatSession>? sessions,
    ChatSession? activeSession,
    bool? typingIndicator,
    bool? isGenerating,
    String? activeGeneratingMessageId,
    bool clearGeneratingId = false,
    String? stoppedMessageId,
    String? stoppedSessionId,
    String? stoppedPartialText,
    bool clearStoppedId = false,
  }) {
    return StreamingChatLoaded(
      sessions: sessions ?? this.sessions,
      activeSession: activeSession ?? this.activeSession,
      typingIndicator: typingIndicator ?? this.typingIndicator,
      isGenerating: isGenerating ?? this.isGenerating,
      activeGeneratingMessageId: clearGeneratingId
          ? null
          : (activeGeneratingMessageId ?? this.activeGeneratingMessageId),
      stoppedMessageId:   clearStoppedId ? null : (stoppedMessageId   ?? this.stoppedMessageId),
      stoppedSessionId:   clearStoppedId ? null : (stoppedSessionId   ?? this.stoppedSessionId),
      stoppedPartialText: clearStoppedId ? null : (stoppedPartialText ?? this.stoppedPartialText),
    );
  }
}

class ErrorStreamingChatState extends StreamingChatState {
  final String message;
  const ErrorStreamingChatState(this.message);
  @override List<ChatSession> get sessions => [];
  @override ChatSession? get activeSession => null;
  @override bool get typingIndicator => false;
  @override bool get isGenerating => false;
  @override String? get activeGeneratingMessageId => null;
}

// ===========================================
// FIXED: WAKEWORD DETECTION PROVIDER
// ===========================================
final wakeWordProvider = StateNotifierProvider<WakeWordNotifier, WakeWordState>((ref) {
  return WakeWordNotifier(ref);
});

class WakeWordNotifier extends StateNotifier<WakeWordState> with WidgetsBindingObserver {
  final Ref ref;
  late final ProductionLogger _logger;
  late final WebSocketService _webSocket;
  late final GlobalUserHandler _userHandler;
  final AudioRecorder _audioRecorder = AudioRecorder();
  Timer? _recordingTimer;
  StreamSubscription<Map<String, dynamic>>? _wakeWordSubscription;
  final ProductionThrottler _wakeWordThrottler = ProductionThrottler(milliseconds: 3000);
  static const int _cooldownSeconds   = 30;
  static const int _maxPerHour        = 3;
  static const int _maxPerDay         = 5;
  final List<DateTime> _activationLog = [];
  DateTime? _lastActivationTime;
  final List<int> _audioBuffer = [];
  static const int _bufferSize = 16000;
  bool _isRecording = false;
  bool _isInitialized = false;
  bool _isDisposed = false;
  bool _pendingPermissionResume = false;
  final Lock _audioLock = Lock();

  WakeWordNotifier(this.ref) : super(const WakeWordState.idle()) {
    WidgetsBinding.instance.addObserver(this);
    _initialize();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState appState) {
    if (appState == AppLifecycleState.resumed && _pendingPermissionResume) {
      _pendingPermissionResume = false;
      initialize();
    }
  }

  Future<void> _initialize() async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      _logger = ref.read(loggerProvider);
      _logger.i('WakeWordNotifier: wake word detection disabled on this platform');
      return;
    }
    try {
      _logger = ref.read(loggerProvider);
      _webSocket = await ref.read(webSocketFutureProvider.future);
      _userHandler = await ref.read(globalUserHandlerFutureProvider.future);
      
      _isInitialized = true;
    } catch (e, stack) {
      _logger.e('WakeWordNotifier initialization failed', error: e, stackTrace: stack);
    }
  }

  Future<void> initialize() async {
    if (!_isInitialized || _isDisposed) return;

    // iOS: wake word detection via background mic is not reliable due to OS restrictions
    // It works only in foreground. Background detection requires a native plugin.
    if (!kIsWeb && Platform.isIOS) {
      _logger.w('[WakeWord] iOS background mic detection is unreliable — foreground only');
      state = const WakeWordState.idle();
    }

    // Android: check battery optimization exemption
    if (!kIsWeb && Platform.isAndroid) {
      final batteryOptStatus = await Permission.ignoreBatteryOptimizations.status;
      if (!batteryOptStatus.isGranted) {
        _logger.w('[WakeWord] Battery optimization active — wake word may be killed by OS. '
            'Guide user to exempt app in Settings > Battery > Unrestricted.');
      }
    }

    try {
      final status = await Permission.microphone.request();
      if (!status.isGranted) {
        if (status.isPermanentlyDenied) {
          state = const WakeWordState.error('Microphone permission permanently denied. Please enable in settings.');
          _pendingPermissionResume = true;
          await openAppSettings();
        } else {
          state = const WakeWordState.error('Microphone permission denied');
        }
        _logger.w('Microphone permission denied');
        return;
      }

      if (kIsWeb) {
        state = const WakeWordState.error('Wake word detection not supported on web');
        return;
      }

      await _webSocket.connectWakeWordDetection(wakePhrases: ['hey_askroa', 'askroa']);

      _wakeWordSubscription = _webSocket.subscribeToWakeWord().listen(_handleWakeWordDetection);

      state = const WakeWordState.ready();
      
      _logger.i('Wake word detection initialized');
    } catch (e, stack) {
      _logger.e('Failed to initialize wake word detection', error: e, stackTrace: stack);
      state = WakeWordState.error('Failed to initialize wake word detection: ${e.toString()}');
    }
  }

  Future<void> startListening() async {
    if (!_isInitialized || _isDisposed) return;
    
    await _audioLock.acquire();
    try {
      if (!_wakeWordThrottler.isThrottled) {
        _wakeWordThrottler.run(() {});
      } else {
        _logger.d('Wake word throttled');
        return;
      }

      if (state is! WakeWordReady && state is! WakeWordIdle) {
        return;
      }

      final now = DateTime.now();

      if (_lastActivationTime != null) {
        final elapsed = now.difference(_lastActivationTime!).inSeconds;
        if (elapsed < _cooldownSeconds) {
          final remaining = _cooldownSeconds - elapsed;
          state = WakeWordState.error(
              'Wake word cooldown: please wait ${remaining}s before saying "Askroa" again.');
          _logger.w('[WakeWord] Cooldown active: ${remaining}s remaining');
          return;
        }
      }

      _activationLog.removeWhere((t) => now.difference(t).inHours >= 24);

      final recentHour = _activationLog
          .where((t) => now.difference(t).inHours < 1)
          .length;
      if (recentHour >= _maxPerHour) {
        state = const WakeWordState.error(
            'Wake word hourly limit reached (3/hour). Please try again later.');
        _logger.w('[WakeWord] Hourly limit reached');
        return;
      }

      if (_activationLog.length >= _maxPerDay) {
        state = const WakeWordState.error(
            'Wake word daily limit reached (5/day). Please try again tomorrow.');
        _logger.w('[WakeWord] Daily limit reached');
        return;
      }

      _lastActivationTime = now;
      _activationLog.add(now);

      final user = _userHandler.currentUser;
      if (user == null || !_userHandler.canSendMessage) {
        state = const WakeWordState.error('Voice feature not available');
        _logger.w('Voice feature not available');
        return;
      }

      if (!kIsWeb && Platform.isAndroid) {
        try {
          final service = FlutterBackgroundService();
          final isRunning = await service.isRunning();
          if (isRunning) {
            service.invoke('setAsForeground');
            _logger.d('[WakeWord] Promoted to foreground service');
          } else {
            _logger.w('[WakeWord] Background service not running — '
                'mic may be killed by OS on battery optimisation');
          }
        } catch (e) {
          _logger.d('[WakeWord] Foreground service promotion failed', error: e);
        }
      }

      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: 16000,
          numChannels: 1,
        ),
      );

      _isRecording = true;
      _audioBuffer.clear();
      state = const WakeWordState.listening();
      _startAudioStreaming();

      _logger.d('[WakeWord] "Hey Askroa" listening started (foreground service active)');
    } catch (e, stack) {
      _logger.e('Failed to start listening', error: e, stackTrace: stack);
      state = WakeWordState.error('Failed to start listening: ${e.toString()}');
    } finally {
      _audioLock.release();
    }
  }

  Future<void> stopListening() async {
    await _audioLock.acquire();
    try {
      _recordingTimer?.cancel();
      _recordingTimer = null;
      _isRecording = false;
      _audioBuffer.clear();
      await _audioRecorder.stop();

      if (!kIsWeb && Platform.isAndroid) {
        try {
          FlutterBackgroundService().invoke('setAsBackground');
        } catch (e) {
          _logger.d('[WakeWord] Foreground service demotion failed', error: e);
        }
      }

      if (_webSocket.isWakeWordConnected.value) {
        state = const WakeWordState.ready();
      } else {
        state = const WakeWordState.idle();
      }

      _logger.d('[WakeWord] "Hey Askroa" listening stopped');
    } catch (e, stack) {
      _logger.d('Stop listening failed', error: e, stackTrace: stack);
      state = const WakeWordState.idle();
    } finally {
      _audioLock.release();
    }
  }

  void _startAudioStreaming() {
    _recordingTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) async {
      try {
        if (!_isRecording || !_webSocket.isWakeWordConnected.value || _isDisposed) {
          timer.cancel();
          return;
        }

        final audioFile = await _audioRecorder.stop();
        if (audioFile != null && await audioFile.exists()) {
          final bytes = await audioFile.readAsBytes();
          _audioBuffer.addAll(bytes);
          
          while (_audioBuffer.length >= _bufferSize) {
            final chunk = _audioBuffer.take(_bufferSize).toList();
            _audioBuffer.removeRange(0, _bufferSize);
            
            await _webSocket.sendAudioChunk(chunk);
          }
          
          await audioFile.delete();
        }
        
        await _audioRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.pcm16bits,
            sampleRate: 16000,
            numChannels: 1,
          ),
        );
      } catch (e) {
        _logger.d('Audio streaming error', error: e);
      }
    });
  }

  void _handleWakeWordDetection(Map<String, dynamic> data) {
    try {
      final wakeWord = data['wake_word'] as String?;
      final confidence = data['confidence'] as double?;
      
      final isWakeWordMatch = wakeWord == 'hey askroa' ||
          wakeWord == 'hey_askroa' ||
          wakeWord == 'askroa';
      if (isWakeWordMatch && confidence != null && confidence > 0.8) {
        state = WakeWordState.detected(
          wakeWord: 'hey askroa',
          confidence: confidence,
        );
        
        _logger.i('Wake word detected: "Hey Askroa" (confidence: $confidence)');
        
        stopListening();
        _triggerVoiceAssistant();
      }
    } catch (e, stack) {
      _logger.d('Handle wake word detection failed', error: e, stackTrace: stack);
    }
  }

  bool _voiceTriggerPending = false;

  Timer? _voiceTriggerTimer;

  void _triggerVoiceAssistant() {
    if (_voiceTriggerPending || _isDisposed) return;
    _voiceTriggerPending = true;
    _voiceTriggerTimer?.cancel();
    _voiceTriggerTimer = Timer(const Duration(milliseconds: 500), () {
      _voiceTriggerPending = false;
      if (_isDisposed) return;
    try {
      final deepLinking = ref.read(deepLinkingProvider);
      final navigatorContext = deepLinking.navigatorKey.currentContext;
      final navigatorState = deepLinking.navigatorKey.currentState;
      if (navigatorContext != null &&
          navigatorContext.mounted &&
          navigatorState != null) {
        GoRouter.of(navigatorContext).push('/voice');
        _logger.d('[WakeWord] Navigated to /voice via global navigator key');
      } else {
        _logger.w('[WakeWord] _triggerVoiceAssistant: navigator context unavailable'
            ' (context=${navigatorContext != null}, mounted=${navigatorContext?.mounted}, state=${navigatorState != null})');
      }
    } catch (e, stack) {
      _logger.e('_triggerVoiceAssistant failed', error: e, stackTrace: stack);
    }
    }); // end Future.delayed debounce
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _recordingTimer?.cancel();
    _wakeWordSubscription?.cancel();
    _audioRecorder.dispose();
    _wakeWordThrottler.dispose();
    _audioBuffer.clear();
    _voiceTriggerTimer?.cancel();
    _voiceTriggerTimer = null;
    _voiceTriggerPending = false;
    _logger.d('WakeWordNotifier disposed');
    super.dispose();
  }
}

@immutable
abstract class WakeWordState {
  const WakeWordState();

  const factory WakeWordState.idle() = WakeWordIdle;
  const factory WakeWordState.ready() = WakeWordReady;
  const factory WakeWordState.listening() = WakeWordListening;
  const factory WakeWordState.detected({
    required String wakeWord,
    required double confidence,
  }) = WakeWordDetected;
  const factory WakeWordState.error(String message) = WakeWordError;
}

class WakeWordIdle extends WakeWordState {
  const WakeWordIdle();
}

class WakeWordReady extends WakeWordState {
  const WakeWordReady();
}

class WakeWordListening extends WakeWordState {
  const WakeWordListening();
}

class WakeWordDetected extends WakeWordState {
  final String wakeWord;
  final double confidence;

  const WakeWordDetected({
    required this.wakeWord,
    required this.confidence,
  });
}

class WakeWordError extends WakeWordState {
  final String message;

  const WakeWordError(this.message);
}

// ===========================================
// FIXED: VOICE PROVIDER
// ===========================================
final voiceProvider = StateNotifierProvider<VoiceNotifier, VoiceState>((ref) {
  return VoiceNotifier(ref);
});

class VoiceNotifier extends StateNotifier<VoiceState> {
  final Ref ref;
  late final ProductionLogger _logger;
  late final ProductionApiService _apiService;
  late final GlobalUserHandler _userHandler;
  late final StreamingChatNotifier _chatNotifier;
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterTts _tts = FlutterTts();
  late final PerformanceOptimizer _performance;
  late final RateLimitingService _rateLimiter;
  late final IdempotencyService _idempotency;
  DateTime? _lastVoiceStartTime;
  String? _currentSessionId;
  String? _currentAudioPath;
  bool _isInitialized = false;
  bool _isDisposed = false;
  final Lock _voiceLock = Lock();

  VoiceNotifier(this.ref) : super(const VoiceState.idle()) {
    _initialize();
  }

  Future<void> _initialize() async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      _logger = ref.read(loggerProvider);
      _logger.i('VoiceNotifier: voice features disabled on this platform (${kIsWeb ? "web" : Platform.operatingSystem})');
      return;
    }
    try {
      _logger = ref.read(loggerProvider);
      _apiService = await ref.read(apiServiceProvider.future);
      _userHandler = await ref.read(globalUserHandlerFutureProvider.future);
      _chatNotifier = ref.read(streamingChatProvider.notifier);
      _performance = await ref.read(performanceOptimizerFutureProvider.future);
      _rateLimiter = await ref.read(rateLimitingFutureProvider.future);
      _idempotency = await ref.read(idempotencyServiceFutureProvider.future);
      
      _isInitialized = true;
    } catch (e, stack) {
      _logger.e('VoiceNotifier initialization failed', error: e, stackTrace: stack);
    }
  }

  Future<void> startListening({String? sessionId}) async {
    if (!_isInitialized || _isDisposed) return;
    
    await _voiceLock.acquire();
    try {
      if (kIsWeb) {
        state = const VoiceState.error('Voice features not supported on web');
        return;
      }
      
      final user = _userHandler.currentUser;
      if (user == null) throw Exception('User not authenticated');
      
      if (!_userHandler.canSendMessage) {
        final errorMsg = user.plan.toLowerCase().trim() == 'yearly'
            ? 'Chat limit reached. Go to new chat.'
            : 'Your voice limit has been reached. Please go to Pro plan.';
        state = VoiceState.error(errorMsg);
        _logger.w('Voice limit reached (plan: ${user.plan})');
        return;
      }

      if (!_userHandler.checkVoiceCooldown()) {
        final remaining = _userHandler.getVoiceCooldownRemaining();
        state = VoiceState.error('Please wait $remaining seconds before starting voice recording again.');
        _logger.w('Voice cooldown active: ${remaining}s remaining');
        return;
      }
      
      final quotaRemaining = _rateLimiter.getRemainingQuota(user.id, user.plan);
      if (quotaRemaining <= 0 && !user.isPremium) {
        state = const VoiceState.error('Daily limit reached. Upgrade to Pro for more.');
        _logger.w('Daily quota exceeded for voice');
        return;
      }

      final status = await Permission.microphone.request();
      if (!status.isGranted) {
        if (status.isPermanentlyDenied) {
          state = const VoiceState.error('Microphone permission permanently denied. Please enable it in settings.');
          await openAppSettings();
        } else {
          state = const VoiceState.error('Microphone permission denied');
        }
        _logger.w('Microphone permission denied');
        return;
      }

      final available = await _speechToText.initialize();
      if (!available) {
        state = const VoiceState.error('Speech recognition not available');
        _logger.w('Speech recognition not available');
        return;
      }

      _currentAudioPath = await _getTempAudioPath();
      await _audioRecorder.start(
        RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 16000,
          numChannels: 1,
        ),
        path: _currentAudioPath,
      );

      await _speechToText.listen(
        onResult: (result) {
          if (result.finalResult) {
            _processVoiceCommand(result.recognizedWords, sessionId);
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 6),
        partialResults: true,
        onSoundLevelChange: (level) {
          if (state is VoiceListening) {
            _performance.throttle(() {
              state = VoiceListening(level: level);
            }, duration: const Duration(milliseconds: 50));
          }
        },
      );

      _lastVoiceStartTime = DateTime.now();
      _currentSessionId = sessionId;
      state = const VoiceListening(level: 0);
      _userHandler.isVoiceActive.value = true;
      _logger.d('Voice listening started');
    } catch (e, stack) {
      _logger.e('Failed to start listening', error: e, stackTrace: stack);
      state = VoiceState.error('Failed to start listening: ${e.toString()}');
    } finally {
      _voiceLock.release();
    }
  }

  Future<void> stopListening() async {
    await _voiceLock.acquire();
    try {
      await _speechToText.stop();
      await _audioRecorder.stop();
      state = const VoiceState.processing();
      _userHandler.isVoiceActive.value = false;
      _logger.d('Voice listening stopped');
      if (_isTtsPending && _pendingTtsText != null) {
        final pending = _pendingTtsText!;
        _isTtsPending = false;
        _pendingTtsText = null;
        unawaited(_executeTts(pending));
      }
    } catch (e, stack) {
      _logger.d('Stop listening failed', error: e, stackTrace: stack);
      state = const VoiceState.idle();
      _userHandler.isVoiceActive.value = false;
    } finally {
      _voiceLock.release();
    }
  }

  Future<void> _processVoiceCommand(String text, String? sessionId) async {
    try {
      state = const VoiceState.processing();

      final user = _userHandler.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final audioFile = File(_currentAudioPath!);
      if (!await audioFile.exists()) {
        throw Exception('Audio file not found');
      }
      
      final audioBytes = await audioFile.readAsBytes();
      final audioBase64 = base64Encode(audioBytes);

      final idempotencyKey = _idempotency.generateKey(
        userId: user.id,
        operation: 'voice_command',
        entity: 'voice',
        entityId: sessionId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      );

      await _userHandler.decrementRequest();

      final currentSessionId = sessionId ?? _currentSessionId ?? 'voice_session_${user.id}_${DateTime.now().millisecondsSinceEpoch}';

      final response = await _apiService.processVoiceCommand(
        audioBase64: audioBase64,
        userId: user.id,
        plan: user.plan,
        sessionId: currentSessionId,
        idempotencyKey: idempotencyKey,
      );

      final recognizedText  = response['text'] as String? ?? text;
      final commandType     = response['command_type'] as String? ?? 'chat';
      final backendLangCode = response['language_code'] as String?;

      _logger.d('[Voice] processed: "$recognizedText" type=$commandType lang=$backendLangCode');

      if (commandType == 'chat') {
        await _chatNotifier.sendMessage(
          sessionId: currentSessionId,
          message: recognizedText,
          idempotencyKey: idempotencyKey,
          languageCode: backendLangCode,
        );
      } else if (commandType == 'action') {
        final result = response['result'] as String?;
        if (result != null) {
          state = VoiceState.result(
            text: recognizedText,
            response: result,
          );
        }
      }

      if (await audioFile.exists()) {
        await audioFile.delete();
      }
      _currentAudioPath = null;

    } catch (e, stack) {
      _logger.e('Voice processing failed', error: e, stackTrace: stack);
      state = VoiceState.error('Voice processing failed: ${e.toString()}');
    }
  }

  bool _isTtsPending = false;
  String? _pendingTtsText;
  String? _pendingTtsLang;
  List<String> _availableTtsLanguages = [];
  bool _ttsLangsLoaded = false;

  static const int _ttsChunkSize = 400;

  static const List<_TtsLangEntry> _kLangScripts = [
    _TtsLangEntry(r'[\u0980-\u09FF]', 'bn-BD', 0.80),
    _TtsLangEntry(r'[\u0900-\u097F]', 'hi-IN', 0.82),
    _TtsLangEntry(r'[\u0600-\u06FF]', 'ar-SA', 0.78),
    _TtsLangEntry(r'[\u4E00-\u9FFF\u3400-\u4DBF]', 'zh-CN', 0.82),
    _TtsLangEntry(r'[\u3040-\u309F\u30A0-\u30FF]', 'ja-JP', 0.82),
    _TtsLangEntry(r'[\uAC00-\uD7AF]', 'ko-KR', 0.83),
    _TtsLangEntry(r'[\u0400-\u04FF]', 'ru-RU', 0.87),
    _TtsLangEntry(r'[\u0E00-\u0E7F]', 'th-TH', 0.80),
    _TtsLangEntry(r'[\u0A00-\u0A7F]', 'pa-IN', 0.82),
    _TtsLangEntry(r'[\u0B80-\u0BFF]', 'ta-IN', 0.82),
    _TtsLangEntry(r'[\u0C00-\u0C7F]', 'te-IN', 0.82),
    _TtsLangEntry(r'[\u0D00-\u0D7F]', 'ml-IN', 0.82),
    _TtsLangEntry(r'[\u0C80-\u0CFF]', 'kn-IN', 0.82),
    _TtsLangEntry(r'[\u0B00-\u0B7F]', 'or-IN', 0.82),
    _TtsLangEntry(r'[\u0A80-\u0AFF]', 'gu-IN', 0.82),
    _TtsLangEntry(r'[\u0D80-\u0DFF]', 'si-LK', 0.80),
    _TtsLangEntry(r'[\u0F00-\u0FFF]', 'bo-CN', 0.78),
    _TtsLangEntry(r'[\u1000-\u109F]', 'my-MM', 0.80),
    _TtsLangEntry(r'[\u1780-\u17FF]', 'km-KH', 0.80),
    _TtsLangEntry(r'[\u0E80-\u0EFF]', 'lo-LA', 0.80),
    _TtsLangEntry(r'[\u1700-\u171F]', 'fil-PH', 0.88),
    _TtsLangEntry(r'[\u10D0-\u10FF]', 'ka-GE', 0.83),
    _TtsLangEntry(r'[\u0560-\u058F\uFB13-\uFB17]', 'hy-AM', 0.83),
    _TtsLangEntry(r'[\u05D0-\u05FF]', 'he-IL', 0.83),
    _TtsLangEntry(r'[\u0370-\u03FF]', 'el-GR', 0.87),
    _TtsLangEntry(r'[\u00C0-\u00D6\u00D8-\u00F6\u1E80-\u1EBF]', 'fr-FR', 0.90),
    _TtsLangEntry(r'[\u00C4\u00D6\u00DC\u00E4\u00F6\u00FC\u00DF]', 'de-DE', 0.90),
    _TtsLangEntry(r'[\u00F1\u00E9\u00ED\u00F3\u00FA\u00C1]', 'es-ES', 0.90),
    _TtsLangEntry(r'[\u00C3\u00E3\u00E7\u00EA\u00F5]', 'pt-PT', 0.90),
    _TtsLangEntry(r'[\u00E0\u00E8\u00E9\u00F9\u00EC\u00F2]', 'it-IT', 0.90),
    _TtsLangEntry(r'[\u0131\u011F\u015F\u00E7]', 'tr-TR', 0.88),
    _TtsLangEntry(r'[\u0430-\u044F]', 'uk-UA', 0.87),
    _TtsLangEntry(r'[\u0450-\u045F]', 'be-BY', 0.87),
    _TtsLangEntry(r'[\u0460-\u047F]', 'mk-MK', 0.87),
    _TtsLangEntry(r'[\u1E00-\u1E1F]', 'pl-PL', 0.88),
    _TtsLangEntry(r'[\u017D\u017E\u010C\u010D]', 'cs-CZ', 0.88),
    _TtsLangEntry(r'[\u0150\u0151\u0170\u0171]', 'hu-HU', 0.88),
    _TtsLangEntry(r'[\u0218\u0219\u021A\u021B]', 'ro-RO', 0.88),
    _TtsLangEntry(r'[\u0116\u0117\u0100\u0101]', 'lv-LV', 0.88),
    _TtsLangEntry(r'[\u012E\u012F\u0160\u0161]', 'lt-LT', 0.88),
    _TtsLangEntry(r'[\u00E6\u00F8\u00E5]', 'da-DK', 0.90),
    _TtsLangEntry(r'[\u00E5\u00E4\u00F6]', 'sv-SE', 0.90),
    _TtsLangEntry(r'[\u00E6\u00F8\u00E5\u00F0]', 'nb-NO', 0.90),
    _TtsLangEntry(r'[\u1200-\u137F]', 'am-ET', 0.80),
    _TtsLangEntry(r'[\u0600-\u060B\u060D-\u061A]', 'fa-IR', 0.80),
    _TtsLangEntry(r'[\u0628\u067E\u0679]', 'ur-PK', 0.80),
    _TtsLangEntry(r'[\u1680-\u169F]', 'ga-IE', 0.88),
    _TtsLangEntry(r'[\u0180-\u024F]', 'ca-ES', 0.88),
    _TtsLangEntry(r'[\uA000-\uA48F]', 'vi-VN', 0.85),
    _TtsLangEntry(r'[\u1E60-\u1E9F]', 'cy-GB', 0.88),
    _TtsLangEntry(r'[\u1B00-\u1B7F]', 'id-ID', 0.88),
    _TtsLangEntry(r'[\u1C00-\u1C4F]', 'ms-MY', 0.88),
    _TtsLangEntry(r'[\u0620-\u063A\u0641-\u064A]', 'ar-SA', 0.78),
  ];

  Future<void> _loadAvailableTtsLanguages() async {
    if (_ttsLangsLoaded) return;
    try {
      final raw = await _tts.getLanguages;
      _availableTtsLanguages = (raw as List<dynamic>)
          .map((e) => e.toString().trim())
          .where((s) => s.isNotEmpty)
          .toList();
      _logger.d('[TTS] Device supports ${_availableTtsLanguages.length} languages');
    } catch (e) {
      _logger.w('[TTS] Could not load language list', error: e);
    } finally {
      _ttsLangsLoaded = true;
    }
  }

  String _resolveLocale(String requested) {
    if (_availableTtsLanguages.isEmpty) return requested;
    if (_availableTtsLanguages.contains(requested)) return requested;
    final prefix = requested.split('-').first.toLowerCase();
    return _availableTtsLanguages.firstWhere(
      (l) => l.toLowerCase().startsWith(prefix),
      orElse: () => 'en-US',
    );
  }

  String _detectLanguage(String text, {String? backendLocale}) {
    if (backendLocale != null && backendLocale.isNotEmpty) {
      return _resolveLocale(backendLocale);
    }
    for (final entry in _kLangScripts) {
      if (entry.pattern.hasMatch(text)) return _resolveLocale(entry.locale);
    }
    return _resolveLocale('en-US');
  }

  double _rateForLocale(String locale) {
    for (final entry in _kLangScripts) {
      if (locale.startsWith(entry.locale.split('-').first)) return entry.rate;
    }
    return 0.90;
  }

  List<String> _chunkText(String text, String locale) {
    final sz = (locale.startsWith('zh') || locale.startsWith('ja'))
        ? _ttsChunkSize ~/ 2
        : _ttsChunkSize;
    if (text.length <= sz) return [text];
    final chunks = <String>[];
    var start = 0;
    while (start < text.length) {
      var end = min(start + sz, text.length);
      if (end < text.length) {
        final brk = text.lastIndexOf(RegExp(r'[.!?;\n\r\u3002\u0964\u06D4\u0589\u2026]'), end);
        if (brk > start) end = brk + 1;
      }
      final chunk = text.substring(start, end).trim();
      if (chunk.isNotEmpty) chunks.add(chunk);
      start = end;
    }
    return chunks;
  }

  Future<void> speakText(String text, {String? languageCode, bool forceFlutter = false}) async {
    if (text.trim().isEmpty) return;

    // ElevenLabs TTS for frontend text-reading; wake-word TTS is server-side
    final voiceSettings = ref.read(voiceSettingsProvider);
    if (!forceFlutter && voiceSettings.useElevenLabs && !kIsWeb) {
      try {
        state = const VoiceState.speaking();
        await ref.read(elevenLabsTtsProvider).speak(
          text,
          voiceKey: voiceSettings.voiceKey,
          onDone: () {
            if (!_isDisposed && state is SpeakingVoiceState) state = const VoiceState.idle();
          },
        );
        _logger.d('[Voice] ElevenLabs TTS: ${text.length} chars, voice=${voiceSettings.voiceKey}');
        return;
      } catch (e) {
        _logger.w('[Voice] ElevenLabs failed, fallback to Flutter TTS', error: e);
      }
    }

    final isRecording = await _audioRecorder.isRecording();
    if (isRecording) {
      _isTtsPending   = true;
      _pendingTtsText = text;
      _pendingTtsLang = languageCode;
      _logger.d('[TTS] Queued — mic active');
      return;
    }
    await _executeTts(text, languageCode: languageCode);
  }

  Future<void> _executeTts(String text, {String? languageCode}) async {
    if (_isDisposed || text.trim().isEmpty) return;
    try {
      await _loadAvailableTtsLanguages();
      state = const VoiceState.speaking();

      final lang   = _detectLanguage(text, backendLocale: languageCode);
      final rate   = _rateForLocale(lang);
      final chunks = _chunkText(text, lang);

      await _tts.setLanguage(lang);
      await _tts.setSpeechRate(rate);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      await _tts.awaitSpeakCompletion(true);

      _logger.d('[TTS] lang=$lang rate=$rate chunks=${chunks.length}');

      for (final chunk in chunks) {
        if (_isDisposed) break;
        await _tts.speak(chunk).timeout(
          Duration(seconds: max(20, chunk.length ~/ 8)),
          onTimeout: () async {
            await _tts.stop();
            throw TimeoutException('[TTS] chunk timeout');
          },
        );
        await _tts.awaitSpeakCompletion(true);
      }

      if (!_isDisposed) state = const VoiceState.idle();
      _logger.d('[TTS] Done: "${text.substring(0, min(60, text.length))}..."');
    } on TimeoutException catch (e) {
      _logger.w('[TTS] Timeout', error: e);
      await _tts.stop();
      if (!_isDisposed) state = const VoiceState.idle();
    } catch (e, stack) {
      _logger.e('[TTS] Failed', error: e, stackTrace: stack);
      if (!_isDisposed) state = const VoiceState.idle();
    } finally {
      if (_isTtsPending && _pendingTtsText != null) {
        final txt  = _pendingTtsText!;
        final lang = _pendingTtsLang;
        _isTtsPending   = false;
        _pendingTtsText = null;
        _pendingTtsLang = null;
        unawaited(_executeTts(txt, languageCode: lang));
      }
    }
  }

  Future<String> _getTempAudioPath() async {
    final tempDir = await getTemporaryDirectory();
    return '${tempDir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.wav';
  }

  @override
  void dispose() {
    _isDisposed = true;
    // Stop ElevenLabs TTS if active
    try { ref.read(elevenLabsTtsProvider).stop(); } catch (_) {}
    _isTtsPending = false;
    _pendingTtsText = null;
    _pendingTtsLang = null;
    _availableTtsLanguages.clear();
    _ttsLangsLoaded = false;
    if (_currentAudioPath != null) {
      try { File(_currentAudioPath!).deleteSync(); } catch (_) {}
      _currentAudioPath = null;
    }
    try { _speechToText.stop(); } catch (_) {}
    try { _audioRecorder.dispose(); } catch (_) {}
    try { _audioPlayer.dispose(); } catch (_) {}
    try { _tts.stop(); } catch (_) {}
    _logger.d('VoiceNotifier disposed');
    super.dispose();
  }
}

class _TtsLangEntry {
  final RegExp pattern;
  final String locale;
  final double rate;
  _TtsLangEntry(String pat, this.locale, this.rate)
      : pattern = RegExp(pat, unicode: true);
}

@immutable
abstract class VoiceState {
  const VoiceState();

  const factory VoiceState.idle() = IdleVoiceState;
  const factory VoiceState.listening({required double level}) = VoiceListening;
  const factory VoiceState.processing() = ProcessingVoiceState;
  const factory VoiceState.result({
    required String text,
    required String response,
  }) = ResultVoiceState;
  const factory VoiceState.speaking() = SpeakingVoiceState;
  const factory VoiceState.error(String message) = ErrorVoiceState;
}

class IdleVoiceState extends VoiceState {
  const IdleVoiceState();
}

class VoiceListening extends VoiceState {
  final double level;

  const VoiceListening({required this.level});
}

class ProcessingVoiceState extends VoiceState {
  const ProcessingVoiceState();
}

class ResultVoiceState extends VoiceState {
  final String text;
  final String response;

  const ResultVoiceState({
    required this.text,
    required this.response,
  });
}

class SpeakingVoiceState extends VoiceState {
  const SpeakingVoiceState();
}

class ErrorVoiceState extends VoiceState {
  final String message;

  const ErrorVoiceState(this.message);
}

// ===========================================
// FIXED: IMAGE UPLOAD PROVIDER
// ===========================================
List<int>? _compressImageBytes(List<int> bytes) {
  try {
    var image = img.decodeImage(Uint8List.fromList(bytes));
    if (image == null) return null;
    // Strip EXIF metadata for privacy (GPS, camera info)
    image = img.Image.from(image);
    image.exif = img.ExifData();
    const maxDim = 1920;
    img.Image resized;
    if (image.width > image.height) {
      resized = img.copyResize(image, width: image.width > maxDim ? maxDim : image.width);
    } else {
      resized = img.copyResize(image, height: image.height > maxDim ? maxDim : image.height);
    }
    return img.encodeJpg(resized, quality: 85);
  } catch (_) {
    return null;
  }
}

final imageUploadProvider = StateNotifierProvider<ImageUploadNotifier, ImageUploadState>((ref) {
  return ImageUploadNotifier(ref);
});

class ImageUploadNotifier extends StateNotifier<ImageUploadState> {
  final Ref ref;
  late final ProductionLogger _logger;
  late final ProductionApiService _apiService;
  late final GlobalUserHandler _userHandler;
  late final PerformanceOptimizer _performance;
  late final IdempotencyService _idempotency;
  final Map<String, CancelToken> _cancelTokens = {};
  bool _isInitialized = false;
  bool _isDisposed = false;
  final Lock _uploadLock = Lock();

  ImageUploadNotifier(this.ref) : super(const ImageUploadState.idle()) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      _logger = ref.read(loggerProvider);
      _apiService = await ref.read(apiServiceProvider.future);
      _userHandler = await ref.read(globalUserHandlerFutureProvider.future);
      _performance = await ref.read(performanceOptimizerFutureProvider.future);
      _idempotency = await ref.read(idempotencyServiceFutureProvider.future);
      
      _isInitialized = true;
    } catch (e, stack) {
      _logger.e('ImageUploadNotifier initialization failed', error: e, stackTrace: stack);
    }
  }

  Future<List<String>> uploadImages(List<XFile> files) async {
    if (!_isInitialized || _isDisposed) return [];
    
    return await _performance.measureOperation('upload_images', () async {
      await _uploadLock.acquire();
      try {
        final user = _userHandler.currentUser;
        if (user == null) throw Exception('User not authenticated');

        state = ImageUploadState.uploading(
          total: files.length,
          current: 0,
          progress: 0.0,
        );

        final uploadedUrls = <String>[];
        final cancelToken = CancelToken();
        
        for (var i = 0; i < files.length; i++) {
          File file = File(files[i].path);
          if (!await file.exists()) {
            throw Exception('File not found: ${files[i].path}');
          }
          
          File? compressedFile;
          try {
            final bytes = await file.readAsBytes();
            final fileSize = bytes.length;
            if (fileSize > 2 * 1024 * 1024) {
              final compressed = await compute(_compressImageBytes, bytes);
              if (compressed != null) {
                final tempDir = await getTemporaryDirectory();
                compressedFile = File(
                    '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg');
                await compressedFile.writeAsBytes(compressed);
                file = compressedFile;
                _logger.d('Compressed image: ${fileSize ~/ 1024}KB → ${compressed.length ~/ 1024}KB');
              }
            }
          } catch (compressErr) {
            _logger.w('Image compression failed, uploading original', error: compressErr);
          }

          final idempotencyKey = _idempotency.generateKey(
            userId: user.id,
            operation: 'upload_image',
            entity: 'image',
            entityId: path.basename(file.path),
          );
          
          _cancelTokens[files[i].path] = cancelToken;
          
          try {
            final response = await _apiService.uploadFile(
              file: file,
              userId: user.id,
              fileType: 'image/jpeg',
              onProgress: (progress) {
                state = ImageUploadState.uploading(
                  total: files.length,
                  current: i,
                  progress: (i + progress) / files.length,
                );
              },
              cancelToken: cancelToken,
              idempotencyKey: idempotencyKey,
            );

            final url = response['url'] as String;
            uploadedUrls.add(url);
            _logger.d('Uploaded image ${i + 1}/${files.length}: $url');
            
            state = ImageUploadState.uploading(
              total: files.length,
              current: i + 1,
              progress: (i + 1) / files.length,
            );
          } catch (e) {
            if (e is DioException && e.type == DioExceptionType.cancel) {
              _logger.d('Upload cancelled: ${files[i].path}');
              state = const ImageUploadState.idle();
              rethrow;
            }
            _logger.e('Upload failed for ${files[i].path}', error: e);
            rethrow;
          } finally {
            _cancelTokens.remove(files[i].path);
            try {
              if (compressedFile != null && await compressedFile.exists()) {
                await compressedFile.delete();
                compressedFile = null;
              }
            } catch (_) {}
          }
        }

        state = ImageUploadState.completed(uploadedUrls);
        _logger.i('Uploaded ${uploadedUrls.length} images successfully');
        return uploadedUrls;
      } catch (e, stack) {
        _logger.e('Failed to upload images', error: e, stackTrace: stack);
        state = ImageUploadState.error('Failed to upload images: ${e.toString()}');
        rethrow;
      } finally {
        _uploadLock.release();
      }
    });
  }
  
  void cancelUpload(String filePath) {
    final token = _cancelTokens[filePath];
    token?.cancel();
    _cancelTokens.remove(filePath);
    _logger.d('Upload cancelled: $filePath');
  }
  
  void cancelAllUploads() {
    for (final token in _cancelTokens.values) {
      token.cancel();
    }
    _cancelTokens.clear();
    _logger.d('All uploads cancelled');
  }

  void reset() {
    cancelAllUploads();
    state = const ImageUploadState.idle();
  }

  @override
  void dispose() {
    _isDisposed = true;
    cancelAllUploads();
    super.dispose();
  }
}

@immutable
abstract class ImageUploadState {
  const ImageUploadState();

  const factory ImageUploadState.idle() = ImageUploadIdle;
  const factory ImageUploadState.uploading({
    required int total,
    required int current,
    required double progress,
  }) = ImageUploadUploading;
  const factory ImageUploadState.completed(List<String> urls) = ImageUploadCompleted;
  const factory ImageUploadState.error(String message) = ImageUploadError;
}

class ImageUploadIdle extends ImageUploadState {
  const ImageUploadIdle();
}

class ImageUploadUploading extends ImageUploadState {
  final int total;
  final int current;
  final double progress;

  const ImageUploadUploading({
    required this.total,
    required this.current,
    required this.progress,
  });
}

class ImageUploadCompleted extends ImageUploadState {
  final List<String> urls;

  const ImageUploadCompleted(this.urls);
}

class ImageUploadError extends ImageUploadState {
  final String message;

  const ImageUploadError(this.message);
}



final isSessionThinkingProvider = Provider.family<bool, String>((ref, sessionId) {
  final chatState = ref.watch(streamingChatProvider);
  if (chatState is! StreamingChatLoaded) return false;
  final session = chatState.sessions.firstWhere(
    (s) => s.id == sessionId,
    orElse: () => chatState.sessions.isNotEmpty ? chatState.sessions.first
        : ChatSession(
            id: sessionId,
            title: '',
            messages: const [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
  );
  final lastAi = session.messages.lastWhere(
    (m) => m.sender == 'ai' && m.isStreaming,
    orElse: () => ChatMessage(
      id: '', text: '', sender: 'ai', timestamp: DateTime.now(),
    ),
  );
  return lastAi.id.isNotEmpty &&
      (lastAi.streamingText?.startsWith('__THINKING__') ?? false);
});

final visibleStreamingTextProvider =
    Provider.family<String?, String>((ref, messageId) {
  final chatState = ref.watch(streamingChatProvider);
  if (chatState is! StreamingChatLoaded) return null;
  for (final session in chatState.sessions) {
    final msgIdx = session.messages.indexWhere((m) => m.id == messageId);
    if (msgIdx >= 0) {
      final msg = session.messages[msgIdx];
      final raw = msg.streamingText ?? msg.text;
      if (raw.startsWith('__THINKING__:')) return null; // thinking phase
      return raw;
    }
  }
  return null;
});

// ===========================================
// THEME PROVIDER
// ===========================================

// ===========================================
// MODEL NAME DISPLAY PROVIDERS
// "This answer generated by <model name>"
// ===========================================

String _modelDisplayName(String? modelId) {
  if (modelId == null || modelId.isEmpty) return 'Askroa AI';
  final id = modelId.toLowerCase();
  if (id.contains('gpt-4o'))            return 'GPT-4o';
  if (id.contains('gpt-4.5'))           return 'GPT-4.5';
  if (id.contains('gpt-4'))             return 'GPT-4';
  if (id.contains('gpt-3.5'))           return 'GPT-3.5';
  if (id.contains('o1'))                return 'OpenAI o1';
  if (id.contains('o3'))                return 'OpenAI o3';
  if (id.contains('claude-opus-4'))     return 'Claude Opus 4';
  if (id.contains('claude-sonnet-4'))   return 'Claude Sonnet 4';
  if (id.contains('claude-3-5-sonnet')) return 'Claude 3.5 Sonnet';
  if (id.contains('claude-3-opus'))     return 'Claude 3 Opus';
  if (id.contains('claude'))            return 'Claude';
  if (id.contains('gemini-2.5'))        return 'Gemini 2.5 Pro';
  if (id.contains('gemini-2.0'))        return 'Gemini 2.0 Flash';
  if (id.contains('gemini'))            return 'Gemini';
  if (id.contains('grok-3.5'))          return 'Grok 3.5';
  if (id.contains('grok'))              return 'Grok';
  if (id.contains('deepseek-r2'))       return 'DeepSeek R2';
  if (id.contains('deepseek'))          return 'DeepSeek';
  if (id.contains('llama-4'))           return 'Llama 4';
  if (id.contains('llama'))             return 'Llama';
  if (id.contains('mistral'))           return 'Mistral';
  return modelId;
}

// Per-message model name (after generation completes)
final messageModelNameProvider = Provider.family<String?, String>((ref, messageId) {
  final chat = ref.watch(streamingChatProvider);
  if (chat is! StreamingChatLoaded) return null;
  for (final session in chat.sessions) {
    final msg = session.messages.firstWhere(
      (m) => m.id == messageId,
      orElse: () => ChatMessage(id: '', text: '', sender: '', timestamp: DateTime.now()),
    );
    if (msg.id.isEmpty) continue;
    if (msg.modelUsed != null && msg.modelUsed!.isNotEmpty) {
      return _modelDisplayName(msg.modelUsed);
    }
  }
  return null;
});

// Live label during streaming: "Generating by Claude Opus 4..."
final generatingModelLabelProvider = Provider.family<String?, String>((ref, sessionId) {
  final chat = ref.watch(streamingChatProvider);
  if (chat is! StreamingChatLoaded || !chat.isGenerating) return null;
  final session = chat.sessions.firstWhere(
    (s) => s.id == sessionId,
    orElse: () => ChatSession(id: '', title: '', messages: [], createdAt: DateTime.now(), updatedAt: DateTime.now()),
  );
  if (session.id.isEmpty) return null;
  final msgId = chat.activeGeneratingMessageId;
  if (msgId == null) return 'Generating...';
  final msg = session.messages.firstWhere(
    (m) => m.id == msgId,
    orElse: () => ChatMessage(id: '', text: '', sender: '', timestamp: DateTime.now()),
  );
  if (msg.modelUsed != null && msg.modelUsed!.isNotEmpty) {
    return 'Generating by \${_modelDisplayName(msg.modelUsed)}...';
  }
  return 'Generating...';
});

// "Generated by <model>" label for completed AI messages
final messageGeneratedByLabelProvider = Provider.family<String?, String>((ref, messageId) {
  final name = ref.watch(messageModelNameProvider(messageId));
  if (name == null) return null;
  return 'Generated by \$name';
});

// Provider for canContinueGeneration flag
final canContinueGenerationProvider = Provider<bool>((ref) {
  final chat = ref.watch(streamingChatProvider);
  if (chat is! StreamingChatLoaded) return false;
  return chat.canContinueGeneration;
});


// ===========================================
// RATE LIMIT PROVIDERS
// ===========================================

final rateLimitStatusProvider = FutureProvider<RateLimitStatus?>((ref) async {
  try {
    final apiService  = await ref.read(apiServiceProvider.future);
    final userHandler = await ref.read(globalUserHandlerFutureProvider.future);
    final user        = userHandler.currentUser;
    if (user == null) return null;
    return await apiService.getRateLimitStatus(user.id);
  } catch (_) { return null; }
});

// Auto-refresh rate limit every 5 minutes
final rateLimitRefreshProvider = StreamProvider<RateLimitStatus?>((ref) async* {
  while (true) {
    try {
      final s = await ref.read(rateLimitStatusProvider.future);
      yield s;
    } catch (_) { yield null; }
    await Future.delayed(const Duration(minutes: 5));
  }
});

// Convenience: can user send a message right now?
final canSendMessageProvider = Provider<bool>((ref) {
  final status = ref.watch(rateLimitStatusProvider).valueOrNull;
  if (status != null) return status.canChat;
  // Fallback: check local state
  final chatState = ref.watch(streamingChatProvider);
  return chatState is! ErrorStreamingChatState;
});

// Cooldown countdown for a specific action
final cooldownProvider = Provider.family<CooldownStatus, String>((ref, action) {
  final status = ref.watch(rateLimitStatusProvider).valueOrNull;
  if (status == null) return const CooldownStatus(canSend: true, waitSeconds: 0);
  switch (action) {
    case 'chat':   return status.chatCooldown;
    case 'image':  return status.imageCooldown;
    case 'video':  return status.videoCooldown;
    case 'voice':  return status.voiceCooldown;
    default:       return const CooldownStatus(canSend: true, waitSeconds: 0);
  }
});

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier(ref);
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  final Ref ref;
  late final ProductionLogger _logger;
  late final GlobalUserHandler _userHandler;
  bool _isInitialized = false;
  bool _isDisposed = false;

  ThemeNotifier(this.ref) : super(ThemeMode.dark) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      _logger = ref.read(loggerProvider);
      _userHandler = await ref.read(globalUserHandlerFutureProvider.future);
      _isInitialized = true;
      await _loadTheme();
    } catch (e, stack) {
      ProductionLogger().e('ThemeNotifier initialization failed', error: e, stackTrace: stack);
    }
  }

  Future<void> _loadTheme() async {
    if (!_isInitialized || _isDisposed) return;
    
    try {
      await _userHandler.initialize();
      state = _userHandler.themeMode.value;
      _logger.d('Theme loaded: $state');
    } catch (e, stack) {
      _logger.e('Failed to load theme', error: e, stackTrace: stack);
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    if (!_isInitialized || _isDisposed) return;
    
    try {
      state = mode;
      await _userHandler.setThemeMode(mode);
      _logger.d('Theme set: $mode');
    } catch (e, stack) {
      _logger.e('Failed to set theme', error: e, stackTrace: stack);
    }
  }

  Future<void> toggleTheme() async {
    final newTheme = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setTheme(newTheme);
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}

// ===========================================
// LOCALIZATION PROVIDER
// ===========================================
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier(ref);
});

class LocaleNotifier extends StateNotifier<Locale> {
  final Ref ref;
  late final ProductionLogger _logger;
  late final GlobalUserHandler _userHandler;
  bool _isInitialized = false;
  bool _isDisposed = false;

  LocaleNotifier(this.ref) : super(const Locale('en')) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      _logger = ref.read(loggerProvider);
      _userHandler = await ref.read(globalUserHandlerFutureProvider.future);
      _isInitialized = true;
      await _loadLocale();
    } catch (e, stack) {
      ProductionLogger().e('LocaleNotifier initialization failed', error: e, stackTrace: stack);
    }
  }

  Future<void> _loadLocale() async {
    if (!_isInitialized || _isDisposed) return;

    try {
      await _userHandler.initialize();
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('askroa_locale');
      if (saved != null && saved.isNotEmpty) {
        state = Locale(saved);
      } else {
        state = _userHandler.locale.value;
      }
      _logger.d('Locale loaded: ${state.languageCode}');
    } catch (e, stack) {
      _logger.e('Failed to load locale', error: e, stackTrace: stack);
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (!_isInitialized || _isDisposed) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('askroa_locale', locale.languageCode);
      await _userHandler.setLocale(locale);
      state = locale;
      _logger.d('Locale set: ${locale.languageCode}');
    } catch (e, stack) {
      _logger.e('Failed to set locale', error: e, stackTrace: stack);
    }
  }

  List<Locale> get supportedLocales => const [
    Locale('en'),
    Locale('bn'),
    Locale('hi'),
    Locale('es'),
    Locale('fr'),
    Locale('de'),
    Locale('ja'),
    Locale('ko'),
    Locale('zh'),
    Locale('ar'),
    Locale('pt'),
    Locale('ru'),
    Locale('id'),
    Locale('tr'),
    Locale('vi'),
    Locale('th'),
    Locale('fa'),
    Locale('pl'),
    Locale('uk'),
    Locale('nl'),
    Locale('it'),
    Locale('sv'),
    Locale('da'),
    Locale('fi'),
    Locale('no'),
    Locale('cs'),
    Locale('sk'),
    Locale('ro'),
    Locale('hu'),
    Locale('el'),
    Locale('he'),
    Locale('ms'),
    Locale('ta'),
    Locale('te'),
    Locale('mr'),
    Locale('gu'),
    Locale('kn'),
    Locale('ml'),
    Locale('pa'),
    Locale('or'),
    Locale('as'),
    Locale('ur'),
    Locale('ne'),
    Locale('si'),
    Locale('my'),
    Locale('km'),
    Locale('lo'),
    Locale('ka'),
    Locale('am'),
    Locale('sw'),
    Locale('yo'),
    Locale('ig'),
    Locale('ha'),
    Locale('zu'),
    Locale('af'),
    Locale('az'),
    Locale('kk'),
    Locale('uz'),
    Locale('ky'),
    Locale('tg'),
    Locale('tk'),
    Locale('mn'),
    Locale('hy'),
    Locale('sq'),
    Locale('sr'),
    Locale('hr'),
    Locale('bs'),
    Locale('sl'),
    Locale('mk'),
    Locale('bg'),
    Locale('lt'),
    Locale('lv'),
    Locale('et'),
    Locale('ca'),
    Locale('gl'),
    Locale('eu'),
    Locale('mt'),
    Locale('cy'),
    Locale('ga'),
    Locale('is'),
    Locale('lb'),
  ];

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}

// ===========================================
// PRODUCTION DEBOUNCER
// ===========================================
class ProductionDebouncer {
  final int milliseconds;
  Timer? _timer;
  int _sequence = 0;
  bool _isDisposed = false;

  ProductionDebouncer({required this.milliseconds});

  void run(VoidCallback action) {
    if (_isDisposed) return;
    _timer?.cancel();
    final seq = ++_sequence;
    _timer = Timer(Duration(milliseconds: milliseconds), () {
      if (!_isDisposed && seq == _sequence) {
        action();
      }
    });
  }

  void cancel() {
    _timer?.cancel();
    ++_sequence; // invalidate any pending callback
  }

  bool get isRunning => (_timer?.isActive ?? false) && !_isDisposed;

  void dispose() {
    _isDisposed = true;
    cancel();
  }
}

// ===========================================
// PRODUCTION THROTTLER
// ===========================================
class ProductionThrottler {
  final int milliseconds;
  Timer? _timer;
  bool _isThrottled = false;
  final Queue<VoidCallback> _queue = Queue<VoidCallback>();
  static const int _maxQueueSize = 10;
  bool _isDisposed = false;

  ProductionThrottler({required this.milliseconds});

  void run(VoidCallback action) {
    if (_isDisposed) return;
    if (_isThrottled) {
      if (_queue.length < _maxQueueSize) {
        _queue.addLast(action);
      }
      return;
    }
    action();
    _isThrottled = true;
    _timer = Timer(Duration(milliseconds: milliseconds), () {
      if (_isDisposed) return;
      _isThrottled = false;
      if (_queue.isNotEmpty) {
        final next = _queue.removeFirst();
        run(next);
      }
    });
  }

  void cancel() {
    _timer?.cancel();
    _isThrottled = false;
    _queue.clear();
  }

  bool get isThrottled => _isThrottled && !_isDisposed;

  void dispose() {
    _isDisposed = true;
    cancel();
  }
}

// ===========================================
// FIXED: APP ROUTER
// ===========================================

class _GoRouterRefreshNotifier extends ChangeNotifier {
  _GoRouterRefreshNotifier(this._ref) {
    _ref.listen(authProvider, (_, __) => notifyListeners());
  }
  final Ref _ref;
}

final routerProvider = Provider<GoRouter>((ref) {
  final deepLinking = ref.read(deepLinkingProvider);

  final refreshNotifier = _GoRouterRefreshNotifier(ref);
  return GoRouter(
    navigatorKey: deepLinking.navigatorKey,
    debugLogDiagnostics: kDebugMode,
    refreshListenable: refreshNotifier,
    initialLocation: '/login',
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isAuthenticated = authState.maybeWhen(
        authenticated: (_) => true,
        orElse: () => false,
      );
      final isLoggingIn = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/verify-email' ||
          state.matchedLocation == '/reset-password';
      if (!isAuthenticated && !isLoggingIn) return '/login';
      if (isAuthenticated && isLoggingIn) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) {
          final authState = ref.watch(authProvider);
          return authState.maybeWhen(
            authenticated: (user) => MainChatScreen(user: user), 
            orElse: () => const LoginScreen(),
          );
        },
      ),
      GoRoute(
        path: '/menu-bar',
        name: 'menuBar',
        builder: (context, state) {
          final authState = ref.watch(authProvider);
          return authState.maybeWhen(
            authenticated: (user) => MenubarScreen(user: user), 
            orElse: () => const LoginScreen(),
          );
        },
      ),
      GoRoute(
        path: '/image-history',
        name: 'imageHistory',
        builder: (context, state) {
          final authState = ref.watch(authProvider);
          return authState.maybeWhen(
            authenticated: (user) => ImageHistoryScreen(user: user), 
            orElse: () => const LoginScreen(),
          );
        },
      ),
      GoRoute(
        path: '/premium',
        name: 'premium',
        builder: (context, state) {
          final authState = ref.watch(authProvider);
          return authState.maybeWhen(
            authenticated: (user) => PremiumScreen(user: user), 
            orElse: () => const LoginScreen(),
          );
        },
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) {
          final authState = ref.watch(authProvider);
          return authState.maybeWhen(
            authenticated: (user) => SettingsScreen(user: user), 
            orElse: () => const LoginScreen(),
          );
        },
      ),
      GoRoute(
        path: '/voice',
        name: 'voice',
        builder: (context, state) {
          final authState = ref.watch(authProvider);
          return authState.maybeWhen(
            authenticated: (user) => VoiceRecordingScreen(user: user), 
            orElse: () => const LoginScreen(),
          );
        },
      ),
      GoRoute(
        path: '/voice-training',
        name: 'voiceTraining',
        builder: (context, state) {
          final authState = ref.watch(authProvider);
          return authState.maybeWhen(
            authenticated: (user) => VoiceTrainingScreen(user: user), 
            orElse: () => const LoginScreen(),
          );
        },
      ),
      GoRoute(
        path: '/voice-change',
        name: 'voiceChange',
        builder: (context, state) {
          final authState = ref.watch(authProvider);
          return authState.maybeWhen(
            authenticated: (user) => VoiceChangeScreen(user: user),
            orElse: () => const LoginScreen(),
          );
        },
      ),
      GoRoute(
        path: '/content-policy',
        name: 'contentPolicy',
        builder: (context, state) => const ContentPolicyScreen(), 
      ),
      GoRoute(
        path: '/data-safety',
        name: 'dataSafety',
        builder: (context, state) => const DataSafetyScreen(),
      ),
      GoRoute(
        path: '/invite/:ref',
        name: 'invite',
        builder: (context, state) {
          final ref = state.pathParameters['ref'] ?? '';
          return InviteScreen(ref: ref); 
        },
      ),
      GoRoute(
        path: '/reset-password',
        name: 'resetPassword',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final token = extra?['token'] as String? ?? '';
          return ResetPasswordScreen(token: token); 
        },
      ),
      GoRoute(
        path: '/verify-email',
        name: 'verifyEmail',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final token = extra?['token'] as String? ?? '';
          return VerifyEmailScreen(token: token);
        },
      ),
    ],
    redirect: (context, state) async {
      final isLogin = state.matchedLocation == '/login';
      final isPolicy = state.matchedLocation == '/content-policy' || 
                      state.matchedLocation == '/data-safety' ||
                      state.matchedLocation.startsWith('/invite') ||
                      state.matchedLocation.startsWith('/reset-password') ||
                      state.matchedLocation.startsWith('/verify-email');

      final authState = ref.read(authProvider);
      return authState.maybeWhen(
        authenticated: (user) {
          if (isLogin) return '/home';
          return null;
        },
        unauthenticated: () {
          if (!isLogin && !isPolicy) return '/login';
          return null;
        },
        orElse: () => '/login',
      );
    },
  );
});

// =============================================================================
//   LoginScreen
// =============================================================================








// =============================================================================
// FIXED: MAIN APP - Complete initialization
// =============================================================================
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  tz.initializeTimeZones();
  final String localTz = DateTime.now().timeZoneName;
  try {
    tz.setLocalLocation(tz.getLocation(localTz));
  } catch (_) {
    tz.setLocalLocation(tz.getLocation('UTC'));
  }

  final _logger = ProductionLogger(isProduction: kReleaseMode);
  await _logger.initialize();

  runZonedGuarded(() async {
    try {

      final envConfig = EnvironmentConfig();
      await envConfig.initialize();

      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        if (Firebase.apps.isEmpty) {
          await Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          );
        }
        try {
          await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
          FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
        } catch (e) {
          _logger.w('[Init] Crashlytics setup failed', error: e);
        }
        try {
          if (kReleaseMode) {
            await FirebaseAppCheck.instance.activate(
              androidProvider: AndroidProvider.playIntegrity,
              appleProvider: AppleProvider.appAttest,
            );
          } else {
            await FirebaseAppCheck.instance.activate(
              androidProvider: AndroidProvider.debug,
              appleProvider: AppleProvider.debug,
            );
          }
        } catch (e) {
          _logger.w('[Init] FirebaseAppCheck activation failed', error: e);
        }
      }

      final sentryDsn = EnvironmentConfig.sentryDsn;
      if (sentryDsn.isNotEmpty && !kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        try {
          await SentryFlutter.init(
            (options) {
              options.dsn = sentryDsn;
              options.environment = EnvironmentConfig.environment;
              options.release = '$appName@$appVersion+$appVersion';
              options.tracesSampleRate = 1.0;
              options.enableNativeCrashHandling = true;
              options.attachStacktrace = true;
              options.sendDefaultPii = false;
            },
          );
        } catch (e) {
          _logger.w('[Init] Sentry init failed', error: e);
        }
      }

      unawaited(LazyLoader.loadDeferredModules(ref.read(loggerProvider)));

      if (!kIsWeb && Platform.isIOS) {
        try {
          const attChannel = MethodChannel('com.askroa/att');
          await attChannel.invokeMethod<void>('requestTracking');
        } catch (_) {}
      }

      await JustAudioBackground.init(
        androidNotificationChannelId: 'com.askroa.audio.channel',
        androidNotificationChannelName: 'Audio Playback',
        androidNotificationOngoing: true,
      );
      
      await Workmanager().initialize(
        callbackDispatcher,
        isInDebugMode: kDebugMode,
      );
      
      await Workmanager().registerPeriodicTask(
        'offline_sync',
        'sync_offline_messages',
        frequency: const Duration(minutes: 15),
        existingWorkPolicy: ExistingWorkPolicy.keep,
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: true,
        ),
      );
      
      await Workmanager().registerPeriodicTask(
        'daily_reset',
        'daily_reset_task',
        frequency: const Duration(hours: 24),
        initialDelay: _getTimeUntilMidnight(),
        existingWorkPolicy: ExistingWorkPolicy.keep,
      );
      
      await Workmanager().registerPeriodicTask(
        'recovery_cleanup',
        'recovery_cleanup_task',
        frequency: const Duration(hours: 24),
        existingWorkPolicy: ExistingWorkPolicy.keep,
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresDeviceIdle: false,
          requiresStorageNotLow: false,
        ),
      );
      
      await Workmanager().registerPeriodicTask(
        'database_vacuum',
        'database_vacuum_task',
        frequency: const Duration(days: 7),
        existingWorkPolicy: ExistingWorkPolicy.keep,
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: true,
          requiresCharging: true,
        ),
      );
      
      if (!kIsWeb) {
        await FirebasePerformance.instance.setPerformanceCollectionEnabled(true);
      }
      
      runApp(
        ProviderScope(
          child: const AskroaApp(),
        ),
      );
    } catch (e, stack) {
      _logger.e('[Init] Fatal initialization error', error: e, stackTrace: stack);
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        FirebaseCrashlytics.instance.recordError(e, stack, fatal: true);
      }
      Sentry.captureException(e, stackTrace: stack);
      
      runApp(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          home: _FatalErrorScreen(error: e.toString()),
        ),
      );
    }
  }, (error, stack) {
    _logger.e('[App] Uncaught error', error: error, stackTrace: stack);
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    }
    Sentry.captureException(error, stackTrace: stack);
  });
}


class _FatalErrorScreen extends StatelessWidget {
  final String error;
  const _FatalErrorScreen({required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Failed to initialize app',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(error, textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (!kIsWeb && Platform.isIOS) {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Restart Required'),
                        content: const Text(
                          'Please close the app from the App Switcher and reopen it.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  } else {
                    SystemNavigator.pop();
                  }
                },
                child: const Text('Restart App'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      final logger = ProductionLogger(isProduction: kReleaseMode);
      
      switch (task) {
        case 'sync_offline_messages':
          await _syncOfflineMessages(logger);
          return true;
        case 'daily_reset_task':
          await _performDailyReset(logger);
          return true;
        case 'recovery_cleanup_task':
          await _cleanupOldData(logger);
          return true;
        case 'database_vacuum_task':
          await _vacuumDatabase(logger);
          return true;
        default:
          return false;
      }
    } catch (e, stack) {
      final bgLogger = ProductionLogger(isProduction: kReleaseMode);
      bgLogger.e('[Background] Task execution failed', error: e, stackTrace: stack);
      return false;
    }
  });
}

// ===========================================
// FIXED: BACKGROUND TASK IMPLEMENTATIONS
// ===========================================
Future<void> _syncOfflineMessages(ProductionLogger logger) async {
  final performance = PerformanceOptimizer(logger: logger);
  final db = DatabaseService(logger: logger, performance: performance);
  try {
    logger.i('Starting offline message sync from background');
    await db.initialize();

    final dbInstance = db.database;
    final unsyncedMessages = await (dbInstance.select(dbInstance.localChatMessages)
      ..where((tbl) => tbl.isSynced.equals(false))).get();

    if (unsyncedMessages.isNotEmpty) {
      logger.i('Syncing ${unsyncedMessages.length} offline messages from background');

      final encryption = ProductionEncryptionService(logger: logger);
      final connectivity = ProductionConnectivityService(logger: logger);
      final rateLimiter = RateLimitingService(logger: logger);
      final webSocket = WebSocketService(logger: logger);

      await encryption.initialize();
      await connectivity.initialize();
      await rateLimiter.initialize();
      await webSocket.initialize();
      if (!kIsWeb) {
        await webSocket.connect();
      }

      final api = ProductionApiService(logger, encryption, connectivity, rateLimiter, webSocket);
      await api.initialize();

      int successCount = 0;
      int failureCount = 0;

      for (var message in unsyncedMessages) {
        try {
          final parts = message.sessionId.split('_');
          final userId = parts.length > 1 ? parts[1] : message.sessionId;
          await api.sendChatMessage(
            sessionId: message.sessionId,
            message: message.text,
            userId: userId,
            plan: 'free',
          );
          await dbInstance.markMessageAsSynced(message.serverId);
          successCount++;
        } catch (e) {
          await dbInstance.markMessageAsFailed(message.serverId, e.toString());
          failureCount++;
        }
      }

      logger.i('Background sync completed: $successCount succeeded, $failureCount failed');
    } else {
      logger.d('No unsynced messages found in background');
    }
  } catch (e, stack) {
    logger.e('Background offline sync failed', error: e, stackTrace: stack);
  } finally {
    await db.dispose();
  }
}

Future<void> _performDailyReset(ProductionLogger logger) async {
    final secureStorage = AppSecureStorage.instance;
  try {
    logger.i('Starting daily reset from background');

    final prefs = await SharedPreferences.getInstance();
    final lastReset = prefs.getString('last_daily_reset');
    final today = DateTime.now().toIso8601String().substring(0, 10);

    if (lastReset != today) {
      final userData = await secureStorage.read(key: 'askroa_user_data');
      if (userData != null) {
        final encryption = ProductionEncryptionService(logger: logger);
        await encryption.initialize();
        final decrypted = await encryption.decrypt(userData);

        if (decrypted != '[DECRYPTION_FAILED]') {
          final userJson = jsonDecode(decrypted) as Map<String, dynamic>;

          if (userJson['plan'] == 'free') {
            userJson['daily_requests'] = 0;
            final encrypted = encryption.encrypt(jsonEncode(userJson));
            await secureStorage.write(key: 'askroa_user_data', value: encrypted);
            
            await prefs.setInt('askroa_remaining_requests', 5);
            
            logger.i('Daily requests reset for free user: ${userJson['id']}');
          }
        }
      }

      await prefs.setString('last_daily_reset', today);
      logger.i('Daily reset performed successfully');
    } else {
      logger.d('Daily reset already performed today');
    }
  } catch (e, stack) {
    logger.e('Background daily reset failed', error: e, stackTrace: stack);
  }
}

Future<void> _cleanupOldData(ProductionLogger logger) async {
  try {
    logger.i('Starting cleanup from background');
    
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();

    final secureStorage = AppSecureStorage.instance;
    await secureStorage.delete(key: 'askroa_recovery_state');

    final tempDir = await getTemporaryDirectory();
    if (await tempDir.exists()) {
      final files = tempDir.listSync();
      int deletedCount = 0;
      
      for (var file in files) {
        try {
          if (file is File) {
            final stat = await file.stat();
            if (stat.modified.isBefore(now.subtract(const Duration(days: 7)))) {
              await file.delete();
              deletedCount++;
            }
          }
        } catch (e) {
          logger.d('Failed to delete temp file', error: e);
        }
      }
      
      logger.i('Deleted $deletedCount temporary files');
    }

    final performance = PerformanceOptimizer(logger: logger);
    final db = DatabaseService(logger: logger, performance: performance);
    await db.initialize();
    await db.cleanupOldData();
    
    final cache = ProductionCacheManager(logger: logger, performance: performance);
    await cache.initialize();
    final cacheSizeBefore = await cache.getCacheSize();
    
    await cache.clearExpiredCache();
    
    final cacheSizeAfter = await cache.getCacheSize();
    final freedSpace = cacheSizeBefore - cacheSizeAfter;
    
    logger.i('Cleanup completed: freed ${freedSpace / (1024 * 1024)} MB from cache');
    
    await db.dispose();
    
  } catch (e, stack) {
    logger.e('Background cleanup failed', error: e, stackTrace: stack);
  }
}

Future<void> _vacuumDatabase(ProductionLogger logger) async {
  try {
    logger.i('Starting database vacuum from background');
    
    final performance = PerformanceOptimizer(logger: logger);
    final db = DatabaseService(logger: logger, performance: performance);
    await db.initialize();
    await db.vacuum();
    
    logger.i('Database vacuum completed');
    
    await db.dispose();
  } catch (e, stack) {
    logger.e('Background database vacuum failed', error: e, stackTrace: stack);
  }
}

// ===========================================
// FIXED: ASKROA APP
// ===========================================
class AskroaApp extends ConsumerStatefulWidget {
  const AskroaApp({super.key});

  @override
  ConsumerState<AskroaApp> createState() => _AskroaAppState();
}

class _AskroaAppState extends ConsumerState<AskroaApp> with WidgetsBindingObserver {
  bool _isInitialized = false;
  DeepLinkingService? _deepLinking;
  ProductionEncryptionService? _encryption;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeApp();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    LazyLoader.clear();
    _encryption?.dispose();
    _deepLinking?.dispose();
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _encryption?.restartKeyRotationTimer();
        try {
          final ws = ref.read(webSocketFutureProvider).valueOrNull;
          ws?.onAppResumed();
        } catch (_) {}
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        WakelockPlus.disable().ignore();
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }

  Future<void> _initializeApp() async {
    final logger = ref.read(loggerProvider);
    
    try {
      // Initialize EnvironmentConfig first — all other providers depend on it
      await LazyLoader.load('env', () => EnvironmentConfig().initialize(logger: logger));
      logger.i('[App] EnvironmentConfig ready. Backend: \${EnvironmentConfig.backendBaseUrl.isEmpty ? "NOT SET" : "OK"}');
      
      try {
        _encryption = await ref.read(encryptionFutureProvider.future)
            .timeout(const Duration(seconds: 30));
      } catch (e) {
        logger.w('[Init] Encryption provider failed, using fallback', error: e);
        final fallbackEnc = ProductionEncryptionService(logger: logger);
        await fallbackEnc.initialize();
        _encryption = fallbackEnc;
      }

      try {
        _deepLinking = await ref.read(deepLinkingFutureProvider.future)
            .timeout(const Duration(seconds: 15));
      } catch (e) {
        logger.w('[Init] DeepLinking provider failed, using fallback', error: e);
        final fallbackDl = DeepLinkingService(logger: logger);
        await fallbackDl.initialize();
        _deepLinking = fallbackDl;
      }
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _precacheEssentialAssets();
      });
    } catch (e, stack) {
      logger.e('App initialization failed', error: e, stackTrace: stack);
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    }
  }

  Future<void> _precacheEssentialAssets() async {
    if (!mounted) return;
    
    final logger = ref.read(loggerProvider);
    
    final assets = [
      AppAssets.appIcon,
      AppAssets.sendIcon,
      AppAssets.googleIcon,
      AppAssets.appleIcon,
      AppAssets.menuBarIcon,
    ];
    
    for (final asset in assets) {
      try {
        await precacheImage(AssetImage(asset), context);
      } catch (e) {
        logger.d('[Assets] Precache skipped: $asset', error: e);
      }
    }
    
    logger.d('Essential assets precached');
  }

  ProductionLogger get logger => ref.read(loggerProvider);

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);
    final router = ref.watch(routerProvider);
    
    if (!_isInitialized) {
      return MaterialApp(
        home: Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0066FF), Color(0xFF0044CC)],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    AppAssets.appIcon,
                    width: 120,
                    height: 120,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(
                          Icons.bolt,
                          size: 60,
                          color: Color(0xFF0066FF),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    appName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 48),
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Askroa',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    
    return GlobalErrorBoundary(
      child: MaterialApp.router(
        title: appName,
        debugShowCheckedModeBanner: false,
        theme: getLightTheme(),
        darkTheme: getDarkTheme(),
        themeMode: themeMode,
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: ref.read(localeProvider.notifier).supportedLocales,
        localeResolutionCallback: (deviceLocale, supportedLocales) {
          if (deviceLocale == null) return const Locale('en');
          for (final supported in supportedLocales) {
            if (supported.languageCode == deviceLocale.languageCode) {
              return supported;
            }
          }
          return const Locale('en');
        },
        routerConfig: router,
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: MediaQuery.of(context).textScaler,
            ),
            child: child!,
          );
        },
      ),
    );
  }
}
