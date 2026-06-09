import 'package:flutter_riverpod/flutter_riverpod.dart';

class MemberTransaction {
  final String title;
  final String amount;
  final String date;
  final String status; // 'Approved', 'Pending Approval'
  final String category; // 'Food', 'Dining', 'Travel', 'Others'
  final bool youPaid; // true if you paid, false if they paid

  MemberTransaction({
    required this.title,
    required this.amount,
    required this.date,
    required this.status,
    required this.category,
    required this.youPaid,
  });
}

class Member {
  final String id;
  final String name;
  final String email;
  final String avatar;
  final String balance; // e.g. "Owes you ₹120.00", "You owe ₹150.00", "Settled Up"
  final String status; // 'owed', 'owe', 'settled'
  final double amount;
  final List<MemberTransaction> history;

  Member({
    required this.id,
    required this.name,
    required this.email,
    required this.avatar,
    required this.balance,
    required this.status,
    required this.amount,
    required this.history,
  });

  Member copyWith({
    String? id,
    String? name,
    String? email,
    String? avatar,
    String? balance,
    String? status,
    double? amount,
    List<MemberTransaction>? history,
  }) {
    return Member(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      balance: balance ?? this.balance,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      history: history ?? this.history,
    );
  }
}

class MembersNotifier extends StateNotifier<List<Member>> {
  MembersNotifier()
      : super([
          Member(
            id: '1',
            name: 'Aman Gupta',
            email: 'aman.gupta@office.com',
            avatar: '🦁',
            balance: 'Owes you ₹120.00',
            status: 'owed',
            amount: 120.00,
            history: [
              MemberTransaction(
                title: 'Office Tea & Samosas',
                amount: '₹120.00',
                date: 'Today, 11:30 AM',
                status: 'Pending Approval',
                category: 'Food',
                youPaid: true,
              ),
              MemberTransaction(
                title: 'Team Coffee Break',
                amount: '₹180.00',
                date: '2 days ago',
                status: 'Approved',
                category: 'Dining',
                youPaid: true,
              ),
            ],
          ),
          Member(
            id: '2',
            name: 'Rohit Sen',
            email: 'rohit.sen@office.com',
            avatar: '🦊',
            balance: 'Owes you ₹330.00',
            status: 'owed',
            amount: 330.00,
            history: [
              MemberTransaction(
                title: 'Lunch Box Order',
                amount: '₹330.00',
                date: 'Yesterday, 1:15 PM',
                status: 'Approved',
                category: 'Dining',
                youPaid: true,
              ),
            ],
          ),
          Member(
            id: '3',
            name: 'Dev Patel',
            email: 'dev.patel@office.com',
            avatar: '🐙',
            balance: 'You owe ₹150.00',
            status: 'owe',
            amount: 150.00,
            history: [
              MemberTransaction(
                title: 'Cab Share to Client',
                amount: '₹150.00',
                date: '3 days ago',
                status: 'Approved',
                category: 'Travel',
                youPaid: false,
              ),
            ],
          ),
          Member(
            id: '4',
            name: 'Neha Sharma',
            email: 'neha.sharma@office.com',
            avatar: '🦄',
            balance: 'Settled Up',
            status: 'settled',
            amount: 0.00,
            history: [
              MemberTransaction(
                title: 'Printouts & Stationery',
                amount: '₹40.00',
                date: 'May 28, 2026',
                status: 'Approved',
                category: 'Others',
                youPaid: false,
              ),
            ],
          ),
          Member(
            id: '5',
            name: 'Ishaan Verma',
            email: 'ishaan.v@office.com',
            avatar: '🐼',
            balance: 'Settled Up',
            status: 'settled',
            amount: 0.00,
            history: [],
          ),
        ]);

  void addMember({
    required String name,
    required String email,
    required String avatar,
  }) {
    final newId = (state.length + 1).toString();
    final newMember = Member(
      id: newId,
      name: name,
      email: email,
      avatar: avatar,
      balance: 'Settled Up',
      status: 'settled',
      amount: 0.00,
      history: [],
    );
    state = [newMember, ...state];
  }

  void settleMember(String id) {
    state = state.map((m) {
      if (m.id == id) {
        return m.copyWith(
          balance: 'Settled Up',
          status: 'settled',
          amount: 0.00,
          history: [
            MemberTransaction(
              title: 'Settle Up Payment',
              amount: '₹${m.amount.toStringAsFixed(2)}',
              date: 'Just now',
              status: 'Approved',
              category: 'Others',
              youPaid: m.status == 'owe',
            ),
            ...m.history,
          ],
        );
      }
      return m;
    }).toList();
  }
}

final membersProvider = StateNotifierProvider<MembersNotifier, List<Member>>((ref) {
  return MembersNotifier();
});
