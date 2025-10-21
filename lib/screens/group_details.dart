import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/header.dart';
import '../services/group_service.dart';
import '../services/auth_service.dart';
import '../services/invite_service.dart';

class GroupDetailsPage extends StatefulWidget {
  final String groupId;

  const GroupDetailsPage({super.key, required this.groupId});

  @override
  State<GroupDetailsPage> createState() => _GroupDetailsPageState();
}

class _GroupDetailsPageState extends State<GroupDetailsPage> {
  bool _isLoading = true;
  String? _error;
  String _groupName = '';
  String _groupDescription = '';
  int _memberCount = 0;
  List<Map<String, String>> _members = [];
  String? _adminId;
  String? _currentUserId;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadGroupDetails();
  }

  Future<void> _loadGroupDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final groupService = Provider.of<GroupService>(context, listen: false);
      final groupData = await groupService.fetchGroupDetails(widget.groupId);

      if (groupData != null) {
        final currentUser = await AuthService.getProfile();
        
        // Get admin/creator ID
        final createdByField = groupData['createdBy'];
        if (createdByField is Map) {
          _adminId = createdByField['_id']?.toString() ?? createdByField['id']?.toString();
        } else if (createdByField is String) {
          _adminId = createdByField;
        }
        
        setState(() {
          _groupName = groupData['name']?.toString() ?? 'Group';
          _groupDescription = groupData['description']?.toString() ?? '';
          
          final membersField = groupData['members'];
          _members = [];
          
          if (currentUser != null) {
            _currentUserId = currentUser.email; // Using email as ID for comparison
            final userEmail = currentUser.email.isNotEmpty ? currentUser.email : 'user@example.com';
            final userId = (userEmail.hashCode.abs() % 70) + 1;
            
            // Check if current user is admin
            if (_adminId != null && createdByField is Map) {
              final adminEmail = createdByField['email']?.toString() ?? '';
              _isAdmin = (adminEmail == currentUser.email);
            }
            
            _members.add({
              'name': currentUser.name,
              'email': userEmail,
              'avatar': 'https://i.pravatar.cc/150?img=$userId',
              'isCurrentUser': 'true',
              'isAdmin': _isAdmin.toString(),
            });
          }
          
          if (membersField is List) {
            _memberCount = membersField.length;
            
            for (final m in membersField) {
              if (m is Map) {
                final email = m['email']?.toString() ?? '';
                final name = m['name']?.toString() ?? m['username']?.toString() ?? 'Member';
                
                if (currentUser != null && email == currentUser.email) {
                  continue;
                }
                
                final id = (email.hashCode.abs() % 70) + 1;
                final memberIsAdmin = (_adminId != null && m['_id']?.toString() == _adminId);
                
                _members.add({
                  'name': name,
                  'email': email,
                  'avatar': 'https://i.pravatar.cc/150?img=$id',
                  'isCurrentUser': 'false',
                  'isAdmin': memberIsAdmin.toString(),
                });
              }
            }
          } else {
            _memberCount = 1;
          }
          
          if (_memberCount < 1) _memberCount = 1;
          
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load group details';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _inviteViaEmail() {
    if (!_isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.lock, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text('Only admin can invite members')),
            ],
          ),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    final TextEditingController emailController = TextEditingController();
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.email, color: theme.primaryColor, size: 28),
            SizedBox(width: 12),
            Text('Invite Member'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter the email address of the person you want to invite:',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'friend@example.com',
                prefixIcon: Icon(Icons.alternate_email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = emailController.text.trim();
              
              if (email.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please enter an email address'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!emailRegex.hasMatch(email)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please enter a valid email address'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              Navigator.of(ctx).pop();

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (ctx) => Center(
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Sending invite...'),
                      ],
                    ),
                  ),
                ),
              );

              try {
                final result = await InviteService.sendInvite(
                  groupId: widget.groupId,
                  friendEmail: email,
                );

                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(
                          result['success'] ? Icons.check_circle : Icons.error,
                          color: Colors.white,
                        ),
                        SizedBox(width: 12),
                        Expanded(child: Text(result['message'])),
                      ],
                    ),
                    backgroundColor: result['success'] ? Colors.green : Colors.red,
                    duration: Duration(seconds: 3),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              } catch (e) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Send Invite'),
          ),
        ],
      ),
    );
  }

  void _addBill() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info, color: Colors.white),
            SizedBox(width: 12),
            Expanded(child: Text('Add Bill feature coming soon!')),
          ],
        ),
        backgroundColor: Theme.of(context).primaryColor,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.cardColor;
    final textColor = theme.textTheme.bodyMedium?.color ?? Colors.black87;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          Header(title: _groupName.isEmpty ? "Loading..." : _groupName),
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: theme.primaryColor,
                          strokeWidth: 3,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Loading group details...',
                          style: TextStyle(
                            color: textColor.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : _error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: Colors.red,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Oops!',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _error!,
                                style: TextStyle(
                                  color: textColor.withOpacity(0.7),
                                  fontSize: 15,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 28),
                              ElevatedButton.icon(
                                onPressed: _loadGroupDetails,
                                icon: const Icon(Icons.refresh, size: 20),
                                label: const Text('Try Again'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: isDark
                                      ? [
                                          theme.primaryColor.withOpacity(0.15),
                                          theme.primaryColor.withOpacity(0.05),
                                        ]
                                      : [
                                          theme.primaryColor.withOpacity(0.08),
                                          theme.primaryColor.withOpacity(0.02),
                                        ],
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                              child: Column(
                                children: [
                                  if (_members.isNotEmpty)
                                    Container(
                                      height: 80,
                                      child: _buildEnhancedAvatarStack(),
                                    ),
                                  const SizedBox(height: 18),
                                  
                                  Text(
                                    _groupName,
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                      letterSpacing: 0.3,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: theme.primaryColor.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: theme.primaryColor.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.people,
                                          size: 16,
                                          color: theme.primaryColor,
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          "$_memberCount member${_memberCount != 1 ? 's' : ''}",
                                          style: TextStyle(
                                            color: theme.primaryColor,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  if (_groupDescription.isNotEmpty) ...[
                                    const SizedBox(height: 16),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: cardColor,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                                            blurRadius: 10,
                                            offset: Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.info_outline,
                                                size: 18,
                                                color: theme.primaryColor,
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                'Description',
                                                style: TextStyle(
                                                  color: theme.primaryColor,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            _groupDescription,
                                            style: TextStyle(
                                              color: textColor.withOpacity(0.85),
                                              fontSize: 14,
                                              height: 1.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Quick Actions',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  
                                  _buildActionCard(
                                    icon: Icons.receipt_long,
                                    title: 'Add Bill',
                                    subtitle: 'Split a new expense with the group',
                                    color: theme.primaryColor,
                                    onTap: _addBill,
                                    cardColor: cardColor,
                                    textColor: textColor,
                                    isDark: isDark,
                                  ),
                                  
                                  const SizedBox(height: 12),
                                  
                                  _buildActionCard(
                                    icon: Icons.person_add,
                                    title: 'Invite Members',
                                    subtitle: _isAdmin 
                                        ? 'Send invitation via email' 
                                        : 'Only admin can invite members',
                                    color: _isAdmin ? Colors.green : Colors.grey,
                                    onTap: _inviteViaEmail,
                                    cardColor: cardColor,
                                    textColor: textColor,
                                    isDark: isDark,
                                    isDisabled: !_isAdmin,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 28),

                            if (_members.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Members',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: textColor,
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: theme.primaryColor.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            '${_members.length}',
                                            style: TextStyle(
                                              color: theme.primaryColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 14),
                                    
                                    ..._members.map((member) => _buildMemberCard(
                                      name: member['name']!,
                                      email: member['email']!,
                                      avatar: member['avatar']!,
                                      cardColor: cardColor,
                                      textColor: textColor,
                                      isDark: isDark,
                                      isCurrentUser: member['isCurrentUser'] == 'true',
                                      isAdmin: member['isAdmin'] == 'true',
                                      primaryColor: theme.primaryColor,
                                    )),
                                  ],
                                ),
                              ),

                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    required Color cardColor,
    required Color textColor,
    required bool isDark,
    bool isDisabled = false,
  }) {
    return Opacity(
      opacity: isDisabled ? 0.6 : 1.0,
      child: Material(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: color.withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: textColor.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isDisabled)
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: textColor.withOpacity(0.3),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMemberCard({
    required String name,
    required String email,
    required String avatar,
    required Color cardColor,
    required Color textColor,
    required bool isDark,
    required Color primaryColor,
    bool isCurrentUser = false,
    bool isAdmin = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: isCurrentUser 
            ? Border.all(color: primaryColor.withOpacity(0.5), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: primaryColor.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(avatar),
                ),
              ),
              if (isAdmin)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      shape: BoxShape.circle,
                      border: Border.all(color: cardColor, width: 2),
                    ),
                    child: Icon(
                      Icons.star,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isCurrentUser) ...[
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'You',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ),
                    ],
                    if (isAdmin) ...[
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Admin',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[700],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (email.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    email,
                    style: TextStyle(
                      fontSize: 13,
                      color: textColor.withOpacity(0.6),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedAvatarStack() {
    if (_members.isEmpty) return const SizedBox.shrink();

    if (_members.length == 1) {
      return Center(
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 36,
            backgroundImage: NetworkImage(_members[0]['avatar']!),
          ),
        ),
      );
    }

    if (_members.length == 2) {
      return Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: MediaQuery.of(context).size.width * 0.25,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 32,
                backgroundImage: NetworkImage(_members[0]['avatar']!),
              ),
            ),
          ),
          Positioned(
            right: MediaQuery.of(context).size.width * 0.25,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 32,
                backgroundImage: NetworkImage(_members[1]['avatar']!),
              ),
            ),
          ),
        ],
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          left: MediaQuery.of(context).size.width * 0.18,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 28,
              backgroundImage: NetworkImage(_members[0]['avatar']!),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 32,
            backgroundImage: NetworkImage(_members[1]['avatar']!),
          ),
        ),
        if (_members.length > 2)
          Positioned(
            right: MediaQuery.of(context).size.width * 0.18,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 28,
                backgroundImage: NetworkImage(_members[2]['avatar']!),
              ),
            ),
          ),
      ],
    );
  }
}