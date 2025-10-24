import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/header.dart';
import 'add_bill.dart';
import 'members.dart';
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
              print('Admin check - Admin email: $adminEmail, Current user email: ${currentUser.email}, Is admin: $_isAdmin');
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
            for (final m in membersField) {
              if (m is Map) {
                final email = m['email']?.toString() ?? '';
                final name = m['name']?.toString() ?? m['username']?.toString() ?? 'Member';
                
                if (currentUser != null && email == currentUser.email) {
                  continue;
                }
                
                final id = (email.hashCode.abs() % 70) + 1;
                final memberIsAdmin = (_adminId != null && m['_id']?.toString() == _adminId);
                
                print('Member: $name, Email: $email, Member ID: ${m['_id']}, Admin ID: $_adminId, Is admin: $memberIsAdmin');
                
                _members.add({
                  'name': name,
                  'email': email,
                  'avatar': 'https://i.pravatar.cc/150?img=$id',
                  'isCurrentUser': 'false',
                  'isAdmin': memberIsAdmin.toString(),
                });
              }
            }
          }
          
          // Set member count to the actual number of members in the list
          _memberCount = _members.length;
          
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

  // Add Bill
  void _addBill() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddBillPage(
          groupId: widget.groupId,
          members: _members,
        ),
      ),
    );
  }

  // Delete Group
  // void _showDeleteGroupDialog() {
  //   if (!_isAdmin) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Row(
  //           children: [
  //             Icon(Icons.lock, color: Colors.white),
  //             SizedBox(width: 12),
  //             Expanded(child: Text('Only admin can delete the group')),
  //           ],
  //         ),
  //         backgroundColor: Colors.orange,
  //         duration: Duration(seconds: 2),
  //         behavior: SnackBarBehavior.floating,
  //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  //       ),
  //     );
  //     return;
  //   }
  //
  //   final theme = Theme.of(context);
  //   showDialog(
  //     context: context,
  //     builder: (ctx) => AlertDialog(
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  //       title: Row(
  //         children: [
  //           Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
  //           SizedBox(width: 12),
  //           Text('Delete Group'),
  //         ],
  //       ),
  //       content: Text(
  //         'Are you sure you want to delete "$_groupName"? This action cannot be undone and will remove all group data.',
  //         style: TextStyle(fontSize: 15),
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.of(ctx).pop(),
  //           child: Text('Cancel', style: TextStyle(color: theme.primaryColor)),
  //         ),
  //         ElevatedButton(
  //           onPressed: () {
  //             Navigator.of(ctx).pop();
  //             _deleteGroup();
  //           },
  //           style: ElevatedButton.styleFrom(
  //             backgroundColor: Colors.red,
  //             foregroundColor: Colors.white,
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(8),
  //             ),
  //           ),
  //           child: Text('Delete'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Future<void> _deleteGroup() async {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (ctx) => Center(
  //       child: Container(
  //         padding: EdgeInsets.all(20),
  //         decoration: BoxDecoration(
  //           color: Theme.of(context).cardColor,
  //           borderRadius: BorderRadius.circular(12),
  //         ),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             CircularProgressIndicator(),
  //             SizedBox(height: 16),
  //             Text('Deleting group...'),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  //
  //   try {
  //     final groupService = Provider.of<GroupService>(context, listen: false);
  //     final success = await groupService.deleteGroup(widget.groupId);
  //
  //     Navigator.of(context).pop();
  //
  //     if (success) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Row(
  //             children: [
  //               Icon(Icons.check_circle, color: Colors.white),
  //               SizedBox(width: 12),
  //               Expanded(child: Text('Group deleted successfully')),
  //             ],
  //           ),
  //           backgroundColor: Colors.green,
  //           behavior: SnackBarBehavior.floating,
  //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  //           duration: Duration(seconds: 2),
  //         ),
  //       );
  //
  //       // Navigate back to groups list
  //       Navigator.of(context).pop();
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Row(
  //             children: [
  //               Icon(Icons.error, color: Colors.white),
  //               SizedBox(width: 12),
  //               Expanded(child: Text('Failed to delete group')),
  //             ],
  //           ),
  //           backgroundColor: Colors.red,
  //           behavior: SnackBarBehavior.floating,
  //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     Navigator.of(context).pop();
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Error: ${e.toString()}'),
  //         backgroundColor: Colors.red,
  //         behavior: SnackBarBehavior.floating,
  //       ),
  //     );
  //   }
  // }


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
                                  color: Colors.red.withValues(alpha: 0.1),
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

                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => MembersPage(
                                            groupName: _groupName,
                                            members: _members,
                                            primaryColor: theme.primaryColor,
                                          ),
                                        ),
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
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
                                          SizedBox(width: 4),
                                          Icon(
                                            Icons.arrow_forward_ios,
                                            size: 12,
                                            color: theme.primaryColor,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  // Action buttons below member count
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Expanded(
                                        child: _buildActionButton(
                                          icon: Icons.receipt_long,
                                          label: 'Add Bill',
                                          onTap: _addBill,
                                          theme: theme,
                                          isEnabled: true,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _buildActionButton(
                                          icon: Icons.person_add,
                                          label: 'Invite Members',
                                          onTap: _inviteViaEmail,
                                          theme: theme,
                                          isEnabled: _isAdmin,
                                        ),
                                      ),
                                    ],
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

                            // Recent Bills Section
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Recent Bills',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  
                                  _buildRecentBillsSection(cardColor, textColor, isDark, theme),
                                ],
                              ),
                            ),

                            const SizedBox(height: 28),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required ThemeData theme,
    required bool isEnabled,
  }) {
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.6,
      child: Material(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: isEnabled ? onTap : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isEnabled 
                    ? theme.primaryColor.withOpacity(0.3)
                    : Colors.grey.withOpacity(0.3),
                width: 1,
              ),
              color: isEnabled 
                  ? theme.primaryColor.withOpacity(0.05)
                  : Colors.grey.withOpacity(0.05),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isEnabled ? theme.primaryColor : Colors.grey,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isEnabled ? theme.primaryColor : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentBillsSection(Color cardColor, Color textColor, bool isDark, ThemeData theme) {
    // For now, we'll show a placeholder since we don't have bill data
    // In a real app, you would fetch bills from your service
    final List<Map<String, dynamic>> recentBills = []; // This would be populated from your bill service
    
    if (recentBills.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: Colors.grey.withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'No bills uploaded yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start by adding your first bill to track expenses',
              style: TextStyle(
                fontSize: 14,
                color: textColor.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // If bills exist, show them here
    return Column(
      children: recentBills.map((bill) => _buildBillCard(bill, cardColor, textColor, isDark, theme)).toList(),
    );
  }

  Widget _buildBillCard(Map<String, dynamic> bill, Color cardColor, Color textColor, bool isDark, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.receipt,
              color: theme.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bill['title'] ?? 'Bill',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  bill['description'] ?? 'No description',
                  style: TextStyle(
                    fontSize: 13,
                    color: textColor.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '\$${bill['amount']?.toStringAsFixed(2) ?? '0.00'}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
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