// lib/panels/create_group.dart
import 'package:flutter/material.dart';
import '../components/header.dart';
import '../models/group_model.dart';
import 'package:provider/provider.dart';
import '../services/group_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/auth_service.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _groupDescriptionController = TextEditingController();

  bool _isCreating = false;

  @override
  void dispose() {
    _groupNameController.dispose();
    _groupDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateGroup() async {
    // Validate the form first
    if (!(_formKey.currentState?.validate() ?? false)) {
      // Show error message if group name is not filled
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in the group name'),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _isCreating = true);

    try {
      // Create a new GroupModel instance with the entered data
      final newGroup = GroupModel(
        name: _groupNameController.text.trim(),
        members: 1, // Initially just the creator
        status: GroupStatus.settled, // No transactions yet
        amount: 0, // No amount owed initially
        avatars: [
          // Add current user's avatar
          'https://i.pravatar.cc/150?img=12', // Replace with actual user avatar
        ],
        icon: Icons.group, // Default group icon
      );

      // Send this data to backend and add returned group to local service
      final serverGroup = await _createGroupInBackend(newGroup);

      try {
        final svc = Provider.of<GroupService>(context, listen: false);
        if (serverGroup != null) {
          svc.addGroup(serverGroup);
        } else {
          // fallback to optimistic local group
          svc.addGroup(newGroup);
        }
        // switch to Groups tab (index 1)
        svc.selectedIndex = 1;
      } catch (_) {
        // if provider is not available, ignore
      }

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Group "${newGroup.name}" created successfully!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      // Clear the form fields
      _groupNameController.clear();
      _groupDescriptionController.clear();

      setState(() => _isCreating = false);

    } catch (e) {
      if (!mounted) return;

      // Show error message if something goes wrong
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating group: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );

      setState(() => _isCreating = false);
    }
  }

  // Backend API call - attempts to create group on server and returns created GroupModel
  Future<GroupModel?> _createGroupInBackend(GroupModel group) async {
    // Build endpoint - NOTE: assumption: groups create endpoint is /groups/create
    const base = 'https://split-pay-q4wa.onrender.com/api/v1';
    final uri = Uri.parse('$base/groups/create');

    final token = await AuthService.getToken();

    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final body = jsonEncode({
      'name': group.name,
      'description': _groupDescriptionController.text.trim(),
      'members': [], // let backend attach creator via token
    });

    try {
      var res = await http.post(uri, headers: headers, body: body).timeout(const Duration(seconds: 10));
      if (!(res.statusCode == 200 || res.statusCode == 201)) {
        // try alternative endpoint /groups
        final altUri = Uri.parse('$base/groups');
        try {
          res = await http.post(altUri, headers: headers, body: body).timeout(const Duration(seconds: 8));
        } catch (_) {}
      }

      if (res.statusCode == 200 || res.statusCode == 201) {
        final Map<String, dynamic> parsed = jsonDecode(res.body);
        // Support different payload shapes
        final Map<String, dynamic>? g = parsed['group'] is Map<String, dynamic>
            ? parsed['group'] as Map<String, dynamic>
            : (parsed['data'] is Map && parsed['data']['group'] is Map)
                ? parsed['data']['group'] as Map<String, dynamic>
                : null;

        if (g != null) {
          final membersField = g['members'];
          int membersCount = 1;
          List<String> avatars = [];
          if (membersField is List) {
            membersCount = membersField.length;
            // if members contain user objects, try to build simple avatars from email using pravatar
            try {
              for (final m in membersField) {
                if (m is Map && (m['email'] is String)) {
                  // generate a placeholder avatar using hash of email -> number
                  final email = m['email'] as String;
                  final id = (email.hashCode.abs() % 70) + 1; // pravatar supports up to ~70
                  avatars.add('https://i.pravatar.cc/150?img=$id');
                }
              }
            } catch (_) {}
          }

          final created = GroupModel(
            name: g['name']?.toString() ?? group.name,
            members: membersCount,
            status: GroupStatus.settled,
            amount: 0,
            avatars: avatars,
            icon: Icons.group,
          );
          return created;
        }
        return null;
      } else {
        // Non-success - parse message for developer feedback
        print('Create group failed: ${res.statusCode} ${res.body}');
        return null;
      }
    } catch (e) {
      print('Error creating group: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;
    final cardColor = theme.cardColor;
    final textColor = theme.textTheme.bodyMedium?.color ?? Colors.black87;
    final backgroundColor = theme.scaffoldBackgroundColor;

    // Insets for safe areas and keyboard
    final media = MediaQuery.of(context);
    final safeBottom = media.viewPadding.bottom;
    final keyboardBottom = media.viewInsets.bottom;
    final extraBottomPadding = (safeBottom + 16.0);

    return Scaffold(
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        bottom: true,
        child: Column(
          children: [
            // Header Component
            const Header(
              title: "Create Group",
              heightFactor: 0.12,
            ),

            // Form Content
            Expanded(
              child: AnimatedPadding(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOut,
                padding: EdgeInsets.only(bottom: keyboardBottom > 0 ? keyboardBottom : 0),
                child: SingleChildScrollView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(20, 16, 20, extraBottomPadding),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),

                        // Group Name Label
                        Text(
                          "Group Name",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Group Name Input (Required)
                        TextFormField(
                          controller: _groupNameController,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 15,
                          ),
                          decoration: InputDecoration(
                            hintText: "Enter group name",
                            hintStyle: TextStyle(
                              color: textColor.withOpacity(0.5),
                            ),
                            filled: true,
                            fillColor: cardColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: isDark
                                    ? Colors.white.withOpacity(0.1)
                                    : Colors.grey.withOpacity(0.2),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: primaryColor,
                                width: 2,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.red,
                                width: 1,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.red,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a group name';
                            }
                            if (value.trim().length < 3) {
                              return 'Group name must be at least 3 characters';
                            }
                            return null;
                          },
                          textInputAction: TextInputAction.next,
                        ),

                        const SizedBox(height: 24),

                        // Description Label
                        Text(
                          "Description",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Description Input (Optional)
                        TextFormField(
                          controller: _groupDescriptionController,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 15,
                          ),
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: "Enter group description (optional)",
                            hintStyle: TextStyle(
                              color: textColor.withOpacity(0.5),
                            ),
                            filled: true,
                            fillColor: cardColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: isDark
                                    ? Colors.white.withOpacity(0.1)
                                    : Colors.grey.withOpacity(0.2),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: primaryColor,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          textInputAction: TextInputAction.done,
                        ),

                        const SizedBox(height: 40),

                        // Create Button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isCreating ? null : _handleCreateGroup,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              disabledBackgroundColor: primaryColor.withOpacity(0.6),
                              foregroundColor: Colors.white,
                              disabledForegroundColor: Colors.white70,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: _isCreating
                                ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                                : const Text(
                              "Create",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
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
}

