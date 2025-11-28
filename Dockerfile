# Use an official OpenJDK runtime as a parent image
FROM maven:3.9-eclipse-temurin-21 AS builder
#FROM demonstrationorg/dhi-maven:3.9-jdk21-dev AS builder

# Set the working directory in the container
WORKDIR /app

# Copy the project's pom.xml and other build-related files
COPY pom.xml ./
COPY src ./src

# Build the project
RUN mvn clean package -DskipTests

# Copy the built jar file to a clean image
FROM eclipse-temurin:21 AS runtime
#FROM demonstrationorg/dhi-eclipse-temurin:21.0 AS runtime
WORKDIR /app
COPY --from=builder /app/target/*.jar /app/app.jar
# Expose port 8080 
EXPOSE 8080

# Run the application
CMD ["java", "-jar", "app.jar"]
