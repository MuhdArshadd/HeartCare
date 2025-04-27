import 'package:flutter/material.dart';

class AddTreatmentPage extends StatefulWidget {
  const AddTreatmentPage({Key? key}) : super(key: key);

  @override
  _AddTreatmentPageState createState() => _AddTreatmentPageState();
}

class _AddTreatmentPageState extends State<AddTreatmentPage> {
  int _selectedCategoryIndex = 0;
  final List<String> _categories = ['Medication', 'Supplement', 'Diet', 'Physical Activity'];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _treatmentDescription = TextEditingController();
  final TextEditingController _dietNameController = TextEditingController();

  String _selectedUnit = 'mg';
  String _selectedType = 'Tablet';

  final Map<String, bool> _timesOfDay = {
    'Morning (6:00 AM - 11:59 AM)': false,
    'Afternoon (12:00 PM - 5:59 PM)': false,
    'Evening (6:00 PM - 8:59 PM)': false,
    'Night (9:00 PM - 5:59 AM)': false,
  };

  final List<IconData> _categoryIcons = [
    Icons.medical_services,  // More appropriate for medication
    Icons.local_pharmacy,         // Better for supplements
    Icons.restaurant_menu,    // More specific for diet
    Icons.directions_run,     // Better for physical activity
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _quantityController.dispose();
    _treatmentDescription.dispose();
    _dietNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Treatment'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionTitle('1. Select Treatment Category'),
            _buildCategorySelector(),
            const SizedBox(height: 24),
            _buildSectionTitle('2. Fill in Treatment Details'),
            _selectedCategoryIndex < 2
                ? _buildMedicationSupplementForm()
                : _buildDietActivityForm(),
            const SizedBox(height: 24),
            _buildSectionTitle('3. Select Time(s) to Take/Do Treatment'),
            _buildTimeSelection(),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Add Treatment',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      height: 100,  // Increased height for better visual
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategoryIndex = index;
              });
            },
            child: Container(
              width: 100,  // Fixed width for consistent sizing
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: _selectedCategoryIndex == index
                    ? Colors.blue.shade700
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
                boxShadow: _selectedCategoryIndex == index
                    ? [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _selectedCategoryIndex == index
                          ? Colors.white.withOpacity(0.2)
                          : Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _categoryIcons[index],
                      size: 20,
                      color: _selectedCategoryIndex == index
                          ? Colors.white
                          : Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _categories[index],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _selectedCategoryIndex == index
                          ? Colors.white
                          : Colors.grey.shade800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMedicationSupplementForm() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: '${_categories[_selectedCategoryIndex]} Name',
                prefixIcon: const Icon(Icons.medication),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _dosageController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Dosage Per Intake',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedUnit,
                    decoration: InputDecoration(
                      labelText: 'Unit',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: ['mg', 'ml', 'g', 'IU'].map((value) {
                      return DropdownMenuItem(value: value, child: Text(value));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedUnit = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Quantity per Session',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: InputDecoration(
                      labelText: 'Type',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: ['Tablet', 'Capsule', 'Liquid', 'Injection'].map((value) {
                      return DropdownMenuItem(value: value, child: Text(value));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _treatmentDescription,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Notes (Optional)',
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDietActivityForm() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _dietNameController,
              decoration: InputDecoration(
                labelText: '${_categories[_selectedCategoryIndex]} Name',
                prefixIcon: Icon(
                  _selectedCategoryIndex == 2 ? Icons.restaurant : Icons.directions_run,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _treatmentDescription,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Notes (Optional)',
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Time(s)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            ..._timesOfDay.entries.map((entry) {
              // Get appropriate icon for each time slot
              IconData icon;
              Color iconColor;

              if (entry.key.contains('Morning')) {
                icon = Icons.wb_sunny;
                iconColor = Colors.orange;
              } else if (entry.key.contains('Afternoon')) {
                icon = Icons.light_mode;
                iconColor = Colors.amber;
              } else if (entry.key.contains('Evening')) {
                icon = Icons.nights_stay;
                iconColor = Colors.indigo;
              } else {
                icon = Icons.bedtime;
                iconColor = Colors.deepPurple;
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: entry.value ? Colors.blue.shade50 : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: entry.value ? Colors.blue.shade200 : Colors.grey.shade200,
                    width: 1,
                  ),
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: entry.value
                          ? iconColor.withOpacity(0.2)
                          : Colors.grey.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: entry.value ? iconColor : Colors.grey,
                    ),
                  ),
                  title: Text(
                    entry.key.split(' (')[0], // Remove the time range from display
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: entry.value ? Colors.blue.shade800 : Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    entry.key.split('(')[1].replaceAll(')', ''), // Just show the time range
                    style: TextStyle(
                      color: entry.value ? Colors.blue.shade600 : Colors.grey.shade600,
                    ),
                  ),
                  trailing: Checkbox(
                    value: entry.value,
                    onChanged: (bool? value) {
                      setState(() {
                        _timesOfDay[entry.key] = value!;
                      });
                    },
                    activeColor: Colors.blue.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      _timesOfDay[entry.key] = !entry.value;
                    });
                  },
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  void _submitForm() {
    if (_selectedCategoryIndex < 2) {
      if (_nameController.text.isEmpty ||
          _dosageController.text.isEmpty ||
          _quantityController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all required fields')),
        );
        return;
      }
    } else {
      if (_dietNameController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a name')),
        );
        return;
      }
    }

    if (!_timesOfDay.values.any((value) => value)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one time of day')),
      );
      return;
    }

    final Map<String, dynamic> treatmentData = {
      'category': _categories[_selectedCategoryIndex],
      'name': _selectedCategoryIndex < 2 ? _nameController.text : _dietNameController.text,
      'dosage': _dosageController.text,
      'unit': _selectedUnit,
      'quantity': _quantityController.text,
      'type': _selectedType,
      'description': _treatmentDescription.text,
      'timesOfDay': _timesOfDay.entries.where((e) => e.value).map((e) => e.key).toList(),
    };

    // For now, print to debug console
    debugPrint('Treatment Data: $treatmentData');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Treatment added successfully')),
    );

    // TODO: send `treatmentData` to backend here

    _clearForm();
  }

  void _clearForm() {
    _nameController.clear();
    _dosageController.clear();
    _quantityController.clear();
    _dietNameController.clear();
    _treatmentDescription.clear();
    setState(() {
      _timesOfDay.updateAll((key, value) => false);
    });
  }
}
