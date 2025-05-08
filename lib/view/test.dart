import 'package:flutter/material.dart';

void main() {
  runApp(const CreateRoom());
}

class CreateRoom extends StatelessWidget {
  const CreateRoom({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: CreateRoomScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CreateRoomScreen extends StatelessWidget {
  const CreateRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFF5E5), // Slightly orange background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        toolbarHeight: 90,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.orange),
          onPressed: () {},
        ),
        title: ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              colors: [Colors.orange, Colors.red], // Gradient colors
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds);
          },
          child: Text(
            'Create Room',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white, // Keep white for gradient effect
            ),
          ),
        ),
      ),
      body: SingleChildScrollView( // Prevent bottom overflow
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 90, // Enlarged profile image
                        height: 90,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.0),
                          image: DecorationImage(
                            image: AssetImage('assets/room_icon.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 1,
                        right: 1,
                        child: Container(
                          width: 25,
                          height: 25,
                          decoration: BoxDecoration(shape: BoxShape.circle),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Gradient background
                              ShaderMask(
                                shaderCallback: (Rect bounds) {
                                  return LinearGradient(
                                    colors: [Colors.orange, Colors.red], // Gradient colors
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ).createShader(bounds);
                                },
                                child: Container(
                                  width: 25,
                                  height: 25,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white, // Base color for masking
                                  ),
                                ),
                              ),
                              // White camera icon stays visible
                              Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 15,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 16),
                  Expanded(child: RoomNameField()),
                ],
              ),
              SizedBox(height: 16),

              Divider(color: Colors.grey[300]), // Added divider line

              SizedBox(height: 16),
              RoomDescriptionField(), // Updated Room Description Field

              SizedBox(height: 16),

              Divider(color: Colors.grey[300]), // Added another divider line

              SizedBox(height: 16),
              Text(
                'Notes:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'You can only create up to 7 rooms in your account\nCurrently (0/7) rooms',
                style: TextStyle(color: Colors.grey[700]),
              ),

              SizedBox(height: 50),

              // Gradient Button with Gradient Text
              Center(
  child: Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(30),
      gradient: LinearGradient(
        colors: [const Color.fromARGB(255, 255,	147,	73), const Color.fromARGB(255, 255,214,118)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
    ),
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 32),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      onPressed: () {},
      child: Text(
        'Create Room',
        style: TextStyle(fontSize: 18, color: Colors.white),
        //Navigator.push(context, /create-room)
      ),
    ),
  ),
),

              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// Room Name Field with Persistent Title
class RoomNameField extends StatefulWidget {
  const RoomNameField({Key? key}) : super(key: key);

  @override
  _RoomNameFieldState createState() => _RoomNameFieldState();
}

class _RoomNameFieldState extends State<RoomNameField> {
  bool _isFocused = false;
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Room Name',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontSize: 20,
          ),
        ),
        SizedBox(height: 8),
        TextField(
          focusNode: _focusNode,
          controller: _controller,
          cursorColor: Colors.orange,
          decoration: InputDecoration(
            hintText: _isFocused ? '' : 'Enter room name', // Hide placeholder when focused
            hintStyle: TextStyle(color: Colors.grey),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(5.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.orange, width: 2.0),
              borderRadius: BorderRadius.circular(5.0),
            ),
          ),
        ),
      ],
    );
  }
}


// Room Description Field with Persistent Title
class RoomDescriptionField extends StatefulWidget {
  const RoomDescriptionField({super.key});

  @override
  _RoomDescriptionFieldState createState() => _RoomDescriptionFieldState();
}

class _RoomDescriptionFieldState extends State<RoomDescriptionField> {
  bool _isFocused = false;
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Room Description',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontSize: 20,
          ),
        ),
        SizedBox(height: 8),
        TextField(
          focusNode: _focusNode,
          controller: _controller,
          maxLines: 4,
          cursorColor: Colors.orange,
          decoration: InputDecoration(
            hintText: _isFocused ? '' : 'Room Description', // Hide placeholder when focused
            hintStyle: TextStyle(color: Colors.grey),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(5.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.orange, width: 2.0),
              borderRadius: BorderRadius.circular(5.0),
            ),
          ),
        ),
      ],
    );
  }
}
