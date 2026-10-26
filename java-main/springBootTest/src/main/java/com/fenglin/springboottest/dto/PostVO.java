package com.fenglin.springboottest.dto;

/** 首页精选内容 VO（desc 对应实体 summary，date 为 MM-dd 短格式） */
public record PostVO(
        Long id,
        String category,
        String date,
        String title,
        String desc,
        String author,
        String city,
        Integer readCount,
        Integer likeCount,
        String tags
) {
}
