-- phpMyAdmin SQL Dump
-- version 4.6.4
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: May 31, 2020 at 03:12 PM
-- Server version: 5.7.15
-- PHP Version: 5.5.38

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `application_db`
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
(12, 'codeGiveup'),
(13, 'codeTimeup'),
(14, 'sampleSwitch'),
(15, 'acceptConsentSurvey'),
(16, 'declineConsentSurvey'),
(17, 'acknowledgeSurveyInfo'),
(18, 'surveyQuestionFinished'),
(19, 'extraSurveyDone'),
(20, 'extraSurveyStart'),
(21, 'extraSurveyValidationError'),
(22, 'scrollSample'),
(23, 'clickSample'),
(24, 'keyDownEntry'),
(25, 'clickEntry'),
(26, 'pasteEntry');

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
  `output` text,
  `eyetrackertime` bigint(20) DEFAULT NULL,
  `valid` tinyint(1) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Stand-in structure for view `events_share`
-- (See below for the actual view)
--
CREATE TABLE `events_share` (
`eventid` int(11)
,`uuid` varchar(60)
,`event` int(11)
,`time` timestamp
,`task` int(11)
,`entry` text
,`output` text
,`eyetrackertime` bigint(20)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `exit_survey_answers_filtered`
-- (See below for the actual view)
--
CREATE TABLE `exit_survey_answers_filtered` (
`uuid` varchar(60)
,`lang` int(11)
,`year` char(25)
,`concepts` text
,`design` text
,`comments` text
,`codeswitch` text
);

-- --------------------------------------------------------

--
-- Table structure for table `language`
--

CREATE TABLE `language` (
  `year` char(25) NOT NULL,
  `nextLanguage` int(11) NOT NULL,
  `Lang1` tinyint(1) NOT NULL DEFAULT '0',
  `Lang2` tinyint(1) NOT NULL DEFAULT '0',
  `Lang3` tinyint(1) NOT NULL DEFAULT '0',
  `numL1` int(11) DEFAULT NULL,
  `numL2` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `language`
--

INSERT INTO `language` (`year`, `nextLanguage`, `Lang1`, `Lang2`, `Lang3`, `numL1`, `numL2`) VALUES
('Freshman', 0, 0, 0, 0, NULL, NULL),
('Graduate', 0, 0, 0, 0, NULL, NULL),
('Junior', 0, 0, 0, 0, NULL, NULL),
('Non-degree seeking', 0, 0, 0, 0, NULL, NULL),
('Not Applicable', 0, 0, 0, 0, NULL, NULL),
('Post-graduate', 0, 0, 0, 0, NULL, NULL),
('Professional', 0, 0, 0, 0, NULL, NULL),
('Senior', 0, 0, 0, 0, NULL, NULL),
('Sophomore', 0, 0, 0, 0, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `participants`
--

CREATE TABLE `participants` (
  `id` int(11) NOT NULL,
  `email` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `courseNum` varchar(255) DEFAULT NULL,
  `courseName` varchar(255) DEFAULT NULL,
  `instructor` varchar(255) DEFAULT NULL,
  `lang` int(11) NOT NULL DEFAULT '0',
  `valid` tinyint(1) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `participation`
--

CREATE TABLE `participation` (
  `id` varchar(60) NOT NULL,
  `time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Stand-in structure for view `summary`
-- (See below for the actual view)
--
CREATE TABLE `summary` (
`id` int(11)
,`year` char(25)
,`lang` int(11)
,`task` int(11)
,`Time` bigint(21)
,`totalxp` int(11)
,`jobxp` int(11)
,`dbclass` char(10)
,`sqlxp` int(11)
,`naturallanguage` char(30)
,`fluency` int(11)
,`gender` char(10)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `summary_share_filtered`
-- (See below for the actual view)
--
CREATE TABLE `summary_share_filtered` (
`uuid` varchar(60)
,`year` char(25)
,`lang` int(11)
,`task` int(11)
,`Time` bigint(21)
,`totalxp` int(11)
,`jobxp` int(11)
,`dbclass` char(10)
,`sqlxp` int(11)
,`englishmain` int(1)
,`fluency` int(11)
);

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
  `course20` char(10) DEFAULT NULL,
  `concepts` text,
  `design` text,
  `comments` text,
  `codeswitch` text,
  `lang18` int(11) DEFAULT NULL,
  `lang19` int(11) DEFAULT NULL,
  `lang20` int(11) DEFAULT NULL,
  `lang21` int(11) DEFAULT NULL,
  `lang22` int(11) DEFAULT NULL,
  `lang23` int(11) DEFAULT NULL,
  `lang24` int(11) DEFAULT NULL,
  `valid` tinyint(1) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Stand-in structure for view `tasksums`
-- (See below for the actual view)
--
CREATE TABLE `tasksums` (
`id` int(11)
,`tasksum` decimal(32,0)
);

-- --------------------------------------------------------

--
-- Structure for view `events_share`
--
DROP TABLE IF EXISTS `events_share`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `events_share`  AS  select `events`.`eventid` AS `eventid`,`events`.`uuid` AS `uuid`,`events`.`event` AS `event`,`events`.`time` AS `time`,`events`.`task` AS `task`,`events`.`entry` AS `entry`,`events`.`output` AS `output`,`events`.`eyetrackertime` AS `eyetrackertime` from (((select `participants`.`id` AS `id`,`participants`.`lang` AS `lang` from `participants` where ((`participants`.`valid` = 1) and (`participants`.`email` like '%@%')))) `p1` left join `events` on((`p1`.`id` = `events`.`id`))) ;

-- --------------------------------------------------------

--
-- Structure for view `exit_survey_answers_filtered`
--
DROP TABLE IF EXISTS `exit_survey_answers_filtered`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `exit_survey_answers_filtered`  AS  select `survey`.`uuid` AS `uuid`,`participants`.`lang` AS `lang`,`survey`.`year` AS `year`,`survey`.`concepts` AS `concepts`,`survey`.`design` AS `design`,`survey`.`comments` AS `comments`,`survey`.`codeswitch` AS `codeswitch` from (`survey` join `participants` on((`survey`.`id` = `participants`.`id`))) where ((`participants`.`valid` = 1) and (`participants`.`email` like '%@%')) ;

-- --------------------------------------------------------

--
-- Structure for view `summary`
--
DROP TABLE IF EXISTS `summary`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `summary`  AS  select `A`.`id` AS `id`,`A`.`year` AS `year`,`A`.`lang` AS `lang`,`A`.`task` AS `task`,timestampdiff(SECOND,`A`.`timeBegin`,`B`.`timeEnd`) AS `Time`,`A`.`totalxp` AS `totalxp`,`A`.`jobxp` AS `jobxp`,`A`.`dbclass` AS `dbclass`,`A`.`sqlxp` AS `sqlxp`,`A`.`language` AS `naturallanguage`,`A`.`fluency` AS `fluency`,`A`.`gender` AS `gender` from (((select `events`.`id` AS `id`,`p1`.`lang` AS `lang`,`survey`.`year` AS `year`,min(`events`.`time`) AS `timeBegin`,`events`.`task` AS `task`,`survey`.`totalxp` AS `totalxp`,`survey`.`jobxp` AS `jobxp`,`survey`.`course20` AS `dbclass`,`survey`.`lang24` AS `sqlxp`,`survey`.`language` AS `language`,`survey`.`gender` AS `gender`,`survey`.`fluency` AS `fluency` from ((`events` join `survey` on((`events`.`id` = `survey`.`id`))) join `participants` `p1` on((`p1`.`id` = `events`.`id`))) where ((`events`.`event` = 6) and (`p1`.`valid` = 1)) group by `survey`.`year`,`events`.`id`,`events`.`task`)) `A` join (select `events`.`id` AS `id`,`p2`.`lang` AS `lang`,`survey`.`year` AS `year`,min(`events`.`time`) AS `timeEnd`,`events`.`task` AS `task` from ((`events` join `survey` on((`events`.`id` = `survey`.`id`))) join `participants` `p2` on((`p2`.`id` = `events`.`id`))) where (((`events`.`event` = 8) or (`events`.`event` = 13)) and (`p2`.`valid` = 1)) group by `survey`.`year`,`events`.`id`,`events`.`task`) `B` on(((`A`.`year` = `B`.`year`) and (`A`.`id` = `B`.`id`) and (`A`.`task` = `B`.`task`)))) group by `A`.`id`,`A`.`task`,`A`.`year`,`A`.`lang` ;

-- --------------------------------------------------------

--
-- Structure for view `summary_share_filtered`
--
DROP TABLE IF EXISTS `summary_share_filtered`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `summary_share_filtered`  AS  select `A`.`uuid` AS `uuid`,`A`.`year` AS `year`,`A`.`lang` AS `lang`,`A`.`task` AS `task`,timestampdiff(SECOND,`A`.`timeBegin`,`B`.`timeEnd`) AS `Time`,`A`.`totalxp` AS `totalxp`,`A`.`jobxp` AS `jobxp`,`A`.`dbclass` AS `dbclass`,`A`.`sqlxp` AS `sqlxp`,(`A`.`language` = 'English') AS `englishmain`,`A`.`fluency` AS `fluency` from (((select `events`.`uuid` AS `uuid`,`p1`.`lang` AS `lang`,`survey`.`year` AS `year`,min(`events`.`time`) AS `timeBegin`,`events`.`task` AS `task`,`survey`.`totalxp` AS `totalxp`,`survey`.`jobxp` AS `jobxp`,`survey`.`course20` AS `dbclass`,`survey`.`lang24` AS `sqlxp`,`survey`.`language` AS `language`,`survey`.`fluency` AS `fluency` from ((`events` join `survey` on((`events`.`uuid` = `survey`.`uuid`))) join `participants` `p1` on((`p1`.`id` = `events`.`id`))) where ((`events`.`event` = 6) and (`p1`.`valid` = 1) and (`p1`.`email` like '%@%')) group by `survey`.`year`,`events`.`uuid`,`events`.`task`,`p1`.`lang`,`survey`.`totalxp`,`survey`.`jobxp`,`survey`.`course20`,`survey`.`lang24`,`survey`.`fluency`,`survey`.`language`)) `A` join (select `events`.`uuid` AS `uuid`,`p2`.`lang` AS `lang`,`survey`.`year` AS `year`,min(`events`.`time`) AS `timeEnd`,`events`.`task` AS `task` from ((`events` join `survey` on((`events`.`uuid` = `survey`.`uuid`))) join `participants` `p2` on((`p2`.`id` = `events`.`id`))) where (((`events`.`event` = 8) or (`events`.`event` = 13)) and (`p2`.`valid` = 1)) group by `survey`.`year`,`events`.`uuid`,`events`.`task`,`p2`.`lang`) `B` on(((`A`.`year` = `B`.`year`) and (`A`.`uuid` = `B`.`uuid`) and (`A`.`task` = `B`.`task`)))) group by `A`.`uuid`,`A`.`task`,`A`.`year`,`A`.`lang`,`A`.`timeBegin`,`B`.`timeEnd`,`A`.`totalxp`,`A`.`jobxp`,`A`.`dbclass`,`A`.`sqlxp`,`A`.`language`,`A`.`fluency` ;

-- --------------------------------------------------------

--
-- Structure for view `tasksums`
--
DROP TABLE IF EXISTS `tasksums`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `tasksums`  AS  select `participants`.`id` AS `id`,sum(`events`.`task`) AS `tasksum` from (`participants` join `events` on((`participants`.`id` = `events`.`id`))) where ((`participants`.`valid` = 1) and (`events`.`event` = 6)) group by `participants`.`id` ;

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
  MODIFY `eventid` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1182633;
--
-- AUTO_INCREMENT for table `participants`
--
ALTER TABLE `participants`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=536;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
