-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Apr 02, 2025 at 11:12 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `nomnomsave`
--

-- --------------------------------------------------------

--
-- Table structure for table `mscollaboration`
--

CREATE TABLE `mscollaboration` (
  `CollabID` int(11) NOT NULL,
  `UserUserID` int(11) DEFAULT NULL,
  `TeamTeamID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `mscollaboration`
--

INSERT INTO `mscollaboration` (`CollabID`, `UserUserID`, `TeamTeamID`) VALUES
(2, 1, 2);

-- --------------------------------------------------------

--
-- Table structure for table `msproduct`
--

CREATE TABLE `msproduct` (
  `ProductID` int(11) NOT NULL,
  `ProductName` varchar(20) NOT NULL,
  `ExpiredDate` date NOT NULL,
  `UserUserID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `msteam`
--

CREATE TABLE `msteam` (
  `TeamID` int(11) NOT NULL,
  `TeamName` varchar(20) NOT NULL,
  `TeamCreateDate` date NOT NULL,
  `RoomCode` varchar(10) NOT NULL,
  `TeamDescription` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `msteam`
--

INSERT INTO `msteam` (`TeamID`, `TeamName`, `TeamCreateDate`, `RoomCode`, `TeamDescription`) VALUES
(2, 'TestingRoomUPT1', '2025-04-02', 'DJ1YS', 'Test 123 Anjay UPT1');

-- --------------------------------------------------------

--
-- Table structure for table `msuser`
--

CREATE TABLE `msuser` (
  `UserID` int(11) NOT NULL,
  `UserName` varchar(20) NOT NULL,
  `UserEmail` varchar(50) NOT NULL,
  `UserPassword` varchar(50) NOT NULL,
  `UserPhoneNumber` varchar(15) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `msuser`
--

INSERT INTO `msuser` (`UserID`, `UserName`, `UserEmail`, `UserPassword`, `UserPhoneNumber`) VALUES
(1, 'testuser', 'test@example.com', '$2b$10$pKsB2WIM4/r2EoiI4r/hCuIlAGWhTk9fhpHeUSmMSE3', '1234567890'),
(3, 'jessica', 'jess123', '$2b$10$pVCT54yNbEoBy706mSuAi.fhN41BCNXJV/sH/.0gcwP', '1234567890'),
(4, 'auryn', 'auryn', '123', '1234567890');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `mscollaboration`
--
ALTER TABLE `mscollaboration`
  ADD PRIMARY KEY (`CollabID`),
  ADD KEY `UserUserID` (`UserUserID`),
  ADD KEY `TeamTeamID` (`TeamTeamID`);

--
-- Indexes for table `msproduct`
--
ALTER TABLE `msproduct`
  ADD PRIMARY KEY (`ProductID`),
  ADD KEY `UserUserID` (`UserUserID`);

--
-- Indexes for table `msteam`
--
ALTER TABLE `msteam`
  ADD PRIMARY KEY (`TeamID`),
  ADD UNIQUE KEY `RoomCode` (`RoomCode`);

--
-- Indexes for table `msuser`
--
ALTER TABLE `msuser`
  ADD PRIMARY KEY (`UserID`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `mscollaboration`
--
ALTER TABLE `mscollaboration`
  MODIFY `CollabID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `msteam`
--
ALTER TABLE `msteam`
  MODIFY `TeamID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `msuser`
--
ALTER TABLE `msuser`
  MODIFY `UserID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `mscollaboration`
--
ALTER TABLE `mscollaboration`
  ADD CONSTRAINT `mscollaboration_ibfk_1` FOREIGN KEY (`UserUserID`) REFERENCES `msuser` (`UserID`) ON DELETE CASCADE,
  ADD CONSTRAINT `mscollaboration_ibfk_2` FOREIGN KEY (`TeamTeamID`) REFERENCES `msteam` (`TeamID`) ON DELETE CASCADE;

--
-- Constraints for table `msproduct`
--
ALTER TABLE `msproduct`
  ADD CONSTRAINT `msproduct_ibfk_1` FOREIGN KEY (`UserUserID`) REFERENCES `msuser` (`UserID`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
