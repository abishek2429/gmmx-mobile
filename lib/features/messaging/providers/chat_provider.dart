import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String recipientId;
  final String recipientName;
  final String message;
  final bool read;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.recipientId,
    required this.recipientName,
    required this.message,
    required this.read,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      senderId: json['senderId'],
      senderName: json['senderName'],
      recipientId: json['recipientId'],
      recipientName: json['recipientName'],
      message: json['message'],
      read: json['read'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

final chatProvider = StateNotifierProvider.family<ChatNotifier, AsyncValue<List<ChatMessage>>, String>((ref, otherUserId) {
  final dio = ref.watch(dioClientProvider);
  return ChatNotifier(dio, otherUserId);
});

class ChatNotifier extends StateNotifier<AsyncValue<List<ChatMessage>>> {
  final Dio _dio;
  final String _otherUserId;

  ChatNotifier(this._dio, this._otherUserId) : super(const AsyncValue.loading()) {
    fetchMessages();
  }

  Future<void> fetchMessages() async {
    try {
      final response = await _dio.get('/api/chat/conversation/$_otherUserId');
      final List<dynamic> data = response.data['data']['content'];
      final messages = data.map((json) => ChatMessage.fromJson(json)).toList();
      state = AsyncValue.data(messages.reversed.toList()); // Oldest first for list view
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> sendMessage(String text) async {
    try {
      await _dio.post('/api/chat/send', data: {
        'recipientId': _otherUserId,
        'message': text,
      });
      fetchMessages();
    } catch (e) {
      rethrow;
    }
  }
}
