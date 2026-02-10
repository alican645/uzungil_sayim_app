import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/application/stock/stock_bloc.dart';
import '../../../../core/application/stock/stock_event.dart';

class SendToVegaButton extends StatelessWidget {
  const SendToVegaButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () {
            context.read<StockBloc>().add(ProcessToVega());
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2D5A3D),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            shadowColor: const Color(0x40000000),
          ),
          child: const Text(
            'Vegaya İşle',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
