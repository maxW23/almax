import 'package:lklk/core/utils/logger.dart';

import 'package:lklk/core/services/api_service.dart';
import 'package:lklk/features/chat/domain/enitity/home_message_entity.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'dart:convert'; // For jsonEncode and jsonDecode
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bloc/bloc.dart';

enum HomeMessageStatus {
  initial,
  loading,
  loadingDeleteConversation,
  loaded,
  error,
  deleting
}

extension HomeMessageStatusX on HomeMessageStatus {
  bool get isInitial => this == HomeMessageStatus.initial;
  bool get isLoading => this == HomeMessageStatus.loading;
  bool get isLoadingDeleteConversation =>
      this == HomeMessageStatus.loadingDeleteConversation;
  bool get isError => this == HomeMessageStatus.error;
  bool get isLoaded => this == HomeMessageStatus.loaded;
  bool get isDeleting => this == HomeMessageStatus.deleting;
}

@immutable
class HomeMessageState {
  final HomeMessageStatus status;
  final List<HomeMessageEntity>? messages;
  final String? errorMessage;

  const HomeMessageState({
    required this.status,
    this.messages,
    this.errorMessage,
  });

  @override
  int get hashCode =>
      status.hashCode ^ messages.hashCode ^ errorMessage.hashCode;
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HomeMessageState &&
        other.status == status &&
        listEquals(other.messages, messages) &&
        other.errorMessage == errorMessage;
  }

  HomeMessageState copyWith({
    HomeMessageStatus? status,
    List<HomeMessageEntity>? messages,
    String? errorMessage,
  }) {
    return HomeMessageState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

///////////////////////////////////////////////////
///////////////////////////////////////////////////
class HomeMessageCubit extends Cubit<HomeMessageState> {
  HomeMessageCubit()
      : super(const HomeMessageState(status: HomeMessageStatus.initial));

  List<HomeMessageEntity>? _cachedMessages;

  Future<void> fetchLastMessages() async {
    // Emit loading state when fetching messages
    emit(state.copyWith(status: HomeMessageStatus.loading));
    log("Fetching last messages...");

    // Load cached messages from Shared Preferences

    await _loadCachedMessages();
    log("_loadCachedMessages: $_cachedMessages");

    try {
      // Check if cached messages are available
      if (_cachedMessages != null && _cachedMessages!.isNotEmpty) {
        emit(state.copyWith(
            status: HomeMessageStatus.loaded, messages: _cachedMessages));
        log("Emitting cached messages: $_cachedMessages");
      } else {
        log("No cached messages available.");
      }

      // Fetch messages from the API
      final response = await ApiService().get('/usermassage');
      final parsedData = jsonDecode(response.data);
      log("usermassage $parsedData");
      final responseData = parsedData['Massage'];
      final List<HomeMessageEntity> messages = (responseData as List)
          .map((json) =>
              HomeMessageEntity.fromJson(json as Map<String, dynamic>))
          .toList();

      log("API response received: $responseData");

      // Sort messages
      final List<HomeMessageEntity> orderedMessages = [];
      final List<HomeMessageEntity> otherMessages = [];

      log("Sorting messages...");
      for (var message in messages) {
        if (message.senderId == '222') {
          orderedMessages.insert(
              0, message); // Prioritize messages from senderId '222'
        } else {
          otherMessages.add(message);
        }
      }
      orderedMessages.addAll(otherMessages);

      // Cache messages for future use
      _cachedMessages = orderedMessages;
      await _cacheMessages(orderedMessages); // Save to Shared Preferences
      log("Cached messages for future use: $_cachedMessages");

      // Emit the new state with ordered messages
      emit(state.copyWith(
          status: HomeMessageStatus.loaded, messages: orderedMessages));
      log("Messages successfully loaded and emitted.");
    } catch (e) {
      // On error, emit the cached messages if they exist
      if (_cachedMessages != null) {
        emit(state.copyWith(
            status: HomeMessageStatus.loaded,
            messages: _cachedMessages,
            errorMessage: 'Failed to load new messages: $e'));
        log("Error occurred but emitting cached messages: $_cachedMessages");
      } else {
        emit(state.copyWith(
          status: HomeMessageStatus.error,
          errorMessage: 'Failed to load messages: $e',
        ));
        log("Error occurred and no cached messages available: $e");
      }
    }
  }

  Future<void> _cacheMessages(List<HomeMessageEntity> messages) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = messages.map((msg) => msg.toJson()).toList();
    await prefs.setString('cachedMessages', jsonEncode(jsonList));
  }

  Future<void> _loadCachedMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('cachedMessages');
    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      _cachedMessages = jsonList
          .map((json) {
            try {
              return HomeMessageEntity.fromJson(json);
            } catch (e) {
              log("Failed to parse cached message: $e");
              return null; // Return null for invalid entries
            }
          })
          .where((message) => message != null)
          .cast<HomeMessageEntity>()
          .toList(); // Filter out nulls
    }
  }

  Future<void> deleteConversation(String conversationId) async {
    // Emit loading state when deleting conversation
    emit(state.copyWith(status: HomeMessageStatus.loadingDeleteConversation));
    log("Deleting conversation with ID: $conversationId");

    try {
      // Call the API to delete the conversation
      final response = await ApiService().post('/allmsg/$conversationId');

      // Check if the deletion was successful
      if (response.statusCode == 200) {
        log("/allmsg/$conversationId ${response.data}");
        log("Conversation deleted successfully.");

        // Remove the deleted conversation from the cached messages
        if (_cachedMessages != null) {
          // _cachedMessages!.removeWhere((message) => message.id == conversationId);
          // await _cacheMessages(_cachedMessages!); // Update the cache
          _cachedMessages
              ?.removeWhere((m) => m.id.toString() == conversationId);
          await _cacheMessages(_cachedMessages ?? []);
        }

        // Emit the new state with the updated messages
        emit(state.copyWith(
          status: HomeMessageStatus.loaded,
          // messages: _cachedMessages,
          messages: List.of(_cachedMessages ?? []),
        ));
      } else {
        // Handle the case where the deletion failed
        emit(state.copyWith(
          status: HomeMessageStatus.error,
          errorMessage: 'Failed to delete conversation: ${response.statusCode}',
        ));
        log("Failed to delete conversation: ${response.statusCode}");
      }
    } catch (e) {
      // Handle any errors that occur during the deletion process
      emit(state.copyWith(
        status: HomeMessageStatus.error,
        errorMessage: 'Failed to delete conversation: $e',
      ));
      log("Error occurred while deleting conversation: $e");
    }
  }
}
