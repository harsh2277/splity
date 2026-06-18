import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../core/config/app_env.dart';
import '../auth/auth_service.dart';
import '../auth/auth_provider.dart';

class Group {
  final String id;
  final String name;
  final String companyName;
  final String type; // Office, Home, Travel, Other
  final String inviteCode;
  final bool approvalRequired;
  final int membersCount;
  final String balance; // e.g., "Owe ₹40.00", "Owed ₹450.00", "Settled"
  final String? imageUrl;

  Group({
    required this.id,
    required this.name,
    required this.companyName,
    required this.type,
    required this.inviteCode,
    required this.approvalRequired,
    required this.membersCount,
    required this.balance,
    this.imageUrl,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'] as String,
      name: json['name'] as String,
      companyName: json['companyName'] as String,
      type: json['type'] as String,
      inviteCode: json['inviteCode'] as String,
      approvalRequired: json['approvalRequired'] as bool,
      membersCount: json['membersCount'] as int,
      balance: json['balance'] as String,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Group copyWith({
    String? id,
    String? name,
    String? companyName,
    String? type,
    String? inviteCode,
    bool? approvalRequired,
    int? membersCount,
    String? balance,
    String? imageUrl,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      companyName: companyName ?? this.companyName,
      type: type ?? this.type,
      inviteCode: inviteCode ?? this.inviteCode,
      approvalRequired: approvalRequired ?? this.approvalRequired,
      membersCount: membersCount ?? this.membersCount,
      balance: balance ?? this.balance,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

class GroupsNotifier extends StateNotifier<List<Group>> {
  final AuthService _authService;

  GroupsNotifier(this._authService) : super([]) {
    fetchGroups();
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_authService.jwtToken != null) 'Authorization': 'Bearer ${_authService.jwtToken}',
  };

  Future<void> fetchGroups() async {
    if (_authService.jwtToken == null) return;
    try {
      final url = Uri.parse('${AppEnv.apiBaseUrl}/groups');
      final response = await http.get(url, headers: _headers);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        state = data.map((g) => Group.fromJson(g)).toList();
      }
    } catch (e) {
      print('Error fetching groups: $e');
    }
  }

  Future<Group> createGroup({
    required String name,
    required String companyName,
    required String type,
    required bool approvalRequired,
    String? imageUrl,
  }) async {
    final url = Uri.parse('${AppEnv.apiBaseUrl}/groups');
    final response = await http.post(
      url,
      headers: _headers,
      body: jsonEncode({
        'name': name,
        'companyName': companyName,
        'type': type,
        'approvalRequired': approvalRequired,
        'imageUrl': imageUrl,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create group');
    }

    final newGroup = Group.fromJson(jsonDecode(response.body));
    state = [newGroup, ...state];
    return newGroup;
  }

  Future<bool> joinGroup(String code) async {
    final url = Uri.parse('${AppEnv.apiBaseUrl}/groups/join');
    final response = await http.post(
      url,
      headers: _headers,
      body: jsonEncode({'code': code}),
    );

    if (response.statusCode != 200) {
      return false;
    }

    final joinedGroup = Group.fromJson(jsonDecode(response.body));
    state = [joinedGroup, ...state];
    return true;
  }
}

final groupsProvider = StateNotifierProvider<GroupsNotifier, List<Group>>((ref) {
  final authService = ref.watch(authServiceProvider);
  return GroupsNotifier(authService);
});
