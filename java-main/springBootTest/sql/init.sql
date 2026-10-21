-- ============================================================
-- springBootTest 初始化脚本（注册/登录功能 · 完整版）
-- 数据库：springboot_test
-- 账号：root / 123456（本地 MySQL 8.0）
-- 用法：mysql -uroot -p123456 --default-character-set=utf8mb4 < sql/init.sql
-- 可重复执行（幂等）：库、表用 IF NOT EXISTS，演示账号用条件插入
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
  `password`   VARCHAR(100) NOT NULL COMMENT '密码（加盐 SHA-256 哈希）',
  `salt`       VARCHAR(50)  NOT NULL COMMENT '密码盐值',
  `created_at` DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='系统用户表';

-- 3) 演示账号（不存在才插入）
--    用户名：admin
--    密码：  admin123
--    加密规则与后端 PasswordUtil 一致：password = SHA-256(salt + 明文密码)
INSERT INTO `sys_user` (`username`, `password`, `salt`)
SELECT 'admin',
       '6a65e9fc69984d6dbb31378c4c63fbb52ca164cd2b20215190aae7e5369b1a3c',
       '0f1e2d3c4b5a69788796a5b4c3d2e1f0'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `sys_user` WHERE `username` = 'admin');

-- 4) 验证
--    SELECT id, username, created_at FROM sys_user;
