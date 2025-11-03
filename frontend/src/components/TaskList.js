import React, { useState, useEffect } from 'react';
import './TaskList.css';
import { getTasks, createTask, updateTask, deleteTask as deleteTaskApi } from '../services/taskService';

const TaskList = () => {
  const [tasks, setTasks] = useState([]);
  const [newTask, setNewTask] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState(null);
  const [editingTask, setEditingTask] = useState(null);
  const [editText, setEditText] = useState('');

  // Load tasks on component mount
  useEffect(() => {
    const fetchTasks = async () => {
      setIsLoading(true);
      setError(null);
      try {
        const data = await getTasks();
        setTasks(data);
      } catch (err) {
        console.error('Failed to load tasks:', err);
        setError('Failed to load tasks. Please try again later.');
      } finally {
        setIsLoading(false);
      }
    };

    fetchTasks();
  }, []);

  const addTask = async (e) => {
    e.preventDefault();
    if (!newTask.trim()) return;

    const taskToAdd = { text: newTask, completed: false };
    
    try {
      const createdTask = await createTask(taskToAdd);
      setTasks([...tasks, createdTask]);
      setNewTask('');
    } catch (err) {
      console.error('Failed to create task:', err);
      setError('Failed to create task. Please try again.');
    }
  };

  const toggleTask = async (taskId) => {
    const taskToUpdate = tasks.find(task => task.id === taskId);
    if (!taskToUpdate) return;

    try {
      const updatedTask = await updateTask(taskId, {
        ...taskToUpdate,
        completed: !taskToUpdate.completed
      });
      
      setTasks(tasks.map(task => 
        task.id === taskId ? updatedTask : task
      ));
    } catch (err) {
      console.error('Failed to update task:', err);
      setError('Failed to update task status. Please try again.');
    }
  };

  const startEditing = (task) => {
    setEditingTask(task.id);
    setEditText(task.text);
  };

  const cancelEditing = () => {
    setEditingTask(null);
    setEditText('');
  };

  const saveTask = async (taskId) => {
    if (!editText.trim()) {
      setError('Task text cannot be empty');
      return;
    }

    const taskToUpdate = tasks.find(task => task.id === taskId);
    if (!taskToUpdate) return;

    try {
      const updatedTask = await updateTask(taskId, {
        ...taskToUpdate,
        text: editText.trim()
      });
      
      setTasks(tasks.map(task => 
        task.id === taskId ? updatedTask : task
      ));
      setEditingTask(null);
      setEditText('');
    } catch (err) {
      console.error('Failed to update task text:', err);
      setError('Failed to update task text. Please try again.');
    }
  };

  const deleteTask = async (taskId) => {
    try {
      await deleteTaskApi(taskId);
      setTasks(tasks.filter(task => task.id !== taskId));
    } catch (err) {
      console.error('Failed to delete task:', err);
      setError('Failed to delete task. Please try again.');
    }
  };

  return (
    <div className="task-list">
      <h1>My Task List</h1>
      
      {/* Error Message */}
      {error && (
        <div className="error-message">
          {error}
          <button onClick={() => setError(null)} className="dismiss-button">×</button>
        </div>
      )}
      
      {/* Add Task Form */}
      <form onSubmit={addTask} className="task-form">
        <input
          type="text"
          value={newTask}
          onChange={(e) => setNewTask(e.target.value)}
          placeholder="Add a new task..."
          className="task-input"
          disabled={isLoading}
        />
        <button 
          type="submit" 
          className="add-button"
          disabled={isLoading || !newTask.trim()}
        >
          {isLoading ? 'Adding...' : 'Add Task'}
        </button>
      </form>
      
      {/* Loading State */}
      {isLoading && tasks.length === 0 ? (
        <div className="loading">Loading tasks...</div>
      ) : (
        <ul className="tasks">
          {tasks.length === 0 ? (
            <li className="no-tasks">No tasks yet. Add one above!</li>
          ) : (
            tasks.map(task => (
              <li key={task.id} className={`task-item ${task.completed ? 'completed' : ''}`}>
                <input
                  type="checkbox"
                  checked={task.completed}
                  onChange={() => toggleTask(task.id)}
                  className="task-checkbox"
                  disabled={isLoading}
                />
                {editingTask === task.id ? (
                  <>
                    <input
                      type="text"
                      value={editText}
                      onChange={(e) => setEditText(e.target.value)}
                      className="edit-input"
                      autoFocus
                    />
                    <div className="edit-buttons">
                      <button
                        type="button"
                        onClick={() => saveTask(task.id)}
                        className="save-button"
                        disabled={isLoading}
                      >
                        Save
                      </button>
                      <button
                        type="button"
                        onClick={cancelEditing}
                        className="cancel-button"
                        disabled={isLoading}
                      >
                        Cancel
                      </button>
                    </div>
                  </>
                ) : (
                  <>
                    <span className="task-text" onDoubleClick={() => startEditing(task)}>
                      {task.text}
                    </span>
                    <div className="task-actions">
                      <button
                        onClick={() => startEditing(task)}
                        className="edit-button"
                        aria-label="Edit task"
                        disabled={isLoading}
                        title="Edit task"
                      >
                        ✏️
                      </button>
                      <button
                        onClick={() => deleteTask(task.id)}
                        className="delete-button"
                        aria-label="Delete task"
                        disabled={isLoading}
                        title="Delete task"
                      >
                        {isLoading ? '...' : '🗑️'}
                      </button>
                    </div>
                  </>
              </li>
            ))
          )}
        </ul>
      )}
      
      <style jsx>{`
        .task-list {
          max-width: 600px;
          margin: 0 auto;
          padding: 20px;
          font-family: Arial, sans-serif;
        }
        
        .error-message {
          background-color: #ffebee;
          color: #c62828;
          padding: 10px 15px;
          border-radius: 4px;
          margin-bottom: 20px;
          display: flex;
          justify-content: space-between;
          align-items: center;
        }
        
        .dismiss-button {
          background: none;
          border: none;
          color: #c62828;
          font-size: 20px;
          cursor: pointer;
          padding: 0 5px;
        }
        
        .task-form {
          display: flex;
          margin-bottom: 20px;
          gap: 10px;
        }
        
        .task-input {
          flex: 1;
          padding: 10px;
          border: 1px solid #ddd;
          border-radius: 4px;
          font-size: 16px;
        }
        
        .add-button {
          padding: 10px 20px;
          background-color: #4CAF50;
          color: white;
          border: none;
          border-radius: 4px;
          cursor: pointer;
          font-size: 16px;
        }
        
        .add-button:disabled {
          background-color: #a5d6a7;
          cursor: not-allowed;
        }
        
        .tasks {
          list-style: none;
          padding: 0;
          margin: 0;
        }
        
        .task-item {
          display: flex;
          align-items: center;
          padding: 10px;
          border: 1px solid #eee;
          margin-bottom: 8px;
          border-radius: 4px;
          background-color: white;
          gap: 8px;
        }
        
        .task-item.completed {
          opacity: 0.7;
        }
        
        .task-checkbox {
          margin-right: 10px;
        }
        
        .task-text {
          flex: 1;
          text-decoration: none;
          padding: 5px;
          border-radius: 3px;
          cursor: pointer;
        }
        
        .task-text:hover {
          background: #f5f5f5;
        }
        
        .edit-input {
          flex: 1;
          padding: 5px 8px;
          border: 1px solid #ddd;
          border-radius: 3px;
          font-size: 16px;
        }
        
        .task-actions, .edit-buttons {
          display: flex;
          gap: 5px;
        }
        
        .edit-button, .save-button, .cancel-button {
          background: none;
          border: none;
          cursor: pointer;
          padding: 2px 5px;
          border-radius: 3px;
          font-size: 14px;
        }
        
        .edit-button {
          color: #2196F3;
        }
        
        .save-button {
          background-color: #4CAF50;
          color: white;
        }
        
        .cancel-button {
          background-color: #f44336;
          color: white;
        }
        
        .edit-button:hover, .save-button:hover, .cancel-button:hover {
          opacity: 0.8;
        }
        
        .edit-button:disabled, .save-button:disabled, .cancel-button:disabled {
          opacity: 0.5;
          cursor: not-allowed;
        }
        
        .task-item.completed .task-text {
          text-decoration: line-through;
          color: #888;
        }
        
        .delete-button {
          background: none;
          border: none;
          color: #f44336;
          font-size: 20px;
          cursor: pointer;
          padding: 0 5px;
        }
        
        .delete-button:disabled {
          color: #ffcdd2;
          cursor: not-allowed;
        }
        
        .loading, .no-tasks {
          text-align: center;
          color: #666;
          padding: 20px;
        }
      `}</style>
    </div>
  );
};

export default TaskList;
