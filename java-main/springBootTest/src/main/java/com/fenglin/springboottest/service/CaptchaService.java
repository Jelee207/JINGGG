package com.fenglin.springboottest.service;

import com.fenglin.springboottest.common.CaptchaUtil;
import com.fenglin.springboottest.dto.CaptchaVO;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;
import org.springframework.stereotype.Service;

/**
 * 图形验证码服务（内存存储，一次性使用）。
 * 生产环境建议改为 Redis：key = token，value = code，并设置过期时间。
 */
@Service
public class CaptchaService {

    private final Map<String, String> store = new ConcurrentHashMap<>();

    /** 生成验证码，返回 token 与 base64 图片 */
    public CaptchaVO create() throws Exception {
        CaptchaUtil.Captcha c = CaptchaUtil.generate();
        String token = UUID.randomUUID().toString().replace("-", "");
        // 统一转大写，便于前端不区分大小写输入
        store.put(token, c.code.toUpperCase());
        return new CaptchaVO(token, c.base64);
    }

    /** 校验并销毁（一次性）：token 不存在/已用过/不匹配均返回 false */
    public boolean validate(String token, String code) {
        if (token == null || code == null) {
            return false;
        }
        String expected = store.remove(token);
        if (expected == null) {
            return false;
        }
        return expected.equalsIgnoreCase(code.trim());
    }
}
