import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_se/view/update_room_page.dart';

class ViewRoom extends StatelessWidget {
  final int teamId;
  final String? teamName;
  final int teamProfileIndex;
  final String? teamDescription;
  final String? teamCode;

  const ViewRoom({
    super.key,
    required this.teamId,
    required this.teamName,
    required this.teamProfileIndex,
    required this.teamDescription,
    required this.teamCode,
  });

  @override
  Widget build(BuildContext context) => RoomPage(
    teamId: teamId,
    teamName: teamName,
    teamProfileIndex: teamProfileIndex,
    teamDescription: teamDescription,
    teamCode: teamCode,
  );
}

class RoomPage extends StatefulWidget {
  final int teamId;
  final String? teamName;
  final int teamProfileIndex;
  final String? teamDescription;
  final String? teamCode;

  const RoomPage({
    super.key,
    required this.teamId,
    required this.teamName,
    required this.teamProfileIndex,
    required this.teamDescription,
    required this.teamCode,
  });

  @override
  State<RoomPage> createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  int? teamId;
  int? currentUserId;
  List<Map<String, dynamic>> members = [];
  final String currentUser = 'You';
  List<dynamic> productList = [];

  static const orange = Color(0xFFFF8C42);
  bool isLoadingMembers = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    int teamId = widget.teamId;
    await _loadUserId(); // pastikan currentUserId sudah tersedia
    await _fetchMembers(); // fetch member setelah userId tersedia
    await _loadProductOverview(teamId); // fetch produk setelah userId tersedia
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    currentUserId = prefs.getInt('UserID');
  }

  Future<void> _fetchMembers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final url = Uri.parse(
        'http://10.0.2.2:3000/get-member-room/${widget.teamId}',
      );
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          members =
              data.map((item) {
                final name = item['UserName'];
                final profileIndex = item['UserProfileIndex'] ?? 1;
                final id = item['UserID'];

                return {
                  'name': id == currentUserId ? '$name' : name,
                  'profileIndex': profileIndex,
                  'userId': id,
                };
              }).toList();
          isLoadingMembers = false;
        });
      } else {
        throw Exception('Failed to load members');
      }
    } catch (e) {
      setState(() {
        isLoadingMembers = false;
      });
    }
  }

  Future<List<Map<String, dynamic>>> fetchMembers(String roomId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final url = Uri.parse(('http://10.0.2.2:3000/get-member-room/$roomId'));
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map<Map<String, dynamic>>((item) {
          final name = item['UserName'];
          final profileIndex = item['UserProfileIndex'] ?? 1;
          final id = item['UserID'];

          return {
            'name': id == currentUserId ? '$name' : name,
            'profileIndex': profileIndex,
            'userId': id,
          };
        }).toList();
      } else {
        throw Exception('Failed to load members');
      }
    } catch (e) {
      return [];
    }
  }

  Future<void> _loadProductOverview(int teamId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final url = Uri.parse('http://10.0.2.2:3000/overview-product-room/$teamId');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      setState(() {
        productList = data;
      });
    } else {
      throw Exception('Failed to load product list');
    }
  }

  Future<void> _deleteRoom() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final url = Uri.parse(
        'http://10.0.2.2:3000/delete-room/${widget.teamId}',
      );
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          "/home",
          (Route<dynamic> route) => false,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Room deleted successfully')),
        );
      } else {
        throw Exception('Failed to delete room');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error deleting room')));
    }
  }

  Future<void> _leaveRoom() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final url = Uri.parse(
        'http://10.0.2.2:3000/leave-room/${widget.teamId}/$currentUserId',
      );
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          "/home",
          (Route<dynamic> route) => false,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Room leave successfully')),
        );
      } else {
        throw Exception('Failed to leave room');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error leaving room')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black, size: 30),
            tooltip: 'Leave Room',
            onPressed: () {
              _showLeaveConfirmation(context);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _buildHeader(),
          const SizedBox(height: 40),
          _buildMemberPreview(context),
          const SizedBox(height: 20),
          _buildRoomDescription(),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          _buildProductHeader(context),
          const SizedBox(height: 10),

          // Product list dynamic
          ...productList.map((product) {
            final name = product['ProductName'] as String;
            final addedBy = product['UserName'] as String;
            final rawDate = product['FormattedExpiredDate'] as String;

            return Column(
              children: [
                _buildProductTile(
                  name: name,
                  addedBy:
                      currentUserId.toString() ==
                              product['UserUserID'].toString()
                          ? "You"
                          : addedBy,
                  date: rawDate,
                ),
                const SizedBox(height: 10),
              ],
            );
          }), //.toList(),

          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(
                child: _buildActionButton("Update Room", orange, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => UpdatePage(
                            teamId: widget.teamId,
                            teamName: widget.teamName,
                            teamProfileIndex: widget.teamProfileIndex,
                            teamDescription: widget.teamDescription,
                          ),
                    ),
                  );
                }),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildActionButton("Delete Room", orange, () {
                  _showDeleteConfirmation(context);
                }),
              ),
            ],
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildHeader() => Column(
    children: [
      Text(
        widget.teamName ?? '',
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 10),
      Container(
        padding: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 2),
          borderRadius: BorderRadius.circular(24),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset(
            'assets/profileRoom/profile_${widget.teamProfileIndex}.jpeg',
            width: 120,
            height: 120,
            fit: BoxFit.cover,
          ),
        ),
      ),
    ],
  );

  Widget _buildMemberPreview(BuildContext context) => Column(
    children: [
      Row(
        children: [
          const Text(
            "Member/s",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down),
            onPressed:
                () => _showMemberSheet(context, widget.teamId.toString()),
          ),
        ],
      ),
      const SizedBox(height: 10),
      isLoadingMembers
          ? const CircularProgressIndicator()
          : Row(
            children: [
              ...members.map(
                (m) => Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Container(
                    padding: const EdgeInsets.all(
                      2,
                    ), // Untuk memberi jarak antara border dan avatar
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 1),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundImage: AssetImage(
                        'assets/profileUser/profile_${m['profileIndex']}.jpg',
                      ),
                    ),
                  ),
                ),
              ),
              _buildAddMemberCircle(),
            ],
          ),
    ],
  );

  Widget _buildAddMemberCircle() => GestureDetector(
    onTap: () => _showCodeSheet(context),
    child: const CircleAvatar(
      radius: 20,
      backgroundColor: Colors.grey,
      child: Icon(Icons.add, color: Colors.white),
    ),
  );

  Widget _buildRoomDescription() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        "Room Description",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 5),
      Text(
        widget.teamDescription ?? '',
        style: const TextStyle(fontSize: 14, color: Colors.black54),
      ),
    ],
  );

  Widget _buildProductHeader(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      const Text("Product List", style: TextStyle(fontWeight: FontWeight.bold)),
      GestureDetector(
        onTap:
            () => ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text("View All clicked"))),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          constraints: const BoxConstraints(minHeight: 24),
          decoration: BoxDecoration(
            color: orange,
            borderRadius: BorderRadius.circular(20),
            // minimumSize: const Size(0, 24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                // blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Text(
            "View All",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    ],
  );

  void _showLeaveConfirmation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder:
          (BuildContext sheetContext) => Container(
            padding: const EdgeInsets.fromLTRB(40, 40, 40, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Are you sure want to leave this room?",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(fontSize: 15, color: Colors.grey),
                    children: [
                      const TextSpan(
                        text:
                            "Are you sure you want to leave this room? You won't be able to come back unless someone re-invites you.",
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      _leaveRoom(); // Call the leave room function
                      // leave room logic here
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Leave",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                TextButton(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                  },
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      color: Colors.orange,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.orange,
                      decorationThickness: 2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
    );
  }

  void _showMemberSheet(BuildContext context, String roomId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchMembers(roomId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  final allMembers = snapshot.data!;

                  // Pisahkan current user
                  final currentUserMember = allMembers.firstWhere(
                    (member) => member['userId'] == currentUserId,
                    orElse: () => {},
                  );

                  final otherMembers =
                      allMembers
                          .where((member) => member['userId'] != currentUserId)
                          .toList();

                  final orderedMembers = [
                    if (currentUserMember.isNotEmpty) currentUserMember,
                    ...otherMembers,
                  ];

                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Text(
                          "Members",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: ListView.builder(
                            controller: scrollController,
                            itemCount: orderedMembers.length + 1,
                            itemBuilder: (context, index) {
                              if (index < orderedMembers.length) {
                                final member = orderedMembers[index];
                                final isYou = member['userId'] == currentUserId;
                                return ListTile(
                                  leading: CircleAvatar(
                                    radius: 20,
                                    backgroundImage: AssetImage(
                                      'assets/profileUser/profile_${member['profileIndex']}.jpg',
                                    ),
                                  ),
                                  title: Text(member['name']),
                                  trailing:
                                      isYou
                                          ? const Text(
                                            "You",
                                            style: TextStyle(
                                              color: Colors.grey,
                                            ),
                                          )
                                          : IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.orange,
                                            ),
                                            onPressed: () {
                                              // TODO: implement delete logic
                                            },
                                          ),
                                );
                              } else {
                                return const SizedBox(height: 10);
                              }
                            },
                          ),
                        ),
                        ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFFE0E0E0),
                            child: Icon(Icons.add, color: Colors.black),
                          ),
                          title: const Text("Add from Invitation Code"),
                          onTap: () {
                            Navigator.pop(context);
                            _showCodeSheet(context);
                          },
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: 150,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: orange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              "OK",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            );
          },
        );
      },
    );
  }

  void _showCodeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder:
          (BuildContext sheetContext) => Container(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Room Invitation Code",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Room Code:",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.teamCode ?? '',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(text: widget.teamCode ?? ''),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Code copied!")),
                    );
                  },
                  child: const Text(
                    "Copy Code",
                    style: TextStyle(
                      color: orange,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(sheetContext); // pakai sheetContext
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "OK",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder:
          (BuildContext sheetContext) => Container(
            padding: const EdgeInsets.fromLTRB(40, 40, 40, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Are you sure to delete this room?",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(fontSize: 15, color: Colors.grey),
                    children: [
                      const TextSpan(
                        text:
                            "By deleting this room, all of your saved products will be deleted ",
                      ),
                      TextSpan(
                        text: "permanently,",
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(text: " Proceed?"),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      _deleteRoom();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Delete Room",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                TextButton(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                  },
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      color: Colors.orange,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.orange,
                      decorationThickness: 2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
    );
  }

  static Widget _buildProductTile({
    required String name,
    required String addedBy,
    required String date,
  }) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.orangeAccent),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              "added by $addedBy",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "Expiration Date",
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
            ),
            const SizedBox(height: 4),
            Text(
              date,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ],
    ),
  );

  static Widget _buildActionButton(
    String label,
    Color color,
    VoidCallback onPressed,
  ) => SizedBox(
    height: 50,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
  );
}
