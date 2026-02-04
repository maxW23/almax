import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lklk/core/services/purchase_service.dart';
import 'package:lklk/core/services/api_service.dart';
import 'package:lklk/core/services/auth_service.dart';

part 'purchase_state.dart';

class _VerificationResult {
  final bool ok;
  final String? message;
  final String? debugInfo;
  const _VerificationResult(this.ok, this.debugInfo, [this.message]);
}

// Controls whether to use legacy fallback endpoint '/iap/verify'.
// Keep it disabled to rely solely on '/transaction/google'.
const bool kEnableLegacyIapVerifyFallback = false;

class PurchaseCubit extends Cubit<PurchaseState> {
  final PurchaseService _purchaseService;
  final ApiService _apiService;
  StreamSubscription<PurchaseUpdate>? _purchaseSubscription;
  Timer? _purchaseTimeout;

  PurchaseCubit({
    PurchaseService? purchaseService,
    ApiService? apiService,
  })  : _purchaseService = purchaseService ?? PurchaseService(),
        _apiService = apiService ?? ApiService(),
        super(const PurchaseInitial());

  void _resetToReadyLater(
      [Duration delay = const Duration(milliseconds: 800)]) {
    // Give UI a moment to show Snackbar before resetting
    Future.delayed(delay, () {
      // Only reset if we're not already loading/pending/verifying
      final s = state;
      if (s is! PurchaseLoading &&
          s is! PurchasePending &&
          s is! PurchaseVerifying) {
        emit(const PurchaseReady());
      }
    });
  }

  Future<void> initialize() async {
    emit(const PurchaseLoading());

    try {
      // Attach listener early to catch any immediate init errors from service
      if (_purchaseSubscription == null) {
        _listenToPurchaseUpdates();
      }

      final bool success = await _purchaseService.initialize();
      if (success) {
        emit(const PurchaseReady());
      } else {
        emit(const PurchaseError('Failed to initialize purchase service'));
      }
    } catch (e) {
      emit(PurchaseError('Initialization error: $e'));
    }
  }

  void _listenToPurchaseUpdates() {
    _purchaseSubscription = _purchaseService.purchaseStream.listen(
      _handlePurchaseUpdate,
      onError: (error) {
        emit(PurchaseError('Purchase stream error: $error'));
        _resetToReadyLater();
      },
    );
  }

  Future<void> _handlePurchaseUpdate(PurchaseUpdate update) async {
    // Cancel any pending timeout when we receive an update
    _purchaseTimeout?.cancel();

    switch (update.status) {
      case PurchaseUpdateStatus.pending:
        emit(PurchasePending(update.productId, update.coinAmount ?? 0));
        break;

      case PurchaseUpdateStatus.purchased:
        await _handleSuccessfulPurchase(update);
        break;

      case PurchaseUpdateStatus.error:
        emit(PurchaseError(update.error ?? 'Purchase failed'));
        _resetToReadyLater();
        break;

      case PurchaseUpdateStatus.canceled:
        emit(const PurchaseCanceled());
        _resetToReadyLater();
        break;
    }
  }

  Future<void> _handleSuccessfulPurchase(PurchaseUpdate update) async {
    if (update.purchaseToken == null || update.coinAmount == null) {
      emit(const PurchaseError('Invalid purchase data'));
      return;
    }

    emit(PurchaseVerifying(update.productId, update.coinAmount!));

    try {
      // Send purchase data to backend for verification
      final _VerificationResult result = await _verifyPurchaseWithBackend(
        purchaseToken: update.purchaseToken!,
        productId: update.productId,
        coinAmount: update.coinAmount!,
        price: update.price ?? 0.0,
        currency: update.currency ?? 'USD',
        orderId: update.orderId,
      );

      if (result.ok) {
        emit(PurchaseSuccess(update.productId, update.coinAmount!,
            serverMessage: result.message, debugInfo: result.debugInfo));
        _resetToReadyLater();
      } else {
        final errorMsg = result.message ?? 'Purchase verification failed';
        emit(PurchaseError(errorMsg));
        _resetToReadyLater();
      }
    } catch (e) {
      emit(PurchaseError('Verification error: $e'));
      _resetToReadyLater();
    }
  }

