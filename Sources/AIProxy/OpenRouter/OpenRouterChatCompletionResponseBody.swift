//
//  OpenRouterChatCompletionResponseBody.swift
//  AIProxy
//
//  Created by Lou Zell on 12/30/24.
//

import Foundation

public struct OpenRouterChatCompletionResponseBody: Decodable {
    /// A list of chat completion choices.
    /// Can be more than one if `n` on `OpenRouterChatCompletionRequestBody` is greater than 1.
    public let choices: [Choice]

    /// The Unix timestamp (in seconds) of when the chat completion was created.
    public let created: Int?

    public let id: String?

    /// The model used for the chat completion.
    public let model: String?

    /// The provider used to fulfill the chat completion.
    public let provider: String?

    /// Usage statistics for the completion request.
    public let usage: Usage?

    private enum CodingKeys: String, CodingKey {
        case choices
        case created
        case id
        case model
        case provider
        case usage
    }
}

// MARK: - ResponseBody.Usage
extension OpenRouterChatCompletionResponseBody {
    public struct Usage: Decodable {
        /// Number of tokens in the generated completion.
        public let completionTokens: Int?

        /// Number of tokens in the prompt.
        public let promptTokens: Int?

        /// Total number of tokens used in the request (prompt + completion).
        public let totalTokens: Int?

        private enum CodingKeys: String, CodingKey {
            case completionTokens = "completion_tokens"
            case promptTokens = "prompt_tokens"
            case totalTokens = "total_tokens"
        }
    }
}

// MARK: - ResponseBody.Choice
extension OpenRouterChatCompletionResponseBody {
    public struct Choice: Decodable {
        /// The reason the model stopped generating tokens. This will be `stop` if the model hit a
        /// natural stop point or a provided stop sequence, `length` if the maximum number of
        /// tokens specified in the request was reached, `content_filter` if content was omitted
        /// due to a flag from our content filters, `tool_calls` if the model called a tool, or
        /// `function_call` (deprecated) if the model called a function.
        public let finishReason: String?

        /// A chat completion message generated by the model.
        public let message: Message

        public let nativeFinishReason: String?

        private enum CodingKeys: String, CodingKey {
            case finishReason = "finish_reason"
            case message
            case nativeFinishReason = "native_finish_reason"
        }
    }
}

extension OpenRouterChatCompletionResponseBody.Choice {
    public struct Message: Decodable {
        /// The contents of the message.
        public let content: String?

        /// Reasoning models such as R1 will populate this field with the reasoning used to arrive at `content`
        public let reasoning: String?

        /// The role of the author of this message.
        public let role: String?

        /// The tool calls generated by the model, such as function calls.
        public let toolCalls: [ToolCall]?

        private enum CodingKeys: String, CodingKey {
            case content
            case reasoning
            case role
            case toolCalls = "tool_calls"
        }
    }
}

// MARK: - ResponseBody.Choice.Message.ToolCall
extension OpenRouterChatCompletionResponseBody.Choice.Message {
    public struct ToolCall: Decodable {
        /// The function that the model instructs us to call
        public let function: Function?

        public let id: String?

        public let index: Int?

        /// The type of the tool. Currently, only `function` is supported.
        public let type: String?
    }
}

// MARK: - ResponseBody.Choice.Message.ToolCall.Function
extension OpenRouterChatCompletionResponseBody.Choice.Message.ToolCall {
    public struct Function: Decodable {
        /// The name of the function to call.
        public let name: String

        /// The arguments to call the function with.
        public let arguments: [String: Any]?

        /// The raw arguments string, unmapped to a `[String: Any]`. The unmapped string is useful for
        /// continuing the converstation with the model. The model expects you to feed the raw argument string
        /// back to the model on susbsequent requests.
        public let argumentsRaw: String?

        private enum CodingKeys: CodingKey {
            case name
            case arguments
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.name = try container.decode(String.self, forKey: .name)
            if let argumentsRaw = try? container.decode(String.self, forKey: .arguments) {
                self.argumentsRaw = argumentsRaw
                self.arguments = (try [String: AIProxyJSONValue].deserialize(from: argumentsRaw)).untypedDictionary
            } else {
                self.argumentsRaw = nil
                self.arguments = nil
            }
        }
    }
}
