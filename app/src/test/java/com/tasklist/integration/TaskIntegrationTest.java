package com.tasklist.integration;

import com.tasklist.model.Task;
import com.tasklist.repository.TaskRepository;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureWebMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

import java.time.LocalDate;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@AutoConfigureWebMvc
@Testcontainers
@Transactional
class TaskIntegrationTest {

    @Container
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:16")
            .withDatabaseName("testdb")
            .withUsername("test")
            .withPassword("test");

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private TaskRepository taskRepository;

    @DynamicPropertySource
    static void configureProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", postgres::getJdbcUrl);
        registry.add("spring.datasource.username", postgres::getUsername);
        registry.add("spring.datasource.password", postgres::getPassword);
        registry.add("spring.jpa.hibernate.ddl-auto", () -> "create-drop");
    }

    @Test
    void shouldCreateTaskAndRetrieveIt() throws Exception {
        // Create a new task
        String taskJson = """
                {
                    "title": "Integration Test Task",
                    "description": "Testing full integration",
                    "completed": false,
                    "dueDate": "2024-12-31"
                }""";

        String response = mockMvc.perform(post("/api/tasks")
                .contentType("application/json")
                .content(taskJson))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").exists())
                .andExpect(jsonPath("$.title").value("Integration Test Task"))
                .andExpect(jsonPath("$.completed").value(false))
                .andReturn()
                .getResponse()
                .getContentAsString();

        // Extract the ID from the response
        Long taskId = extractIdFromResponse(response);

        // Verify task exists in database
        Task savedTask = taskRepository.findById(taskId).orElse(null);
        assert savedTask != null;
        assert savedTask.getTitle().equals("Integration Test Task");
        assert !savedTask.isCompleted();
    }

    @Test
    void shouldListAllTasks() throws Exception {
        // Create test tasks in database
        Task task1 = new Task();
        task1.setTitle("Task 1");
        task1.setCompleted(false);
        task1.setDueDate(LocalDate.now().plusDays(1));
        taskRepository.save(task1);

        Task task2 = new Task();
        task2.setTitle("Task 2");
        task2.setCompleted(true);
        task2.setDueDate(LocalDate.now().plusDays(2));
        taskRepository.save(task2);

        // Test GET /api/tasks
        mockMvc.perform(get("/api/tasks"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(2))
                .andExpect(jsonPath("$[0].title").value("Task 1"))
                .andExpect(jsonPath("$[1].title").value("Task 2"));
    }

    @Test
    void shouldFilterTasksByStatus() throws Exception {
        // Create test tasks
        Task completedTask = new Task();
        completedTask.setTitle("Completed Task");
        completedTask.setCompleted(true);
        completedTask.setDueDate(LocalDate.now().plusDays(1));
        taskRepository.save(completedTask);

        Task incompleteTask = new Task();
        incompleteTask.setTitle("Incomplete Task");
        incompleteTask.setCompleted(false);
        incompleteTask.setDueDate(LocalDate.now().plusDays(2));
        taskRepository.save(incompleteTask);

        // Test filtering by completed status
        mockMvc.perform(get("/api/tasks/filter?completed=true"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(1))
                .andExpect(jsonPath("$[0].title").value("Completed Task"))
                .andExpect(jsonPath("$[0].completed").value(true));

        mockMvc.perform(get("/api/tasks/filter?completed=false"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(1))
                .andExpect(jsonPath("$[0].title").value("Incomplete Task"))
                .andExpect(jsonPath("$[0].completed").value(false));
    }

    @Test
    void shouldUpdateTask() throws Exception {
        // Create a task
        Task task = new Task();
        task.setTitle("Original Title");
        task.setDescription("Original Description");
        task.setCompleted(false);
        task.setDueDate(LocalDate.now().plusDays(1));
        Task savedTask = taskRepository.save(task);

        // Update the task
        String updateJson = """
                {
                    "title": "Updated Title",
                    "description": "Updated Description",
                    "completed": true,
                    "dueDate": "2024-12-31"
                }""";

        mockMvc.perform(put("/api/tasks/" + savedTask.getId())
                .contentType("application/json")
                .content(updateJson))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.title").value("Updated Title"))
                .andExpect(jsonPath("$.description").value("Updated Description"))
                .andExpect(jsonPath("$.completed").value(true));

        // Verify in database
        Task updatedTask = taskRepository.findById(savedTask.getId()).orElse(null);
        assert updatedTask != null;
        assert updatedTask.getTitle().equals("Updated Title");
        assert updatedTask.getDescription().equals("Updated Description");
        assert updatedTask.isCompleted();
    }

    @Test
    void shouldDeleteTask() throws Exception {
        // Create a task
        Task task = new Task();
        task.setTitle("Task to Delete");
        task.setCompleted(false);
        Task savedTask = taskRepository.save(task);

        mockMvc.perform(delete("/api/tasks/" + savedTask.getId()))
                .andExpect(status().isNoContent());

        // Verify it's deleted
        assert taskRepository.findById(savedTask.getId()).isEmpty();
    }

    @AfterAll
    static void tearDown() {
        postgres.stop();
    }

    private Long extractIdFromResponse(String response) {
        // Simple JSON parsing to extract ID (in a real scenario, use JsonPath or ObjectMapper)
        int idIndex = response.indexOf("\"id\":");
        if (idIndex != -1) {
            int start = idIndex + 5;
            int end = response.indexOf(",", start);
            if (end == -1) end = response.indexOf("}", start);
            return Long.parseLong(response.substring(start, end));
        }
        throw new RuntimeException("Could not extract ID from response");
    }
}
