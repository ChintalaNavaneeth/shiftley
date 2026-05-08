// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$analyticsOverviewHash() => r'654c860a11ecce2c2b4a0d5d71757c1dcc45953b';

/// See also [analyticsOverview].
@ProviderFor(analyticsOverview)
final analyticsOverviewProvider =
    AutoDisposeFutureProvider<AnalyticsOverview>.internal(
  analyticsOverview,
  name: r'analyticsOverviewProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$analyticsOverviewHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AnalyticsOverviewRef = AutoDisposeFutureProviderRef<AnalyticsOverview>;
String _$financialMetricsHash() => r'61c7bc0a76bdbd97b21c4b794e3e75c0a6bc8c18';

/// See also [financialMetrics].
@ProviderFor(financialMetrics)
final financialMetricsProvider =
    AutoDisposeFutureProvider<FinancialMetrics>.internal(
  financialMetrics,
  name: r'financialMetricsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$financialMetricsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef FinancialMetricsRef = AutoDisposeFutureProviderRef<FinancialMetrics>;
String _$adminTaxonomyHash() => r'a98bff94d73d7d9e7ef8c29da1686ec9561ef02b';

/// See also [AdminTaxonomy].
@ProviderFor(AdminTaxonomy)
final adminTaxonomyProvider =
    AutoDisposeAsyncNotifierProvider<AdminTaxonomy, List<Category>>.internal(
  AdminTaxonomy.new,
  name: r'adminTaxonomyProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$adminTaxonomyHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AdminTaxonomy = AutoDisposeAsyncNotifier<List<Category>>;
String _$managementUsersHash() => r'e7749c281f8c1ff290e01b010440363e7bf3e98e';

/// See also [ManagementUsers].
@ProviderFor(ManagementUsers)
final managementUsersProvider = AutoDisposeAsyncNotifierProvider<
    ManagementUsers, List<ManagementUser>>.internal(
  ManagementUsers.new,
  name: r'managementUsersProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$managementUsersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ManagementUsers = AutoDisposeAsyncNotifier<List<ManagementUser>>;
String _$platformConfigNotifierHash() =>
    r'f387a4d329e6d2da06391d82ca6c4f01131afecb';

/// See also [PlatformConfigNotifier].
@ProviderFor(PlatformConfigNotifier)
final platformConfigNotifierProvider = AutoDisposeAsyncNotifierProvider<
    PlatformConfigNotifier, PlatformConfig>.internal(
  PlatformConfigNotifier.new,
  name: r'platformConfigNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$platformConfigNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PlatformConfigNotifier = AutoDisposeAsyncNotifier<PlatformConfig>;
String _$pendingDisputesHash() => r'c16f74022c94796cdd100c4878d6e388ee6ce6a8';

/// See also [PendingDisputes].
@ProviderFor(PendingDisputes)
final pendingDisputesProvider =
    AutoDisposeAsyncNotifierProvider<PendingDisputes, List<Dispute>>.internal(
  PendingDisputes.new,
  name: r'pendingDisputesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$pendingDisputesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PendingDisputes = AutoDisposeAsyncNotifier<List<Dispute>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
