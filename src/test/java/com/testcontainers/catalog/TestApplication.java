package com.testcontainers.catalog;

import org.springframework.boot.SpringApplication;

public class TestApplication {
    public static void main(String[] args) {
        SpringApplication
                // note that we are starting our actual Application from within our TestApplication
                .from(Application::main)
                .with(ContainersConfig.class)
                .run(args);
    }
}
