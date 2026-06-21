import 'dart:convert';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/respository/home_repositories/dropdown_categories_selection_repositories/approve_booking_repository.dart';
import 'package:flutter/material.dart';

class ApproveBookingViewModel with ChangeNotifier {
  final _repo = ApproveBookingRepository();

  // ── Approve Loading ────────────────────────────────────────────────────────
  bool _isApproveLoading = false;
  bool get isApproveLoading => _isApproveLoading;

  void setApproveLoading(bool value) {
    _isApproveLoading = value;
    notifyListeners();
  }

  // ── Reject Loading ─────────────────────────────────────────────────────────
  bool _isRejectLoading = false;
  bool get isRejectLoading => _isRejectLoading;

  void setRejectLoading(bool value) {
    _isRejectLoading = value;
    notifyListeners();
  }

  // ── Extra Items Status ─────────────────────────────────────────────────────
  // Possible values: 'PENDING', 'APPROVED', 'REJECTED', null
  String? _extraItemsStatus;
  String? get extraItemsStatus => _extraItemsStatus;

  bool get isApproved => _extraItemsStatus?.toUpperCase() == 'APPROVED';
  bool get isRejected => _extraItemsStatus?.toUpperCase() == 'REJECTED';
  bool get isPending  => _extraItemsStatus?.toUpperCase() == 'PENDING';

  /// Call this on screen load to sync status from API
  void setStatusFromApi(String? status) {
    _extraItemsStatus = status;
    // no notify needed — called before build in postFrameCallback
  }

  // ── Approve ────────────────────────────────────────────────────────────────
  Future<void> approveBooking({
    required BuildContext context,
    required String bookingId,
    required String freelancerId,
    required VoidCallback onSuccess,
  }) async {
    if (isApproved || _isApproveLoading) return;
    setApproveLoading(true);

    try {
      final response = await _repo.approveBookingApi(
        bookingId: bookingId,
        data: {
          "status": "APPROVED",
          "freelancerId":freelancerId,
        },
      );

      if (response != null && response['success'] == true) {
        _extraItemsStatus = 'APPROVED';
        notifyListeners();
        Utils.flushBarSuccessMessage("Extra items approved successfully!", context);
        onSuccess();
      } else {
        String msg = response?['message'] ?? 'Approval failed';
        Utils.flushBarErrorMessage(msg, context);
      }
    } catch (error) {
      _handleError(error, context);
    } finally {
      setApproveLoading(false);
    }
  }

  // ── Reject ─────────────────────────────────────────────────────────────────
  Future<void> rejectBooking({
    required BuildContext context,
    required String bookingId,
    required String freelancerId,
    required VoidCallback onSuccess,
  }) async {
    if (isRejected || _isRejectLoading) return;
    setRejectLoading(true);

    try {
      final response = await _repo.approveBookingApi(
        bookingId: bookingId,
        data: {
          "status": "REJECTED",
          "freelancerId":freelancerId,
        },
      );

      if (response != null && response['success'] == true) {
        _extraItemsStatus = 'REJECTED';
        notifyListeners();
        Utils.flushBarSuccessMessage("Extra items rejected!", context);
        onSuccess();
      } else {
        String msg = response?['message'] ?? 'Rejection failed';
        Utils.flushBarErrorMessage(msg, context);
      }
    } catch (error) {
      _handleError(error, context);
    } finally {
      setRejectLoading(false);
    }
  }

  // ── Error Handler ──────────────────────────────────────────────────────────
  void _handleError(dynamic error, BuildContext context) {
    String errorMessage = 'Unexpected error occurred';
    try {
      String errorBody = error.toString();
      int jsonStartIndex = errorBody.indexOf('{');
      if (jsonStartIndex != -1) {
        final decoded = jsonDecode(errorBody.substring(jsonStartIndex));
        errorMessage = decoded['message'] ??
            (decoded['errorMessages'] is List && decoded['errorMessages'].isNotEmpty
                ? decoded['errorMessages'][0]['message']
                : errorMessage);
      }
    } catch (_) {}
    Utils.flushBarErrorMessage(errorMessage, context);
  }
}