  Future<_VerificationResult> _verifyPurchaseWithBackend({
    required String purchaseToken,
    required String productId,
    required int coinAmount,
    required double price,
    required String currency,
    String? orderId,
  }) async {
    // Logging disabled per request

    try {
      // No logging

      // 1) Try /transaction/google endpoint
      try {
        final user = await AuthService.getUserFromSharedPreferences();
        final String userId = (user?.iduser ?? user?.id ?? '').toString();

        if (userId.isNotEmpty) {
          // Align names to backend expectations and add snake_case duplicates for compatibility
          final queryParams = <String, dynamic>{
            // Required
            'productId': productId,
            'purchaseToken': purchaseToken,
            'packageName': 'com.bwmatbw.lklklivechatapp',
            // Duplicates (snake_case) in case backend expects underscores
            'product_id': productId,
            'purchase_token': purchaseToken,
            // Optional extras,
            'price': price,
            'currency': currency,
            'orderId': orderId,
            // User/amount variants (both forms)
            'userId': userId.toString(),
            'amount': coinAmount,
            'u_id': userId.toString(),
            'ammount': coinAmount,
          };
          // Build URL with encoded query string manually
          final encodedQuery = Uri(
              queryParameters:
                  queryParams.map((k, v) => MapEntry(k, v?.toString()))).query;
          final endpointWithQuery = '/transaction/google?$encodedQuery';
          final expResp = await _apiService.post(
            endpointWithQuery,
            // no body, params inline
          );
          // Convert statusCode to int safely - everything as String first
          final String statusCodeStr = expResp.statusCode.toString();
          final int expStatus = int.tryParse(statusCodeStr) ?? 0;

          if (expStatus >= 200 && expStatus < 300) {
            // Extract message - Backend returns plain String (not JSON)
            String extractedMessage = '';
            try {
              // Backend returns String directly (e.g., "Coin added successfully")
              final dynamic responseData = expResp.data;

              // Check if it's already a String
              if (responseData is String) {
                extractedMessage = responseData;
              } else {
                // Fallback: try to parse as JSON (just in case)
                final String rawDataStr = responseData.toString();

                try {
                  // Try JSON decode
                  final parsedData = jsonDecode(rawDataStr);

                  if (parsedData is Map) {
                    final mapData = parsedData;
                    // Try multiple field names
                    extractedMessage = mapData['error']?.toString() ??
                        mapData['message']?.toString() ??
                        mapData['msg']?.toString() ??
                        mapData['detail']?.toString() ??
                        mapData['reason']?.toString() ??
                        mapData['status']?.toString() ??
                        rawDataStr;
                  } else if (parsedData is List) {
                    final listData = parsedData;
                    extractedMessage = listData.isNotEmpty
                        ? listData.first.toString()
                        : rawDataStr;
                  } else {
                    extractedMessage = rawDataStr;
                  }
                } catch (jsonError) {
                  // Not JSON, use as plain string
                  extractedMessage = rawDataStr;
                }
              }
            } catch (extractError) {
              extractedMessage = 'extraction error: $extractError';
            }

            final finalMessage =
                extractedMessage.isNotEmpty ? extractedMessage : 'ok';
            return _VerificationResult(true, finalMessage);
          } else {
            // Non-2xx response
            // Extract error message - Backend returns plain String
            String errorMessage = '';
            try {
              final dynamic errorData = expResp.data;

              // Check if it's already a String (expected from backend)
              if (errorData is String) {
                errorMessage = errorData;
              } else {
                // Fallback: try to parse as JSON
                final String rawDataStr = errorData.toString();

                try {
                  final parsedData = jsonDecode(rawDataStr);

                  if (parsedData is Map) {
                    final mapData = parsedData;
                    // Priority: error > message > msg > detail > reason > status > raw
                    errorMessage = mapData['error']?.toString() ??
                        mapData['message']?.toString() ??
                        mapData['msg']?.toString() ??
                        mapData['detail']?.toString() ??
                        mapData['reason']?.toString() ??
                        mapData['status']?.toString() ??
                        rawDataStr;
                  } else if (parsedData is List) {
                    final listData = parsedData;
                    errorMessage = listData.isNotEmpty
                        ? listData.first.toString()
                        : rawDataStr;
                  } else {
                    errorMessage = rawDataStr;
                  }
                } catch (jsonError) {
                  // Not JSON, use as plain string
                  errorMessage = rawDataStr;
                }
              }
            } catch (extractError) {
              errorMessage = 'status $expStatus';
            }

            if (!kEnableLegacyIapVerifyFallback) {
              return _VerificationResult(false,
                  errorMessage.isNotEmpty ? errorMessage : 'status $expStatus');
            } else {
              // Fallback disabled
            }
          }
        } else {
          if (!kEnableLegacyIapVerifyFallback) {
            return _VerificationResult(false, 'user id not found');
          }
        }
      } on DioException catch (dioError) {
        // Handle DioException specifically to extract response data
        // Extract meaningful error from DioException
        String errorMsg = 'خطأ في الاتصال';
        try {
          if (dioError.response?.data != null) {
            final data = dioError.response!.data;
            if (data is String) {
              errorMsg = data;
            } else if (data is Map) {
              errorMsg = data['error']?.toString() ??
                  data['message']?.toString() ??
                  data['msg']?.toString() ??
                  'خطأ من السيرفر';
            }
          } else if (dioError.error != null) {
            errorMsg = dioError.error.toString();
          }
        } catch (_) {
          errorMsg = dioError.message ?? 'خطأ غير معروف';
        }
        if (!kEnableLegacyIapVerifyFallback) {
          return _VerificationResult(false, errorMsg);
        }
      } catch (endpointError) {
        // Handle any other exceptions
        if (!kEnableLegacyIapVerifyFallback) {
          return _VerificationResult(false, 'خطأ: $endpointError');
        }
      }

      // 2) Legacy fallback removed
      return _VerificationResult(false, 'fallback removed');
    } catch (outerError) {
      return _VerificationResult(false, 'outer exception: $outerError');
    }
  }

  Future<void> purchaseCoins(int coinAmount) async {
    if (state is PurchaseLoading ||
        state is PurchasePending ||
        state is PurchaseVerifying) {
      return;
    }

    emit(PurchaseLoading());

    try {
      final bool success = await _purchaseService.purchaseCoins(coinAmount);

      if (!success) {
        emit(const PurchaseError('Failed to start purchase'));
      } else {
        // Optimistically inform UI we're pending while waiting for purchase stream
        final productId =
            PurchaseService.coinsToProductId[coinAmount] ?? 'unknown_product';
        emit(PurchasePending(productId, coinAmount));

        // Safety timeout in case no purchase updates arrive from Play Billing
        _purchaseTimeout?.cancel();
        _purchaseTimeout = Timer(const Duration(seconds: 90), () {
          emit(const PurchaseError(
              'Timed out waiting for purchase confirmation'));
          _resetToReadyLater();
        });
      }
      // Further state changes will be driven by the purchase stream listener
    } catch (e) {
      emit(PurchaseError('Purchase error: $e'));
    }
  }

  void resetState() {
    emit(const PurchaseReady());
  }

  @override
  Future<void> close() {
    _purchaseSubscription?.cancel();
    _purchaseTimeout?.cancel();
    _purchaseService.dispose();
    return super.close();
  }
}
