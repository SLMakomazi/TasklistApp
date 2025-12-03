const API_URL = process.env.REACT_APP_API_URL || 'https://api.tasklistapp.local';

export const getTasks = async () => {
  try {
    console.log('Sending GET to API:', `${API_URL}/tasks`);
    const response = await fetch(`${API_URL}/tasks`);
    if (!response.ok) {
      throw new Error('Failed to fetch tasks');
    }
    const data = await response.json();
    console.log('Task GET Success. Received tasks array length:', data.length);
    return data;
  } catch (error) {
    console.error('Task GET Failed:', error);
    throw error;
  }
};


export const createTask = async (taskData) => {
  try {
    console.log('Sending POST to API:', `${API_URL}/tasks`, 'with data:', taskData);
    const response = await fetch(`${API_URL}/tasks`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(taskData),
    });
    if (!response.ok) {
      throw new Error('Failed to create task');
    }
    const createdTask = await response.json();
    console.log('Task POST Success. Response:', createdTask);
    return createdTask;
  } catch (error) {
    console.error('Task POST Failed:', error);
    throw error;
  }
};

export const updateTask = async (id, taskData) => {
  try {
    const response = await fetch(`${API_URL}/tasks/${id}`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(taskData),
    });
    if (!response.ok) {
      throw new Error('Failed to update task');
    }
    return await response.json();
  } catch (error) {
    console.error('Error updating task:', error);
    throw error;
  }
};

export const deleteTask = async (id) => {
  try {
    const response = await fetch(`${API_URL}/tasks/${id}`, {
      method: 'DELETE',
    });
    if (!response.ok) {
      throw new Error('Failed to delete task');
    }
  } catch (error) {
    console.error('Error deleting task:', error);
    throw error;
  }
};
