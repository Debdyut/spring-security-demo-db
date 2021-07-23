# Spring Security Demo

This is a demo project which exhibits below features:
1. Implementing basic authentication using spring security
2. Using database as source for basic authentication
3. Using custom tables as source for authentication and authorization details
4. Using https with spring boot
5. Dockerizing spring boot application
6. Loading certificate files from external path into the container, using Dockerfile

# Setting up DB-based basic authentication

1. Add security configuration in Security.config file.

```
@Configuration
@EnableWebSecurity
public class SecurityConfig extends WebSecurityConfigurerAdapter {

	@Autowired
	private DataSource dataSource;

	@Autowired
	public void configureGlobal(AuthenticationManagerBuilder auth) throws Exception {
		auth.jdbcAuthentication().dataSource(dataSource)
				.usersByUsernameQuery("select username,password,enabled from users where username=?")
				.authoritiesByUsernameQuery("select username,authority from authorities where username=?");
	}

	@Override
	protected void configure(HttpSecurity http) throws Exception {

		http.requiresChannel().anyRequest().requiresSecure();

		http.authorizeRequests()
			.antMatchers("/**").hasAnyRole("EMPLOYEE", "ADMIN").anyRequest().authenticated()
			.and().formLogin()
			.defaultSuccessUrl("/home", false);
	}

}
```

2. In this example we are using H2 database. Add the below configuration in application.properties file.

```
spring.datasource.url=jdbc:h2:mem:testdb
spring.datasource.driverClassName=org.h2.Driver
spring.datasource.username=admin
spring.datasource.password=admin
spring.jpa.database-platform=org.hibernate.dialect.H2Dialect
spring.jpa.show-sql=true
spring.jpa.hibernate.ddl-auto=create-drop
```

3. Add the database initialization script.

```
CREATE TABLE users (
  user_id INT AUTO_INCREMENT  PRIMARY KEY,
  username VARCHAR(50) NOT NULL,
  password VARCHAR(100) NOT NULL,
  enabled TINYINT NOT NULL DEFAULT 1
);
  
CREATE TABLE authorities (
  role_id INT AUTO_INCREMENT  PRIMARY KEY,
  username VARCHAR(50) NOT NULL,
  authority VARCHAR(50) NOT NULL,
  FOREIGN KEY (username) REFERENCES users(username)
);

CREATE UNIQUE INDEX ix_auth_username on authorities (username,authority);

INSERT INTO users(username, password, enabled) values('john', '{noop}password', 1);
INSERT INTO users(username, password, enabled) values('frank', '{noop}password', 1);

INSERT INTO authorities(username, authority) values('john', 'ROLE_EMPLOYEE');
INSERT INTO authorities(username, authority) values('frank', 'ROLE_ADMIN');
```

4. Add a controller for testing.

```
@RestController
@RequestMapping("/")
public class HelloController {

	@GetMapping("home")
	public ResponseEntity<String> hello() {
		return ResponseEntity.status(HttpStatus.OK).body("Hello, World!");
	}

}
```

5. Try to access http://localhost:8080/home. When prompted with the default login screen, enter the username and password as 'john' and 'password' respectively. On successful login, you will be redirected to the home page.

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