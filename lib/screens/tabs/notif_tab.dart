import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_waste_web/widgets/text_widget.dart';
import 'package:smart_waste_web/widgets/toast_widget.dart';

class NotifTab extends StatelessWidget {
  const NotifTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Records')
            .where('status', isEqualTo: 'Pending')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            print(snapshot.error);
            return const Center(child: Text('Error'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.only(top: 50),
              child: Center(
                  child: CircularProgressIndicator(
                color: Colors.black,
              )),
            );
          }

          final data = snapshot.requireData;
          return SizedBox(
            height: 500,
            child: ListView.builder(
              itemCount: data.docs.length,
              itemBuilder: (context, index) {
                return ListTile(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text(
                          'Redeem Confirmation',
                          style: TextStyle(
                              fontFamily: 'QBold', fontWeight: FontWeight.bold),
                        ),
                        actions: <Widget>[
                          MaterialButton(
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection('Records')
                                  .doc(data.docs[index].id)
                                  .update({'status': 'Rejected'});
                              Navigator.pop(context);
                              showToast('Request rejected!');
                            },
                            child: const Text(
                              'Reject',
                              style: TextStyle(
                                  fontFamily: 'QRegular',
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          MaterialButton(
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection('Records')
                                  .doc(data.docs[index].id)
                                  .update({'status': 'Accepted'});
                              Navigator.pop(context);
                              showToast('Request accepted!');
                            },
                            child: const Text(
                              'Accept',
                              style: TextStyle(
                                  fontFamily: 'QRegular',
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  leading: TextWidget(text: '${index + 1}.', fontSize: 18),
                  title: TextWidget(
                      text: 'Wants to redeem pancit cantoon', fontSize: 18),
                );
              },
            ),
          );
        });
  }
}
