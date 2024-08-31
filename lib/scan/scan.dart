// scan.dart
// Scan groceries using the mobile scanner

// MARK: Imports
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;

// MARK: Scan Class
class Scan extends StatefulWidget {
  const Scan({Key? key}) : super(key: key);

  @override
  State<Scan> createState() => _ScanState();
}

class _ScanState extends State<Scan> with WidgetsBindingObserver {
  // Mobile Scanner Controller
  MobileScannerController controller = MobileScannerController(
    autoStart: false,
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: [BarcodeFormat.upcA, BarcodeFormat.upcE],
  );

  // Subscription for Barcode Events
  StreamSubscription<Object?>? _subscription;

  // Show Item Pop-up
  bool showItem = false;

  // Current Item
  Map<String, dynamic> currentItem = {};

  // MARK: Lifecycle State
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // If the controller is not ready, do not try to start or stop it.
    // Permission dialogs can trigger lifecycle changes before the controller is ready.
    if (!controller.value.isInitialized) {
      return;
    }

    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        return;
      case AppLifecycleState.resumed:
        // Restart the scanner when the app is resumed.
        // Don't forget to resume listening to the barcode events.
        _subscription = controller.barcodes.listen(_handleBarcode);

        unawaited(controller.start());
      case AppLifecycleState.inactive:
        // Stop the scanner when the app is paused.
        // Also stop the barcode events subscription.
        unawaited(_subscription?.cancel());
        _subscription = null;
        unawaited(controller.stop());
    }
  }

  // MARK: Init State
  @override
  void initState() {
    super.initState();
    // Start listening to lifecycle changes.
    WidgetsBinding.instance.addObserver(this);

    // Start listening to the barcode events.
    _subscription = controller.barcodes.listen(_handleBarcode);

    // Finally, start the scanner itself.
    unawaited(controller.start());
  }

  // MARK: Handle Barcode
  void _handleBarcode(BarcodeCapture barcode) {
    // TODO: Figure out why this is not working!
    // if (barcode is Barcode) {
    //   controller.stop();
    //   controller.dispose();
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //         builder: (context) =>
    //             Item(upc: barcode.barcodes.first.rawValue ?? '')),
    //   );
    // }
  }

  // Build the app
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner'),
        actions: [
          // Flash Button
          IconButton(
            icon: Icon(
                controller.torchEnabled ? Icons.flash_off : Icons.flash_on),
            onPressed: () {
              controller.toggleTorch();
            },
          ),
        ],
      ),
      body: Center(
        child: Stack(children: [
          // MARK: Item Information
          Center(
            child: Column(
              children: [
                // Item Image
                Image.network(
                    currentItem.isNotEmpty
                        ? currentItem["product"]["image_url"] ?? 'https://via.placeholder.com/150'
                        : ''),
                // Spacing
                const SizedBox(height: 20),
                // Item Name
                Text(currentItem.isNotEmpty
                    ? currentItem["product"]["product_name"] ?? 'Unknown'
                    : ''),
                // Spacing
                const SizedBox(height: 20),
                // Item Brand
                Text(currentItem.isNotEmpty
                    ? currentItem["product"]["brand_owner"] ?? 'Unknown'
                    : ''),
                // Close Button
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      // Hide the item pop-up
                      showItem = false;
                      // Reset the current item
                      currentItem = {};
                      // Restart the scanner
                      controller.start();
                    });
                  },
                ),
              ],
            ),
          ),

          // MARK: Mobile Scanner
          MobileScanner(
            controller: controller,
            onDetect: (barcodes) async {
              // Stop the scanner
              controller.stop();
              // Fetch the item
              try {
                final item = await _fetchItem(barcodes.barcodes.first.rawValue ?? '');
                // Print the item
                debugPrint("FOUND ITEM: $item");
                debugPrint("FOUND ITEM IMAGE URL: ${item["product"]["image_url"]}");
                debugPrint("FOUND ITEM NAME: ${item["product"]["product_name"]}");
                debugPrint("FOUND ITEM BRAND: ${item["product"]["brand_owner"]}");
                // Show the item pop-up
                setState(() {
                  // Set the current item
                  currentItem = item;
                  // Set the current item
                  showItem = true;
                });
              } catch (e) {
                // Print the error
                debugPrint("ERROR FINDING ITEM: $e");
                // Restart the scanner
                controller.start();
              }
            },
          ),
        ]),
      ),
    );
  }

  // MARK: Fetch Item
  Future<dynamic> _fetchItem(String upc) async {
    final response = await http.get(
        Uri.parse('https://us.openfoodfacts.org/api/v0/product/$upc.json'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load item');
    }
  }

  // MARK: Dispose Controller
  @override
  Future<void> dispose() async {
    // Stop listening to lifecycle changes.
    WidgetsBinding.instance.removeObserver(this);
    // Stop listening to the barcode events.
    unawaited(_subscription?.cancel());
    _subscription = null;
    // Dispose the widget itself.
    super.dispose();
    // Finally, dispose of the controller.
    await controller.dispose();
  }
}
