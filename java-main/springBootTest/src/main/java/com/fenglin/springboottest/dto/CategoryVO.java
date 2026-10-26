package com.fenglin.springboottest.dto;

/** 首页分类 VO（desc 对应实体 summary） */
public record CategoryVO(Long id, String icon, String name, String desc, String keyword) {
}
