# Spring Security Demo

This is a demo project which exhibits below features:
1. Implementing basic authentication using spring security
2. Using database as source for basic authentication
3. Using custom tables as source for authentication and authorization details
4. Using https with spring boot
5. Dockerizing spring boot application
6. Loading certificate files from external path into the container, using Dockerfile

# Creating certificate file

For generating our keystore in a JKS format, we can use the following command:

```
keytool -genkeypair -alias spring-security-demo -keyalg RSA -keysize 2048 -keystore demo.jks -validity 3650
```

> Note: When prompted for password, enter 'password'

Place the generate keystore in the following path in the project's root directory. 

~~~
+-- config
|   +-- keystore
|   |   +-- demo.jks
~~~

## Starting application in docker

### 1. Using Dockerfile only

<strong>Docker file contents</strong>

```
FROM adoptopenjdk/openjdk11:alpine-jre
RUN addgroup -S ec2-user && adduser -S ec2-user -G ec2-user
USER ec2-user:ec2-user
WORKDIR /
COPY config/keystore/demo.jks /home/ec2-user/demo.jks
ARG JAR_FILE=target/basic_auth_db-0.0.1-SNAPSHOT.jar
COPY ${JAR_FILE} app.jar
ENTRYPOINT [“java”,"-jar","-Dspring.profiles.active=docker","/app.jar"]
```

<strong>Important Commands</strong>

```
.\mvnw clean package spring-boot:repackage
docker build -t demo/spring-security-demo .
docker run -p 8443:8443 demo/spring-security-demo
docker ps -a
docker rm \<container-id\>
docker rmi demo/spring-security-demo
docker exec -it 2f332543f37c /bin/bash
docker exec -it 2f332543f37c sh
```

### 2. Using Dockerfile and volume mount

<strong>Docker file contents</strong>

```
FROM adoptopenjdk/openjdk11:alpine-jre
ARG JAR_FILE=target/basic_auth_db-0.0.1-SNAPSHOT.jar
COPY ${JAR_FILE} app.jar 
ENTRYPOINT ["java","-jar","-Dspring.profiles.active=docker","/app.jar"]
```

<strong>Important Commands</strong>

```
.\mvnw clean package spring-boot:repackage
docker build -t demo/spring-security-demo .
docker run -v $pwd/config/keystore:/home/ec2-user  -p 8443:8443 demo/spring-security-demo
```