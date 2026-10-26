package com.fenglin.springboottest.service;

import com.fenglin.springboottest.dto.BidDTO;
import com.fenglin.springboottest.dto.LotDTO;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import org.springframework.stereotype.Service;

/**
 * 竞拍服务（演示用内存存储，无需建表即可启动）。
 *
 * 项目其余模块走 MyBatis-Plus + MySQL；竞拍为演示数据，这里用内存 Map 模拟，
 * 对外 DTO 与接口保持不变。后续接入真实库时，把本类的读写替换为
 * AuctionLotMapper / AuctionBidMapper，并补充 auction_lot / auction_bid 两张表即可，
 * Controller 与前端无需改动。
 */
@Service
public class AuctionService {

    private final Map<Long, Lot> store = new ConcurrentHashMap<>();

    public AuctionService() {
        seed();
    }

    /** 拍品列表（按结束时间升序，即将结束的排在前面） */
    public List<LotDTO> listLots() {
        return store.values().stream()
                .sorted(Comparator.comparingLong(l -> l.endTime))
                .map(this::toDTO)
                .toList();
    }

    public LotDTO getLot(Long id) {
        Lot lot = store.get(id);
        return lot == null ? null : toDTO(lot);
    }

    /**
     * 出价。校验拍品存在、处于进行中、金额达标；达标后更新当前价与出价数并前置写入出价记录。
     * 失败抛异常，由 Controller 转成 Result.error。
     */
    public synchronized LotDTO placeBid(Long lotId, long amount, String username) {
        Lot lot = store.get(lotId);
        if (lot == null) return null;
        long now = System.currentTimeMillis();
        if (now < lot.openTime || now >= lot.endTime) {
            throw new IllegalStateException("拍卖未开始或已结束");
        }
        long min = lot.currentPrice + lot.increment;
        if (amount < min) {
            throw new IllegalArgumentException("出价需不低于 " + min);
        }
        lot.currentPrice = amount;
        lot.bidCount += 1;
        String who = (username == null || username.isEmpty()) ? "尊贵会员" : username;
        lot.bids.add(0, new Bid(who, amount, now));
        return toDTO(lot);
    }

    private LotDTO toDTO(Lot l) {
        List<BidDTO> bids = l.bids.stream()
                .map(b -> new BidDTO(b.user, b.amount, b.time))
                .toList();
        return new LotDTO(l.id, l.title, l.category, l.icon, l.hue, l.desc,
                l.startPrice, l.currentPrice, l.increment, l.openTime, l.endTime,
                l.bidCount, l.watch, bids);
    }

