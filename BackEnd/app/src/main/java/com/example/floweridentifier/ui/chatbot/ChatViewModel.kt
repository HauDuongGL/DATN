package com.example.floweridentifier.ui.chatbot

import android.app.Application
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.viewModelScope
import com.example.floweridentifier.data.model.Message
import com.example.floweridentifier.data.repository.Repository
import com.example.floweridentifier.ui.base.BaseViewModel
import com.example.floweridentifier.utils.NetworkConfig
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class ChatViewModel(
    private val repository: Repository,
    application: Application
) : BaseViewModel(application) {

    // List messages
    private val _messagesList = mutableListOf<Message>()
    val messagesList: List<Message> = _messagesList

    // Live data list messages
    private val _messagesListLiveData = MutableLiveData<List<Message>>()
    val messagesListLiveData: LiveData<List<Message>> = _messagesListLiveData

    var isLoading: Boolean = false

    fun getHistories() {
        viewModelScope.launch {
            _messagesList.clear()
            _messagesList.addAll(repository.getMessage(0).reversed())

            // Update the live data
            _messagesListLiveData.value = messagesList.map { it.copy() }
        }
    }

    fun sendMessage(content: String) {
        // Create the message object
        if (isLoading) {
            return
        }

        isLoading = true

        val message = Message(
            NetworkConfig.felixUser,
            content,
            System.currentTimeMillis(),
            System.currentTimeMillis().toString()
        )
        saveMessage(message)
        // Add the message to the list
        _messagesList.add(message)

        // Update the live data
        _messagesListLiveData.value = messagesList.map { it.copy() }

        // Generate answer message using OpenAI
        generateAnswerMessage()
    }

    private fun generateAnswerMessage() {
        // Create a new pending message
        val waitingMessage = Message(
            NetworkConfig.botUser,
            "",
            System.currentTimeMillis(),
            System.currentTimeMillis().toString()
        )

        // Append the waiting message to the list
        _messagesList.add(waitingMessage)
        _messagesListLiveData.value = messagesList.map { it.copy() }

        generateMessage()
    }

    private fun generateMessage() {
        // Create a new coroutine to move the execution off the UI thread
        viewModelScope.launch(Dispatchers.IO) {
            // Sleep for 2 seconds
            // Thread.sleep(3000)

            // Call GPT-3 API to get the new messages depending on the source type
            try {
                val messageContent =
                    repository.generateAnswerMessage(messagesList)

                // Create a new coroutine to move the execution to the main thread
                viewModelScope.launch(Dispatchers.Main) {
                    isLoading = false

                    try {
                        if (messageContent != null) {
                            // Update the content of the last message
                            _messagesList.last().run {
                                content = messageContent.content
                                created = System.currentTimeMillis()
                                saveMessage(this)
                            }
                        } else {
                            // If failure, then remove the last message
                            _messagesList.last().run {
                                content = "Error. Please try again."
                                created = System.currentTimeMillis()
                                saveMessage(this)
                            }
                        }

                        // Update the live data
                        _messagesListLiveData.value = messagesList.map { it.copy() }
                    } catch (e: Exception) {
                        e.printStackTrace()
                    }
                }
            } catch (e: Exception) {
                isLoading = false

                viewModelScope.launch(Dispatchers.Main) {
                    _messagesList.last().content = "Error. Please try again."
                    _messagesListLiveData.value = messagesList.map { it.copy() }
                }
            }
        }
    }

    private fun saveMessage(message: Message) {
        viewModelScope.launch(Dispatchers.Main) {
            repository.addMessage(message)
        }
    }


    fun clearHistories() {
        // Clear messages
        _messagesList.clear()

        // Update the live data
        _messagesListLiveData.value = messagesList.map { it.copy() }

        viewModelScope.launch(Dispatchers.Main) {
            repository.deleteAllMessage()
        }
    }
}