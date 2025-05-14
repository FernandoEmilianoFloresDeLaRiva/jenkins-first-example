const express = require("express");
const helmet = require("helmet");

const app = express();
app.use(helmet());
app.use(express.json());

app.get("/health", (_req, res) => {
  res
    .status(200)
    .json({
      status: "SERVER UP",
      timestamp: new Date().toISOString(),
      author: "Fernando Emiliano Flores De La Riva",
    });
});

app.get("/tasks", (_req, res) => {
  res.status(200).json({
    tasks: [
      { id: 1, title: "Task 1 for staging", description: "Description 1 for staging" },
      { id: 2, title: "Task 2 for staging", description: "Description 2 for staging" },
      { id: 3, title: "Task 3 for staging", description: "Description 3 for staging" },
    ],
  });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Healthcheck service running on port ${PORT}`);
});
