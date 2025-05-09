-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: May 08, 2025 at 10:51 AM
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
(3, 5, 2),
(4, 6, 11),
(5, 7, 12);

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
  `TeamDescription` varchar(255) DEFAULT NULL,
  `TeamProfileIndex` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `msteam`
--

INSERT INTO `msteam` (`TeamID`, `TeamName`, `TeamCreateDate`, `RoomCode`, `TeamDescription`, `TeamProfileIndex`) VALUES
(2, 'TestingRoomUPT1', '2025-04-02', 'DJ1YS', 'Test 123 Anjay UPT1', 0),
(3, 'makananku yey', '2025-05-05', '8V43P', 'ini isinya makananku semua', 0),
(4, 'Roomnya auryn', '2025-05-05', 'JVFPH', 'Ini room makanan untuk auryn, yang bukan auryn jauh-jauh sana', 0),
(5, 'room apa ya', '2025-05-06', 'UUGZH', 'isinya apa ya', 0),
(6, 'room1', '2025-05-08', 'YI85Y', 'testdesc1', 1),
(10, 'testroom2', '2025-05-08', 'M23LK', 'testdescription2', 4),
(11, 'testroom3', '2025-05-08', '8LPNV', 'roomdescription3', 2),
(12, 'room4', '2025-05-08', 'RKYA3', 'description44444', 4);

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
(5, 'ryn', 'ryn@gmail.com', '123', '0123'),
(6, 'admin', 'admin', '123', '123'),
(7, 'auryn', 'auryn', '123', '09');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `mscollaboration`
--
ALTER TABLE `mscollaboration`
  ADD PRIMARY KEY (`CollabID`);

--
-- Indexes for table `msproduct`
--
ALTER TABLE `msproduct`
  ADD PRIMARY KEY (`ProductID`);

--
-- Indexes for table `msteam`
--
ALTER TABLE `msteam`
  ADD PRIMARY KEY (`TeamID`);

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
  MODIFY `CollabID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `msproduct`
--
ALTER TABLE `msproduct`
  MODIFY `ProductID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `msteam`
--
ALTER TABLE `msteam`
  MODIFY `TeamID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `msuser`
--
ALTER TABLE `msuser`
  MODIFY `UserID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
