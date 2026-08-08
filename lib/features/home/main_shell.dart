import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_state.dart';
import '../../theme/app_colors.dart';
import 'home_screen.dart';
import '../formula/formula_screen.dart';
import '../evolution/evolution_screen.dart';
import '../health/health_screen.dart';
import '../more/more_screen.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: state.tabIndex,
        children: const [
          HomeScreen(),
          FormulaScreen(),
          EvolutionScreen(),
          HealthScreen(),
          MoreScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: state.tabIndex,
          onTap: state.setTab,
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.background,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.tertiary,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Início'),
            BottomNavigationBarItem(icon: Icon(Icons.bolt_rounded), label: 'Fórmula'),
            BottomNavigationBarItem(icon: Icon(Icons.show_chart_rounded), label: 'Evolução'),
            BottomNavigationBarItem(icon: Icon(Icons.favorite_rounded), label: 'Saúde'),
            BottomNavigationBarItem(icon: Icon(Icons.more_horiz_rounded), label: 'More'),
          ],
        ),
      ),
    );
  }
}
