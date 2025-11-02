package com.example.floweridentifier.data.repository.openai

import com.example.floweridentifier.data.model.Message

interface OpenAiDataSource {
    fun generatePersonalInfoPrompt(): List<Message>

    suspend fun executeCompletionRequest(
        prompt: String,
        temperature: Double? = null,
        topP: Double? = null,
        maxTokens: Int,
        stop: List<String>,
        presencePenalty: Double,
        frequencyPenalty: Double
    ): Message?

    /**
     * Generate a new message for the "Factual answering" use case. This prompt helps guide the model towards
     * factual answering by showing it how to respond to questions that fall outside its knowledge base. Using a '?'
     * to indicate a response to words and phrases that it doesn't know provides a natural response that seems to
     * work better than more abstract replies.
     *
     * @param messageHistory: The list of messages to include in the request.
     * @return The generated message.
     */
    suspend fun fetchChatAIAssistantMessage(messagesHistory: List<Message>): Message?

    suspend fun generateAnswerMessage(
        messagesHistory: List<Message>
    ): Message?
}