package com.tasklist.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.tasklist.model.Task;
import com.tasklist.repository.TaskRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.time.LocalDate;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(TaskController.class)
class TaskControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private TaskRepository taskRepository;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    void shouldGetAllTasks() throws Exception {
        // given
        Task task1 = new Task();
        task1.setId(1L);
        task1.setTitle("Task 1");
        task1.setCompleted(false);
        task1.setDueDate(LocalDate.now().plusDays(1));

        Task task2 = new Task();
        task2.setId(2L);
        task2.setTitle("Task 2");
        task2.setCompleted(true);
        task2.setDueDate(LocalDate.now().plusDays(2));

        List<Task> tasks = Arrays.asList(task1, task2);
        when(taskRepository.findAllByOrderByDueDateAsc()).thenReturn(tasks);

        // when & then
        mockMvc.perform(get("/api/tasks"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(2))
                .andExpect(jsonPath("$[0].title").value("Task 1"))
                .andExpect(jsonPath("$[1].title").value("Task 2"));
    }

    @Test
    void shouldGetTasksByStatus() throws Exception {
        // given
        Task completedTask = new Task();
        completedTask.setId(1L);
        completedTask.setTitle("Completed Task");
        completedTask.setCompleted(true);

        List<Task> completedTasks = Arrays.asList(completedTask);
        when(taskRepository.findByCompleted(true)).thenReturn(completedTasks);

        // when & then
        mockMvc.perform(get("/api/tasks/filter?completed=true"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(1))
                .andExpect(jsonPath("$[0].title").value("Completed Task"))
                .andExpect(jsonPath("$[0].completed").value(true));
    }

    @Test
    void shouldCreateTask() throws Exception {
        // given
        Task newTask = new Task();
        newTask.setTitle("New Task");
        newTask.setDescription("New Description");
        newTask.setCompleted(false);
        newTask.setDueDate(LocalDate.now().plusDays(1));

        Task savedTask = new Task();
        savedTask.setId(1L);
        savedTask.setTitle("New Task");
        savedTask.setDescription("New Description");
        savedTask.setCompleted(false);
        savedTask.setDueDate(LocalDate.now().plusDays(1));

        when(taskRepository.save(any(Task.class))).thenReturn(savedTask);

        // when & then
        mockMvc.perform(post("/api/tasks")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(newTask)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(1))
                .andExpect(jsonPath("$.title").value("New Task"))
                .andExpect(jsonPath("$.description").value("New Description"))
                .andExpect(jsonPath("$.completed").value(false));
    }

    @Test
    void shouldGetTaskById() throws Exception {
        // given
        Task task = new Task();
        task.setId(1L);
        task.setTitle("Test Task");
        task.setCompleted(false);

        when(taskRepository.findById(1L)).thenReturn(Optional.of(task));

        // when & then
        mockMvc.perform(get("/api/tasks/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(1))
                .andExpect(jsonPath("$.title").value("Test Task"))
                .andExpect(jsonPath("$.completed").value(false));
    }

    @Test
    void shouldReturnNotFoundForNonExistentTask() throws Exception {
        // given
        when(taskRepository.findById(999L)).thenReturn(Optional.empty());

        // when & then
        mockMvc.perform(get("/api/tasks/999"))
                .andExpect(status().isNotFound());
    }

    @Test
    void shouldUpdateTask() throws Exception {
        // given
        Task existingTask = new Task();
        existingTask.setId(1L);
        existingTask.setTitle("Original Title");
        existingTask.setCompleted(false);

        Task updatedTask = new Task();
        updatedTask.setId(1L);
        updatedTask.setTitle("Updated Title");
        updatedTask.setDescription("Updated Description");
        updatedTask.setCompleted(true);
        updatedTask.setDueDate(LocalDate.now().plusDays(1));

        when(taskRepository.findById(1L)).thenReturn(Optional.of(existingTask));
        when(taskRepository.save(any(Task.class))).thenReturn(updatedTask);

        // when & then
        mockMvc.perform(put("/api/tasks/1")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(updatedTask)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.title").value("Updated Title"))
                .andExpect(jsonPath("$.description").value("Updated Description"))
                .andExpect(jsonPath("$.completed").value(true));
    }

    @Test
    void shouldReturnNotFoundWhenUpdatingNonExistentTask() throws Exception {
        // given
        Task updatedTask = new Task();
        updatedTask.setTitle("Updated Title");

        when(taskRepository.findById(999L)).thenReturn(Optional.empty());

        // when & then
        mockMvc.perform(put("/api/tasks/999")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(updatedTask)))
                .andExpect(status().isNotFound());
    }

    @Test
    void shouldDeleteTask() throws Exception {
        // given
        when(taskRepository.existsById(1L)).thenReturn(true);

        // when & then
        mockMvc.perform(delete("/api/tasks/1"))
                .andExpect(status().isNoContent());
    }

    @Test
    void shouldReturnNotFoundWhenDeletingNonExistentTask() throws Exception {
        // given
        when(taskRepository.existsById(999L)).thenReturn(false);

        // when & then
        mockMvc.perform(delete("/api/tasks/999"))
                .andExpect(status().isNotFound());
    }
}
