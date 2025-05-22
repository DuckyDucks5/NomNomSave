import 'package:flutter/material.dart';

class MemberLeavePage extends StatefulWidget {
  const MemberLeavePage({super.key});

  @override
  State<MemberLeavePage> createState() => _MemberLeavePageState();
}

class _MemberLeavePageState extends State<MemberLeavePage> {
  bool _showMembers = true;
  bool _hasLeftRoom = false;

  @override
  void initState() {
    super.initState();

    // Show modal after first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showLeavePopup(context);
    });
  }

  void _showLeavePopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!_hasLeftRoom) ...[
                    const Text(
                      "Are you sure want to leave this room?",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Are you sure you want to exit this room? You won’t be able to come back unless someone re-invites you.",
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
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
                        onPressed: () {
                          setModalState(() {
                            _hasLeftRoom = true;
                          });
                        },
                        child: const Text("Leave"),
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ] else ...[
                    const Text(
                      "You have successfully left the room!",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
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
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("OK"),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
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
