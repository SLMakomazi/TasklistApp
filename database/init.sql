-- Create the tasks table
CREATE TABLE IF NOT EXISTS tasks (
    id BIGSERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    due_date DATE,
    completed BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_tasks_completed ON tasks(completed);
CREATE INDEX IF NOT EXISTS idx_tasks_due_date ON tasks(due_date);

-- Create a trigger to update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply the trigger to the tasks table
DROP TRIGGER IF EXISTS update_tasks_updated_at ON tasks;
CREATE TRIGGER update_tasks_updated_at
BEFORE UPDATE ON tasks
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- Reset sequence to start from 1
SELECT setval('tasks_id_seq', 1, false);
INSERT INTO tasks (id, title, description, completed, due_date, created_at, updated_at)
VALUES 
    (1, 'Complete project setup', 'Set up the complete TasklistApp with Docker and documentation', false, '2024-12-31', '2024-10-08T18:34:39', '2024-10-08T18:34:39'),
    (2, 'Create API documentation', 'Document all API endpoints and create Postman collection', false, '2024-12-31', '2024-10-08T18:35:00', '2024-10-08T18:35:00')
ON CONFLICT (id) DO NOTHING;

-- Reset the sequence after inserting sample data
SELECT reset_sequence();

-- Grant necessary permissions
GRANT ALL PRIVILEGES ON DATABASE tasklistdb TO postgres;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO postgres;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO postgres;

-- Verify the data was inserted
SELECT * FROM tasks ORDER BY id;