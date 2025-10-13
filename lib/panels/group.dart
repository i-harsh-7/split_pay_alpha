// import 'package:flutter/material.dart';
// import 'create_group.dart';
// import '../components/header.dart';
//
// class GroupsPanel extends StatelessWidget {
//   final List<GroupInfo> groups;
//
//   const GroupsPanel({
//     Key? key,
//     this.groups = const [],
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final textColor = theme.textTheme.bodyMedium?.color ?? Colors.black87;
//     final cardColor = theme.cardColor;
//     final owedColor = theme.brightness == Brightness.dark ? Colors.red[300]! : Colors.red;
//     final owingColor = theme.brightness == Brightness.dark ? Colors.greenAccent : Colors.green;
//     final background = theme.scaffoldBackgroundColor;
//
//     return Scaffold(
//       backgroundColor: background,
//       body: Column(
//         children: [
//           Header(
//             title: "Groups",
//           ),
//           Expanded(
//             child: groups.isEmpty
//                 ? _NoGroupsView()
//                 : Padding(
//               padding: const EdgeInsets.all(18),
//               child: SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _GroupActionButtons(),
//                     SizedBox(height: 18),
//                     Text(
//                       "Your Groups",
//                       style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 17,
//                           color: textColor),
//                     ),
//                     SizedBox(height: 14),
//                     Column(
//                       children: groups
//                           .map(
//                             (g) => _GroupCard(
//                           group: g,
//                           cardColor: cardColor,
//                           owedColor: owedColor,
//                           owingColor: owingColor,
//                           textColor: textColor,
//                         ),
//                       )
//                           .toList(),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // --- Action Buttons ---
// class _GroupActionButtons extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final colorPrimary = Theme.of(context).primaryColor;
//     return Container(
//       width: double.infinity,
//       decoration: BoxDecoration(
//         color: Theme.of(context).cardColor,
//         borderRadius: BorderRadius.circular(15),
//       ),
//       padding: const EdgeInsets.all(16),
//       child: Row(
//         children: [
//           Expanded(
//             child: ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: colorPrimary,
//                 foregroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 elevation: 0,
//                 padding: EdgeInsets.symmetric(vertical: 12),
//               ),
//               onPressed: () {},
//               child: Text("+ Create Group", style: TextStyle(fontSize: 15)),
//             ),
//           ),
//           SizedBox(width: 10),
//           Expanded(
//             child: OutlinedButton(
//               style: OutlinedButton.styleFrom(
//                 foregroundColor: colorPrimary,
//                 side: BorderSide(color: colorPrimary),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 padding: EdgeInsets.symmetric(vertical: 12),
//               ),
//               onPressed: () {},
//               child:
//               Text("Join via Code", style: TextStyle(fontSize: 15)),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // --- Group Card ---
// class _GroupCard extends StatelessWidget {
//   final GroupInfo group;
//   final Color cardColor;
//   final Color owedColor;
//   final Color owingColor;
//   final Color textColor;
//
//   const _GroupCard({
//     required this.group,
//     required this.cardColor,
//     required this.owedColor,
//     required this.owingColor,
//     required this.textColor,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     Color statusColor;
//     String statusText;
//
//     if (group.status == GroupStatus.owe) {
//       statusColor = owedColor;
//       statusText = "You owe ₹${group.amount.abs()}";
//     } else if (group.status == GroupStatus.owed) {
//       statusColor = owingColor;
//       statusText = "You are owed ₹${group.amount.abs()}";
//     } else {
//       statusColor = Colors.grey;
//       statusText = "Settled";
//     }
//
//     return Container(
//       margin: EdgeInsets.only(bottom: 12),
//       child: Card(
//         color: cardColor,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//         elevation: 0,
//         child: ListTile(
//           leading: _GroupAvatar(avatars: group.avatars, icon: group.icon),
//           title: Text(group.name, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
//           subtitle: Text("${group.members} members", style: TextStyle(color: textColor.withValues(alpha: 0.6))),
//           trailing: Text(
//             statusText,
//             style: TextStyle(
//               color: statusColor,
//               fontWeight: FontWeight.w600,
//               fontSize: 15,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // --- Group Avatar Widget ---
// class _GroupAvatar extends StatelessWidget {
//   final List<String> avatars;
//   final IconData? icon;
//
//   const _GroupAvatar({required this.avatars, this.icon});
//
//   @override
//   Widget build(BuildContext context) {
//     if (avatars.isNotEmpty) {
//       // Show up to 2 avatars, else fallback to icon
//       return Stack(
//         children: List.generate(
//           avatars.length > 2 ? 2 : avatars.length,
//               (i) => Positioned(
//             left: i * 15.0,
//             child: CircleAvatar(
//               radius: 15,
//               backgroundColor: Colors.grey[200],
//               backgroundImage: avatars[i].isEmpty ? null : NetworkImage(avatars[i]),
//               child: avatars[i].isEmpty && icon != null ? Icon(icon, size: 18, color: Colors.grey) : null,
//             ),
//           ),
//         ),
//       );
//     } else {
//       return CircleAvatar(
//         radius: 15,
//         backgroundColor: Colors.grey[200],
//         child: Icon(icon ?? Icons.group, size: 18, color: Colors.grey),
//       );
//     }
//   }
// }
//
// // --- Empty State View ---
// class _NoGroupsView extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final primaryColor = Theme.of(context).primaryColor;
//
//     return Container(
//       width: double.infinity,
//       alignment: Alignment.center,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 60),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.group_outlined, size: 70, color: isDark ? Colors.white24 : Colors.grey[400]),
//             SizedBox(height: 22),
//             Text(
//               "You're not in any group yet!",
//               style: TextStyle(
//                   fontSize: 18,
//                   color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
//                   fontWeight: FontWeight.w600
//               ),
//               textAlign: TextAlign.center,
//             ),
//             SizedBox(height: 6),
//             GestureDetector(
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => CreateGroupPage()),
//                 );
//               },
//               child: Text(
//                   "Create Your First Group",
//                   style: TextStyle(
//                     color: primaryColor, // Blue color from theme
//                     fontWeight: FontWeight.w600,
//                     fontSize: 15,
//                   ),
//                   textAlign: TextAlign.center
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // --- Group Data Model ---
// enum GroupStatus { owe, owed, settled }
//
// class GroupInfo {
//   final String name;
//   final int members;
//   final GroupStatus status;
//   final int amount;
//   final List<String> avatars;
//   final IconData? icon;
//
//   GroupInfo({
//     required this.name,
//     required this.members,
//     required this.status,
//     required this.amount,
//     this.avatars = const [],
//     this.icon,
//   });
// }
















