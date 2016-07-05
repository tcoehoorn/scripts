
DROP DATABASE IF EXISTS `impetusmaster`;
CREATE DATABASE `impetusmaster`;
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, CREATE TEMPORARY TABLES ON `impetusmaster`.*  TO 'impetusmaster'@'localhost' IDENTIFIED BY 'impetustest';
USE `impetusmaster`;
SOURCE impetusmaster.sql;
