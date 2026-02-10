# MobileScanner Initialization Error

## Issue Description
When pressing the "Barkod Tara" button, the app crashes with the following error:
```
[ERROR:flutter/runtime/dart_vm_initializer.cc(40)] Unhandled Exception: MobileScannerException(controllerInitializing, The MobileScannerController is still initializing. Await the previous call to start() or disable autoStart before starting manually.)
#0      MobileScannerController.start (package:mobile_scanner/src/mobile_scanner_controller.dart:416:7)
#1      _MobileScannerState.initMobileScanner (package:mobile_scanner/src/mobile_scanner.dart:344:24)
<asynchronous suspension>
```

## Root Cause
The `MobileScanner` widget, by default, has `autoStart: true`. When `_startScanning` is called:
1. `setState` is called, determining that `_isScanning` is true.
2. The `MobileScanner` widget is added to the widget tree and immediately begins initializing/starting the controller.
3. Immediately after `setState`, `_scannerController.start()` is called manually.
4. This results in a race condition where the controller is already initializing (from the widget mount) when the manual start is requested, triggering the `MobileScannerException`.

## Solution
Since the `MobileScanner` widget automatically starts the controller when it is mounted (if `autoStart` is true, which is the default), we should **NOT** manually call `_scannerController.start()` in the `_startScanning` method.

### Recommended Fix
Remove the manual start call in `lib/presentation/Views/stock/scan_view.dart`:

```dart
  void _startScanning() {
    setState(() {
      _isScanning = true;
      _scannedCode = null;
    });
    // REMOVE THIS LINE:
    // _scannerController.start(); 
  }
```

This ensures that the controller is started only once by the `MobileScanner` widget itself when it enters the widget tree.
