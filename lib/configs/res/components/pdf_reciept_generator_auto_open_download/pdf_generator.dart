import 'dart:io';
import 'package:dinmajur_customer/configs/utils/date_formater/date_formater.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

import '../../../../model/home_models/all_service_models/getservice_confirmationdetails_model.dart' as service_model;
import '../../../../model/home_models/dropdown_categories_selection_models/beauty_and_salon_model/get_beautysalon_model.dart';

// ==================== GENERIC RECEIPT DATA MODELS ====================

/// Generic receipt data that works for ANY booking type
class ReceiptData {
  final String trackingId;
  final String? customerName;
  final String? phone;
  final String? email;
  final String? address;
  final String? notes;
  final String? status;
  final DateTime? date;
  final String? time;
  final String? paymentMethod;
  final List<ReceiptServiceItem> services;
  final ReceiptPaymentSummary paymentSummary;
  final String? footerMessage;
  final String? contactNumber;

  ReceiptData({
    required this.trackingId,
    this.customerName,
    this.phone,
    this.email,
    this.address,
    this.notes,
    this.status,
    this.date,
    this.time,
    this.paymentMethod,
    required this.services,
    required this.paymentSummary,
    this.footerMessage,
    this.contactNumber = '01929600600',
  });
}

/// Generic service item for any booking type
class ReceiptServiceItem {
  final String serviceName;
  final List<ReceiptSubItem> items;
  final int quantity;
  final num totalPrice;

  ReceiptServiceItem({
    required this.serviceName,
    required this.items,
    this.quantity = 1,
    required this.totalPrice,
  });
}

/// Sub-items within a service
class ReceiptSubItem {
  final String name;
  final num price;

  ReceiptSubItem({
    required this.name,
    required this.price,
  });
}

/// Payment summary data
class ReceiptPaymentSummary {
  final num subTotal;
  final num vat;
  final num transportationFee;
  final num discount;
  final num total;
  final num grandTotal;

  ReceiptPaymentSummary({
    required this.subTotal,
    this.vat = 0,
    this.transportationFee = 0,
    this.discount = 0,
    required this.total,
    required this.grandTotal,
  });
}

// ==================== DYNAMIC PDF GENERATOR ====================

class PDFReceiptGenerator {
  /// Generate and download receipt PDF for ANY booking type
  static Future<File?> generateAndDownloadPDFReceipt(ReceiptData receiptData) async {
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
            if (receiptData.date != null || receiptData.time != null)
              _buildOrderSchedule(receiptData),
            if (receiptData.date != null || receiptData.time != null)
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

  static pw.Widget _buildOrderId(ReceiptData data) {
    return pw.Center(
      child: pw.Text(
        'Order ID: #${data.trackingId}',
        style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.normal),
      ),
    );
  }

