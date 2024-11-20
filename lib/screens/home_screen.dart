import 'dart:convert';
import 'dart:io' as io;
import 'dart:html' as html; // Import dart:html for web
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_bar_code_scanner_dialog/qr_bar_code_scanner_dialog.dart';
import 'package:path_provider/path_provider.dart'; // For getting application directory
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/widgets.dart' as pw; // Import pdf package
import 'package:printing/printing.dart'; // Import printing package
import 'package:fl_chart/fl_chart.dart'; // Import fl_chart package for graph
import 'package:smart_waste_web/screens/tabs/notif_tab.dart';
import 'package:table_calendar/table_calendar.dart'; // Import for Calendar

import '../utlis/colors.dart'; // Ensure this file exists
import 'login_screen.dart';
import 'tabs/items_tab.dart';
import 'tabs/records_tab.dart';
import '../widgets/text_widget.dart';
import 'tabs/users_records_tab.dart'; // Import the new tab
import 'tabs/dashboard_tab.dart'; // Import the new DashboardTab file

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool inrecords = false;
  bool initems = false;
  bool inqrcode = false;
  bool intickets = false;
  bool inusers = false;
  bool indashboard = true;
  bool innotif = false;

  final _qrBarCodeScannerDialogPlugin = QrBarCodeScannerDialog();
  String? code;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Card(
              child: SizedBox(
                width: 300,
                height: double.infinity,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2.5),
                        child: Image.asset(
                          'assets/images/logos.png',
                          height: 200,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 90.0),
                        child: TextWidget(
                          text: 'Administrator',
                          fontFamily: 'Bold',
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildMenuTile('Dashboard', indashboard, () {
                        setState(() {
                          inrecords = false;
                          initems = false;
                          inqrcode = false;
                          intickets = false;
                          inusers = false;
                          indashboard = true;
                          innotif = false;
                        });
                      }),
                      const SizedBox(height: 30),
                      _buildMenuTile('Logs', inrecords, () {
                        setState(() {
                          inrecords = true;
                          initems = false;
                          inqrcode = false;
                          intickets = false;
                          inusers = false;
                          indashboard = false;
                          innotif = false;
                        });
                      }),
                      const SizedBox(height: 30),
                      _buildMenuTile('Notification', innotif, () {
                        setState(() {
                          inrecords = false;
                          initems = false;
                          inqrcode = false;
                          intickets = false;
                          inusers = false;
                          indashboard = false;
                          innotif = true;
                        });
                      }),
                      const SizedBox(height: 20),
                      _buildMenuTile('Users Records', inusers, () {
                        setState(() {
                          inrecords = false;
                          initems = false;
                          inqrcode = false;
                          intickets = false;
                          inusers = true;
                          indashboard = false;
                          innotif = false;
                        });
                      }),
                      const SizedBox(height: 20),
                      _buildMenuTile('Items', initems, () {
                        setState(() {
                          inrecords = false;
                          initems = true;
                          inqrcode = false;
                          intickets = false;
                          inusers = false;
                          indashboard = false;
                          innotif = false;
                        });
                      }),
                      const SizedBox(height: 20),
                      _buildMenuTile('QR Code', inqrcode, () async {
                        _qrBarCodeScannerDialogPlugin.getScannedQrBarCode(
                          context: context,
                          onCode: (code) async {
                            await FirebaseFirestore.instance
                                .collection('Records')
                                .doc(code!.split('= ')[1])
                                .get()
                                .then(
                                    (DocumentSnapshot documentSnapshot) async {
                              print('My code ${code.split('= ')[1]}');
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) {
                                  return AlertDialog(
                                    content: TextWidget(
                                      text: 'QR Code Scanned Successfully!',
                                      fontSize: 48,
                                      fontFamily: 'Bold',
                                    ),
                                    actions: <Widget>[
                                      MaterialButton(
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pop(); // Close the dialog
                                        },
                                        child: const Text(
                                          'Close',
                                          style: TextStyle(
                                              fontFamily: 'QRegular',
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      MaterialButton(
                                        onPressed: () async {
                                          showReceipt(documentSnapshot.data()
                                              as Map<String, dynamic>);
                                        },
                                        child: const Text(
                                          'Generate Receipt',
                                          style: TextStyle(
                                              fontFamily: 'QRegular',
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }).catchError((error) {
                              print('Error fetching data: $error');
                            });
                          },
                        );
                      }),
                      const SizedBox(height: 20),
                      ListTile(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text(
                                'Logout Confirmation',
                                style: TextStyle(
                                    fontFamily: 'QBold',
                                    fontWeight: FontWeight.bold),
                              ),
                              content: const Text(
                                'Are you sure you want to Logout?',
                                style: TextStyle(fontFamily: 'QRegular'),
                              ),
                              actions: <Widget>[
                                MaterialButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text(
                                    'Close',
                                    style: TextStyle(
                                        fontFamily: 'QRegular',
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                MaterialButton(
                                  onPressed: () async {
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const LoginScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Continue',
                                    style: TextStyle(
                                        fontFamily: 'QRegular',
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        title: TextWidget(
                          text: 'Logout',
                          fontSize: 18,
                          color: Colors.grey,
                          fontFamily: 'Bold',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 50),
                      Align(
                        alignment: Alignment.topRight,
                        child: TextWidget(
                          text: DateFormat('MMMM dd, yyyy | hh:mm a')
                              .format(DateTime.now()),
                          fontSize: 14,
                          fontFamily: 'Bold',
                          color: primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: inrecords
                        ? const RecordsTab()
                        : inusers
                            ? const UsersRecordsTab()
                            : initems
                                ? const ItemsTab()
                                : indashboard
                                    ? const UsersGraphTab() // Refers to the new DashboardTab file
                                    : innotif
                                        ? const NotifTab()
                                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  ListTile _buildMenuTile(String text, bool selected, VoidCallback onTap) {
    return ListTile(
      tileColor: selected ? primary : Colors.transparent,
      onTap: onTap,
      title: TextWidget(
        text: text,
        fontSize: 18,
        color: selected ? Colors.white : Colors.grey,
        fontFamily: 'Bold',
      ),
    );
  }

  Future<void> showReceipt(Map<String, dynamic>? data) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          content: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextWidget(
                  text: 'User name: ${data?['myname']}',
                  fontSize: 18,
                ),
                TextWidget(
                  text: 'Item name: ${data?['name']}',
                  fontSize: 18,
                ),
                TextWidget(
                  text: 'Equivalent Points: ${data?['pts']} pts',
                  fontSize: 18,
                ),
                TextWidget(
                  text:
                      'Date and Time: ${DateFormat.yMMMd().add_jm().format((data?['dateTime'] as Timestamp).toDate())}',
                  fontSize: 18,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            MaterialButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            MaterialButton(
              onPressed: () async {
                // Create PDF
                final pdf = pw.Document();
                pdf.addPage(
                  pw.Page(
                    build: (pw.Context context) => pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Receipt',
                            style: const pw.TextStyle(fontSize: 24)),
                        pw.Text(''),
                        pw.Text('User name: ${data?['myname']}'),
                        pw.Text('Item name: ${data?['name']}'),
                        pw.Text('Equivalent Points: ${data?['pts']} pts'),
                        pw.Text(
                            'Date and Time: ${DateFormat.yMMMd().add_jm().format((data?['dateTime'] as Timestamp).toDate())}'),
                      ],
                    ),
                  ),
                );

                // Generate and download PDF
                if (kIsWeb) {
                  final bytes = await pdf.save();
                  final blob = html.Blob([bytes], 'application/pdf');
                  final url = html.Url.createObjectUrlFromBlob(blob);
                  final anchor = html.AnchorElement(href: url)
                    ..setAttribute('download', 'receipt.pdf')
                    ..click();
                  html.Url.revokeObjectUrl(url);
                } else {
                  final directory = await getApplicationDocumentsDirectory();
                  final file = io.File('${directory.path}/receipt.pdf');
                  await file.writeAsBytes(await pdf.save());
                  await Printing.sharePdf(
                      bytes: await pdf.save(), filename: 'receipt.pdf');
                }
              },
              child: const Text('Download Receipt'),
            ),
          ],
        );
      },
    );
  }
}
