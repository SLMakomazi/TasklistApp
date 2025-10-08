package com.tasklist.config;

import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.OpenAPI;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OpenApiConfig {
    @Bean
    public OpenAPI taskListOpenAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("Tasklist API")
                        .description("Spring Boot API for managing tasks")
                        .version("1.0.0"));
    }
}
