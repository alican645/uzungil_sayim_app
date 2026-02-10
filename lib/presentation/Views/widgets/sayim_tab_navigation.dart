import 'package:flutter/material.dart';

class SayimTabNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  const SayimTabNavigation({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              index: 0,
              title: 'Sayım',
              icon: Icons.qr_code_scanner,
              currentIndex: currentIndex,
              onTap: () => onTabSelected(0),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _TabButton(
              index: 1,
              title: 'Stok Listesi',
              icon: Icons.list_alt,
              currentIndex: currentIndex,
              onTap: () => onTabSelected(1),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final int index;
  final String title;
  final IconData icon;
  final int currentIndex;
  final VoidCallback onTap;

  const _TabButton({
    required this.index,
    required this.title,
    required this.icon,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = currentIndex == index;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: isActive
              ? const LinearGradient(
                  colors: [Color(0xFFA8D5BA), Color(0xFF7EC8A3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isActive ? null : const Color(0xFFF8FAF9),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: const Color(0xFF7EC8A3).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive ? Colors.white : const Color(0xFF6B8F7A),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: isActive ? Colors.white : const Color(0xFF6B8F7A),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
