-- ============================================================
-- 后台管理系统脚本 —— 管理员账号表 + 默认账号
-- 数据库：springboot_test（MySQL 8.0，root/123456）
-- 用法：mysql -uroot -p123456 --default-character-set=utf8mb4 < sql/admin_system.sql
-- 幂等：表与账号均有存在性判断，可重复执行
--
-- 默认管理员账号：admin / 123456
-- 加密规则与后端 PasswordUtil 一致：password = SHA-256(salt + 明文密码)
--   salt = a1b2c3d4e5f60718293a4b5c6d7e8f90
--   hash = 457a2ff654a76ac5a19ce5a4e04e5c54ad717e94712db4dc28d54c03d13c452b
-- ============================================================

CREATE DATABASE IF NOT EXISTS springboot_test
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_general_ci;

USE springboot_test;

-- 1) 后台管理员账号表（与前台会员表 sys_user 相互独立）
CREATE TABLE IF NOT EXISTS `sys_admin` (
  `id`            BIGINT      NOT NULL AUTO_INCREMENT COMMENT '主键',
  `username`      VARCHAR(50) NOT NULL COMMENT '登录账号（唯一）',
  `password`      VARCHAR(100) NOT NULL COMMENT '密码（加盐 SHA-256 哈希）',
  `salt`          VARCHAR(50) NOT NULL COMMENT '密码盐值',
  `nickname`      VARCHAR(50) NOT NULL DEFAULT '' COMMENT '显示昵称',
  `status`        TINYINT     NOT NULL DEFAULT 1 COMMENT '状态：1 启用 0 停用',
  `last_login_at` DATETIME    NULL COMMENT '最后登录时间',
  `created_at`    DATETIME    DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`    DATETIME    DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_admin_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='后台管理员账号表';

-- 2) 默认管理员账号：admin / 123456（不存在才插入）
INSERT INTO `sys_admin` (`username`, `password`, `salt`, `nickname`, `status`)
SELECT 'admin',
       '457a2ff654a76ac5a19ce5a4e04e5c54ad717e94712db4dc28d54c03d13c452b',
       'a1b2c3d4e5f60718293a4b5c6d7e8f90',
       '系统管理员',
       1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `sys_admin` WHERE `username` = 'admin');

-- 3) 核对
--    SELECT id, username, nickname, status, last_login_at FROM sys_admin;

-- 附：若忘记密码，可用下面的语句重置为 123456（salt 与 admin 保持一致）
--    UPDATE `sys_admin`
--       SET `salt` = 'a1b2c3d4e5f60718293a4b5c6d7e8f90',
--           `password` = '457a2ff654a76ac5a19ce5a4e04e5c54ad717e94712db4dc28d54c03d13c452b'
--     WHERE `username` = 'admin';
