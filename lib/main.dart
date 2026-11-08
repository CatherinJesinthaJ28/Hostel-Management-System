import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const HostelManagementApp());
}

class HostelManagementApp extends StatelessWidget {
  const HostelManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hostel Management',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
        ),
        useMaterial3: true,
      ),
      home: const DashboardPage(),
    );
  }
}

// ============================================================
// DASHBOARD
// ============================================================

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final List<Map<String, String>> students = [];
  final List<Map<String, String>> rooms = [];

  final Map<String, Map<String, String>> feeRecords = {};

  @override
  void initState() {
    super.initState();
    loadAllData();
  }

  Future<void> loadAllData() async {
    await Future.wait([
      loadStudents(),
      loadRooms(),
      loadFees(),
    ]);
  }

  Future<void> loadStudents() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('students').get();

    if (!mounted) return;

    setState(() {
      students
        ..clear()
        ..addAll(
          snapshot.docs.map((doc) {
            final data = doc.data();

            return <String, String>{
              'name': data['name']?.toString() ?? '',
              'register': data['register']?.toString() ?? '',
              'gender': data['gender']?.toString() ?? '',
              'phone': data['phone']?.toString() ?? '',
              'email': data['email']?.toString() ?? '',
              'course': data['course']?.toString() ?? '',
              'year': data['year']?.toString() ?? '',
              'parent': data['parent']?.toString() ?? '',
              'parentPhone': data['parentPhone']?.toString() ?? '',
              'address': data['address']?.toString() ?? '',
            };
          }),
        );
    });
  }

  Future<void> loadRooms() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('rooms').get();

    if (!mounted) return;

    setState(() {
      rooms
        ..clear()
        ..addAll(
          snapshot.docs.map((doc) {
            final data = doc.data();

            return <String, String>{
              'number': data['number']?.toString() ?? '',
              'type': data['type']?.toString() ?? '',
              'capacity': data['capacity']?.toString() ?? '',
              'status': data['status']?.toString() ?? 'Available',
            };
          }),
        );
    });
  }

  Future<void> loadFees() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('fees').get();

    if (!mounted) return;

    setState(() {
      feeRecords.clear();

      for (final doc in snapshot.docs) {
        final data = doc.data();

        final register =
            data['register']?.toString() ?? doc.id;

        feeRecords[register] = {
          'register': register,
          'studentName':
              data['studentName']?.toString() ?? '',
          'totalFee':
              data['totalFee']?.toString() ?? '0',
          'amountPaid':
              data['amountPaid']?.toString() ?? '0',
          'balance':
              data['balance']?.toString() ?? '0',
          'status':
              data['status']?.toString() ?? 'Pending',
        };
      }
    });
  }

  int get availableRooms {
    return rooms
        .where(
          (room) => room['status'] == 'Available',
        )
        .length;
  }

  int get occupiedRooms {
    return rooms
        .where(
          (room) => room['status'] == 'Occupied',
        )
        .length;
  }

  double get pendingFees {
    return feeRecords.values.fold<double>(
      0,
      (sum, fee) =>
          sum +
          (double.tryParse(
                fee['balance'] ?? '0',
              ) ??
              0),
    );
  }

  void openRegistrationPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StudentRegistrationPage(
          onStudentAdded: (student) {
            setState(() {
              students.add(student);
            });
          },
        ),
      ),
    );
  }

  void openStudentList() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StudentListPage(
          students: students,
        ),
      ),
    );
  }

  void openRoomManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RoomManagementPage(
          rooms: rooms,
          onRoomsChanged: () {
            setState(() {});
          },
        ),
      ),
    );
  }

  void openRoomAllocation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RoomAllocationPage(
          students: students,
          rooms: rooms,
          onAllocationChanged: () {
            setState(() {});
          },
        ),
      ),
    );
  }

  void openFeeDetails() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FeeDetailsPage(
          students: students,
          feeRecords: feeRecords,
          onFeesChanged: () {
            loadFees();
          },
        ),
      ),
    );
  }

  void openBookings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingsPage(
          students: students,
          rooms: rooms,
        ),
      ),
    );
  }

  void openSimpleModule(
    String title,
    IconData icon,
    String message,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SimpleModulePage(
          title: title,
          icon: icon,
          message: message,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        title: const Text(
          'Hostel Management',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(
              Icons.person_outline,
            ),
            onPressed: () {},
          ),
        ],
      ),

      // ========================================================
      // DRAWER
      // ========================================================

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.indigo,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.home_work,
                      color: Colors.indigo,
                      size: 32,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Hostel Management',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Admin Dashboard',
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            ListTile(
              leading: const Icon(
                Icons.dashboard,
              ),
              title: const Text(
                'Dashboard',
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(
                Icons.people,
              ),
              title: const Text(
                'Student Registration',
              ),
              onTap: () {
                Navigator.pop(context);
                openRegistrationPage();
              },
            ),

            ListTile(
              leading: const Icon(
                Icons.groups,
              ),
              title: const Text(
                'Registered Students',
              ),
              onTap: () {
                Navigator.pop(context);
                openStudentList();
              },
            ),

            ListTile(
              leading: const Icon(
                Icons.bed,
              ),
              title: const Text(
                'Room Management',
              ),
              onTap: () {
                Navigator.pop(context);
                openRoomManagement();
              },
            ),

            ListTile(
              leading: const Icon(
                Icons.assignment,
              ),
              title: const Text(
                'Room Allocation',
              ),
              onTap: () {
                Navigator.pop(context);
                openRoomAllocation();
              },
            ),

            ListTile(
              leading: const Icon(
                Icons.currency_rupee,
              ),
              title: const Text(
                'Fee Details',
              ),
              onTap: () {
                Navigator.pop(context);
                openFeeDetails();
              },
            ),

            ListTile(
              leading: const Icon(
                Icons.calendar_month,
              ),
              title: const Text(
                'Bookings',
              ),
              onTap: () {
                Navigator.pop(context);
                openBookings();
              },
            ),

            ListTile(
              leading: const Icon(
                Icons.bar_chart,
              ),
              title: const Text(
                'Reports',
              ),
              onTap: () {
  Navigator.pop(context);

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ReportsPage(
        students: students,
        rooms: rooms,
        feeRecords: feeRecords,
      ),
    ),
  );
},
),

            const Divider(),

            ListTile(
              leading: const Icon(
                Icons.settings,
              ),
              title: const Text(
                'Settings',
              ),
              onTap: () {
  Navigator.pop(context);

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const SettingsPage(),
    ),
  );
},
            ),
          ],
        ),
      ),

      // ========================================================
      // DASHBOARD BODY
      // ========================================================

      body: RefreshIndicator(
        onRefresh: loadAllData,
        child: SingleChildScrollView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome to Hostel Management 👋',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Manage students, rooms, bookings and fees easily.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 25),

              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.5,
                children: [
                  DashboardCard(
                    title: 'Students',
                    value:
                        students.length.toString(),
                    icon: Icons.people,
                    color: Colors.blue,
                  ),

                  DashboardCard(
                    title: 'Available Rooms',
                    value:
                        availableRooms.toString(),
                    icon: Icons.bed,
                    color: Colors.green,
                  ),

                  DashboardCard(
                    title: 'Occupied Rooms',
                    value:
                        occupiedRooms.toString(),
                    icon: Icons.meeting_room,
                    color: Colors.orange,
                  ),

                  DashboardCard(
                    title: 'Pending Fees',
                    value:
                        '₹${pendingFees.toStringAsFixed(0)}',
                    icon: Icons.currency_rupee,
                    color: Colors.red,
                  ),
                ],
              ),

              const SizedBox(height: 30),

              const Text(
                'Quick Access',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              QuickAccessTile(
                icon: Icons.person_add,
                title: 'Student Registration',
                subtitle:
                    'Add a new student',
                onTap:
                    openRegistrationPage,
              ),

              QuickAccessTile(
                icon: Icons.groups,
                title: 'Registered Students',
                subtitle:
                    'View registered students',
                onTap:
                    openStudentList,
              ),

              QuickAccessTile(
                icon: Icons.bed,
                title: 'Room Management',
                subtitle:
                    'Add and manage hostel rooms',
                onTap:
                    openRoomManagement,
              ),

              QuickAccessTile(
                icon: Icons.assignment,
                title: 'Room Allocation',
                subtitle:
                    'Allocate rooms to students',
                onTap:
                    openRoomAllocation,
              ),

              QuickAccessTile(
                icon: Icons.currency_rupee,
                title: 'Fee Details',
                subtitle:
                    'Manage hostel fees',
                onTap:
                    openFeeDetails,
              ),

              QuickAccessTile(
                icon: Icons.calendar_month,
                title: 'Bookings',
                subtitle:
                    'Create and manage bookings',
                onTap:
                    openBookings,
              ),

              QuickAccessTile(
                icon: Icons.bar_chart,
                title: 'Reports',
                subtitle:
                    'View hostel reports',
                onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ReportsPage(
        students: students,
        rooms: rooms,
        feeRecords: feeRecords,
      ),
    ),
  );
},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// ROOM MANAGEMENT
// ============================================================

