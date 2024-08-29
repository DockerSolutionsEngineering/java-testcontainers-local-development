# Use an official OpenJDK runtime as a parent image
FROM openjdk:24-jdk-slim

# Set the working directory in the container
WORKDIR /app

# Copy the project's pom.xml and other build-related files
COPY pom.xml ./
COPY src ./src

# Install Maven and build the project (using a multi-stage build to reduce final image size)
RUN apt-get update && apt-get install -y maven && \
    mvn dependency:resolve

# Build the project
RUN mvn package -DskipTests

# Copy the built jar file to a clean image
FROM openjdk:24-jdk-slim

WORKDIR /app
COPY --from=0 /app/target/*.jar /app/app.jar
USER nonroot
# Expose port 8080 (if your application uses it)
EXPOSE 8080

# Run the application
CMD ["java", "-jar", "app.jar"]
