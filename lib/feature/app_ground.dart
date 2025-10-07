import 'package:alejandroloi/core/util/app_colors.dart';
import 'package:alejandroloi/core/util/images.dart';
import 'package:alejandroloi/feature/aven/view/event_view.dart';
import 'package:alejandroloi/feature/home/view/home_view.dart';
import 'package:alejandroloi/feature/profile/view/profile_screen_view.dart';
import 'package:alejandroloi/feature/service/view/service_view.dart';
import 'package:flutter/material.dart';

import 'create_service/view/create_services_view.dart';

class AppGround extends StatefulWidget {
  const AppGround({
    super.key,
    this.initialIndex = 0,      // 0=Home, 1=Services, 2=Create, 3=Event, 4=Profile
    this.servicesInitialTab = 0, // 0=Investments, 1=Project, 2=Auctions
  });

  final int initialIndex;
  final int servicesInitialTab;

  @override
  State<AppGround> createState() => _AppGroundState();
}

class _AppGroundState extends State<AppGround> {
  late int _selectedIndex;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    // Clamp just in case a bad index is passed
    _selectedIndex = widget.initialIndex.clamp(0, 4);

    _pages = <Widget>[
      const HomeScreenView(),
      ServiceView(initialIndex: widget.servicesInitialTab),

      const CreateServicesView(),
      const EventView(),
      const ProfileScreenView(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index.clamp(0, _pages.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _pages[_selectedIndex],
      floatingActionButton: GestureDetector(
        onTap: () => _onItemTapped(2), // center FAB opens Create Services
        child: Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            color: AppColors.bottomColor1,
            borderRadius: BorderRadius.circular(50),
          ),
          child: const Icon(Icons.add_box_outlined, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        height: 80,
        shape: const CircularNotchedRectangle(),
        notchMargin: 3,
        color: AppColors.fieldColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Images.nv1, 'Home', 0),
            _buildNavItem(Images.nv2, 'Services', 1),
            const SizedBox(width: 40), // space for FAB
            _buildNavItem(Images.nb3, 'Event', 3),
            _buildNavItem(Images.personIcon, 'Profile', 4),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(String iconPath, String label, int index) {
    final bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              iconPath,
              height: 24,
              width: 24,
              color: isSelected ? Colors.orange : Colors.white,
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.orange : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
