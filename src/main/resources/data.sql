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