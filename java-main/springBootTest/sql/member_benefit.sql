-- ============================================================
-- AURELIA CLUB · 会员专属福利 —— 建表 + 演示数据脚本
-- 数据库：springboot_test（MySQL 8.0，root/123456）
-- 用法：mysql -uroot -p123456 --default-character-set=utf8mb4 < sql/member_benefit.sql
-- 幂等：表/列/数据均有存在性判断，可重复执行
--
-- 三张表：
--   mb_discount     会员专属折扣（卡券权益）
--   mb_goods        会员专属好物（会员购商品）
--   mb_user_coupon  会员卡包（已领取的折扣券）
-- 另：sys_user 扩展会员等级 / 积分 / 有效期三列
-- ============================================================

CREATE DATABASE IF NOT EXISTS springboot_test
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_general_ci;

USE springboot_test;

-- 1) 会员专属折扣：餐饮 / 旅行 / 购物 / 生活 / 文娱
CREATE TABLE IF NOT EXISTS `mb_discount` (
  `id`            BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
  `title`         VARCHAR(100) NOT NULL COMMENT '折扣标题',
  `brand`         VARCHAR(60)  NOT NULL DEFAULT '' COMMENT '品牌/商户',
  `category`      VARCHAR(30)  NOT NULL DEFAULT '' COMMENT '分类：餐饮/旅行/购物/生活/文娱',
  `discount_type` VARCHAR(20)  NOT NULL DEFAULT 'RATE' COMMENT '优惠类型：RATE折扣 / AMOUNT满减 / SPECIAL会员价',
  `discount_rate` DECIMAL(4, 2)  NOT NULL DEFAULT 1.00 COMMENT '折扣率，0.85 表示 8.5 折',
  `min_amount`    DECIMAL(10, 2) NOT NULL DEFAULT 0 COMMENT '满减门槛金额',
  `minus_amount`  DECIMAL(10, 2) NOT NULL DEFAULT 0 COMMENT '满减优惠金额',
  `original_price` DECIMAL(10, 2) NOT NULL DEFAULT 0 COMMENT '参考原价',
  `member_price`  DECIMAL(10, 2) NOT NULL DEFAULT 0 COMMENT '会员到手价',
  `emoji`         VARCHAR(10)  NOT NULL DEFAULT '✦' COMMENT '封面图标',
  `tags`          VARCHAR(100) NOT NULL DEFAULT '' COMMENT '标签，逗号分隔',
  `description`   VARCHAR(255) NOT NULL DEFAULT '' COMMENT '权益说明',
  `level_limit`   VARCHAR(20)  NOT NULL DEFAULT 'ALL' COMMENT '适用等级：ALL / GOLD / PLATINUM / BLACK',
  `stock`         INT          NOT NULL DEFAULT 0 COMMENT '剩余可领份数',
  `claims`        INT          NOT NULL DEFAULT 0 COMMENT '已领取数量',
  `valid_from`    DATE         NULL COMMENT '生效日期',
  `valid_until`   DATE         NULL COMMENT '失效日期',
  `status`        TINYINT      NOT NULL DEFAULT 1 COMMENT '状态：1 上架 0 下架',
  `sort_weight`   INT          NOT NULL DEFAULT 0 COMMENT '排序权重，越大越靠前',
  `created_at`    DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`    DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_category` (`category`),
  KEY `idx_status_sort` (`status`, `sort_weight`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='会员专属折扣表';

-- 2) 会员专属好物（类似会员购的商品货架）
CREATE TABLE IF NOT EXISTS `mb_goods` (
  `id`             BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name`           VARCHAR(100) NOT NULL COMMENT '商品名称',
  `subtitle`       VARCHAR(160) NOT NULL DEFAULT '' COMMENT '副标题/卖点',
  `category`       VARCHAR(30)  NOT NULL DEFAULT '' COMMENT '分类：手办潮玩/数码影音/生活方式/美妆香氛/藏书文创',
  `emoji`          VARCHAR(10)  NOT NULL DEFAULT '◈' COMMENT '商品主图（图标占位）',
  `tags`           VARCHAR(100) NOT NULL DEFAULT '' COMMENT '标签，逗号分隔',
  `original_price` DECIMAL(10, 2) NOT NULL DEFAULT 0 COMMENT '原价',
  `member_price`   DECIMAL(10, 2) NOT NULL DEFAULT 0 COMMENT '会员专享价',
  `points_price`   INT          NOT NULL DEFAULT 0 COMMENT '纯积分兑换所需积分，0 表示不支持',
  `stock`          INT          NOT NULL DEFAULT 0 COMMENT '库存',
  `sales`          INT          NOT NULL DEFAULT 0 COMMENT '累计销量',
  `rating`         DECIMAL(2, 1) NOT NULL DEFAULT 5.0 COMMENT '评分',
  `level_limit`    VARCHAR(20)  NOT NULL DEFAULT 'ALL' COMMENT '适用等级：ALL / GOLD / PLATINUM / BLACK',
  `status`         TINYINT      NOT NULL DEFAULT 1 COMMENT '状态：1 上架 0 下架',
  `sort_weight`    INT          NOT NULL DEFAULT 0 COMMENT '排序权重，越大越靠前',
  `created_at`     DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`     DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_category` (`category`),
  KEY `idx_status_sort` (`status`, `sort_weight`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='会员专属好物表';

-- 3) 会员卡包：领取折扣后生成的券
CREATE TABLE IF NOT EXISTS `mb_user_coupon` (
  `id`           BIGINT      NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id`      BIGINT      NOT NULL COMMENT '领取会员 ID',
  `discount_id`  BIGINT      NOT NULL COMMENT '所属折扣 ID',
  `coupon_code`  VARCHAR(24) NOT NULL COMMENT '券码',
  `status`       TINYINT     NOT NULL DEFAULT 0 COMMENT '状态：0 未使用 1 已核销 2 已过期',
  `claimed_at`   DATETIME    DEFAULT CURRENT_TIMESTAMP COMMENT '领取时间',
  `used_at`      DATETIME    NULL COMMENT '核销时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_coupon_code` (`coupon_code`),
  KEY `idx_user_status` (`user_id`, `status`),
  KEY `idx_discount` (`discount_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='会员卡包表';

-- 4) sys_user 扩展会员字段（幂等：逐列判断后再 ALTER）
DROP PROCEDURE IF EXISTS `proc_mb_add_user_cols`;
DELIMITER $$
CREATE PROCEDURE `proc_mb_add_user_cols`()
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'sys_user' AND COLUMN_NAME = 'member_level'
  ) THEN
    ALTER TABLE `sys_user`
      ADD COLUMN `member_level` VARCHAR(20) NOT NULL DEFAULT 'GOLD' COMMENT '会员等级' AFTER `salt`;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'sys_user' AND COLUMN_NAME = 'points'
  ) THEN
    ALTER TABLE `sys_user`
      ADD COLUMN `points` INT NOT NULL DEFAULT 0 COMMENT '会员积分' AFTER `member_level`;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'sys_user' AND COLUMN_NAME = 'member_expire_at'
  ) THEN
    ALTER TABLE `sys_user`
      ADD COLUMN `member_expire_at` DATE NULL COMMENT '会员有效期' AFTER `points`;
  END IF;
END$$
DELIMITER ;
CALL `proc_mb_add_user_cols`();
DROP PROCEDURE IF EXISTS `proc_mb_add_user_cols`;

-- 首次接入时，给已存在的账号补一份演示会员信息（有效期为空视为首次）
UPDATE `sys_user`
SET `member_level`    = 'GOLD',
    `points`          = 12480,
    `member_expire_at` = '2027-12-31'
WHERE `member_expire_at` IS NULL;

-- ============================================================
-- 5) 演示数据（仅当对应表为空时插入，避免重复执行堆积）
-- ============================================================

SET @mb_has_discount = (SELECT COUNT(*) FROM `mb_discount`);

INSERT INTO `mb_discount`
  (`title`, `brand`, `category`, `discount_type`, `discount_rate`, `min_amount`, `minus_amount`,
   `original_price`, `member_price`, `emoji`, `tags`, `description`,
   `level_limit`, `stock`, `claims`, `valid_from`, `valid_until`, `status`, `sort_weight`)
SELECT '米其林三星 · 双人品鉴晚宴', 'Léonarde 法餐厅', '餐饮', 'RATE', 0.85, 0.00, 0.00,
       2880.00, 2448.00, '🍷', '热门,需提前预约',
       '八道式主厨菜单配侍酒师选酒，会员到手价 2448 元，含双人香槟开胃酒。',
       'ALL', 30, 0, '2026-11-01', '2027-06-30', 1, 100
FROM DUAL WHERE @mb_has_discount = 0;

INSERT INTO `mb_discount`
  (`title`, `brand`, `category`, `discount_type`, `discount_rate`, `min_amount`, `minus_amount`,
   `original_price`, `member_price`, `emoji`, `tags`, `description`,
   `level_limit`, `stock`, `claims`, `valid_from`, `valid_until`, `status`, `sort_weight`)
SELECT '亚太航线 · 公务舱升舱礼遇', 'AURELIA Travel', '旅行', 'AMOUNT', 1.00, 8000.00, 1200.00,
       9800.00, 8600.00, '✈️', '限量,单程',
       '单笔机票满 8000 元立减 1200 元，含专属值机通道与贵宾休息室权益。',
       'GOLD', 12, 0, '2026-10-20', '2027-03-31', 1, 95
FROM DUAL WHERE @mb_has_discount = 0;

INSERT INTO `mb_discount`
  (`title`, `brand`, `category`, `discount_type`, `discount_rate`, `min_amount`, `minus_amount`,
   `original_price`, `member_price`, `emoji`, `tags`, `description`,
   `level_limit`, `stock`, `claims`, `valid_from`, `valid_until`, `status`, `sort_weight`)
SELECT '私享购物日 · 全场 8 折', '连卡佛 Lane Crawford', '购物', 'RATE', 0.80, 0.00, 0.00,
       5000.00, 4000.00, '🛍️', '独家,双倍积分',
       '闭店专场导购陪同选购，会员享全场 8 折并叠加双倍积分返还。',
       'ALL', 80, 0, '2026-10-16', '2027-12-31', 1, 90
FROM DUAL WHERE @mb_has_discount = 0;

INSERT INTO `mb_discount`
  (`title`, `brand`, `category`, `discount_type`, `discount_rate`, `min_amount`, `minus_amount`,
   `original_price`, `member_price`, `emoji`, `tags`, `description`,
   `level_limit`, `stock`, `claims`, `valid_from`, `valid_until`, `status`, `sort_weight`)
SELECT '安缦 SPA · 双人疗愈套餐', 'Aman Spa', '生活', 'RATE', 0.70, 0.00, 0.00,
       4680.00, 3276.00, '💆', '口碑,周末可用',
       '120 分钟双人山泉疗愈与热石按摩，周末与节假日通用，含双人下午茶。',
       'GOLD', 20, 0, '2026-10-16', '2027-09-30', 1, 88
FROM DUAL WHERE @mb_has_discount = 0;

INSERT INTO `mb_discount`
  (`title`, `brand`, `category`, `discount_type`, `discount_rate`, `min_amount`, `minus_amount`,
   `original_price`, `member_price`, `emoji`, `tags`, `description`,
   `level_limit`, `stock`, `claims`, `valid_from`, `valid_until`, `status`, `sort_weight`)
SELECT '私人包厢观演 · 交响乐团专场', '上海交响乐团', '文娱', 'SPECIAL', 1.00, 0.00, 0.00,
       1980.00, 1580.00, '🎭', '席位紧张',
       '二楼私人包厢六座含中场酒水，后台导览与乐手签名节目单。',
       'ALL', 15, 0, '2026-11-15', '2027-05-31', 1, 85
FROM DUAL WHERE @mb_has_discount = 0;

INSERT INTO `mb_discount`
  (`title`, `brand`, `category`, `discount_type`, `discount_rate`, `min_amount`, `minus_amount`,
   `original_price`, `member_price`, `emoji`, `tags`, `description`,
   `level_limit`, `stock`, `claims`, `valid_from`, `valid_until`, `status`, `sort_weight`)
SELECT '精品咖啡豆年卡 · 每月直送', '明前手冲研究所', '生活', 'RATE', 0.75, 0.00, 0.00,
       1680.00, 1260.00, '☕', '包邮,可续订',
       '十二期单一庄园豆按月冷链直送，附产地手记与冲煮参数卡。',
       'ALL', 50, 0, '2026-10-16', '2027-12-31', 1, 80
FROM DUAL WHERE @mb_has_discount = 0;

INSERT INTO `mb_discount`
  (`title`, `brand`, `category`, `discount_type`, `discount_rate`, `min_amount`, `minus_amount`,
   `original_price`, `member_price`, `emoji`, `tags`, `description`,
   `level_limit`, `stock`, `claims`, `valid_from`, `valid_until`, `status`, `sort_weight`)
SELECT '奢华酒店联盟 · 住三付二', '全球奢华酒店联盟', '旅行', 'SPECIAL', 1.00, 0.00, 0.00,
       12000.00, 8000.00, '🏨', '爆款,长住推荐',
       '安缦 / 六善等成员酒店连住三晚仅付两晚，含双人早餐与 100 美元消费额度。',
       'PLATINUM', 8, 0, '2026-12-01', '2027-11-30', 1, 92
FROM DUAL WHERE @mb_has_discount = 0;

INSERT INTO `mb_discount`
  (`title`, `brand`, `category`, `discount_type`, `discount_rate`, `min_amount`, `minus_amount`,
   `original_price`, `member_price`, `emoji`, `tags`, `description`,
   `level_limit`, `stock`, `claims`, `valid_from`, `valid_until`, `status`, `sort_weight`)
SELECT '酒庄直采香槟 · 整箱立减', 'Maison AURELIA', '餐饮', 'AMOUNT', 1.00, 3000.00, 600.00,
       3600.00, 3000.00, '🍾', '新上架',
       '勃艮第名家年份香槟整箱 6 支，满 3000 元立减 600 元并附恒温酒柜配送。',
       'ALL', 40, 0, '2026-10-16', '2027-08-31', 1, 70
FROM DUAL WHERE @mb_has_discount = 0;

SET @mb_has_goods = (SELECT COUNT(*) FROM `mb_goods`);

INSERT INTO `mb_goods`
  (`name`, `subtitle`, `category`, `emoji`, `tags`, `original_price`, `member_price`, `points_price`,
   `stock`, `sales`, `rating`, `level_limit`, `status`, `sort_weight`)
SELECT '限定和风手办 · 锦鲤姬 1/7', '会员专属限量编号 / 附收藏证书', '手办潮玩', '🎎', '会员专享,限量编号',
       1999.00, 1499.00, 149900, 60, 328, 4.9, 'ALL', 1, 100
FROM DUAL WHERE @mb_has_goods = 0;

INSERT INTO `mb_goods`
  (`name`, `subtitle`, `category`, `emoji`, `tags`, `original_price`, `member_price`, `points_price`,
   `stock`, `sales`, `rating`, `level_limit`, `status`, `sort_weight`)
SELECT '联名降噪头戴耳机', '主动降噪 / 40 小时续航', '数码影音', '🎧', '新品,直降460',
       2299.00, 1839.00, 183900, 120, 856, 4.8, 'ALL', 1, 96
FROM DUAL WHERE @mb_has_goods = 0;

INSERT INTO `mb_goods`
  (`name`, `subtitle`, `category`, `emoji`, `tags`, `original_price`, `member_price`, `points_price`,
   `stock`, `sales`, `rating`, `level_limit`, `status`, `sort_weight`)
SELECT '东方调 · 沉香香氛礼盒', '三支装香氛 + 扩香石', '美妆香氛', '🕯️', '热销,礼盒装',
       899.00, 679.00, 67900, 200, 1240, 4.7, 'ALL', 1, 94
FROM DUAL WHERE @mb_has_goods = 0;

INSERT INTO `mb_goods`
  (`name`, `subtitle`, `category`, `emoji`, `tags`, `original_price`, `member_price`, `points_price`,
   `stock`, `sales`, `rating`, `level_limit`, `status`, `sort_weight`)
SELECT '典藏 · 浮世绘复刻版画集', '限印 1000 册 / 编号藏书票', '藏书文创', '📚', '限印,编号',
       699.00, 559.00, 55900, 80, 412, 4.9, 'ALL', 1, 88
FROM DUAL WHERE @mb_has_goods = 0;

INSERT INTO `mb_goods`
  (`name`, `subtitle`, `category`, `emoji`, `tags`, `original_price`, `member_price`, `points_price`,
   `stock`, `sales`, `rating`, `level_limit`, `status`, `sort_weight`)
SELECT '手作银壶 · 工夫茶具组', '匠人手打 / 含公道杯双杯', '生活方式', '🫖', '手作,单件孤品',
       2680.00, 1980.00, 198000, 15, 96, 5.0, 'GOLD', 1, 92
FROM DUAL WHERE @mb_has_goods = 0;

INSERT INTO `mb_goods`
  (`name`, `subtitle`, `category`, `emoji`, `tags`, `original_price`, `member_price`, `points_price`,
   `stock`, `sales`, `rating`, `level_limit`, `status`, `sort_weight`)
SELECT '山羊绒 · 双面水波纹围巾', '内蒙白绒山羊 / 会员礼盒', '生活方式', '🧣', '秋冬新品',
       1580.00, 1180.00, 118000, 150, 603, 4.6, 'ALL', 1, 84
FROM DUAL WHERE @mb_has_goods = 0;

INSERT INTO `mb_goods`
  (`name`, `subtitle`, `category`, `emoji`, `tags`, `original_price`, `member_price`, `points_price`,
   `stock`, `sales`, `rating`, `level_limit`, `status`, `sort_weight`)
SELECT '限定编号钢笔 + 皮面手账', '14K 金尖 / 意大利植鞣皮', '藏书文创', '🖋️', '会员限定',
       1080.00, 788.00, 78800, 60, 271, 4.8, 'ALL', 1, 82
FROM DUAL WHERE @mb_has_goods = 0;

INSERT INTO `mb_goods`
  (`name`, `subtitle`, `category`, `emoji`, `tags`, `original_price`, `member_price`, `points_price`,
   `stock`, `sales`, `rating`, `level_limit`, `status`, `sort_weight`)
SELECT '限量版无线手柄 · 会员主题', '附专属动态主题与收纳包', '数码影音', '🎮', '首发预售',
       799.00, 599.00, 59900, 300, 1890, 4.7, 'ALL', 1, 80
FROM DUAL WHERE @mb_has_goods = 0;

-- 6) 执行结果核对
--    SELECT (SELECT COUNT(*) FROM mb_discount) AS discounts,
--           (SELECT COUNT(*) FROM mb_goods)    AS goods,
--           (SELECT COUNT(*) FROM mb_user_coupon) AS coupons;
--    SELECT id, username, member_level, points, member_expire_at FROM sys_user;
