FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

FROM eclipse-temurin:17-jre
WORKDIR /deployments
COPY --from=build /app/target/backend.jar app.jar
EXPOSE 9084
ENTRYPOINT ["java", "-jar", "app.jar"]
