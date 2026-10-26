package com.fenglin.springboottest.dto;

/** 后台管理系统登录请求体（无需验证码） */
public record AdminLoginRequest(String username, String password) {
}
