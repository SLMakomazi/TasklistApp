package com.tasklist.controller;

import com.tasklist.model.Task;
import com.tasklist.repository.TaskRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/tasks")
public class TaskController {

    private final TaskRepository taskRepository;

    public TaskController(TaskRepository taskRepository) {
        this.taskRepository = taskRepository;
    }

    // List all tasks (sorted by due date)
    @GetMapping
    public List<Task> getAllTasks() {
        return taskRepository.findAllByOrderByDueDateAsc();
    }

    // Filter by completion status
    @GetMapping("/filter")
    public List<Task> getTasksByStatus(@RequestParam boolean completed) {
        return taskRepository.findByCompleted(completed);
    }

    // Create a new task
    @PostMapping
    public Task createTask(@RequestBody Task task) {
        return taskRepository.save(task);
    }

    // Mark as complete
    @PutMapping("/{id}/complete")
    public ResponseEntity<Task> markComplete(@PathVariable Long id) {
        return taskRepository.findById(id).map(task -> {
            task.setCompleted(true);
            return ResponseEntity.ok(taskRepository.save(task));
        }).orElse(ResponseEntity.notFound().build());
    }

    // Delete task
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteTask(@PathVariable Long id) {
        if (taskRepository.existsById(id)) {
            taskRepository.deleteById(id);
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
    }
}
