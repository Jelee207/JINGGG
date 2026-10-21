package com.fenglin.springboottest.dto;

/** 图形验证码返回体：token 提交时回传，image 为 base64 PNG */
public record CaptchaVO(String token, String image) {
}
