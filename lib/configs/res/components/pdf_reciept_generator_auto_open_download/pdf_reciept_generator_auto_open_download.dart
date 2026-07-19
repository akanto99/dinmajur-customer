import 'dart:io';
import 'package:dinmajur_customer/configs/utils/amount_formatter/amount_formatter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:dinmajur_customer/model/home_models/nearby_retailers_and_order_models/get_order_details_model.dart';
import 'package:intl/intl.dart';

class ReceiptPdfGenerator {
  /// Generate and download receipt PDF
  static Future<File?> generateAndDownloadReceipt(Data orderData) async {
    try {
      final pdf = pw.Document();

      // Add page to PDF
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(32),
          build: (context) => [
            _buildHeader(),
            pw.SizedBox(height: 20),
            _buildOrderInfo(orderData),
            pw.SizedBox(height: 20),
            _buildCustomerInfo(orderData),
            pw.SizedBox(height: 20),
            _buildRetailerInfo(orderData),
            pw.SizedBox(height: 20),
            _buildDeliveryInfo(orderData),
            pw.SizedBox(height: 20),
            _buildItemsTable(orderData),
            pw.SizedBox(height: 20),
            _buildPriceSummary(orderData),
            pw.SizedBox(height: 30),
            _buildFooter(),
          ],
        ),
      );

