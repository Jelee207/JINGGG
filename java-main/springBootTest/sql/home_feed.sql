-- ============================================================
-- AURELIA CLUB · 首页（展示 + 搜索）—— 建表 + 演示数据脚本
-- 数据库：springboot_test（MySQL 8.0，root/123456）
-- 用法：mysql -uroot -p123456 --default-character-set=utf8mb4 < sql/home_feed.sql
-- 幂等：表与数据均有存在性判断，可重复执行
--
-- 三张表：
--   home_category     首页分类快捷入口
--   home_post         编辑精选内容（首页信息流 + 搜索数据源）
--   home_hot_keyword  热门搜索词
-- ============================================================

CREATE DATABASE IF NOT EXISTS springboot_test
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_general_ci;

USE springboot_test;

-- 1) 首页分类快捷入口
CREATE TABLE IF NOT EXISTS `home_category` (
  `id`          BIGINT      NOT NULL AUTO_INCREMENT COMMENT '主键',
  `icon`        VARCHAR(10) NOT NULL DEFAULT '✦' COMMENT '分类图标（符号/emoji）',
  `name`        VARCHAR(30) NOT NULL COMMENT '分类名称',
  `summary`     VARCHAR(60) NOT NULL DEFAULT '' COMMENT '一句话描述',
  `keyword`     VARCHAR(60) NOT NULL DEFAULT '' COMMENT '点击分类时提交的搜索词',
  `sort_weight` INT         NOT NULL DEFAULT 0 COMMENT '排序权重，越大越靠前',
  `status`      TINYINT     NOT NULL DEFAULT 1 COMMENT '状态：1 启用 0 停用',
  `created_at`  DATETIME    DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`  DATETIME    DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_status_sort` (`status`, `sort_weight`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='首页分类表';

-- 2) 编辑精选内容（首页信息流 / 搜索主表）
CREATE TABLE IF NOT EXISTS `home_post` (
  `id`          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
  `title`       VARCHAR(120) NOT NULL COMMENT '标题',
  `summary`     VARCHAR(255) NOT NULL DEFAULT '' COMMENT '摘要（列表页展示）',
  `content`     TEXT         NULL COMMENT '正文（列表页不返回）',
  `category`    VARCHAR(30)  NOT NULL DEFAULT '' COMMENT '所属分类',
  `cover`       VARCHAR(255) NOT NULL DEFAULT '' COMMENT '封面图 URL，为空时前端用图标占位',
  `author`      VARCHAR(40)  NOT NULL DEFAULT '' COMMENT '作者/责编',
  `city`        VARCHAR(40)  NOT NULL DEFAULT '' COMMENT '关联城市/目的地',
  `read_count`  INT          NOT NULL DEFAULT 0 COMMENT '阅读数',
  `like_count`  INT          NOT NULL DEFAULT 0 COMMENT '点赞数',
  `tags`        VARCHAR(120) NOT NULL DEFAULT '' COMMENT '标签，逗号分隔',
  `publish_at`  DATETIME     NULL COMMENT '发布时间',
  `status`      TINYINT      NOT NULL DEFAULT 1 COMMENT '状态：1 已发布 0 草稿',
  `sort_weight` INT          NOT NULL DEFAULT 0 COMMENT '排序权重，越大越靠前',
  `created_at`  DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`  DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_category` (`category`),
  KEY `idx_status_publish` (`status`, `publish_at`),
  KEY `idx_title` (`title`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='首页精选内容表';

-- 3) 热门搜索词
CREATE TABLE IF NOT EXISTS `home_hot_keyword` (
  `id`          BIGINT     NOT NULL AUTO_INCREMENT COMMENT '主键',
  `keyword`     VARCHAR(30) NOT NULL COMMENT '搜索词',
  `heat`        INT        NOT NULL DEFAULT 0 COMMENT '热度值',
  `sort_weight` INT        NOT NULL DEFAULT 0 COMMENT '排序权重，越大越靠前',
  `status`      TINYINT    NOT NULL DEFAULT 1 COMMENT '状态：1 启用 0 停用',
  `created_at`  DATETIME   DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`  DATETIME   DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_keyword` (`keyword`),
  KEY `idx_status_sort` (`status`, `sort_weight`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='首页热门搜索词表';

-- ============================================================
-- 4) 演示数据（仅当表为空时插入）
-- ============================================================

SET @hf_has_category = (SELECT COUNT(*) FROM `home_category`);

INSERT INTO `home_category` (`icon`, `name`, `summary`, `keyword`, `sort_weight`)
SELECT '❖', '私人礼遇', '管家式定制服务', '私人礼遇', 60 FROM DUAL WHERE @hf_has_category = 0;
INSERT INTO `home_category` (`icon`, `name`, `summary`, `keyword`, `sort_weight`)
SELECT '◈', '餐饮甄选', '米其林主厨餐桌', '餐饮', 55 FROM DUAL WHERE @hf_has_category = 0;
INSERT INTO `home_category` (`icon`, `name`, `summary`, `keyword`, `sort_weight`)
SELECT '✦', '旅行栖居', '全球奢华酒店礼遇', '旅行', 50 FROM DUAL WHERE @hf_has_category = 0;
INSERT INTO `home_category` (`icon`, `name`, `summary`, `keyword`, `sort_weight`)
SELECT '◆', '艺术文化', '私人画廊与沙龙', '艺术', 45 FROM DUAL WHERE @hf_has_category = 0;
INSERT INTO `home_category` (`icon`, `name`, `summary`, `keyword`, `sort_weight`)
SELECT '❋', '健康生活', '高端康养与 SPA', '康养', 40 FROM DUAL WHERE @hf_has_category = 0;
INSERT INTO `home_category` (`icon`, `name`, `summary`, `keyword`, `sort_weight`)
SELECT '✧', '会员活动', '专属线下聚会', '会员活动', 35 FROM DUAL WHERE @hf_has_category = 0;

-- ---------- 精选内容 ----------
SET @hf_has_post = (SELECT COUNT(*) FROM `home_post`);

INSERT INTO `home_post`
  (`title`, `summary`, `content`, `category`, `author`, `city`,
   `read_count`, `like_count`, `tags`, `publish_at`, `sort_weight`)
SELECT '京都 · 枫叶季私邸栖居七日',
       '入住百年町家改造私邸，随茶道师体验一期一会的秋日茶席，专车漫游东山暮色。',
       '全文：十一月的京都，晨雾自鸭川升起。我们为您保留了东山脚下三栋百年町家中的主栋， 随行茶道师将在枯山水庭院铺设席位，以当季和果子佐宇治抹茶。行程含专车接送、 和服私装指导与米其林一星怀石晚宴各一次。',
       '旅行栖居', '编辑部 · 林', '京都', 1820, 236, '旅行,日本,赏枫,私邸',
       '2026-10-12 09:00:00', 100 FROM DUAL WHERE @hf_has_post = 0;

INSERT INTO `home_post`
  (`title`, `summary`, `content`, `category`, `author`, `city`,
   `read_count`, `like_count`, `tags`, `publish_at`, `sort_weight`)
SELECT '秋暮主厨餐桌 · 八道式品鉴晚宴',
       '米其林二星主厨应季菜单，侍酒师配对勃艮第名家年份，仅设十二席。',
       '全文：本季菜单以栗子、鲷鱼与鹿肉为三条主线，主厨将在开放厨房前完成最后一道工序。 侍酒师准备了五款勃艮第村级以上年份配酒，全场仅十二席，须于三日前预订。',
       '餐饮甄选', '编辑部 · 苏', '上海', 2460, 418, '餐饮,米其林,晚宴,品鉴',
       '2026-10-10 18:30:00', 96 FROM DUAL WHERE @hf_has_post = 0;

INSERT INTO `home_post`
  (`title`, `summary`, `content`, `category`, `author`, `city`,
   `read_count`, `like_count`, `tags`, `publish_at`, `sort_weight`)
SELECT '私人画廊之夜：当代水墨新声',
       '闭馆专场导览，与艺术家对谈，率先预订限量版画收藏席位。',
       '全文：美术馆闭馆后两小时，策展人与参展艺术家将以圆桌形式分享创作脉络。 现场开放十二位限量编号版画的优先认购权，附艺术家签名证书。',
       '艺术文化', '编辑部 · 何', '北京', 1140, 173, '艺术,展览,水墨,收藏',
       '2026-10-08 20:00:00', 92 FROM DUAL WHERE @hf_has_post = 0;

INSERT INTO `home_post`
  (`title`, `summary`, `content`, `category`, `author`, `city`,
   `read_count`, `like_count`, `tags`, `publish_at`, `sort_weight`)
SELECT '黄浦江畔 · 私享游艇酒会',
       '落日巡游与香槟品鉴，结识同席会员，限额三十位，凭会员码报名。',
       '全文：自十六铺启航，沿外滩经典航线巡游两小时。船上提供沙龙香槟与轻盈小食， 甲板爵士三重奏现场演奏。限额三十位，请凭会员码提前报名。',
       '会员活动', '编辑部 · 周', '上海', 3080, 502, '活动,游艇,酒会,社交',
       '2026-10-05 17:00:00', 88 FROM DUAL WHERE @hf_has_post = 0;

INSERT INTO `home_post`
  (`title`, `summary`, `content`, `category`, `author`, `city`,
   `read_count`, `like_count`, `tags`, `publish_at`, `sort_weight`)
SELECT '山间疗愈 · 森林冥想康养营',
       '三日两夜山居静修，颂钵疗愈与有机轻食，为身心按下暂停键。',
       '全文：海拔一千二百米的森林腹地，晨起瑜伽与溪畔冥想，午后颂钵与芳疗按摩。 饮食由营养师定制，全部取自五十公里内的有机农场。',
       '健康生活', '编辑部 · 叶', '莫干山', 1360, 288, '康养,SPA,冥想,静修',
       '2026-10-02 07:00:00', 84 FROM DUAL WHERE @hf_has_post = 0;

INSERT INTO `home_post`
  (`title`, `summary`, `content`, `category`, `author`, `city`,
   `read_count`, `like_count`, `tags`, `publish_at`, `sort_weight`)
SELECT '管家服务升级：全球行程一站托管',
       '签证、专车、餐厅与活动预订全程代办，您的专属礼宾团队已就位。',
       '全文：礼宾团队扩充至十二时区覆盖，支持签证代办、私人专机、餐厅与演出票务、 以及行程突发状况的即时响应。会员可通过专属顾问随时呼叫。',
       '私人礼遇', '编辑部 · 林', '全球', 2210, 361, '礼遇,管家,礼宾,出行',
       '2026-09-28 10:00:00', 80 FROM DUAL WHERE @hf_has_post = 0;

INSERT INTO `home_post`
  (`title`, `summary`, `content`, `category`, `author`, `city`,
   `read_count`, `like_count`, `tags`, `publish_at`, `sort_weight`)
SELECT '阿尔卑斯 · 雪季木屋与私人滑雪教练',
       '开窗即雪山的双卧木屋，配私人教练与雪场优先通道，含温泉疗愈。',
       '全文：木屋位于海拔一千八百米的雪场腹地，含独立桑拿与恒温泳池。 配备退役国家队教练一对一指导，并提供雪具寄送与会籍礼遇。',
       '旅行栖居', '编辑部 · 苏', '采尔马特', 1580, 244, '旅行,滑雪,雪山,欧洲',
       '2026-09-24 09:00:00', 76 FROM DUAL WHERE @hf_has_post = 0;

INSERT INTO `home_post`
  (`title`, `summary`, `content`, `category`, `author`, `city`,
   `read_count`, `like_count`, `tags`, `publish_at`, `sort_weight`)
SELECT '日内瓦高级制表私享品鉴',
       '独立制表师现场拆解机芯，开放三枚限量作品的优先认购。',
       '全文：沙龙设于制表工坊二层，制表师将演示陀飞轮装配过程。 现场开放三枚编号作品的优先认购权，附终身保养服务。',
       '艺术文化', '编辑部 · 何', '日内瓦', 980, 156, '腕表,制表,沙龙,收藏',
       '2026-09-20 15:00:00', 72 FROM DUAL WHERE @hf_has_post = 0;

INSERT INTO `home_post`
  (`title`, `summary`, `content`, `category`, `author`, `city`,
   `read_count`, `like_count`, `tags`, `publish_at`, `sort_weight`)
SELECT '地中海私人岛宴 · 十二席位',
       '厨师团队包岛定制菜单，日落帆船接送，夜宿临海 villa 套房。',
       '全文：整座私人小岛当晚仅接待十二位会员，长桌沿崖边铺设。 菜单依据当日渔获即时调整，含私人侍酒师配酒与现场弦乐四重奏。',
       '餐饮甄选', '编辑部 · 周', '卡普里', 1740, 322, '餐饮,私宴,海岛,定制',
       '2026-09-15 19:00:00', 68 FROM DUAL WHERE @hf_has_post = 0;

INSERT INTO `home_post`
  (`title`, `summary`, `content`, `category`, `author`, `city`,
   `read_count`, `like_count`, `tags`, `publish_at`, `sort_weight`)
SELECT '会员回馈月 · 双倍积分与生日礼遇',
       '整月消费双倍积分，生日当月额外获赠专属礼盒与蛋糕定制。',
       '全文：本月所有预订与消费均累计双倍积分，可于会员商城兑换限定好物。 生日当月会员额外获赠定制礼盒、蛋糕与主厨手写贺卡。',
       '会员活动', '编辑部 · 叶', '全球', 4120, 736, '活动,积分,福利,生日',
       '2026-09-10 11:00:00', 64 FROM DUAL WHERE @hf_has_post = 0;

-- ---------- 热门搜索词 ----------
SET @hf_has_hot = (SELECT COUNT(*) FROM `home_hot_keyword`);

INSERT INTO `home_hot_keyword` (`keyword`, `heat`, `sort_weight`)
SELECT '京都赏枫', 986, 40 FROM DUAL WHERE @hf_has_hot = 0;
INSERT INTO `home_hot_keyword` (`keyword`, `heat`, `sort_weight`)
SELECT '米其林晚宴', 872, 35 FROM DUAL WHERE @hf_has_hot = 0;
INSERT INTO `home_hot_keyword` (`keyword`, `heat`, `sort_weight`)
SELECT '私享游艇', 654, 30 FROM DUAL WHERE @hf_has_hot = 0;
INSERT INTO `home_hot_keyword` (`keyword`, `heat`, `sort_weight`)
SELECT '艺术沙龙', 531, 25 FROM DUAL WHERE @hf_has_hot = 0;
INSERT INTO `home_hot_keyword` (`keyword`, `heat`, `sort_weight`)
SELECT '康养静修', 418, 20 FROM DUAL WHERE @hf_has_hot = 0;
INSERT INTO `home_hot_keyword` (`keyword`, `heat`, `sort_weight`)
SELECT '滑雪木屋', 376, 15 FROM DUAL WHERE @hf_has_hot = 0;

-- 5) 核对
--    SELECT (SELECT COUNT(*) FROM home_category) c,
--           (SELECT COUNT(*) FROM home_post) p,
--           (SELECT COUNT(*) FROM home_hot_keyword) h;