class RoomManagementPage extends StatefulWidget {
  final List<Map<String, String>> rooms;
  final VoidCallback onRoomsChanged;

  const RoomManagementPage({
    super.key,
    required this.rooms,
    required this.onRoomsChanged,
  });

  @override
  State<RoomManagementPage> createState() =>
      _RoomManagementPageState();
}

class _RoomManagementPageState
    extends State<RoomManagementPage> {

  Future<void> showAddRoomDialog() async {
    final controller =
        TextEditingController();

    String roomType = 'Single';
    String status = 'Available';

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            final capacity =
                roomType == 'Single'
                    ? 1
                    : roomType == 'Double'
                        ? 2
                        : 3;

            return AlertDialog(
              title: const Text(
                'Add New Room',
              ),

              content:
                  SingleChildScrollView(
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    TextField(
                      controller: controller,
                      keyboardType:
                          TextInputType.number,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Room Number',
                        prefixIcon:
                            Icon(
                          Icons.meeting_room,
                        ),
                        border:
                            OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    DropdownButtonFormField<
                        String>(
                      value: roomType,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Room Type',
                        prefixIcon:
                            Icon(Icons.bed),
                        border:
                            OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Single',
                          child:
                              Text('Single'),
                        ),
                        DropdownMenuItem(
                          value: 'Double',
                          child:
                              Text('Double'),
                        ),
                        DropdownMenuItem(
                          value: 'Triple',
                          child:
                              Text('Triple'),
                        ),
                      ],
                      onChanged:
                          (value) {
                        if (value != null) {
                          setDialogState(
                            () {
                              roomType =
                                  value;
                            },
                          );
                        }
                      },
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    DropdownButtonFormField<
                        String>(
                      value: status,
                      decoration:
                          const InputDecoration(
                        labelText: 'Status',
                        prefixIcon:
                            Icon(
                          Icons.info_outline,
                        ),
                        border:
                            OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value:
                              'Available',
                          child: Text(
                            'Available',
                          ),
                        ),
                        DropdownMenuItem(
                          value:
                              'Occupied',
                          child: Text(
                            'Occupied',
                          ),
                        ),
                      ],
                      onChanged:
                          (value) {
                        if (value != null) {
                          setDialogState(
                            () {
                              status =
                                  value;
                            },
                          );
                        }
                      },
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    Text(
                      'Capacity: $capacity person(s)',
                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                    );
                  },
                  child:
                      const Text('Cancel'),
                ),

                ElevatedButton(
                  onPressed: () async {
                    final roomNumber =
                        controller.text
                            .trim();

                    if (roomNumber.isEmpty) {
                      ScaffoldMessenger
                              .of(this.context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please enter a room number',
                          ),
                        ),
                      );
                      return;
                    }

                    final exists =
                        widget.rooms.any(
                      (room) =>
                          room['number'] ==
                          roomNumber,
                    );

                    if (exists) {
                      ScaffoldMessenger
                              .of(this.context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Room number already exists',
                          ),
                        ),
                      );
                      return;
                    }

                    await FirebaseFirestore
                        .instance
                        .collection(
                          'rooms',
                        )
                        .add({
                      'number':
                          roomNumber,
                      'type':
                          roomType,
                      'capacity':
                          capacity
                              .toString(),
                      'status':
                          status,
                    });

                    widget.rooms.add({
                      'number':
                          roomNumber,
                      'type':
                          roomType,
                      'capacity':
                          capacity
                              .toString(),
                      'status':
                          status,
                    });

                    widget
                        .onRoomsChanged();

                    if (mounted) {
                      setState(() {});
                    }

                    if (dialogContext
                        .mounted) {
                      Navigator.pop(
                        dialogContext,
                      );
                    }

                    if (mounted) {
                      ScaffoldMessenger
                              .of(this.context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Room added successfully!',
                          ),
                          backgroundColor:
                              Colors.green,
                        ),
                      );
                    }
                  },
                  child:
                      const Text('Add Room'),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();
  }

  Future<void> deleteRoom(
    int index,
  ) async {
    final roomNumber =
        widget.rooms[index]['number'] ??
            '';

    final confirm =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:
              const Text('Delete Room?'),
          content: Text(
            'Are you sure you want to delete Room $roomNumber?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child:
                  const Text('Cancel'),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child:
                  const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return;
    }

    final snapshot =
        await FirebaseFirestore
            .instance
            .collection('rooms')
            .where(
              'number',
              isEqualTo: roomNumber,
            )
            .get();

    for (final doc
        in snapshot.docs) {
      await doc.reference.delete();
    }

    if (!mounted) return;

    setState(() {
      widget.rooms.removeAt(index);
    });

    widget.onRoomsChanged();
  }

  Future<void> changeRoomStatus(
    int index,
  ) async {
    final roomNumber =
        widget.rooms[index]['number'] ??
            '';

    final current =
        widget.rooms[index]['status'] ??
            'Available';

    final newStatus =
        current == 'Available'
            ? 'Occupied'
            : 'Available';

    final snapshot =
        await FirebaseFirestore
            .instance
            .collection('rooms')
            .where(
              'number',
              isEqualTo: roomNumber,
            )
            .get();

    for (final doc
        in snapshot.docs) {
      await doc.reference.update({
        'status': newStatus,
      });
    }

    if (!mounted) return;

    setState(() {
      widget.rooms[index]['status'] =
          newStatus;
    });

    widget.onRoomsChanged();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            Colors.indigo,
        foregroundColor:
            Colors.white,
        title: const Text(
          'Room Management',
        ),
      ),

      floatingActionButton:
          FloatingActionButton.extended(
        onPressed:
            showAddRoomDialog,
        backgroundColor:
            Colors.indigo,
        foregroundColor:
            Colors.white,
        icon: const Icon(
          Icons.add,
        ),
        label:
            const Text('Add Room'),
      ),

      body: widget.rooms.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment
                        .center,
                children: [
                  Icon(
                    Icons.bed_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Text(
                    'No rooms available',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding:
                  const EdgeInsets.all(
                15,
              ),
              itemCount:
                  widget.rooms.length,
              itemBuilder:
                  (context, index) {
                final room =
                    widget.rooms[index];

                final isAvailable =
                    room['status'] ==
                        'Available';

                return Card(
                  margin:
                      const EdgeInsets.only(
                    bottom: 12,
                  ),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.all(
                      12,
                    ),

                    leading:
                        CircleAvatar(
                      radius: 28,
                      backgroundColor:
                          isAvailable
                              ? Colors.green
                                  .shade100
                              : Colors.red
                                  .shade100,
                      child: Icon(
                        Icons.bed,
                        color:
                            isAvailable
                                ? Colors.green
                                : Colors.red,
                      ),
                    ),

                    title: Text(
                      'Room ${room['number']}',
                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),

                    subtitle: Text(
                      '${room['type']} Room • Capacity: ${room['capacity']} • ${room['status']}',
                    ),

                    trailing:
                        PopupMenuButton<
                            String>(
                      onSelected:
                          (value) {
                        if (value ==
                            'status') {
                          changeRoomStatus(
                            index,
                          );
                        }

                        if (value ==
                            'delete') {
                          deleteRoom(
                            index,
                          );
                        }
                      },
                      itemBuilder:
                          (_) => [
                        PopupMenuItem(
                          value:
                              'status',
                          child: Text(
                            isAvailable
                                ? 'Mark Occupied'
                                : 'Mark Available',
                          ),
                        ),
                        const PopupMenuItem(
                          value:
                              'delete',
                          child: Text(
                            'Delete Room',
                          ),
                        ),
                      ],
                    ),

                    isThreeLine: true,
                  ),
                );
              },
            ),
    );
  }
}

