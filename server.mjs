"use strict";

import express from "express"; // Import Express module.

// create web-app
const app = express();
// prefer environment over fallback
const port = isNaN(process.env.port)? 3000 : parseInt(process.env.port);

// serve static files from the public directory
app.use(express.static('public'));

// redirect empty requests
app.get("/", (_req, res) => {
  res.redirect('view.html?v=example1');
});

// start the server
app.listen(port, () => {
  console.log(`Server is listening on port ${port}`);
});
