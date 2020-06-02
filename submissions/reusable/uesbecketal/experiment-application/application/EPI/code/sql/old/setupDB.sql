SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";

CREATE DATABASE IF NOT EXISTS concurrency;

USE concurrency;

CREATE TABLE IF NOT EXISTS participants (
    `id` INT NOT NULL AUTO_INCREMENT,
    `email` varchar(255) NOT NULL,
    `name` varchar(255) DEFAULT NULL,
    `courseNum` varchar(255) DEFAULT NULL,
    `courseName` varchar(255) DEFAULT NULL,
    `instructor` varchar(255) DEFAULT NULL,
    `lang` INT NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS events (
    `eventid` INT NOT NULL AUTO_INCREMENT,
    `id` INT NOT NULL,
    `event` INT NOT NULL,
    `category` INT DEFAULT NULL,
    `time` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `task` INT DEFAULT NULL,
    `entry` TEXT DEFAULT NULL,
  PRIMARY KEY (`eventid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS survey (
    `id` INT NOT NULL,
    `totalxp` INT,
    `jobxp` INT,
    `education` CHAR(25),
    `institution` VARCHAR(255),
    `major` VARCHAR(255),
    `degree` VARCHAR(255),
    `year` CHAR(25),
    `gpa` CHAR(25),
    `origin` CHAR(30),
    `language` CHAR(30),
    `fluency` INT,
    `colorBlind` BOOLEAN,
    `lowVisual` BOOLEAN,
    `blind` BOOLEAN,
    `lowAural` BOOLEAN,
    `deaf` BOOLEAN,
    `motorImpaired` BOOLEAN,
    `learning` BOOLEAN,
    `age` INT,
    `gender` CHAR(10),
    `internxp` INT,
    `lang1` INT,
    `lang2` INT,
    `lang3` INT,
    `lang4` INT,
    `lang5` INT,
    `lang6` INT,
    `lang7` INT,
    `lang8` INT,
    `lang9` INT,
    `lang10` INT,
    `lang11` INT,
    `lang12` INT,
    `lang13` INT,
    `lang14` INT,
    `lang15` INT,
    `lang16` INT,
    `lang17` INT,
    `course1` CHAR(10),
    `course2` CHAR(10),
    `course3` CHAR(10),
    `course4` CHAR(10),
    `course5` CHAR(10),
    `course6` CHAR(10),
    `course7` CHAR(10),
    `course8` CHAR(10),
    `course9` CHAR(10),
    `course10` CHAR(10),
    `course11` CHAR(10),
    `course12` CHAR(10),
    `course13` CHAR(10),
    `course14` CHAR(10),
    `course15` CHAR(10),
    `course16` CHAR(10),
    `course17` CHAR(10),
    `course18` CHAR(10),
    `course19` CHAR(10),
    `concepts` TEXT DEFAULT NULL,
    `design` TEXT DEFAULT NULL,
    `comments` TEXT DEFAULT NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS codes (
  `code` INT NOT NULL,
  `desc` varchar(255) NOT NULL,
  UNIQUE(`code`),
  PRIMARY KEY (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS language (
  `year` CHAR(25),
  `nextLanguage` INT NOT NULL,
  `numL1` INT,
  `numL2` INT,
  PRIMARY KEY (`year`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
