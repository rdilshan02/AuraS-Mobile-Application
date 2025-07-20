import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:skincare_app/AboutUsScreen.dart';
import 'package:skincare_app/user%20authentication/login.dart';
import 'package:skincare_app/AIAnalysisScreen.dart';
import 'package:skincare_app/BlogScreen.dart';
import 'package:skincare_app/DoctorChannelingScreen.dart';
import 'package:skincare_app/FAQScreen.dart';
import 'package:skincare_app/home_page.dart';
import 'package:skincare_app/ChatBotScreen.dart';

import 'AppointmentScreen.dart';

class CustomHeader extends StatefulWidget implements PreferredSizeWidget {
  const CustomHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<CustomHeader> createState() => _CustomHeaderState();
}

class _CustomHeaderState extends State<CustomHeader> {
  final LayerLink _layerLink = LayerLink();
  final LayerLink _profileLayerLink = LayerLink();
  OverlayEntry? _menuOverlayEntry;
  OverlayEntry? _profileOverlayEntry;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
  }

  void _handleMenuTap(String routeName) {
    _removeMenuOverlay();
    switch (routeName) {
      case 'Home':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
        break;
      case 'ChatBot':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ChatBotScreen()),
        );
        break;
      case 'My Appointments':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MyAppointmentsScreen()),
        );
        break;
      case 'FAQ':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FAQScreen()),
        );
        break;
      case 'About Us':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AboutUsScreen()),
        );
        break;
    }
  }

  void _showMenuOverlay(BuildContext context) {
    final renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);

    _menuOverlayEntry = OverlayEntry(
      builder:
          (context) => GestureDetector(
            onTap: _removeMenuOverlay,
            behavior: HitTestBehavior.translucent,
            child: Stack(
              children: [
                Positioned(
                  top: position.dy + renderBox.size.height,
                  right: 16,
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(8),
                    child: _buildMenuContent(),
                  ),
                ),
              ],
            ),
          ),
    );

    Overlay.of(context).insert(_menuOverlayEntry!);
  }

  Widget _buildMenuContent() {
    return Container(
      width: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MenuButton('Home', () => _handleMenuTap('Home')),
          _MenuButton('ChatBot', () => _handleMenuTap('ChatBot')),
          _MenuButton(
            'My Appointments',
            () => _handleMenuTap('My Appointments'),
          ),
          _MenuButton('FAQ', () => _handleMenuTap('FAQ')),
          _MenuButton('About Us', () => _handleMenuTap('About Us')),
        ],
      ),
    );
  }

  void _removeMenuOverlay() {
    _menuOverlayEntry?.remove();
    _menuOverlayEntry = null;
  }

  void _handleSignOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      _removeProfileOverlay();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error signing out')));
    }
  }

  void _showProfileOverlay(BuildContext context) {
    final renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);

    _profileOverlayEntry = OverlayEntry(
      builder:
          (context) => GestureDetector(
            onTap: _removeProfileOverlay,
            behavior: HitTestBehavior.translucent,
            child: Stack(
              children: [
                Positioned(
                  top: position.dy + renderBox.size.height,
                  right: 16,
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(8),
                    child: _buildProfileMenu(),
                  ),
                ),
              ],
            ),
          ),
    );

    Overlay.of(context).insert(_profileOverlayEntry!);
  }

  Widget _buildProfileMenu() {
    return Container(
      width: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [_MenuButton('Sign Out', _handleSignOut)],
      ),
    );
  }

  void _removeProfileOverlay() {
    _profileOverlayEntry?.remove();
    _profileOverlayEntry = null;
  }

  @override
  void dispose() {
    _removeMenuOverlay();
    _removeProfileOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: CompositedTransformTarget(
        link: _profileLayerLink,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'AuraS',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu, color: Color(0xFFF44336)),
                    onPressed:
                        () =>
                            _menuOverlayEntry == null
                                ? _showMenuOverlay(context)
                                : _removeMenuOverlay(),
                  ),
                  CompositedTransformTarget(
                    link: _profileLayerLink,
                    child: InkWell(
                      onTap:
                          () =>
                              _profileOverlayEntry == null
                                  ? _showProfileOverlay(context)
                                  : _removeProfileOverlay(),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundImage:
                            _currentUser?.photoURL != null
                                ? NetworkImage(_currentUser!.photoURL!)
                                : const AssetImage(
                                      'assets/images/default_profile.jpg',
                                    )
                                    as ImageProvider,
                        child:
                            _currentUser?.photoURL == null
                                ? const Icon(Icons.person, color: Colors.white)
                                : null,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _MenuButton(this.text, this.onTap);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
        ),
        child: SizedBox(
          width: double.infinity,
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ),
      ),
    );
  }
}

class CustomNavigationBar extends StatelessWidget {
  final String activeRoute;

  const CustomNavigationBar({super.key, required this.activeRoute});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            const SizedBox(width: 16),
            _NavItem(
              title: 'Home',
              isActive: activeRoute == 'Home',
              onTap:
                  () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  ),
            ),
            _NavItem(
              title: 'AI Analysis',
              isActive: activeRoute == 'AI Analysis',
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AISkinAnalysisScreen(),
                    ),
                  ),
            ),
            _NavItem(
              title: 'Chat Bot',
              isActive: activeRoute == 'Chat Bot',
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChatBotScreen(),
                    ),
                  ),
            ),
            _NavItem(
              title: 'Doctor Channelling',
              isActive: activeRoute == 'Doctor Channelling',
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DoctorChannelingScreen(),
                    ),
                  ),
            ),
            _NavItem(
              title: 'Blog',
              isActive: activeRoute == 'Blog',
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const BlogScreen()),
                  ),
            ),
            _NavItem(
              title: 'FAQ',
              isActive: activeRoute == 'FAQ',
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FAQScreen()),
                  ),
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String title;
  final bool isActive;
  final VoidCallback? onTap;

  const _NavItem({
    required this.title,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IntrinsicWidth(
              child: Column(
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.normal,
                      color: isActive ? Colors.black : Colors.grey,
                    ),
                  ),
                  if (isActive)
                    Container(
                      height: 2,
                      color: const Color(0xFFDF4F5C),
                      margin: const EdgeInsets.only(top: 4),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
