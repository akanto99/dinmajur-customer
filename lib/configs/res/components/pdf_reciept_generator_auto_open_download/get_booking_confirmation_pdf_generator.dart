import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:dinmajur_customer/model/home_models/dropdown_categories_selection_models/premium_house_keeper_model/get_confirmedbooking_model.dart';
import 'package:intl/intl.dart';

class BookingReceiptPdfGenerator {
  /// Generate and download booking receipt PDF
  static Future<File?> generateAndDownloadReceipt(Data bookingData) async {
    try {
      final pdf = pw.Document();

      // Add page to PDF
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(32),
          build: (context) => [
            _buildHeader(),
            pw.SizedBox(height: 5),
            _buildOrderId(bookingData),
            pw.SizedBox(height: 24),
            pw.Divider(height: 5, color: PdfColor.fromHex('#299D8F')),
            _buildCustomerDetails(bookingData),
            pw.SizedBox(height: 24),
            _buildOrderSchedule(bookingData),
            pw.SizedBox(height: 24),
            _buildTasksSection(bookingData),
            pw.SizedBox(height: 24),
            _buildPaymentSummary(bookingData),
            pw.SizedBox(height: 24),
            _buildFooter(),
          ],
        ),
      );

      // Save PDF to device
      final output = await _savePdf(pdf, bookingData.trackingId ?? 'booking');
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

  static pw.Widget _buildOrderId(Data bookingData) {
    return pw.Center(
      child: pw.Container(
        child: pw.Text(
          'Order ID: #${bookingData.trackingId ?? 'N/A'}',
          style: pw.TextStyle(
            fontSize: 13,
            fontWeight: pw.FontWeight.normal,
          ),
        ),
      ),
    );
  }

