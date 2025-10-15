import 'package:flutter/material.dart';
import '../components/header.dart';

class GroupDetailsPage extends StatelessWidget {
  // Add real data models as needed
  const GroupDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.cardColor;
    final textColor = theme.textTheme.bodyMedium?.color ?? Colors.black87;

    // Dummy data for the example UI
    final List<MemberBalance> members = [
      MemberBalance(name: "Aryan", avatar: "https://i.pravatar.cc/150?img=12", status: "You owe ₹120", amount: 250),
      MemberBalance(name: "Harsh", avatar: "https://i.pravatar.cc/150?img=13", status: "You are owed", amount: 300)
    ];

    final List<BillItem> bills = [
      BillItem(title: "Dinner at Olive", paidBy: "Harsh", amount: 420),
      BillItem(title: "Drinks", paidBy: "Aryan", amount: 300)
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          // HEADER COMPONENT
          const Header(title: "Friday Dinner"),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  // Group visual (avatars) and title, example:
                  Center(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 60,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Positioned(
                                left: 30,
                                child: CircleAvatar(
                                  radius: 22,
                                  backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=12"),
                                ),
                              ),
                              Positioned(
                                child: CircleAvatar(
                                  radius: 24,
                                  backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=13"),
                                ),
                              ),
                              Positioned(
                                right: 30,
                                child: CircleAvatar(
                                  radius: 22,
                                  backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=14"),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Friday Dinner",
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          "5 members · Dinner at Olive",
                          style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.add),
                          label: const Text("Add Bill"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primaryColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          label: const Text("Invite"),
                          icon: const Icon(Icons.person_add_alt_1),
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            foregroundColor: theme.primaryColor,
                            side: BorderSide(color: theme.primaryColor),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Members", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                      TextButton(
                        onPressed: () {},
                        child: Text("See all", style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  ...members.map((m) => Card(
                    color: cardColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                    child: ListTile(
                      leading: CircleAvatar(backgroundImage: NetworkImage(m.avatar)),
                      title: Text(m.name, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                      subtitle: Text(m.status, style: TextStyle(color: textColor.withOpacity(0.7))),
                      trailing: Text("₹${m.amount}", style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                    ),
                  )),
                  const SizedBox(height: 13),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Recent Bills", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                      TextButton(
                        onPressed: () {},
                        child: Text("See all", style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  ...bills.map((b) => Card(
                    color: cardColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                    child: ListTile(
                      leading: CircleAvatar(child: Icon(Icons.receipt_long, color: theme.primaryColor)),
                      title: Text(b.title, style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
                      subtitle: Text("Paid by ${b.paidBy}", style: TextStyle(color: textColor.withOpacity(0.7))),
                      trailing: Text("₹${b.amount}", style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                    ),
                  )),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
      // RETAIN THE BOTTOM NAV BAR PROVIDED IN MAIN APP
      bottomNavigationBar: null, // Leave null to retain HomePanel's navigation.
      floatingActionButton: null, // Likewise, unless you specifically want to show it.
      floatingActionButtonLocation: null,
    );
  }
}

class MemberBalance {
  final String name;
  final String avatar;
  final String status;
  final int amount;

  MemberBalance({
    required this.name,
    required this.avatar,
    required this.status,
    required this.amount,
  });
}

class BillItem {
  final String title;
  final String paidBy;
  final int amount;

  BillItem({
    required this.title,
    required this.paidBy,
    required this.amount,
  });
}
