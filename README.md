# Delegator

A lightweight Flutter-based mobile application for managing tasks with backend integration using PHP and MySQL. This project emphasizes **backend-driven functionality**, including CRUD operations, user management, and dynamic task assignment. It demonstrates modern Flutter development practices combined with a relational database backend.

---

## Table of Contents

- [Project Overview](#project-overview)
- [Features](#features)
- [Architecture](#architecture)
- [Screenshots](#screenshots)
- [Getting Started](#getting-started)
- [Backend Setup](#backend-setup)
- [Frontend Setup](#frontend-setup)
- [API Endpoints](#api-endpoints)
- [Database Schema](#database-schema)
- [Design Decisions](#design-decisions)
- [Future Improvements](#future-improvements)
- [License](#license)

---

## Project Overview

The Task Assignment App allows users to:

- Create, read, update, and delete tasks.
- Assign tasks to users or create new users on the fly.
- Filter tasks by status (`todo`, `in_progress`, `done`).
- View task details with dynamic assignment.
- Use a clean, modern Material 3 interface.

The app is designed for **fast development and educational purposes**, demonstrating full-stack integration of a mobile frontend with a relational backend.

---

## Features

- **Task Management**: CRUD operations for tasks.
- **User Assignment**: Assign tasks to existing users or create a new user during task creation/editing.
- **Status Filtering**: Filter tasks by status using backend-driven queries.
- **Dynamic Backend Integration**: Nested user object returned from backend to avoid extra requests.
- **Material 3 UI**: Modern, clean interface with status icons, color coding, and intuitive controls.
- **Pull-to-Refresh**: Easy refresh of task lists.
- **Persistent Backend**: All data stored in MySQL via PHP endpoints.

---

## Architecture

- **Frontend**: Flutter with `http` package for API communication.
- **Backend**: PHP scripts (`tasks.php`, `users.php`) for CRUD and user management.
- **Database**: MySQL hosted on AwardSpace (or any LAMP environment), with two main tables:
  - `tasks` — stores task info, status, and assigned user ID.
  - `users` — stores user info.
- **APIService**: Central service in Flutter handling all network calls and JSON parsing.
- **State Management**: Local state via `StatefulWidget` for simplicity.

---

## Screenshots

*Replace these with actual screenshots of your app.*

- **Task List Screen**: Displays all tasks with status icons and assigned users.
- **Task Detail Screen**: Edit task title, description, status, and assigned user.
- **Create Task Screen**: Add new tasks and assign users.

---

## Getting Started

### Prerequisites

- Flutter SDK (>= 3.0)
- Dart
- PHP (>= 7.4)
- MySQL

---

## Backend Setup

1. Upload the PHP scripts (`tasks.php`, `users.php`, `db.php`) to your hosting environment (e.g., AwardSpace).
2. Create a MySQL database and execute the following tables:

```sql
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE tasks (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    status ENUM('todo','in_progress','done') DEFAULT 'todo',
    assigned_user INT DEFAULT NULL,
    FOREIGN KEY (assigned_user) REFERENCES users(id) ON DELETE SET NULL
);
