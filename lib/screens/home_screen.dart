import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {

    final CollectionReference events =
        FirebaseFirestore.instance.collection('try');

    final Stream<QuerySnapshot> _usersStream =
        FirebaseFirestore.instance.collection('try').snapshots();

    final FirebaseAuth _auth = FirebaseAuth.instance;

    final TextEditingController dateinput = TextEditingController();
    final TextEditingController eventNameInput = TextEditingController();

    void initState() {
      eventNameInput.text = "";
      dateinput.text = "";
      super.initState();
    }

    return Scaffold(
        backgroundColor: Colors.black38,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //TODO: Update UI
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Events Calendar",
                      style: TextStyle(color: Colors.white, fontSize: 30),
                    ),
                    IconButton(
                        color: Colors.white,
                        onPressed: () {
                          _auth.signOut();
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.power_settings_new))
                  ],
                ),
              ),
              StreamBuilder<QuerySnapshot>(
                builder: (ctx, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(
                      color: Colors.white54,
                    ));
                  }

                  if (snapshot.data!.size == 0) {
                    return const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Center(
                        child: Text(
                          "Add Events",
                          style: TextStyle(color: Colors.white54, fontSize: 20),
                        ),
                      ),
                    );
                  }

                  return ListView(
                    shrinkWrap: true,
                    children:
                        snapshot.data!.docs.map((DocumentSnapshot document) {
                      Map<String, dynamic> data =
                          document.data()! as Map<String, dynamic>;
                      //print(data);

                      int days = DateTime.parse(data["time"])
                          .difference(DateTime.now())
                          .inDays;


                      return Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ListTile(
                          title: Text(
                            data['text'],
                            style: const TextStyle(
                                color: Colors.white, fontSize: 23),
                          ),
                          subtitle: days < 0 ? Text("Event passed "+ days.abs().toString() +" days ago",
                            style :const TextStyle(
                              color: Colors.white, fontSize: 15),) : Text(
                            days.toString() + " day(s)",
                            style: const TextStyle(
                                color: Colors.white, fontSize: 18),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                  color: Colors.white,
                                  onPressed: () async {
                                    showModalBottomSheet<void>(
                                        isScrollControlled: true,
                                        context: context,
                                        builder: (context) {
                                          return Padding(
                                            padding: MediaQuery.of(context)
                                                .viewInsets,
                                            child: SingleChildScrollView(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10.0),
                                                    child: TextField(
                                                      controller: dateinput,
                                                      decoration:
                                                          const InputDecoration(
                                                              icon: Icon(Icons
                                                                  .calendar_today),
                                                              labelText:
                                                                  "Enter Date"),
                                                      readOnly: true,
                                                      onTap: () async {
                                                        DateTime? pickedDate =
                                                            await showDatePicker(
                                                                context:
                                                                    context,
                                                                initialDate:
                                                                    DateTime
                                                                        .now(),
                                                                firstDate:
                                                                    DateTime(
                                                                        2000),
                                                                //DateTime.now() - not to allow to choose before today.
                                                                lastDate:
                                                                    DateTime(
                                                                        2101));

                                                        if (pickedDate !=
                                                            null) {
                                                          print(pickedDate);
                                                          String formattedDate =
                                                              DateFormat(
                                                                      'yyyy-MM-dd')
                                                                  .format(
                                                                      pickedDate);
                                                          print(formattedDate);
                                                          setState(() {
                                                            dateinput.text =
                                                                formattedDate; //set output date to TextField value.
                                                          });
                                                        } else {
                                                          //print("Date is not selected");
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                  ElevatedButton(
                                                      onPressed: () {
                                                        events
                                                            .doc(data['text'])
                                                            .update({
                                                              'time':
                                                                  dateinput.text
                                                            })
                                                            .then((value) =>
                                                                print(
                                                                    "Updated"))
                                                            .catchError(
                                                                (error) => print(
                                                                    "Failed to delete user: $error"));
                                                      },
                                                      child: const Text(
                                                          "Update Event"))
                                                ],
                                              ),
                                            ),
                                          );
                                        });
                                  },
                                  icon: const Icon(Icons.edit)),
                              IconButton(
                                  color: Colors.white,
                                  onPressed: () async {
                                    await events
                                        .doc(data['text'])
                                        .delete()
                                        .then((value) => print("User Deleted"))
                                        .catchError((error) => print(
                                            "Failed to delete user: $error"));
                                  },
                                  icon: const Icon(Icons.delete)),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
                stream: _usersStream,
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.black,
          onPressed: () {
            showModalBottomSheet<void>(
                isScrollControlled: true,
                context: context,
                builder: (context) {
                  return Padding(
                    padding: MediaQuery.of(context).viewInsets,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: TextField(
                              controller: eventNameInput,
                              decoration:
                                  const InputDecoration(hintText: "Event Name"),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: TextField(
                              controller: dateinput,
                              decoration: const InputDecoration(
                                  icon: Icon(Icons.calendar_today),
                                  labelText: "Enter Date"),
                              readOnly: true,
                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2000),
                                    //DateTime.now() - not to allow to choose before today.
                                    lastDate: DateTime(2101));

                                if (pickedDate != null) {
                                  //print(pickedDate);
                                  String formattedDate =
                                      DateFormat('yyyy-MM-dd')
                                          .format(pickedDate);
                                  //print(formattedDate);
                                  setState(() {
                                    dateinput.text =
                                        formattedDate; //set output date to TextField value.
                                  });
                                } else {
                                  //print("Date is not selected");
                                }
                              },
                            ),
                          ),
                          ElevatedButton(
                              onPressed: () {
                                //print(EventNameInput.text.toString());
                                events.doc(eventNameInput.text.toString()).set({
                                  'text': eventNameInput.text.toString(),
                                  'time': dateinput.text.toString()
                                });
                              },
                              child: const Text("Add Event"))
                        ],
                      ),
                    ),
                  );
                });
          },
          child: const Center(
              child: Icon(
            Icons.add,
            size: 45,
          )),
        ));
  }
}
