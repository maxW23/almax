import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:lklk/core/utils/logger.dart';

class PurchaseService {
  static final PurchaseService _instance = PurchaseService._internal();
  factory PurchaseService() => _instance;
  PurchaseService._internal();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  // Product IDs based on coinsOptions (1 USD = 10000 coins)
  static const List<String> _productIds = [
    'coins3000lklk',   // $1 -> coins,

    'coins15000lklk',  // $5 -> coins,

    'coins30000lklk',  // $10 ->coins,

    'coins45000lklk',  // $15 ->coins,
    
    'coins60000lklk', // $20 ->coins,
    
    'coins75000', // $25 ->coins
  ];

  // Mapping coins to product IDs (must match _productIds)
  static const Map<int, String> coinsToProductId = {
    3000   : 'coins3000lklk',
    15000  : 'coins15000lklk',
    30000  : 'coins30000lklk',
    45000  : 'coins45000lklk',
    60000 : 'coins60000lklk',
    75000 : 'coins75000',
  };

  // Stream controller for purchase updates
  final StreamController<PurchaseUpdate> _purchaseController =
      StreamController<PurchaseUpdate>.broadcast();
  Stream<PurchaseUpdate> get purchaseStream => _purchaseController.stream;

  bool _isInitialized = false;
  List<ProductDetails> _products = [];

  Future<bool> initialize() async {
    if (_isInitialized) {
      AppLogger.debug('⚠️ [INIT] Already initialized', tag: 'purchase');
      return true;
    }

    try {
      AppLogger.info('🚀 [INIT] Initializing PurchaseService...',
          tag: 'purchase');
      final bool available = await _inAppPurchase.isAvailable();
      if (!available) {
        AppLogger.error(
            '❌ [INIT] In-app purchase NOT AVAILABLE on this device!',
            tag: 'purchase');
        AppLogger.error('❌ [INIT] Make sure app is installed from Play Store',
            tag: 'purchase');
        return false;
      }
      AppLogger.info('✅ [INIT] In-app purchase is available', tag: 'purchase');

      // Set up purchase stream listener
      _subscription = _inAppPurchase.purchaseStream.listen(
        _handlePurchaseUpdate,
        onDone: () => AppLogger.debug('Purchase stream done', tag: 'purchase'),
        onError: (error) =>
            AppLogger.error('Purchase stream error: $error', tag: 'purchase'),
      );

      // Query product details
      await _queryProductDetails();

      _isInitialized = true;
      AppLogger.info('PurchaseService initialized successfully',
          tag: 'purchase');
      return true;
    } catch (e) {
      AppLogger.error('Failed to initialize PurchaseService: $e',
          tag: 'purchase');
      return false;
    }
  }

  Future<void> _queryProductDetails() async {
    try {
      AppLogger.info('🔍 [INIT] Querying products from Play Store...',
          tag: 'purchase');
      AppLogger.debug('🔍 [INIT] Product IDs to query: $_productIds',
          tag: 'purchase');

      final ProductDetailsResponse response =
          await _inAppPurchase.queryProductDetails(_productIds.toSet());

      if (response.error != null) {
        AppLogger.error('❌ [INIT] Error querying products: ${response.error}',
            tag: 'purchase');
        AppLogger.error('❌ [INIT] Error code: ${response.error?.code}',
            tag: 'purchase');
        AppLogger.error('❌ [INIT] Error message: ${response.error?.message}',
            tag: 'purchase');
        return;
      }

      _products = response.productDetails;
      AppLogger.info('✅ [INIT] Found ${_products.length} products',
          tag: 'purchase');

      for (final product in _products) {
        AppLogger.info(
            '📦 [INIT] Product: ${product.id} - ${product.title} - ${product.price}',
            tag: 'purchase');
      }

      if (response.notFoundIDs.isNotEmpty) {
        AppLogger.error(
            '❌ [INIT] Products NOT FOUND in Play Console: ${response.notFoundIDs}',
            tag: 'purchase');
        AppLogger.error(
            '❌ [INIT] Make sure these products are Active in Play Console!',
            tag: 'purchase');
        // Emit error with details for UI to show
        _purchaseController.add(PurchaseUpdate(
          productId: 'init_error',
          status: PurchaseUpdateStatus.error,
          error:
              'Products not found: ${response.notFoundIDs.join(", ")}. Found: ${_products.length}',
        ));
      } else {
        AppLogger.info('✅ [INIT] All products found successfully',
            tag: 'purchase');
      }
    } catch (e) {
      AppLogger.error('❌ [INIT] Exception querying products: $e',
          tag: 'purchase');
    }
  }

