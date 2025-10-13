# Test Suite Documentation - TasklistApp

This directory contains the comprehensive test suite for the TasklistApp, ensuring code quality, reliability, and proper functionality across all application layers.

## Table of Contents

- [Test Structure](#test-structure)
- [Test Types](#test-types)
- [Running Tests](#running-tests)
- [Test Coverage](#test-coverage)
- [Dependencies](#dependencies)
- [Best Practices](#best-practices)

## Test Structure

```
app/src/test/java/com/tasklist/
├── controller/
│   └── TaskControllerTest.java     # REST API endpoint tests
├── integration/
│   └── TaskIntegrationTest.java    # End-to-end application tests
├── model/
│   └── TaskTest.java              # Entity model tests
└── repository/
    └── TaskRepositoryTest.java     # Database repository tests
```

## Test Types

### 1. Unit Tests

#### TaskTest.java
**Location:** `model/TaskTest.java`
- **Purpose:** Tests the Task entity model
- **Framework:** JUnit 5
- **Coverage:**
  - Default constructor and field initialization
  - Getter and setter methods (via Lombok)
  - Null value handling
  - Edge cases and validation

**Example Usage:**
```bash
mvn test -Dtest=TaskTest
```

#### TaskRepositoryTest.java
**Location:** `repository/TaskRepositoryTest.java`
- **Purpose:** Tests database repository operations
- **Framework:** `@DataJpaTest` (Spring Boot Test Slice)
- **Coverage:**
  - CRUD operations
  - Custom query methods (`findByCompleted`, `findAllByOrderByDueDateAsc`)
  - Data persistence and retrieval
  - Transaction rollback

**Example Usage:**
```bash
mvn test -Dtest=TaskRepositoryTest
```

### 2. Integration Tests

#### TaskControllerTest.java
**Location:** `controller/TaskControllerTest.java`
- **Purpose:** Tests REST API endpoints in isolation
- **Framework:** `@WebMvcTest` (Spring Boot Test Slice)
- **Coverage:**
  - HTTP request/response handling
  - JSON serialization/deserialization
  - REST endpoint behavior
  - Error handling (404, validation errors)
  - Content-Type negotiation

**Example Usage:**
```bash
mvn test -Dtest=TaskControllerTest
```

#### TaskIntegrationTest.java
**Location:** `integration/TaskIntegrationTest.java`
- **Purpose:** Tests complete application workflows
- **Framework:** `@SpringBootTest` + TestContainers
- **Coverage:**
  - Full application context
  - Real database integration (PostgreSQL)
  - End-to-end API workflows
  - Database persistence across requests
  - Cross-component interactions

**Example Usage:**
```bash
mvn test -Dtest=TaskIntegrationTest
```

## Running Tests

### Run All Tests
```bash
# From the app directory
mvn test
```

### Run Specific Test Categories

#### Unit Tests Only
```bash
mvn test -Dtest="*Test" -Dtest="!(*IntegrationTest)"
```

#### Integration Tests Only
```bash
mvn test -Dtest="*IntegrationTest"
```

#### Controller Tests Only
```bash
mvn test -Dtest="*ControllerTest"
```

#### Repository Tests Only
```bash
mvn test -Dtest="*RepositoryTest"
```

### Run with Coverage Report
```bash
mvn test jacoco:report
# View report at: target/site/jacoco/index.html
```

### Run Tests in IDE
1. **IntelliJ IDEA:**
   - Right-click on test file → "Run Test"
   - Use "Run Configuration" for specific test methods

2. **VS Code:**
   - Install "Java Test Runner" extension
   - Right-click on test method → "Run Test"

3. **Eclipse:**
   - Right-click on test file → "Run As" → "JUnit Test"

### Continuous Testing (Watch Mode)
```bash
# Requires Maven Surefire plugin configuration
mvn test-compile surefire:test
```

## Test Coverage

| Component | Test File | Coverage | Framework |
|-----------|-----------|----------|-----------|
| **Task Entity** | `TaskTest.java` | Model validation, Lombok integration | JUnit 5 |
| **TaskRepository** | `TaskRepositoryTest.java` | Database operations, queries | `@DataJpaTest` |
| **TaskController** | `TaskControllerTest.java` | REST endpoints, HTTP responses | `@WebMvcTest` |
| **Full Application** | `TaskIntegrationTest.java` | E2E workflows, database integration | `@SpringBootTest` + TestContainers |

### Coverage Goals
- **Unit Tests:** ≥ 80% coverage for individual components
- **Integration Tests:** ≥ 70% coverage for component interactions
- **End-to-End Tests:** ≥ 60% coverage for complete workflows

## Dependencies

### Test Dependencies (in pom.xml)

```xml
<!-- Core testing framework -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-test</artifactId>
    <scope>test</scope>
</dependency>

<!-- TestContainers for database integration testing -->
<dependency>
    <groupId>org.testcontainers</groupId>
    <artifactId>junit-jupiter</artifactId>
    <scope>test</scope>
</dependency>
<dependency>
    <groupId>org.testcontainers</groupId>
    <artifactId>postgresql</artifactId>
    <scope>test</scope>
</dependency>
```

### TestContainers Configuration

#### PostgreSQL Container Setup
```java
@Container
static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:16")
    .withDatabaseName("testdb")
    .withUsername("test")
    .withPassword("test");
```

#### Dynamic Properties
```java
@DynamicPropertySource
static void configureProperties(DynamicPropertyRegistry registry) {
    registry.add("spring.datasource.url", postgres::getJdbcUrl);
    registry.add("spring.datasource.username", postgres::getUsername);
    registry.add("spring.datasource.password", postgres::getPassword);
}
```

## Best Practices

### Test Organization
1. **Package Structure:** Mirror main source structure
2. **File Naming:** `{ClassName}Test.java` or `{ClassName}{TestType}Test.java`
3. **Method Naming:** `should{ExpectedBehavior}When{Condition}`

### Test Data Management
1. **Use TestContainers** for database isolation
2. **Rollback transactions** after each test
3. **Create test data factories** for complex objects
4. **Use `@DirtiesContext`** sparingly for expensive cleanup

### Assertions
```java
// Use AssertJ for fluent assertions
import static org.assertj.core.api.Assertions.assertThat;

// Example assertions
assertThat(task.getTitle()).isEqualTo("Expected Title");
assertThat(tasks).hasSize(3);
assertThat(response.getStatus()).isEqualTo(HttpStatus.OK);
```

### Mocking Guidelines
- **Unit Tests:** Mock external dependencies
- **Integration Tests:** Use real components where possible
- **Avoid over-mocking:** Test real behavior, not implementation details

### Test Database Strategy
1. **Unit Tests:** Use `@DataJpaTest` with in-memory H2 database
2. **Integration Tests:** Use TestContainers with real PostgreSQL
3. **Production Tests:** Use separate test database instance

## Troubleshooting

### Common Issues

#### TestContainers Issues
```bash
# Check if Docker is running
docker info

# Clean up existing containers
docker container prune

# Increase TestContainers timeout
@Testcontainers(disabledWithoutDocker = true)
```

#### Database Connection Issues
```bash
# Verify PostgreSQL container logs
docker logs <container-name>

# Check database connectivity
docker exec <container-name> pg_isready -U test -d testdb
```

#### Maven Test Issues
```bash
# Clean and recompile tests
mvn clean test-compile

# Run tests in debug mode
mvn test -X

# Skip integration tests for faster feedback
mvn test -Dtest="!(*IntegrationTest)"
```

### Performance Optimization
1. **Parallel Test Execution:** Configure Surefire plugin
2. **TestContainers Reuse:** Enable container reuse between tests
3. **Selective Testing:** Run only failing tests during development

## Integration with CI/CD

### GitHub Actions Integration
```yaml
- name: Run Tests
  run: mvn test

- name: Generate Coverage Report
  run: mvn test jacoco:report

- name: Upload Coverage to Codecov
  uses: codecov/codecov-action@v3
  with:
    file: ./app/target/site/jacoco/jacoco.xml
```

### Quality Gates
- **Test Success Rate:** ≥ 95%
- **Code Coverage:** ≥ 70%
- **Test Execution Time:** < 5 minutes
- **Flaky Tests:** < 1%

## Contributing

### Adding New Tests
1. **Follow naming conventions** (see Test Organization)
2. **Add appropriate test slices** (`@WebMvcTest`, `@DataJpaTest`, etc.)
3. **Include edge cases** and error scenarios
4. **Update this README** if adding new test patterns

### Test Maintenance
1. **Keep tests up-to-date** with code changes
2. **Remove obsolete tests** when refactoring
3. **Fix flaky tests** immediately
4. **Review test performance** regularly

## Related Documentation

- **Main Application:** [../README.md](../../README.md) - Project overview
- **Development Guide:** [../app/README.md](../app/README.md) - Development documentation
- **Testing Strategy:** See testing section in main README

---

**🧪 Test Suite Ready!** Run `mvn test` to verify your TasklistApp functionality! 🚀