      // Save PDF to device
      final output = await _savePdf(pdf, orderData.order?.id ?? 'receipt');
      return output;
    } catch (e) {
      return null;
    }
  }

  // PDF Components

  static pw.Widget _buildHeader() {
    return pw.Container(
      padding: pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#00424D'),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'DINMAJUR',
            style: pw.TextStyle(
              fontSize: 32,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Delivery Receipt',
            style: pw.TextStyle(
              fontSize: 16,
              color: PdfColors.white,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildOrderInfo(Data orderData) {
    final order = orderData.order;
    final orderId = order?.id?.substring(order.id!.length - 6) ?? 'N/A';
    final createdAt = order?.createdAt != null
        ? DateFormat('MMM dd, yyyy hh:mm a').format(order!.createdAt!)
        : 'N/A';

    return pw.Container(
      padding: pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Order ID',
                style: pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.grey700,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                '#$orderId',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'Order Date',
                style: pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.grey700,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                createdAt,
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildCustomerInfo(Data orderData) {
    final customer = orderData.customer;

    return pw.Container(
      padding: pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#F5F5F5'),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Customer Information',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Divider(),
          pw.SizedBox(height: 8),
          _buildInfoRow('Name', customer?.fullName ?? 'N/A'),
          pw.SizedBox(height: 6),
          _buildInfoRow('Phone', customer?.phone ?? 'N/A'),
        ],
      ),
    );
  }

  static pw.Widget _buildRetailerInfo(Data orderData) {
    final retailer = orderData.retailer;

    return pw.Container(
      padding: pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#F5F5F5'),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Retailer Information',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Divider(),
          pw.SizedBox(height: 8),
          _buildInfoRow('Business Name', retailer?.businessName ?? 'N/A'),
          pw.SizedBox(height: 6),
          _buildInfoRow('Business Type', retailer?.businessType ?? 'N/A'),
          pw.SizedBox(height: 6),
          _buildInfoRow('Address', retailer?.fullAddress ?? 'N/A'),
        ],
      ),
    );
  }

  static pw.Widget _buildDeliveryInfo(Data orderData) {
    final delivery = orderData.delivery;
    final payment = orderData.paymentMethod;
    final freelancer = orderData.freelancer;
    final deliveredAt = delivery?.deliveredAt != null
        ? DateFormat('MMM dd, yyyy hh:mm a').format(
        delivery!.deliveredAt!.add(Duration(hours: 6)))
        : 'N/A';

    return pw.Container(
      padding: pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#E8F5E9'),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Delivery Information',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#2E7D32'),
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Divider(),
          pw.SizedBox(height: 8),
          _buildInfoRow(
            'Delivery Person',
            '${freelancer?.firstName ?? ''} ${freelancer?.lastName ?? ''}'.trim().isEmpty
                ? 'N/A'
                : '${freelancer?.firstName ?? ''} ${freelancer?.lastName ?? ''}'.trim(),
          ),
          pw.SizedBox(height: 6),
          _buildInfoRow('Phone', freelancer?.phone ?? 'N/A'),
          pw.SizedBox(height: 6),
          _buildInfoRow('Delivered At', deliveredAt),
          pw.SizedBox(height: 6),
          _buildInfoRow('Distance', delivery?.distance ?? 'N/A'),
          pw.SizedBox(height: 6),
          _buildInfoRow('Duration', delivery?.duration ?? 'N/A'),
          pw.SizedBox(height: 6),
          _buildInfoRow('Payment Type', payment?.provider ?? ''),
        ],
      ),
    );
  }

  static pw.Widget _buildItemsTable(Data orderData) {
    final items = orderData.order?.items ?? [];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Order Items',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 12),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          children: [
            // Header
            pw.TableRow(
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#00424D'),
              ),
              children: [
                _buildTableHeader('Item'),
                _buildTableHeader('Quantity'),
                _buildTableHeader('Total'),
                _buildTableHeader('Comment'),
              ],
            ),
            // Items
            ...items.map((item) {
              return pw.TableRow(
                children: [
                  _buildTableCell(item.name ?? 'N/A'),
                  _buildTableCell(
                      '${item.quantity?.toStringAsFixed(2) ?? '0'} ${item.unit ?? ''}'),
                  _buildTableCell('tk ${AmountFormatter.formatDynamic(item.totalPrice)}'),
                  _buildTableCell('${item.comment ?? "N/A"}'),
                ],
              );
            }).toList(),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildPriceSummary(Data orderData) {
    final order = orderData.order;

    return pw.Container(
      padding: pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300, width: 2),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          _buildPriceRow('Subtotal', order?.subTotalAmount ?? 0),
          pw.SizedBox(height: 8),
          _buildPriceRow('VAT', order?.vat ?? 0),
          pw.SizedBox(height: 8),
          _buildPriceRow('Service Fee', order?.customerPlatformFee ?? 0),
          pw.SizedBox(height: 8),
          _buildPriceRow('Delivery Charge', order?.deliveryCharge ?? 0),
          pw.SizedBox(height: 8),
          if (order?.customerTip != null && order!.customerTip! > 0) ...[
            _buildPriceRow('Customer Tip', order.customerTip ?? 0),
            pw.SizedBox(height: 8),
          ],
          pw.Divider(thickness: 2),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Total Amount',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                'tk ${order?.totalAmount ?? 0}',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#1E88E5'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Container(
      padding: pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#F5F5F5'),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'Thank you for using Dinmajur!',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'For support, contact us at support@dinmajur.com',
            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Generated on: ${DateFormat('MMM dd, yyyy hh:mm a').format(DateTime.now())}',
            style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Helper Methods

  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          flex: 2,
          child: pw.Text(
            '$label:',
            style: pw.TextStyle(
              fontSize: 12,
              color: PdfColors.grey700,
            ),
          ),
        ),
        pw.Expanded(
          flex: 3,
          child: pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildTableHeader(String text) {
    return pw.Container(
      padding: pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 12,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static pw.Widget _buildTableCell(String text) {
    return pw.Container(
      padding: pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 10),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static pw.Widget _buildPriceRow(String label, num amount) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
        ),
        pw.Text(
          'tk $amount',
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }


  static Future<File> _savePdf(pw.Document pdf, String orderId) async {
    try {
      Directory? baseDirectory;

      if (Platform.isAndroid) {
        baseDirectory = Directory('/storage/emulated/0/Download');

        if (!await baseDirectory.exists()) {
          try {
            await baseDirectory.create(recursive: true);
          } catch (e) {
            baseDirectory = await getExternalStorageDirectory();
          }
        }
      } else if (Platform.isIOS) {
        baseDirectory = await getApplicationDocumentsDirectory();
      }

      if (baseDirectory == null) {
        throw Exception('Could not access storage directory');
      }

      // ✅ Create "Dinajpur Booking" subfolder if it doesn't exist
      final Directory bookingFolder = Directory('${baseDirectory.path}/Dinajpur Booking');
      if (!await bookingFolder.exists()) {
        await bookingFolder.create(recursive: true);
      } else {
      }

      final String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final String fileName = 'Grocery_order_${orderId}_$timestamp.pdf';
      final String filePath = '${bookingFolder.path}/$fileName';

      final File file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      return file;
    } catch (e) {
      rethrow;
    }
  }
}