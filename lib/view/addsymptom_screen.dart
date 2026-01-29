import 'package:flutter/material.dart';
import 'package:heartcare/controller/symptom_controller.dart';
import 'package:heartcare/view/popup_screen/loading_processing_popup.dart';
import 'package:provider/provider.dart';
import '../model/provider/user_provider.dart';
import 'app_bar/main_navigation.dart';

class AddSymptomScreen extends StatefulWidget {
  const AddSymptomScreen({super.key});

  @override
  State<AddSymptomScreen> createState() => _AddSymptomScreenState();
}

class _AddSymptomScreenState extends State<AddSymptomScreen> {
  List<int> userActiveSymptoms = [];
  final SymptomController symptomController = SymptomController();

  final Map<int, bool> _selectedSymptoms = {
    1: false,
    2: false,
    3: false,
    4: false,
    5: false,
    6: false,
    7: false,
    8: false,
  };

  @override
  void initState() {
    super.initState();
    _loadUserSymptoms();
  }

  Future<void> _loadUserSymptoms() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    final symptoms = await symptomController.getSymptomsActiveID(user!.userID);

    setState(() {
      userActiveSymptoms = symptoms;
      for (int id in userActiveSymptoms) {
        _selectedSymptoms[id] = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Add New Symptom'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How are you feeling today?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            const Text(
              'Select any symptoms you’re currently experiencing. This helps us monitor your condition better.',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Scrollbar(
                thumbVisibility: true, // Always show scrollbar
                thickness: 6, // Optional: make scrollbar more visible
                radius: const Radius.circular(8),
                child: ListView(
                  children: [
                    _buildSymptomTile(
                      id: 1,
                      title: 'Chest Pain',
                      description:
                      'Tightness, pressure, or discomfort in the chest, especially during activity or stress.',
                    ),
                    _buildSymptomTile(
                      id: 2,
                      title: 'Shortness of Breath',
                      description:
                      'Difficulty breathing during activity, rest, or at night.',
                    ),
                    _buildSymptomTile(
                      id: 3,
                      title: 'Unexplained Fatigue',
                      description:
                      'Feeling tired or drained without a clear reason.',
                    ),
                    _buildSymptomTile(
                      id: 4,
                      title: 'Heart Palpitations',
                      description:
                      'Racing, skipping, or pounding heartbeat without obvious cause.',
                    ),
                    _buildSymptomTile(
                      id: 5,
                      title: 'Dizziness or Fainting',
                      description:
                      'Sudden light-headedness, unsteadiness, or blacking out.',
                    ),
                    _buildSymptomTile(
                      id: 6,
                      title: 'Swelling in Legs or Ankles',
                      description:
                      'Noticeable puffiness in the lower limbs or tight shoes.',
                    ),
                    _buildSymptomTile(
                      id: 7,
                      title: 'Radiating Pain',
                      description:
                      'Pain spreading to your arm, neck, jaw, or back.',
                    ),
                    _buildSymptomTile(
                      id: 8,
                      title: 'Cold Sweats & Nausea',
                      description:
                      'Sudden sweating with queasiness, sometimes with discomfort.',
                    ),
                  ],
                ),
              )
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _onSubmit(user!.userID),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text('Add Symptoms'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onSubmit(int userId) async {
    final selectedIds = _selectedSymptoms.entries
        .where((entry) => entry.value && !userActiveSymptoms.contains(entry.key))
        .map((entry) => entry.key)
        .toList();

    print (selectedIds);

    if (selectedIds.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('No Symptoms Selected'),
          content: const Text('Please select at least one symptom before submitting.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    } else {
      bool symptomActive = true;
      AppPopup.showLoading(context, message: 'Processing...');

      try {
        final result = await symptomController.addSymptom(userId, selectedIds, symptomActive);

        if (result == true){
          AppPopup.hide(context);
          AppPopup.showResult(
            context,
            isSuccess: true,
            message: "Successfully Added!",
            onDismiss: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const MainNavigationScreen(selectedIndex: 2)),
              );
            },
          );
        }
        else {
          AppPopup.hide(context);
          AppPopup.showResult(
            context,
            isSuccess: false,
            message: "Failed to add symptoms.",
          );
        }
      } catch (e) {
        AppPopup.hide(context);
        AppPopup.showResult(
          context,
          isSuccess: false,
          message: "Error: ${e.toString()}",
        );
      }
    }
  }

  Widget _buildSymptomTile({
    required int id,
    required String title,
    required String description,
  }) {
    final isAlreadyLogged = userActiveSymptoms.contains(id);

    return Card(
      color: Colors.grey[100],
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            description,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ),
        trailing: Checkbox(
          value: _selectedSymptoms[id],
          onChanged: isAlreadyLogged
              ? null // disable the checkbox if already logged
              : (bool? value) {
            setState(() {
              _selectedSymptoms[id] = value ?? false;
            });
          },
        ),
        onTap: isAlreadyLogged
            ? null
            : () {
          setState(() {
            _selectedSymptoms[id] = !_selectedSymptoms[id]!;
          });
        },
      ),
    );
  }
}
