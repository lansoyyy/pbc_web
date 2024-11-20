import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class UserDetailsPage extends StatelessWidget {
  final String userId;

  const UserDetailsPage({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Details'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection('Users').doc(userId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('User not found.'));
          }

          final user = snapshot.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Name: ${user['name'] ?? 'No Name'}',
                  style: Theme.of(context).textTheme.titleLarge ??
                      const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Email: ${user['email'] ?? 'No Email'}',
                  style: Theme.of(context).textTheme.bodyMedium ??
                      const TextStyle(fontSize: 16),
                ),
                Text(
                  'Address: ${user['address'] ?? 'No Address'}',
                  style: Theme.of(context).textTheme.bodyMedium ??
                      const TextStyle(fontSize: 16),
                ),
                Text(
                  'Points: ${user['pts'] ?? 0}',
                  style: Theme.of(context).textTheme.bodyMedium ??
                      const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Transaction Records:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('Records')
                        .where('uid', isEqualTo: userId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                            child: Text('No transaction records.'));
                      }

                      final records = snapshot.data!.docs;

                      return SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Item Name')),
                              DataColumn(label: Text('Points')),
                              DataColumn(label: Text('Date & Time')),
                            ],
                            rows: records.map((record) {
                              final data =
                                  record.data() as Map<String, dynamic>;
                              return DataRow(cells: [
                                DataCell(Text(data['name'] ?? 'No Item Name')),
                                DataCell(Text('${data['pts'] ?? 0}')),
                                DataCell(Text(DateFormat.yMMMd()
                                    .add_jm()
                                    .format((data['dateTime'] as Timestamp)
                                        .toDate()))),
                              ]);
                            }).toList(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
