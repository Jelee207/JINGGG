-- ============================================================
-- springBootTest 初始化脚本（注册/登录功能 · 完整版）
-- 数据库：springboot_test
-- 账号：root / 123456（本地 MySQL 8.0）
-- 用法：mysql -uroot -p123456 --default-character-set=utf8mb4 < sql/init.sql
-- 可重复执行（幂等）：库、表用 IF NOT EXISTS；字段变更用信息_schema 判断；演示账号用条件插入/更新
-- ============================================================

-- 1) 建库（不存在才创建）
CREATE DATABASE IF NOT EXISTS springboot_test
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_general_ci;

USE springboot_test;

-- 2) 用户表
CREATE TABLE IF NOT EXISTS `sys_user` (
  `id`         BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
  `username`   VARCHAR(50)  NOT NULL COMMENT '用户名（唯一）',
  `password`   VARCHAR(100) NOT NULL COMMENT '密码（明文存储，不加密）',
  `permission` INT          NOT NULL DEFAULT 1 COMMENT '权限：0 管理员，1 默认会员',
  `created_at` DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='系统用户表';

-- 2.1) 兼容已存在的旧表：新增 permission 字段（若不存在）
SET @db = 'springboot_test';
SET @tbl = 'sys_user';
SET @col_perm = 'permission';
SET @perm_exists = (
  SELECT COUNT(*) FROM information_schema.columns
  WHERE table_schema = @db AND table_name = @tbl AND column_name = @col_perm
);
SET @sql_perm = IF(@perm_exists = 0,
  "ALTER TABLE sys_user ADD COLUMN permission INT NOT NULL DEFAULT 1 COMMENT '权限：0 管理员，1 默认会员'",
  'SELECT 1');
PREPARE stmt_perm FROM @sql_perm;
EXECUTE stmt_perm;
DEALLOCATE PREPARE stmt_perm;

-- 2.2) 兼容旧表：移除 salt 列（密码改为明文，不再需要盐值）
SET @col_salt = 'salt';
SET @salt_exists = (
  SELECT COUNT(*) FROM information_schema.columns
  WHERE table_schema = @db AND table_name = @tbl AND column_name = @col_salt
);
SET @sql_salt = IF(@salt_exists > 0,
  'ALTER TABLE sys_user DROP COLUMN salt',
  'SELECT 1');
PREPARE stmt_salt FROM @sql_salt;
EXECUTE stmt_salt;
DEALLOCATE PREPARE stmt_salt;

-- 3) 演示管理员账号（权限 0），密码明文 admin123
--    不存在则插入；已存在则确保其为管理员且密码为明文，避免旧哈希导致无法登录
INSERT INTO `sys_user` (`username`, `password`, `permission`)
SELECT 'admin', 'admin123', 0
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `sys_user` WHERE `username` = 'admin');

UPDATE `sys_user`
   SET `password` = 'admin123', `permission` = 0
 WHERE `username` = 'admin';

-- 4) 验证
--    SELECT id, username, permission, created_at FROM sys_user;
