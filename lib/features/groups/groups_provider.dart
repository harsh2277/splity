import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  GroupsNotifier()
      : super([
          Group(
            id: '1',
            name: 'Office Chai',
            companyName: 'Splity Corp',
            type: 'Office',
            inviteCode: 'CHAI24',
            approvalRequired: false,
            membersCount: 8,
            balance: 'Owe ₹40.00',
          ),
          Group(
            id: '2',
            name: 'Friday Lunch',
            companyName: 'Splity Corp',
            type: 'Office',
            inviteCode: 'LUNCH5',
            approvalRequired: true,
            membersCount: 5,
            balance: 'Owed ₹450.00',
          ),
          Group(
            id: '3',
            name: 'Flatmates',
            companyName: 'Home',
            type: 'Home',
            inviteCode: 'FLAT99',
            approvalRequired: false,
            membersCount: 3,
            balance: 'Settled',
          ),
        ]);

  Group createGroup({
    required String name,
    required String companyName,
    required String type,
    required bool approvalRequired,
    String? imageUrl,
  }) {
    final newId = (state.length + 1).toString();
    // Generate a random 6-character invite code
    final inviteCode = name.replaceAll(' ', '').toUpperCase().padRight(4, 'X').substring(0, 4) +
        newId.padLeft(2, '0');
        
    final newGroup = Group(
      id: newId,
      name: name,
      companyName: companyName,
      type: type,
      inviteCode: inviteCode,
      approvalRequired: approvalRequired,
      membersCount: 1, // Created by current user, starts with 1 member
      balance: 'Settled',
      imageUrl: imageUrl,
    );
    state = [...state, newGroup];
    return newGroup;
  }

  bool joinGroup(String code) {
    final sanitizedCode = code.trim().toUpperCase();
    // Check if group with invite code already exists in active list
    if (state.any((g) => g.inviteCode == sanitizedCode)) {
      return false; // Already joined
    }
    
    // Simulate joining an existing group
    final joinedGroup = Group(
      id: (state.length + 1).toString(),
      name: 'Joined Group',
      companyName: 'External',
      type: 'Other',
      inviteCode: sanitizedCode,
      approvalRequired: false,
      membersCount: 4,
      balance: 'Settled',
    );
    state = [...state, joinedGroup];
    return true;
  }
}

final groupsProvider = StateNotifierProvider<GroupsNotifier, List<Group>>((ref) {
  return GroupsNotifier();
});