// ============================================================
// STUDENT REGISTRATION
// ============================================================

class StudentRegistrationPage
    extends StatefulWidget {
  final Function(
    Map<String, String>,
  ) onStudentAdded;

  const StudentRegistrationPage({
    super.key,
    required this.onStudentAdded,
  });

  @override
  State<StudentRegistrationPage>
      createState() =>
          _StudentRegistrationPageState();
}

class _StudentRegistrationPageState
    extends State<
        StudentRegistrationPage> {
  final formKey =
      GlobalKey<FormState>();

  final nameController =
      TextEditingController();

  final registerController =
      TextEditingController();

  final phoneController =
      TextEditingController();

  final emailController =
      TextEditingController();

  final courseController =
      TextEditingController();

  final parentController =
      TextEditingController();

  final parentPhoneController =
      TextEditingController();

  final addressController =
      TextEditingController();

  String gender = 'Male';
  String year = '1st Year';

  @override
  void dispose() {
    nameController.dispose();
    registerController.dispose();
    phoneController.dispose();
    emailController.dispose();
    courseController.dispose();
    parentController.dispose();
    parentPhoneController.dispose();
    addressController.dispose();

    super.dispose();
  }

  InputDecoration decoration(
    String label,
    IconData icon,
  ) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(
          12,
        ),
      ),
    );
  }

  String? requiredField(
    String? value,
    String label,
  ) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'Please enter $label';
    }

    return null;
  }

  Future<void> registerStudent()
      async {
    if (!formKey.currentState!
        .validate()) {
      return;
    }

    final register =
        registerController
            .text
            .trim();

    final existing =
        await FirebaseFirestore
            .instance
            .collection(
              'students',
            )
            .where(
              'register',
              isEqualTo:
                  register,
            )
            .get();

    if (existing.docs.isNotEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Register number already exists',
          ),
        ),
      );

      return;
    }

    final student =
        <String, String>{
      'name':
          nameController.text
              .trim(),
      'register':
          register,
      'gender':
          gender,
      'phone':
          phoneController.text
              .trim(),
      'email':
          emailController.text
              .trim(),
      'course':
          courseController.text
              .trim(),
      'year':
          year,
      'parent':
          parentController.text
              .trim(),
      'parentPhone':
          parentPhoneController
              .text
              .trim(),
      'address':
          addressController.text
              .trim(),
    };

    await FirebaseFirestore
        .instance
        .collection(
          'students',
        )
        .add(student);

    widget.onStudentAdded(
      student,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      const SnackBar(
        content: Text(
          'Student registered successfully!',
        ),
        backgroundColor:
            Colors.green,
      ),
    );

    await Future.delayed(
      const Duration(
        milliseconds: 500,
      ),
    );

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            Colors.indigo,
        foregroundColor:
            Colors.white,
        title: const Text(
          'Student Registration',
        ),
      ),

      body:
          SingleChildScrollView(
        padding:
            const EdgeInsets.all(
          20,
        ),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              const Icon(
                Icons.person_add,
                size: 70,
                color: Colors.indigo,
              ),

              const SizedBox(
                height: 10,
              ),

              const Text(
                'Register New Student',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight:
                      FontWeight.bold,
                  color:
                      Colors.indigo,
                ),
              ),

              const SizedBox(
                height: 25,
              ),

              TextFormField(
                controller:
                    nameController,
                decoration:
                    decoration(
                  'Student Name',
                  Icons.person,
                ),
                validator:
                    (value) =>
                        requiredField(
                  value,
                  'student name',
                ),
              ),

              const SizedBox(
                height: 15,
              ),

              TextFormField(
                controller:
                    registerController,
                decoration:
                    decoration(
                  'Register Number',
                  Icons.badge,
                ),
                validator:
                    (value) =>
                        requiredField(
                  value,
                  'register number',
                ),
              ),

              const SizedBox(
                height: 15,
              ),

              DropdownButtonFormField<
                  String>(
                value: gender,
                decoration:
                    decoration(
                  'Gender',
                  Icons.people,
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Male',
                    child:
                        Text('Male'),
                  ),
                  DropdownMenuItem(
                    value: 'Female',
                    child:
                        Text('Female'),
                  ),
                  DropdownMenuItem(
                    value: 'Other',
                    child:
                        Text('Other'),
                  ),
                ],
                onChanged:
                    (value) {
                  setState(() {
                    gender =
                        value ??
                            'Male';
                  });
                },
              ),

              const SizedBox(
                height: 15,
              ),

              TextFormField(
                controller:
                    phoneController,
                keyboardType:
                    TextInputType.phone,
                decoration:
                    decoration(
                  'Phone Number',
                  Icons.phone,
                ),
                validator:
                    (value) =>
                        requiredField(
                  value,
                  'phone number',
                ),
              ),

              const SizedBox(
                height: 15,
              ),

              TextFormField(
                controller:
                    emailController,
                keyboardType:
                    TextInputType
                        .emailAddress,
                decoration:
                    decoration(
                  'Email Address',
                  Icons.email,
                ),
              ),

              const SizedBox(
                height: 15,
              ),

              TextFormField(
                controller:
                    courseController,
                decoration:
                    decoration(
                  'Course',
                  Icons.school,
                ),
                validator:
                    (value) =>
                        requiredField(
                  value,
                  'course',
                ),
              ),

              const SizedBox(
                height: 15,
              ),

              DropdownButtonFormField<
                  String>(
                value: year,
                decoration:
                    decoration(
                  'Year',
                  Icons.calendar_today,
                ),
                items: const [
                  DropdownMenuItem(
                    value: '1st Year',
                    child: Text(
                      '1st Year',
                    ),
                  ),
                  DropdownMenuItem(
                    value: '2nd Year',
                    child: Text(
                      '2nd Year',
                    ),
                  ),
                  DropdownMenuItem(
                    value: '3rd Year',
                    child: Text(
                      '3rd Year',
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'Final Year',
                    child: Text(
                      'Final Year',
                    ),
                  ),
                ],
                onChanged:
                    (value) {
                  setState(() {
                    year =
                        value ??
                            '1st Year';
                  });
                },
              ),

              const SizedBox(
                height: 15,
              ),

              TextFormField(
                controller:
                    parentController,
                decoration:
                    decoration(
                  'Parent / Guardian Name',
                  Icons.family_restroom,
                ),
                validator:
                    (value) =>
                        requiredField(
                  value,
                  'parent/guardian name',
                ),
              ),

              const SizedBox(
                height: 15,
              ),

              TextFormField(
                controller:
                    parentPhoneController,
                keyboardType:
                    TextInputType.phone,
                decoration:
                    decoration(
                  'Parent / Guardian Phone',
                  Icons.phone_android,
                ),
                validator:
                    (value) =>
                        requiredField(
                  value,
                  'parent/guardian phone',
                ),
              ),

              const SizedBox(
                height: 15,
              ),

              TextFormField(
                controller:
                    addressController,
                maxLines: 3,
                decoration:
                    decoration(
                  'Address',
                  Icons.location_on,
                ),
                validator:
                    (value) =>
                        requiredField(
                  value,
                  'address',
                ),
              ),

              const SizedBox(
                height: 25,
              ),

              SizedBox(
                width:
                    double.infinity,
                height: 52,
                child:
                    ElevatedButton
                        .icon(
                  onPressed:
                      registerStudent,
                  icon:
                      const Icon(
                    Icons.check,
                  ),
                  label:
                      const Text(
                    'REGISTER STUDENT',
                    style:
                        TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  style:
                      ElevatedButton
                          .styleFrom(
                    backgroundColor:
                        Colors.indigo,
                    foregroundColor:
                        Colors.white,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                        12,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// REGISTERED STUDENTS
// ============================================================

class StudentListPage extends StatelessWidget {
  final List<Map<String, String>> students;

  const StudentListPage({
    super.key,
    required this.students,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        title: const Text(
          'Registered Students',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: students.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 15),
                  Text(
                    'No students registered yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),

                    leading: CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.indigo.shade100,
                      child: const Icon(
                        Icons.person,
                        color: Colors.indigo,
                        size: 30,
                      ),
                    ),

                    title: Text(
                      student['name'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),

                    subtitle: Text(
                      '${student['register'] ?? ''} • '
                      '${student['course'] ?? ''}',
                    ),

                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                    ),

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              StudentDetailsPage(
                            student: student,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

// ============================================================
// STUDENT DETAILS
// ============================================================

class StudentDetailsPage extends StatelessWidget {
  final Map<String, String> student;

  const StudentDetailsPage({
    super.key,
    required this.student,
  });

  Widget detailCard(
    String title,
    String value,
    IconData icon,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.indigo.shade100,
          child: Icon(
            icon,
            color: Colors.indigo,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 13,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            value.isEmpty ? 'Not provided' : value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        title: const Text(
          'Student Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            // Student profile header
            CircleAvatar(
              radius: 45,
              backgroundColor: Colors.indigo.shade100,
              child: const Icon(
                Icons.person,
                color: Colors.indigo,
                size: 50,
              ),
            ),

            const SizedBox(height: 15),

            Text(
              student['name'] ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              student['register'] ?? '',
              style: const TextStyle(
                fontSize: 15,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 25),

            // Personal information
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 12),

            detailCard(
              'Register Number',
              student['register'] ?? '',
              Icons.badge,
            ),

            detailCard(
              'Gender',
              student['gender'] ?? '',
              Icons.people,
            ),

            detailCard(
              'Phone Number',
              student['phone'] ?? '',
              Icons.phone,
            ),

            detailCard(
              'Email Address',
              student['email'] ?? '',
              Icons.email,
            ),

            const SizedBox(height: 10),

            // Academic information
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Academic Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 12),

            detailCard(
              'Course',
              student['course'] ?? '',
              Icons.school,
            ),

            detailCard(
              'Year',
              student['year'] ?? '',
              Icons.calendar_today,
            ),

            const SizedBox(height: 10),

            // Parent information
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Parent / Guardian Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 12),

            detailCard(
              'Parent / Guardian Name',
              student['parent'] ?? '',
              Icons.family_restroom,
            ),

            detailCard(
              'Parent / Guardian Phone',
              student['parentPhone'] ?? '',
              Icons.phone_android,
            ),

            const SizedBox(height: 10),

            // Address
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Address',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 12),

            detailCard(
              'Residential Address',
              student['address'] ?? '',
              Icons.location_on,
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// ROOM ALLOCATION
// ============================================================

class RoomAllocationPage
    extends StatefulWidget {
  final List<Map<String, String>>
      students;

  final List<Map<String, String>>
      rooms;

  final VoidCallback
      onAllocationChanged;

  const RoomAllocationPage({
    super.key,
    required this.students,
    required this.rooms,
    required this.onAllocationChanged,
  });

  @override
  State<RoomAllocationPage>
      createState() =>
          _RoomAllocationPageState();
}

class _RoomAllocationPageState
    extends State<
        RoomAllocationPage> {
  String? selectedStudent;
  String? selectedRoom;

  final Map<String, String>
      allocations = {};

  @override
  void initState() {
    super.initState();
    loadAllocations();
  }

  Future<void>
      loadAllocations() async {
    final snapshot =
        await FirebaseFirestore
            .instance
            .collection(
              'allocations',
            )
            .get();

    if (!mounted) return;

    setState(() {
      allocations.clear();

      for (final doc
          in snapshot.docs) {
        final data =
            doc.data();

        final register =
            data['register']
                    ?.toString() ??
                '';

        final roomNumber =
            data['roomNumber']
                    ?.toString() ??
                '';

        if (register
                .isNotEmpty &&
            roomNumber
                .isNotEmpty) {
          allocations[
                  register] =
              roomNumber;
        }
      }
    });
  }

  Future<void> allocateRoom()
      async {
    if (selectedStudent ==
        null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select a student',
          ),
        ),
      );

      return;
    }

    if (selectedRoom == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select an available room',
          ),
        ),
      );

      return;
    }

    final student =
        widget.students.firstWhere(
      (student) =>
          student['register'] ==
          selectedStudent,
      orElse: () =>
          <String, String>{},
    );

    if (student.isEmpty) {
      return;
    }

    final room =
        widget.rooms.firstWhere(
      (room) =>
          room['number'] ==
          selectedRoom,
      orElse: () =>
          <String, String>{},
    );

    if (room.isEmpty ||
        room['status'] !=
            'Available') {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Selected room is no longer available',
          ),
        ),
      );

      await loadAllocations();
      return;
    }

    await FirebaseFirestore
        .instance
        .collection(
          'allocations',
        )
        .doc(selectedStudent)
        .set({
      'register':
          selectedStudent,
      'studentName':
          student['name'] ??
              '',
      'roomNumber':
          selectedRoom,
      'allocatedAt':
          FieldValue
              .serverTimestamp(),
    });

    final roomSnapshot =
        await FirebaseFirestore
            .instance
            .collection(
              'rooms',
            )
            .where(
              'number',
              isEqualTo:
                  selectedRoom,
            )
            .get();

    for (final doc
        in roomSnapshot.docs) {
      await doc.reference
          .update({
        'status':
            'Occupied',
      });
    }

    final roomIndex =
        widget.rooms.indexWhere(
      (room) =>
          room['number'] ==
          selectedRoom,
    );

    if (roomIndex != -1) {
      widget.rooms[roomIndex]
              ['status'] =
          'Occupied';
    }

    if (!mounted) return;

    setState(() {
      allocations[
              selectedStudent!] =
          selectedRoom!;

      selectedStudent = null;
      selectedRoom = null;
    });

    widget
        .onAllocationChanged();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      const SnackBar(
        content: Text(
          'Room allocated successfully!',
        ),
        backgroundColor:
            Colors.green,
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final waitingStudents =
        widget.students.where(
      (student) {
        final register =
            student['register'] ??
                '';

        return register
                .isNotEmpty &&
            !allocations
                .containsKey(
              register,
            );
      },
    ).toList();

    final availableRooms =
        widget.rooms
            .where(
              (room) =>
                  room['status'] ==
                  'Available',
            )
            .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            Colors.indigo,
        foregroundColor:
            Colors.white,
        title: const Text(
          'Room Allocation',
        ),
      ),

      body:
          SingleChildScrollView(
        padding:
            const EdgeInsets.all(
          20,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment
                  .start,
          children: [
            const Text(
              'Allocate Room to Student',
              style: TextStyle(
                fontSize: 24,
                fontWeight:
                    FontWeight.bold,
                color:
                    Colors.indigo,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            const Text(
              'Select a student and an available room.',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 15,
              ),
            ),

            const SizedBox(
              height: 25,
            ),

            DropdownButtonFormField<
                String>(
              value:
                  selectedStudent,
              decoration:
                  const InputDecoration(
                labelText:
                    'Select Student',
                prefixIcon:
                    Icon(
                  Icons.person,
                ),
                border:
                    OutlineInputBorder(),
              ),
              items:
                  waitingStudents
                      .map(
                (student) {
                  return DropdownMenuItem<
                      String>(
                    value: student[
                        'register'],
                    child: Text(
                      '${student['name']} (${student['register']})',
                    ),
                  );
                },
              ).toList(),
              onChanged:
                  (value) {
                setState(() {
                  selectedStudent =
                      value;
                });
              },
            ),

            const SizedBox(
              height: 20,
            ),

            DropdownButtonFormField<
                String>(
              value:
                  selectedRoom,
              decoration:
                  const InputDecoration(
                labelText:
                    'Select Available Room',
                prefixIcon:
                    Icon(
                  Icons.bed,
                ),
                border:
                    OutlineInputBorder(),
              ),
              items:
                  availableRooms
                      .map(
                (room) {
                  return DropdownMenuItem<
                      String>(
                    value:
                        room['number'],
                    child: Text(
                      'Room ${room['number']} - ${room['type']}',
                    ),
                  );
                },
              ).toList(),
              onChanged:
                  (value) {
                setState(() {
                  selectedRoom =
                      value;
                });
              },
            ),

            const SizedBox(
              height: 30,
            ),

            SizedBox(
              width:
                  double.infinity,
              height: 52,
              child:
                  ElevatedButton
                      .icon(
                onPressed:
                    allocateRoom,
                icon:
                    const Icon(
                  Icons
                      .assignment_turned_in,
                ),
                label:
                    const Text(
                  'ALLOCATE ROOM',
                  style:
                      TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                style:
                    ElevatedButton
                        .styleFrom(
                  backgroundColor:
                      Colors.indigo,
                  foregroundColor:
                      Colors.white,
                ),
              ),
            ),

            const SizedBox(
              height: 35,
            ),

            Card(
              child:
                  Padding(
                padding:
                    const EdgeInsets.all(
                  16,
                ),
                child:
                    Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    const Text(
                      'Allocation Information',
                      style:
                          TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    Text(
                      'Students waiting for allocation: ${waitingStudents.length}',
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    Text(
                      'Available rooms: ${availableRooms.length}',
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    Text(
                      'Allocated students: ${allocations.length}',
                    ),
                  ],
                ),
              ),
            ),

            if (allocations
                .isNotEmpty) ...[
              const SizedBox(
                height: 25,
              ),

              const Text(
                'Current Allocations',
                style:
                    TextStyle(
                  fontSize: 20,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              ...allocations
                  .entries
                  .map(
                (entry) {
                  final matchingStudent =
                      widget.students
                          .where(
                    (student) =>
                        student[
                            'register'] ==
                        entry.key,
                  );

                  final name =
                      matchingStudent
                              .isNotEmpty
                          ? matchingStudent
                                  .first[
                              'name'] ??
                              entry.key
                          : entry.key;

                  return Card(
                    child:
                        ListTile(
                      leading:
                          const CircleAvatar(
                        backgroundColor:
                            Color(
                          0xFFE8EAF6,
                        ),
                        child:
                            Icon(
                          Icons.person,
                          color:
                              Colors.indigo,
                        ),
                      ),

                      title:
                          Text(
                        name,
                      ),

                      subtitle:
                          Text(
                        'Room ${entry.value}',
                      ),

                      trailing:
                          const Icon(
                        Icons
                            .check_circle,
                        color:
                            Colors.green,
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ============================================================
// FEE DETAILS
// ============================================================

class FeeDetailsPage
    extends StatefulWidget {
  final List<Map<String, String>>
      students;

  final Map<String,
          Map<String, String>>
      feeRecords;

  final VoidCallback
      onFeesChanged;

  const FeeDetailsPage({
    super.key,
    required this.students,
    required this.feeRecords,
    required this.onFeesChanged,
  });

  @override
  State<FeeDetailsPage>
      createState() =>
          _FeeDetailsPageState();
}

class _FeeDetailsPageState
    extends State<
        FeeDetailsPage> {
  String? selectedStudent;

  final totalFeeController =
      TextEditingController();

  final amountPaidController =
      TextEditingController();

  double get pendingFee {
    final total =
        double.tryParse(
              totalFeeController
                  .text,
            ) ??
            0;

    final paid =
        double.tryParse(
              amountPaidController
                  .text,
            ) ??
            0;

    final pending =
        total - paid;

    return pending < 0
        ? 0
        : pending;
  }

  @override
  void dispose() {
    totalFeeController
        .dispose();

    amountPaidController
        .dispose();

    super.dispose();
  }

  void selectStudent(
    String? register,
  ) {
    setState(() {
      selectedStudent =
          register;
    });

    if (register ==
        null) {
      totalFeeController
          .clear();

      amountPaidController
          .clear();

      return;
    }

    final existing =
        widget.feeRecords[
            register];

    totalFeeController
            .text =
        existing?[
                'totalFee'] ??
            '';

    amountPaidController
            .text =
        existing?[
                'amountPaid'] ??
            '';
  }

  Future<void> saveFee()
      async {
    if (selectedStudent ==
        null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select a student',
          ),
        ),
      );

      return;
    }

    final total =
        double.tryParse(
      totalFeeController
          .text
          .trim(),
    );

    final paid =
        double.tryParse(
      amountPaidController
          .text
          .trim(),
    );

    if (total == null ||
        total <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter a valid total fee',
          ),
        ),
      );

      return;
    }

    if (paid == null ||
        paid < 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter a valid paid amount',
          ),
        ),
      );

      return;
    }

    if (paid > total) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Amount paid cannot be greater than total fee',
          ),
        ),
      );

      return;
    }

    final student =
        widget.students.firstWhere(
      (student) =>
          student['register'] ==
          selectedStudent,
      orElse: () =>
          <String, String>{},
    );

    if (student.isEmpty) {
      return;
    }

    final balance =
        total - paid;

    final status =
        balance == 0
            ? 'Paid'
            : 'Pending';

    await FirebaseFirestore
        .instance
        .collection('fees')
        .doc(selectedStudent)
        .set({
      'register':
          selectedStudent,
      'studentName':
          student['name'] ??
              '',
      'totalFee':
          total,
      'amountPaid':
          paid,
      'balance':
          balance,
      'status':
          status,
      'updatedAt':
          FieldValue
              .serverTimestamp(),
    });

    if (!mounted) return;

    setState(() {
      widget.feeRecords[
              selectedStudent!] =
          {
        'register':
            selectedStudent!,
        'studentName':
            student['name'] ??
                '',
        'totalFee':
            total.toString(),
        'amountPaid':
            paid.toString(),
        'balance':
            balance.toString(),
        'status':
            status,
      };

      selectedStudent =
          null;

      totalFeeController
          .clear();

      amountPaidController
          .clear();
    });

    widget.onFeesChanged();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content: Text(
          status == 'Paid'
              ? 'Fee paid successfully!'
              : 'Fee details saved successfully!',
        ),
        backgroundColor:
            Colors.green,
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            Colors.indigo,
        foregroundColor:
            Colors.white,
        title: const Text(
          'Fee Details',
        ),
      ),

      body:
          SingleChildScrollView(
        padding:
            const EdgeInsets.all(
          20,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment
                  .start,
          children: [
            const Text(
              'Manage Hostel Fees',
              style: TextStyle(
                fontSize: 24,
                fontWeight:
                    FontWeight.bold,
                color:
                    Colors.indigo,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            const Text(
              'Add or update fee details for registered students.',
              style:
                  TextStyle(
                color:
                    Colors.grey,
              ),
            ),

            const SizedBox(
              height: 25,
            ),

            DropdownButtonFormField<
                String>(
              value:
                  selectedStudent,
              decoration:
                  const InputDecoration(
                labelText:
                    'Select Student',
                prefixIcon:
                    Icon(
                  Icons.person,
                ),
                border:
                    OutlineInputBorder(),
              ),
              items:
                  widget.students
                      .map(
                (student) {
                  return DropdownMenuItem<
                      String>(
                    value: student[
                        'register'],
                    child: Text(
                      '${student['name']} (${student['register']})',
                    ),
                  );
                },
              ).toList(),
              onChanged:
                  selectStudent,
            ),

            const SizedBox(
              height: 20,
            ),

            TextField(
              controller:
                  totalFeeController,
              keyboardType:
                  const TextInputType
                      .numberWithOptions(
                decimal: true,
              ),
              decoration:
                  const InputDecoration(
                labelText:
                    'Total Hostel Fee',
                prefixIcon:
                    Icon(
                  Icons.currency_rupee,
                ),
                border:
                    OutlineInputBorder(),
              ),
              onChanged: (_) {
                setState(() {});
              },
            ),

            const SizedBox(
              height: 20,
            ),

            TextField(
              controller:
                  amountPaidController,
              keyboardType:
                  const TextInputType
                      .numberWithOptions(
                decimal: true,
              ),
              decoration:
                  const InputDecoration(
                labelText:
                    'Amount Paid',
                prefixIcon:
                    Icon(
                  Icons.payments,
                ),
                border:
                    OutlineInputBorder(),
              ),
              onChanged: (_) {
                setState(() {});
              },
            ),

            const SizedBox(
              height: 20,
            ),

            Card(
              child:
                  Padding(
                padding:
                    const EdgeInsets.all(
                  18,
                ),
                child:
                    Row(
                  children: [
                    const Icon(
                      Icons
                          .account_balance_wallet,
                      color:
                          Colors.indigo,
                      size: 30,
                    ),

                    const SizedBox(
                      width: 15,
                    ),

                    Expanded(
                      child:
                          Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          const Text(
                            'Pending Fee',
                            style:
                                TextStyle(
                              color:
                                  Colors.grey,
                            ),
                          ),

                          const SizedBox(
                            height: 5,
                          ),

                          Text(
                            '₹${pendingFee.toStringAsFixed(2)}',
                            style:
                                const TextStyle(
                              fontSize:
                                  22,
                              fontWeight:
                                  FontWeight.bold,
                              color:
                                  Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(
              height: 25,
            ),

            SizedBox(
              width:
                  double.infinity,
              height: 52,
              child:
                  ElevatedButton
                      .icon(
                onPressed:
                    saveFee,
                icon:
                    const Icon(
                  Icons.save,
                ),
                label:
                    const Text(
                  'SAVE FEE DETAILS',
                  style:
                      TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                style:
                    ElevatedButton
                        .styleFrom(
                  backgroundColor:
                      Colors.indigo,
                  foregroundColor:
                      Colors.white,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius
                            .circular(
                      12,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 35,
            ),

            const Text(
              'Fee Records',
              style:
                  TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            if (widget
                .feeRecords
                .isEmpty)
              const Card(
                child:
                    Padding(
                  padding:
                      EdgeInsets.all(
                    20,
                  ),
                  child:
                      Center(
                    child:
                        Text(
                      'No fee records available',
                      style:
                          TextStyle(
                        color:
                            Colors.grey,
                      ),
                    ),
                  ),
                ),
              )
            else
              ...widget
                  .feeRecords
                  .values
                  .map(
                (fee) {
                  final status =
                      fee['status'] ??
                          'Pending';

                  final isPaid =
                      status ==
                          'Paid';

                  return Card(
                    margin:
                        const EdgeInsets
                            .only(
                      bottom: 12,
                    ),
                    child:
                        ListTile(
                      leading:
                          CircleAvatar(
                        backgroundColor:
                            isPaid
                                ? Colors
                                    .green
                                    .shade100
                                : Colors
                                    .orange
                                    .shade100,
                        child:
                            Icon(
                          isPaid
                              ? Icons
                                  .check
                              : Icons
                                  .pending,
                          color:
                              isPaid
                                  ? Colors
                                      .green
                                  : Colors
                                      .orange,
                        ),
                      ),

                      title:
                          Text(
                        fee['studentName'] ??
                            '',
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),

                      subtitle:
                          Text(
                        'Total: ₹${fee['totalFee']}\n'
                        'Paid: ₹${fee['amountPaid']}\n'
                        'Balance: ₹${fee['balance']}',
                      ),

                      trailing:
                          Text(
                        status,
                        style:
                            TextStyle(
                          fontWeight:
                              FontWeight
                                  .bold,
                          color: isPaid
                              ? Colors
                                  .green
                              : Colors
                                  .orange,
                        ),
                      ),

                      isThreeLine:
                          true,
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// DASHBOARD CARD
// ============================================================

class DashboardCard
    extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const DashboardCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Card(
      elevation: 3,
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          16,
        ),
      ),
      child:
          Padding(
        padding:
            const EdgeInsets.all(
          15,
        ),
        child:
            Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor:
                  color.withOpacity(
                0.15,
              ),
              child:
                  Icon(
                icon,
                color: color,
                size: 27,
              ),
            ),

            const SizedBox(
              width: 12,
            ),

            Expanded(
              child:
                  Column(
                mainAxisAlignment:
                    MainAxisAlignment
                        .center,
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    title,
                    style:
                        const TextStyle(
                      color:
                          Colors.grey,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  Text(
                    value,
                    style:
                        const TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// QUICK ACCESS TILE
// ============================================================

class QuickAccessTile
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const QuickAccessTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),
      elevation: 2,
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          14,
        ),
      ),
      child:
          ListTile(
        contentPadding:
            const EdgeInsets
                .symmetric(
          horizontal: 18,
          vertical: 8,
        ),

        leading:
            CircleAvatar(
          backgroundColor:
              Colors.indigo
                  .withOpacity(
            0.1,
          ),
          child:
              Icon(
            icon,
            color:
                Colors.indigo,
          ),
        ),

        title:
            Text(
          title,
          style:
              const TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),

        subtitle:
            Text(subtitle),

        trailing:
            const Icon(
          Icons
              .arrow_forward_ios,
          size: 16,
        ),

        onTap: onTap,
      ),
    );
  }
}

// ============================================================
// BOOKINGS
// ============================================================

class BookingsPage extends StatefulWidget {
  final List<Map<String, String>> students;
  final List<Map<String, String>> rooms;

  const BookingsPage({
    super.key,
    required this.students,
    required this.rooms,
  });

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  String? selectedStudent;
  String? selectedRoom;
  DateTime? bookingDate;

  final durationController = TextEditingController();
  List<Map<String, dynamic>> bookings = [];
  bool loading = true;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    loadBookings();
  }

  @override
  void dispose() {
    durationController.dispose();
    super.dispose();
  }

  Future<void> loadBookings() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .orderBy('createdAt', descending: true)
          .get();

      if (!mounted) return;
      setState(() {
        bookings = snapshot.docs.map((doc) => {
          'id': doc.id,
          ...doc.data(),
        }).toList();
        loading = false;
      });
    } catch (_) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('bookings')
            .get();

        if (!mounted) return;
        setState(() {
          bookings = snapshot.docs.map((doc) => {
            'id': doc.id,
            ...doc.data(),
          }).toList();
          loading = false;
        });
      } catch (e) {
        if (!mounted) return;
        setState(() => loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not load bookings: $e')),
        );
      }
    }
  }

  Future<void> pickBookingDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: bookingDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );

    if (picked != null && mounted) {
      setState(() => bookingDate = picked);
    }
  }

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String formatStoredDate(dynamic value) {
    if (value is Timestamp) return formatDate(value.toDate());
    if (value is DateTime) return formatDate(value);
    return value?.toString() ?? '';
  }

  Future<void> saveBooking() async {
    if (selectedStudent == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a student')),
      );
      return;
    }

    if (selectedRoom == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an available room')),
      );
      return;
    }

    if (bookingDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a booking date')),
      );
      return;
    }

    final duration = int.tryParse(durationController.text.trim());
    if (duration == null || duration <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid duration')),
      );
      return;
    }

    final student = widget.students.firstWhere(
      (item) => item['register'] == selectedStudent,
      orElse: () => <String, String>{},
    );

    final room = widget.rooms.firstWhere(
      (item) => item['number'] == selectedRoom,
      orElse: () => <String, String>{},
    );

    if (student.isEmpty || room.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student or room details not found')),
      );
      return;
    }

    if (room['status'] != 'Available') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selected room is no longer available')),
      );
      return;
    }

    setState(() => saving = true);

    try {
      final bookingRef = await FirebaseFirestore.instance
          .collection('bookings')
          .add({
        'register': selectedStudent,
        'studentName': student['name'] ?? '',
        'roomNumber': selectedRoom,
        'roomType': room['type'] ?? '',
        'bookingDate': Timestamp.fromDate(bookingDate!),
        'duration': duration,
        'status': 'Confirmed',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      setState(() {
        bookings.insert(0, {
          'id': bookingRef.id,
          'register': selectedStudent,
          'studentName': student['name'] ?? '',
          'roomNumber': selectedRoom,
          'roomType': room['type'] ?? '',
          'bookingDate': bookingDate,
          'duration': duration,
          'status': 'Confirmed',
        });
        selectedStudent = null;
        selectedRoom = null;
        bookingDate = null;
        durationController.clear();
        saving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save booking: $e')),
      );
    }
  }

  Future<void> deleteBooking(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Booking'),
        content: const Text('Are you sure you want to delete this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(id)
          .delete();

      if (!mounted) return;
      setState(() {
        bookings.removeWhere((booking) => booking['id'] == id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking deleted successfully!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete booking: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final availableRooms = widget.rooms
        .where((room) => room['status'] == 'Available')
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        title: const Text(
          'Bookings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create Hostel Booking',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Select a student, an available room and booking details.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 25),

            DropdownButtonFormField<String>(
              value: selectedStudent,
              decoration: const InputDecoration(
                labelText: 'Select Student',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              items: widget.students.map((student) {
                final register = student['register'] ?? '';
                return DropdownMenuItem<String>(
                  value: register,
                  child: Text('${student['name']} ($register)'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => selectedStudent = value);
              },
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              value: selectedRoom,
              decoration: const InputDecoration(
                labelText: 'Select Available Room',
                prefixIcon: Icon(Icons.bed),
                border: OutlineInputBorder(),
              ),
              items: availableRooms.map((room) {
                final number = room['number'] ?? '';
                final type = room['type'] ?? '';
                final capacity = room['capacity'] ?? '';
                return DropdownMenuItem<String>(
                  value: number,
                  child: Text(
                    'Room $number • $type • Capacity $capacity',
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => selectedRoom = value);
              },
            ),

            if (availableRooms.isEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                'No available rooms. Add or make a room available in Room Management.',
                style: TextStyle(color: Colors.orange, fontSize: 13),
              ),
            ],

            const SizedBox(height: 20),

            InkWell(
              onTap: pickBookingDate,
              borderRadius: BorderRadius.circular(4),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Booking Date',
                  prefixIcon: Icon(Icons.calendar_month),
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  bookingDate == null
                      ? 'Select Date'
                      : formatDate(bookingDate!),
                  style: TextStyle(
                    fontSize: 16,
                    color: bookingDate == null
                        ? Colors.grey.shade600
                        : Colors.black87,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: durationController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Duration (Days)',
                prefixIcon: Icon(Icons.schedule),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 25),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    const Icon(
                      Icons.verified,
                      color: Colors.indigo,
                      size: 30,
                    ),
                    const SizedBox(width: 15),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Booking Status',
                            style: TextStyle(color: Colors.grey),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Confirmed',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: saving ? null : saveBooking,
                icon: saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  saving ? 'SAVING...' : 'SAVE BOOKING',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 35),

            const Text(
              'Booking Records',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            if (loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(25),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (bookings.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      'No booking records available',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              )
            else
              ...bookings.map((booking) {
                final status =
                    booking['status']?.toString() ?? 'Confirmed';
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: CircleAvatar(
                      backgroundColor: Colors.indigo.shade100,
                      child: const Icon(
                        Icons.calendar_month,
                        color: Colors.indigo,
                      ),
                    ),
                    title: Text(
                      booking['studentName']?.toString() ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Room: ${booking['roomNumber'] ?? ''}\n'
                      'Date: ${formatStoredDate(booking['bookingDate'])}\n'
                      'Duration: ${booking['duration'] ?? ''} days',
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          status,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () => deleteBooking(
                            booking['id']?.toString() ?? '',
                          ),
                          tooltip: 'Delete booking',
                        ),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
// ============================================================
// SETTINGS PAGE
// ============================================================

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notificationsEnabled = true;
  bool darkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: darkModeEnabled ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Settings',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // HEADER
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Colors.indigo,
                    Colors.blueAccent,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.settings,
                      size: 38,
                      color: Colors.indigo,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hostel Management',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Manage your application settings',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // GENERAL SETTINGS
            const Text(
              'General',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),

            const SizedBox(height: 10),

            Card(
              elevation: 2,
              child: SwitchListTile(
                secondary: const Icon(
                  Icons.notifications,
                  color: Colors.orange,
                ),
                title: const Text(
                  'Notifications',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: const Text(
                  'Enable hostel notifications',
                ),
                value: notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    notificationsEnabled = value;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        value
                            ? 'Notifications enabled'
                            : 'Notifications disabled',
                      ),
                    ),
                  );
                },
              ),
            ),

            Card(
              elevation: 2,
              child: SwitchListTile(
                secondary: const Icon(
                  Icons.dark_mode,
                  color: Colors.deepPurple,
                ),
                title: const Text(
                  'Dark Mode',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: const Text(
                  'Change the appearance of Settings',
                ),
                value: darkModeEnabled,
                onChanged: (value) {
                  setState(() {
                    darkModeEnabled = value;
                  });
                },
              ),
            ),

            const SizedBox(height: 25),

            // APP INFORMATION
            const Text(
              'App Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),

            const SizedBox(height: 10),

            Card(
              elevation: 2,
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Icon(
                    Icons.info,
                    color: Colors.white,
                  ),
                ),
                title: const Text(
                  'About the App',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: const Text(
                  'View application information',
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Row(
                          children: [
                            Icon(
                              Icons.info,
                              color: Colors.indigo,
                            ),
                            SizedBox(width: 10),
                            Text('About the App'),
                          ],
                        ),
                        content: const Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hostel Management System',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'This application helps manage hostel students, rooms, room allocation, fees, bookings and reports.',
                            ),
                            SizedBox(height: 12),
                            Text('Version: 1.0.0'),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('CLOSE'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),

            Card(
              elevation: 2,
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Icon(
                    Icons.school,
                    color: Colors.white,
                  ),
                ),
                title: const Text(
                  'College / Developer Details',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: const Text(
                  'View developer information',
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Developer Details'),
                        content: const Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Developed By',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text('CATHERIN JESINTHA J'),
                            SizedBox(height: 12),
                            Text(
                              'Course',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text('B.Sc Computer Science'),
                            SizedBox(height: 12),
                            Text(
                              'College',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              "St. Anne's Arts and Science College",
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('CLOSE'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 25),

            // DATA
            const Text(
              'Data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),

            const SizedBox(height: 10),

            Card(
              elevation: 2,
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.teal,
                  child: Icon(
                    Icons.refresh,
                    color: Colors.white,
                  ),
                ),
                title: const Text(
                  'Refresh Data',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: const Text(
                  'Refresh application data',
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Data refresh requested successfully',
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 30),

            // FOOTER
            Center(
              child: Column(
                children: [
                  const Icon(
                    Icons.home_work,
                    size: 42,
                    color: Colors.indigo,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Hostel Management System',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
// ============================================================
// SIMPLE MODULE PAGE
// ============================================================

class SimpleModulePage
    extends StatelessWidget {
  final String title;
  final IconData icon;
  final String message;

  const SimpleModulePage({
    super.key,
    required this.title,
    required this.icon,
    required this.message,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            Colors.indigo,
        foregroundColor:
            Colors.white,
        title: Text(title),
      ),

      body: Center(
        child:
            Padding(
          padding:
              const EdgeInsets.all(
            25,
          ),
          child:
              Column(
            mainAxisAlignment:
                MainAxisAlignment
                    .center,
            children: [
              Icon(
                icon,
                size: 80,
                color:
                    Colors.indigo,
              ),

              const SizedBox(
                height: 20,
              ),

              Text(
                title,
                style:
                    const TextStyle(
                  fontSize: 26,
                  fontWeight:
                      FontWeight.bold,
                  color:
                      Colors.indigo,
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              Text(
                message,
                textAlign:
                    TextAlign.center,
                style:
                    const TextStyle(
                  color:
                      Colors.grey,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// ============================================================
// REPORTS MODULE
// ============================================================

class ReportsPage extends StatefulWidget {
  final List<Map<String, String>> students;
  final List<Map<String, String>> rooms;
  final Map<String, Map<String, String>> feeRecords;

  const ReportsPage({
    super.key,
    required this.students,
    required this.rooms,
    required this.feeRecords,
  });

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  List<Map<String, dynamic>> bookings = [];

  bool loadingBookings = true;

  @override
  void initState() {
    super.initState();
    loadBookings();
  }

  // ==========================================================
  // LOAD BOOKING RECORDS
  // ==========================================================

  Future<void> loadBookings() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .get();

      if (!mounted) return;

      setState(() {
        bookings = snapshot.docs.map((doc) {
          final data = doc.data();

          return <String, dynamic>{
            'id': doc.id,
            'register': data['register']?.toString() ?? '',
            'studentName':
                data['studentName']?.toString() ?? '',
            'roomNumber':
                data['roomNumber']?.toString() ?? '',
            'roomType':
                data['roomType']?.toString() ?? '',
            'bookingDate':
                data['bookingDate'],
            'duration':
                data['duration']?.toString() ?? '',
            'status':
                data['status']?.toString() ?? 'Confirmed',
          };
        }).toList();

        loadingBookings = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loadingBookings = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not load booking reports: $e',
          ),
        ),
      );
    }
  }

  // ==========================================================
  // FEE CALCULATIONS
  // ==========================================================

  double get totalFees {
    return widget.feeRecords.values.fold<double>(
      0,
      (sum, fee) {
        return sum +
            (double.tryParse(
                  fee['totalFee'] ?? '0',
                ) ??
                0);
      },
    );
  }

  double get totalPaid {
    return widget.feeRecords.values.fold<double>(
      0,
      (sum, fee) {
        return sum +
            (double.tryParse(
                  fee['amountPaid'] ?? '0',
                ) ??
                0);
      },
    );
  }

  double get totalPending {
    return widget.feeRecords.values.fold<double>(
      0,
      (sum, fee) {
        return sum +
            (double.tryParse(
                  fee['balance'] ?? '0',
                ) ??
                0);
      },
    );
  }

  int get availableRooms {
    return widget.rooms
        .where(
          (room) => room['status'] == 'Available',
        )
        .length;
  }

  int get occupiedRooms {
    return widget.rooms
        .where(
          (room) => room['status'] == 'Occupied',
        )
        .length;
  }

  int get confirmedBookings {
    return bookings
        .where(
          (booking) =>
              booking['status'] == 'Confirmed',
        )
        .length;
  }

  // ==========================================================
  // DATE FORMAT
  // ==========================================================

  String formatBookingDate(dynamic value) {
    if (value == null) {
      return 'Not available';
    }

    DateTime? date;

    if (value is Timestamp) {
      date = value.toDate();
    } else if (value is DateTime) {
      date = value;
    } else {
      try {
        date = DateTime.parse(
          value.toString(),
        );
      } catch (_) {
        return value.toString();
      }
    }

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  // ==========================================================
  // STAT CARD
  // ==========================================================

  Widget reportCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: color.withOpacity(0.12),
              child: Icon(
                icon,
                color: color,
                size: 27,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // SECTION TITLE
  // ==========================================================

  Widget sectionTitle(
    String title,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.indigo,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.indigo,
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // STUDENT REPORT
  // ==========================================================

  Widget buildStudentReport() {
    if (widget.students.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(
            child: Text(
              'No student records available.',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
        ),
      );
    }

    return Card(
      child: Column(
        children: widget.students.map((student) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  Colors.blue.shade100,
              child: const Icon(
                Icons.person,
                color: Colors.blue,
              ),
            ),
            title: Text(
              student['name'] ?? '',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'Register No: '
              '${student['register'] ?? ''}\n'
              'Course: '
              '${student['course'] ?? ''}',
            ),
            isThreeLine: true,
          );
        }).toList(),
      ),
    );
  }

  // ==========================================================
  // ROOM REPORT
  // ==========================================================

  Widget buildRoomReport() {
    if (widget.rooms.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(
            child: Text(
              'No room records available.',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
        ),
      );
    }

    return Card(
      child: Column(
        children: widget.rooms.map((room) {
          final isAvailable =
              room['status'] == 'Available';

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: isAvailable
                  ? Colors.green.shade100
                  : Colors.orange.shade100,
              child: Icon(
                Icons.bed,
                color: isAvailable
                    ? Colors.green
                    : Colors.orange,
              ),
            ),
            title: Text(
              'Room ${room['number'] ?? ''}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              '${room['type'] ?? ''} Room • '
              'Capacity: ${room['capacity'] ?? ''}',
            ),
            trailing: Text(
              room['status'] ?? '',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isAvailable
                    ? Colors.green
                    : Colors.orange,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ==========================================================
  // FEE REPORT
  // ==========================================================

  Widget buildFeeReport() {
    if (widget.feeRecords.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(
            child: Text(
              'No fee records available.',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
        ),
      );
    }

    return Card(
      child: Column(
        children:
            widget.feeRecords.values.map((fee) {
          final status =
              fee['status'] ?? 'Pending';

          final isPaid = status == 'Paid';

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: isPaid
                  ? Colors.green.shade100
                  : Colors.orange.shade100,
              child: Icon(
                isPaid
                    ? Icons.check
                    : Icons.pending,
                color: isPaid
                    ? Colors.green
                    : Colors.orange,
              ),
            ),
            title: Text(
              fee['studentName'] ?? '',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'Total: ₹${fee['totalFee'] ?? '0'}\n'
              'Paid: ₹${fee['amountPaid'] ?? '0'}\n'
              'Balance: ₹${fee['balance'] ?? '0'}',
            ),
            trailing: Text(
              status,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isPaid
                    ? Colors.green
                    : Colors.orange,
              ),
            ),
            isThreeLine: true,
          );
        }).toList(),
      ),
    );
  }

  // ==========================================================
  // BOOKING REPORT
  // ==========================================================

  Widget buildBookingReport() {
    if (loadingBookings) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (bookings.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(
            child: Text(
              'No booking records available.',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
        ),
      );
    }

    return Card(
      child: Column(
        children: bookings.map((booking) {
          final status =
              booking['status'] ?? 'Confirmed';

          return ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  Colors.indigo.shade100,
              child: const Icon(
                Icons.calendar_month,
                color: Colors.indigo,
              ),
            ),
            title: Text(
              booking['studentName'] ?? '',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'Room: '
              '${booking['roomNumber'] ?? ''}\n'
              'Date: '
              '${formatBookingDate(
                booking['bookingDate'],
              )}\n'
              'Duration: '
              '${booking['duration'] ?? ''} days',
            ),
            trailing: Text(
              status,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            isThreeLine: true,
          );
        }).toList(),
      ),
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F7FB),

      appBar: AppBar(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        title: const Text(
          'Reports',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: RefreshIndicator(
        onRefresh: loadBookings,
        child: SingleChildScrollView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          padding:
              const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              // ------------------------------------------------
              // HEADER
              // ------------------------------------------------

              const Text(
                'Hostel Reports',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'View a complete summary of hostel '
                'students, rooms, fees and bookings.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 25),

              // ------------------------------------------------
              // SUMMARY
              // ------------------------------------------------

              sectionTitle(
                'Hostel Summary',
                Icons.dashboard,
              ),

              const SizedBox(height: 15),

              reportCard(
                title: 'Total Students',
                value:
                    widget.students.length.toString(),
                icon: Icons.people,
                color: Colors.blue,
              ),

              const SizedBox(height: 12),

              reportCard(
                title: 'Total Rooms',
                value:
                    widget.rooms.length.toString(),
                icon: Icons.bed,
                color: Colors.indigo,
              ),

              const SizedBox(height: 12),

              reportCard(
                title: 'Available Rooms',
                value:
                    availableRooms.toString(),
                icon: Icons.meeting_room,
                color: Colors.green,
              ),

              const SizedBox(height: 12),

              reportCard(
                title: 'Occupied Rooms',
                value:
                    occupiedRooms.toString(),
                icon: Icons.meeting_room,
                color: Colors.orange,
              ),

              const SizedBox(height: 12),

              reportCard(
                title: 'Total Bookings',
                value:
                    bookings.length.toString(),
                icon: Icons.calendar_month,
                color: Colors.indigo,
              ),

              const SizedBox(height: 12),

              reportCard(
                title: 'Confirmed Bookings',
                value:
                    confirmedBookings.toString(),
                icon: Icons.verified,
                color: Colors.green,
              ),

              const SizedBox(height: 30),

              // ------------------------------------------------
              // FEE SUMMARY
              // ------------------------------------------------

              sectionTitle(
                'Fee Summary',
                Icons.currency_rupee,
              ),

              const SizedBox(height: 15),

              reportCard(
                title: 'Total Hostel Fees',
                value:
                    '₹${totalFees.toStringAsFixed(2)}',
                icon: Icons.account_balance_wallet,
                color: Colors.indigo,
              ),

              const SizedBox(height: 12),

              reportCard(
                title: 'Total Amount Paid',
                value:
                    '₹${totalPaid.toStringAsFixed(2)}',
                icon: Icons.payments,
                color: Colors.green,
              ),

              const SizedBox(height: 12),

              reportCard(
                title: 'Total Pending Fees',
                value:
                    '₹${totalPending.toStringAsFixed(2)}',
                icon: Icons.pending_actions,
                color: Colors.red,
              ),

              const SizedBox(height: 30),

              // ------------------------------------------------
              // STUDENT REPORT
              // ------------------------------------------------

              sectionTitle(
                'Student Report',
                Icons.groups,
              ),

              const SizedBox(height: 15),

              buildStudentReport(),

              const SizedBox(height: 30),

              // ------------------------------------------------
              // ROOM REPORT
              // ------------------------------------------------

              sectionTitle(
                'Room Report',
                Icons.bed,
              ),

              const SizedBox(height: 15),

              buildRoomReport(),

              const SizedBox(height: 30),

              // ------------------------------------------------
              // FEE REPORT
              // ------------------------------------------------

              sectionTitle(
                'Fee Report',
                Icons.currency_rupee,
              ),

              const SizedBox(height: 15),

              buildFeeReport(),

              const SizedBox(height: 30),

              // ------------------------------------------------
              // BOOKING REPORT
              // ------------------------------------------------

              sectionTitle(
                'Booking Report',
                Icons.calendar_month,
              ),

              const SizedBox(height: 15),

              buildBookingReport(),

              const SizedBox(height: 30),

              // ------------------------------------------------
              // FOOTER
              // ------------------------------------------------

              Center(
                child: Text(
                  'Hostel Management • Reports',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}