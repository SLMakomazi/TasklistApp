package com.tasklist.repository;

import com.tasklist.model.Task;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.boot.test.autoconfigure.orm.jpa.TestEntityManager;

import java.time.LocalDate;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

@DataJpaTest
class TaskRepositoryTest {

    @Autowired
    private TestEntityManager entityManager;

    @Autowired
    private TaskRepository taskRepository;

    @Test
    void shouldFindTasksByCompletedStatus() {
        // given
        Task completedTask = new Task();
        completedTask.setTitle("Completed Task");
        completedTask.setDescription("This task is done");
        completedTask.setCompleted(true);
        completedTask.setDueDate(LocalDate.now().plusDays(1));
        entityManager.persist(completedTask);

        Task incompleteTask = new Task();
        incompleteTask.setTitle("Incomplete Task");
        incompleteTask.setDescription("This task is not done");
        incompleteTask.setCompleted(false);
        incompleteTask.setDueDate(LocalDate.now().plusDays(2));
        entityManager.persist(incompleteTask);

        entityManager.flush();

        // when
        List<Task> completedTasks = taskRepository.findByCompleted(true);
        List<Task> incompleteTasks = taskRepository.findByCompleted(false);

        // then
        assertThat(completedTasks).hasSize(1);
        assertThat(completedTasks.get(0).getTitle()).isEqualTo("Completed Task");
        assertThat(completedTasks.get(0).isCompleted()).isTrue();

        assertThat(incompleteTasks).hasSize(1);
        assertThat(incompleteTasks.get(0).getTitle()).isEqualTo("Incomplete Task");
        assertThat(incompleteTasks.get(0).isCompleted()).isFalse();
    }

    @Test
    void shouldFindAllTasksOrderedByDueDate() {
        // given
        Task task1 = new Task();
        task1.setTitle("Task 1");
        task1.setDueDate(LocalDate.now().plusDays(3));
        entityManager.persist(task1);

        Task task2 = new Task();
        task2.setTitle("Task 2");
        task2.setDueDate(LocalDate.now().plusDays(1));
        entityManager.persist(task2);

        Task task3 = new Task();
        task3.setTitle("Task 3");
        task3.setDueDate(LocalDate.now().plusDays(2));
        entityManager.persist(task3);

        entityManager.flush();

        // when
        List<Task> tasks = taskRepository.findAllByOrderByDueDateAsc();

        // then
        assertThat(tasks).hasSize(3);
        assertThat(tasks.get(0).getTitle()).isEqualTo("Task 2"); // Due in 1 day
        assertThat(tasks.get(1).getTitle()).isEqualTo("Task 3"); // Due in 2 days
        assertThat(tasks.get(2).getTitle()).isEqualTo("Task 1"); // Due in 3 days
    }

    @Test
    void shouldSaveAndRetrieveTask() {
        // given
        Task task = new Task();
        task.setTitle("Test Task");
        task.setDescription("Test Description");
        task.setCompleted(false);
        task.setDueDate(LocalDate.now().plusDays(1));

        // when
        Task savedTask = taskRepository.save(task);

        // then
        assertThat(savedTask.getId()).isNotNull();
        assertThat(savedTask.getTitle()).isEqualTo("Test Task");
        assertThat(savedTask.getDescription()).isEqualTo("Test Description");
        assertThat(savedTask.isCompleted()).isFalse();
        assertThat(savedTask.getDueDate()).isEqualTo(LocalDate.now().plusDays(1));

        // Verify it can be retrieved
        Task retrievedTask = taskRepository.findById(savedTask.getId()).orElse(null);
        assertThat(retrievedTask).isNotNull();
        assertThat(retrievedTask.getTitle()).isEqualTo("Test Task");
    }
}
