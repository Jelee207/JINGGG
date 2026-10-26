package com.fenglin.springboottest.dto;

import java.util.List;

/**
 * 拍品 VO：字段结构与前端 AuctionView 的 lot 对象一一对应。
 * openTime / endTime / bids[].time 均为 epoch 毫秒，便于前端统一做倒计时。
 */
public record LotDTO(
        Long id,
        String title,
        String category,
        String icon,
        Integer hue,
        String desc,
        Long startPrice,
        Long currentPrice,
        Long increment,
        Long openTime,
        Long endTime,
        Integer bidCount,
        Integer watch,
        List<BidDTO> bids
) {
}
