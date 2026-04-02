-- =============================================
-- Arya Samaj Community App — Database Schema
-- Version: 1.0 | MySQL 8.0 | InnoDB
-- Tables: 24 | Generated: 2025
-- =============================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS=0;

-- ── 1. MIGRATIONS ────────────────────────────────────────────────────────────
CREATE TABLE `migrations` (
  `id`        INT UNSIGNED    NOT NULL AUTO_INCREMENT,
  `migration` VARCHAR(255)    NOT NULL,
  `batch`     INT             NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ── 2. CACHE ─────────────────────────────────────────────────────────────────
CREATE TABLE `cache` (
  `key`        VARCHAR(255)  NOT NULL,
  `value`      MEDIUMTEXT    NOT NULL,
  `expiration` INT           NOT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ── 3. CACHE_LOCKS ───────────────────────────────────────────────────────────
CREATE TABLE `cache_locks` (
  `key`        VARCHAR(255)  NOT NULL,
  `owner`      VARCHAR(255)  NOT NULL,
  `expiration` INT           NOT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ── 4. SESSIONS ──────────────────────────────────────────────────────────────
CREATE TABLE `sessions` (
  `id`            VARCHAR(255)          NOT NULL,
  `user_id`       BIGINT UNSIGNED       NULL,
  `ip_address`    VARCHAR(45)           NULL,
  `user_agent`    TEXT                  NULL,
  `payload`       LONGTEXT              NOT NULL,
  `last_activity` INT                   NOT NULL,
  PRIMARY KEY (`id`),
  KEY `sessions_last_activity_index` (`last_activity`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ── 5. JOBS ───────────────────────────────────────────────────────────────────
CREATE TABLE `jobs` (
  `id`           BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `queue`        VARCHAR(255)     NOT NULL,
  `payload`      LONGTEXT         NOT NULL,
  `attempts`     TINYINT UNSIGNED NOT NULL DEFAULT 0,
  `reserved_at`  INT UNSIGNED     NULL,
  `available_at` INT UNSIGNED     NOT NULL,
  `created_at`   INT UNSIGNED     NOT NULL,
  PRIMARY KEY (`id`),
  KEY `jobs_queue_index` (`queue`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ── 6. FAILED_JOBS ───────────────────────────────────────────────────────────
CREATE TABLE `failed_jobs` (
  `id`         BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `uuid`       VARCHAR(255)     NOT NULL,
  `connection` TEXT             NOT NULL,
  `queue`      TEXT             NOT NULL,
  `payload`    LONGTEXT         NOT NULL,
  `exception`  LONGTEXT         NOT NULL,
  `failed_at`  TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ── 7. JOB_BATCHES ───────────────────────────────────────────────────────────
CREATE TABLE `job_batches` (
  `id`             VARCHAR(255)  NOT NULL,
  `name`           VARCHAR(255)  NOT NULL,
  `total_jobs`     INT           NOT NULL,
  `pending_jobs`   INT           NOT NULL,
  `failed_jobs`    INT           NOT NULL,
  `failed_job_ids` LONGTEXT      NOT NULL,
  `options`        MEDIUMTEXT    NULL,
  `cancelled_at`   INT           NULL,
  `created_at`     INT           NOT NULL,
  `finished_at`    INT           NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ── 8. ADMINS ─────────────────────────────────────────────────────────────────
CREATE TABLE `admins` (
  `id`             BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `name`           VARCHAR(100)     NOT NULL,
  `email`          VARCHAR(100)     NOT NULL,
  `password`       VARCHAR(255)     NOT NULL,
  `remember_token` VARCHAR(100)     NULL,
  `created_at`     TIMESTAMP        NULL,
  `updated_at`     TIMESTAMP        NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `admins_email_unique` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ── 9. USERS ──────────────────────────────────────────────────────────────────
CREATE TABLE `users` (
  `id`               BIGINT UNSIGNED                      NOT NULL AUTO_INCREMENT,
  `name`             VARCHAR(100)                         NULL,
  `phone`            VARCHAR(15)                          NOT NULL,
  `email`            VARCHAR(100)                         NULL,
  `profile_complete` TINYINT(1)                           NOT NULL DEFAULT 0,
  `is_verified`      TINYINT(1)                           NOT NULL DEFAULT 0,
  `status`           ENUM('active','blocked')             NOT NULL DEFAULT 'active',
  `profile_views`    INT UNSIGNED                         NOT NULL DEFAULT 0,
  `fcm_token`        VARCHAR(255)                         NULL,
  `state`            VARCHAR(100)                         NULL,
  `district`         VARCHAR(100)                         NULL,
  `city`             VARCHAR(100)                         NULL,
  `address`          TEXT                                 NULL,
  `bio`              TEXT                                 NULL,
  `occupation`       VARCHAR(100)                         NULL,
  `date_of_birth`    DATE                                 NULL,
  `gender`           ENUM('male','female','other')        NULL,
  `profile_photo`    VARCHAR(255)                         NULL,
  `remember_token`   VARCHAR(100)                         NULL,
  `created_at`       TIMESTAMP                            NULL,
  `updated_at`       TIMESTAMP                            NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_phone_unique`  (`phone`),
  UNIQUE KEY `users_email_unique`  (`email`),
  KEY `users_state_index`            (`state`),
  KEY `users_district_index`         (`district`),
  KEY `users_status_profile_index`   (`status`, `profile_complete`),
  KEY `users_is_verified_index`      (`is_verified`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ── 10. OTP_LOGS ─────────────────────────────────────────────────────────────
CREATE TABLE `otp_logs` (
  `id`         BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `phone`      VARCHAR(15)      NOT NULL,
  `otp_hash`   VARCHAR(64)      NOT NULL,
  `expires_at` TIMESTAMP        NOT NULL,
  `is_used`    TINYINT(1)       NOT NULL DEFAULT 0,
  `created_at` TIMESTAMP        NULL,
  `updated_at` TIMESTAMP        NULL,
  PRIMARY KEY (`id`),
  KEY `otp_logs_phone_index`      (`phone`),
  KEY `otp_logs_expires_at_index` (`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ── 11. PERSONAL_ACCESS_TOKENS (Laravel Sanctum) ─────────────────────────────
CREATE TABLE `personal_access_tokens` (
  `id`             BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `tokenable_type` VARCHAR(255)     NOT NULL,
  `tokenable_id`   BIGINT UNSIGNED  NOT NULL,
  `name`           VARCHAR(255)     NOT NULL,
  `token`          VARCHAR(64)      NOT NULL,
  `abilities`      TEXT             NULL,
  `last_used_at`   TIMESTAMP        NULL,
  `expires_at`     TIMESTAMP        NULL,
  `created_at`     TIMESTAMP        NULL,
  `updated_at`     TIMESTAMP        NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  KEY `personal_access_tokens_tokenable_index` (`tokenable_type`, `tokenable_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ── 12. FEATURES ─────────────────────────────────────────────────────────────
CREATE TABLE `features` (
  `id`          BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `name`        VARCHAR(100)     NOT NULL,
  `name_hindi`  VARCHAR(100)     NULL,
  `icon`        VARCHAR(255)     NULL,
  `route`       VARCHAR(100)     NOT NULL,
  `section`     VARCHAR(50)      NOT NULL DEFAULT 'main',
  `sort_order`  INT UNSIGNED     NOT NULL DEFAULT 0,
  `is_active`   TINYINT(1)       NOT NULL DEFAULT 1,
  `created_at`  TIMESTAMP        NULL,
  `updated_at`  TIMESTAMP        NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ── 13. CATEGORIES (self-referencing — FK added via ALTER below) ──────────────
CREATE TABLE `categories` (
  `id`         BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `name`       VARCHAR(100)     NOT NULL,
  `slug`       VARCHAR(120)     NOT NULL,
  `icon`       VARCHAR(255)     NULL,
  `type`       VARCHAR(50)      NULL,
  `parent_id`  BIGINT UNSIGNED  NULL,
  `has_child`  TINYINT(1)       NOT NULL DEFAULT 0,
  `sort_order` INT UNSIGNED     NOT NULL DEFAULT 0,
  `is_active`  TINYINT(1)       NOT NULL DEFAULT 1,
  `created_at` TIMESTAMP        NULL,
  `updated_at` TIMESTAMP        NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `categories_slug_unique` (`slug`),
  KEY `categories_parent_id_index` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ── 14. CONTENTS ─────────────────────────────────────────────────────────────
CREATE TABLE `contents` (
  `id`               BIGINT UNSIGNED                              NOT NULL AUTO_INCREMENT,
  `title`            VARCHAR(255)                                 NOT NULL,
  `description`      TEXT                                         NULL,
  `type`             ENUM('pdf','audio','video','image','text')   NOT NULL,
  `file_path`        VARCHAR(500)                                 NULL,
  `thumbnail_path`   VARCHAR(500)                                 NULL,
  `author`           VARCHAR(100)                                 NULL,
  `category_id`      BIGINT UNSIGNED                              NULL,
  `uploaded_by`      BIGINT UNSIGNED                              NULL,
  `status`           ENUM('active','inactive')                    NOT NULL DEFAULT 'active',
  `view_count`       INT UNSIGNED                                 NOT NULL DEFAULT 0,
  `download_count`   INT UNSIGNED                                 NOT NULL DEFAULT 0,
  `created_at`       TIMESTAMP                                    NULL,
  `updated_at`       TIMESTAMP                                    NULL,
  PRIMARY KEY (`id`),
  KEY `contents_type_status_index`   (`type`, `status`),
  KEY `contents_category_id_index`   (`category_id`),
  CONSTRAINT `contents_category_id_fk`  FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE SET NULL,
  CONSTRAINT `contents_uploaded_by_fk` FOREIGN KEY (`uploaded_by`)  REFERENCES `admins`     (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ── 15. EVENTS ───────────────────────────────────────────────────────────────
CREATE TABLE `events` (
  `id`          BIGINT UNSIGNED                                      NOT NULL AUTO_INCREMENT,
  `title`       VARCHAR(255)                                         NOT NULL,
  `description` TEXT                                                 NULL,
  `event_date`  DATETIME                                             NOT NULL,
  `location`    VARCHAR(255)                                         NULL,
  `image_path`  VARCHAR(500)                                         NULL,
  `status`      ENUM('upcoming','ongoing','past','cancelled')        NOT NULL DEFAULT 'upcoming',
  `created_by`  BIGINT UNSIGNED                                      NULL,
  `created_at`  TIMESTAMP                                            NULL,
  `updated_at`  TIMESTAMP                                            NULL,
  PRIMARY KEY (`id`),
  KEY `events_status_date_index` (`status`, `event_date`),
  CONSTRAINT `events_created_by_fk` FOREIGN KEY (`created_by`) REFERENCES `admins` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ── 16. DONATION_ACCOUNTS ────────────────────────────────────────────────────
CREATE TABLE `donation_accounts` (
  `id`             BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `type`           VARCHAR(50)      NOT NULL DEFAULT 'bank',
  `account_name`   VARCHAR(100)     NULL,
  `account_number` VARCHAR(30)      NULL,
  `ifsc_code`      VARCHAR(20)      NULL,
  `upi_id`         VARCHAR(100)     NULL,
  `image_url`      VARCHAR(500)     NULL,
  `is_active`      TINYINT(1)       NOT NULL DEFAULT 1,
  `created_at`     TIMESTAMP        NULL,
  `updated_at`     TIMESTAMP        NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ── 17. DONATIONS ────────────────────────────────────────────────────────────
CREATE TABLE `donations` (
  `id`                   BIGINT UNSIGNED                      NOT NULL AUTO_INCREMENT,
  `user_id`              BIGINT UNSIGNED                      NULL,
  `donation_account_id`  BIGINT UNSIGNED                      NULL,
  `amount`               DECIMAL(10,2)                        NOT NULL,
  `razorpay_order_id`    VARCHAR(100)                         NULL,
  `razorpay_payment_id`  VARCHAR(100)                         NULL,
  `status`               ENUM('pending','success','failed')   NOT NULL DEFAULT 'pending',
  `note`                 TEXT                                 NULL,
  `created_at`           TIMESTAMP                            NULL,
  `updated_at`           TIMESTAMP                            NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `donations_user_id_fk`             FOREIGN KEY (`user_id`)             REFERENCES `users`             (`id`) ON DELETE SET NULL,
  CONSTRAINT `donations_donation_account_id_fk` FOREIGN KEY (`donation_account_id`) REFERENCES `donation_accounts` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ── 18. FEEDBACKS ────────────────────────────────────────────────────────────
CREATE TABLE `feedbacks` (
  `id`          BIGINT UNSIGNED                              NOT NULL AUTO_INCREMENT,
  `user_id`     BIGINT UNSIGNED                              NULL,
  `type`        ENUM('suggestion','bug','praise')            NOT NULL DEFAULT 'suggestion',
  `message`     TEXT                                         NOT NULL,
  `status`      ENUM('pending','reviewed','resolved')        NOT NULL DEFAULT 'pending',
  `admin_note`  TEXT                                         NULL,
  `created_at`  TIMESTAMP                                    NULL,
  `updated_at`  TIMESTAMP                                    NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `feedbacks_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ── 19. MEMBER_CATEGORIES ────────────────────────────────────────────────────
CREATE TABLE `member_categories` (
  `id`         BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `name`       VARCHAR(100)     NOT NULL,
  `group`      VARCHAR(50)      NULL,
  `created_at` TIMESTAMP        NULL,
  `updated_at` TIMESTAMP        NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ── 20. MEMBER_CATEGORY_USER (pivot) ─────────────────────────────────────────
CREATE TABLE `member_category_user` (
  `user_id`            BIGINT UNSIGNED  NOT NULL,
  `member_category_id` BIGINT UNSIGNED  NOT NULL,
  PRIMARY KEY (`user_id`, `member_category_id`),
  CONSTRAINT `mcu_user_id_fk`            FOREIGN KEY (`user_id`)            REFERENCES `users`            (`id`) ON DELETE CASCADE,
  CONSTRAINT `mcu_member_category_id_fk` FOREIGN KEY (`member_category_id`) REFERENCES `member_categories` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ── 21. MEMBER_IMAGES ────────────────────────────────────────────────────────
CREATE TABLE `member_images` (
  `id`         BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `user_id`    BIGINT UNSIGNED  NOT NULL,
  `image_path` VARCHAR(500)     NOT NULL,
  `sort_order` INT UNSIGNED     NOT NULL DEFAULT 0,
  `created_at` TIMESTAMP        NULL,
  `updated_at` TIMESTAMP        NULL,
  PRIMARY KEY (`id`),
  KEY `member_images_user_id_index` (`user_id`),
  CONSTRAINT `member_images_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ── 22. PROFILE_VIEW_LOGS ────────────────────────────────────────────────────
CREATE TABLE `profile_view_logs` (
  `id`             BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `viewed_user_id` BIGINT UNSIGNED  NOT NULL,
  `viewer_ip`      VARCHAR(45)      NOT NULL,
  `viewed_at`      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `profile_view_logs_viewed_user_id_index` (`viewed_user_id`),
  CONSTRAINT `profile_view_logs_viewed_user_id_fk` FOREIGN KEY (`viewed_user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ── 23. NOTIFICATIONS (Laravel standard) ─────────────────────────────────────
CREATE TABLE `notifications` (
  `id`              CHAR(36)         NOT NULL,
  `type`            VARCHAR(255)     NOT NULL,
  `notifiable_type` VARCHAR(255)     NOT NULL,
  `notifiable_id`   BIGINT UNSIGNED  NOT NULL,
  `data`            JSON             NOT NULL,
  `read_at`         TIMESTAMP        NULL,
  `created_at`      TIMESTAMP        NULL,
  `updated_at`      TIMESTAMP        NULL,
  PRIMARY KEY (`id`),
  KEY `notifications_notifiable_index` (`notifiable_type`, `notifiable_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ── 24. PUSH_NOTIFICATION_LOGS ───────────────────────────────────────────────
CREATE TABLE `push_notification_logs` (
  `id`         BIGINT UNSIGNED                      NOT NULL AUTO_INCREMENT,
  `title`      VARCHAR(255)                         NOT NULL,
  `body`       TEXT                                 NOT NULL,
  `target`     ENUM('all','specific')               NOT NULL DEFAULT 'all',
  `user_id`    BIGINT UNSIGNED                      NULL,
  `status`     ENUM('sent','failed')                NOT NULL DEFAULT 'sent',
  `sent_at`    TIMESTAMP                            NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_at` TIMESTAMP                            NULL,
  `updated_at` TIMESTAMP                            NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `push_notification_logs_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ── Self-referencing FK: categories.parent_id ────────────────────────────────
ALTER TABLE `categories`
  ADD CONSTRAINT `categories_parent_id_fk`
    FOREIGN KEY (`parent_id`) REFERENCES `categories` (`id`) ON DELETE SET NULL;

-- ─────────────────────────────────────────────────────────────────────────────
-- SAMPLE DATA
-- ─────────────────────────────────────────────────────────────────────────────

-- Admin (password: Admin@123456  — bcrypt hash)
INSERT INTO `admins` (`name`, `email`, `password`, `created_at`, `updated_at`) VALUES
('Admin', 'admin@aryasamaj.site', '$2y$12$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', NOW(), NOW());

-- Features: Sangathan section
INSERT INTO `features` (`name`, `name_hindi`, `icon`, `route`, `section`, `sort_order`, `is_active`, `created_at`, `updated_at`) VALUES
('Satsang',   'सत्संग',   'satsang.png',   '/events',     'features_sangathan', 1, 1, NOW(), NOW()),
('Yagya',     'यज्ञ',     'yagya.png',     '/events',     'features_sangathan', 2, 1, NOW(), NOW()),
('Pravachan', 'प्रवचन',   'pravachan.png', '/categories', 'features_sangathan', 3, 1, NOW(), NOW());

-- Features: Suvidha section
INSERT INTO `features` (`name`, `name_hindi`, `icon`, `route`, `section`, `sort_order`, `is_active`, `created_at`, `updated_at`) VALUES
('Library', 'पुस्तकालय', 'library.png', '/library', 'features_suvidha', 1, 1, NOW(), NOW()),
('Members', 'सदस्य',     'members.png', '/members', 'features_suvidha', 2, 1, NOW(), NOW()),
('Events',  'कार्यक्रम', 'events.png',  '/events',  'features_suvidha', 3, 1, NOW(), NOW());

-- Categories
INSERT INTO `categories` (`name`, `slug`, `icon`, `type`, `parent_id`, `has_child`, `sort_order`, `is_active`, `created_at`, `updated_at`) VALUES
('Bhajan',    'bhajan',    'bhajan.png',    'audio', NULL, 0, 1, 1, NOW(), NOW()),
('Pravachan', 'pravachan', 'pravachan.png', 'video', NULL, 0, 2, 1, NOW(), NOW());

-- Donation account (bank + UPI)
INSERT INTO `donation_accounts` (`type`, `account_name`, `account_number`, `ifsc_code`, `upi_id`, `image_url`, `is_active`, `created_at`, `updated_at`) VALUES
('bank', 'Arya Samaj Trust', '123456789012', 'SBIN0001234', 'aryasamaj@upi', NULL, 1, NOW(), NOW()),
('upi',  'Arya Samaj UPI',   NULL,           NULL,          'trust@aryasamaj', NULL, 1, NOW(), NOW());

-- Member categories
INSERT INTO `member_categories` (`name`, `group`, `created_at`, `updated_at`) VALUES
('Vyavsayi',  'profession', NOW(), NOW()),
('Adhyapak',  'profession', NOW(), NOW());

SET FOREIGN_KEY_CHECKS=1;
