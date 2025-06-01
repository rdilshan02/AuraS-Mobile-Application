import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

// Import shared widgets
import 'shared_widgets.dart';

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final List<Message> _messages = [];
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  final FocusNode _textFieldFocusNode = FocusNode();
  File? _selectedImage;
  bool _isLoading = false;
  bool _quotaExceeded = false;
  bool _isInputFocused = false;

  // Animation controllers
  late AnimationController _floatingAnimationController;
  late AnimationController _pulseAnimationController;
  late AnimationController _fadeController;
  late AnimationController _slideController;

  // Animations
  late Animation<double> _floatingAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  static const String apiKey = 'AIzaSyDtuMZVCIfAuZBFLuuZob2O3wjlF1vgxjY';
  late GenerativeModel _textModel;
  late GenerativeModel _visionModel;

  @override
  void initState() {
    super.initState();
    _initializeModels();
    _setupFocusListener();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Floating animation for the chatbot image
    _floatingAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _floatingAnimation = Tween<double>(
      begin: 0,
      end: 10,
    ).animate(CurvedAnimation(
      parent: _floatingAnimationController,
      curve: Curves.easeInOut,
    ));

    // Pulse animation for send button
    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseAnimationController,
      curve: Curves.easeInOut,
    ));

    // Fade animation for messages
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    // Slide animation for input area
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    // Start animations
    _floatingAnimationController.repeat(reverse: true);
    _slideController.forward();
    _fadeController.forward();
  }

  void _initializeModels() {
    _textModel = GenerativeModel(
      model: 'models/gemini-2.0-flash',
      apiKey: apiKey,
    );
    _visionModel = GenerativeModel(
      model: 'models/gemini-2.0-flash',
      apiKey: apiKey,
    );
  }

  void _setupFocusListener() {
    _textFieldFocusNode.addListener(() {
      setState(() {
        _isInputFocused = _textFieldFocusNode.hasFocus;
      });

      // Animate pulse when focused
      if (_textFieldFocusNode.hasFocus) {
        _pulseAnimationController.repeat(reverse: true);
      } else {
        _pulseAnimationController.stop();
        _pulseAnimationController.reset();
      }
    });
  }

  @override
  void dispose() {
    _floatingAnimationController.dispose();
    _pulseAnimationController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _textFieldFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const CustomHeader(),
            const CustomNavigationBar(activeRoute: 'Chat Bot'),
            if (_quotaExceeded) _buildQuotaWarning(),

            Expanded(
              child: Stack(
                children: [
                  // Chat messages area
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            controller: _scrollController,
                            reverse: true,
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              final reversedIndex = _messages.length - 1 - index;
                              return _buildAnimatedMessageBubble(_messages[reversedIndex], index);
                            },
                          ),
                        ),
                        if (!_quotaExceeded) _buildAnimatedQuickActions(),
                        _buildAnimatedInputArea(),
                      ],
                    ),
                  ),

                  // Animated floating chatbot image
                  Positioned(
                    top: 50,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: AnimatedBuilder(
                        animation: _floatingAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _floatingAnimation.value),
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 500),
                              opacity: (!_isInputFocused && _messages.isEmpty) ? 1.0 : 0.1,
                              child: AnimatedScale(
                                duration: const Duration(milliseconds: 600),
                                scale: (!_isInputFocused && _messages.isEmpty) ? 1.0 : 0.8,
                                curve: Curves.easeInOut,
                                child: Hero(
                                  tag: 'chatbot_image',
                                  child: Container(
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.2),
                                          blurRadius: 20,
                                          spreadRadius: 5,
                                        ),
                                      ],
                                    ),
                                    child: Image.asset(
                                      'assets/images/chatbot_image.png',
                                      width: 400,
                                      height: 400,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuotaWarning() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      padding: const EdgeInsets.all(12),
      color: Colors.orange[100],
      child: Row(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            builder: (context, value, child) {
              return Transform.rotate(
                angle: value * 0.1,
                child: const Icon(Icons.warning_amber, color: Colors.orange),
              );
            },
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "Service temporarily unavailable due to API quota limits. Please contact support.",
              style: TextStyle(
                color: Colors.orange[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedMessageBubble(Message message, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 100)),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 400),
            opacity: value,
            child: _buildMessageBubble(message),
          ),
        );
      },
    );
  }

  Widget _buildMessageBubble(Message message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: message.isUser
                ? const Color(0xFFE94057).withOpacity(0.1)
                : Colors.grey[200],
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: Radius.circular(message.isUser ? 20 : 4),
              bottomRight: Radius.circular(message.isUser ? 4 : 20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (message.image != null)
                Hero(
                  tag: 'message_image_${message.hashCode}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      message.image!,
                      height: 150,
                      width: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              if (message.image != null) const SizedBox(height: 8),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  color: message.isUser ? const Color(0xFFE94057) : Colors.black,
                  fontSize: 16,
                ),
                child: Text(message.text),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedQuickActions() {
    final quickQuestions = [
      'Dry and flaky skin remedies?',
      'Acne on cheeks treatment?',
      'How to fade dark spots?',
      'Sensitive skin routine?',
    ];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      height: 42,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: quickQuestions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 500 + (index * 100)),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE94057).withOpacity(0.1),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () => _sendMessage(quickQuestions[index]),
                    child: Text(
                      quickQuestions[index],
                      style: const TextStyle(color: Color(0xFFE94057), fontSize: 13),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAnimatedInputArea() {
    return SlideTransition(
      position: _slideAnimation,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(top: 8),
        decoration: BoxDecoration(
          color: Colors.lightBlue[50],
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: _isInputFocused ? Colors.blue[600]! : Colors.blue[900]!,
            width: _isInputFocused ? 2.0 : 1.5,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: IconButton(
                icon: _selectedImage != null
                    ? AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    color: Colors.blue[900],
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(4),
                  child: const Icon(Icons.image, color: Colors.white),
                )
                    : Icon(Icons.image_outlined, color: Colors.blue[700]),
                onPressed: _quotaExceeded ? null : _pickImage,
              ),
            ),
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: TextField(
                  controller: _messageController,
                  focusNode: _textFieldFocusNode,
                  minLines: 1,
                  maxLines: 3,
                  enabled: !_quotaExceeded,
                  decoration: InputDecoration(
                    hintText: _quotaExceeded
                        ? 'Service unavailable'
                        : 'Ask about skin concerns...',
                    hintStyle: TextStyle(color: Colors.blue[700]),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    filled: false,
                  ),
                  style: TextStyle(color: Colors.blue[900]),
                ),
              ),
            ),
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _isInputFocused ? _pulseAnimation.value : 1.0,
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.greenAccent[400],
                      shape: BoxShape.circle,
                      boxShadow: _isInputFocused
                          ? [
                        BoxShadow(
                          color: Colors.greenAccent[400]!.withOpacity(0.4),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ]
                          : [],
                    ),
                    child: IconButton(
                      icon: _isLoading
                          ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Icon(Icons.send, color: Colors.white),
                      onPressed: _quotaExceeded || _isLoading
                          ? null
                          : () {
                        if (_messageController.text.isNotEmpty ||
                            _selectedImage != null) {
                          _sendMessage(_messageController.text);
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _selectedImage = File(image.path));
    }
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty && _selectedImage == null) return;

    final messageText = text.trim();
    final imageToSend = _selectedImage;

    setState(() {
      _messages.add(
        Message(
          text: messageText.isEmpty && imageToSend != null
              ? "Analyze this skin condition"
              : messageText,
          isUser: true,
          image: imageToSend,
        ),
      );
      _messageController.clear();
      _isLoading = true;
      _selectedImage = null;
    });
    _scrollToBottom();

    try {
      final response = await _getGeminiResponse(messageText, imageToSend);
      if (response != null) {
        setState(() {
          _messages.add(Message(text: response, isUser: false));
          _quotaExceeded = false;
        });
      } else {
        throw Exception('No response received from the AI model');
      }
    } catch (e) {
      final errorMessage = _handleApiError(e);
      setState(() {
        _messages.add(Message(text: errorMessage, isUser: false));
        if (e.toString().contains("quota") ||
            e.toString().contains("billing") ||
            e.toString().contains("exceeded")) {
          _quotaExceeded = true;
        }
      });
      print('Chatbot Error: ${e.toString()}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  String _handleApiError(dynamic error) {
    if (error.toString().contains("quota") ||
        error.toString().contains("billing") ||
        error.toString().contains("exceeded")) {
      return "I'm currently unavailable due to API quota limits. "
          "Please contact support to resolve this issue.";
    } else if (error.toString().contains('API key')) {
      return "Authentication error. Please check API configuration.";
    } else if (error.toString().contains('network')) {
      return "Network error. Please check your internet connection.";
    } else if (error.toString().contains('timeout')) {
      return "Request timed out. Please try again.";
    }
    return "Sorry, something went wrong. Please try again later.";
  }

  Future<String?> _getGeminiResponse(String text, File? image) async {
    const systemPrompt = """
      You are a professional dermatology assistant. When responding to skin concerns:
      1. First, analyze the condition briefly
      2. Then, provide 2-3 recommended treatments
      3. List key ingredients to look for in products
      4. Finally, mention when to see a dermatologist
      
      Keep responses clear, concise, and structured with bullet points.
      If the query is not related to skincare, politely redirect to skincare topics.
    """;

    try {
      if (image != null) {
        final imageBytes = await image.readAsBytes();
        final prompt = """
          $systemPrompt
          
          Analyze this skin condition image. User query: 
          ${text.isEmpty ? "Please analyze this skin condition" : text}
          
          Format your response as follows:
          📝 Analysis...
        """;

        final response = await _visionModel.generateContent([
          Content.multi([
            TextPart(prompt),
            DataPart('image/png', imageBytes),
          ]),
        ]);
        return response.text;
      } else {
        final response = await _textModel.generateContent([
          Content.text('$systemPrompt\n\nUser: $text'),
        ]);
        return response.text;
      }
    } catch (e) {
      throw Exception('Error getting Gemini response: ${e.toString()}');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}

class Message {
  final String text;
  final bool isUser;
  final File? image;

  Message({
    required this.text,
    required this.isUser,
    this.image,
  });
}