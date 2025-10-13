package com.tasklist.model;

import org.junit.jupiter.api.Test;

import java.time.LocalDate;

import static org.assertj.core.api.Assertions.assertThat;

class TaskTest {

    @Test
    void shouldCreateTaskWithDefaultValues() {
        // given & when
        Task task = new Task();

        // then
        assertThat(task.getId()).isNull();
        assertThat(task.getTitle()).isNull();
        assertThat(task.getDescription()).isNull();
        assertThat(task.getDueDate()).isNull();
        assertThat(task.isCompleted()).isFalse(); // default value
    }

    @Test
    void shouldSetAndGetTaskProperties() {
        // given
        Task task = new Task();
        LocalDate dueDate = LocalDate.now().plusDays(1);

        // when
        task.setTitle("Test Title");
        task.setDescription("Test Description");
        task.setDueDate(dueDate);
        task.setCompleted(true);

        // then
        assertThat(task.getTitle()).isEqualTo("Test Title");
        assertThat(task.getDescription()).isEqualTo("Test Description");
        assertThat(task.getDueDate()).isEqualTo(dueDate);
        assertThat(task.isCompleted()).isTrue();
    }

    @Test
    void shouldHandleNullValues() {
        // given
        Task task = new Task();

        // when
        task.setTitle(null);
        task.setDescription(null);
        task.setDueDate(null);
        task.setCompleted(false);

        // then
        assertThat(task.getTitle()).isNull();
        assertThat(task.getDescription()).isNull();
        assertThat(task.getDueDate()).isNull();
        assertThat(task.isCompleted()).isFalse();
    }

    @Test
    void shouldCreateTaskWithAllValues() {
        // given
        LocalDate dueDate = LocalDate.of(2024, 12, 31);

        // when
        Task task = new Task();
        task.setTitle("Complete Task");
        task.setDescription("A fully configured task");
        task.setDueDate(dueDate);
        task.setCompleted(true);

        // then
        assertThat(task.getTitle()).isEqualTo("Complete Task");
        assertThat(task.getDescription()).isEqualTo("A fully configured task");
        assertThat(task.getDueDate()).isEqualTo(dueDate);
        assertThat(task.isCompleted()).isTrue();
    }

    @Test
    void shouldHandleEmptyStrings() {
        // given
        Task task = new Task();

        // when
        task.setTitle("");
        task.setDescription("");

        // then
        assertThat(task.getTitle()).isEqualTo("");
        assertThat(task.getDescription()).isEqualTo("");
        assertThat(task.isCompleted()).isFalse(); // default value
    }
}
