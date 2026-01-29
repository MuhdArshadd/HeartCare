import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/user_controller.dart';
import '../model/provider/user_provider.dart';

import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:cloud_functions/cloud_functions.dart';

class FamilyModeView extends StatefulWidget {
  final VoidCallback onSwitchToPersonal;

  const FamilyModeView({super.key, required this.onSwitchToPersonal});

  @override
  State<FamilyModeView> createState() => _FamilyModeViewState();
}

class _FamilyModeViewState extends State<FamilyModeView> {
  final UserController userController = UserController();

  // --- MAP CONFIGURATION ---
  final Completer<GoogleMapController> _mapController = Completer();
  Set<Marker> _markers = {};

  // Default fallback (Kuala Lumpur)
  static const CameraPosition _defaultCamera = CameraPosition(
    target: LatLng(3.149197, 101.692504),
    zoom: 12,
  );
  // -------------------------

  bool _isLoading = false;
  bool _isExpanded = false;
  final TextEditingController _idController = TextEditingController();

  List<Map<String, dynamic>> familyMembers = [];

  final List<Color> _uiColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.brown,
  ];

  final List<double> _mapHues = [
    BitmapDescriptor.hueBlue,
    BitmapDescriptor.hueRed,
    BitmapDescriptor.hueGreen,
    BitmapDescriptor.hueOrange,
    BitmapDescriptor.hueViolet,
    BitmapDescriptor.hueCyan,
    BitmapDescriptor.hueMagenta,
    BitmapDescriptor.hueRose,
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchFamilyData();
    });
  }

  // --- NEW: SEND POKE FUNCTION ---
  Future<void> _sendPoke(int targetUserId, String targetName, String? targetToken) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final myName = userProvider.user?.fullname ?? "A Family Member";

    // 1. Validation: Check if token exists immediately
    if (targetToken == null || targetToken.isEmpty) {
      return;
    }

    try {
      // 2. Call Cloud Function directly (No DB call needed!)
      final result = await FirebaseFunctions.instance
          .httpsCallable('sendPokeNotification')
          .call({
        'targetToken': targetToken,
        'senderName': myName,
        'targetName': targetName,
      });

    } catch (e) {
      print("Poke Error: $e");
    }
  }

  // --- 1. FETCH DATA & GENERATE MARKERS ---
  Future<void> _fetchFamilyData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUserId = userProvider.user?.userID;

    if (currentUserId == null) return;

    setState(() => _isLoading = true);

    try {
      // Fetch complete list (Me + Family) from backend
      List<Map<String, dynamic>> fetchedMembers = await userController.getFamilyMemberList(currentUserId);

      if (mounted) {
        setState(() {
          familyMembers = fetchedMembers;
          _generateMarkers(); // 2. Create Pins
        });

        // 3. AUTO-CENTER CAMERA
        // We wait a tiny bit to ensure the map controller is ready
        _adjustCameraToFitMembers();
      }

    } catch (e) {
      print("Error fetching family data: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

// --- MAP LOGIC: Create Markers from Data ---
  void _generateMarkers() {
    Set<Marker> newMarkers = {};

    // Use a standard for-loop so we have the 'index' (i)
    for (int i = 0; i < familyMembers.length; i++) {
      var member = familyMembers[i];

      double lat = member['lat'] ?? 0.0;
      double lng = member['lng'] ?? 0.0;
      String name = member['name'] ?? "Unknown";
      String status = member['status'] ?? "Unidentified";
      String userId = member['userId'].toString();

      if (lat == 0.0 && lng == 0.0) continue;

      // COLOR LOGIC: Pick color based on the order in the list
      // We use modulo (%) so if you have more users than colors, it cycles back to blue.
      double hue = _mapHues[i % _mapHues.length];

      newMarkers.add(
        Marker(
          markerId: MarkerId(userId),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(title: name, snippet: status),
          icon: BitmapDescriptor.defaultMarkerWithHue(hue), // Apply Legend Color
        ),
      );
    }

    setState(() {
      _markers = newMarkers;
    });
  }

  // --- NEW LOGIC: Calculate Middle & Zoom ---
  Future<void> _adjustCameraToFitMembers() async {
    if (familyMembers.isEmpty) return;

    // Filter out invalid locations (0,0)
    final validMembers = familyMembers.where((m) =>
    (m['lat'] != null && m['lat'] != 0.0) &&
        (m['lng'] != null && m['lng'] != 0.0)
    ).toList();

    if (validMembers.isEmpty) return;

    final GoogleMapController controller = await _mapController.future;

    // ALGORITHM: Find the Bounds (Min/Max Lat/Lng)
    double minLat = validMembers.first['lat'];
    double maxLat = validMembers.first['lat'];
    double minLng = validMembers.first['lng'];
    double maxLng = validMembers.first['lng'];

    for (var m in validMembers) {
      double lat = m['lat'];
      double lng = m['lng'];
      if (lat < minLat) minLat = lat;
      if (lat > maxLat) maxLat = lat;
      if (lng < minLng) minLng = lng;
      if (lng > maxLng) maxLng = lng;
    }

    // Apply Bounds with Padding (so markers aren't on the absolute edge)
    controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        100.0, // 100 padding pixels
      ),
    );
  }

  // --- MAP LOGIC: Zoom to specific user ---
  Future<void> _goToLocation(double lat, double lng) async {
    if (lat == 0.0 && lng == 0.0) return;

    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng), 15));
  }



  // --- 2. RESULT DIALOG ---
  void _showResultDialog(bool isSuccess) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Colors.white,
          title: Icon(
            isSuccess ? Icons.check_circle : Icons.error,
            color: isSuccess ? Colors.green : Colors.red,
            size: 50,
          ),
          content: Text(
            isSuccess
                ? "Operation successful!"
                : "Operation failed. Please check the ID and try again.",
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSuccess ? Colors.green : Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  if (isSuccess) _fetchFamilyData(); // Refresh list on success
                },
                child: const Text("OK"),
              ),
            ),
          ],
        );
      },
    );
  }

  // --- 3. REMOVE LOGIC ---
  Future<void> _handleRemoveMember(int index) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUserId = userProvider.user?.userID;

    // Get the User ID of the person we want to remove
    final targetMemberId = familyMembers[index]['userId'];

    if (currentUserId == null || targetMemberId == null) return;

    // Call Backend: isRemove = true
    // userFamilyID = 0 (ignored), removeId = targetMemberId
    bool success = await userController.addOrRemoveFamilyMember(
        true,           // isRemove
        0,              // userFamilyID (not needed for remove)
        currentUserId,  // requesterId
        targetMemberId  // removeId
    );

    if (success) {
      _fetchFamilyData(); // Refresh everything (Map + List)
    }
  }

  void _showRemoveConfirmation(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text("Remove family member?", style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text("Are you sure you want to remove this person from your family list?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("No", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
                _handleRemoveMember(index);
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  // --- 4. ADD MEMBER POPUP ---
  void _showAddMemberPopup() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _idController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Add Family Members", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context))
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Enter Your Family Member's ID", style: TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 8),
              TextField(
                controller: _idController,
                keyboardType: TextInputType.number, // Ensure numeric keyboard
                decoration: InputDecoration(
                  hintText: "Family Members ID...",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 8),
              Text('Your ID is ${userProvider.user?.generatedID ?? "Unknown"}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  String inputString = _idController.text.trim();
                  if (inputString.isEmpty) return;

                  // Parse to int for backend
                  int? inputId = int.tryParse(inputString);
                  if (inputId == null) {
                    return;
                  }

                  Navigator.pop(context); // Close input dialog

                  final currentUserId = userProvider.user?.userID;
                  if (currentUserId == null) return;

                  // 3. Call Backend Function
                  // isRemove = false
                  // userFamilyID = inputId, removeId = 0
                  bool success = await userController.addOrRemoveFamilyMember(
                      false,          // isRemove
                      inputId,        // userFamilyID (The Invite Code)
                      currentUserId,  // requesterId
                      0               // removeId (not needed for add)
                  );

                  // 4. Handle Result
                  _showResultDialog(success);
                },
                child: const Text("Add Family Member"),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // --- LAYER 1: GOOGLE MAPS ---
        Positioned.fill(
          child: GoogleMap(
          mapType: MapType.normal,
            initialCameraPosition: _defaultCamera,
            markers: _markers, // <--- BIND MARKERS HERE
            myLocationEnabled: true, // Shows Blue Dot (Uses GPS Permission)
            myLocationButtonEnabled: false, // Hides default button
            zoomControlsEnabled: false, // Hides +/- buttons
            onMapCreated: (GoogleMapController controller) {
              if (!_mapController.isCompleted) {
                _mapController.complete(controller);
              }
            },
          ),
        ),
        // --- LAYER 2: TOP TOGGLE ---
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: widget.onSwitchToPersonal,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(8)),
                      child: const Center(child: Text("Personal", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8)
                    ),
                    child: const Center(child: Text("Family Mode", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                  ),
                ),
              ],
            ),
          ),
        ),

        // --- LAYER 3: BOTTOM SHEET ---
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () => setState(() => _isExpanded = !_isExpanded),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Family Members:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Icon(_isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up, color: Colors.red),
                    ],
                  ),
                ),
                if (_isExpanded) ...[
                  const SizedBox(height: 10),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: familyMembers.isEmpty
                        ? Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : const Center(child: Text("No family members found.", style: TextStyle(color: Colors.grey))),
                    )
                        : ListView.separated(
                      shrinkWrap: true,
                      itemCount: familyMembers.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final m = familyMembers[index];

                        // 1. Get the Unique Color for this user
                        Color legendColor = _uiColors[index % _uiColors.length];

                        // 2. STATUS COLOR (For Risk Text)
                        // Restored logic: Red for High, Green for Low
                        Color statusColor = Colors.grey;
                        if (m['status'] == "High Risk") statusColor = Colors.red;
                        if (m['status'] == "Low Risk") statusColor = Colors.green;
                        if (m['status'] == "Low Risk") statusColor = Colors.green;
                        bool isPokeable = m['fcm_token'] != null && m['fcm_token'].toString().isNotEmpty;

                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onLongPress: () {
                              if (m['isMe'] == false) {
                                _showRemoveConfirmation(index);
                              }
                            },
                            onTap: () {
                              _goToLocation(m['lat'] ?? 0.0, m['lng'] ?? 0.0);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12)
                              ),
                              child: Row(
                                children: [
                                  // 2. Updated CircleAvatar with Legend Color
                                  CircleAvatar(
                                      backgroundColor: legendColor.withOpacity(0.2), // Light background
                                      child: Icon(
                                          Icons.person,
                                          color: legendColor // Solid Icon color
                                      )
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                      child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                m['name'],
                                                style: const TextStyle(fontWeight: FontWeight.bold)
                                            ),
                                            Row(
                                              children: [
                                                const Text("Status: ", style: TextStyle(fontSize: 12)),
                                                // We keep the text plain black/grey now since the avatar handles ID
                                                Text(
                                                    m['status'],
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.bold,
                                                        color: statusColor                                                    )
                                                ),
                                              ],
                                            ),
                                          ]
                                      )
                                  ),
                                  // --- NEW: POKE BUTTON ---
                                  if (m['isMe'] != true)
                                    IconButton(
                                      // If not pokeable, show Grey color. Else show Orange.
                                      icon: Icon(Icons.touch_app, color: isPokeable ? Colors.orange : Colors.grey),

                                      // If not pokeable, show different message
                                      tooltip: isPokeable ? "Poke ${m['name']}" : "${m['name']} hasn't updated the app",

                                      onPressed: () {
                                        if (isPokeable) {
                                          _sendPoke(m['userId'], m['name'], m['fcm_token']);
                                        }
                                      },
                                    ),

                                  if(m['isMe'] == true)
                                    const Chip(label: Text("ME", style: TextStyle(fontSize: 10, color: Colors.white)), backgroundColor: Colors.blue, visualDensity: VisualDensity.compact, padding: EdgeInsets.zero)
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: _showAddMemberPopup,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.add, color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Text("Add more family members", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ]
              ],
            ),
          ),
        ),
      ],
    );
  }
}