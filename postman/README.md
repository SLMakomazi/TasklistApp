# 📮 Postman Collection - TasklistApp API Testing

This folder contains the **essential files** for testing the **TasklistApp API** using Postman.

## 📋 Contents

- **`TasklistApp_API_Collection.json`** - 🏆 Complete Postman collection for import
- **`README.md`** - 📖 This usage guide

## 🚀 Quick Start

### **Postman Collection (Only Method)**

#### **Import the Collection**
1. Open Postman
2. Click **Import** button (top left)
3. Select **`TasklistApp_API_Collection.json`**
4. Collection appears in your workspace as **"TasklistApp API Collection"**

#### **Configure Environment**
1. In Postman, click **Environments** (left sidebar)
2. Create new environment or use existing
3. Add variable: `baseUrl` = `http://localhost:8080`
4. Save the environment

#### **Test the API**
1. **Health Check** - Verify application status
2. **Get All Tasks** - View existing tasks
3. **Create Task** - Add new tasks with sample data
4. **Get Task by ID** - Retrieve specific tasks
5. **Update Task** - Modify existing tasks
6. **Delete Task** - Remove tasks

## 📚 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| **GET** | `/actuator/health` | Application health check |
| **GET** | `/api/tasks` | Get all tasks |
| **POST** | `/api/tasks` | Create new task |
| **GET** | `/api/tasks/{id}` | Get task by ID |
| **PUT** | `/api/tasks/{id}` | Update existing task |
| **DELETE** | `/api/tasks/{id}` | Delete task |

## 🔧 Usage Instructions

### **1. Environment Setup**
```json
{
  "baseUrl": "http://localhost:8080",
  "taskId": "1"
}
```

### **2. Set Path Variables (CRITICAL!)**

**For requests with `{{taskId}}` in the URL:**

#### **Option A: Environment Variables**
```json
{
  "baseUrl": "http://localhost:8080",
  "taskId": "1"
}
```

#### **Option B: Postman Params Tab**
1. Select request (e.g., **"Get Task by ID"**)
2. Click **"Params"** tab (next to Authorization)
3. Add path variable:
   - **Key**: `taskId` (⚠️ **Important**: This matches `{taskId}` in your controller)
   - **Value**: `1` (or any task ID)

#### **Option C: Direct URL Edit**
- Change `{{baseUrl}}/api/tasks/{{taskId}}` to `{{baseUrl}}/api/tasks/1`

### **3. Testing Workflow**

#### **Step 1: Create a Task First**
```bash
curl -X POST http://localhost:8080/api/tasks \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test Task",
    "description": "Testing path variables",
    "completed": false,
    "dueDate": "2024-12-31"
  }'
# Returns: {"id": 1, ...}
```

#### **Step 2: Use the Returned ID**
- Copy the `id` from the response (e.g., `1`)
- Set `taskId` variable to `1` in Postman
- Now **Get Task by ID** will work: `http://localhost:8080/api/tasks/1`

#### **Step 3: Test Individual Requests**
1. **Get Task by ID**: `GET {{baseUrl}}/api/tasks/{{taskId}}`
   - Set `taskId` to `1` first
   - Should return the task you created

2. **Update Task**: `PUT {{baseUrl}}/api/tasks/{{taskId}}`
   - Set `taskId` to `1` first
   - Send updated task data in body

3. **Delete Task**: `DELETE {{baseUrl}}/api/tasks/{{taskId}}`
   - Set `taskId` to `1` first
   - Should return `204 No Content`

## 📋 Collection Features

### **✅ What's Included**
- **Health Monitoring** - Application status endpoints
- **Complete CRUD** - All task management operations
- **API Documentation** - Swagger UI access links
- **Smart Variables** - `baseUrl` and `taskId` auto-management
- **Response Examples** - Sample data for all endpoints
- **Validation Tests** - Status code and response time checks

### **🎯 Collection Structure**
```
TasklistApp API Collection/
├── Application Health
│   └── Health Check
├── Task Management
│   ├── Get All Tasks
│   ├── Create New Task
│   ├── Get Task by ID
│   ├── Update Task
│   └── Delete Task
└── API Documentation
    ├── Swagger UI
    └── OpenAPI Specification
```

## 🔍 Testing Examples

### **Create Sample Tasks**
Use the **Create New Task** request in Postman with the provided sample data:

```json
{
  "title": "Complete Project Setup",
  "description": "Set up complete Spring Boot application with PostgreSQL, Docker, and documentation",
  "completed": false,
  "dueDate": "2024-12-31"
}
```

### **Expected Response**
```json
{
  "id": 1,
  "title": "Complete Project Setup",
  "description": "Set up complete Spring Boot application...",
  "completed": false,
  "dueDate": "2024-12-31",
  "createdAt": "2024-10-08T18:34:39",
  "updatedAt": "2024-10-08T18:34:39"
}
```

## 🛠️ Troubleshooting

### **Import Issues**
- Ensure JSON file is valid
- Try re-importing if collection doesn't appear

### **Variable Issues**
- Check `baseUrl` variable is set correctly
- Verify environment is selected before running requests

### **Path Variable Issues (ID Parameters)**
**Problem:** Getting `{{baseUrl}}/api/tasks/{{taskId}}` URLs in Postman

**Solution:** Set the `taskId` variable:

1. **In Postman Environments:**
   - Go to **Environments** tab
   - Set `taskId` to actual ID (e.g., `1`)

2. **In Request Params:**
   - Select request with `{{taskId}}`
   - Click **Params** tab
   - Add: Key=`taskId`, Value=`1`

3. **Expected URLs After Setting Variables:**
   - ❌ `{{baseUrl}}/api/tasks/{{taskId}}` (broken)
   - ✅ `http://localhost:8080/api/tasks/1` (working)

### **Connection Issues**
- Confirm application is running on port 8080
- Check Docker containers are active

