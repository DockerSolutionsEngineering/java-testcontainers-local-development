
# Use an official Maven image to build the application
FROM maven:3.8.1-openjdk-17-slim as builder

# Set the working directory
WORKDIR /app

# Copy the pom.xml and download dependencies
COPY pom.xml ./
RUN mvn dependency:go-offline

# Copy the source code and build the application
COPY src ./src
RUN mvn package -DskipTests

# Use an official OpenJDK runtime image to run the application
FROM openjdk:24-ea-6-jdk-slim

# Set the working directory
WORKDIR /app

# Copy the JAR file from the builder stage
COPY --from=builder /app/target/*.jar app.jar

# Expose the port the application runs on
EXPOSE 8080

# Default non root user
USER nonroot

# Define the entrypoint
ENTRYPOINT ["java", "-jar", "app.jar"]