-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Nov 02, 2025 at 12:17 AM
-- Server version: 8.0.30
-- PHP Version: 8.2.7

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `pbl1`
--

-- --------------------------------------------------------

--
-- Table structure for table `announcement`
--

CREATE TABLE `announcement` (
  `id` int NOT NULL,
  `title` varchar(100) NOT NULL,
  `content` text NOT NULL,
  `type` enum('test_schedule','test_result','certificate','general') NOT NULL,
  `target_audience` enum('student','admin','all') NOT NULL DEFAULT 'all',
  `event_date` timestamp NULL DEFAULT NULL,
  `pickup_certificate` timestamp NULL DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `announcement`
--

INSERT INTO `announcement` (`id`, `title`, `content`, `type`, `target_audience`, `event_date`, `pickup_certificate`, `created_at`, `updated_at`) VALUES
(2, 'Laporan', 'LAPORAN UNTUK SEMUA', 'general', 'student', '2025-06-01 17:00:00', '2025-06-01 17:00:00', '2025-06-02 14:29:12', '2025-06-03 10:43:35'),
(3, 'Lapor1', 'Lapor', 'test_result', 'student', '2025-06-03 17:00:00', NULL, '2025-06-02 14:36:22', '2025-06-02 14:36:22');

-- --------------------------------------------------------

--
-- Table structure for table `failed_jobs`
--

CREATE TABLE `failed_jobs` (
  `id` bigint UNSIGNED NOT NULL,
  `uuid` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `connection` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `queue` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `exception` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `majors`
--

CREATE TABLE `majors` (
  `id` int NOT NULL,
  `name` varchar(100) NOT NULL,
  `code` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `majors`
--

INSERT INTO `majors` (`id`, `name`, `code`) VALUES
(1, 'Information Technology', '1'),
(2, 'aka', '31212');

-- --------------------------------------------------------

--
-- Table structure for table `migrations`
--

CREATE TABLE `migrations` (
  `id` int UNSIGNED NOT NULL,
  `migration` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `migrations`
--

INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
(1, '2014_10_12_000000_create_users_table', 1),
(2, '2014_10_12_100000_create_password_reset_tokens_table', 1),
(3, '2019_08_19_000000_create_failed_jobs_table', 1),
(4, '2019_12_14_000001_create_personal_access_tokens_table', 1),
(5, '2025_05_23_040137_add_username_to_users_table', 2),
(6, '2025_05_23_153209_create_announcements_table', 3);

-- --------------------------------------------------------

--
-- Table structure for table `password_reset_tokens`
--

CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `password_reset_tokens`
--

INSERT INTO `password_reset_tokens` (`email`, `token`, `created_at`) VALUES
('sujono@gmail.com', '$2y$12$Cz6izyc1oezdGkTMNmkE1.BbmVBk1PB6YbXXX3oi3DZT.RyRKo2gS', '2025-05-23 04:30:52');

-- --------------------------------------------------------

--
-- Table structure for table `personal_access_tokens`
--

CREATE TABLE `personal_access_tokens` (
  `id` bigint UNSIGNED NOT NULL,
  `tokenable_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tokenable_id` bigint UNSIGNED NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `abilities` text COLLATE utf8mb4_unicode_ci,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `study_programs`
--

CREATE TABLE `study_programs` (
  `id` int NOT NULL,
  `name` varchar(100) NOT NULL,
  `code` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `study_programs`
--

INSERT INTO `study_programs` (`id`, `name`, `code`) VALUES
(1, 'Bussiness Infromation System', '1'),
(2, 'ssasa', '1213213');

-- --------------------------------------------------------

--
-- Table structure for table `toeic_registration`
--

CREATE TABLE `toeic_registration` (
  `id` int NOT NULL,
  `nim` varchar(20) NOT NULL,
  `status` enum('free','paid') NOT NULL,
  `registration_date` date NOT NULL,
  `score` int DEFAULT NULL,
  `certificate_path` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `toeic_registration`
--

INSERT INTO `toeic_registration` (`id`, `nim`, `status`, `registration_date`, `score`, `certificate_path`) VALUES
(1, '323232342', 'paid', '2025-06-03', NULL, NULL),
(2, '214215512', 'paid', '2025-06-03', NULL, NULL),
(3, '2123213132321', 'paid', '2025-06-03', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `toeic_scores`
--

CREATE TABLE `toeic_scores` (
  `id` int NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `pdf` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `toeic_scores`
--

INSERT INTO `toeic_scores` (`id`, `created_at`, `pdf`, `updated_at`) VALUES
(1, '2025-06-03 11:07:19', 'toeic_pdfs/jDbcUCHR82vrHwMSNg6DvYdHPpUzJ9ErxvDnIZTI.pdf', '2025-06-03 11:07:19');

-- --------------------------------------------------------

--
-- Table structure for table `user`
--

CREATE TABLE `user` (
  `id` int NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `email` varchar(100) NOT NULL,
  `role_name` varchar(50) NOT NULL,
  `role_description` text,
  `nim` varchar(20) NOT NULL,
  `name` varchar(100) NOT NULL,
  `nik` varchar(20) NOT NULL,
  `phone` varchar(15) NOT NULL,
  `origin_address` text NOT NULL,
  `current_address` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
  `study_program_id` int DEFAULT NULL,
  `major_id` int DEFAULT NULL,
  `campus` enum('Main','PSDKU Kediri','PSDKU Lumajang','PSDKU Pamekasan') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `photo_path` varchar(255) DEFAULT NULL,
  `id_card_path` varchar(255) DEFAULT NULL,
  `student_card_path` varchar(255) DEFAULT NULL,
  `has_registered_free_toeic` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp(6) NULL DEFAULT NULL,
  `updated_at` timestamp(6) NULL DEFAULT NULL,
  `status` enum('pending','approved','rejected') NOT NULL DEFAULT 'pending',
  `rejection_reason` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `user`
--

INSERT INTO `user` (`id`, `username`, `password`, `email`, `role_name`, `role_description`, `nim`, `name`, `nik`, `phone`, `origin_address`, `current_address`, `study_program_id`, `major_id`, `campus`, `photo_path`, `id_card_path`, `student_card_path`, `has_registered_free_toeic`, `created_at`, `updated_at`, `status`, `rejection_reason`) VALUES
(1, 'safrizal RAHMAN', '$2y$12$lUz2P.BueGMt7..CHf/oCOwsg0O4hSNfGEjaA8V4qk2/u6767LuuC', 'safrizal@gmail.com', 'student', 'Regular student user', '123787281', 'safrizal', '2182817782', '78787878', 'malang', 'malang', 1, 1, 'PSDKU Lumajang', '', NULL, NULL, 0, '2025-05-23 00:13:23.000000', '2025-06-03 03:30:47.000000', 'pending', NULL),
(2, 'sujono', '$2y$12$bjXnYW8Yk97Wq3a0wYUh/OSYtSwS5vMLk10BEV/n8A075Nw.Yezja', 'sujono@gmail.com', 'student', 'Regular student user', '1234214123', 'sujonos', '321908923', '09898310231', 'malang', 'malang', 1, 1, 'PSDKU Lumajang', NULL, NULL, NULL, 0, '2025-05-23 03:37:00.000000', '2025-05-23 03:37:00.000000', 'pending', NULL),
(3, 'admin', '$2y$12$ktGOQzltfsz7JCUPyWWrhumPzgH1AJRr2VCD0VrhHEblPR7Rw3jIO', 'Admin@gmail.com', 'admin', 'System administrator', '-', '-', '-', '-', '-', '-', 1, 1, 'Main', NULL, NULL, NULL, 0, '2025-05-24 06:05:53.000000', '2025-05-24 06:05:53.000000', 'pending', NULL),
(4, 'admin2', '$2y$12$4ylPHgvfoXsIV4yxOG6LKe3JZbucElSwu1htAy6QUv5Q1i8LCeqFK', 'admin2@gmail.com', 'admin', 'System administrator', '-', '-', '-', '-', '-', '-', 1, 1, 'Main', NULL, NULL, NULL, 0, '2025-05-24 06:06:54.000000', '2025-05-24 06:06:54.000000', 'pending', NULL),
(5, 'admin3', '$2y$12$zY8iv3QJV/.hSP6f9Az99ORTorL8oI.8FmjSdZa6.ogrPccCiAxIC', 'Admin3@gmail.com', 'admin', 'System administrator', '-', '-', '-', '-', '-', '-', 1, 1, 'Main', NULL, NULL, NULL, 0, '2025-05-24 06:28:31.000000', '2025-05-24 06:28:31.000000', 'pending', NULL),
(7, 'asas', '$2y$12$IKJHGe5mlrXoy8LHASPNhO/XCdL8xxwBuTHpq6rtlMUE8gF/GqZ5u', 'asas@gmail.com', 'admin', 'System administrator', '-', '-', '-', '-', '-', '-', NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-05-26 19:01:30.000000', '2025-05-26 19:01:30.000000', 'pending', NULL),
(8, 'sasa', '$2y$12$nmyedWQnpnrs7YxyJMnPsuiuzrDbL7yCMBnUIEzPva2Y7A3GJ3BXG', 'sasa@gmail.com', 'educational_staff', 'Educational Staff', '2129192091', 'sasa', '29102019209', '9090909090', 'makang', 'malang', 1, 1, 'Main', 'photos/vzIhEiDghJjhfO81bpI2j5PbJ2dbZrY98gSPFoBk.jpg', 'id_cards/F0YR5Cflf0HSIRXhkaEXj2tGgeDERZo5Ewk6BOeJ.jpg', NULL, 0, '2025-06-02 23:59:40.000000', '2025-06-03 03:25:29.000000', 'pending', NULL),
(9, '21231231', '$2y$12$G4/FU3BVqXHIU89JZkAwaeXNgtiFAea1RLh7rVhUiiiltRqlzkctq', '21231231@example.com', 'educational_staff', NULL, '-', 'kaze', '21231231', '09302930923', 'jskaksjakjq', 'dsdsdsd', NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-06-03 02:57:09.000000', '2025-06-03 02:57:09.000000', 'pending', NULL),
(10, '2132131', '$2y$12$71QcviCXbVskdKn/17Ak9uxmA6CE1jVn6c89q2I5RqbbVcAk1DF3q', '2132131@example.com', 'educational_staff', NULL, '-', 'kaze kagi', '2132131', '082139181639', 'Malang', 'dsadsad', NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-06-03 03:00:23.000000', '2025-06-03 03:00:23.000000', 'pending', NULL),
(11, '21929212', '$2y$12$agptIIFW0IeLc1Da8ysZHup4gE4MyQEg5Bre/0r4jSQ49mc1vKqcu', '21929212@example.com', 'educational_staff', NULL, '-', 'Kurasi', '21929212', '982192189', 'batu', 'Batu sbahshba', NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-06-03 03:29:11.000000', '2025-06-03 03:29:11.000000', 'pending', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` bigint UNSIGNED NOT NULL,
  `username` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `remember_token` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `announcement`
--
ALTER TABLE `announcement`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`);

--
-- Indexes for table `majors`
--
ALTER TABLE `majors`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `password_reset_tokens`
--
ALTER TABLE `password_reset_tokens`
  ADD PRIMARY KEY (`email`);

--
-- Indexes for table `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  ADD KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`);

--
-- Indexes for table `study_programs`
--
ALTER TABLE `study_programs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `toeic_registration`
--
ALTER TABLE `toeic_registration`
  ADD PRIMARY KEY (`id`),
  ADD KEY `nim` (`nim`);

--
-- Indexes for table `toeic_scores`
--
ALTER TABLE `toeic_scores`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`id`),
  ADD KEY `study_program_id` (`study_program_id`),
  ADD KEY `major_id` (`major_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `users_email_unique` (`email`),
  ADD UNIQUE KEY `users_username_unique` (`username`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `announcement`
--
ALTER TABLE `announcement`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `majors`
--
ALTER TABLE `majors`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `study_programs`
--
ALTER TABLE `study_programs`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `toeic_registration`
--
ALTER TABLE `toeic_registration`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `toeic_scores`
--
ALTER TABLE `toeic_scores`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `user`
--
ALTER TABLE `user`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `user`
--
ALTER TABLE `user`
  ADD CONSTRAINT `user_ibfk_1` FOREIGN KEY (`study_program_id`) REFERENCES `study_programs` (`id`),
  ADD CONSTRAINT `user_ibfk_2` FOREIGN KEY (`major_id`) REFERENCES `majors` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