  Future<bool> purchaseCoins(int coinAmount) async {
    AppLogger.info('🛒 [PURCHASE] Starting purchase for $coinAmount coins',
        tag: 'purchase');

    if (!_isInitialized) {
      AppLogger.error('❌ [PURCHASE] PurchaseService not initialized',
          tag: 'purchase');
      return false;
    }

    final String? productId = coinsToProductId[coinAmount];
    if (productId == null) {
      AppLogger.error('❌ [PURCHASE] No product ID found for $coinAmount coins',
          tag: 'purchase');
      return false;
    }

    AppLogger.debug('🔍 [PURCHASE] Looking for product: $productId',
        tag: 'purchase');
    AppLogger.debug(
        '📦 [PURCHASE] Available products: ${_products.map((p) => p.id).toList()}',
        tag: 'purchase');

    ProductDetails? product;
    try {
      product = _products.firstWhere(
        (p) => p.id == productId,
      );
    } catch (e) {
      AppLogger.error(
          '❌ [PURCHASE] Product $productId not found in available products!',
          tag: 'purchase');
      AppLogger.error(
          '❌ [PURCHASE] Available: ${_products.map((p) => p.id).join(", ")}',
          tag: 'purchase');
      return false;
    }

    try {
      AppLogger.info(
          '💳 [PURCHASE] Initiating Google Play purchase for ${product.id} ($coinAmount coins)',
          tag: 'purchase');
      AppLogger.debug(
          '💰 [PURCHASE] Price: ${product.price} (${product.currencyCode})',
          tag: 'purchase');

      final PurchaseParam purchaseParam =
          PurchaseParam(productDetails: product);

      AppLogger.debug('🚀 [PURCHASE] Calling buyConsumable...',
          tag: 'purchase');
      final bool success =
          await _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);

      if (!success) {
        AppLogger.error(
            '❌ [PURCHASE] buyConsumable returned false for ${product.id}',
            tag: 'purchase');
      } else {
        AppLogger.info(
            '✅ [PURCHASE] buyConsumable returned true - waiting for purchase dialog',
            tag: 'purchase');
      }

      return success;
    } catch (e) {
      AppLogger.error('❌ [PURCHASE] Exception during purchase: $e',
          tag: 'purchase');
      AppLogger.error('❌ [PURCHASE] Stack trace: ${StackTrace.current}',
          tag: 'purchase');
      return false;
    }
  }

  void _handlePurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      AppLogger.debug(
          'Purchase update: ${purchaseDetails.productID} - ${purchaseDetails.status}',
          tag: 'purchase');

      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          _purchaseController.add(PurchaseUpdate(
            productId: purchaseDetails.productID,
            status: PurchaseUpdateStatus.pending,
            purchaseDetails: purchaseDetails,
          ));
          break;

        case PurchaseStatus.purchased:
          _handleSuccessfulPurchase(purchaseDetails);
          break;

        case PurchaseStatus.error:
          AppLogger.error('Purchase error: ${purchaseDetails.error}',
              tag: 'purchase');
          _purchaseController.add(PurchaseUpdate(
            productId: purchaseDetails.productID,
            status: PurchaseUpdateStatus.error,
            error: purchaseDetails.error?.message ?? 'Unknown error',
            purchaseDetails: purchaseDetails,
          ));
          break;

        case PurchaseStatus.canceled:
          AppLogger.debug('Purchase canceled: ${purchaseDetails.productID}',
              tag: 'purchase');
          _purchaseController.add(PurchaseUpdate(
            productId: purchaseDetails.productID,
            status: PurchaseUpdateStatus.canceled,
            purchaseDetails: purchaseDetails,
          ));
          break;

        case PurchaseStatus.restored:
          // Handle restored purchases if needed
          AppLogger.debug('Purchase restored: ${purchaseDetails.productID}',
              tag: 'purchase');
          break;
      }

      // Complete the purchase to acknowledge it
      if (purchaseDetails.pendingCompletePurchase) {
        _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }

  void _handleSuccessfulPurchase(PurchaseDetails purchaseDetails) {
    AppLogger.info('Purchase successful: ${purchaseDetails.productID}',
        tag: 'purchase');

    // Extract verification data
    final String purchaseToken =
        purchaseDetails.verificationData.serverVerificationData;
    final String productId = purchaseDetails.productID;

    // Get coin amount from product ID
    final int? coinAmount = _getCoinAmountFromProductId(productId);
    if (coinAmount == null) {
      AppLogger.error('Could not determine coin amount for product: $productId',
          tag: 'purchase');
      return;
    }

    // Get price from product details
    final ProductDetails product = _products.firstWhere(
      (p) => p.id == productId,
      orElse: () => throw StateError('Product not found'),
    );

    _purchaseController.add(PurchaseUpdate(
      productId: productId,
      status: PurchaseUpdateStatus.purchased,
      purchaseToken: purchaseToken,
      coinAmount: coinAmount,
      price: product.rawPrice,
      currency: product.currencyCode,
      orderId: purchaseDetails.purchaseID,
      purchaseDetails: purchaseDetails,
    ));
  }

  int? _getCoinAmountFromProductId(String productId) {
    for (final entry in coinsToProductId.entries) {
      if (entry.value == productId) {
        return entry.key;
      }
    }
    return null;
  }

  List<ProductDetails> get availableProducts => List.unmodifiable(_products);

  ProductDetails? getProductDetails(int coinAmount) {
    final String? productId = coinsToProductId[coinAmount];
    if (productId == null) return null;

    try {
      return _products.firstWhere((p) => p.id == productId);
    } catch (e) {
      return null;
    }
  }

  void dispose() {
    _subscription.cancel();
    _purchaseController.close();
    _isInitialized = false;
  }
}

class PurchaseUpdate {
  final String productId;
  final PurchaseUpdateStatus status;
  final String? error;
  final String? purchaseToken;
  final int? coinAmount;
  final double? price;
  final String? currency;
  final String? orderId;
  final PurchaseDetails? purchaseDetails;

  PurchaseUpdate({
    required this.productId,
    required this.status,
    this.error,
    this.purchaseToken,
    this.coinAmount,
    this.price,
    this.currency,
    this.orderId,
    this.purchaseDetails,
  });
}

enum PurchaseUpdateStatus {
  pending,
  purchased,
  error,
  canceled,
}