    /* ===================== 内存种子数据（与前端 mock 一致） ===================== */
    private void seed() {
        long now = System.currentTimeMillis();
        long H = 3_600_000L;
        long M = 60_000L;

        add(new Lot(1L, "赵无极 · 抽象水墨《风起》", "艺术珍品", "🖼️", 38,
                "二十世纪抽象大师晚年代表作，绢本水墨，附鉴定证书与展览记录。",
                1_200_000L, 1_860_000L, 50_000L, now - 2 * H, now + 5 * H, 23, 156,
                bids(new Bid("会员 C***", 1_860_000L, now - 8 * M),
                        new Bid("会员 L***", 1_810_000L, now - 25 * M),
                        new Bid("会员 W***", 1_760_000L, now - 70 * M))));

        add(new Lot(2L, "百达翡丽 5711 蓝盘腕表", "珠宝腕表", "⌚", 42,
                "经典 Nautilus 运动钢表，附原厂保卡与表盒，品相近全新。",
                380_000L, 520_000L, 20_000L, now - 1 * H, now + 3 * H, 17, 203,
                bids(new Bid("会员 Z***", 520_000L, now - 5 * M),
                        new Bid("会员 Q***", 500_000L, now - 40 * M))));

        add(new Lot(3L, "罗曼尼康帝 1999 整箱（6 瓶）", "珍稀佳酿", "🍷", 34,
                "勃艮第之王巅峰年份，原木箱封存，恒温酒窖直出。",
                600_000L, 880_000L, 30_000L, now - 30 * M, now + 8 * H, 31, 178,
                bids(new Bid("会员 K***", 880_000L, now - 2 * M),
                        new Bid("会员 X***", 850_000L, now - 18 * M),
                        new Bid("会员 M***", 820_000L, now - 55 * M))));

        add(new Lot(4L, "爱马仕 喜马拉雅 Birkin 25", "奢品皮具", "👜", 46,
                "雾面尼罗鳄鱼皮搭配白金件，殿堂级收藏，即将开拍。",
                900_000L, 900_000L, 50_000L, now + 2 * H, now + 26 * H, 0, 264,
                new ArrayList<>()));

        add(new Lot(5L, "私人岛屿 48 小时包船体验", "私享体验", "🛥️", 36,
                "地中海蓝岸专属行程，含米其林主厨随行与管家团队。",
                150_000L, 210_000L, 10_000L, now - 6 * H, now + 1 * H, 12, 97,
                bids(new Bid("会员 V***", 210_000L, now - 12 * M),
                        new Bid("会员 D***", 200_000L, now - 60 * M))));

        add(new Lot(6L, "常玉《曲腿裸女》素描手稿", "艺术珍品", "✏️", 40,
                "二十世纪东方现代主义先驱纸本素描，已结束拍卖。",
                800_000L, 1_500_000L, 50_000L, now - 48 * H, now - 20 * H, 41, 312,
                bids(new Bid("会员 S***", 1_500_000L, now - 21 * H),
                        new Bid("会员 R***", 1_450_000L, now - 22 * H))));

        add(new Lot(7L, "卡地亚 猎豹胸针", "珠宝腕表", "💎", 44,
                "18K 黄金镶嵌缟玛瑙与钻石，品牌档案可查，附证书。",
                260_000L, 360_000L, 15_000L, now - 4 * H, now + 12 * H, 9, 121,
                bids(new Bid("会员 F***", 360_000L, now - 15 * M),
                        new Bid("会员 G***", 345_000L, now - 90 * M))));

        add(new Lot(8L, "麦卡伦 1926 单一麦芽威士忌", "珍稀佳酿", "🥃", 32,
                "传奇年份珍稀装瓶，全球极少数量，即将开拍。",
                1_500_000L, 1_500_000L, 100_000L, now + 5 * H, now + 29 * H, 0, 188,
                new ArrayList<>()));

        add(new Lot(9L, "路易威登 古董硬箱旅行套装", "奢品皮具", "🧳", 48,
                "1920 年代定制硬箱，含梳妆与文具隔层，收藏级品相。",
                120_000L, 175_000L, 8_000L, now - 3 * H, now + 6 * H, 14, 83,
                bids(new Bid("会员 B***", 175_000L, now - 7 * M),
                        new Bid("会员 N***", 167_000L, now - 48 * M))));
    }

    private void add(Lot lot) {
        store.put(lot.id, lot);
    }

    private static List<Bid> bids(Bid... bs) {
        return new ArrayList<>(Arrays.asList(bs));
    }

    /* ---------------- 内存模型（可变，仅服务内部使用） ---------------- */
    private static class Lot {
        Long id;
        String title;
        String category;
        String icon;
        int hue;
        String desc;
        long startPrice;
        long currentPrice;
        long increment;
        long openTime;
        long endTime;
        int bidCount;
        int watch;
        List<Bid> bids;

        Lot(Long id, String title, String category, String icon, int hue, String desc,
            long startPrice, long currentPrice, long increment, long openTime, long endTime,
            int bidCount, int watch, List<Bid> bids) {
            this.id = id;
            this.title = title;
            this.category = category;
            this.icon = icon;
            this.hue = hue;
            this.desc = desc;
            this.startPrice = startPrice;
            this.currentPrice = currentPrice;
            this.increment = increment;
            this.openTime = openTime;
            this.endTime = endTime;
            this.bidCount = bidCount;
            this.watch = watch;
            this.bids = bids;
        }
    }

    private static class Bid {
        String user;
        long amount;
        long time;

        Bid(String user, long amount, long time) {
            this.user = user;
            this.amount = amount;
            this.time = time;
        }
    }
}
