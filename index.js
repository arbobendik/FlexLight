"use strict";

import express from 'express';

const app = express(); // Create Express app instance.

// Set up static middleware to serve files from the "/public" directory.
app.use("/public", express.static("/public"));

// Define the port on which the server will listen.
const PORT = 3000;

// Start the server.
app.listen(PORT, () => {
  console.log("Server is running on port " + PORT);
});

app.get("/", (_req, res) => {
  res.sendFile(__dirname + "/index.html");
});
