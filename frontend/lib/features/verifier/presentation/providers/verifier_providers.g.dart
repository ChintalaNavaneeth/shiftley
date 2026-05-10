// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verifier_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$verifierQueueHash() => r'c5355f20d0b9c640d476a9151d105b02e641c758';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [verifierQueue].
@ProviderFor(verifierQueue)
const verifierQueueProvider = VerifierQueueFamily();

/// See also [verifierQueue].
class VerifierQueueFamily extends Family<AsyncValue<List<QueueItem>>> {
  /// See also [verifierQueue].
  const VerifierQueueFamily();

  /// See also [verifierQueue].
  VerifierQueueProvider call({
    String? type,
  }) {
    return VerifierQueueProvider(
      type: type,
    );
  }

  @override
  VerifierQueueProvider getProviderOverride(
    covariant VerifierQueueProvider provider,
  ) {
    return call(
      type: provider.type,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'verifierQueueProvider';
}

/// See also [verifierQueue].
class VerifierQueueProvider extends AutoDisposeFutureProvider<List<QueueItem>> {
  /// See also [verifierQueue].
  VerifierQueueProvider({
    String? type,
  }) : this._internal(
          (ref) => verifierQueue(
            ref as VerifierQueueRef,
            type: type,
          ),
          from: verifierQueueProvider,
          name: r'verifierQueueProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$verifierQueueHash,
          dependencies: VerifierQueueFamily._dependencies,
          allTransitiveDependencies:
              VerifierQueueFamily._allTransitiveDependencies,
          type: type,
        );

  VerifierQueueProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.type,
  }) : super.internal();

  final String? type;

  @override
  Override overrideWith(
    FutureOr<List<QueueItem>> Function(VerifierQueueRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: VerifierQueueProvider._internal(
        (ref) => create(ref as VerifierQueueRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        type: type,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<QueueItem>> createElement() {
    return _VerifierQueueProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is VerifierQueueProvider && other.type == type;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, type.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin VerifierQueueRef on AutoDisposeFutureProviderRef<List<QueueItem>> {
  /// The parameter `type` of this provider.
  String? get type;
}

class _VerifierQueueProviderElement
    extends AutoDisposeFutureProviderElement<List<QueueItem>>
    with VerifierQueueRef {
  _VerifierQueueProviderElement(super.provider);

  @override
  String? get type => (origin as VerifierQueueProvider).type;
}

String _$verifierHistoryHash() => r'3c0ca45f29e76f6c6d03a88382d736d749b34a13';

/// See also [verifierHistory].
@ProviderFor(verifierHistory)
final verifierHistoryProvider =
    AutoDisposeFutureProvider<List<VerificationAudit>>.internal(
  verifierHistory,
  name: r'verifierHistoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$verifierHistoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef VerifierHistoryRef
    = AutoDisposeFutureProviderRef<List<VerificationAudit>>;
String _$verifierProfileHash() => r'a544b36f083c21da6013b7dcc2463d23a33031fa';

/// See also [verifierProfile].
@ProviderFor(verifierProfile)
final verifierProfileProvider =
    AutoDisposeFutureProvider<VerifierProfile>.internal(
  verifierProfile,
  name: r'verifierProfileProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$verifierProfileHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef VerifierProfileRef = AutoDisposeFutureProviderRef<VerifierProfile>;
String _$employerDetailsHash() => r'dc31ab5d627e706de3b77e0645252e0f8c93070d';

/// See also [employerDetails].
@ProviderFor(employerDetails)
const employerDetailsProvider = EmployerDetailsFamily();

/// See also [employerDetails].
class EmployerDetailsFamily extends Family<AsyncValue<EmployerProfile>> {
  /// See also [employerDetails].
  const EmployerDetailsFamily();

  /// See also [employerDetails].
  EmployerDetailsProvider call(
    String id,
  ) {
    return EmployerDetailsProvider(
      id,
    );
  }

  @override
  EmployerDetailsProvider getProviderOverride(
    covariant EmployerDetailsProvider provider,
  ) {
    return call(
      provider.id,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'employerDetailsProvider';
}

/// See also [employerDetails].
class EmployerDetailsProvider
    extends AutoDisposeFutureProvider<EmployerProfile> {
  /// See also [employerDetails].
  EmployerDetailsProvider(
    String id,
  ) : this._internal(
          (ref) => employerDetails(
            ref as EmployerDetailsRef,
            id,
          ),
          from: employerDetailsProvider,
          name: r'employerDetailsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$employerDetailsHash,
          dependencies: EmployerDetailsFamily._dependencies,
          allTransitiveDependencies:
              EmployerDetailsFamily._allTransitiveDependencies,
          id: id,
        );

  EmployerDetailsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(
    FutureOr<EmployerProfile> Function(EmployerDetailsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: EmployerDetailsProvider._internal(
        (ref) => create(ref as EmployerDetailsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<EmployerProfile> createElement() {
    return _EmployerDetailsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is EmployerDetailsProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin EmployerDetailsRef on AutoDisposeFutureProviderRef<EmployerProfile> {
  /// The parameter `id` of this provider.
  String get id;
}

class _EmployerDetailsProviderElement
    extends AutoDisposeFutureProviderElement<EmployerProfile>
    with EmployerDetailsRef {
  _EmployerDetailsProviderElement(super.provider);

  @override
  String get id => (origin as EmployerDetailsProvider).id;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
