import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/header.dart';
import '../models/group_model.dart';
import '../screens/group_details.dart';
import '../services/group_service.dart';

class GroupsPanel extends StatelessWidget {
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
            title: "Groups"
          ),
          Expanded(
            child: Consumer<GroupService>(
              builder: (context, svc, _) {
                final groups = svc.groups;
                return groups.isEmpty
                    ? _NoGroupsView()
                    : Padding(
                        padding: const EdgeInsets.all(18),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Your Groups",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                    color: textColor),
                              ),
                              const SizedBox(height: 14),
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
                      );
              },
            ),
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

    return InkWell(
      onTap: () {
        if (group.id != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GroupDetailsPage(groupId: group.id!),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Card(
          color: cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      ),
    );
  }
}

// --- Group Avatar ---
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
            const SizedBox(height: 22),
            Text(
              "You're not in any group yet!",
              style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
                  fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}