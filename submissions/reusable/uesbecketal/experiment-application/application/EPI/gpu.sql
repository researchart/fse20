-- phpMyAdmin SQL Dump
-- version 4.7.7
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Mar 19, 2018 at 02:34 AM
-- Server version: 10.1.30-MariaDB
-- PHP Version: 7.2.2

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `gpu`
--

-- --------------------------------------------------------

--
-- Table structure for table `codes`
--

CREATE TABLE `codes` (
  `code` int(11) NOT NULL,
  `desc` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `codes`
--

INSERT INTO `codes` (`code`, `desc`) VALUES
(1, 'start'),
(2, 'acceptConsent'),
(3, 'declineConsent'),
(4, 'classificationEnd'),
(5, 'sampleStart'),
(6, 'codeStart'),
(7, 'periodicCode'),
(8, 'codeSuccess'),
(9, 'codeFail'),
(10, 'surveyEnd'),
(11, 'end'),
(12, 'codeCheck'),
(13, 'codeTimeup'),
(14, 'sampleSwitch'),
(15, 'acceptConsentSurvey'),
(16, 'declineConsentSurvey'),
(17, 'acknowledgeSurveyInfo'),
(18, 'surveyQuestionFinished'),
(19, 'extraSurveyDone'),
(20, 'extraSurveyStart'),
(21, 'extraSurveyValidationError');

-- --------------------------------------------------------

--
-- Table structure for table `events`
--

CREATE TABLE `events` (
  `eventid` int(11) NOT NULL,
  `id` int(11) NOT NULL,
  `uuid` varchar(60) DEFAULT NULL,
  `event` int(11) NOT NULL,
  `category` int(11) DEFAULT NULL,
  `time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `task` int(11) DEFAULT NULL,
  `entry` text,
  `output` text
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `extrasurvey`
--

CREATE TABLE `extrasurvey` (
  `id` int(11) NOT NULL,
  `uuid` varchar(60) DEFAULT NULL,
  `qid` varchar(60) NOT NULL,
  `optionname` varchar(60) NOT NULL,
  `value` int(11) NOT NULL,
  `time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `language`
--

CREATE TABLE `language` (
  `year` char(25) NOT NULL,
  `nextLanguage` int(11) NOT NULL,
  `Lang1` tinyint(1) NOT NULL DEFAULT '0',
  `Lang2` tinyint(1) NOT NULL DEFAULT '0',
  `numL1` int(11) DEFAULT NULL,
  `numL2` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `language`
--

INSERT INTO `language` (`year`, `nextLanguage`, `Lang1`, `Lang2`, `numL1`, `numL2`) VALUES
('Freshman', 0, 0, 0, NULL, NULL),
('Graduate', 0, 0, 0, NULL, NULL),
('Junior', 0, 0, 0, NULL, NULL),
('Non-degree seeking', 0, 0, 0, NULL, NULL),
('Not Applicable', 0, 0, 0, NULL, NULL),
('Post-graduate', 0, 0, 0, NULL, NULL),
('Professional', 0, 0, 0, NULL, NULL),
('Senior', 0, 0, 0, NULL, NULL),
('Sophomore', 0, 0, 0, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `participants`
--

CREATE TABLE `participants` (
  `id` int(11) NOT NULL,
  `email` varchar(255) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `courseNum` varchar(255) DEFAULT NULL,
  `courseName` varchar(255) DEFAULT NULL,
  `instructor` varchar(255) DEFAULT NULL,
  `lang` int(11) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `questionoption`
--

CREATE TABLE `questionoption` (
  `optionname` varchar(60) NOT NULL,
  `question` varchar(60) NOT NULL,
  `content` varchar(250) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `questionoption`
--

INSERT INTO `questionoption` (`optionname`, `question`, `content`) VALUES
('O0', 'QE1', 'enumeration'),
('O0', 'QE10', 'byte'),
('O0', 'QE11', 'number<16>'),
('O0', 'QE12', 'byte'),
('O0', 'QE2', 'Monday\' Tuesday\' Wednesday'),
('O0', 'QE3', 'First is 1, Second is 2, Third is 3'),
('O0', 'QE4', 'Category becomes number Day'),
('O0', 'QE5', '1byte<integer>'),
('O0', 'QE6', '16byte<integer>'),
('O0', 'QE7', 'small integer'),
('O0', 'QE8', 'integer<128>'),
('O0', 'QE9', 'integer8'),
('O1', 'QE1', 'kind'),
('O1', 'QE10', 'quad number'),
('O1', 'QE11', '8byte number'),
('O1', 'QE12', 'decimal'),
('O1', 'QE2', 'Monday^ Tuesday^ Wednesday'),
('O1', 'QE3', 'First value 1, Second value 2, Third value 3'),
('O1', 'QE4', 'enumeration'),
('O1', 'QE5', 'fractal integer'),
('O1', 'QE6', 'biggest integer'),
('O1', 'QE7', '2byte<integer>'),
('O1', 'QE8', '16byte<integer>'),
('O1', 'QE9', '4byte integer'),
('O10', 'QE1', 'group'),
('O10', 'QE10', 'number128'),
('O10', 'QE11', 'long'),
('O10', 'QE12', 'number'),
('O10', 'QE2', 'Monday{ Tuesday{ Wednesday'),
('O10', 'QE3', 'First => 1, Second => 2, Third => 3'),
('O10', 'QE4', 'category Day :number'),
('O10', 'QE5', 'integer16'),
('O10', 'QE6', 'float'),
('O10', 'QE7', 'integer<128>'),
('O10', 'QE8', '2byte integer'),
('O10', 'QE9', 'chocolate integer'),
('O11', 'QE1', 'square'),
('O11', 'QE10', 'number<64>'),
('O11', 'QE11', 'giant number'),
('O11', 'QE12', 'smallest number'),
('O11', 'QE2', 'Monday[ Tuesday[ Wednesday'),
('O11', 'QE3', 'First <- 1, Second <- 2, Third <- 3'),
('O11', 'QE4', 'category Day {number}'),
('O11', 'QE5', 'small integer'),
('O11', 'QE6', 'bigger integer'),
('O11', 'QE7', 'integer<32>'),
('O11', 'QE8', 'float integer'),
('O11', 'QE9', 'integer64'),
('O12', 'QE10', 'number<8>'),
('O12', 'QE11', 'double number'),
('O12', 'QE12', 'number16'),
('O12', 'QE3', 'First(1), Second(2), Third(3)'),
('O12', 'QE4', 'category Day ::number'),
('O12', 'QE5', 'integer<8>'),
('O12', 'QE6', 'double'),
('O12', 'QE7', 'giant integer'),
('O12', 'QE8', 'fractal integer'),
('O12', 'QE9', 'integer32'),
('O13', 'QE10', '4byte<number>'),
('O13', 'QE11', 'number<64>'),
('O13', 'QE12', '1byte<number>'),
('O13', 'QE3', 'First, Second, Third values 1, 2, 3'),
('O13', 'QE4', 'category Day is number'),
('O13', 'QE5', 'giant integer'),
('O13', 'QE6', 'integer<64>'),
('O13', 'QE7', 'integer<8>'),
('O13', 'QE8', 'integer32'),
('O13', 'QE9', 'mini integer'),
('O14', 'QE10', 'float'),
('O14', 'QE11', 'number16'),
('O14', 'QE12', 'smaller number'),
('O14', 'QE3', 'First, Second, Third <= 1, 2, 3'),
('O14', 'QE4', 'are number category Day'),
('O14', 'QE5', 'integer<32>'),
('O14', 'QE6', 'integer<128>'),
('O14', 'QE7', 'chocolate integer'),
('O14', 'QE8', 'integer8'),
('O14', 'QE9', 'huge integer'),
('O15', 'QE10', 'big number'),
('O15', 'QE11', 'mini number'),
('O15', 'QE12', 'double number'),
('O15', 'QE3', 'First = 1, Second = 2, Third = 3'),
('O15', 'QE4', '= number category Day'),
('O15', 'QE5', 'bigger integer'),
('O15', 'QE6', 'integer<32>'),
('O15', 'QE7', 'float integer'),
('O15', 'QE8', '1byte<integer>'),
('O15', 'QE9', 'giant integer'),
('O16', 'QE10', 'short number'),
('O16', 'QE11', '2byte number'),
('O16', 'QE12', '8byte<number>'),
('O16', 'QE3', 'First := 1, Second := 2, Third := 3'),
('O16', 'QE4', 'category Day &lt;number&gt;'),
('O16', 'QE5', '2byte<integer>'),
('O16', 'QE6', 'small integer'),
('O16', 'QE7', 'integer16'),
('O16', 'QE8', 'quad integer'),
('O16', 'QE9', '2byte<integer>'),
('O17', 'QE10', 'double number'),
('O17', 'QE11', 'decimal number'),
('O17', 'QE12', 'number128'),
('O17', 'QE3', 'First <= 1, Second <= 2, Third <= 3'),
('O17', 'QE4', 'category Day are number'),
('O17', 'QE5', '1byte integer'),
('O17', 'QE6', 'integer16'),
('O17', 'QE7', 'integer32'),
('O17', 'QE8', 'byte integer'),
('O17', 'QE9', 'double integer'),
('O18', 'QE10', 'giant number'),
('O18', 'QE11', 'number<32>'),
('O18', 'QE12', '2byte<number>'),
('O18', 'QE3', 'First, Second, Third = 1, 2, 3'),
('O18', 'QE4', 'category :number Day'),
('O18', 'QE5', '4byte<integer>'),
('O18', 'QE6', 'short'),
('O18', 'QE7', '2byte integer'),
('O18', 'QE8', 'decimal'),
('O18', 'QE9', 'double'),
('O19', 'QE10', 'mini number'),
('O19', 'QE11', 'huge number'),
('O19', 'QE12', '4byte number'),
('O19', 'QE3', 'First, Second, Third -> 1, 2, 3'),
('O19', 'QE4', '#number# category Day'),
('O19', 'QE5', 'short'),
('O19', 'QE6', 'decimal integer'),
('O19', 'QE7', '4byte integer'),
('O19', 'QE8', 'byte'),
('O19', 'QE9', '2byte integer'),
('O2', 'QE1', 'list'),
('O2', 'QE10', 'smallest number'),
('O2', 'QE11', 'decimal'),
('O2', 'QE12', 'bigger number'),
('O2', 'QE2', 'Monday, Tuesday, Wednesday'),
('O2', 'QE3', 'First, Second, Third := 1, 2, 3'),
('O2', 'QE4', '(number) category Day'),
('O2', 'QE5', 'short integer'),
('O2', 'QE6', 'integer<16>'),
('O2', 'QE7', '8byte<integer>'),
('O2', 'QE8', 'smaller integer'),
('O2', 'QE9', 'quad integer'),
('O20', 'QE10', 'byte number'),
('O20', 'QE11', 'small number'),
('O20', 'QE12', 'number<64>'),
('O20', 'QE4', 'category &lt;number&gt; Day'),
('O20', 'QE5', 'float integer'),
('O20', 'QE6', 'chocolate integer'),
('O20', 'QE7', '16byte integer'),
('O20', 'QE8', 'mini integer'),
('O20', 'QE9', 'long'),
('O21', 'QE10', 'bigger number'),
('O21', 'QE11', 'number128'),
('O21', 'QE12', 'giant number'),
('O21', 'QE4', 'category ::number Day'),
('O21', 'QE5', 'quad integer'),
('O21', 'QE6', '4byte<integer>'),
('O21', 'QE7', 'smaller integer'),
('O21', 'QE8', 'long'),
('O21', 'QE9', 'float'),
('O22', 'QE10', 'short'),
('O22', 'QE11', '4byte number'),
('O22', 'QE12', 'chocolate number'),
('O22', 'QE4', 'category is number'),
('O22', 'QE5', 'mini integer'),
('O22', 'QE6', 'tiny integer'),
('O22', 'QE7', 'fractal integer'),
('O22', 'QE8', '2byte<integer>'),
('O22', 'QE9', '1byte<integer>'),
('O23', 'QE10', 'float number'),
('O23', 'QE11', 'bigger number'),
('O23', 'QE12', '8byte number'),
('O23', 'QE4', 'becomes number category Day'),
('O23', 'QE5', 'smaller integer'),
('O23', 'QE6', 'giant integer'),
('O23', 'QE7', 'short'),
('O23', 'QE8', 'big integer'),
('O23', 'QE9', 'bigger integer'),
('O24', 'QE10', 'long number'),
('O24', 'QE11', 'byte number'),
('O24', 'QE12', 'fractal number'),
('O24', 'QE4', '[As number] category Day'),
('O24', 'QE5', 'smallest integer'),
('O24', 'QE6', '1byte<integer>'),
('O24', 'QE7', 'integer64'),
('O24', 'QE8', 'integer128'),
('O24', 'QE9', '1byte integer'),
('O25', 'QE10', 'tiny number'),
('O25', 'QE11', 'fractal number'),
('O25', 'QE12', 'long number'),
('O25', 'QE4', 'category {number} Day'),
('O25', 'QE5', '8byte integer'),
('O25', 'QE6', '4byte integer'),
('O25', 'QE7', 'double'),
('O25', 'QE8', '8byte integer'),
('O25', 'QE9', '4byte<integer>'),
('O26', 'QE10', 'number8'),
('O26', 'QE11', 'number<128>'),
('O26', 'QE12', 'huge number'),
('O26', 'QE4', 'category @number@ Day'),
('O26', 'QE5', 'integer128'),
('O26', 'QE6', 'double integer'),
('O26', 'QE7', 'big integer'),
('O26', 'QE8', 'huge integer'),
('O26', 'QE9', 'integer16'),
('O27', 'QE10', 'number64'),
('O27', 'QE11', 'tiny number'),
('O27', 'QE12', 'float number'),
('O27', 'QE4', 'category are number Day'),
('O27', 'QE5', '4byte integer'),
('O27', 'QE6', 'mini integer'),
('O27', 'QE7', 'decimal integer'),
('O27', 'QE8', 'bigger integer'),
('O27', 'QE9', '8byte integer'),
('O28', 'QE10', '4byte number'),
('O28', 'QE11', 'biggest number'),
('O28', 'QE12', 'number<8>'),
('O28', 'QE4', '&lt;number&gt; category Day'),
('O28', 'QE5', 'integer<64>'),
('O28', 'QE6', 'smaller integer'),
('O28', 'QE7', 'integer128'),
('O28', 'QE8', 'integer<16>'),
('O28', 'QE9', 'short'),
('O29', 'QE10', '16byte<number>'),
('O29', 'QE11', 'float number'),
('O29', 'QE12', 'short number'),
('O29', 'QE4', 'category Day = number'),
('O29', 'QE5', 'biggest integer'),
('O29', 'QE6', '16byte integer'),
('O29', 'QE7', 'biggest integer'),
('O29', 'QE8', 'short integer'),
('O29', 'QE9', 'short integer'),
('O3', 'QE1', 'enum-id'),
('O3', 'QE10', 'long'),
('O3', 'QE11', 'float'),
('O3', 'QE12', 'number64'),
('O3', 'QE2', 'Monday~ Tuesday~ Wednesday'),
('O3', 'QE3', 'First, Second, Third => 1, 2, 3'),
('O3', 'QE4', 'category = number Day'),
('O3', 'QE5', 'long integer'),
('O3', 'QE6', 'byte'),
('O3', 'QE7', 'byte integer'),
('O3', 'QE8', 'integer<32>'),
('O3', 'QE9', 'decimal integer'),
('O30', 'QE10', '1byte number'),
('O30', 'QE11', 'smallest number'),
('O30', 'QE12', 'byte number'),
('O30', 'QE4', 'category Day @number@'),
('O30', 'QE5', '2byte integer'),
('O30', 'QE6', 'decimal'),
('O30', 'QE7', 'integer<16>'),
('O30', 'QE8', 'short'),
('O30', 'QE9', 'float integer'),
('O31', 'QE10', 'small number'),
('O31', 'QE11', 'number8'),
('O31', 'QE12', 'number<16>'),
('O31', 'QE4', 'category [As number] Day'),
('O31', 'QE5', 'double'),
('O31', 'QE6', '8byte integer'),
('O31', 'QE7', 'integer<64>'),
('O31', 'QE8', '4byte integer'),
('O31', 'QE9', 'decimal'),
('O32', 'QE10', '2byte number'),
('O32', 'QE11', 'short'),
('O32', 'QE12', 'long'),
('O32', 'QE4', 'category Day becomes number'),
('O32', 'QE5', 'double integer'),
('O32', 'QE6', 'big integer'),
('O32', 'QE7', 'mini integer'),
('O32', 'QE8', 'smallest integer'),
('O32', 'QE9', 'integer<64>'),
('O33', 'QE10', 'fractal number'),
('O33', 'QE11', 'number<8>'),
('O33', 'QE12', 'number8'),
('O33', 'QE4', 'category #number# Day'),
('O33', 'QE5', 'integer32'),
('O33', 'QE6', 'integer8'),
('O33', 'QE7', '16byte<integer>'),
('O33', 'QE8', 'double integer'),
('O33', 'QE9', 'byte integer'),
('O34', 'QE10', 'number16'),
('O34', 'QE11', 'long number'),
('O34', 'QE12', 'mini number'),
('O34', 'QE4', 'category Day (number)'),
('O34', 'QE5', 'decimal integer'),
('O34', 'QE6', 'integer<8>'),
('O34', 'QE7', 'byte'),
('O34', 'QE8', 'tiny integer'),
('O34', 'QE9', 'integer<128>'),
('O35', 'QE10', 'number'),
('O35', 'QE11', 'number32'),
('O35', 'QE12', 'number32'),
('O35', 'QE4', '::number category Day'),
('O35', 'QE5', 'long'),
('O35', 'QE6', 'integer64'),
('O35', 'QE7', 'short integer'),
('O35', 'QE8', '4byte<integer>'),
('O35', 'QE9', 'big integer'),
('O36', 'QE10', 'number<16>'),
('O36', 'QE11', '1byte<number>'),
('O36', 'QE12', '1byte number'),
('O36', 'QE5', 'tiny integer'),
('O36', 'QE6', 'long'),
('O36', 'QE7', 'decimal'),
('O36', 'QE8', 'giant integer'),
('O36', 'QE9', 'small integer'),
('O37', 'QE10', 'smaller number'),
('O37', 'QE11', '2byte<number>'),
('O37', 'QE12', 'quad number'),
('O37', 'QE5', 'float'),
('O37', 'QE6', 'quad integer'),
('O37', 'QE7', 'double integer'),
('O37', 'QE8', '1byte integer'),
('O37', 'QE9', '16byte integer'),
('O38', 'QE10', '2byte<number>'),
('O38', 'QE11', 'short number'),
('O38', 'QE12', 'decimal number'),
('O38', 'QE5', '8byte<integer>'),
('O38', 'QE6', 'integer32'),
('O38', 'QE7', '8byte integer'),
('O38', 'QE8', 'integer<64>'),
('O38', 'QE9', 'tiny integer'),
('O39', 'QE10', '1byte<number>'),
('O39', 'QE11', 'big number'),
('O39', 'QE12', 'big number'),
('O39', 'QE5', 'integer<16>'),
('O39', 'QE6', 'integer128'),
('O39', 'QE7', '1byte integer'),
('O39', 'QE8', 'double'),
('O39', 'QE9', '8byte<integer>'),
('O4', 'QE1', 'constants'),
('O4', 'QE10', 'number<128>'),
('O4', 'QE11', '16byte<number>'),
('O4', 'QE12', 'number<32>'),
('O4', 'QE2', 'Monday_ Tuesday_ Wednesday'),
('O4', 'QE3', 'First, Second, Third <- 1, 2, 3'),
('O4', 'QE4', 'category Day #number# '),
('O4', 'QE5', 'decimal'),
('O4', 'QE6', '2byte integer'),
('O4', 'QE7', 'bigger integer'),
('O4', 'QE8', 'decimal integer'),
('O4', 'QE9', 'long integer'),
('O40', 'QE10', 'biggest number'),
('O40', 'QE11', 'number'),
('O40', 'QE12', 'biggest number'),
('O40', 'QE5', 'big integer'),
('O40', 'QE6', 'byte integer'),
('O40', 'QE7', 'integer8'),
('O40', 'QE8', 'integer64'),
('O40', 'QE9', 'integer128'),
('O41', 'QE10', 'huge number'),
('O41', 'QE11', '16byte number'),
('O41', 'QE12', 'tiny number'),
('O41', 'QE5', 'byte integer'),
('O41', 'QE6', 'float integer'),
('O41', 'QE7', '1byte<integer>'),
('O41', 'QE8', 'integer16'),
('O41', 'QE9', '16byte<integer>'),
('O42', 'QE10', '8byte<number>'),
('O42', 'QE11', '8byte<number>'),
('O42', 'QE12', '2byte number'),
('O42', 'QE5', 'integer8'),
('O42', 'QE6', 'short integer'),
('O42', 'QE7', 'long'),
('O42', 'QE8', 'long integer'),
('O42', 'QE9', 'smaller integer'),
('O43', 'QE10', 'decimal'),
('O43', 'QE11', '4byte<number>'),
('O43', 'QE12', 'small number'),
('O43', 'QE5', '16byte integer'),
('O43', 'QE6', '1byte integer'),
('O43', 'QE7', 'long integer'),
('O43', 'QE8', 'chocolate integer'),
('O43', 'QE9', 'byte'),
('O44', 'QE10', '16byte number'),
('O44', 'QE11', 'chocolate number'),
('O44', 'QE12', '16byte number'),
('O44', 'QE5', 'byte'),
('O44', 'QE6', 'huge integer'),
('O44', 'QE7', 'tiny integer'),
('O44', 'QE8', '16byte integer'),
('O44', 'QE9', 'integer<8> '),
('O5', 'QE1', 'type'),
('O5', 'QE10', 'chocolate number'),
('O5', 'QE11', 'byte'),
('O5', 'QE12', '16byte<number>'),
('O5', 'QE2', 'Monday Tuesday Wednesday'),
('O5', 'QE3', 'First: 1, Second: 2, Third: 3'),
('O5', 'QE4', 'is number category Day'),
('O5', 'QE5', 'huge integer'),
('O5', 'QE6', '2byte<integer>'),
('O5', 'QE7', 'quad integer'),
('O5', 'QE8', 'small integer'),
('O5', 'QE9', 'biggest integer'),
('O6', 'QE1', 'NS_ENUM'),
('O6', 'QE10', 'number32'),
('O6', 'QE11', '1byte number'),
('O6', 'QE12', 'number<128>'),
('O6', 'QE2', 'Monday# Tuesday# Wednesday'),
('O6', 'QE3', 'First, Second, Third: 1, 2, 3'),
('O6', 'QE4', '@number@ category Day'),
('O6', 'QE5', 'chocolate integer'),
('O6', 'QE6', '8byte<integer>'),
('O6', 'QE7', 'smallest integer'),
('O6', 'QE8', '8byte<integer>'),
('O6', 'QE9', 'smallest integer'),
('O7', 'QE1', 'grouping'),
('O7', 'QE10', '8byte number'),
('O7', 'QE11', 'smaller number'),
('O7', 'QE12', 'short'),
('O7', 'QE2', 'Monday. Tuesday. Wednesday'),
('O7', 'QE3', 'First, Second, Third (1), (2), (3)'),
('O7', 'QE4', 'category Day [As number]'),
('O7', 'QE5', 'integer64'),
('O7', 'QE6', 'fractal integer'),
('O7', 'QE7', 'float'),
('O7', 'QE8', 'integer<8>'),
('O7', 'QE9', 'fractal integer'),
('O8', 'QE1', 'enum'),
('O8', 'QE10', 'number<32>'),
('O8', 'QE11', 'quad number'),
('O8', 'QE12', 'float'),
('O8', 'QE2', 'Monday: Tuesday: Wednesday'),
('O8', 'QE3', 'First, Second, Third are 1, 2, 3'),
('O8', 'QE4', 'category (number) Day'),
('O8', 'QE5', '16byte<integer>'),
('O8', 'QE6', 'long integer'),
('O8', 'QE7', '4byte<integer>'),
('O8', 'QE8', 'biggest integer'),
('O8', 'QE9', 'integer<32>'),
('O9', 'QE1', 'ocean'),
('O9', 'QE10', 'decimal number'),
('O9', 'QE11', 'number64'),
('O9', 'QE12', '4byte<number>'),
('O9', 'QE2', 'Monday; Tuesday; Wednesday'),
('O9', 'QE3', 'First -> 1, Second -> 2, Third -> 3'),
('O9', 'QE4', ':number category Day'),
('O9', 'QE5', 'integer<128>'),
('O9', 'QE6', 'smallest integer'),
('O9', 'QE7', 'huge integer'),
('O9', 'QE8', 'float'),
('O9', 'QE9', 'integer<16>');

-- --------------------------------------------------------

--
-- Table structure for table `questions`
--

CREATE TABLE `questions` (
  `Question` varchar(5) NOT NULL,
  `Description` text,
  `Concept` text
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `questions`
--

INSERT INTO `questions` (`Question`, `Description`, `Concept`) VALUES
('QE5', 'Rate the following choices on how well they correspond with an integer variable holding 1 byte (8 bits) of memory.', 'An integer variable that holds 1 byte (8 bits) of memory.'),
('QE6', 'Rate the following choices on how well they correspond with an integer variable holding 2 bytes (16 bits) of memory.', 'An integer variable that holds 2 bytes (16 bits) of memory.'),
('QE7', 'Rate the following choices on how well they correspond with an integer variable holding 4 bytes (32 bits) of memory.', 'An integer variable that holds 4 bytes (32 bits) of memory.'),
('QE8', 'Rate the following choices on how well they correspond with an integer variable holding 8 bytes (64 bits) of memory.', 'An integer variable that holds 8 bytes (64 bits) of memory.'),
('QE9', ' Rate the following choices on how well they correspond with an integer variable holding 16 bytes (128 bits) of memory.', ' An integer variable that holds 16 bytes (128 bits) of memory.'),
('QE10', 'Rate the following choices on how well they correspond with a number variable holding 4 bytes (32 bits) of memory.', 'A number variable that holds 4 bytes (32 bits) of memory.'),
('QE11', 'Rate the following choices on how well they correspond with a number variable holding 8 bytes (64 bits) of memory.', 'A number variable that holds 8 bytes (64 bits) of memory.'),
('QE12', 'Rate the following choices on how well they correspond with a number variable holding 16 bytes (128 bits) of memory.', 'A number variable that holds 16 bytes (128 bits) of memory.'),
('QE1', 'Suppose that we need a word that will tell the computer that we are about to create a distinct set of items from a category. Rate how well each word represents this concept.', 'Representing a distinct set of items in a category'),
('QE2', 'Suppose that the computer needs a way to determine that one word has ended and another one is going to begin.  Rate each of the following choices as to how well you think they accomplish separating three words', 'Separating words'),
('QE3', 'Suppose that we have a set of distinct words and we want to assign a value to each word. The computer needs to know how these values are going to be assigned. Rate each of the following choices as to how well you think it represents assigning a value to three words.', 'Assigning a value to a word'),
('QE4', 'Suppose that there is a set of words and the computer needs to know what type of value it is giving each word. Rate each of the following options on how well it corresponds with telling the computer to assign a type of value.', 'Assigning a type of value');

-- --------------------------------------------------------

--
-- Table structure for table `survey`
--

CREATE TABLE `survey` (
  `id` int(11) NOT NULL,
  `uuid` varchar(60) DEFAULT NULL,
  `totalxp` int(11) DEFAULT NULL,
  `jobxp` int(11) DEFAULT NULL,
  `education` char(25) DEFAULT NULL,
  `institution` varchar(255) DEFAULT NULL,
  `major` varchar(255) DEFAULT NULL,
  `degree` varchar(255) DEFAULT NULL,
  `year` char(25) DEFAULT NULL,
  `gpa` char(25) DEFAULT NULL,
  `origin` char(30) DEFAULT NULL,
  `language` char(30) DEFAULT NULL,
  `fluency` int(11) DEFAULT NULL,
  `colorBlind` tinyint(1) DEFAULT NULL,
  `lowVisual` tinyint(1) DEFAULT NULL,
  `blind` tinyint(1) DEFAULT NULL,
  `lowAural` tinyint(1) DEFAULT NULL,
  `deaf` tinyint(1) DEFAULT NULL,
  `motorImpaired` tinyint(1) DEFAULT NULL,
  `learning` tinyint(1) DEFAULT NULL,
  `age` int(11) DEFAULT NULL,
  `gender` char(10) DEFAULT NULL,
  `internxp` int(11) DEFAULT NULL,
  `lang1` int(11) DEFAULT NULL,
  `lang2` int(11) DEFAULT NULL,
  `lang3` int(11) DEFAULT NULL,
  `lang4` int(11) DEFAULT NULL,
  `lang5` int(11) DEFAULT NULL,
  `lang6` int(11) DEFAULT NULL,
  `lang7` int(11) DEFAULT NULL,
  `lang8` int(11) DEFAULT NULL,
  `lang9` int(11) DEFAULT NULL,
  `lang10` int(11) DEFAULT NULL,
  `lang11` int(11) DEFAULT NULL,
  `lang12` int(11) DEFAULT NULL,
  `lang13` int(11) DEFAULT NULL,
  `lang14` int(11) DEFAULT NULL,
  `lang15` int(11) DEFAULT NULL,
  `lang16` int(11) DEFAULT NULL,
  `lang17` int(11) DEFAULT NULL,
  `course1` char(10) DEFAULT NULL,
  `course2` char(10) DEFAULT NULL,
  `course3` char(10) DEFAULT NULL,
  `course4` char(10) DEFAULT NULL,
  `course5` char(10) DEFAULT NULL,
  `course6` char(10) DEFAULT NULL,
  `course7` char(10) DEFAULT NULL,
  `course8` char(10) DEFAULT NULL,
  `course9` char(10) DEFAULT NULL,
  `course10` char(10) DEFAULT NULL,
  `course11` char(10) DEFAULT NULL,
  `course12` char(10) DEFAULT NULL,
  `course13` char(10) DEFAULT NULL,
  `course14` char(10) DEFAULT NULL,
  `course15` char(10) DEFAULT NULL,
  `course16` char(10) DEFAULT NULL,
  `course17` char(10) DEFAULT NULL,
  `course18` char(10) DEFAULT NULL,
  `course19` char(10) DEFAULT NULL,
  `concepts` text,
  `design` text,
  `comments` text,
  `lang18` int(11) DEFAULT NULL,
  `lang19` int(11) DEFAULT NULL,
  `lang20` int(11) DEFAULT NULL,
  `lang21` int(11) DEFAULT NULL,
  `lang22` int(11) DEFAULT NULL,
  `lang23` int(11) DEFAULT NULL,
  `lang24` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `survey`
--

INSERT INTO `survey` (`id`, `uuid`, `totalxp`, `jobxp`, `education`, `institution`, `major`, `degree`, `year`, `gpa`, `origin`, `language`, `fluency`, `colorBlind`, `lowVisual`, `blind`, `lowAural`, `deaf`, `motorImpaired`, `learning`, `age`, `gender`, `internxp`, `lang1`, `lang2`, `lang3`, `lang4`, `lang5`, `lang6`, `lang7`, `lang8`, `lang9`, `lang10`, `lang11`, `lang12`, `lang13`, `lang14`, `lang15`, `lang16`, `lang17`, `course1`, `course2`, `course3`, `course4`, `course5`, `course6`, `course7`, `course8`, `course9`, `course10`, `course11`, `course12`, `course13`, `course14`, `course15`, `course16`, `course17`, `course18`, `course19`, `concepts`, `design`, `comments`, `lang18`, `lang19`, `lang20`, `lang21`, `lang22`, `lang23`, `lang24`) VALUES
(56, '5aaaa8e399808', 12, 12, 'Ph. D.', 'unlv', 'cs', 'cs', 'Graduate', '3.50-4.00', 'United States', 'English', -1, 0, 0, 0, 0, 0, 0, 0, 12, 'Other', 12, 1, 2, 3, 4, 5, 6, 1, 2, 3, 4, 5, 6, 1, 2, 3, 4, 5, 'Complete', 'Enrolled', 'N/A', 'Enrolled', 'Complete', 'Enrolled', 'N/A', 'Enrolled', 'Complete', 'Enrolled', 'N/A', 'Enrolled', 'Complete', 'Enrolled', 'N/A', 'Enrolled', 'Complete', 'Enrolled', 'N/A', NULL, NULL, NULL, 6, 1, 2, 3, 4, 5, 6),
(57, '5aab56976f586', 123, 12, 'Some college / university', '1234', '1234', '1324', 'Not Applicable', '2.50-2.99', 'Albania', 'French', 2, 0, 0, 0, 0, 0, 0, 0, 123, 'Male', 124, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', NULL, NULL, NULL, 0, 0, 0, 0, 0, 0, 0),
(58, '5aab56976f586', 1, 1, 'Bachelor Degree', '1', '1', '1', 'Freshman', '2.50-2.99', 'Algeria', 'French', 4, 0, 0, 0, 0, 0, 0, 0, 99, 'Male', 13412, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', NULL, NULL, NULL, 0, 0, 0, 0, 0, 0, 0);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `codes`
--
ALTER TABLE `codes`
  ADD PRIMARY KEY (`code`),
  ADD UNIQUE KEY `code` (`code`);

--
-- Indexes for table `events`
--
ALTER TABLE `events`
  ADD PRIMARY KEY (`eventid`);

--
-- Indexes for table `extrasurvey`
--
ALTER TABLE `extrasurvey`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `language`
--
ALTER TABLE `language`
  ADD PRIMARY KEY (`year`);

--
-- Indexes for table `participants`
--
ALTER TABLE `participants`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `questionoption`
--
ALTER TABLE `questionoption`
  ADD PRIMARY KEY (`optionname`,`question`);

--
-- Indexes for table `survey`
--
ALTER TABLE `survey`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `events`
--
ALTER TABLE `events`
  MODIFY `eventid` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14705;

--
-- AUTO_INCREMENT for table `extrasurvey`
--
ALTER TABLE `extrasurvey`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `participants`
--
ALTER TABLE `participants`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=59;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
