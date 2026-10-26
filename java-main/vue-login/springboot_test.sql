/*
 Navicat Premium Dump SQL

 Source Server         : test
 Source Server Type    : MySQL
 Source Server Version : 80039 (8.0.39)
 Source Host           : localhost:3306
 Source Schema         : springboot_test

 Target Server Type    : MySQL
 Target Server Version : 80039 (8.0.39)
 File Encoding         : 65001

 Date: 26/10/2026 11:56:31
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for home_category
-- ----------------------------
DROP TABLE IF EXISTS `home_category`;
CREATE TABLE `home_category`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `icon` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '✦' COMMENT '分类图标（符号/emoji）',
  `name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '分类名称',
  `summary` varchar(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '一句话描述',
  `keyword` varchar(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '点击分类时提交的搜索词',
  `sort_weight` int NOT NULL DEFAULT 0 COMMENT '排序权重，越大越靠前',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：1 启用 0 停用',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_status_sort`(`status` ASC, `sort_weight` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 9 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '首页分类表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of home_category
-- ----------------------------
INSERT INTO `home_category` VALUES (1, '#', '私人礼遇', '管家式定制服务', '私人礼遇', 60, 1, '2026-10-16 16:04:31', '2026-10-26 11:39:36');
INSERT INTO `home_category` VALUES (2, '◈', '餐饮甄选', '米其林主厨餐桌', '餐饮', 55, 1, '2026-10-16 16:04:31', '2026-10-16 16:04:31');
INSERT INTO `home_category` VALUES (3, '✦', '旅行栖居', '全球奢华酒店礼遇', '旅行', 50, 1, '2026-10-16 16:04:31', '2026-10-16 16:04:31');
INSERT INTO `home_category` VALUES (4, '◆', '艺术文化', '私人画廊与沙龙', '艺术', 45, 1, '2026-10-16 16:04:31', '2026-10-16 16:04:31');
INSERT INTO `home_category` VALUES (5, '❋', '健康生活', '高端康养与 SPA', '康养', 40, 1, '2026-10-16 16:04:31', '2026-10-16 16:04:31');
INSERT INTO `home_category` VALUES (6, '✧', '会员活动', '专属线下聚会', '会员活动', 35, 1, '2026-10-16 16:04:31', '2026-10-16 16:04:31');

-- ----------------------------
-- Table structure for home_hot_keyword
-- ----------------------------
DROP TABLE IF EXISTS `home_hot_keyword`;
CREATE TABLE `home_hot_keyword`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `keyword` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '搜索词',
  `heat` int NOT NULL DEFAULT 0 COMMENT '热度值',
  `sort_weight` int NOT NULL DEFAULT 0 COMMENT '排序权重，越大越靠前',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：1 启用 0 停用',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_keyword`(`keyword` ASC) USING BTREE,
  INDEX `idx_status_sort`(`status` ASC, `sort_weight` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '首页热门搜索词表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of home_hot_keyword
-- ----------------------------
INSERT INTO `home_hot_keyword` VALUES (1, '京都赏枫', 986, 40, 1, '2026-10-16 16:06:14', '2026-10-16 16:06:14');
INSERT INTO `home_hot_keyword` VALUES (2, '米其林晚宴', 872, 35, 1, '2026-10-16 16:06:14', '2026-10-16 16:06:14');
INSERT INTO `home_hot_keyword` VALUES (3, '私享游艇', 654, 30, 1, '2026-10-16 16:06:14', '2026-10-16 16:06:14');
INSERT INTO `home_hot_keyword` VALUES (4, '艺术沙龙', 531, 25, 1, '2026-10-16 16:06:14', '2026-10-16 16:06:14');
INSERT INTO `home_hot_keyword` VALUES (5, '康养静修', 418, 20, 1, '2026-10-16 16:06:14', '2026-10-16 16:06:14');
INSERT INTO `home_hot_keyword` VALUES (6, '滑雪木屋', 376, 15, 1, '2026-10-16 16:06:14', '2026-10-16 16:06:14');

-- ----------------------------
-- Table structure for home_post
-- ----------------------------
DROP TABLE IF EXISTS `home_post`;
CREATE TABLE `home_post`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `title` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '标题',
  `summary` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '摘要（列表页展示）',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '正文（列表页不返回）',
  `category` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '所属分类',
  `cover` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '封面图 URL，为空时前端用图标占位',
  `author` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '作者/责编',
  `city` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '关联城市/目的地',
  `read_count` int NOT NULL DEFAULT 0 COMMENT '阅读数',
  `like_count` int NOT NULL DEFAULT 0 COMMENT '点赞数',
  `tags` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '标签，逗号分隔',
  `publish_at` datetime NULL DEFAULT NULL COMMENT '发布时间',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：1 已发布 0 草稿',
  `sort_weight` int NOT NULL DEFAULT 0 COMMENT '排序权重，越大越靠前',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_category`(`category` ASC) USING BTREE,
  INDEX `idx_status_publish`(`status` ASC, `publish_at` ASC) USING BTREE,
  INDEX `idx_title`(`title` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '首页精选内容表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of home_post
-- ----------------------------
INSERT INTO `home_post` VALUES (1, '京都 · 枫叶季私邸栖居七日', '入住百年町家改造私邸，随茶道师体验一期一会的秋日茶席，专车漫游东山暮色。', '全文：十一月的京都，晨雾自鸭川升起。我们为您保留了东山脚下三栋百年町家中的主栋， 随行茶道师将在枯山水庭院铺设席位，以当季和果子佐宇治抹茶。行程含专车接送、 和服私装指导与米其林一星怀石晚宴各一次。', '旅行栖居', '', '编辑部 · 林', '京都', 1820, 236, '旅行,日本,赏枫,私邸', '2026-10-12 09:00:00', 1, 100, '2026-10-16 16:06:14', '2026-10-16 16:06:14');
INSERT INTO `home_post` VALUES (2, '秋暮主厨餐桌 · 八道式品鉴晚宴', '米其林二星主厨应季菜单，侍酒师配对勃艮第名家年份，仅设十二席。', '全文：本季菜单以栗子、鲷鱼与鹿肉为三条主线，主厨将在开放厨房前完成最后一道工序。 侍酒师准备了五款勃艮第村级以上年份配酒，全场仅十二席，须于三日前预订。', '餐饮甄选', '', '编辑部 · 苏', '上海', 2460, 418, '餐饮,米其林,晚宴,品鉴', '2026-10-10 18:30:00', 1, 96, '2026-10-16 16:06:14', '2026-10-16 16:06:14');
INSERT INTO `home_post` VALUES (3, '私人画廊之夜：当代水墨新声', '闭馆专场导览，与艺术家对谈，率先预订限量版画收藏席位。', '全文：美术馆闭馆后两小时，策展人与参展艺术家将以圆桌形式分享创作脉络。 现场开放十二位限量编号版画的优先认购权，附艺术家签名证书。', '艺术文化', '', '编辑部 · 何', '北京', 1140, 173, '艺术,展览,水墨,收藏', '2026-10-08 20:00:00', 1, 92, '2026-10-16 16:06:14', '2026-10-16 16:06:14');
INSERT INTO `home_post` VALUES (4, '黄浦江畔 · 私享游艇酒会', '落日巡游与香槟品鉴，结识同席会员，限额三十位，凭会员码报名。', '全文：自十六铺启航，沿外滩经典航线巡游两小时。船上提供沙龙香槟与轻盈小食， 甲板爵士三重奏现场演奏。限额三十位，请凭会员码提前报名。', '会员活动', '', '编辑部 · 周', '上海', 3080, 502, '活动,游艇,酒会,社交', '2026-10-05 17:00:00', 1, 88, '2026-10-16 16:06:14', '2026-10-16 16:06:14');
INSERT INTO `home_post` VALUES (5, '山间疗愈 · 森林冥想康养营', '三日两夜山居静修，颂钵疗愈与有机轻食，为身心按下暂停键。', '全文：海拔一千二百米的森林腹地，晨起瑜伽与溪畔冥想，午后颂钵与芳疗按摩。 饮食由营养师定制，全部取自五十公里内的有机农场。', '健康生活', '', '编辑部 · 叶', '莫干山', 1360, 288, '康养,SPA,冥想,静修', '2026-10-02 07:00:00', 1, 84, '2026-10-16 16:06:14', '2026-10-16 16:06:14');
INSERT INTO `home_post` VALUES (6, '管家服务升级：全球行程一站托管', '签证、专车、餐厅与活动预订全程代办，您的专属礼宾团队已就位。', '全文：礼宾团队扩充至十二时区覆盖，支持签证代办、私人专机、餐厅与演出票务、 以及行程突发状况的即时响应。会员可通过专属顾问随时呼叫。', '私人礼遇', '', '编辑部 · 林', '全球', 2210, 361, '礼遇,管家,礼宾,出行', '2026-09-28 10:00:00', 1, 80, '2026-10-16 16:06:14', '2026-10-16 16:06:14');
INSERT INTO `home_post` VALUES (7, '阿尔卑斯 · 雪季木屋与私人滑雪教练', '开窗即雪山的双卧木屋，配私人教练与雪场优先通道，含温泉疗愈。', '全文：木屋位于海拔一千八百米的雪场腹地，含独立桑拿与恒温泳池。 配备退役国家队教练一对一指导，并提供雪具寄送与会籍礼遇。', '旅行栖居', '', '编辑部 · 苏', '采尔马特', 1580, 244, '旅行,滑雪,雪山,欧洲', '2026-09-24 09:00:00', 1, 76, '2026-10-16 16:06:14', '2026-10-16 16:06:14');
INSERT INTO `home_post` VALUES (8, '日内瓦高级制表私享品鉴', '独立制表师现场拆解机芯，开放三枚限量作品的优先认购。', '全文：沙龙设于制表工坊二层，制表师将演示陀飞轮装配过程。 现场开放三枚编号作品的优先认购权，附终身保养服务。', '艺术文化', '', '编辑部 · 何', '日内瓦', 980, 156, '腕表,制表,沙龙,收藏', '2026-09-20 15:00:00', 1, 72, '2026-10-16 16:06:14', '2026-10-16 16:06:14');
INSERT INTO `home_post` VALUES (9, '地中海私人岛宴 · 十二席位', '厨师团队包岛定制菜单，日落帆船接送，夜宿临海 villa 套房。', '全文：整座私人小岛当晚仅接待十二位会员，长桌沿崖边铺设。 菜单依据当日渔获即时调整，含私人侍酒师配酒与现场弦乐四重奏。', '餐饮甄选', '', '编辑部 · 周', '卡普里', 1740, 322, '餐饮,私宴,海岛,定制', '2026-09-15 19:00:00', 1, 68, '2026-10-16 16:06:14', '2026-10-16 16:06:14');
INSERT INTO `home_post` VALUES (10, '会员回馈月 · 双倍积分与生日礼遇', '整月消费双倍积分，生日当月额外获赠专属礼盒与蛋糕定制。', '全文：本月所有预订与消费均累计双倍积分，可于会员商城兑换限定好物。 生日当月会员额外获赠定制礼盒、蛋糕与主厨手写贺卡。', '会员活动', '', '编辑部 · 叶', '全球', 4120, 736, '活动,积分,福利,生日', '2026-09-10 11:00:00', 1, 64, '2026-10-16 16:06:14', '2026-10-16 16:06:14');

-- ----------------------------
-- Table structure for mb_discount
-- ----------------------------
DROP TABLE IF EXISTS `mb_discount`;
CREATE TABLE `mb_discount`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '折扣标题',
  `brand` varchar(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '品牌/商户',
  `category` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '分类：餐饮/旅行/购物/生活/文娱',
  `discount_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'RATE' COMMENT '优惠类型：RATE折扣 / AMOUNT满减 / SPECIAL会员价',
  `discount_rate` decimal(4, 2) NOT NULL DEFAULT 1.00 COMMENT '折扣率，0.85 表示 8.5 折',
  `min_amount` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '满减门槛金额',
  `minus_amount` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '满减优惠金额',
  `original_price` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '参考原价',
  `member_price` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '会员到手价',
  `emoji` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '✦' COMMENT '封面图标',
  `tags` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '标签，逗号分隔',
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '权益说明',
  `level_limit` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'ALL' COMMENT '适用等级：ALL / GOLD / PLATINUM / BLACK',
  `stock` int NOT NULL DEFAULT 0 COMMENT '剩余可领份数',
  `claims` int NOT NULL DEFAULT 0 COMMENT '已领取数量',
  `valid_from` date NULL DEFAULT NULL COMMENT '生效日期',
  `valid_until` date NULL DEFAULT NULL COMMENT '失效日期',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：1 上架 0 下架',
  `sort_weight` int NOT NULL DEFAULT 0 COMMENT '排序权重，越大越靠前',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_category`(`category` ASC) USING BTREE,
  INDEX `idx_status_sort`(`status` ASC, `sort_weight` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 9 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '会员专属折扣表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of mb_discount
-- ----------------------------
INSERT INTO `mb_discount` VALUES (1, '米其林三星 · 双人品鉴晚宴', 'Léonarde 法餐厅', '餐饮', 'RATE', 0.85, 0.00, 0.00, 2880.00, 2448.00, '🍷', '热门,需提前预约', '八道式主厨菜单配侍酒师选酒，会员到手价 2448 元，含双人香槟开胃酒。', 'ALL', 30, 0, '2026-11-01', '2027-06-30', 1, 100, '2026-10-16 16:01:18', '2026-10-16 16:01:18');
INSERT INTO `mb_discount` VALUES (2, '亚太航线 · 公务舱升舱礼遇', 'AURELIA Travel', '旅行', 'AMOUNT', 1.00, 8000.00, 1200.00, 9800.00, 8600.00, '✈️', '限量,单程', '单笔机票满 8000 元立减 1200 元，含专属值机通道与贵宾休息室权益。', 'GOLD', 12, 0, '2026-10-20', '2027-03-31', 1, 95, '2026-10-16 16:01:18', '2026-10-16 16:01:18');
INSERT INTO `mb_discount` VALUES (3, '私享购物日 · 全场 8 折', '连卡佛 Lane Crawford', '购物', 'RATE', 0.80, 0.00, 0.00, 5000.00, 4000.00, '🛍️', '独家,双倍积分', '闭店专场导购陪同选购，会员享全场 8 折并叠加双倍积分返还。', 'ALL', 80, 0, '2026-10-16', '2027-12-31', 1, 90, '2026-10-16 16:01:18', '2026-10-16 16:01:18');
INSERT INTO `mb_discount` VALUES (4, '安缦 SPA · 双人疗愈套餐', 'Aman Spa', '生活', 'RATE', 0.70, 0.00, 0.00, 4680.00, 3276.00, '💆', '口碑,周末可用', '120 分钟双人山泉疗愈与热石按摩，周末与节假日通用，含双人下午茶。', 'GOLD', 20, 0, '2026-10-16', '2027-09-30', 1, 88, '2026-10-16 16:01:18', '2026-10-16 16:01:18');
INSERT INTO `mb_discount` VALUES (5, '私人包厢观演 · 交响乐团专场', '上海交响乐团', '文娱', 'SPECIAL', 1.00, 0.00, 0.00, 1980.00, 1580.00, '🎭', '席位紧张', '二楼私人包厢六座含中场酒水，后台导览与乐手签名节目单。', 'ALL', 15, 0, '2026-11-15', '2027-05-31', 1, 85, '2026-10-16 16:01:18', '2026-10-16 16:01:18');
INSERT INTO `mb_discount` VALUES (6, '精品咖啡豆年卡 · 每月直送', '明前手冲研究所', '生活', 'RATE', 0.75, 0.00, 0.00, 1680.00, 1260.00, '☕', '包邮,可续订', '十二期单一庄园豆按月冷链直送，附产地手记与冲煮参数卡。', 'ALL', 50, 0, '2026-10-16', '2027-12-31', 1, 80, '2026-10-16 16:01:18', '2026-10-16 16:01:18');
INSERT INTO `mb_discount` VALUES (7, '奢华酒店联盟 · 住三付二', '全球奢华酒店联盟', '旅行', 'SPECIAL', 1.00, 0.00, 0.00, 12000.00, 8000.00, '🏨', '爆款,长住推荐', '安缦 / 六善等成员酒店连住三晚仅付两晚，含双人早餐与 100 美元消费额度。', 'PLATINUM', 8, 0, '2026-12-01', '2027-11-30', 1, 92, '2026-10-16 16:01:18', '2026-10-16 16:01:18');
INSERT INTO `mb_discount` VALUES (8, '酒庄直采香槟 · 整箱立减', 'Maison AURELIA', '餐饮', 'AMOUNT', 1.00, 3000.00, 600.00, 3600.00, 3000.00, '🍾', '新上架', '勃艮第名家年份香槟整箱 6 支，满 3000 元立减 600 元并附恒温酒柜配送。', 'ALL', 40, 0, '2026-10-16', '2027-08-31', 1, 70, '2026-10-16 16:01:18', '2026-10-16 16:01:18');

-- ----------------------------
-- Table structure for mb_goods
-- ----------------------------
DROP TABLE IF EXISTS `mb_goods`;
CREATE TABLE `mb_goods`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '商品名称',
  `subtitle` varchar(160) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '副标题/卖点',
  `category` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '分类：手办潮玩/数码影音/生活方式/美妆香氛/藏书文创',
  `emoji` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '◈' COMMENT '商品主图（图标占位）',
  `tags` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '标签，逗号分隔',
  `original_price` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '原价',
  `member_price` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '会员专享价',
  `points_price` int NOT NULL DEFAULT 0 COMMENT '纯积分兑换所需积分，0 表示不支持',
  `stock` int NOT NULL DEFAULT 0 COMMENT '库存',
  `sales` int NOT NULL DEFAULT 0 COMMENT '累计销量',
  `rating` decimal(2, 1) NOT NULL DEFAULT 5.0 COMMENT '评分',
  `level_limit` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'ALL' COMMENT '适用等级：ALL / GOLD / PLATINUM / BLACK',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：1 上架 0 下架',
  `sort_weight` int NOT NULL DEFAULT 0 COMMENT '排序权重，越大越靠前',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_category`(`category` ASC) USING BTREE,
  INDEX `idx_status_sort`(`status` ASC, `sort_weight` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 9 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '会员专属好物表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of mb_goods
-- ----------------------------
INSERT INTO `mb_goods` VALUES (1, '限定和风手办 · 锦鲤姬 1/7', '会员专属限量编号 / 附收藏证书', '手办潮玩', '🎎', '会员专享,限量编号', 1999.00, 1499.00, 149900, 60, 328, 4.9, 'ALL', 1, 100, '2026-10-16 16:01:18', '2026-10-16 16:01:18');
INSERT INTO `mb_goods` VALUES (2, '联名降噪头戴耳机', '主动降噪 / 40 小时续航', '数码影音', '🎧', '新品,直降460', 2299.00, 1839.00, 183900, 120, 856, 4.8, 'ALL', 1, 96, '2026-10-16 16:01:18', '2026-10-16 16:01:18');
INSERT INTO `mb_goods` VALUES (3, '东方调 · 沉香香氛礼盒', '三支装香氛 + 扩香石', '美妆香氛', '🕯️', '热销,礼盒装', 899.00, 679.00, 67900, 200, 1240, 4.7, 'ALL', 1, 94, '2026-10-16 16:01:18', '2026-10-16 16:01:18');
INSERT INTO `mb_goods` VALUES (4, '典藏 · 浮世绘复刻版画集', '限印 1000 册 / 编号藏书票', '藏书文创', '📚', '限印,编号', 699.00, 559.00, 55900, 80, 412, 4.9, 'ALL', 1, 88, '2026-10-16 16:01:18', '2026-10-16 16:01:18');
INSERT INTO `mb_goods` VALUES (5, '手作银壶 · 工夫茶具组', '匠人手打 / 含公道杯双杯', '生活方式', '🫖', '手作,单件孤品', 2680.00, 1980.00, 198000, 15, 96, 5.0, 'GOLD', 1, 92, '2026-10-16 16:01:18', '2026-10-16 16:01:18');
INSERT INTO `mb_goods` VALUES (6, '山羊绒 · 双面水波纹围巾', '内蒙白绒山羊 / 会员礼盒', '生活方式', '🧣', '秋冬新品', 1580.00, 1180.00, 118000, 150, 603, 4.6, 'ALL', 1, 84, '2026-10-16 16:01:18', '2026-10-16 16:01:18');
INSERT INTO `mb_goods` VALUES (7, '限定编号钢笔 + 皮面手账', '14K 金尖 / 意大利植鞣皮', '藏书文创', '🖋️', '会员限定', 1080.00, 788.00, 78800, 60, 271, 4.8, 'ALL', 1, 82, '2026-10-16 16:01:18', '2026-10-16 16:01:18');
INSERT INTO `mb_goods` VALUES (8, '限量版无线手柄 · 会员主题', '附专属动态主题与收纳包', '数码影音', '🎮', '首发预售', 799.00, 599.00, 59900, 300, 1890, 4.7, 'ALL', 1, 80, '2026-10-16 16:01:18', '2026-10-16 16:01:18');

-- ----------------------------
-- Table structure for mb_user_coupon
-- ----------------------------
DROP TABLE IF EXISTS `mb_user_coupon`;
CREATE TABLE `mb_user_coupon`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` bigint NOT NULL COMMENT '领取会员 ID',
  `discount_id` bigint NOT NULL COMMENT '所属折扣 ID',
  `coupon_code` varchar(24) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '券码',
  `status` tinyint NOT NULL DEFAULT 0 COMMENT '状态：0 未使用 1 已核销 2 已过期',
  `claimed_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '领取时间',
  `used_at` datetime NULL DEFAULT NULL COMMENT '核销时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_coupon_code`(`coupon_code` ASC) USING BTREE,
  INDEX `idx_user_status`(`user_id` ASC, `status` ASC) USING BTREE,
  INDEX `idx_discount`(`discount_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '会员卡包表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of mb_user_coupon
-- ----------------------------

-- ----------------------------
-- Table structure for sys_admin
-- ----------------------------
DROP TABLE IF EXISTS `sys_admin`;
CREATE TABLE `sys_admin`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '登录账号（唯一）',
  `password` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '密码（加盐 SHA-256 哈希）',
  `salt` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '密码盐值',
  `nickname` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '显示昵称',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：1 启用 0 停用',
  `last_login_at` datetime NULL DEFAULT NULL COMMENT '最后登录时间',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_admin_username`(`username` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '后台管理员账号表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_admin
-- ----------------------------
INSERT INTO `sys_admin` VALUES (1, 'admin', '457a2ff654a76ac5a19ce5a4e04e5c54ad717e94712db4dc28d54c03d13c452b', 'a1b2c3d4e5f60718293a4b5c6d7e8f90', '系统管理员', 1, '2026-10-26 11:39:05', '2026-10-26 11:24:02', '2026-10-26 11:39:05');

-- ----------------------------
-- Table structure for sys_user
-- ----------------------------
DROP TABLE IF EXISTS `sys_user`;
CREATE TABLE `sys_user`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '用户名（唯一）',
  `password` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '密码（加盐 SHA-256 哈希）',
  `salt` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '密码盐值',
  `member_level` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'GOLD' COMMENT '会员等级',
  `points` int NOT NULL DEFAULT 0 COMMENT '会员积分',
  `member_expire_at` date NULL DEFAULT NULL COMMENT '会员有效期',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_username`(`username` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '系统用户表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_user
-- ----------------------------
INSERT INTO `sys_user` VALUES (1, 'admin', '6a65e9fc69984d6dbb31378c4c63fbb52ca164cd2b20215190aae7e5369b1a3c', '0f1e2d3c4b5a69788796a5b4c3d2e1f0', 'GOLD', 12480, '2027-12-31', '2026-10-12 10:48:07', '2026-10-16 15:56:19');
INSERT INTO `sys_user` VALUES (2, 'yuzhouchangwan', 'ce1ff2965a70baf37cb83451f16febf801b4e8042828188624e244b662a07cd3', '13a338906894022bd37dea1ea648cbf6', 'GOLD', 12480, '2027-12-31', '2026-10-12 11:04:12', '2026-10-16 15:56:19');

SET FOREIGN_KEY_CHECKS = 1;
