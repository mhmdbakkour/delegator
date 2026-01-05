# Delegator

A Flutter-based mobile application for managing tasks with backend integration using PHP and MySQL. The app emphasizes **backend-driven functionality**, including CRUD operations, user management, and dynamic task assignment. This project demonstrates modern Flutter development practices combined with a relational database backend.

---

## Table of Contents

* [Project Overview](#project-overview)
* [Features](#features)
* [Architecture](#architecture)
* [Screenshots](#screenshots)
* [Getting Started](#getting-started)
* [Backend Setup](#backend-setup)
* [Frontend Setup](#frontend-setup)
* [API Endpoints](#api-endpoints)
* [Database Schema](#database-schema)
* [Design Decisions](#design-decisions)
* [Future Improvements](#future-improvements)
* [License](#license)

---

## Project Overview

The **Delegator** App allows users to:

* Create, read, update, and delete tasks.
* Assign tasks to users or create new users on the fly.
* Filter tasks by status (`todo`, `in_progress`, `done`).
* View task details with dynamic assignment.
* Use a clean, modern Material 3 interface.

The app is designed for **fast development and educational purposes**, demonstrating full-stack integration of a mobile frontend with a relational backend.

---

## Features

* **Task Management**: Full CRUD operations for tasks.
* **User Assignment**: Assign tasks to existing users or create a new user during task creation/editing.
* **Status Filtering**: Filter tasks by status using backend-driven queries.
* **Dynamic Backend Integration**: Nested user object returned from backend to avoid extra requests.
* **Material 3 UI**: Modern interface with icons and colors for improved readability.
* **Pull-to-Refresh**: Easy refresh of task lists.
* **Persistent Backend**: All data stored in MySQL via PHP endpoints.

---

## Architecture

* **Frontend**: Flutter with `http` package for API communication.
* **Backend**: PHP scripts (`tasks.php`, `users.php`) for CRUD and user management.
* **Database**: MySQL hosted on AwardSpace, with two main tables:

  * `tasks` — stores task info, status, and assigned user ID.
  * `users` — stores user info.
* **APIService**: Central service in Flutter handling all network calls and JSON parsing.
* **State Management**: Local state via `StatefulWidget` for simplicity.

---

## Screenshots

<img width="392" height="698" alt="image" src="https://github.com/user-attachments/assets/f51d3126-f58b-4a54-96de-305f485a4210" />
<img width="392" height="698" alt="image" src="https://github.com/user-attachments/assets/538023eb-c566-4368-892b-89d613bce984" />
<img width="392" height="698" alt="image" src="https://github.com/user-attachments/assets/43600d82-1d93-449a-a702-959c064921ab" />


* **Task List Screen**: Displays all tasks with status icons and assigned users.
* **Task Detail Screen**: Edit task title, description, status, and assigned user.
* **Create Task Screen**: Add new tasks and assign users.

---

## Getting Started

### Prerequisites

* Flutter SDK (>= 3.0)
* Dart
* PHP (>= 7.4)
* MySQL

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
```

3. Update `db.php` with your database credentials:

```php
<?php
$host = 'localhost';
$db = 'your_database_name';
$user = 'your_db_user';
$pass = 'your_db_password';

$pdo = new PDO("mysql:host=$host;dbname=$db;charset=utf8mb4", $user, $pass);
$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
?>
```

---

## Frontend Setup

1. Clone the repository:

```bash
git clone https://github.com/mhmdbakkour/delegator.git
cd delegator
```

2. Install dependencies:

```bash
flutter pub get
```

3. Run the app:

```bash
flutter run
```

4. Update the `ApiService` base URL to point to your hosted PHP backend:

In my case it's: 
```dart
static const String baseUrl = 'http://mhmdbakkour.atwebpages.com/task_api';
```

---

## API Endpoints

| Endpoint           | Method | Description         | Request Body                                                          |             |       |
| ------------------ | ------ | ------------------- | --------------------------------------------------------------------- | ----------- | ----- |
| `/tasks.php`       | GET    | Fetch all tasks     | Optional query: `?status=todo                                         | in_progress | done` |
| `/tasks.php`       | POST   | Create a new task   | `{"title":"..","description":"..","status":"todo","assigned_user":1}` |             |       |
| `/tasks.php?id=ID` | PATCH  | Update a task by ID | `{"title":"..","description":"..","status":"..","assigned_user":1}`   |             |       |
| `/tasks.php?id=ID` | DELETE | Delete a task by ID | —                                                                     |             |       |
| `/users.php`       | GET    | Fetch all users     | —                                                                     |             |       |
| `/users.php`       | POST   | Create a new user   | `{"username":"newuser"}`                                              |             |       |

---

## Database Schema

**users**

| Column   | Type         | Notes                       |
| -------- | ------------ | --------------------------- |
| id       | INT          | Primary Key, Auto Increment |
| username | VARCHAR(255) | Unique, Not Null            |

**tasks**

| Column        | Type                                | Notes                       |
| ------------- | ----------------------------------- | --------------------------- |
| id            | INT                                 | Primary Key, Auto Increment |
| title         | VARCHAR(255)                        | Not Null                    |
| description   | TEXT                                | Optional                    |
| status        | ENUM('todo', 'in_progress', 'done') | Default 'todo'              |
| assigned_user | INT                                 | Foreign Key to `users(id)`  |

---

## Design Decisions

* **Backend-Driven Filtering**: Tasks are filtered by status in the backend for efficiency.
* **Nested User Objects**: Avoids extra network calls by including user info in the task payload.
* **Dynamic User Creation**: Users can be created on the fly when assigning a task.
* **Material 3 UI**: Clean, modern design with icons and colors for improved readability.
* **Minimal Dependencies**: Only `http` for network calls to reduce complexity.
* **Scalable Structure**: Backend can be expanded for authentication, multiple projects, or team management.

---

## Future Improvements

* Add authentication and multi-user support.
* Support multiple users per task.
* Add task deadlines, priority levels, and notifications.
* Use Riverpod or another state management solution for large-scale app.
* Improve frontend with animations and richer UI components.
* Add search and sort functionality in the task list.

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
