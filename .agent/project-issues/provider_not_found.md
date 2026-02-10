---
title: ProviderNotFoundException in StockListView
status: Not Fixed
priority: High
created: 2026-02-10
tags: [flutter, provider, bloc, error]
---

# Issue: ProviderNotFoundException

## Description
When attempting to delete or edit a stock record in `StockListView`, the app crashes with `ProviderNotFoundException: Error: Could not find the correct Provider<StockBloc> above this Builder Widget`.

## Root Cause
The `showDialog` method pushes a new route onto the navigation stack. This new route's widget tree is structurally separate from the widget tree where `showDialog` was called.

In our current architecture, `StockBloc` is provided inside `SayimScreen` (a specific route). Because the provider is scoped to that route, the dialog (which lives in the root navigator overlay) cannot access it.

## Solution
To fix this, we ensure that the `BuildContext` used inside the dialog has access to the `StockBloc`.

### Applied Fix: Capture Bloc Instance
We capture the existing `StockBloc` instance from the valid context before showing the dialog, and then provide it to the dialog's widget tree using `BlocProvider.value`.

#### Code Changes

**1. `_showEditDialog` Update:**
We wrap `ProductForm` in `BlocProvider.value` so it can access the bloc internally.

```dart
  void _showEditDialog(BuildContext context, StockCount item) {
    // Capture the bloc from the context where it is valid
    final stockBloc = context.read<StockBloc>();
    
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        // ...
        child: SingleChildScrollView(
            child: BlocProvider.value(
              value: stockBloc,
              child: ProductForm(
                // ...
              ),
            ),
        ),
      ),
    );
  }
```

**2. `_confirmDelete` Update:**
We use the captured `stockBloc` instance directly to add the event.

```dart
  void _confirmDelete(BuildContext context, int id) {
    // Capture the existing bloc
    final stockBloc = context.read<StockBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        // ...
            ElevatedButton(
                onPressed: () {
                    // Use captured bloc
                    stockBloc.add(DeleteLocalStock(id)); 
                    Navigator.pop(dialogContext);
                    // ...
                },
                // ...
            ),
        // ...
      ),
    );
  }
```