  static pw.Widget _buildCustomerDetails(Data bookingData) {
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
          _buildDetailRow('Name:', bookingData.fullName ?? 'N/A'),
          pw.SizedBox(height: 6),
          _buildDetailRow('Phone:', bookingData.phone ?? 'N/A'),
          pw.SizedBox(height: 6),
          _buildDetailRow('Email:', bookingData.email?.isNotEmpty == true ? bookingData.email! : 'N/A'),
          pw.SizedBox(height: 6),
          _buildDetailRow('Service Address:', bookingData.fullAddress ?? 'N/A'),
          // pw.SizedBox(height: 6),
          // _buildDetailRow('House Size:', bookingData.houseSize ?? 'N/A'),
          pw.SizedBox(height: 6),
          _buildDetailRow('Plan Type:', bookingData.serviceType ?? 'Premium Cleaning'),
          pw.SizedBox(height: 6),
          _buildDetailRow('Payment Method:', bookingData.paymentType ?? 'N/A',),
        ],
      ),
    );
  }

  static pw.Widget _buildOrderSchedule(Data bookingData) {
    final shiftId = bookingData.shiftId;
    final DateTime? rawDate = bookingData.date;
    final String dateStr = rawDate != null
        ? DateFormat('dd-MM-yyyy').format(
      rawDate.isUtc
          ? rawDate.add(const Duration(hours: 6))
          : rawDate.toUtc().add(const Duration(hours: 6)),
    )
        : 'N/A';
    final shiftStr = shiftId != null
        ? '${shiftId.type ?? ''} (${shiftId.startTime ?? ''} - ${shiftId.endTime ?? ''})'
        : 'N/A';

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColor.fromHex('#E7E9E9')),
      columnWidths: {
        0: pw.FlexColumnWidth(1),
      },
      children: [
        // Header row with "Order Schedule"
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
                textAlign: pw.TextAlign.left,
              ),
            ),
          ],
        ),
        // Column headers row (Date and Shift)
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
                        child: pw.Text(
                          'Date',
                          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Shift',
                          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        // Data row
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
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(dateStr, style: pw.TextStyle(fontSize: 12)),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(shiftStr, style: pw.TextStyle(fontSize: 12)),
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
  static pw.Widget _buildTasksSection(Data bookingData) {
    final items = bookingData.houseKeeperBookingItems ?? [];

    if (items.isEmpty) {
      return pw.Container(
        padding: pw.EdgeInsets.all(16),
        child: pw.Text(
          'No tasks available',
          style: pw.TextStyle(fontSize: 14, color: PdfColors.grey),
        ),
      );
    }

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColor.fromHex('#E7E9E9')),
      columnWidths: {
        0: pw.FlexColumnWidth(1),
      },
      children: [
        // Header row with "Tasks"
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColor.fromHex('#299D8F')),
          children: [
            pw.Padding(
              padding: pw.EdgeInsets.all(8),
              child: pw.Text(
                'Tasks',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
                textAlign: pw.TextAlign.left,
              ),
            ),
          ],
        ),
        // Column headers row (Task, Items, Total)
        pw.TableRow(
          children: [
            pw.Container(
              child: pw.Table(
                border: pw.TableBorder(
                  verticalInside: pw.BorderSide(color: PdfColor.fromHex('#E7E9E9')),
                ),
                columnWidths: {
                  0: pw.FlexColumnWidth(3),
                  1: pw.FlexColumnWidth(4),
                  2: pw.FlexColumnWidth(1.5),
                },
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey100),
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Task',
                          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Items',
                          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Total (BDT)',
                          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        // Data rows
        ...items.map((item) {
          final taskName = item.houseKeeperTaskId?.name ?? 'N/A';
          final rooms = item.totalRooms;
          final taskItems = item.houseKeeperTaskItemIds ?? [];

          // Calculate total price
          num totalPrice = 0;
          for (var taskItem in taskItems) {
            totalPrice += (taskItem.price ?? 0) * (rooms ?? 1);
          }

          // Build task name with rooms if applicable
          String displayTaskName = taskName;
          if (rooms != null && rooms > 0 && item.houseKeeperTaskId?.hasRoom == true) {
            displayTaskName = '$taskName (Rooms: $rooms)';
          }

          // Build items list
          List<pw.Widget> itemWidgets = taskItems.map((taskItem) {
            return pw.Padding(
              padding: pw.EdgeInsets.only(bottom: 2),
              child: pw.Text(
                '${taskItem.name ?? ''} - BDT ${taskItem.price ?? 0}',
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
                    0: pw.FlexColumnWidth(3),
                    1: pw.FlexColumnWidth(4),
                    2: pw.FlexColumnWidth(1.5),
                  },
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text(
                            displayTaskName,
                            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: itemWidgets,
                          ),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'BDT ${totalPrice.toStringAsFixed(0)}',
                            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
                            textAlign: pw.TextAlign.center,
                          ),
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

  static pw.Widget _buildPaymentSummary(Data bookingData) {
    final subTotal = bookingData.subTotal ?? 0;
    final transport = bookingData.fare ?? 0;
    final total = bookingData.total ?? 0;
    final grandTotal = bookingData.grandTotal ?? 0;

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColor.fromHex('#E7E9E9')),
      columnWidths: {
        0: pw.FlexColumnWidth(1),
      },
      children: [
        // Header row with "Payment Summary"
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
                textAlign: pw.TextAlign.left,
              ),
            ),
          ],
        ),
        // Payment details rows
        pw.TableRow(
          children: [
            pw.Container(
              child: pw.Table(
                border: pw.TableBorder(
                  horizontalInside: pw.BorderSide(color: PdfColor.fromHex('#E7E9E9')),
                ),
                children: [
                  _buildPaymentTableRow('Subtotal', subTotal),
                  _buildPaymentTableRow('Transportation', transport),
                  _buildPaymentTableRow('Total', total),
                ],
              ),
            ),
          ],
        ),
        // Grand Total row with colored background
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
                    'BDT ${grandTotal.toStringAsFixed(1)}',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  static pw.TableRow _buildPaymentTableRow(String label, num amount) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                label,
                style: pw.TextStyle(fontSize: 12),
              ),
              pw.Text(
                'BDT ${amount.toStringAsFixed(1)}',
                style: pw.TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Center(
      child: pw.Column(
        children: [
          pw.Text(
            'Thank you for choosing our premium housekeeping service!',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Contact us: 01929600600',
            style: pw.TextStyle(fontSize: 12),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ==================== Helper Methods ====================

  static pw.Widget _buildDetailRow(String label, String value) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: 120,
          child: pw.Text(
            label,
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            value,
            style: pw.TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }


  /// Save PDF to device storage (Downloads folder for easy access)
  // static Future<File> _savePdf(pw.Document pdf, String trackingId) async {
  //   try {
  //     Directory? directory;
  //
  //     if (Platform.isAndroid) {
  //       // Try Downloads folder first
  //       directory = Directory('/storage/emulated/0/Download');
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
  //     final String fileName = 'HouseKeeper_Bookings_${trackingId}_$timestamp.pdf';
  //     final String filePath = '${directory.path}/$fileName';
  //
  //     // Save PDF
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
            // Fallback to external storage directory
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
      final String fileName = 'HouseKeeper_Bookings_${trackingId}_$timestamp.pdf';
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