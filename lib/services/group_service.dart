import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/group_model.dart';
import 'auth_service.dart';

class GroupService extends ChangeNotifier {
  final List<GroupModel> _groups = [];
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  set selectedIndex(int v) {
    if (_selectedIndex == v) return;
    _selectedIndex = v;
    notifyListeners();
  }

  List<GroupModel> get groups => List.unmodifiable(_groups);

  void addGroup(GroupModel group) {
    _groups.insert(0, group);
    notifyListeners();
  }

  void addSampleData() {
    if (_groups.isNotEmpty) return;
    _groups.addAll([
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
      GroupModel(
        name: "Weekend Trip",
        members: 4,
        status: GroupStatus.owed,
        amount: 350,
        avatars: [
          'https://i.pravatar.cc/150?img=3',
          'https://i.pravatar.cc/150?img=4',
        ],
        icon: Icons.hiking,
      ),
    ]);
    notifyListeners();
  }

  // Try to fetch user's groups from backend. Tries a set of likely endpoints.
  Future<void> fetchGroups() async {
    final base = 'https://split-pay-q4wa.onrender.com/api/v1';
    final candidates = ['/groups', '/groups/me', '/groups/user', '/group'];
    final token = await AuthService.getToken();
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    for (final ep in candidates) {
      try {
        final uri = Uri.parse('$base$ep');
        final res = await http.get(uri, headers: headers).timeout(const Duration(seconds: 8));
        if (res.statusCode == 200) {
          final parsed = jsonDecode(res.body);
          List<dynamic>? arr;
          if (parsed is List) arr = parsed;
          if (parsed is Map && parsed['groups'] is List) arr = parsed['groups'];
          if (parsed is Map && parsed['data'] is List) arr = parsed['data'];
          if (arr != null) {
            _groups.clear();
            for (final item in arr) {
              try {
                final Map<String, dynamic> g = item is Map<String, dynamic> ? item : Map<String, dynamic>.from(item);
                final membersField = g['members'];
                int membersCount = 1;
                List<String> avatars = [];
                if (membersField is List) {
                  membersCount = membersField.length;
                  try {
                    for (final m in membersField) {
                      if (m is Map && (m['email'] is String)) {
                        final email = m['email'] as String;
                        final id = (email.hashCode.abs() % 70) + 1;
                        avatars.add('https://i.pravatar.cc/150?img=$id');
                      }
                    }
                  } catch (_) {}
                }

                _groups.add(GroupModel(
                  name: g['name']?.toString() ?? 'Group',
                  members: membersCount,
                  status: GroupStatus.settled,
                  amount: 0,
                  avatars: avatars,
                ));
              } catch (_) {}
            }
            notifyListeners();
            return;
          }
        }
      } catch (_) {}
    }

    // If nothing fetched, keep sample data
    addSampleData();
  }
}
