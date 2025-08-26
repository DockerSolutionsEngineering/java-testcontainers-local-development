package com.testcontainers.catalog;

import static org.testcontainers.utility.DockerImageName.parse;

import com.testcontainers.catalog.domain.FileStorageService;
import io.github.microcks.testcontainers.MicrocksContainer;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.boot.testcontainers.service.connection.ServiceConnection;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.DependsOn;
import org.springframework.test.context.DynamicPropertyRegistrar;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.containers.localstack.LocalStackContainer;
import org.testcontainers.kafka.KafkaContainer;
import org.testcontainers.utility.DockerImageName;

@TestConfiguration(proxyBeanMethods = false)
public class ContainersConfig {
    @Bean
    @ServiceConnection
    PostgreSQLContainer<?> postgresContainer() {
        return new PostgreSQLContainer<>(parse("postgres:17.5-alpine"));
    }

    @Bean
    @ServiceConnection
    KafkaContainer kafkaContainer() {
        return new KafkaContainer(DockerImageName.parse("apache/kafka-native:latest"));
    }

    @Bean("localstackContainer")
    LocalStackContainer localstackContainer() {
        return new LocalStackContainer(DockerImageName.parse("localstack/localstack:4.5.0"));
    }

    @Bean
    DynamicPropertyRegistrar localstackContainerRegistrar(LocalStackContainer localStack) {
        return registry -> {
            registry.add("spring.cloud.aws.credentials.access-key", localStack::getAccessKey);
            registry.add("spring.cloud.aws.credentials.secret-key", localStack::getSecretKey);
            registry.add("spring.cloud.aws.region.static", localStack::getRegion);
            registry.add("spring.cloud.aws.endpoint", localStack::getEndpoint);
        };
    }

    @Bean
    @DependsOn("localstackContainer")
    ApplicationRunner awsInitializer(ApplicationProperties properties, FileStorageService fileStorageService) {
        return args -> fileStorageService.createBucket(properties.productImagesBucketName());
    }

    @Bean("microcksContainer")
    MicrocksContainer microcksContainer() {
        return new MicrocksContainer("quay.io/microcks/microcks-uber:1.12.0")
                .withMainArtifacts("inventory-openapi.yaml")
                .withAccessToHost(true);
    }

    @Bean
    DynamicPropertyRegistrar microcksContainerRegistrar(MicrocksContainer microcks) {
        return registry -> {
            registry.add(
                    "application.inventory-service-url",
                    () -> microcks.getRestMockEndpoint("Inventory Service", "1.0"));
        };
    }
}
