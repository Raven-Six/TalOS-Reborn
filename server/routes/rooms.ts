import express from 'express';
import fs from "fs";
import path from "path";
import { roomsPath } from '../server.js';
import { Room } from '../typings/discordBot.js';
import { removeRoomFromActive, updateRoomFromFile } from './discord.js';

export const roomsRouter = express.Router();

function fetchAllRooms() {
  try {
    const newPath = path.join(roomsPath);
    const files = fs.readdirSync(newPath);
    const data = files
      .filter((file) => file.endsWith(".json"))
      .map((file) => {
        try {
          const filePath = path.join(newPath, file);
          const fileData = fs.readFileSync(filePath, "utf-8");
          
          // Skip empty files
          if (!fileData || fileData.trim() === "") {
            console.warn(`Skipping empty file: ${file}`);
            return null;
          }
          
          // Parse JSON with error handling
          const parsed = JSON.parse(fileData);
          return parsed;
        } catch (fileErr) {
          console.error(`Error processing ${file}:`, fileErr instanceof Error ? fileErr.message : fileErr);
          // Optionally move corrupt files to a backup location
          try {
            const filePath = path.join(newPath, file);
            const backupPath = path.join(newPath, `${file}.corrupt`);
            if (!fs.existsSync(backupPath)) {
              fs.copyFileSync(filePath, backupPath);
              console.log(`Backed up corrupt file to: ${backupPath}`);
            }
          } catch (backupErr) {
            console.error(`Failed to backup corrupt file ${file}:`, backupErr);
          }
          return null;
        }
      })
      .filter((room) => room !== null); // Remove null entries
    return data;
  } catch (err) {
    console.error('Error fetching all rooms:', err);
    throw err;
  }
}

function saveRoom(roomData: Room) {
  try {
    const newPath = path.join(roomsPath);
    const filePath = path.join(newPath, `${roomData._id}.json`);
    const data = JSON.stringify(roomData, null, 4); // Pretty print the JSON
    fs.writeFileSync(filePath, data, "utf-8");
  } catch (err) {
    console.error(err);
    throw err;
  }
  updateRoomFromFile(roomData._id);
}

function fetchRoomById(id: string) {
  try {
    const newPath = path.join(roomsPath);
    const filePath = path.join(newPath, `${id}.json`);
    if (fs.existsSync(filePath)) {
      const fileData = fs.readFileSync(filePath, "utf-8");
      return JSON.parse(fileData);
    } else {
      return null; // or handle the error as needed
    }
  } catch (err) {
    console.error(err);
    throw err;
  }
}

function removeRoomById(id: string) {
  try {
    const newPath = path.join(roomsPath);
    const filePath = path.join(newPath, `${id}.json`);
    fs.rmSync(filePath);
    return true;
  } catch (err) {
    console.error(err);
    throw err;
  }
}

roomsRouter.get('/', (req, res) => {
  const roomData = fetchAllRooms();
  res.send(roomData);
});

roomsRouter.post('/save', (req, res) => {
  const roomData = req.body;
  saveRoom(roomData);
  res.send({ message: "Room saved successfully!" });
});

roomsRouter.get('/:id', (req, res) => {
  const id = req.params.id;
  const roomData = fetchRoomById(id);
  if (roomData) {
    res.send(roomData);
  } else {
    res.status(404).send({ message: "Room not found" });
  }
});

roomsRouter.delete('/:id', (req, res) => {
  const id = req.params.id;
  const roomData = removeRoomById(id);
  removeRoomFromActive(id);
  console.log(roomData);
  if (roomData) {
    res.send({ message: "Room deleted successfully!" });
  } else {
    res.status(404).send({ message: "Room not found" });
  }
});

