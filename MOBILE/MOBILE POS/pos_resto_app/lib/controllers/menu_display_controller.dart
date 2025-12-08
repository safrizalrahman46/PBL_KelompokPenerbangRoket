import 'dart:async';
import 'package:flutter/foundation.dart';

import '../models/menu_model.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class MenuDisplayController extends ChangeNotifier {
  final ApiService _api;

  MenuDisplayController({ApiService? api}) : _api = api ?? ApiService();

  List<Menu> _menus = [];
  List<Menu> get menus => _menus;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  String _query = '';
  String get query => _query;

  Timer? _autoRefreshTimer;

  bool get isAutoRefreshing => _autoRefreshTimer != null;

  List<Menu> get filteredMenus {
    if (_query.isEmpty) return _menus;
    final q = _query.toLowerCase();
    return _menus
        .where(
          (m) =>
              m.name.toLowerCase().contains(q) ||
              (m.description ?? '').toLowerCase().contains(q),
        )
        .toList();
  }

  Future<void> loadMenus() async {
    // prevent overlapping loads
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final fetched = await _api.fetchMenus();
      _menus = fetched;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await loadMenus();
  }

  void setQuery(String q) {
    _query = q;
    notifyListeners();
  }

  /// Start automatic polling to refresh menus every [seconds]. If already
  /// running, it will be restarted with the new interval.
  void startAutoRefresh({int seconds = 10}) {
    stopAutoRefresh();
    _autoRefreshTimer = Timer.periodic(Duration(seconds: seconds), (_) async {
      try {
        await loadMenus();
      } catch (_) {
        // errors handled in loadMenus
      }
    });
    notifyListeners();
  }

  /// Stop automatic polling.
  void stopAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = null;
    notifyListeners();
  }

  /// Normalize image url returned by backend. If the url is relative,
  /// prefix with API_URL. Returns empty string when no image.
  String normalizeImageUrl(String? imageUrl) {
    if (imageUrl == null) return '';
    final trimmed = imageUrl.trim();
    if (trimmed.isEmpty) return '';
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://'))
      return trimmed;
    // common case: "/storage/..." or "storage/..."
    final withoutLeading = trimmed.startsWith('/')
        ? trimmed.substring(1)
        : trimmed;
    return '$API_URL/$withoutLeading';
  }

  @override
  void dispose() {
    stopAutoRefresh();
    super.dispose();
  }
}
