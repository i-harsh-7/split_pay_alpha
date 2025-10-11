import 'package:flutter/material.dart';
import 'panels/profile.dart';

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

  final _activity = [
    {
      'avatar': 'A',
      'text': 'Harsh uploaded a bill in Friday Dinner',
      'time': '2h'
    },
    {
      'avatar': 'D',
      'text': 'Deeksha settled ₹500 with you',
      'time': '1d'
    },
    {
      'avatar': 'K',
      'text': 'Kanhaiya added you to Trip Goa',
      'time': '3d'
    }
  ];

  Widget _buildHome(BuildContext context) {
    final isDark = widget.themeMode == ThemeMode.dark;
    final colorPrimary = isDark ? Color(0xFF1D3557) : Color(0xFF3A7FD5);
    final background = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = Theme.of(context).cardColor;
    final owedColor = isDark ? Colors.red[300] : Colors.red;
    final owingColor = isDark ? Colors.greenAccent : Colors.green;
    final textPrimary = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          color: colorPrimary,
          padding: const EdgeInsets.only(left: 20, right: 20, top: 38, bottom: 8),
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.menu, color: Colors.white, size: 30),
                    const Spacer(),
                    Icon(Icons.notifications_outlined, color: Colors.white),
                  ],
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hi Aryan, ready to split todays bill?",
                        style: TextStyle(
                          color: textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 19,
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorPrimary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () {},
                            child: Text("+ Add Bill"),
                          ),
                          SizedBox(width: 10),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: colorPrimary,
                              side: BorderSide(color: colorPrimary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () {},
                            child: Text("Create Group"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 18),
              ],
            ),
          ),
        ),
        Expanded(
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            color: background,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Balances
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Your Balances",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text("See all"),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        color: cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(18),
                          child: Column(
                            children: [
                              Text("You Owe", style: TextStyle(color: owedColor, fontSize: 15)),
                              SizedBox(height: 4),
                              Text("₹ 200",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 19,
                                    color: textPrimary,
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Card(
                        color: cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(18),
                          child: Column(
                            children: [
                              Text("You are Owed", style: TextStyle(color: owingColor, fontSize: 15)),
                              SizedBox(height: 4),
                              Text("₹ 200",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 19,
                                    color: textPrimary,
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                // Recent Activity
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Recent Activity', style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: textPrimary,
                    )),
                    TextButton(
                      onPressed: () {},
                      child: Text("See all"),
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: EdgeInsets.all(12),
                  child: Column(
                    children: _activity.map((a) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 7.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              child: Text(a['avatar'] ?? ''),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                a['text'] ?? '',
                                style: TextStyle(
                                  color: textPrimary,
                                ),
                              ),
                            ),
                            Text(
                              a['time'] ?? '',
                              style: TextStyle(color: Colors.grey, fontSize: 15),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  final List<BottomNavigationBarItem> _navItems = [
    BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.group_outlined), label: 'Groups'),
    BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: ''),
    BottomNavigationBarItem(icon: Icon(Icons.list_alt_outlined), label: 'Activity'),
    BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
  ];

  // List<Widget> _tabs(BuildContext context) => [
  //   _buildHome(context),
  //   Center(child: Text("Groups Panel", style: Theme.of(context).textTheme.titleLarge)),
  //   Center(child: Text("Add Bill", style: Theme.of(context).textTheme.titleLarge)),
  //   Center(child: Text("Activity Panel", style: Theme.of(context).textTheme.titleLarge)),
  //   Center(child: Text("Profile Panel", style: Theme.of(context).textTheme.titleLarge)),
  // ];

  List<Widget> _tabs(BuildContext context) => [
    _buildHome(context),
    Center(child: Text("Groups Panel", style: Theme.of(context).textTheme.titleLarge)),
    Center(child: Text("Add Bill", style: Theme.of(context).textTheme.titleLarge)),
    Center(child: Text("Activity Panel", style: Theme.of(context).textTheme.titleLarge)),
    ProfilePanel(
      onLogout: widget.onLogout,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = widget.themeMode == ThemeMode.dark;

    return Scaffold(
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 350),
        transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
        child: _tabs(context)[_selectedIndex],
      ),
      floatingActionButton: _selectedIndex == 2
          ? FloatingActionButton(
        onPressed: () {},
        backgroundColor: isDark ? Color(0xFF2266B6) : Color(0xFF3A7FD5),
        child: Icon(Icons.add),
      )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        items: _navItems,
        currentIndex: _selectedIndex,
        selectedItemColor: isDark ? Colors.white : Color(0xFF3A7FD5),
        unselectedItemColor: isDark ? Colors.white38 : Colors.grey,
        backgroundColor: isDark ? Color(0xFF19202E) : Colors.white,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 2) {
            setState(() => _selectedIndex = index); // Show add screen
          } else {
            setState(() => _selectedIndex = index);
          }
        },
      ),
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
    );
  }
}
