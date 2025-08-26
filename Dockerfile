# Use an official OpenJDK runtime as a parent image
FROM demonstrationorg/dhi-maven:3.9-jdk21-dev AS builder

# Set the working directory in the container
WORKDIR /app

# Copy the project's pom.xml and other build-related files
COPY pom.xml ./
COPY src ./src

#RUN apt-get update && apt-get install -y curl git && rm -rf /var/lib/apt/lists/* \
# Build the project
RUN mvn clean package -DskipTests

# Copy the built jar file to a clean image
FROM demonstrationorg/dhi-amazoncorretto:21 AS runtime

WORKDIR /app
COPY --from=builder /app/target/*.jar /app/app.jar
USER nonroot
# Expose port 8080 (if your application uses it)
EXPOSE 8080

# Run the application
CMD ["java", "-jar", "app.jar"]
