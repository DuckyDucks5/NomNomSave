-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: May 15, 2025 at 07:32 AM
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
-- Table structure for table `mscategory`
--

CREATE TABLE `mscategory` (
  `CategoryID` int(11) NOT NULL,
  `CategoryName` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `mscategory`
--

INSERT INTO `mscategory` (`CategoryID`, `CategoryName`) VALUES
(1, 'Bakery & Bread'),
(2, 'Beverages'),
(3, 'Canned & Preserved Food'),
(4, 'Dairy & Eggs'),
(5, 'Frozen Food'),
(6, 'Snack & Sweets'),
(7, 'Spice & Condiments'),
(8, 'Other');

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
(5, 7, 12),
(7, 6, 2),
(8, 13, 13);

-- --------------------------------------------------------

--
-- Table structure for table `msproduct`
--

CREATE TABLE `msproduct` (
  `ProductID` int(11) NOT NULL,
  `ProductName` varchar(20) NOT NULL,
  `ExpiredDate` date NOT NULL,
  `UserUserID` int(11) NOT NULL,
  `TeamTeamID` int(11) DEFAULT NULL,
  `ProductCategoryId` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `msproduct`
--

INSERT INTO `msproduct` (`ProductID`, `ProductName`, `ExpiredDate`, `UserUserID`, `TeamTeamID`, `ProductCategoryId`) VALUES
(4, 'cookies', '2025-05-09', 6, 2, 1),
(5, 'mentai', '2025-05-12', 6, 2, 8),
(6, 'karage', '2025-05-10', 6, 2, 5),
(7, 'telur', '2025-05-19', 13, 13, 4);

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
(4, 'Roomnya auryn', '2025-05-05', 'JVFPH', 'Ini room makanan untuk auryn, yang bukan auryn jauh-jauh sana', 0),
(5, 'room apa ya', '2025-05-06', 'UUGZH', 'isinya apa ya', 0),
(6, 'room1', '2025-05-08', 'YI85Y', 'testdesc1', 1),
(10, 'testroom2', '2025-05-08', 'M23LK', 'testdescription2', 4),
(12, 'room4', '2025-05-08', 'RKYA3', 'description44444', 4),
(13, 'room5', '2025-05-15', 'SWXBU', 'testing yeye', 3);

-- --------------------------------------------------------

--
-- Table structure for table `msuser`
--

CREATE TABLE `msuser` (
  `UserID` int(11) NOT NULL,
  `UserName` varchar(20) NOT NULL,
  `UserEmail` varchar(50) NOT NULL,
  `UserPassword` varchar(50) NOT NULL,
  `UserPhoneNumber` varchar(15) DEFAULT NULL,
  `UserProfileIndex` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `msuser`
--

INSERT INTO `msuser` (`UserID`, `UserName`, `UserEmail`, `UserPassword`, `UserPhoneNumber`, `UserProfileIndex`) VALUES
(1, 'testuser', 'test@example.com', '$2b$10$pKsB2WIM4/r2EoiI4r/hCuIlAGWhTk9fhpHeUSmMSE3', '1234567890', 0),
(3, 'jessica', 'jess123', '$2b$10$pVCT54yNbEoBy706mSuAi.fhN41BCNXJV/sH/.0gcwP', '1234567890', 0),
(5, 'ryn', 'ryn@gmail.com', '123', '0123', 0),
(6, 'admin', 'admin', '123', '123', 0),
(7, 'yura jessica', 'akubisa@gmail.com', '123', '08231', 1),
(8, 'jessica bella', '2005jessicabella@gmail.com', '7654321', '0813', 0),
(10, 'jennie bella', 'bellsjs@gmail.com', '$2b$10$k/SYxWP.BFI08FvvbAKfp.mzHiEqU86sQ06WOmjoFPj', '08123', 0),
(11, 'jisoo bella', 'bellsjsss@gmail.com', '$2b$13$VE93.FfuLk2gloe2b8E1bOLN4pCfyYsggPolm5biwGj', '0812fsdf3', 0),
(12, 'roje bella', 'siapa@gmail.com', '$2b$13$vlHSA4h4M4IRhBmAnt17Keh42l2y244TufY.jpi1sBp', '623434', 0),
(13, 'ryn', 'auryn', '123', '0', 1);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `mscategory`
--
ALTER TABLE `mscategory`
  ADD PRIMARY KEY (`CategoryID`);

--
-- Indexes for table `mscollaboration`
--
ALTER TABLE `mscollaboration`
  ADD PRIMARY KEY (`CollabID`);

--
-- Indexes for table `msproduct`
--
ALTER TABLE `msproduct`
  ADD PRIMARY KEY (`ProductID`),
  ADD KEY `fk_team` (`TeamTeamID`),
  ADD KEY `fk_product_category` (`ProductCategoryId`);

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
  MODIFY `CollabID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `msproduct`
--
ALTER TABLE `msproduct`
  MODIFY `ProductID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `msteam`
--
ALTER TABLE `msteam`
  MODIFY `TeamID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT for table `msuser`
--
ALTER TABLE `msuser`
  MODIFY `UserID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `msproduct`
--
ALTER TABLE `msproduct`
  ADD CONSTRAINT `fk_product_category` FOREIGN KEY (`ProductCategoryId`) REFERENCES `mscategory` (`CategoryID`),
  ADD CONSTRAINT `fk_team` FOREIGN KEY (`TeamTeamID`) REFERENCES `msteam` (`TeamID`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
