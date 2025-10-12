package com.example.floweridentifier.data.repository.openai

import com.aallam.openai.api.BetaOpenAI
import com.aallam.openai.api.chat.ChatCompletion
import com.aallam.openai.api.chat.ChatCompletionRequest
import com.aallam.openai.api.chat.ChatMessage
import com.aallam.openai.api.chat.ChatRole
import com.aallam.openai.api.http.Timeout
import com.aallam.openai.api.model.ModelId
import com.aallam.openai.client.OpenAI
import com.aallam.openai.client.OpenAIConfig
import com.aallam.openai.client.OpenAIHost
import com.example.floweridentifier.data.model.Message
import com.example.floweridentifier.utils.NetworkConfig
import kotlin.time.Duration.Companion.seconds


class OpenAiData : OpenAiDataSource {
    private val openAI: OpenAI
        get() = OpenAI(
            OpenAIConfig(
                token = NetworkConfig.OPEN_API_KEY,
                timeout = Timeout(socket = 120.seconds),
                host = OpenAIHost.OpenAI
            )
        )

    override fun generatePersonalInfoPrompt(): List<Message> = emptyList()

    @OptIn(BetaOpenAI::class)
    override suspend fun executeCompletionRequest(
        prompt: String,
        temperature: Double?,
        topP: Double?,
        maxTokens: Int,
        stop: List<String>,
        presencePenalty: Double,
        frequencyPenalty: Double
    ): Message? {
        // Return variable
        var message: Message? = null
        println("\n> Getting ada model...")
        val ada = openAI.model(modelId = ModelId("gpt-4o-mini"))
        println(ada)

        println("\n>️ Creating completion...")
        // Create the completion request
        val chatMessage = ChatMessage(
            role = ChatRole.User,
            content = prompt
        )
        val completionRequest = ChatCompletionRequest(
            model = ada.id,
            messages = listOf(chatMessage),
            maxTokens = maxTokens,
            stop = stop,
        )

        // Fetch the completion from GPT-3
        val completion: ChatCompletion = openAI.chatCompletion(completionRequest)

        // Get the message
        if (completion.choices.isNotEmpty()) {
            message = Message(
                NetworkConfig.botUser,
                completion.choices.first().message?.content.toString(),
                completion.created.toLong(),
                completion.id
            )
        }

        return message
    }

    override suspend fun fetchChatAIAssistantMessage(messagesHistory: List<Message>): Message? {
        // Generate the use case prompt
        var prompt = ""

        // Append the personal info to the prompt
        val pesonalInfoPrompt = generatePersonalInfoPrompt()

        if (pesonalInfoPrompt.isNotEmpty()) {
            prompt += "Human: ${pesonalInfoPrompt[0].content}\n"
            prompt += "AI: Ok perfect.\n"
        }

        // Append the chat history to the prompt
        for (message in messagesHistory) {
            prompt += if (message.user.isCurrentUser) "Human:" else "AI:"

            if (message.content.isNotEmpty()) {
                prompt += (message.content + "\n")
            }
        }

        // Execute the request
        return executeCompletionRequest(
            prompt = prompt,
            temperature = null,
            maxTokens = 2048,
            stop = listOf("Human:", "AI:"),
            presencePenalty = 0.6,
            frequencyPenalty = 0.0
        )
    }

    override suspend fun generateAnswerMessage(
        messagesHistory: List<Message>
    ): Message? {
        return fetchChatAIAssistantMessage(messagesHistory)
    }
}