import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'panels/profile.dart';
import 'panels/group.dart';
import 'panels/create_group.dart';
import 'panels/balances.dart';
import 'services/auth_service.dart';
import 'services/group_service.dart';

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

class _HomePanelState extends State<HomePanel> {
  String? _name;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    // Fetch groups when home panel loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GroupService>(context, listen: false).fetchGroups();
    });
  }

  Future<void> _loadProfile() async {
    final profile = await AuthService.getProfile();
    if (profile != null && mounted) {
      setState(() {
        _name = profile.name;
      });
    }
  }

  // Navigate to balances tab
  void _navigateToBalances() {
    final svc = Provider.of<GroupService>(context, listen: false);
    svc.selectedIndex = 3;
  }

  // Navigate to create group tab
  void _navigateToCreateGroup() {
    final svc = Provider.of<GroupService>(context, listen: false);
    svc.selectedIndex = 2;
  }

  Widget _buildHome(BuildContext context) {
    final isDark = widget.themeMode == ThemeMode.dark;
    final colorPrimary = isDark ? Color(0xFF2266B6) : Color(0xFF3A7FD5);
    final background = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = Theme.of(context).cardColor;
    final owedColor = isDark ? Colors.red[300] : Colors.red;
    final owingColor = isDark ? Colors.greenAccent : Colors.green;
    final textPrimary = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;

    // Responsive metrics
    final media = MediaQuery.of(context);
    final size = media.size;
    final textScale = media.textScaler.scale(1.0);
    final horizontalPadding = (size.width * 0.045).clamp(12.0, 24.0);
    final cardRadius = (size.width * 0.035).clamp(12.0, 18.0);
    final sectionTitleSize = (size.width * 0.045).clamp(16.0, 20.0) * textScale;
    final cardPadding = (size.width * 0.04).clamp(14.0, 22.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRoundedHeader(context, colorPrimary, cardColor, textPrimary),

        Expanded(
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(horizontalPadding),
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
                          fontSize: sectionTitleSize,
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
                              borderRadius: BorderRadius.circular(cardRadius),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(cardPadding),
                              child: Column(
                                children: [
                                  Text("You Owe",
                                      style: TextStyle(color: owedColor, fontSize: (size.width * 0.04).clamp(13.0, 17.0) * textScale)),
                                  SizedBox(height: 4),
                                  Text(
                                    "₹ 200",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: (size.width * 0.05).clamp(16.0, 22.0) * textScale,
                                      color: textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: (size.width * 0.03).clamp(10.0, 16.0)),
                      Expanded(
                        child: GestureDetector(
                          onTap: _navigateToBalances,
                          child: Card(
                            color: cardColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(cardRadius),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(cardPadding),
                              child: Column(
                                children: [
                                  Text("You are Owed",
                                      style: TextStyle(color: owingColor, fontSize: (size.width * 0.04).clamp(13.0, 17.0) * textScale)),
                                  SizedBox(height: 4),
                                  Text(
                                    "₹ 200",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: (size.width * 0.05).clamp(16.0, 22.0) * textScale,
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
            Padding(
              padding: EdgeInsets.symmetric(vertical: (headerHeight * 0.06).clamp(10.0, 24.0)),
              child: Center(
                child: Text(
                  "SplitPay",
                  style: TextStyle(
                    fontSize: (headerHeight * 0.09).clamp(18.0, 26.0),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
            Flexible(
              fit: FlexFit.loose,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: (headerHeight * 0.12).clamp(8.0, 28.0), left: 18, right: 18),
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Container(
                      padding: EdgeInsets.all((headerHeight * 0.06).clamp(10.0, 20.0)),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular((headerHeight * 0.08).clamp(16.0, 28.0)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _name != null
                                ? "Hi $_name, ready to split today's bill?"
                                : "Hi there, ready to split today's bill?",
                            style: TextStyle(
                              color: textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: (headerHeight * 0.06).clamp(14.0, 18.0),
                            ),
                          ),
                          SizedBox(height: (headerHeight * 0.03).clamp(6.0, 10.0)),
                          Center(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorPrimary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular((headerHeight * 0.05).clamp(10.0, 16.0)),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: (headerHeight * 0.12).clamp(16.0, 26.0), vertical: (headerHeight * 0.05).clamp(8.0, 12.0)),
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
        final svc = Provider.of<GroupService>(context, listen: false);
        if (svc.selectedIndex != 0) {
          svc.selectedIndex = 0;
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: Provider.of<GroupService>(context).selectedIndex == 4
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
        body: Consumer<GroupService>(
          builder: (context, svc, _) {
            final idx = svc.selectedIndex;
            return AnimatedSwitcher(
              duration: Duration(milliseconds: 350),
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
              child: _tabs(context)[idx],
            );
          },
        ),
        floatingActionButton: Provider.of<GroupService>(context).selectedIndex == 2
            ? FloatingActionButton(
                onPressed: () {},
                backgroundColor: colorPrimary,
                child: Icon(Icons.add),
              )
            : null,
        bottomNavigationBar: Consumer<GroupService>(
          builder: (context, svc, _) {
            return BottomNavigationBar(
              items: _navItems,
              currentIndex: svc.selectedIndex,
              selectedItemColor: colorPrimary,
              unselectedItemColor: isDark ? Colors.white38 : Colors.grey,
              backgroundColor: isDark ? Color(0xFF19202E) : Colors.white,
              type: BottomNavigationBarType.fixed,
              onTap: (index) {
                svc.selectedIndex = index;
              },
            );
          },
        ),
      ),
    );
  }
}