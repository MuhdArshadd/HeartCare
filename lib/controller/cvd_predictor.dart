import 'package:tflite_flutter/tflite_flutter.dart';

class CvdPredictor {
  late Interpreter _interpreter;
  bool _isModelLoaded = false;

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/models/cvd_risk_model.tflite');
      _isModelLoaded = true;
    } catch (e) {
      throw Exception("Error loading TFLite model: $e");
    }
  }

  /// Accepts symptom map and CVD risk map, returns 'High Risk' or 'Low Risk'
  Future<String> predictRisk({required Map<String, String> symptoms, required Map<String, Map<String, String>> cvdRisks, required int userAge, required String userGender}) async {
    if (!_isModelLoaded) {
      throw Exception("Model is not loaded yet. Call loadModel() first.");
    }

    // Prepare the input features (expected: exactly 16 features per sample)
    final inputFeatures = _prepareInput(symptoms, cvdRisks, userAge, userGender);
    print (inputFeatures);
    if (inputFeatures.length != 16) {
      throw Exception("Prepared input must contain exactly 16 features.");
    }
    // Wrap input in a batch of size 1 since only expect to have only one input (TensorFlow Lite expects input as 2D: [batch_size, feature_count])
    final input = [inputFeatures]; // Shape: [1, 16] // example : input = [[feature1_sample1, feature2_sample1, ..., feature16_sample1]], // size of 1 with 16 features
    // Allocate space for output prediction (1 output per sample in batch)
    // Here, batch size = 1 and output dimension = 1, so shape is [1, 1]
    final output = List.filled(1 * 1, 0).reshape([1, 1]); // Initialized as [[0]]

    try {
      _interpreter.run(input, output);
      // Extract prediction value from output[0][0]
      // Since batch size = 1, the result is a single float value
      final prediction = output[0][0];
      print (prediction);
      return prediction > 0.02 ? 'High Risk' : 'Low Risk';
    } catch (e) {
      throw Exception("Prediction failed: $e");
    }
  }

  /// Converts symptoms and CVD risk data to 16-element list for model
  List<int> _prepareInput(Map<String, String> symptoms, Map<String, Map<String, String>> cvdRisks, int userAge, String userGender) {

    // Debug print for symptoms map
    print('--- Debug: Raw Symptoms Map ---');
    symptoms.forEach((key, value) {
      print('Symptom: $key => $value');
    });

    // Debug print for cvdRisks map
    print('--- Debug: Raw CVD Risks Map ---');
    cvdRisks.forEach((key, nestedMap) {
      print('Risk Factor: $key');
      nestedMap.forEach((nestedKey, nestedValue) {
        print('  $nestedKey => $nestedValue');
      });
    });

    // Convert symptoms (binary: present = 1.0, not = 0.0)
    final List<String> symptomKeys = [
      'Chest Pain',
      'Shortness of Breath',
      'Unexplained Fatigue',
      'Heart Palpitations',
      'Dizziness or Fainting',
      'Swelling in Legs or Ankles',
      'Radiating Pain',
      'Cold Sweats & Nausea'
    ];

    List<int> symptomInputs = symptomKeys.map((key) {
      return symptoms.containsKey(key) ? 1 : 0;
    }).toList();

    // Extract risk factors
    int age = userAge;
    int gender = userGender.toLowerCase() == 'Male' ? 0 : 1;
    int hypertension = _yesNoToBinary(cvdRisks['Hypertension']?['status']);
    int diabetes = _yesNoToBinary(cvdRisks['Diabetes Mellitus']?['status']);
    int hypercholesterolemia = _yesNoToBinary(cvdRisks['Hypercholesterolemia']?['status']);
    int smoking = _yesNoToBinary(cvdRisks['Smoking']?['status']);
    int familyHistory = _yesNoToBinary(cvdRisks['Family history of CVD']?['status']);
    int obesity = _yesNoToBinary(cvdRisks['Obesity']?['status']);

    // Combine features
    // Must follow the order of
    // [chest pain, shortness breath, fatigue, palpitation, dizziness, swelling, radiating pain, cold sweats, hypertension, hypercholesterolemia, diabetes, smoking, obesity, family history, gender, age)
    // Combine features in proper order

    return [
      ...symptomInputs,                 // 8 symptoms
      hypertension,                    // 9
      hypercholesterolemia,            // 10
      diabetes,                        // 11
      smoking,                         // 12
      obesity,                         // 13
      familyHistory,                   // 14
      gender,                          // 15
      age                              // 16
    ];
  }

  int _yesNoToBinary(String? value) {
    if (value == null) return 0;
    return value.toLowerCase() == 'present' ? 1 : 0;
  }

  void dispose() {
    _interpreter.close();
  }
}
