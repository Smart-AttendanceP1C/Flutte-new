import 'package:flutter/material.dart';

import '../../../core/routing/app_router.dart';
import '../../../core/widgets/app_bottom_nav.dart';

/// Instructor shell — 4 tabs: Home / QR / Reports / Menu.
class InstructorShell extends StatefulWidget {
  final int initialIndex;
  const InstructorShell({super.key, this.initialIndex = 0});

  @override
  State<InstructorShell> createState() => _InstructorShellState();
}

class _InstructorShellState extends State<InstructorShell> {
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, 3);
  }

  @override
  void didUpdateWidget(covariant InstructorShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex) {
      setState(() {
        _index = widget.initialIndex.clamp(0, 3);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: InstructorTabs.pages,
      ),
      bottomNavigationBar: InstructorBottomNav(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}
