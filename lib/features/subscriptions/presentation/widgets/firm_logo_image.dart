import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../di/injection.dart';

/// Renders a firm's logo.
///
/// `tenant.logoUrl` is **not** a URL: `TenantsService.updateLogo` stores the
/// MinIO object key (`branding/tenants/<id>/logo-<hex>`) and the bytes are only
/// readable through one of the two download routes the deployed API exposes:
/// `GET /tenants/my-firm/logo` (the caller's own firm) or
/// `GET /tenants/{id}/logo` (any firm, for a Super Admin — the same reason the
/// platform registry is the only place a Super Admin can read a firm at all).
/// Rendering the key with `Image.network` resolved it to
/// `http://host/branding/tenants/...`, which 404s, so a successfully uploaded
/// logo always fell back to the placeholder. Even a correct URL to either
/// route would still need the bearer token, so this fetches the bytes through
/// the shared `Dio` (auth interceptor attaches the JWT, refresh interceptor
/// rotates it on 401) — the same `ResponseType` bytes approach
/// `DocumentRepository.downloadDocument` uses.
///
/// Bytes are cached in memory keyed by `route|logoKey|version`, so reopening
/// a page does not refetch or flicker, while a re-upload (a fresh random
/// `logoKey`, or a bumped `updatedAt`) forces a fresh load.
class FirmLogoImage extends StatefulWidget {
  const FirmLogoImage({
    super.key,
    required this.logoKey,
    this.version,
    this.tenantId,
  });

  /// The raw `logoUrl` value stored on the firm — an object key, not a URL.
  final String? logoKey;

  /// Null fetches the caller's own firm (`/tenants/my-firm/logo`); a value
  /// fetches that firm (`/tenants/{id}/logo`), which is the Super Admin's
  /// view of a firm in the platform registry.
  final String? tenantId;

  /// Typically the firm's `updatedAt`; changing it invalidates the cache for
  /// this logo without having to depend on `logoKey` alone.
  final Object? version;

  @override
  State<FirmLogoImage> createState() => _FirmLogoImageState();
}

class _FirmLogoImageState extends State<FirmLogoImage> {
  static final Map<String, Uint8List> _cache = {};

  /// Null when there is no logo yet — [initState] must not kick off a
  /// request for a firm that has never uploaded one.
  Future<Uint8List>? _bytes;
  late String _cacheKey;

  bool get _hasLogo => widget.logoKey != null && widget.logoKey!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _cacheKey = _keyFor(widget.logoKey, widget.version);
    _startLoad();
  }

  @override
  void didUpdateWidget(covariant FirmLogoImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextKey = _keyFor(widget.logoKey, widget.version);
    if (nextKey != _cacheKey) {
      _cacheKey = nextKey;
      _startLoad();
    }
  }

  void _startLoad() {
    _bytes = _hasLogo ? _load() : null;
  }

  String get _endpoint => widget.tenantId == null
      ? '/tenants/my-firm/logo'
      : '/tenants/${widget.tenantId}/logo';

  String _keyFor(String? logoKey, Object? version) =>
      '$_endpoint|$logoKey|${version ?? ''}';

  Future<Uint8List> _load() async {
    final cached = _cache[_cacheKey];
    if (cached != null) return cached;
    // Failure surfaces as an error the builder turns back into the
    // placeholder — a missing/expired logo must never break this screen.
    final response = await getIt<Dio>().get<List<int>>(
      _endpoint,
      options: Options(responseType: ResponseType.bytes),
    );
    final bytes = Uint8List.fromList(response.data ?? const <int>[]);
    if (bytes.isNotEmpty) _cache[_cacheKey] = bytes;
    return bytes;
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasLogo || _bytes == null) return const _FirmLogoPlaceholder();

    return FutureBuilder<Uint8List>(
      future: _bytes,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }
        if (snapshot.hasError || snapshot.data == null) {
          return const _FirmLogoPlaceholder();
        }
        return Image.memory(snapshot.data!, fit: BoxFit.contain);
      },
    );
  }
}

class _FirmLogoPlaceholder extends StatelessWidget {
  const _FirmLogoPlaceholder();

  @override
  Widget build(BuildContext context) => const Icon(
    Icons.business_outlined,
    size: 28,
    color: AppColors.textHint,
  );
}
