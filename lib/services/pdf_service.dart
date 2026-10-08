import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/invoice.dart';
import '../models/customer.dart';
import '../models/invoice_item.dart';
import 'settings_service.dart';

class PdfService {
  static Future<void> generateAndShareInvoice({
    required Invoice invoice,
    required Customer customer,
    required List<InvoiceItem> items,
  }) async {
    final pdf = pw.Document();

    // ⚠️ مؤقتاً بدون خط عربي - سنعيد تفعيله لاحقاً
    final fontData = await rootBundle.load("assets/fonts/Cairo-Regular.ttf");
    // final ttf = pw.Font.ttf(fontData);

    final companyInfo = await SettingsService.getCompanyInfo();

    pw.ImageProvider? logoImage;
    if (companyInfo['logo']!.isNotEmpty) {
      try {
        final logoBytes = await File(companyInfo['logo']!).readAsBytes();
        logoImage = pw.MemoryImage(logoBytes);
      } catch (e) {
        logoImage = null;
      }
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(base: ttf, bold: ttf), 
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (logoImage != null)
                      pw.Container(
                        width: 70,
                        height: 70,
                        child: pw.Image(logoImage),
                      )
                    else
                      pw.SizedBox(width: 70),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          companyInfo['name']!,
                          style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
                        ),
                        if (companyInfo['phone']!.isNotEmpty)
                          pw.Text('الهاتف: ${companyInfo['phone']}'),
                        if (companyInfo['address']!.isNotEmpty)
                          pw.Text('العنوان: ${companyInfo['address']}'),
                      ],
                    ),
                  ],
                ),
                pw.Divider(thickness: 2, color: PdfColors.blueGrey800),
                pw.SizedBox(height: 10),
                pw.Center(
                  child: pw.Text(
                    'فاتورة مبيعات',
                    style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('معلومات العميل:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
                        pw.SizedBox(height: 5),
                        pw.Text('الاسم: ${customer.name}'),
                        pw.Text('الهاتف: ${customer.phone.isNotEmpty ? customer.phone : "غير متوفر"}'),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('تفاصيل الفاتورة:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
                        pw.SizedBox(height: 5),
                        pw.Text('رقم الفاتورة: ${invoice.invoiceNumber}'),
                        pw.Text('التاريخ: ${invoice.date.substring(0, 10)}'),
                        pw.Text('الحالة: ${invoice.status}'),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 25),
                pw.Table.fromTextArray(
                  headers: ['الوصف', 'الكمية', 'سعر الوحدة', 'الإجمالي'],
                  data: items.map((item) {
                    return [
                      item.description,
                      item.quantity.toString(),
                      item.unitPrice.toStringAsFixed(2),
                      item.totalPrice.toStringAsFixed(2),
                    ];
                  }).toList(),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                  headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
                  cellAlignment: pw.Alignment.centerRight,
                  cellStyle: const pw.TextStyle(fontSize: 12),
                  border: pw.TableBorder.all(color: PdfColors.grey300),
                ),
                pw.SizedBox(height: 20),
                pw.Align(
                  alignment: pw.Alignment.centerLeft,
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey100,
                      borderRadius: pw.BorderRadius.all(pw.Radius.circular(5)),
                    ),
                    child: pw.Text(
                      'الإجمالي الكلي: ${invoice.totalAmount.toStringAsFixed(2)}',
                      style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.green800),
                    ),
                  ),
                ),
                pw.SizedBox(height: 40),
                pw.Center(
                  child: pw.Text('شكراً لتعاملكم معنا!', style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey700)),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'invoice_${invoice.invoiceNumber}.pdf',
    );
  }
}