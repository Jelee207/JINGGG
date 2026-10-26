package com.fenglin.springboottest.controller;

import com.fenglin.springboottest.common.Result;
import com.fenglin.springboottest.dto.BidRequest;
import com.fenglin.springboottest.dto.LotDTO;
import com.fenglin.springboottest.service.AuctionService;
import java.util.List;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestAttribute;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * 竞拍接口（演示数据由 AuctionService 内存提供）。
 * GET  /api/auction/lots   拍品列表（公开，已加入 JWT 白名单）
 * POST /api/auction/bid    出价（需登录，JWT 校验通过后从请求属性取用户名）
 */
@RestController
@RequestMapping("/api/auction")
public class AuctionController {

    private final AuctionService auctionService;

    public AuctionController(AuctionService auctionService) {
        this.auctionService = auctionService;
    }

    /** 拍品列表：GET /api/auction/lots */
    @GetMapping("/lots")
    public Result<List<LotDTO>> lots() {
        return Result.success(auctionService.listLots());
    }

    /** 出价：POST /api/auction/bid  body { lotId, amount } */
    @PostMapping("/bid")
    public Result<LotDTO> bid(@RequestBody BidRequest req,
                             @RequestAttribute(value = "username", required = false) String username) {
        if (req == null || req.lotId() == null) {
            return Result.error("缺少拍品 ID");
        }
        try {
            LotDTO lot = auctionService.placeBid(req.lotId(), req.amount() == null ? 0 : req.amount(), username);
            if (lot == null) return Result.error("拍品不存在");
            return Result.success(lot);
        } catch (IllegalStateException | IllegalArgumentException e) {
            return Result.error(e.getMessage());
        }
    }
}
