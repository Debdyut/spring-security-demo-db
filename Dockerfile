FROM adoptopenjdk/openjdk11:alpine-jre
ARG JAR_FILE=target/basic_auth_db-0.0.1-SNAPSHOT.jar
COPY ${JAR_FILE} app.jar
ENTRYPOINT ["java","-jar","-Dspring.profiles.active=docker","/app.jar"]