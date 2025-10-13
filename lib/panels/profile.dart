import 'package:flutter/material.dart';

class ProfilePanel extends StatefulWidget {
  final VoidCallback? onLogout;
  final VoidCallback? onBackToHome; // NEW: Callback to go back to home

  const ProfilePanel({
    Key? key,
    this.onLogout,
    this.onBackToHome, // NEW
  }) : super(key: key);

  @override
  State<ProfilePanel> createState() => _ProfilePanelState();
}

class _ProfilePanelState extends State<ProfilePanel> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;
    final cardColor = theme.cardColor;
    final textColor = theme.textTheme.bodyMedium?.color ?? Colors.black;

    // Scroll progress with clamping
    final double maxScroll = 180.0;
    final double progress = (_scrollOffset / maxScroll).clamp(0.0, 1.0);

    // Blue header height animation
    final double expandedHeaderHeight = 500.0;
    final double collapsedHeaderHeight = 200.0;
    final double headerHeight = expandedHeaderHeight - (progress * (expandedHeaderHeight - collapsedHeaderHeight));

    // Profile photo size animation
    final double largePhotoSize = 180.0;
    final double smallPhotoSize = 70.0;
    final double photoSize = largePhotoSize - (progress * (largePhotoSize - smallPhotoSize));

    // Profile photo position - MINIMIZE gap in collapsed state
    final double photoCutPercentage = 0.25;
    final double expandedPhotoLeft = -(photoSize * photoCutPercentage);
    final double collapsedPhotoLeft = 30.0;
    final double photoLeftPosition = expandedPhotoLeft + (progress * (collapsedPhotoLeft - expandedPhotoLeft));

    // REDUCED top position for minimal gap
    final double expandedPhotoTop = 120.0;
    final double collapsedPhotoTop = 55.0;
    final double photoTopPosition = expandedPhotoTop - (progress * (expandedPhotoTop - collapsedPhotoTop));

    // User details position - aligned with photo
    final double expandedTextLeft = photoLeftPosition + photoSize + 20;
    final double collapsedTextLeft = collapsedPhotoLeft + smallPhotoSize + 20;
    final double textLeftPosition = expandedTextLeft + (progress * (collapsedTextLeft - expandedTextLeft));

    final double expandedTextTop = expandedPhotoTop + (photoSize / 2) - 35;
    final double collapsedTextTop = collapsedPhotoTop + (smallPhotoSize / 2) - 20;
    final double textTopPosition = expandedTextTop - (progress * (expandedTextTop - collapsedTextTop));

    // Text sizes
    final double nameSize = (24.0 - (progress * 6.0)).clamp(18.0, 24.0);
    final double emailSize = (15.0 - (progress * 2.0)).clamp(13.0, 15.0);

    // Phone number opacity
    final double phoneOpacity = (1.0 - (progress * 3.0)).clamp(0.0, 1.0);

    // Border radius
    final double borderRadius = (60.0 - (progress * 10.0)).clamp(50.0, 60.0);

    return WillPopScope(
      onWillPop: () async {
        // Intercept back button press
        if (widget.onBackToHome != null) {
          widget.onBackToHome!();
          return false; // Prevent default back action
        }
        return true; // Allow default back action if no callback
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: CustomScrollView(
          controller: _scrollController,
          physics: BouncingScrollPhysics(),
          slivers: [
            // Fixed Header
            SliverPersistentHeader(
              pinned: true,
              delegate: _ProfileHeaderDelegate(
                minHeight: collapsedHeaderHeight,
                maxHeight: expandedHeaderHeight,
                child: Stack(
                  children: [
                    // Blue Header Background
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: primary,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(borderRadius),
                            bottomRight: Radius.circular(borderRadius),
                          ),
                        ),
                        child: SafeArea(
                          bottom: false,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Profile Photo
                    Positioned(
                      top: MediaQuery.of(context).padding.top + photoTopPosition,
                      left: photoLeftPosition,
                      child: Container(
                        width: photoSize,
                        height: photoSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 15,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.network(
                            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),

                    // User Details
                    Positioned(
                      top: MediaQuery.of(context).padding.top + textTopPosition,
                      left: textLeftPosition,
                      right: 24,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Jane Doe',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: nameSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'jane.doe@example.com',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.95),
                              fontSize: emailSize,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (phoneOpacity > 0.05)
                            Opacity(
                              opacity: phoneOpacity,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  '+1 555-123-4567',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Settings List
            SliverList(
              delegate: SliverChildListDelegate([
                Padding(
                  padding: const EdgeInsets.only(top: 20, left: 18, right: 18, bottom: 100),
                  child: Column(
                    children: [
                      // Edit Profile - only in Panel 1
                      if (progress < 0.5)
                        _buildSettingCard(
                          icon: Icons.edit_outlined,
                          title: 'Edit Profile',
                          subtitle: '',
                          cardColor: cardColor,
                          textColor: textColor,
                          iconColor: primary,
                          onTap: () {},
                        ),

                      // Change Password
                      _buildSettingCard(
                        icon: Icons.lock_outline,
                        title: 'Change Password',
                        subtitle: 'Update your account security',
                        cardColor: cardColor,
                        textColor: textColor,
                        iconColor: primary,
                        onTap: () {},
                      ),

                      // Theme
                      _buildSettingCard(
                        icon: Icons.palette_outlined,
                        title: 'Theme',
                        subtitle: 'Light, Dark, or System default',
                        cardColor: cardColor,
                        textColor: textColor,
                        iconColor: primary,
                        onTap: () {},
                      ),

                      // All Other Settings
                      _buildSettingCard(
                        icon: Icons.settings_outlined,
                        title: 'All Other Settings',
                        subtitle: 'Manage notifications, privacy, and more',
                        cardColor: cardColor,
                        textColor: textColor,
                        iconColor: primary,
                        onTap: () {},
                      ),

                      SizedBox(height: 10),

                      // Logout
                      _buildSettingCard(
                        icon: Icons.logout,
                        title: 'Logout',
                        subtitle: 'Securely sign out of your account',
                        cardColor: cardColor,
                        textColor: Colors.red,
                        iconColor: Colors.red,
                        onTap: widget.onLogout,
                      ),

                      SizedBox(height: 10),

                      // About Us
                      _buildSettingCard(
                        icon: Icons.info_outline,
                        title: 'About Us',
                        subtitle: 'Learn more about our app',
                        cardColor: cardColor,
                        textColor: textColor,
                        iconColor: primary,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color cardColor,
    required Color textColor,
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: iconColor,
                  size: 26,
                ),
                SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      if (subtitle.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 13,
                              color: textColor.withOpacity(0.65),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (iconColor != Colors.red)
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey.withOpacity(0.4),
                    size: 16,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _ProfileHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_ProfileHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