import 'package:flutter/material.dart';
import '../components/header.dart';
import 'create_group.dart';

class GroupsPanel extends StatelessWidget {
  // Dummy group data
  final List<GroupModel> groups = [
    GroupModel(
      name: "Friday Dinner",
      members: 5,
      status: GroupStatus.owe,
      amount: 200,
      avatars: [
        'https://i.pravatar.cc/150?img=1',
        'https://i.pravatar.cc/150?img=2',
      ],
      icon: Icons.restaurant,
    ),
  ];

  GroupsPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color ?? Colors.black87;
    final cardColor = theme.cardColor;
    final owedColor = theme.brightness == Brightness.dark ? Colors.red[300]! : Colors.red;
    final owingColor = theme.brightness == Brightness.dark ? Colors.greenAccent : Colors.green;
    final background = theme.scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: background,
      body: Column(
        children: [
          Header(
            title: "Groups",
            actions: [
              Icon(Icons.notifications_outlined, color: Colors.white),
            ],
          ),
          Expanded(
            child: groups.isEmpty
                ? _NoGroupsView()
                : Padding(
              padding: const EdgeInsets.all(18),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _GroupActionButtons(),
                    SizedBox(height: 18),
                    Text(
                      "Your Groups",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: textColor),
                    ),
                    SizedBox(height: 14),
                    Column(
                      children: groups
                          .map((g) => _GroupCard(
                        group: g,
                        cardColor: cardColor,
                        owedColor: owedColor,
                        owingColor: owingColor,
                        textColor: textColor,
                      ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Group Action Buttons: Create Group / Join via Code ---
class _GroupActionButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorPrimary = Theme.of(context).primaryColor;
    final cardColor = Theme.of(context).cardColor;
    final textColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black87;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Manage all your groups in one place.",
            style: TextStyle(
              fontSize: 14,
              color: textColor,
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CreateGroupPage()),
                    );
                  },
                  child: Text("+ Create Group", style: TextStyle(fontSize: 15)),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorPrimary,
                    side: BorderSide(color: colorPrimary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {},
                  child: Text("Join via Code", style: TextStyle(fontSize: 15)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- Group Card ---
class _GroupCard extends StatelessWidget {
  final GroupModel group;
  final Color cardColor;
  final Color owedColor;
  final Color owingColor;
  final Color textColor;

  const _GroupCard({
    required this.group,
    required this.cardColor,
    required this.owedColor,
    required this.owingColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;

    if (group.status == GroupStatus.owe) {
      statusColor = owedColor;
      statusText = "You owe ₹${group.amount.abs()}";
    } else if (group.status == GroupStatus.owed) {
      statusColor = owingColor;
      statusText = "You are owed ₹${group.amount.abs()}";
    } else {
      statusColor = Colors.grey;
      statusText = "Settled";
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Card(
        color: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: _GroupAvatar(avatars: group.avatars, icon: group.icon),
          title: Text(
            group.name,
            style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 16),
          ),
          subtitle: Text(
            "${group.members} members",
            style: TextStyle(color: textColor.withValues(alpha: 0.6), fontSize: 13),
          ),
          trailing: Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

// --- Group Avatar Widget ---
class _GroupAvatar extends StatelessWidget {
  final List<String> avatars;
  final IconData? icon;

  const _GroupAvatar({required this.avatars, this.icon});

  @override
  Widget build(BuildContext context) {
    if (avatars.isNotEmpty && avatars.length >= 2) {
      return SizedBox(
        width: 45,
        height: 40,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey[300],
                backgroundImage: NetworkImage(avatars[0]),
              ),
            ),
            Positioned(
              left: 18,
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey[300],
                backgroundImage: NetworkImage(avatars[1]),
              ),
            ),
          ],
        ),
      );
    } else if (avatars.isNotEmpty) {
      return CircleAvatar(
        radius: 20,
        backgroundColor: Colors.grey[300],
        backgroundImage: NetworkImage(avatars[0]),
      );
    } else {
      return CircleAvatar(
        radius: 20,
        backgroundColor: Colors.grey[300],
        child: Icon(icon ?? Icons.group, size: 22, color: Colors.grey[600]),
      );
    }
  }
}

// --- Empty State View ---
class _NoGroupsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group_outlined,
                size: 70, color: isDark ? Colors.white24 : Colors.grey[400]),
            SizedBox(height: 22),
            Text(
              "You're not in any group yet!",
              style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).textTheme.bodyLarge?.color ??
                      Colors.black,
                  fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 6),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateGroupPage()),
                );
              },
              child: Text("Create Your First Group",
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.center),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Group Data Model ---
enum GroupStatus { owe, owed, settled }

class GroupModel {
  final String name;
  final int members;
  final GroupStatus status;
  final int amount;
  final List<String> avatars;
  final IconData? icon;

  GroupModel({
    required this.name,
    required this.members,
    required this.status,
    required this.amount,
    this.avatars = const [],
    this.icon,
  });
}
