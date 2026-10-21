package com.fenglin.springboottest.dto;

/** 登录请求体 */
public record LoginRequest(String username, String password, String captcha, String captchaToken) {
}
