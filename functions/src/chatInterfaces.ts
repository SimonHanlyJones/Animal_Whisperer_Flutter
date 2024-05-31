export interface AIMessage {
  role: "user" | "assistant" | "system";
  content: string;
}

// export interface ChatCompletionRequest {
//   model: string;
//   messages: AIMessage[];
//   max_tokens?: number;
//   temperature?: number;
//   top_p?: number;
//   frequency_penalty?: number;
//   presence_penalty?: number;
// }
