import 'package:flutter/material.dart';
import 'panels/profile.dart';
import 'panels/group.dart';
import 'panels/create_group.dart';
import 'panels/balances.dart';

class HomePanel extends StatefulWidget {
  final VoidCallback toggleTheme;
  final ThemeMode themeMode;
  final VoidCallback onLogout;

  const HomePanel({
    super.key,
    required this.toggleTheme,
    required this.themeMode,
    required this.onLogout,
  });

  @override
  State<HomePanel> createState() => _HomePanelState();
}

class _HomePanelState extends State<HomePanel> with TickerProviderStateMixin {
  int _selectedIndex = 0;

  // Navigate to balances tab
  void _navigateToBalances() {
    setState(() {
      _selectedIndex = 3; // Balances is at index 3
    });
  }

  // Navigate to create group tab
  void _navigateToCreateGroup() {
    setState(() {
      _selectedIndex = 2; // Create Group is at index 2
    });
  }

  Widget _buildHome(BuildContext context) {
    final isDark = widget.themeMode == ThemeMode.dark;
    final colorPrimary = isDark ? Color(0xFF2266B6) : Color(0xFF3A7FD5);
    final background = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = Theme.of(context).cardColor;
    final owedColor = isDark ? Colors.red[300] : Colors.red;
    final owingColor = isDark ? Colors.greenAccent : Colors.green;
    final textPrimary = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Custom Header with rounded corners
        _buildRoundedHeader(context, colorPrimary, cardColor, textPrimary),

        Expanded(
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            color: background,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Your Balances",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: textPrimary,
                        ),
                      ),
                      TextButton(
                        onPressed: _navigateToBalances,
                        child: Text("See all"),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _navigateToBalances,
                          child: Card(
                            color: cardColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(18),
                              child: Column(
                                children: [
                                  Text("You Owe",
                                      style: TextStyle(color: owedColor, fontSize: 15)),
                                  SizedBox(height: 4),
                                  Text(
                                    "₹ 200",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 19,
                                      color: textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: _navigateToBalances,
                          child: Card(
                            color: cardColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(18),
                              child: Column(
                                children: [
                                  Text("You are Owed",
                                      style: TextStyle(color: owingColor, fontSize: 15)),
                                  SizedBox(height: 4),
                                  Text(
                                    "₹ 200",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 19,
                                      color: textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Rounded header for home panel
  Widget _buildRoundedHeader(BuildContext context, Color colorPrimary, Color cardColor, Color textPrimary) {
    final screenHeight = MediaQuery.of(context).size.height;
    final headerHeight = screenHeight * 0.30;

    return Container(
      height: headerHeight,
      decoration: BoxDecoration(
        color: colorPrimary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Title centered
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  "SplitPay",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
            // Card with greeting and button
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 30, left: 18, right: 18),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hi Aryan, ready to split today's bill?",
                          style: TextStyle(
                            color: textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorPrimary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              elevation: 0,
                            ),
                            onPressed: _navigateToCreateGroup,
                            child: const Text(
                              "Create Group",
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  final List<BottomNavigationBarItem> _navItems = [
    BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.group_outlined), label: 'Groups'),
    BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: ''),
    BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), label: 'Balances'),
    BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
  ];

  List<Widget> _tabs(BuildContext context) => [
    _buildHome(context),
    GroupsPanel(),
    CreateGroupPage(),
    BalancesPanel(),
    ProfilePanel(
      onLogout: widget.onLogout,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = widget.themeMode == ThemeMode.dark;
    final colorPrimary = Theme.of(context).primaryColor;

    return WillPopScope(
      onWillPop: () async {
        if (_selectedIndex != 0) {
          setState(() {
            _selectedIndex = 0;
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: _selectedIndex == 4
            ? AppBar(
          title: Text('SplitPay'),
          actions: [
            IconButton(
              icon: Icon(isDark ? Icons.wb_sunny : Icons.nightlight_round),
              onPressed: widget.toggleTheme,
            ),
          ],
        )
            : null,
        body: AnimatedSwitcher(
          duration: Duration(milliseconds: 350),
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: _tabs(context)[_selectedIndex],
        ),
        floatingActionButton: _selectedIndex == 2
            ? FloatingActionButton(
          onPressed: () {},
          backgroundColor: colorPrimary,
          child: Icon(Icons.add),
        )
            : null,
        bottomNavigationBar: BottomNavigationBar(
          items: _navItems,
          currentIndex: _selectedIndex,
          selectedItemColor: colorPrimary,
          unselectedItemColor: isDark ? Colors.white38 : Colors.grey,
          backgroundColor: isDark ? Color(0xFF19202E) : Colors.white,
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            setState(() => _selectedIndex = index);
          },
        ),
      ),
    );
  }
}
