package com.fenglin.springboottest.dto;

/** 出价请求体：lotId 拍品 ID，amount 出价金额 */
public record BidRequest(Long lotId, Long amount) {
}
