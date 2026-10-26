package com.fenglin.springboottest.dto;

/** 出价记录 VO：user 出价人（脱敏昵称），amount 金额，time epoch 毫秒 */
public record BidDTO(String user, Long amount, Long time) {
}
