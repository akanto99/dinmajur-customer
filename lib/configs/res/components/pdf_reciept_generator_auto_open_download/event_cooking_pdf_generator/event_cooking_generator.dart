import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

// ==================== UNIVERSAL RECEIPT DATA MODELS ====================

/// Universal receipt data that works for ANY booking type
class UniversalReceiptData {
  final String trackingId;
  final String? customerName;
  final String? phone;
  final String? email;
  final String? address;
  final String? notes;
  final String? status;
  final DateTime? date;
  final String? time;
  final String? bookingType; // 'REGULAR' or 'MANUAL'
  final String? guestRange;
  final String? paymentMethod;
  final List<UniversalServiceItem> services;
  final UniversalPaymentSummary paymentSummary;
  final String? footerMessage;
  final String? contactNumber;

  UniversalReceiptData({
    required this.trackingId,
    this.customerName,
    this.phone,
    this.email,
    this.address,
    this.notes,
    this.status,
    this.date,
    this.time,
    this.bookingType,
    this.guestRange,
    this.paymentMethod,
    required this.services,
    required this.paymentSummary,
    this.footerMessage,
    this.contactNumber = '01929600600',
  });
}

/// Universal service item for any booking type
class UniversalServiceItem {
  final String serviceName; // Category name for REGULAR, Package name for MANUAL
  final List<UniversalSubItem> items; // Package names for REGULAR, Item names for MANUAL
  final int quantity;
  final num totalPrice;

  UniversalServiceItem({
    required this.serviceName,
    required this.items,
    this.quantity = 1,
    required this.totalPrice,
  });
}

/// Sub-items within a service
class UniversalSubItem {
  final String name;
  final num price;

  UniversalSubItem({
    required this.name,
    required this.price,
  });
}

/// Payment summary data
class UniversalPaymentSummary {
  final num subTotal;
  final num vat;
  final num transportationFee;
  final num discount;
  final num total;
  final num grandTotal;

  UniversalPaymentSummary({
    required this.subTotal,
    this.vat = 0,
    this.transportationFee = 0,
    this.discount = 0,
    required this.total,
    required this.grandTotal,
  });
}

// ==================== UNIVERSAL PDF GENERATOR ====================

