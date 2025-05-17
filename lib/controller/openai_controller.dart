import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OpenAIService {
  final String openaiApiKey = dotenv.env['OPENAI_KEY'] ?? '';

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
        "name": "handle_general_app_info_question",
        "description": "Handles general inquiries about the HeartCare app, including greetings, acknowledgments (e.g., 'Hello', 'Thank you'), and questions regarding the app's purpose, features, and functionality. This includes explanations of core features such as Cardiovascular Disease (CVD) risk level detection, health readings (Blood Pressure, Blood Sugar, Cholesterol Level, and BMI), treatment tracking and planning, and symptom tracking and logging.",
        "parameters": {
          "type": "object",
          "properties": {
            "content": {
              "type": "string",
              "description": "The user's general inquiry about HeartCare application or interaction."
            }
          },
          "required": ["content"]
        }
      },
      {
        "name": "handle_user_health_question",
        "description": "Handles user questions, concerns, or statements specifically related to cardiovascular health. This includes symptoms, risk factors, lifestyle impacts, preventive measures, or conditions caused by or related to heart disease. The function is tailored to provide guidance, educational insights, and relevant app support for heart-related health concerns.",
        "parameters": {
          "type": "object",
          "properties": {
            "content": {
              "type": "string",
              "description": "The user's health-related question or statement."
            }
          },
          "required": ["content"]
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
      'model': 'gpt-4o-mini-2024-07-18',
      "messages": [
        {"role": "system", "content": systemPrompt},
        {"role": "user", "content": content}
      ],
      "functions": tools,
      "function_call": "auto"
    };

    try {
      // Send the API request
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $openaiApiKey',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final responseMessage = responseData['choices'][0]['message'];

        // Check if a function was called
        if (responseMessage.containsKey('function_call')) {
          final String functionName = responseMessage['function_call']['name'];
          final Map<String, dynamic> functionArguments = jsonDecode(responseMessage['function_call']['arguments']);

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
    String prompt = """
    You are a knowledgeable and concise assistant dedicated to answering questions about the HeartCare app. 
    
    - If the user's question is about the app's features, purpose, or functionality, provide a clear, concise, and accurate response.  
    - If the question is unrelated to the app, politely redirect the user to focus on HeartCare-related inquiries.  
    - If the user is engaging in casual interaction rather than asking a question, respond in a friendly and conversational manner to maintain a natural user experience.  
    
    Note: The format of your answer must be concise and clear. Avoid over-explain to the user questions.

    User's question: "$content"
    """;


    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $openaiApiKey',
      },
      body: json.encode({
        'model': 'gpt-4o-mini-2024-07-18',
        'messages': [{'role': 'system', 'content': prompt}],
      }),
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      return responseBody['choices'][0]['message']['content'];
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
      
      Keep your responses concise, more shorter and directly on topic.
      
      The user asked: "$content"
      """;

    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $openaiApiKey',
      },
      body: json.encode({
        'model': 'gpt-4o-mini-2024-07-18',
        'messages': [{'role': 'system', 'content': prompt}],
      }),
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      return responseBody['choices'][0]['message']['content'];
    } else {
      return 'Error in fetching response from OpenAI.';
    }
  }

}
