import 'package:flutter/material.dart';

class ProfilePanel extends StatelessWidget {
  final VoidCallback? onLogout;

  const ProfilePanel({Key? key, this.onLogout}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;
    final cardColor = theme.cardColor;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: primary,
            padding: EdgeInsets.only(top: 54, bottom: 28),
            child: Column(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.teal[400],
                  radius: 42,
                  child: Icon(Icons.person, size: 52, color: Colors.white),
                ),
                SizedBox(height: 16),
                Text(
                  "Hi Aryan!",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Ready to split bills! 👋",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: primary,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Edit Profile"),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              color: theme.scaffoldBackgroundColor,
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  SizedBox(height: 20),
                  _ProfileItem(
                    icon: Icons.edit,
                    text: "Edit Profile",
                    onTap: () {},
                    color: primary,
                  ),
                  _ProfileItem(
                    icon: Icons.lock_outline,
                    text: "Change Password",
                    onTap: () {},
                    color: primary,
                  ),
                  _ProfileItem(
                    icon: Icons.payment_outlined,
                    text: "Payment Settings",
                    onTap: () {},
                    color: primary,
                  ),
                  _ProfileItem(
                    icon: Icons.help_outline,
                    text: "Help & Support",
                    onTap: () {},
                    color: primary,
                  ),
                  Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: onLogout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text("Log Out", style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final Color color;

  const _ProfileItem({
    Key? key,
    required this.icon,
    required this.text,
    required this.onTap,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardColor = Theme.of(context).cardColor;
    final textColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Material(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: ListTile(
            leading: Icon(icon, color: color),
            title: Text(
              text,
              style: TextStyle(fontSize: 16, color: textColor, fontWeight: FontWeight.w500),
            ),
            trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 19),
          ),
        ),
      ),
    );
  }
}
