import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ViewMemberPage extends StatefulWidget {
  const ViewMemberPage({super.key});

  @override
  State<ViewMemberPage> createState() => _ViewMemberPageState();
}

class _ViewMemberPageState extends State<ViewMemberPage> {
  bool _showMembers = true;

  final List<Map<String, String>> _members = [
    {'label': 'You', 'name': 'Siapanamanydmnrumahny'},
    {'label': 'A', 'name': 'Auryn'},
    {'label': 'S', 'name': 'Selina'},
  ];

  @override
  void initState() {
    super.initState();

    // Show modal after first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showMemberListPopup(context);
    });
  }

  void _showMemberListPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Member/s",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // List Member
              ..._members.map((member) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: const Color(0xFFEFD6C8),
                        radius: 20,
                        child: Text(
                          member['label']!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        member['name']!,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                );
              }).toList(),

              // Add New Member
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.transparent,
                      radius: 20,
                      child: Icon(Icons.add, color: Colors.grey.shade600),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Add New Member",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 12),

              // Back Button
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              const SizedBox(height: 12),

              Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: const DecorationImage(
                        image: AssetImage("assets/images/pochacco.png"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Nomnom’s",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Member Toggle
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showMembers = !_showMembers;
                  });
                },
                child: Row(
                  children: [
                    const Text(
                      "Member/s",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      _showMembers
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Member Chips
              if (_showMembers)
                Row(
                  children: const [
                    _MemberChip(label: "You"),
                    _MemberChip(label: "A"),
                    _MemberChip(label: "S"),
                    _MemberChip(label: "+", isAdd: true),
                  ],
                ),

              const SizedBox(height: 24),

              // Room Description
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Room Description",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Remember to save your nomnoms!",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MemberChip extends StatelessWidget {
  final String label;
  final bool isAdd;

  const _MemberChip({required this.label, this.isAdd = false});

  @override
  Widget build(BuildContext context) {
    final double size = 44;

    return Container(
      margin: const EdgeInsets.only(right: 10),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isAdd ? Colors.transparent : const Color(0xFFEFD6C8),
        shape: BoxShape.circle,
        border: isAdd ? Border.all(color: Colors.grey.shade400) : null,
      ),
      child: Center(
        child:
            isAdd
                ? const Icon(Icons.add, size: 20, color: Colors.grey)
                : Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
      ),
    );
  }
}