class UniversalPDFReceiptGenerator {
  /// Generate and download receipt PDF for ANY booking type
  static Future<File?> generateAndDownloadPDFReceipt(UniversalReceiptData receiptData) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(32),
          build: (context) => [
            _buildHeader(),
            pw.SizedBox(height: 5),
            _buildOrderId(receiptData),
            pw.SizedBox(height: 24),
            pw.Divider(height: 5, color: PdfColor.fromHex('#299D8F')),
            _buildCustomerDetails(receiptData),
            pw.SizedBox(height: 24),
            if (receiptData.date != null || receiptData.time != null ||
                receiptData.bookingType != null || receiptData.guestRange != null)
              _buildOrderSchedule(receiptData),
            if (receiptData.date != null || receiptData.time != null ||
                receiptData.bookingType != null || receiptData.guestRange != null)
              pw.SizedBox(height: 24),
            _buildServicesSection(receiptData),
            pw.SizedBox(height: 24),
            _buildPaymentSummary(receiptData),
            pw.SizedBox(height: 24),
            _buildFooter(receiptData),
          ],
        ),
      );

      final output = await _savePdf(pdf, receiptData.trackingId);
      return output;
    } catch (e) {
      print('Error generating PDF: $e');
      return null;
    }
  }

  // ==================== PDF Components ====================

  static pw.Widget _buildHeader() {
    return pw.Center(
      child: pw.Text(
        'Booking Receipt',
        style: pw.TextStyle(
          fontSize: 28,
          color: PdfColor.fromHex('#299D8F'),
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  static pw.Widget _buildOrderId(UniversalReceiptData data) {
    return pw.Center(
      child: pw.Text(
        'Order ID: #${data.trackingId}',
        style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.normal),
      ),
    );
  }

  static pw.Widget _buildCustomerDetails(UniversalReceiptData data) {
    return pw.Container(
      padding: pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColor.fromHex('#E7E9E9')),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Customer Details',
            style: pw.TextStyle(
              fontSize: 18,
              color: PdfColor.fromHex('#299D8F'),
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 12),
          if (data.customerName != null) ...[
            _buildDetailRow('Name:', data.customerName!),
            pw.SizedBox(height: 6),
          ],
          if (data.phone != null) ...[
            _buildDetailRow('Phone:', data.phone!),
            pw.SizedBox(height: 6),
          ],
          if (data.email != null && data.email!.isNotEmpty) ...[
            _buildDetailRow('Email:', data.email!),
            pw.SizedBox(height: 6),
          ],
          if (data.address != null) ...[
            _buildDetailRow('Address:', data.address!),
            pw.SizedBox(height: 6),
          ],
          if (data.paymentMethod != null && data.paymentMethod!.isNotEmpty) ...[
            _buildDetailRow('Payment Method:', data.paymentMethod!),
            pw.SizedBox(height: 6),
          ],
          if (data.status != null)
            _buildDetailRow('Status:', data.status!.toUpperCase()),
        ],
      ),
    );
  }

  static pw.Widget _buildOrderSchedule(UniversalReceiptData data) {
    final dateStr = data.date != null
        ? DateFormat('dd MMM yyyy').format(data.date!)
        : null;
    final timeStr = data.time;
    final bookingTypeStr = data.bookingType;
    final guestRangeStr = data.guestRange;

    // Count how many fields we have
    int fieldCount = 0;
    if (dateStr != null) fieldCount++;
    if (timeStr != null) fieldCount++;
    if (bookingTypeStr != null) fieldCount++;
    if (guestRangeStr != null) fieldCount++;

    if (fieldCount == 0) return pw.Container();

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColor.fromHex('#E7E9E9')),
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColor.fromHex('#299D8F')),
          children: [
            pw.Padding(
              padding: pw.EdgeInsets.all(8),
              child: pw.Text(
                'Order Schedule & Details',
                style: pw.TextStyle(
                  fontSize: 14,
                  color: PdfColors.white,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        pw.TableRow(
          children: [
            pw.Container(
              child: pw.Table(
                border: pw.TableBorder(
                  verticalInside: pw.BorderSide(color: PdfColor.fromHex('#E7E9E9')),
                  horizontalInside: pw.BorderSide(color: PdfColor.fromHex('#E7E9E9')),
                ),
                columnWidths: {
                  0: pw.FlexColumnWidth(1),
                  1: pw.FlexColumnWidth(1),
                },
                children: [
                  // Header row
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey100),
                    children: _buildScheduleHeaderCells(dateStr, timeStr, bookingTypeStr, guestRangeStr),
                  ),
                  // Data row
                  pw.TableRow(
                    children: _buildScheduleDataCells(dateStr, timeStr, bookingTypeStr, guestRangeStr),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  static List<pw.Widget> _buildScheduleHeaderCells(
      String? dateStr, String? timeStr, String? bookingTypeStr, String? guestRangeStr) {
    List<pw.Widget> cells = [];

    if (dateStr != null) {
      cells.add(pw.Padding(
        padding: pw.EdgeInsets.all(8),
        child: pw.Text('Date', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
      ));
    }
    if (timeStr != null) {
      cells.add(pw.Padding(
        padding: pw.EdgeInsets.all(8),
        child: pw.Text('Time Slot', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
      ));
    }
    if (bookingTypeStr != null) {
      cells.add(pw.Padding(
        padding: pw.EdgeInsets.all(8),
        child: pw.Text('Type', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
      ));
    }
    if (guestRangeStr != null) {
      cells.add(pw.Padding(
        padding: pw.EdgeInsets.all(8),
        child: pw.Text('Guest Range', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
      ));
    }

    return cells;
  }

  static List<pw.Widget> _buildScheduleDataCells(
      String? dateStr, String? timeStr, String? bookingTypeStr, String? guestRangeStr) {
    List<pw.Widget> cells = [];

    if (dateStr != null) {
      cells.add(pw.Padding(
        padding: pw.EdgeInsets.all(8),
        child: pw.Text(dateStr, style: pw.TextStyle(fontSize: 12)),
      ));
    }
    if (timeStr != null) {
      cells.add(pw.Padding(
        padding: pw.EdgeInsets.all(8),
        child: pw.Text(timeStr, style: pw.TextStyle(fontSize: 12)),
      ));
    }
    if (bookingTypeStr != null) {
      cells.add(pw.Padding(
        padding: pw.EdgeInsets.all(8),
        child: pw.Text(bookingTypeStr, style: pw.TextStyle(fontSize: 12)),
      ));
    }
    if (guestRangeStr != null) {
      cells.add(pw.Padding(
        padding: pw.EdgeInsets.all(8),
        child: pw.Text(guestRangeStr, style: pw.TextStyle(fontSize: 12)),
      ));
    }

    return cells;
  }

  static pw.Widget _buildServicesSection(UniversalReceiptData data) {
    if (data.services.isEmpty) {
      return pw.Container(
        padding: pw.EdgeInsets.all(16),
        child: pw.Text(
          'No services available',
          style: pw.TextStyle(fontSize: 14, color: PdfColors.grey),
        ),
      );
    }

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColor.fromHex('#E7E9E9')),
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColor.fromHex('#299D8F')),
          children: [
            pw.Padding(
              padding: pw.EdgeInsets.all(8),
              child: pw.Text(
                'Services',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
            ),
          ],
        ),
        pw.TableRow(
          children: [
            pw.Container(
              child: pw.Table(
                border: pw.TableBorder(
                  verticalInside: pw.BorderSide(color: PdfColor.fromHex('#E7E9E9')),
                ),
                columnWidths: {
                  0: pw.FlexColumnWidth(2.5),
                  1: pw.FlexColumnWidth(4),
                  2: pw.FlexColumnWidth(1.5),
                },
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey100),
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text('Service', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text('Items', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text('Total\n(BDT)', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        ...data.services.map((service) {
          List<pw.Widget> itemWidgets = service.items.map((item) {
            return pw.Padding(
              padding: pw.EdgeInsets.only(bottom: 2),
              child: pw.Text(
                '${item.name}${item.price > 0 ? ' - BDT ${item.price.toStringAsFixed(0)}' : ''}',
                style: pw.TextStyle(fontSize: 10),
              ),
            );
          }).toList();

          return pw.TableRow(
            children: [
              pw.Container(
                child: pw.Table(
                  border: pw.TableBorder(
                    verticalInside: pw.BorderSide(color: PdfColor.fromHex('#E7E9E9')),
                  ),
                  columnWidths: {
                    0: pw.FlexColumnWidth(2.5),
                    1: pw.FlexColumnWidth(4),
                    2: pw.FlexColumnWidth(1.5),
                  },
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text(service.serviceName, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: itemWidgets.isEmpty
                                ? [pw.Text('No items', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey))]
                                : itemWidgets,
                          ),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text('BDT\n${service.totalPrice.toStringAsFixed(0)}', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ],
    );
  }

  static pw.Widget _buildPaymentSummary(UniversalReceiptData data) {
    final payment = data.paymentSummary;

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColor.fromHex('#E7E9E9')),
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColor.fromHex('#299D8F')),
          children: [
            pw.Padding(
              padding: pw.EdgeInsets.all(8),
              child: pw.Text(
                'Payment Summary',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
            ),
          ],
        ),
        pw.TableRow(
          children: [
            pw.Container(
              child: pw.Table(
                border: pw.TableBorder(
                  horizontalInside: pw.BorderSide(color: PdfColor.fromHex('#E7E9E9')),
                ),
                children: [
                  _buildPaymentTableRow('Subtotal', payment.subTotal),
                  if (payment.vat > 0)
                    _buildPaymentTableRow('VAT', payment.vat),
                  if (payment.transportationFee > 0)
                    _buildPaymentTableRow('Transportation', payment.transportationFee),
                  if (payment.discount > 0)
                    _buildPaymentTableRow('Discount', -payment.discount, isDiscount: true),
                  _buildPaymentTableRow('Total', payment.total),
                ],
              ),
            ),
          ],
        ),
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.grey100),
          children: [
            pw.Padding(
              padding: pw.EdgeInsets.all(12),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Grand Total:',
                    style: pw.TextStyle(
                      fontSize: 14,
                      color: PdfColor.fromHex('#299D8F'),
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    'BDT ${payment.grandTotal.toStringAsFixed(0)}',
                    style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  static pw.TableRow _buildPaymentTableRow(String label, num amount, {bool isDiscount = false}) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                label,
                style: pw.TextStyle(
                  fontSize: 12,
                  color: isDiscount ? PdfColors.green : PdfColors.black,
                ),
              ),
              pw.Text(
                'BDT ${amount.toStringAsFixed(0)}',
                style: pw.TextStyle(
                  fontSize: 12,
                  color: isDiscount ? PdfColors.green : PdfColors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildFooter(UniversalReceiptData data) {
    return pw.Center(
      child: pw.Column(
        children: [
          pw.Text(
            data.footerMessage ?? 'Thank you for choosing our service!',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            textAlign: pw.TextAlign.center,
          ),
          if (data.contactNumber != null) ...[
            pw.SizedBox(height: 8),
            pw.Text(
              'Contact us: ${data.contactNumber}',
              style: pw.TextStyle(fontSize: 12),
              textAlign: pw.TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  static pw.Widget _buildDetailRow(String label, String value) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: 120,
          child: pw.Text(label, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
        ),
        pw.Expanded(
          child: pw.Text(value, style: pw.TextStyle(fontSize: 12)),
        ),
      ],
    );
  }

  static Future<File> _savePdf(pw.Document pdf, String trackingId) async {
    try {
      Directory? directory;

      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        throw Exception('Could not access storage directory');
      }

      final String dinmajurPath = '${directory.path}/Dinmajur_Bookings';
      final Directory dinmajurDir = Directory(dinmajurPath);
      if (!await dinmajurDir.exists()) {
        await dinmajurDir.create(recursive: true);
      }

      final String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final String fileName = 'Receipt_${trackingId}_$timestamp.pdf';
      final String filePath = '$dinmajurPath/$fileName';

      final File file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      print('✅ PDF saved to: $filePath');
      return file;
    } catch (e) {
      print('❌ Error saving PDF: $e');
      rethrow;
    }
  }
}