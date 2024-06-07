/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

import { onCall, onRequest, HttpsError } from "firebase-functions/v2/https";
const { logger } = require("firebase-functions/v2");

// import * as logger from "firebase-functions/logger";
// const functions = require("firebase-functions");
// const axios = require("axios");
// const cors = require("cors")({ origin: true });

// Start writing functions
// https://firebase.google.com/docs/functions/typescript
const admin = require("firebase-admin");
admin.initializeApp();

exports.helloWorldHttp = onRequest((request, response) => {
  // Message text passed from the client.
  logger.info("Hello logs!", { structuredData: true });
  response.send("Hello from Firebase!!");
});

exports.helloWorld = onCall({ secrets: ["OPENAI"] }, (request) => {
  if (request.app) {
    return request.app;
  }

  // Authentication / user information is automatically added to the request.
  //   if (request.auth) {
  //     const uid = request.auth.uid || null;
  //     const name = request.auth.token.name || null;
  //     const picture = request.auth.token.picture || null;
  //     const email = request.auth.token.email || null;
  //   }

  let apiKeyIn = "API NOT IN";
  if (process.env.OPENAI) {
    apiKeyIn = "API KEY LOADED FROM SECRET MANAGER";
  }

  return "Hello, callable world!!!!" + apiKeyIn;
});

import OpenAI from "openai";

exports.animalChat = onCall({ secrets: ["OPENAI"] }, async (request) => {
  // Authentication / user information is automatically added to the request.
  if (!request.auth || !request.auth.uid) {
    throw new HttpsError("failed-precondition", "Log in to use this function");
  }

  //   check appcheck

  // validate input
  if (!request.data.messages) {
    throw new HttpsError(
      "failed-precondition",
      "The Animal Chat function must be called with a messages argument"
    );
  }
  if (!Array.isArray(request.data.messages)) {
    throw new HttpsError(
      "invalid-argument",
      "The 'messages' argument must be an array."
    );
  }

  // request.data.messages.forEach((message: any) => {
  //   if (typeof message !== "object" || !message.role || !message.content) {
  //     throw new HttpsError(
  //       "invalid-argument",
  //       "Each message in the 'messages' array must be an object with 'role' and 'content' properties."
  //     );
  //   }
  //   if (
  //     typeof message.role !== "string" ||
  //     typeof message.content !== "string"
  //   ) {
  //     throw new HttpsError(
  //       "invalid-argument",
  //       "The 'role' and 'content' properties of each message must be strings."
  //     );
  //   }
  // });

  const openai = new OpenAI({
    apiKey: process.env.OPENAI,
  });

  try {
    const chatCompletion = await openai.chat.completions.create({
      messages: request.data.messages,
      model: "gpt-4o",
    });
    const response = chatCompletion.choices[0].message.content;
    return response;
  } catch (error) {
    logger.error("Authentication or API call error: ", error);
    throw new HttpsError("internal", "Error processing your request: " + error);
  }
});