  static pw.Widget _buildCustomerDetails(ReceiptData data) {
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
          if (data.customerName != null)
            _buildDetailRow('Name:', data.customerName!),
          if (data.customerName != null) pw.SizedBox(height: 6),
          if (data.phone != null)
            _buildDetailRow('Phone:', data.phone!),
          if (data.phone != null) pw.SizedBox(height: 6),
          if (data.email != null && data.email!.isNotEmpty)
            _buildDetailRow('Email:', data.email!),
          if (data.email != null && data.email!.isNotEmpty) pw.SizedBox(height: 6),
          if (data.address != null)
            _buildDetailRow('Address:', data.address!),
          if (data.address != null) pw.SizedBox(height: 6),
          // if (data.notes != null && data.notes!.isNotEmpty) ...[
          //   _buildDetailRow('Notes:', data.notes!),
          //   pw.SizedBox(height: 6),
          // ],
          if (data.paymentMethod != null && data.paymentMethod!.isNotEmpty) ...[
            _buildDetailRow('Payment Method:', data.paymentMethod ?? 'N/A',),
            pw.SizedBox(height: 6),
          ],
          if (data.status != null)
            _buildDetailRow('Status:', data.status!.toUpperCase()),
        ],
      ),
    );
  }

  static pw.Widget _buildOrderSchedule(ReceiptData data) {
    final String dateStr = data.date != null
        ? DateFormat('dd MMM yyyy').format(DateFormatter.toBD(data.date!))
        : '-';
    final String timeStr = DateFormatter.formatTimeString(data.time);
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColor.fromHex('#E7E9E9')),
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColor.fromHex('#299D8F')),
          children: [
            pw.Padding(
              padding: pw.EdgeInsets.all(8),
              child: pw.Text(
                'Order Schedule',
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
                ),
                columnWidths: {
                  0: pw.FlexColumnWidth(1),
                  1: pw.FlexColumnWidth(1),
                },
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey100),
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text('Date', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text('Time', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(dateStr, style: pw.TextStyle(fontSize: 12)),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(timeStr, style: pw.TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildServicesSection(ReceiptData data) {
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
                  3: pw.FlexColumnWidth(1.5),
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
                        child: pw.Text('Quantity', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center),
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
                '${item.name} - BDT ${item.price}',
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
                    3: pw.FlexColumnWidth(1.5),
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
                          child: pw.Text('${service.quantity}', style: pw.TextStyle(fontSize: 11), textAlign: pw.TextAlign.center),
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

  static pw.Widget _buildPaymentSummary(ReceiptData data) {
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

  static pw.Widget _buildFooter(ReceiptData data) {
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

  // static Future<File> _savePdf(pw.Document pdf, String trackingId) async {
  //   try {
  //     Directory? directory;
  //
  //     if (Platform.isAndroid) {
  //       // Try Downloads folder first
  //       directory = Directory('/storage/emulated/0/Download');
  //
  //       if (!await directory.exists()) {
  //         try {
  //           await directory.create(recursive: true);
  //         } catch (e) {
  //           print("Could not create Downloads: $e");
  //           // Fallback to external storage directory
  //           directory = await getExternalStorageDirectory();
  //         }
  //       }
  //     } else if (Platform.isIOS) {
  //       directory = await getApplicationDocumentsDirectory();
  //     }
  //
  //     if (directory == null) {
  //       throw Exception('Could not access storage directory');
  //     }
  //
  //     // Create file name with timestamp
  //     final String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
  //     final String fileName = 'Beauty_Bookings_${trackingId}_$timestamp.pdf';
  //     final String filePath = '${directory.path}/$fileName';
  //
  //     // Save PDF directly to Downloads (no subfolder)
  //     final File file = File(filePath);
  //     await file.writeAsBytes(await pdf.save());
  //
  //     print('✅ PDF saved to: $filePath');
  //     return file;
  //   } catch (e) {
  //     print('❌ Error saving PDF: $e');
  //     rethrow;
  //   }
  // }
  static Future<File> _savePdf(pw.Document pdf, String trackingId) async {
    try {
      Directory? baseDirectory;

      if (Platform.isAndroid) {
        // Use Downloads folder as the base
        baseDirectory = Directory('/storage/emulated/0/Download');

        if (!await baseDirectory.exists()) {
          try {
            await baseDirectory.create(recursive: true);
          } catch (e) {
            print("Could not create Downloads: $e");
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
        print('📁 Created folder: ${bookingFolder.path}');
      } else {
        print('📁 Folder already exists: ${bookingFolder.path}');
      }

      // Create file name with timestamp
      final String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final String fileName = 'Beauty_Bookings_${trackingId}_$timestamp.pdf';
      final String filePath = '${bookingFolder.path}/$fileName';

      // Save PDF inside "Dinajpur Booking" folder
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

// ==================== ADAPTER FOR YOUR BEAUTY SALON MODEL ====================

extension BeautySalonReceiptAdapter on Data {
  ReceiptData toReceiptData() {
    // Convert beauty salon booking items to generic service items
    final services = beautySalonBookingItems?.map((item) {
      final subItems = item.beautySalonTaskItemIds?.map((taskItem) {
        return ReceiptSubItem(
          name: taskItem.name ?? '',
          price: taskItem.salePrice ?? 0,
        );
      }).toList() ?? [];

      // Calculate total for this service
      num totalPrice = 0;
      for (var subItem in subItems) {
        totalPrice += subItem.price * (item.quantity ?? 1);
      }

      return ReceiptServiceItem(
        serviceName: item.beautySalonTaskId?.name ?? 'Service',
        items: subItems,
        quantity: item.quantity ?? 1,
        totalPrice: totalPrice,
      );
    }).toList() ?? [];

    return ReceiptData(
      trackingId: trackingId ?? 'N/A',
      customerName: fullName,
      phone: phone,
      email: (email != null && email!.isNotEmpty) ? email : 'N/A',
      address: fullAddress,
      notes: notes,
      status: status,
      date: date,
      time: time,
      paymentMethod: paymentType,
      services: services,
      paymentSummary: ReceiptPaymentSummary(
        subTotal: subTotal ?? 0,
        vat: vat ?? 0,
        transportationFee: fare ?? 0,
        discount: discountValue ?? 0,
        total: total ?? 0,
        grandTotal: grandTotal ?? 0,
      ),
      footerMessage: 'Thank you for choosing our beauty and salon service!',
      contactNumber: '01929600600',
    );
  }
}

// ==================== ADAPTER FOR SERVICE MODEL ====================

extension ServiceReceiptAdapter on service_model.Data {
  ReceiptData toReceiptData() {
    final services = bookingItems?.map((item) {
      final subItems = item.task != null
          ? [
        ReceiptSubItem(
          name: item.task!.name ?? '',
          price: item.task!.price?.salePrice ?? 0,
        )
      ]
          : <ReceiptSubItem>[];

      final num totalPrice =
          (item.task?.price?.salePrice ?? 0) * (item.quantity ?? 1);

      return ReceiptServiceItem(
        serviceName: serviceSnapshot?.name ?? 'Service',
        items: subItems,
        quantity: item.quantity ?? 1,
        totalPrice: totalPrice,
      );
    }).toList() ?? [];

    return ReceiptData(
      trackingId: trackingId ?? 'N/A',
      customerName: fullName,
      phone: phone,
      email: (email != null && email!.isNotEmpty) ? email : 'N/A',
      address: fullAddress,
      notes: notes,
      status: status,
      date: date,
      time: timeSlotSnapshot?.timeLabel ?? time,
      paymentMethod: paymentType,
      services: services,
      paymentSummary: ReceiptPaymentSummary(
        subTotal: subTotal ?? 0,
        vat: vat ?? 0,
        transportationFee: fare ?? 0,
        discount: 0,
        total: total ?? 0,
        grandTotal: grandTotal ?? 0,
      ),
      footerMessage: 'Thank you for choosing our service!',
      contactNumber: '01929600600',
    );
  }
}