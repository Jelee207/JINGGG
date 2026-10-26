package com.fenglin.springboottest.dto;

import java.util.List;

/** 首页展示 VO：结构与前端 HomeView 的 categories / posts / hotKeywords 一一对应 */
public record HomeFeedVO(List<CategoryVO> categories, List<PostVO> posts, List<String> hotKeywords) {
}
