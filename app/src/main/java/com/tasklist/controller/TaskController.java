package com.tasklist.controller;

import com.tasklist.model.Task;
import com.tasklist.repository.TaskRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/tasks")
@Slf4j
public class TaskController {

    private final TaskRepository taskRepository;

    public TaskController(TaskRepository taskRepository) {
        this.taskRepository = taskRepository;
    }

    // List all tasks (sorted by due date)
    @GetMapping
    public List<Task> getAllTasks() {
        log.info('Received request to get all tasks.');
        List<Task> tasks = taskRepository.findAllByOrderByDueDateAsc();
        log.info('Returning {} tasks from repository.', tasks.size());
        return tasks;
    }

    // Filter by completion status
    @GetMapping("/filter")
    public List<Task> getTasksByStatus(@RequestParam boolean completed) {
        return taskRepository.findByCompleted(completed);
    }

    // Create a new task
    @PostMapping
    public Task createTask(@RequestBody Task task) {
        log.info('Received request to save task: {}', task);
        // Handle frontend sending 'text' field instead of 'title'
        if (task.getTitle() == null && task.getText() != null) {
            task.setTitle(task.getText());
        }
        log.info('Attempting to save task to repository: {}', task);
        Task savedTask = taskRepository.save(task);
        log.info('Successfully saved task with ID: {}', savedTask.getId());
        return savedTask;
    }

    // Get task by ID
    @GetMapping("/{taskId}")
    public ResponseEntity<Task> getTaskById(@PathVariable Long taskId) {
        return taskRepository.findById(taskId)
                .map(task -> ResponseEntity.ok(task))
                .orElse(ResponseEntity.notFound().build());
    }

    // Update entire task
    @PutMapping("/{taskId}")
    public ResponseEntity<Task> updateTask(@PathVariable Long taskId, @RequestBody Task taskDetails) {
        return taskRepository.findById(taskId).map(task -> {
            task.setTitle(taskDetails.getTitle());
            task.setDescription(taskDetails.getDescription());
            task.setCompleted(taskDetails.isCompleted());
            task.setDueDate(taskDetails.getDueDate());
            return ResponseEntity.ok(taskRepository.save(task));
        }).orElse(ResponseEntity.notFound().build());
    }

    // Delete task
    @DeleteMapping("/{taskId}")
    public ResponseEntity<Void> deleteTask(@PathVariable Long taskId) {
        if (taskRepository.existsById(taskId)) {
            taskRepository.deleteById(taskId);
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
    }
}
