import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

/// Lightweight TTL-based cache using Hive.
/// Data is stored as JSON strings alongside an expiry timestamp.
class CacheService {
  static const _boxName = 'cache';
  static const _ttlHours = 1;

  static Box get _box => Hive.box(_boxName);

  /// Stores [data] as JSON under [key] with a 1-hour TTL.
  static Future<void> set(String key, dynamic data) async {
    final entry = {
      'data': data,
      'expires_at': DateTime.now().add(const Duration(hours: _ttlHours)).millisecondsSinceEpoch,
    };
    await _box.put(key, jsonEncode(entry));
  }

  /// Returns the cached value for [key], or null if missing / expired.
  static dynamic get(String key) {
    final raw = _box.get(key);
    if (raw == null) return null;
    try {
      final entry = jsonDecode(raw as String) as Map;
      final expiresAt = entry['expires_at'] as int;
      if (DateTime.now().millisecondsSinceEpoch > expiresAt) {
        _box.delete(key); // evict expired entry
        return null;
      }
      return entry['data'];
    } catch (_) {
      return null;
    }
  }

  /// Returns true if a valid (non-expired) cache entry exists.
  static bool has(String key) => get(key) != null;

  /// Removes a cached entry.
  static Future<void> invalidate(String key) => _box.delete(key);
}
