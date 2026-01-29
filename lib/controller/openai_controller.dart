import 'dart:convert';
import 'dart:io';
import 'package:heartcare/controller/treatment_controller.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../database_service.dart';
import '../model/treatment_model.dart';

class OpenAIService {
  final db = DatabaseConnection();
  final String openaiApiKey = dotenv.env['OPENAI_KEY'] ?? '';
  final TreatmentController treatmentController = TreatmentController();
  DateTime _currentDate = DateTime.now();


  OpenAIService() {
    if (openaiApiKey.isEmpty) {
      throw Exception("OpenAI API key is missing. Please check your .env file.");
    }
  }

  // Main conversation logic
  Future<String> runConversation(String content) async {
    // Define the tools
    final List<Map<String, dynamic>> tools = [
      {
        "type": "function",
        "name": "handle_general_app_info_question",
        "description": "Handles general inquiries about the HeartCare app, including greetings, acknowledgments (e.g., 'Hello', 'Thank you'), and questions regarding the app's purpose, features, and functionality. This includes explanations of core features such as Cardiovascular Disease (CVD) risk level detection, health readings (Blood Pressure, Blood Sugar, Cholesterol Level, and BMI), treatment tracking and planning, and symptom tracking and logging.",
        "strict": true,
        "parameters": {
          "type": "object",
          "properties": {
            "content": {
              "type": "string",
              "description": "The user's general inquiry about HeartCare application or interaction."
            }
          },
          "required": ["content"],
          "additionalProperties": false
        }
      },
      {
        "type": "function",
        "name": "handle_user_health_question",
        "description": "Handles user questions, concerns, or statements specifically related to cardiovascular health. This includes symptoms, risk factors, lifestyle impacts, preventive measures, or conditions caused by or related to heart disease. The function is tailored to provide guidance, educational insights, and relevant app support for heart-related health concerns.",
        "strict": true,
        "parameters": {
          "type": "object",
          "properties": {
            "content": {
              "type": "string",
              "description": "The user's health-related question or statement."
            }
          },
          "required": ["content"],
          "additionalProperties": false
        }
      },
    ];

    // System prompt to guide function usage
    const String systemPrompt = """
    You are a chatbot for the HeartCare mobile app, designed to assist users with health management, symptom tracking, medication reminders, and general app-related inquiries.
    
    Follow these rules:
    1. Use the 'handle_general_app_info_question' function for general app-related queries, greetings, and casual interactions. This includes questions about the app's purpose, features, and functionality.
    2. Use the 'handle_user_health_question' function when the user asks about or expresses concerns related to heart health, symptoms, risk factors, clinical readings, or cardiovascular disease.
    3. Only call a function if the user's request is relevant to it. If no function is applicable, respond conversationally without invoking a function.
    """;

    // Prepare the request payload for OpenAI API
    final Map<String, dynamic> payload = {
      "model": "gpt-4.1-mini-2025-04-14",
      "input": [
        {"role": "system", "content": systemPrompt},
        {"role": "user", "content": content}
      ],
      "tools": tools,
      "tool_choice": "auto"
    };

    try {
      // Send the API request
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/responses'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $openaiApiKey',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        // print('Raw API response: ${response.body}');
        final responseData = jsonDecode(response.body);
        // print (responseData);
        final responseMessage = responseData['output'][0];

        // Check if a function was called
        if (responseMessage['type'] == 'function_call' && responseMessage['status'] == 'completed') {
          final String functionName = responseMessage['name'];
          final Map<String, dynamic> functionArguments = jsonDecode(responseMessage['arguments']);

          // Debugging: Print function name and arguments
          print('Function called: $functionName');
          print('Function arguments: ${jsonEncode(functionArguments, toEncodable: (e) => e.toString())}');

          // Map functions to their implementations
          final Map<String, Function> availableFunctions = {
            "handle_general_app_info_question": handleGeneralAppInfoQuestion,
            "handle_user_health_question": handleUserHealthQuestion,
          };

          // Call the selected function if available
          if (availableFunctions.containsKey(functionName)) {
            return availableFunctions[functionName]!(functionArguments['content']);
          }
        }
        // Default response if no function call
        return "I'm sorry, I can only assist with questions related to the app's features and functionalities only.";

      } else {
        // Handle HTTP errors
        return "Error: ${response.statusCode} - ${response.reasonPhrase}";
      }
    } catch (e) {
      // Handle network or other errors
      return "An error occurred: $e";
    }
  }

  // Function to handle general app info questions
  Future<String> handleGeneralAppInfoQuestion(String content) async {
    final List<Map<String, dynamic>> tools = [{
      "type": "file_search",
      "vector_store_ids": ["vs_68317c10b754819182b9a0595525f21d"],
    }];

    String prompt = """
    You are a knowledgeable and concise assistant dedicated to answering questions about the HeartCare app. 
    
    - If the user's question is about the app's features, purpose, or functionality, provide a clear, concise, and accurate response.  
    - If the question is unrelated to the app, politely redirect the user to focus on HeartCare-related inquiries.  
    - If the user is engaging in casual interaction rather than asking a question, respond in a friendly and conversational manner to maintain a natural user experience.  
    
    Note for you: 
    - Provide answers in a concise and clear format. 
    - Do not use emojis, font styles (e.g., bold, italics), or other visual embellishments.
    - Avoid over-explaining user questions; keep responses focused and to the point.

    User's question: "$content"
    """;


    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/responses'),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $openaiApiKey',
      },
      body: json.encode({
        "model": "gpt-4.1-mini-2025-04-14",
        "input": [{"role": "system", "content": prompt}],
        "tools": tools,
        "tool_choice": "required"
      }),
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);

      // Find the first output with a 'content' list containing type = output_text
      final output = responseBody['output']?.firstWhere(
            (item) => item['type'] == 'message' && item['content'] != null,
        orElse: () => null,
      );

      if (output != null) {
        final contentList = output['content'];
        final textItem = contentList.firstWhere(
              (item) => item['type'] == 'output_text',
          orElse: () => null,
        );
        if (textItem != null) {
          return textItem['text'];
        }
      }

      return 'No valid text response found.';
    } else {
      return 'Error in fetching response from OpenAI.';
    }
  }

  // Function to handle user health questions
  Future<String> handleUserHealthQuestion(String content) async {
    String prompt = """
      You are a knowledgeable, compassionate assistant dedicated to helping users understand and manage their cardiovascular health.
      
      - When the user expresses stress, anxiety, or emotional distress about their heart, respond with calm, empathetic support.
      - Provide evidence‑based information and practical self‑care suggestions without over‑promising outcomes.
      - Always reassure the provided answers is AI generated and best for user to consult a qualified healthcare professional for personalized diagnosis or treatment.
      - Focus exclusively on heart‑related symptoms and treatments (medication, supplements, diet, physical activity).
      
      Note for you: 
      - Provide answers in a concise and clear format. 
      - Do not use emojis, font styles (e.g., bold, italics), or other visual embellishments.
      - Avoid over-explaining user questions; keep responses focused and to the point.
      
      The user asked: "$content"
      """;

    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/responses'),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $openaiApiKey',
      },
      body: json.encode({
        "model": "gpt-4.1-mini-2025-04-14",
        "input": [{"role": "system", "content": prompt}],
      }),
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      return responseBody['output'][0]['content'][0]['text'];
    } else {
      return 'Error in fetching response from OpenAI.';
    }
  }

  Future<String> getAITreatment(int userID, Map<String, Map<String, String>> cvdPresences, Map<String, String> activeSymptoms, String detectionValue) async {
    final List<Map<String, dynamic>> tools = [{
      "type": "file_search",
      "vector_store_ids": ["vs_6831df8add9881919d7de3444ce3e071"],
    }];
    if (db.isConnected) {
      try {
        // 1. Get current treatments
        final timelines = await treatmentController.getTreatment("Treatment", userID, _currentDate);

        // 2. Convert each data into a String text for Prompting
        String treatmentList = await readableTreatmentList(timelines); // Format user treatment into readable string
        String cvdPresencesList = await readableCVDPresencesList(cvdPresences); // Format cvdPresences into readable string
        String activeSymptomsList = await readableSymptomsList(activeSymptoms); // Format activeSymptoms into readable string
        String cvdLevelDetection = await readableCVDDetectionLevel(detectionValue); // Format CVD Risk level detection into a readable string

        // 3. Define the prompt
        String prompt = """
        You are an AI healthcare assistant specialized in cardiovascular disease (CVD) management.
        
        Your task is to generate **personalized treatment recommendations** for a patient based on the following context. The treatments can be of four types only: **Medication, Supplement, Diet, or Physical Activity**.
        
        ### FORMAT:
        All outputs must strictly follow the **JSON format** shown below. Do not include any explanations or text outside the JSON.
        
        $treatmentSchema
        
        ### CONTEXT (to analyze in the following order):
        1. **Current Treatment Plan** — Avoid suggesting duplicate or redundant treatments. Do not recommend treatments that conflict with the user’s existing treatment regimen.
        $treatmentList
        
        2. **CVD Risk Factors** — Understand what specific cardiovascular risks (e.g., hypertension, diabetes) are present. This should inform the choice of treatment.
        $cvdPresencesList
        
        3. **Active Symptoms** — Suggest treatments that may help manage or reduce these symptoms, if medically appropriate.
        $activeSymptomsList
        
        4. **CVD Risk Score** — Risk status indicating the user's current cardiovascular risk level.
        $cvdLevelDetection
        
        5. **Research Source (PDFs)** — You have access to two academic PDF documents via a file search tool. Use them to identify possible evidence-based treatments (medications or supplements) that are suitable for the user based on their risk factors and symptoms. Prioritize treatments mentioned in these documents over generic suggestions.

        
        ### INSTRUCTIONS:
        - Tailor the treatment suggestions **based on the combination of context above**.
        - Suggest **0, 1, or more treatments per time of day** (Morning, Afternoon, Evening, Night) as needed.
        - You do NOT need to fill all time slots — only suggest treatments when necessary or beneficial.
        - Use **realistic dosages, units, and scheduling** based on standard practices.
        - Base your recommendations only on evidence or studies found in the Research Source (PDFs) unless absolutely necessary.
        - Only return a valid JSON array (a list of JSON objects). Do not include any explanation, comments, or text outside the JSON.
        """;

        // 4. Send request to OpenAI
        final response = await http.post(
          Uri.parse('https://api.openai.com/v1/responses'),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader: 'Bearer $openaiApiKey',
          },
          body: json.encode({
            "model": "gpt-4.1-mini-2025-04-14",
            "input": [{"role": "system", "content": prompt}],
            "tools": tools,
            "tool_choice": "required",
            'temperature': 0.2, // Reduce randomness to ensure consistent recommendations
          }),
        );

        // 5. Handle and return the response
        if (response.statusCode == 200) {
          final responseBody = json.decode(response.body);

          // Find the first output with a 'content' list containing type = output_text
          final output = responseBody['output']?.firstWhere(
                (item) => item['type'] == 'message' && item['content'] != null,
            orElse: () => null,
          );

          if (output != null) {
            final contentList = output['content'];
            final textItem = contentList.firstWhere(
                  (item) => item['type'] == 'output_text',
              orElse: () => null,
            );
            if (textItem != null) {
              return textItem['text'];
            }
          }

          return 'No valid text response found.';
        }else {
          return 'Error in fetching response from OpenAI.';
        }
      } catch (e) {
        print('Exception in getAITreatment: $e');
        return 'An unexpected error occurred: $e';
      }
    } else {
      return 'Database is not connected.';
    }
  }

  Future<String> readableTreatmentList (List<TreatmentTimeline> timelines) async {
    String treatmentText = "";
    if (timelines.isNotEmpty){
      treatmentText = "User's current treatment Plan:\n";
      for (var timeline in timelines) {
        treatmentText += "\n${timeline.name} (${timeline.timeRange}):\n";

        if (timeline.treatments.isEmpty) {
          treatmentText += "- No treatments.\n";
          continue;
        }

        for (var treatment in timeline.treatments) {
          String medicationDetails = "";
          if (treatment.treatmentCategory == "Medication" || treatment.treatmentCategory == "Supplement") {
            medicationDetails =
            " | Dosage: ${treatment.dosage ?? '-'} ${treatment.unit ?? ''}, "
                "Sessions: ${treatment.sessionCount ?? '-'}, "
                "Type: ${treatment.medicationType ?? '-'}";
          }
          treatmentText +=
          "- ${treatment.name} (${treatment.treatmentCategory}) ${medicationDetails.isNotEmpty ? medicationDetails : ""}\n";

          if ((treatment.notes ?? "").trim().isNotEmpty) {
            treatmentText += "  Notes: ${treatment.notes}\n";
          }
        }
      }
    }
    return treatmentText;
  }

  Future<String> readableCVDPresencesList (Map<String, Map<String, String>> cvdPresences) async {
    String cvdPresenceText = "User's CVD Risk Factors:\n";
    cvdPresences.forEach((riskName, details) {
      String status = details['status'] ?? 'Unknown';
      cvdPresenceText += "- $riskName: $status \n";
    });

    return cvdPresenceText;
  }

  Future<String> readableSymptomsList (Map<String, String> activeSymptoms) async {
    String symptomText = "User's current active symptoms:\n";
    activeSymptoms.forEach((symptomName, lastUpdated) {
      symptomText += "- $symptomName\n";
    });

    return symptomText;
  }

  Future<String> readableCVDDetectionLevel (String detectionValue) async {
    String cvdLevelText = "User's CVD Risk Score: $detectionValue\n";
    return cvdLevelText;
  }

  String treatmentSchema = """ 
  {
    "category": "Must be one of: 'Medication', 'Supplement', 'Diet', or 'Physical Activity'.",
    "name": "Name of the treatment (e.g., Atorvastatin, Morning Walk, Low-sodium diet)",
    "dosage": "REQUIRED ONLY IF category is 'Medication' or 'Supplement'. Must be a numeric value (e.g., 10). MUST BE LEFT BLANK for 'Diet' or 'Physical Activity'.",
    "unit": "REQUIRED ONLY IF category is 'Medication' or 'Supplement'. Must be one of: 'mg', 'ml', 'g', or 'IU'. MUST BE LEFT BLANK for 'Diet' or 'Physical Activity'.",
    "quantity": "REQUIRED ONLY IF category is 'Medication' or 'Supplement'. Must be an integer (e.g., 1, 2, 3). MUST BE LEFT BLANK for 'Diet' or 'Physical Activity'.",
    "type": "REQUIRED ONLY IF category is 'Medication' or 'Supplement'. Must be one of: 'Tablet', 'Capsule', 'Liquid', 'Injection'. MUST BE LEFT BLANK for 'Diet' or 'Physical Activity'.",
    "description": "Really short explanation or purpose of the treatment",
    "timesOfDay": ["List the exact times of day this treatment applies to. Allowed values: 'Morning', 'Afternoon', 'Evening', 'Night'. MUST be a non-empty array of valid values."]  
  }
  """;

}
